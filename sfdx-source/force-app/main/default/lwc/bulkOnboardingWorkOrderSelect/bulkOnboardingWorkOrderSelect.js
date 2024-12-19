import {LightningElement, api, track, wire} from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getExistingWorkOrders from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getExistingWorkOrders";

export default class BulkOnboardingWorkOrderSelect extends LightningElement {
    @api accountId;
    @api flowRequestId;
    @track isLoading = true;
    @track workOrders = [];
    @track isNextDisabled = true;
    selectedWorkOrderId;
    _currentStep;
    _hasOpportunityAccess;

    set hasOpportunityAccess(value) {
        this._hasOpportunityAccess = value;
        this.createNewDisabled = !value;
        // Update the title based on the hasOpportunityAccess value
        this.createNewTitle = value ? "" : "You do not have permission to create a new Work Order. Please select from existing.";
    }

    @api
    get hasOpportunityAccess() {
        return this._hasOpportunityAccess;
    }

    @api
    set currentStep(value) {
        this._currentStep = (value) ? value.toString() : "1";
    }

    get currentStep() {
        return this._currentStep;
    }

    @wire(getExistingWorkOrders, { accountId: "$accountId" })
    workOrderList({ error, data }) {
        if (data) {
            this.workOrders = data;
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {            
            this.error = error;
            this.workOrders = undefined;
            this.isLoading = false;
            this.showToast("Error retrieving Work Orders", "Unable to load Work Orders. Please try again later.", "error");
            console.error(error);
        }
    }

    handleSelect(event) {
        this.selectedWorkOrderId = event.target.value;
        this.isNextDisabled = !this.selectedWorkOrderId;
    }

    handleNext() {
        // Check if a work order is selected
        if(this.selectedWorkOrderId) {
            // Create a CustomEvent with the selected Work Order Id
            const selectedEvent = new CustomEvent("workorderselected", {
                detail: this.selectedWorkOrderId
            });
            
            // Dispatch the event to the parent component
            this.dispatchEvent(selectedEvent);
        } else {
            // Handle error if no work order is selected (optional)
            this.showToast("Please select a Work Order", "Select a Work Order before proceeding", "warning");
        }
    }
    switchToWorkOrderCreation() {        
        this.dispatchEvent(new CustomEvent("switchworkordermethod", {
            detail: {
                newType: "creation"
            }
        }));        
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}