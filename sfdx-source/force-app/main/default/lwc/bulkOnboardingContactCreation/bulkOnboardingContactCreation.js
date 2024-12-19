import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCOUNT_FIELD from "@salesforce/schema/Contract.AccountId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const GENERIC_TOAST_ERROR_TITLE = "Failed to Save Contact";
const GENERIC_TOAST_ERROR_MESSAGE = "Review and correct errors below.";
const GENERIC_TOAST_ERROR_VARIANT = "error";
const MANUAL_CONTACT_SOURCE = "Manual";

export default class BulkOnboardingContactCreation extends LightningElement {
    @api customInstructions;
    @api parentPage;
    @api contractId;
    @track errors;
    @track selectedContact;
    @track hideCreateFormPrivate = false;
    @track hideLookupSearchPrivate = false;
    @track showCreateFormOnlyPrivate = false;
    @track disableButton = true;
    @track layoutColumnWidth = 12; // options are 12 or 6
    @track useTwoColumnLayout = false;

    newContactId;
    requiredFields = [];
    leftFields = [];
    rightFields = [];
    requiredFieldValues = {};
    fieldNames = [];
    accountId;

    @wire(getRecord, { recordId: "$contractId", fields: [ACCOUNT_FIELD] })
    wiredAccountField({ error, data }) {
        if (data) {
            this.accountId = getFieldValue(data, ACCOUNT_FIELD);
        } else if (error) {
            console.error('Error retrieving account field:');
            this.logger(error);
        }
    }

    // Fill out the form details with the default Contact's fields once the form loads
    renderedCallback() {
        if(!this.fieldsFilledOnLoad && this.contactDetails && this.contactDetails.updatedContactData) {
            this.fillContactFieldsFromLookupSelection(
                { "record": this.contactDetails.updatedContactData }
            );

            this.fieldsFilledOnLoad = true;
            this.getIsFormCompleted();
        }
    }

    @api
    set parentErrorMessage(value) {
        // Take the unique identifier off the error message. This is needed to force the variable to re-render on the child component.
        if(value && value.indexOf(":") !== -1) {
            // Extract everything after the colon
            let listOfRawErrors = value.substring(value.indexOf(":") + 1).trim();
            value = listOfRawErrors.split("///");
        }

        this.errors = value;
    }

    get parentErrorMessage() {
        return this.errors;
    }

    @api
    set verticalPadding(value) {
        this._verticalPadding = "slds-p-vertical_" + value;
    }

    get verticalPadding() {
        return this._verticalPadding;
    }

    @api
    set contactDetails(value) {
        this._contactDetails = value;
    }

    get contactDetails() {
        return this._contactDetails;
    }

    @api
    set specifiedFields(value) {
        this._inputtedFields = value;
        if(this._inputtedFields && this._inputtedFields.length) {
            this._inputtedFields.forEach((field) => {
                if(field.required) {
                    this.requiredFields.push(field);
                }

                if(field.column === 1) {
                    this.leftFields.push(field);
                } else {
                    this.rightFields.push(field);
                }

                // Do not include any non-field elements in the list
                if(field.name) {
                    this.fieldNames.push(field.name);
                }
            });

            this.setFieldValuesMap();
            this.setLayoutProperties();
        }
    }

    get specifiedFields() {
        return this._inputtedFields;
    }

    @api
    set hideCreateForm(value) {
        this.hideCreateFormPrivate = value;
    }

    get hideCreateForm() {
        return this.hideCreateFormPrivate;
    }

    @api
    set hideLookupSearch(value) {
        this.hideLookupSearchPrivate = value;
    }

    get hideLookupSearch() {
        return this.hideLookupSearchPrivate;
    }

    @api
    set showCreateFormOnly(value) {
        this.showCreateFormOnlyPrivate = value;
    }

    get showCreateFormOnly() {
        return this.showCreateFormOnlyPrivate;
    }

    // Initialize field values map
    setFieldValuesMap() {
        this.requiredFields.forEach(field => {
            this.requiredFieldValues[field.name] = "";
        });
    }

    // Sets attributes related to rendering the layout
    setLayoutProperties() {
        this.useTwoColumnLayout = (this.rightFields.length) ? true : false;
        this.layoutColumnWidth = (this.useTwoColumnLayout) ? 6 : 12;
    }

    // Hides or displays the `lookupSearch` field based on user preference
    toggleShowLookupSearch() {
        this.errors = undefined;
        this.hideLookupSearchPrivate = !this.hideLookupSearchPrivate;

        // If the Create Form should always be displayed, make sure we never toggle it
        if(this.parentPage && this.parentPage === "DecisionMaker") {
            this.hideCreateFormPrivate = !this.hideCreateFormPrivate;
        }

        if(this.hideLookupSearchPrivate) {
            this.handleRemovalOfExistingContact();
        }
    }

    // Handler which is invoked when a Contact is selected from the `lookupSearch` component
    handleSelectionOfExistingContact(event) {
        const selectedDetails = event.detail;
        this.selectedContact = selectedDetails;
        this.fillContactFieldsFromLookupSelection(selectedDetails.record);
        this.getIsFormCompleted();
    }

