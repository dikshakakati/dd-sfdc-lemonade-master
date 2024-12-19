import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import submitNewWorkOrder from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.submitNewWorkOrder";
import getStatusPicklistValues from '@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getStatusPicklistValues';
import getTypePicklistValues from '@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getTypePicklistValues';

const OBJECT_NAME_TO_GET_FIELDS = 'WorkOrder';
const TYPE_ERROR_MESSGAE = 'Error while fetching Type picklist values.';
export default class BulkOnboardingWorkOrder extends LightningElement {
    @api accountId;
    @api contractId;
    @api flowRequestId;
    @api opportunityId;
    @track isLoading = true;
    @track isSaving = false;
    @track errors = {};
    @track createNewFormClass = "slds-hidden";
    @track orderProtocol;
    @track workOrderFields = new Map();
    statusOptions = [];
    typeOptions = [];
    defaultStatus;
    defaultType;
    activatedCentrallyValue;

    _currentStep;

    // This setup dynamically determines required fields for Work Orders based on their Type.
    // For example, certain fields must be completed for Marketplace WOs, unlike other types.
    // We leverage getters to manage UI-required fields not enforced at the object level,
    // accommodating validations driven by Type.
    requiredFields = {
        "Marketplace": {
            "Menu_to_be_Completed_By__c": true,
            "Proposed_Date_of_Activation__c": true,
            "Order_Protocol__c": true,
            "Activated_Centrally_AC__c": true
        }
    };

    // This allows us to set default values based on the WO type used
    defaultFieldValues = {
        "Marketplace": {
            "Business_to_Store_Assignment__c": "Automatic"
        }
    }

    // Get fields for WorkOrder object
    @wire(getObjectInfo, { objectApiName: OBJECT_NAME_TO_GET_FIELDS })
    getObjectInfo({ error, data }) {
        if (data) {
            this.workOrderFields = new Map();
            for (let key in data.fields) {
                if (Object.prototype.hasOwnProperty.call(data.fields, key)) {
                    this.workOrderFields.set(key, data.fields[key].label);
                }
            }
        } else if (error) {
            console.error("Error fetching WorkOrder fields", error);
            this.workOrderFields = new Map();
        }
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

    // Determine what fields are required
    get isMenuToBeCompletedByRequired() {
        return this.requiredFields[this.defaultType]?.Menu_to_be_Completed_By__c || false;
    }

    get isOrderProtocolRequired() {
        return this.requiredFields[this.defaultType]?.Order_Protocol__c || false;
    }

    get isActivatedCentrallyRequired() {
        return this.requiredFields[this.defaultType]?.Activated_Centrally_AC__c || false;
    }

    get isProposedDateOfActivationRequired() {
        return this.requiredFields[this.defaultType]?.Proposed_Date_of_Activation__c || false;
    }

    get isPosIntegrationTypeRequired() {
        return this.orderProtocol && this.orderProtocol.toUpperCase().includes("POS");
    }

    get defaultProvisioningProcess() {
        return this.defaultFieldValues[this.defaultType]?.Business_to_Store_Assignment__c;
    }

    connectedCallback() {
        this.getPicklistValues();
    }

    handleMenuUpdate(event) {
        const menuFieldValue = event.detail.value;

        if(menuFieldValue === "Account Owner" && !this.activatedCentrallyValue) {
            this.activatedCentrallyValue = "No";
        }
    }

    handleActivatedCentrallyUpdate(event) {
        this.activatedCentrallyValue = event.detail.value;
    }

    handleOrderProtocolUpdate(event) {
        this.orderProtocol = event.detail.value;
    }

    // Retrieves the picklist values for read-only `WorkOrder.Status` and 'WorkOrder.Type__c' field
    getPicklistValues() {
        getStatusPicklistValues()
            .then(result => {
                this.statusOptions = result.values.map(value => ({ label: value, value }));
                this.defaultStatus = result.default;
            })
            .catch(error => {
                console.error("Error fetching Status picklist values", error);
            })
            .finally(() => {
                // Circumvent the delayed render of the lightning edit form by showing the loading spinner
                setTimeout(() => {
                    this.isLoading = false;
                    this.createNewFormClass = "slds-visible";
                }, 2000);
            });
        // To get Work Order Type field values
        getTypePicklistValues()
            .then(result => {
                this.typeOptions = result.values.map(value => ({ label: value, value }));
                this.defaultType = result.default;
            })
            .catch(error => {
                console.error(TYPE_ERROR_MESSGAE, error);
            })
            .finally(() => {
                // Circumvent the delayed render of the lightning edit form by showing the loading spinner
                setTimeout(() => {
                    this.isLoading = false;
                    this.createNewFormClass = "slds-visible";
                }, 2000);
            });
    }

    handleSubmit(event) {
        event.preventDefault(); // Stop the form from submitting
        const fields = event.detail.fields; // Get the fields and relevant values

        fields.AccountId = this.accountId;
        fields.Contract__c = this.contractId;
        this.handleWorkOrderCreation(fields);
    }

    handleWorkOrderCreation(fields) {
        fields.AccountId = this.accountId;
        fields.Contract__c = this.contractId;
        fields.Type__c = this.defaultType;
        this.isSaving = true;

        submitNewWorkOrder({ flowRequestId: this.flowRequestId, workOrderFields: fields })
            .then(result => {

                // Handle successful update.
                this.dispatchEvent(new ShowToastEvent({
                    title: "Success",
                    message: "Work Order and Process Flow Request Created",
                    variant: "success",
                }));

                this.dispatchEvent(new CustomEvent("workordersuccess", {
                    detail: {
                        flowRequestValue: result
                    }
                }));
                this.isSaving = false;
                this.errors = {}; // clear out any existing errors
            })
            .catch(error => {
                let errorMsg = error.body.message;
                let fieldErrors = errorMsg.split("\n");

                fieldErrors.forEach(err => {
                    let [fieldName, message] = err.split(":");
                    if (fieldName) {
                        fieldName = fieldName.trim();
                        if (this.workOrderFields.has(fieldName)) {
                            fieldName = this.workOrderFields.get(fieldName);
                        } else if (message === undefined) {
                            message = fieldName;
                            fieldName = "";
                        }
                    } else {
                        fieldName = "";
                    }
                    message = message ? message.trim() : "";
                    // Maybe use field label instead of API Name
                    let errorTitle = fieldName ? `Error in field: ${fieldName}` : `Error`;

                    // Dispatch a toast for each error
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: errorTitle,
                            message: message,
                            variant: "error",
                        })
                    );
                });

                this.isSaving = false;
            });
    }
    switchToWorkOrderSelection() {
        this.dispatchEvent(new CustomEvent("switchworkordermethod", {
            detail: {
                newType: "selection"
            }
        }));
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }
}