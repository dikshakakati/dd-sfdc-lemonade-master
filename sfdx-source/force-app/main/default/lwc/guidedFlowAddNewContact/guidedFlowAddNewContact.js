import { LightningElement, api } from "lwc";
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
export default class GuidedFlowAddNewContact extends LightningElement {
	nameField = NAME_FIELD;
	@api selectedId;
	@api recordId;
	@api objectApiName;
	saveRecord = false;
	displayModal = false;
	/**
	* @description To open Modal dialogue for Contact record
	*/
	showModal(event) {
		this.displayModal = true;
	}
	/**
	* @description To close Modal dialogue for Contact record
	*/
	closeHandler() {
		this.displayModal = false;
	}
	/**
	* @description Create Contact Record Message
	*/
	handleSuccess(event) {
		this.showNotification("", "Contact record has been created", "success");
		this.displayModal = false;
		this.saveRecord = false;
		const attributeChangeEvent = new FlowAttributeChangeEvent('selectedId', event.detail.id);
		this.dispatchEvent(attributeChangeEvent);
	}
	/**
	* @description Show Toast message on contact record creation
	*/
	showNotification(titleText, messageText, variantText) {
		const evt = new ShowToastEvent({
			title: titleText,
			message: messageText,
			variant: variantText,
		});
		this.dispatchEvent(evt);
	}
	/**
	* @description Show Toast message on contact record creation
	*/
	setProcessing(event) {
		this.saveRecord = true;
	}
	/**
	* @description Set Save Record Flag with False on any Error
	*/
	handleError(event) {
		this.saveRecord = false;
	}
}