    // Handler invoked when a Contact is removed from the `lookupSearch` component
    handleRemovalOfExistingContact() {
        // Clear the selectedContact
        this.selectedContact = null;
        this.newContactId = null;

        // Reset the fields in the UI
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            field.value = null;

            // Remove the value from the requiredFieldValues if it's there, which resets the form status
            if (this.requiredFieldValues.hasOwnProperty(field.fieldName)) {
                this.requiredFieldValues[field.fieldName] = null;
            }
        });

        this.getIsFormCompleted(); // This method re-checks the form validity
    }

    // When a Contact is selected from the `lookupSearch` form, or when one is defaulted from the Apex controller, then fill
    // out the fields on the form. The reason we do this is to provide a method for users to add or modify the contact data
    // that we have in the system. There might be an existing relevant Contact that does not have all the properties needed
    // for the Stripe integration. In that case, we'd have to add those properties through the form here.
    fillContactFieldsFromLookupSelection(contact) {
        this.newContactId = contact?.record?.Id;

        const fields = this.template.querySelectorAll("lightning-input-field");

        // Fill this fields map to show them in the UI
        fields.forEach(field => {
            const valueForThisField = contact.record[field.fieldName];
            // The field name has to match the API name of the contact fields
            if (contact.record[field.fieldName]) {
                field.value = valueForThisField;
            }

            if (this.requiredFieldValues.hasOwnProperty(field.fieldName)) {
                this.requiredFieldValues[field.fieldName] = valueForThisField;
            }
        });
    }

    // Handler for the `onerror` `lightning-record-edit-form component. This runs when the `submit()`
    // did NOT go successfully.
    handleError(event) {
        if(event.detail && event.detail.detail) {
            this.errors = [event.detail.detail];
        }

        this.updateSaveStatus(false);
        this.dispatchEvent(
            new ShowToastEvent({
                title: GENERIC_TOAST_ERROR_TITLE,
                message: GENERIC_TOAST_ERROR_MESSAGE,
                variant: GENERIC_TOAST_ERROR_VARIANT,
            })
        );
    }

    // Handler for the `onsuccess` `lightning-record-edit-form component. This runs when the `submit()`
    // went successfully.
    handleSuccess(event) {
        if(event && event.detail) {
            this.newContactId = event.detail.id;
            this.updatedContactData = event.detail.updatedContactData;
        }

        this.notifyParent();
    }

    // Handler for the `onsubmit` `lightning-record-edit-form component`
    // This is used to save the Contact and, if successful, to inform the parent component of
    // the status of the transaction.
    handleSubmit(event) {
        this.errors = undefined;

        this.updateSaveStatus(true);
        event.preventDefault(); // Stop the form from submitting, until we add default values below

        // Set the default field values
        const fields = event.detail.fields;
        fields.Contact_Source__c = MANUAL_CONTACT_SOURCE;
        fields.AccountId = this.accountId;

        // If we selected a Contact, go straight to the ACR insertion
        if(this.newContactId) {
            // Send update details to update any information in the system
            const formData = {};
            this.template.querySelectorAll("lightning-input-field").forEach(field => {
                formData[field.fieldName] = field.value;
            });

            let submissionEvent = {
                "detail": {
                    "id": this.newContactId,
                    "updatedContactData": formData
                }
            };

            this.handleSuccess(submissionEvent);
        } else {
            this.template.querySelector("lightning-record-edit-form").submit(fields);
        }
    }

    // The `onchange` handler for every form field -- this examines the form and determines if
    // all required fields are completed, and, if so, it un-disables the Save button.
    handleEvaluateCompletion(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;

        // Add the value to the requiredFieldValues object, if it exists there
        if (this.requiredFieldValues && this.requiredFieldValues.hasOwnProperty(field)) {
            this.requiredFieldValues[field] = value;
        }

        this.getIsFormCompleted();
    }

    getIsFormCompleted() {
        let isComplete = true;
        const keys = Object.keys(this.requiredFieldValues);
        for (let i = 0; i < keys.length; i++) {
            const field = keys[i];
            if (!this.requiredFieldValues[field]) {
                isComplete = false;
                break; // Using a traditional for-loop to break early
            }
        }

        this.disableButton = !isComplete;
        this.notifyFormCompletion(isComplete);
    }

    // Notify the parent if the form is completed successfully
    notifyFormCompletion(isComplete) {
        const selectedEvent = new CustomEvent("fieldupdate", {
            detail: {
                key: this.contactDetails,
                isComplete: isComplete,
                contactId: this.newContactId
            }
        });

        this.dispatchEvent(selectedEvent);
    }

    // Notify the parent if a Contact was successfully submitted (inserted or updated)
    notifyParent() {
        // Dispatching a custom event with the selected Payment Account ID to the parent component
        const selectedEvent = new CustomEvent("contactcreated", {
            detail: {
                contactId: this.newContactId,
                recordId: this.newContactId,
                contactDetails: this.contactDetails, // Assuming 'title' holds the role information
                updatedContactData: this.updatedContactData,
                fieldNames: this.fieldNames
            }
        });

        this.dispatchEvent(selectedEvent);
    }

    // Dispatch an event to the parent to let it know whether a Save is in progress
    updateSaveStatus(isSaving) {
        this.dispatchEvent(new CustomEvent("updatesavestatus", {
            detail: {
                isSaving: isSaving
            }
        }));
    }

    // TODO - Used for development purposes only - remove when completed
    logger(obj) {
        console.log(JSON.parse(JSON.stringify(obj)));
    }
}