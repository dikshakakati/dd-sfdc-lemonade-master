import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import getStoreInfos from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getStoreInfosForFlowRequest";
import getExistingRecords from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getRecordsForMultiSelectDisplay";
import linkRecords from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores";
import fetchRecordById from "@salesforce/apex/LookupSearchCtrl.fetchRecordById";
import createLog from "@salesforce/apex/LogController.createLog";

const COMPONENT_NAME = "BulkOnboardingMultiSelect";
const CLASS_FORM_HIDDEN = "slds-hidden";
const CLASS_FORM_VISIBLE = "slds-visible";
const CLASS_LIST_INACTIVE = "slds-vertical-tabs__nav-item";
const CLASS_LIST_ACTIVE = "slds-vertical-tabs__nav-item slds-is-active";
const FIELDS_DM_CREATE = "Salutation,FirstName,AccountId,Phone,Email,Title,LastName,MobilePhone,Preferred_Language__c,Birthdate";
const INSTRUCTIONS_GENERIC = "Select which records to associate with your stores by using the search bar on the left or the 'Create New' link to add new records.";
const INSTRUCTIONS_DMs = "Select which Decision Maker Contacts to associate with your stores by using the search bar on the left or the 'Create New' link to add new Contacts.";
const INSTRUCTIONS_PAs = "Select which Payment Accounts to associate with your stores by using the search bar on the left or the 'Create New' link to add new Payment Accounts.";
const INSTRUCTIONS_MISSING_RECORDS = "Please search for a record or create a new one to get started.";
const INSTRUCTIONS_MISSING_PAs = "Please search for a Payment Account or create a new one to get started.";
const INSTRUCTIONS_MISSING_DMs = "Please search for a Decison Maker or create a new one to get started.";
const INSTRUCTIONS_SAVE_INFO = "You can press the Confirm button to save your selections as you go or wait until the end to save all changes at once. Once you have made selections for all stores you will be prompted to click Next.";
const INSTRUCTIONS_SELECTIONS_COMPLETE = " have been successfully linked to all stores. You may review and modify selections below if necessary. Click 'Next' to proceed.";
const LOGGER_STRING = `==================== ${COMPONENT_NAME} ====================`;
const LOGGER_STYLE_ERROR = "color: red; font-weight: bold;";
const OBJECT_API_PAYMENT_ACCOUNT = "Payment_Account__c";
const OBJECT_API_CONTACT = "Contact";
const OBJECT_LABEL_PAYMENT_ACCOUNT = "Payment Account";
const OBJECT_LABEL_CONTACT = "Decision Maker";
const OBJECT_PROPERTY_STOREINFO_PAYMENT_ACCOUNT_ID = "paymentAccountId";
const OBJECT_PROPERTY_STOREINFO_DECISION_MAKER_ID = "decisionMakerId";
const SEARCH_FIELD_LABEL_PREFIX = "Search for a ";

export default class BulkOnboardingMultiSelect extends LightningElement {
    @api isSaving;
    @api accountId;
    @api contractId;

    @track recordsToLink = [];
    @track allStores = [];


    @track isPaymentAccountFlow = false;
    @track isDecisionMakerFlow = false;
    @track showCreateRecordForm = false;
    @track skipEmbeddedSearchOption = true;
    @track errorMessage;
    @track isSavingNewRecord = false;
    @track isLoading = true;
    @track createNewFormClass = CLASS_FORM_HIDDEN;
    @track createFormModified = false;
    @track contactCreationFields; // Fields to show on the Contact form

    contactDetails = {
        hideLookupSearch: false,
        isSaving: false,
        key: "DecisionMaker",
        label: "Decision Maker",
        roleName: "Decision Maker",
        errorMessage: undefined,
        fieldsToQuery: FIELDS_DM_CREATE
    };

    idPropertyToUse;
    hideContactLookupSearch = true;
    primaryInstructions;
    mainInstructions = INSTRUCTIONS_GENERIC;
    saveInstructions = INSTRUCTIONS_SAVE_INFO;
    missingRecords = INSTRUCTIONS_MISSING_RECORDS;

    instructionalText = {
        mainInstructions: this.mainInstructions,
        saveInstructions: this.saveInstructions,
        missingRecords: this.missingRecords
    };

