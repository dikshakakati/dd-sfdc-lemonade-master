/* eslint-disable guard-for-in */
/*
* @author Deloitte
* @date 10/12/2022
* @description LWC qucik record action for Sync With Netsuite action button
*/
import { LightningElement, api } from "lwc";
import syncWithNetsuite from "@salesforce/apex/SyncWithNetsuiteActionController.syncWithNetsuite";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
export default class SyncWithNetsuite extends LightningElement {
    isLoading = true;
    toastVariant;
    toastMessage;
    responseStatus = 'status';
    utilityType = 'utility:';
    showToastMessagecomponent = 'c-show-toast-message';
    @api
    recordId;
    /**
    * @description Method invoke by Quick Action button
    */
    @api
    invoke() {
        if (this.recordId) {
            this.isLoading = true;
            this.syncWithNetsuiteRequest();
        }
    }
    /**
    * @description
    * Method to validate Payment Account record before Sync with Netsuite
    * Sync with Restlet and Middleware system
    */
    syncWithNetsuiteRequest() {
        syncWithNetsuite(
            {
                paymentAccountId: this.recordId
            }
        ).then((result) => {
            this.toastVariant = result['status'];
            this.toastMessage = result['message'];
        }).catch((error) => {
            this.toastVariant = 'error';
            this.toastMessage = '';
            let errorMessages = error.body.message.split('~~');
            errorMessages.forEach(element => {
                this.toastMessage = this.toastMessage + '<li>' + element + '</li>';
            });
        }).finally(() => {
            this.isLoading = false
            this.showToastMessage(this.toastVariant, this.toastMessage, this.utilityType + this.toastVariant);
            getRecordNotifyChange([{ recordId: this.recordId }]);
        });
    }
    /**
    * @description Generic method to display toast message
    * @param titleVal
    * @param messageVal
    * @param variantVal
    * @param messageDataVal
    * @param modeVal
    */
    showToastMessage(taskVariant, messageVal, utilityType) {
        this.template.querySelector(
            this.showToastMessagecomponent).showToast(
                taskVariant,
                messageVal,
                utilityType,
                10000
            );
    }
    /**
    * @description Invokes when the component is removed from the DOM.
    */
    disconnectedCallback() {
        getRecordNotifyChange([{ recordId: this.recordId }]);
    }
}