import { LightningElement, api, track } from "lwc";

export default class BulkOnboardingExistingRequest extends LightningElement {
    @track showError = false;
    @api workOrderTypeError;

    @api
    handleCreateNew() {
        this.dispatchEvent(new CustomEvent("createnewflow"));
    }

    @api
    handleSelectExisting() {
        this.dispatchEvent(new CustomEvent("continueexistingflow"));
    }

    connectedCallback() {
        if (this.workOrderTypeError !== undefined && this.workOrderTypeError !== null) {
            this.showError = true;
        }
    }

}