    @api
    set flowRequestId(value) {
        this._recordId = value;
        this.tryToLoadRecords();
    }
    get flowRequestId() {
        return this._recordId;
    }

    @api
    set objectType(value) {
        this._objectType = value;

        this.setComponentPropertiesBasedOnObject(this._objectType);
        this.tryToLoadRecords();
    }

    @api
    set isTabletWorkOrder(value) {
        this._isTabletWorkOrder = value;
        this.initializeContactCreationFields(); // Load these details only after we get API values
    }
    get isTabletWorkOrder() {
        return this._isTabletWorkOrder;
    }

    get objectType() {
        return this._objectType;
    }

    async getAllStores() {
        this.allStores = [];

        try {
            const result = await getStoreInfos({ flowRequestId: this.flowRequestId });

            if(result) {
                // Convert `StoreInfoWithAccountRecord` to the front-end wrapper
                const recordsByIds = this.recordsToLink.reduce((acc, item) => {
                    acc[item.id] = {
                        id: item.id,
                        classList: item.classList,
                        name: item.name,
                        subFields: item.subFields
                    };
                    return acc;
                }, {});

                let allStoresHaveLinkedRecords = true;
                result.forEach((storeObj) => {
                    // If there is a StoreInfo object AND it has a relevant property based on the component we're on...
                    if(storeObj.storeInfo && storeObj.storeInfo[this.idPropertyToUse]) {
                        let recordForStore = recordsByIds[storeObj.storeInfo[this.idPropertyToUse]];

                        storeObj.selectedRecord = {
                            "id": recordForStore.id,
                            "name": recordForStore.name,
                            "isSaved": true
                        };

                        // This handles the scenario where a record was linked (and saved), then the
                        // user makes another selection, but they change their mind before saving:
                        // in this case, we go back to the previously saved record.
                        storeObj.savedRecord = storeObj.selectedRecord;
                    } else {
                        allStoresHaveLinkedRecords = false;
                    }
                });

                // If all stores have linked records on load, communicate to parent component
                // so that the parent can enable the `Next` button
                if(allStoresHaveLinkedRecords) {
                    const selectedEvent = new CustomEvent("multirecordsselected", {
                        detail: {
                            recordId: result[0].selectedRecord.id,
                            isComplete: true
                        }
                    });

                    this.dispatchEvent(selectedEvent);
                }
            }

            this.allStores = result;
        } catch (error) {
            this.logErrorToConsole("Unable to retrieve StoreInfos. See error below:", error);

            const toastMsg = `An error occurred when loading the stores. Please try again.`;
            this.showToast(`Error during load`, toastMsg, true);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "getStoreInfos",
                message: JSON.stringify(error.body)
            });
        } finally {
            this.isLoading = false;
        }
    }

    // When records are saved and the user comes back to the flow, we want to display the already-linked records
    // This retrieves the `paymentAccountId` or `decisionMakerId` for each store -- if they exist -- and then
    // sets up the Payment Accounts or Decision Makers on the left side of the grid.
    async getAlreadyLinkedRecords() {
        this.recordsToLink = [];

        try {
            const results = await getExistingRecords({ flowRequestId: this.flowRequestId, objectType: this.objectType });
            let isInitialRecord = true;

            // For the records that are already associated with the stores, add them to the list of records to select from
            results.forEach((thisRecord) => {
                let subFieldsStr = thisRecord.subField.replace(" • ", "");
                this.recordsToLink.push({
                    "id": thisRecord.record.Id,
                    "classList": isInitialRecord ? CLASS_LIST_ACTIVE : CLASS_LIST_INACTIVE,
                    "name": thisRecord.mainField,
                    "subFields": subFieldsStr
                });
                isInitialRecord = false;
            });

            // Select the first record on initial load
            if(this.recordsToLink.length) {
                this.selectedRecord = this.recordsToLink[0];
            }
        } catch(error) {
            // Do not show a toast message here and proceed to `getAllStores()` in the `finally` block
            // This retrieves existing data -- which is an edge case anyway -- so continue to attempt store retrieval
            this.logErrorToConsole("Error while retrieving existing linked Payment Accounts:", error);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "getExistingRecords",
                message: JSON.stringify(error.body)
            });
        } finally {
            this.getAllStores();
        }
    }

    // Calls the data initialization methods when appropriate. These methods rely on properties
    // from multiple setters, so we should perform checks to make sure the requisite data exists.
    tryToLoadRecords() {
        if (this.flowRequestId && this.objectType) {
            this.getAlreadyLinkedRecords();
        }
    }

    // This is the `Confirm` button to save your selections
    async handleConfirm() {
        this.isLoading = true;
        this.errorMessage = null;
        let storeInfos = [];
        let isComplete = false;

        // The Apex method takes `StoreInfo` objects, which are part of this more complex object
        // Extract them to the `storeInfos` array so this can be passed into the method
        this.allStores.forEach((storeObj) => {
            storeInfos.push(storeObj.storeInfo);
        });

        const storeInfosStr = JSON.stringify(storeInfos);
        const recordId = this.selectedRecord.id;

        try {
            const result = await linkRecords({ flowRequestId: this.flowRequestId, relatedRecordId: recordId, storeInfoStr: storeInfosStr });

            // Set all the Payment Accounts as saved
            this.allStores.forEach((thisStoreObj) => {
                if(thisStoreObj && thisStoreObj.selectedRecord) {
                    thisStoreObj.selectedRecord.isSaved = true;
                    thisStoreObj.savedRecord = thisStoreObj.selectedRecord; // Update the saved record copy
                }
            });

            // Uncheck all checkboxes in the table
            this.handleDeselectCheckboxes();
            isComplete = result.isComplete;
        } catch (error) {
            const errorTitle = `Unable to save ${this.objectLabel}s to the stores. See error below: `;
            this.logErrorToConsole(errorTitle, error);

            let toastMsg = `An error occurred while attempting to save ${this.objectLabel}s to the stores. `;

            // Write specific error to the screen if we have one
            if(error.body && error.body.message) {
                toastMsg += "Error: " + error.body.message;
            } else {
                toastMsg += " The save might not have been completed.";
            }

            this.showToast(`Error during save`, toastMsg, true);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "linkRecords",
                message: JSON.stringify(error.body)
            });
        } finally {
            this.createFormModified = false;
            this.showCreateRecordForm = false;
            this.isLoading = false;

            // Dispatch an event to the parent with information on whether this is finished
            // If complete, this will enable the "Next" button
            const selectedEvent = new CustomEvent("multirecordsselected", {
                detail: {
                    recordId: recordId,
                    isComplete: isComplete
                }
            });

            this.dispatchEvent(selectedEvent);

            // If all the stores were linked, display a success message
            if(isComplete) {
                const msgTitle = `${this.objectLabel}s linked successfully`;
                const msgBody = `${this.objectLabel}s ${INSTRUCTIONS_SELECTIONS_COMPLETE}`;

                this.showToast(msgTitle, msgBody, false);
            }
        }
    }

    // When a record is created (from the "Create New" flow), this transforms it into a wrapper expected
    // by the UI, so that it can display properly in the list of selected records.
    async fetchAndTransformNewlyCreatedRecord(recordId) {
        try {
            const result = await fetchRecordById({ recordId: recordId });

            // Set certain properties if there are no records yet
            let isInitialRecord = !this.recordsToLink.length;

            let newRecord = {
                "id": recordId,
                "classList": isInitialRecord ? CLASS_LIST_ACTIVE : CLASS_LIST_INACTIVE,
                "name": result.mainField,
                "subFields": result.subField
            };

            this.recordsToLink.push(newRecord);

            if(isInitialRecord) {
                this.selectedRecord = newRecord;
            }

        } catch(error) {
            this.logErrorToConsole(`Error inserting ${this.objectLabel}. See error below:`, error);

            const toastMsg = `An error occurred when creating the ${this.objectLabel}. The save might not have been completed.`;
            this.showToast(`Error during save`, toastMsg, true);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: "fetchRecordById",
                message: JSON.stringify(error.body)
            });
        } finally {
            this.isSavingNewRecord = false;
            this.createNewFormClass = CLASS_FORM_HIDDEN;
            this.showCreateRecordForm = false;
        }

    }

    // Callback after the "Create New" flow creates a new record successfully; this then takes the new
    // record and places it in the UI (on the left side with the other selected records), so you can
    // start associating Stores to it.
    handleRecordCreation(event) {
        const recordId = event.detail.recordId;
        if(!recordId) {
            return;
        }

        this.fetchAndTransformNewlyCreatedRecord(recordId);
    }

    // When one of the records from the "Create New" flow is saving - this turns on the saving indicators
    handleNewRecordSave(event) {
        this.createFormModified = false;

        if(event && event.detail && event.detail.isSaving !== undefined) {
            this.isSavingNewRecord = event.detail.isSaving;
        } else {
            this.isSavingNewRecord = true;
        }
    }

    // Resets the save indicators in the failure case
    handleNewRecordFailure() {
        this.isSavingNewRecord = false;
        this.createFormModified = true;
    }

    // Called when any fields in the Create New form are edited
    handleCreateFormChange() {
        this.createFormModified = true;
    }

    // Called when the "Cancel" button on the Create New form is clicked
    handleClickCancelCreateNew() {
        this.showCreateRecordForm = false;
        this.isSavingNewRecord = false;
    }

    // Handler for onclick of the "Create New" button
    handleClickCreateNew() {
        this.showCreateRecordForm = true;
        this.isSavingNewRecord = true;

            // Circumvent the delayed render of the lightning edit form by showing the loading spinner
            setTimeout(() => {
                this.isSavingNewRecord = false;
                this.createNewFormClass = CLASS_FORM_VISIBLE;
            }, 2000);
    }

    // Handler when the records on the left side of the page are clicked
    async handleClickRecord(event) {

        // Navigate away from the Create New form when the user clicks another record
        if(this.showCreateRecordForm) {
            // If there are changes to the Create New form, then show a confirmation prompt
            if(this.createFormModified) {
                const cancelCreateNewMsg = `You have unsaved changes in the ${this.objectLabel} form. If you switch now, you'll lose these changes. \nAre you sure you want to leave this page?`;
                const confirmResult = await this.handleConfirmClick(cancelCreateNewMsg);

                if(!confirmResult) {
                    return;
                }
            }

            this.showCreateRecordForm = false;
        }

        const recordIdToUse = event.currentTarget.dataset.recordId;

        if(!recordIdToUse) {
            this.selectedRecord = null;
            return;
        }

        this.recordsToLink.forEach((record) => {
            if(record.id === recordIdToUse) {
                this.selectedRecord = record;
                record.classList = CLASS_LIST_ACTIVE;
            } else {
                record.classList = CLASS_LIST_INACTIVE;
            }
        });

        // Uncheck all checkboxes in the table
        this.handleDeselectCheckboxes();
    }

    // When a record is found and clicked on from the search input, transform it and add it
    // to the list of records.
    // Possible future enhancement: Remove selected record from consideration for subsequent searches
    handleSelectionOfFoundRecord(event) {
        const foundRecord = event.detail;

        if(!foundRecord) {
            return;
        }

        let recordId = foundRecord.record.record.Id;

        // Don't add the record to the list if it is already there
        if (!this.recordsToLink.find(record => record.id === recordId)) {
            // Remove the unnecessary " • "
            let subFieldsStr = foundRecord.subField.replace(" • ", "");
            this.recordsToLink.push(
                {
                    "id": recordId,
                    "classList": CLASS_LIST_INACTIVE,
                    "name": foundRecord.mainField,
                    "subFields": subFieldsStr
                }
            );
        }

        // Select the first record as active if none are active...
        if(this.recordsToLink.length && !this.recordsToLink.find(record => record.classList === CLASS_LIST_ACTIVE)) {
            this.recordsToLink[0].classList = CLASS_LIST_ACTIVE;
            this.selectedRecord = this.recordsToLink[0];
        }

        // Clear the search input
        this.template.querySelector('c-lookup-search').clearInput();
    }

    // Called when the checkbox is clicked on a store -- this will tentatively link the selected record.
    // Future enhancement: When there is a saved value, and then you select another value and
    // clear it before saving, it goes back to a NULL value!
    handleSelectStore(event) {
        this.allStores.forEach((store) => {
            // If the user clicked "Select All" OR they clicked the current store...
            if(event.target.name === "selectAll" || store.storeInfo.storeId === event.target.name) {
                if(event.target.checked) {
                    store.storeInfo[this.idPropertyToUse] = this.selectedRecord.id;
                    store.selectedRecord = {
                        "id": this.selectedRecord.id,
                        "name": this.selectedRecord.name,
                        "isSaved": false
                    };
                } else if(store.savedRecord) {
                    store.storeInfo[this.idPropertyToUse] = store.savedRecord.id;
                    store.selectedRecord = store.savedRecord;
                } else {
                    store.storeInfo[this.idPropertyToUse] = null;
                    store.selectedRecord = undefined;
                }
            }
        });
    }

    // When the records are saved or the linked record is switched, uncheck the selections
    handleDeselectCheckboxes() {
        // Uncheck all checkboxes in the table
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
        checkboxes.forEach(checkbox => {
            checkbox.checked = false;
        });
    }

    // Renders a toast message
    showToast(title, message, isError) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: isError ? "error" : "success"
            })
        );
    }

    // Sets the component state based on object -- this helps the bulkOnboardingMultiSelect component
    // to be reusable across PAs/DMs/anything else.
    setComponentPropertiesBasedOnObject(currentObjectType) {
        if(currentObjectType === OBJECT_API_PAYMENT_ACCOUNT) {
            this.isPaymentAccountFlow = true;
            this.instructionalText.mainInstructions = INSTRUCTIONS_PAs;
            this.instructionalText.missingRecords = INSTRUCTIONS_MISSING_PAs;
            this.objectLabel = OBJECT_LABEL_PAYMENT_ACCOUNT;
            this.idPropertyToUse = OBJECT_PROPERTY_STOREINFO_PAYMENT_ACCOUNT_ID;
            this.objectIcon = "standard:account";
            this.primarySearchField = "Name";
            this.secondarySearchFields = "Entity_Type__c,Business_Account__r.Name";

        } else if(currentObjectType === OBJECT_API_CONTACT) {
            this.isDecisionMakerFlow = true;
            this.instructionalText.mainInstructions = INSTRUCTIONS_DMs;
            this.instructionalText.missingRecords = INSTRUCTIONS_MISSING_DMs;
            this.idPropertyToUse = OBJECT_PROPERTY_STOREINFO_DECISION_MAKER_ID;
            this.objectLabel = OBJECT_LABEL_CONTACT;
            this.objectIcon = "standard:contact";
            this.primarySearchField = "Name";
            this.secondarySearchFields = "Email,Phone";
        }

        this.searchFieldLabel = `${SEARCH_FIELD_LABEL_PREFIX} ${this.objectLabel}...`;
    }

    // Logs the error to the console with special formatting for readability
    logErrorToConsole(message, error) {
        console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
        console.log(message);
        console.error(error);
        console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
    }

    // This handles the select all checkbox atop the grid which will select or deselect all the stores
    handleSelectAll(event) {
        // This will check the boxes when selectAll is checked and likewise uncheck them when it's unchecked
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
        checkboxes.forEach(checkbox => {
            checkbox.checked = event.target.checked;
        });

        // Call the normal selectStore handler now that the appropriate boxes have been checked/unchecked
        this.handleSelectStore(event);
    }

    handleConfirmClick(confirmMessage) {
        const result = LightningConfirm.open({
            label: "Remove Store",
            message: confirmMessage,
            variant: "header",
            theme: "alt-inverse"
        });

        return result;
    }

    // Sets fields to build the "Create New" Contact form
    initializeContactCreationFields() {
        this.contactCreationFields = [
            { name: "Salutation", required: false, column: 1 },
            { name: "FirstName", required: true, column: 1 },
            { name: "LastName", required: true, column: 1 },
            { name: "Title", required: false, column: 1 },
            { name: "Email", required: false, column: 1 },
            { name: "Phone", required: this.isTabletWorkOrder, column: 1 },
            { name: "MobilePhone", required: false, column: 1 },
            { name: "Preferred_Language__c", required: false, column: 1 },
            { name: "Birthdate", required: false, column: 1 }
        ];
    }
}