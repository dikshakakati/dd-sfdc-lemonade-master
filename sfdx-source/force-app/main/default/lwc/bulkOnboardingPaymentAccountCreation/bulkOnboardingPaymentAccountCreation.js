import { LightningElement, api, track } from "lwc";
import getPaymentsRecordTypeId from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getPaymentsRecordType";
import createLog from "@salesforce/apex/LogController.createLog";

const COMPONENT_NAME = "BulkOnboardingPaymentAccountCreation";

export default class BulkOnboardingPaymentAccountCreation extends LightningElement {
    @api accountId;
    @api flowRequestId;

    @track isSavingNewRecord = false;

    paymentsRecordTypeId;

    connectedCallback() {
        console.log("Record Type Id fix....");
        this.fetchPaymentsRecordTypeId();
    }

    // Get the "Payments" Payment_Account__c Record Type Id
    async fetchPaymentsRecordTypeId() {
        try {
            const result = await getPaymentsRecordTypeId();
            this.paymentsRecordTypeId = result;
        } catch (error) {
            this.logErrorToConsole("Unable to retrieve Payments Record Type ID. See error below:", error)

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "getPaymentsRecordTypeId",
                message: JSON.stringify(error.body)
            });
        }
    }

    // Handle submission of the form - this happens when a user creates a new record and saves it
    handleSubmit(event) {
        this.fireSaveEvent();

        this.isSavingNewRecord = true;
        event.preventDefault(); // Stop the form from submitting, until we add default values below
        const fields = event.detail.fields;
        fields.RecordTypeId = this.paymentsRecordTypeId;
        fields.Business_Account__c = this.accountId;
        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    // Invoked when the submit form finishes successfully
    handleSuccess(event) {
        const recordId = event && event.detail ? event.detail.id : null;

        // Publish event to parent
        const selectedEvent = new CustomEvent("paymentaccountcreated", {
            detail: {
                recordId: recordId
            }
        });

        this.dispatchEvent(selectedEvent);
    }

    // Handles errors on the new record form submission
    handleError() {
        this.isSavingNewRecord = false;
        this.dispatchEvent(new CustomEvent("paymentaccountfailed"));
    }

    handleFieldUpdate() {
        this.dispatchEvent(new CustomEvent("fieldupdate"));
    }

    fireSaveEvent() {
        this.dispatchEvent(new CustomEvent("paymentaccountsaving"));
    }
}
