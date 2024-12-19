/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Component which helps save Search Filters.
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
 import { api, LightningElement } from 'lwc';
 import { createRecord } from 'lightning/uiRecordApi';
 import { stringIsBlank } from 'c/lwcDdUtils';
 import currUserId from '@salesforce/user/Id';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import DD_GRID_REPORT_SAVE_SEARCH_OBJECT from '@salesforce/schema/DD_Grid_Report_Saved_Search__c';
 import DDGRSS_NAME_FIELD from '@salesforce/schema/DD_Grid_Report_Saved_Search__c.Name';
 import DDGRSS_CONFIG_FIELD from '@salesforce/schema/DD_Grid_Report_Saved_Search__c.Config__c';
 import DDGRSS_REPORT_NAME_FIELD from '@salesforce/schema/DD_Grid_Report_Saved_Search__c.Report_Name__c';
 import DDGRSS_OWNER_ID_FIELD from '@salesforce/schema/DD_Grid_Report_Saved_Search__c.OwnerId';

 /*****************************************************************************************************************************
  *
  * Functional Consts
  *
  *****************************************************************************************************************************/
 const ELE_MODAL = '[data-id="modal"]';

export default class LwcDdGridReportSaveSearchFilters extends LightningElement {

    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {Object[]} - Filter config with filter metadata and values
    @api filterConfiguration;
    // {Object} - sort config with sorted by and direction
    @api sortConfiguration;
    // {Object[]} - Fields/Column config
    @api fieldConfiguration;

    @api reportName;
    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
     showModal = false;
     name;

     /*****************************************************************************************************************************
      *
      * Event Handlers
      *
      *****************************************************************************************************************************/
     handleShowModal(event) {
         event.stopPropagation();
         this.showModal = true;
         let control = this.template.querySelector(ELE_MODAL);
         if (control)
             control.show();
         else
             alert('Modal not found in DOM');
     }

     handleNameChange(event) {
        this.name = event.detail.value;
    }

     handleSave(event) {
        event.stopPropagation();
        const fields = {};
        const config = {};
        config['fieldConfiguration'] = this.fieldConfiguration;
        config['sortConfiguration'] = this.sortConfiguration;
        config['filterConfiguration'] = this.filterConfiguration;
        
        fields[DDGRSS_REPORT_NAME_FIELD.fieldApiName] = this.reportName;
        fields[DDGRSS_CONFIG_FIELD.fieldApiName] = JSON.stringify(config);
        fields[DDGRSS_NAME_FIELD.fieldApiName] = this.name;
        fields[DDGRSS_OWNER_ID_FIELD.fieldApiName] = currUserId;
        const ddGridReportSaveSearch = {apiName: DD_GRID_REPORT_SAVE_SEARCH_OBJECT.objectApiName, fields};
        
        createRecord(ddGridReportSaveSearch)
        .then(response => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `The Saved Search named ${this.name} has been created successfully.`,
                    variant: 'Success',
                }),
            );
            this.handleHideModal(); 
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Creating DD Grid Report Saved Search Record',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'sticky',
                }),
            );
        });
     }

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

    get allowSave() {
        return stringIsBlank(this.name);
    }
}