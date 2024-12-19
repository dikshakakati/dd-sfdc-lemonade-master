import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecordTypeId from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getPaymentsRecordType";
import canSkipPaymentAccountStep from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.isEligibleToSkipPaymentAccountStep";
import createLog from "@salesforce/apex/LogController.createLog";

const COMPONENT_NAME = "BulkOnboardingPaymentAccount";
const GENERIC_TOAST_ERROR_TITLE = "Failed to Save Payment Account";
const GENERIC_TOAST_ERROR_MESSAGE = "Review and correct errors below.";
const GENERIC_TOAST_ERROR_VARIANT = "error";

export default class BulkOnboardingPaymentAccount extends LightningElement {
    _currentStep; // For currentStep string value

    @api showPaymentAccountSkipOption;
    @api accountId;
    paymentsRecordTypeId;
    selectedPaymentAccountId;
    @track disableButton = true; // Set to "false" when Payment Account is selected
    @track isSaving = true;
    @track createNewFormClass = "slds-hidden";
    @track showCreatePaymentAccountForm = false;
    @track isEligibleForSkipping = false;
    @track promptForFlowSelection = true;
    @track useSingleSelectFlow = false;
    @track useMultiSelectFlow = false;

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
    set flowRequestId(value) {
        this._recordId = value;

        if(this._recordId) {
            this.fetchStepSkipIndicator();
        }
    }
    get flowRequestId() {
        return this._recordId;
    }

    connectedCallback() {
        this.fetchPaymentsRecordTypeId();
    }

    // Get the "Payments" Payment_Account__c Record Type Id
    fetchPaymentsRecordTypeId() {
        getRecordTypeId({})
            .then(result => {
                this.paymentsRecordTypeId = result;
            })
    }

    async fetchStepSkipIndicator() {
        try {
            const result = await canSkipPaymentAccountStep({flowRequestId: this.flowRequestId});
            this.isEligibleForSkipping = result;
        } catch(error) {
            this.isEligibleForSkipping = false;

            console.error("Error while retrieving ability to skip Payment Account skip / DSD store status:");
            console.error(error);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "isEligibleToSkipPaymentAccountStep",
                message: JSON.stringify(error.body)
              });
        } finally {
            // Enable the "Next" button in the DSD scenario
            if(this.isEligibleForSkipping) {
                this.disableButton = false;
            }

            this.isSaving = false;
        }
    }

    // Lookup search implementation - called when a value is selected from the search field
    handlePaymentAccountSelection(event) {
        const selectedPaymentAccount = event.detail;

        // ID gets reset here only in single flow
        if(!this.useMultiSelectFlow) {
            this.selectedPaymentAccountId = selectedPaymentAccount ? selectedPaymentAccount.id : null;
        }

        // If we are here for the multi-select flow, the flow is completed
        if (this.selectedPaymentAccountId || this.useMultiSelectFlow || this.isEligibleForSkipping) {
            this.disableButton = false;
        } else {
            // Handle the case where no Account ID is selected, e.g., show an error message
            this.disableButton = true;
        }
    }

    handleMultiRecordsSelection(event) {
        this.selectedPaymentAccountId = event.detail.recordId;
        this.isComplete = event.detail.isComplete;

        // Only enable the page if the full selection is complete
        if(event.detail.isComplete) {
            this.handlePaymentAccountSelection({
                detail: this.selectedPaymentAccountId
            });
        }
    }

    // Called when the "Next" button is pressed and the user navigates to the next screen
    updateFlowRequestWithPaymentAccount() {
        // Dispatching a custom event with the selected Payment Account ID to the parent component
        const selectedEvent = new CustomEvent("paymentaccountselected", {
            detail: {
                recordId: this.selectedPaymentAccountId,
                skipRecordLinking: this.useMultiSelectFlow
            }
        });

        this.dispatchEvent(selectedEvent);
    }

    // Show/hide the Payment Account creation form
    toggleCreatePaymentAccountForm() {
        const switchToCreateNew = !this.showCreatePaymentAccountForm;

        if (switchToCreateNew) {
            this.showCreatePaymentAccountForm = true;
            this.isSaving = true;
            this.createNewFormClass = "slds-hidden";

            // Circumvent the delayed render of the lightning edit form by showing the loading spinner
            setTimeout(() => {
                this.isSaving = false;
                this.createNewFormClass = "slds-visible";
            }, 2000);
        } else {
            this.showCreatePaymentAccountForm = false;
            this.createNewFormClass = "slds-hidden";
        }
    }

    // Called when the "Save" button is clicked when a NEW Payment Account is created
    handleSubmit(event) {
        this.isSaving = true;
        event.preventDefault(); // Stop the form from submitting, until we add default values below
        const fields = event.detail.fields;
        fields.RecordTypeId = this.paymentsRecordTypeId;
        fields.Business_Account__c = this.accountId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError() {
        this.isSaving = false;

        // Dispatch Toast Error
        this.dispatchEvent(
            new ShowToastEvent({
                title: GENERIC_TOAST_ERROR_TITLE,
                message: GENERIC_TOAST_ERROR_MESSAGE,
                variant: GENERIC_TOAST_ERROR_VARIANT,
            })
        );
    }

    handleSuccess(event) {
        this.selectedPaymentAccountId = event && event.detail ? event.detail.recordId : null;
        this.disableButton = false;
        this.updateFlowRequestWithPaymentAccount();
    }

    // When one of the PAs from the "Create New" flow is saving - this turns on the saving indicators
    handleNewPaymentAccountSave(event) {
        if(event && event.detail && event.detail.isSaving !== undefined) {
            this.isSaving = event.detail.isSaving;
        } else {
            this.isSaving = true;
        }
    }

    // Called when `Select a single Payment Account` is pressed
    handleUseSingleSelect() {
        this.promptForFlowSelection = false;
        this.useSingleSelectFlow = true;
        this.useMultiSelectFlow = false;
    }

    // Called when `Select multiple Payment Accounts` is pressed
    handleUseMultiSelect() {
        this.promptForFlowSelection = false;
        this.useMultiSelectFlow = true;
        this.useSingleSelectFlow = false;
    }
}