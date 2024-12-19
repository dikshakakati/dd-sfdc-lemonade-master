import { LightningElement, api, track } from "lwc";

export default class BulkOnboardingWorkOrderOptions extends LightningElement {
    @track createNewTitle = "";
    _hasOpportunityAccess;
    _currentStep;

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
    
    // @api setter for currentStep
    @api
    set currentStep(value) {
        this._currentStep = (value) ? value.toString() : "1"; // convert to string and store in private property
    }

    // getter for currentStep
    get currentStep() {
        return this._currentStep; // return the private property value
    }
    
    @api
    handleCreateNew() {
        this.dispatchEvent(new CustomEvent("createnew"));
    }

    @api
    handleSelectExisting() {
        this.dispatchEvent(new CustomEvent("selectexisting"));
    }
}
