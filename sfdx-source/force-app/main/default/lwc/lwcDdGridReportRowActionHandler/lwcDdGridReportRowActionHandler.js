/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Custom Project specific row actions of the Grid Action Datatable should be here.
 *
 * I have provided a default modal + are you sure modal which can be called easily. feel free to add any other project specific code.
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { api, LightningElement,wire } from 'lwc';
import { stringIsBlank,stringIsNotBlank,isUndefinedOrNull,cloneObject } from 'c/lwcDdUtils';

/*****************************************************************************************************************************
*
* CSS Class Consts
*
*****************************************************************************************************************************/

/*****************************************************************************************************************************
*
* Functional Consts
*
*****************************************************************************************************************************/

const INFO = 'info';
const CONFIRM = 'confirm';
const DIALOG = 'dialog';

const MEDIUM = "medium";
const DEFAULT_AREYOUSURE_TITLE = "Are you sure?";
const DEFAULT_AREYOUSURE_CONTENT = "Are you sure you want to complete this action?";

const CONTROL_MODAL = '[data-id="modal"]';
const CONTROL_AREYOUSURE_MODAL = '[data-id="areYouSureModal"]';

const TAB = 'tab';
const SUBTAB = 'subTab';
const NEW_BROWSER_TAB = 'newBrowserTab';

export default class LwcDdGridReportRowActionHandler extends LightningElement {

    /*****************************************************************************************************************************
    *
    * Public Methods
    *
    *****************************************************************************************************************************/
    /**
     * @decription Called by parent component, custom project specific code can be added here. Please take care of nomenclature here.
     * @param   {String} actionName - Unique <Well defined, proper> name of the action
     *          {Object} row - Row against which the action as triggered against.
     * @return  None
     */
    @api
    handleRowAction(actionName,row) {
        switch (actionName) {
            case 'mxp-user-report_view-account-mxp': // BIZS-466
                this.processMxpUserReportViewAccountMxp(row);
                break;
            default:
                break;
        }
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    showModal = false;
    modalTitle;
    modalContent;
    modalType;
    modalSize = MEDIUM;

    showAreYouSureModal = false;
    areYouSureModalTitle = DEFAULT_AREYOUSURE_TITLE;
    areYouSureModalContent = DEFAULT_AREYOUSURE_CONTENT;

    /*****************************************************************************************************************************
    *
    * UI Getters - Custom getters for variables in the HTML
    *
    *****************************************************************************************************************************/

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // Standard Modal Primary button was clicked
    handleModalPrimaryButtonClick(event) {

    }

    // Standard Modal Secondary button was clicked
    handleModalSecondaryButtonClick(event) {

    }

    // Standard Modal was closed.
    handleModalClose(event) {
        this.showModal = false;
        this.modalTitle = null;
        this.modalContent = null;
        this.modalType = null;
        this.modalSize = MEDIUM;
    }

    // Are You Sure Modal 'Yes' was clicked
    handleAreYouSureYes(event) {

    }

    // Are You Sure Modal 'No' was clicked
    handleAreYouSureNo(event) {

    }

    // Are You Sure Modal is closed.
    handleAreYouSureModalClose(event) {
        this.showAreYouSureModal = false;
        this.showAreYouSureModal = false;
        this.areYouSureModalTitle = DEFAULT_AREYOUSURE_TITLE;
        this.areYouSureModalContent = DEFAULT_AREYOUSURE_CONTENT;
    }

    /*****************************************************************************************************************************
     *
     * Project Specific Logic/Helpers
     *
     *****************************************************************************************************************************/

    /**
     * @decription BIZS-466 - Show the Account MXP in the modal
     * @param   {Object} row - Row against which the action as triggered against.
     * @return  None
     */
    processMxpUserReportViewAccountMxp(row) {
        this.modalTitle = `Account: ${row.AccountName}`;
        this.modalContent = `Account MXP: ${row.AccountMxp}`;
        this.modalType = INFO;
        this.showMainModal();
    }

    /*****************************************************************************************************************************
     *
     * Generic Logic/Helpers
     *
     *****************************************************************************************************************************/

    // Show the main Modal
    showMainModal() {
        this.showModal = true;
        this.showModal_helper(CONTROL_MODAL);
    }

    // Hide the main modal
    hideMainModal() {
        this.showModal = false;
        this.hideModal_helper(CONTROL_MODAL);
    }

    // show the are you sure modal
    showAreYouSureModal() {
        this.showAreYouSureModal = true;
        this.showModal_helper(CONTROL_AREYOUSURE_MODAL);
    }

    // hide the are you sure modal
    hideAreYouSureModal() {
        this.showAreYouSureModal = false;
        this.hideModal_helper(CONTROL_AREYOUSURE_MODAL);
    }

    /**
     * @decription Show Modal
     * @param   {String} controlName - Modal Name
     * @return  None
     */
    showModal_helper(controlName) {
        let control = this.template.querySelector(controlName);
        if (control)
            control.show();
    }

    /**
     * @decription Hide Modal
     * @param   {String} controlName - Modal Name
     * @return  None
     */
    hideModal_helper(controlName) {
        let control = this.template.querySelector(controlName);
        if (control)
            control.hide();
    }

    /**
     * @decription If we need to navigate to an Sobject, this will send to wrapper aura which is implements workspace api.
     * @param   {String} recordId - Id of record to navigate to
     *          {String} openMode - How to open in console - Options: tab,subTab,newBrowserTab
     * @return  None
     */
    processNavigateToSobject(recordId,openMode) {
        const message = {
            recordId: recordId,
            openMode: openMode ?? 'tab'
        };
        const evt = new CustomEvent("navigatetorecord",{
            detail: message,bubbles:true,composed:true
        });
        this.dispatchEvent(evt);
    }
}