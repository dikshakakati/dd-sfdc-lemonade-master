import { wire, LightningElement, api} from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getDDGridReportSavedSearchForCurrentUser from '@salesforce/apex/GridReportCtrl.getDDGridReportSavedSearchForCurrentUser'; 

const columns = [
    { label: 'Action', type: 'button', typeAttributes:{ label: 'Load', name: 'load' , title: 'Load', alternativeText: 'load'}, initialWidth: 80},
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { type: 'button-icon', typeAttributes:{ iconName: 'utility:delete', title: 'Delete', alternativeText: 'delete', name: 'delete' }, initialWidth: 80}
];

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
 const ELE_MODAL = '[data-id="modal"]';
 const NO_SAVED_SEARCH_ERROR = 'There are no saved searches for this report type';
 const DEFAULT_AREYOUSURE_TITLE = "Are you sure?";
 const DEFAULT_AREYOUSURE_CONTENT = "Are you sure you want to delete this saved search?";
 const CONTROL_AREYOUSURE_MODAL = '[data-id="areYouSureModal"]';

export default class LwcDdGridReportShowSavedSearchFilters extends LightningElement {

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    showModal = false;
    savedSearches;
    columns = columns;
    wiredSavedSearches = [];
    errorMessage;
    areYouSureModalTitle = DEFAULT_AREYOUSURE_TITLE;
    areYouSureModalContent = DEFAULT_AREYOUSURE_CONTENT;
    recordId;

    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    @api reportName;

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/
    get doesSavedSearchesExist(){
        return this.savedSearches && this.savedSearches.length > 0;
    }

    /*****************************************************************************************************************************
     *
     * Wires
     *
     *****************************************************************************************************************************/
    @wire(getDDGridReportSavedSearchForCurrentUser, {reportName : '$reportName'})
    getWiredSavedSearches(value) {
        this.wiredSavedSearches = value;
        const {data , error} = value;
        if(data){
            this.errorMessage = data.length === 0 ? this.errorMessage = NO_SAVED_SEARCH_ERROR : null;
            this.savedSearches = data;
        }
        if(error){
            console.log(JSON.stringify(error));
        }
    };

    /*****************************************************************************************************************************
    *
    * Logic / Helper methods
    *
    *****************************************************************************************************************************/
    handleHideModal() {
        this.showModal = false;
        this.name = undefined;
        let control = this.template.querySelector('[data-id="modal"]');
        if (control)
            control.hide();
    }

    // hide the are you sure modal
    hideAreYouSureModal() {
        this.showAreYouSureModal = false;
        let control = this.template.querySelector(CONTROL_AREYOUSURE_MODAL);
        if (control)
            control.hide();
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/
    // Show Modal on Show Saved Searches button click
    handleShowModal(event) {
        event.stopPropagation();
        this.showModal = true;
        let control = this.template.querySelector(ELE_MODAL);
        if (control)
            control.show();
        else
            alert('Modal not found in DOM');

        return refreshApex(this.wiredSavedSearches);
    }

    // When Row Action against DD Saved Search record is clicked
    handleRowAction(event) {
        const action = event.detail.action.name;
        if(action === 'load'){
            const config = JSON.parse(event.detail.row.Config__c);
            event.stopPropagation();
            const evt = new CustomEvent("loadsearch",{
                detail: {config:config}
            });
            this.dispatchEvent(evt);
            this.handleHideModal();
        }
        else if(action === 'delete'){
            this.recordId = event.detail.row.Id;
            let control = this.template.querySelector(CONTROL_AREYOUSURE_MODAL);
            if (control)
                control.show();
        }
    }

    // Are You Sure Modal 'Yes' was clicked
    handleAreYouSureYes() {
        deleteRecord(this.recordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The saved search has been deleted successfully',
                    variant: 'success'
                })
            );
            refreshApex(this.wiredSavedSearches);
            this.recordId = null;
            this.hideAreYouSureModal();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'An error occured while deleting the saved search',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'sticky',
                })
            );
            this.hideAreYouSureModal();
        });
    }

    // Are You Sure Modal 'No' was clicked
    handleAreYouSureNo() {
        this.hideAreYouSureModal();
    }
}