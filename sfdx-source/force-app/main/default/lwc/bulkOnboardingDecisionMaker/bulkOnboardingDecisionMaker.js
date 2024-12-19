import { LightningElement, api, track, wire } from "lwc";
import getIsTabletWorkOrder from '@salesforce/apex/BulkCorporateOnboardingRequestCtrl.isTabletWorkOrder';
const ALL_FORM_FIELDS = "Salutation,FirstName,AccountId,Phone,Email,Title,LastName,MobilePhone,Preferred_Language__c,Birthdate";
const CUSTOM_INSTRUCTIONS = "Input the Contact's details below. Upon saving, this Contact will be linked as a Decision Maker to the Stores you uploaded with the CSV file.";
const DECISION_MAKER_ROLE = "Decision Maker";
const DECISION_MAKER_KEY = "DecisionMaker";

export default class BulkOnboardingDecisionMaker extends LightningElement {
    @api flowRequestId;
    @api contractId;

    @track disableButton = true; // False when no Decision Maker is selected
    @track isSaving = false;
    @track promptForFlowSelection = true;
    @track useSingleSelectFlow = false;
    @track useMultiSelectFlow = false;

    customInstructions = CUSTOM_INSTRUCTIONS;

    selectedDecisionMakerId;
    hideCreateFormByDefault = true;
    _currentStep;

    contactDetails = {
        hideLookupSearch: false,
        isSaving: false,
        key: DECISION_MAKER_KEY,
        label: DECISION_MAKER_ROLE,
        roleName: DECISION_MAKER_ROLE,
        errorMessage: undefined,
        fieldsToQuery: ALL_FORM_FIELDS
    };

    formFields = [
        { name: "Salutation", required: false, column: 1 },
        { name: "FirstName", required: true, column: 1 },
        { name: "Phone", required: false, column: 1 },
        { name: "Email", required: false, column: 1 },
        { name: "Title", required: false, column: 2 },
        { name: "LastName", required: true, column: 2 },
        { name: "MobilePhone", required: false, column: 2 },
        { name: "Preferred_Language__c", required: false, column: 2 },
        { name: "Birthdate", required: false, column: 2 }
    ];

    @api
    set currentStep(value) {
        this._currentStep = (value) ? value.toString() : "1"; // convert to string and store in private property
    }

    get currentStep() {
        return this._currentStep; // return the private property value
    }

    // Retrieves flag for whether this is a Tablet WO, which requires add'l contact validations
    @wire(getIsTabletWorkOrder, { flowRequestId: '$flowRequestId' })
    getIsTabletWorkOrder({ error, data }) {
        if (data) {
            this.isTabletWorkOrder = data;
        } else {
            if(error) {
                console.error('Error retrieving isTabletWorkOrder:', error);
            }

            this.isTabletWorkOrder = false; // Set to false as a default
        }
    }

    // Lookup search implementation - called when a value is selected from the search field
    handleDecisionMakerSelection(event) {
        const selectedDecisionMaker = event.detail;

        // ID gets reset here only in single flow
        if(!this.useMultiSelectFlow) {
            this.selectedDecisionMakerId = selectedDecisionMaker ? selectedDecisionMaker.id : null;
        }

        // Enable the button if there is a truthy value selected for selectedDecisionMakerId or if we
        // are in the multi-select flow
        if (this.selectedDecisionMakerId || this.useMultiSelectFlow) {
            this.disableButton = false;
        } else {
            // Handle the case where no Account ID is selected, e.g., show an error message
            this.disableButton = true;
        }
    }

    handleMultiRecordsSelection(event) {
        this.selectedDecisionMakerId = event.detail.recordId;
        this.isComplete = event.detail.isComplete;

        // Only enable the page if the full selection is complete
        if(event.detail.isComplete) {
            this.handleDecisionMakerSelection({
                detail: this.selectedPaymentAccountId
            });
        }
    }


    updateFlowRequestWithDecisionMaker() {
        // TODO - Update the Event Detail to unhardcode the `skipRecordLinking` in LEM-14120
        // Dispatching a custom event with the selected Payment Account ID to the parent component
        const selectedEvent = new CustomEvent("decisionmakerselected", {
            detail: {
                recordId: this.selectedDecisionMakerId,
                skipRecordLinking: this.useMultiSelectFlow
            }
        });

        this.dispatchEvent(selectedEvent);
    }

    handleNewContactCreated(event) {
        this.selectedDecisionMakerId = event.detail.contactId;
        this.disableButton = false;
        this.handleSuccess();
    }

    handleEnableSave(event) {
        const contactId = event.detail.contactId;
        this.handleDecisionMakerSelection({detail: {
            id: contactId
        }});
    }

    handleUpdateSaveStatus(event) {
        const isSaving = event.detail.isSaving;
        this.isSaving = isSaving;
    }

    handleSuccess() {
        this.disableButton = false;
        this.isSaving = false;
        this.updateFlowRequestWithDecisionMaker();
    }

    // Called when `Select a single Decision Maker` is pressed
    handleUseSingleSelect() {
        this.promptForFlowSelection = false;
        this.useSingleSelectFlow = true;
        this.useMultiSelectFlow = false;
    }

    // Called when `Select multiple Decision Makers` is pressed
    handleUseMultiSelect() {
        this.promptForFlowSelection = false;
        this.useMultiSelectFlow = true;
        this.useSingleSelectFlow = false;
    }
}