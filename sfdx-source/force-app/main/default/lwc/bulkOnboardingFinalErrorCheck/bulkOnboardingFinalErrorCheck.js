import { LightningElement, api, track } from "lwc";
import LightningConfirm from "lightning/confirm";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successMessage from '@salesforce/label/c.Bulk_Store_Final_Error_Check_Pass';
import rejectedMessage from '@salesforce/label/c.Bulk_Store_Final_Error_Check_Rejected';
import outOfCoverageMessage from '@salesforce/label/c.Bulk_Store_Final_Error_Check_Coverage';
import elevatorsAccessibilityField from '@salesforce/label/c.Seattle_Accessibilities_Elevators_Field_Name';
import stairsAccessibilityField from '@salesforce/label/c.Seattle_Accessibilities_Stairs_Field_Name';
import accessibilitiesMessage from '@salesforce/label/c.Seattle_Accessibilities_ANSO_Instructions';
import unverifiedMessage from '@salesforce/label/c.Bulk_Store_Final_Error_Check_Unverified';
import mainInstructions from '@salesforce/label/c.Bulk_Store_Final_Error_Check_Instructions';
import getFailedStoreDetails from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getInvalidOrIncompleteStores";
import saveAccessibilitiesData from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.saveAccessibilities";
import deleteStore from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.deleteStore";
import confirmOutOfCoverage from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.removeOutOfCoverageStoresFromUpload";
import navigateToStore from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.navigateToStore";
import createLog from "@salesforce/apex/LogController.createLog";

const COMPONENT_NAME = "BulkOnboardingFinalErrorCheck";
const CSS_CLASS_DISABLED_TABLE = "disabled-table";
const GENERIC_TOAST_REQUIRED_INFO_ERROR_TITLE = "Unable to Save Store Information";
const GENERIC_TOAST_ERROR_TITLE = "Unable to Remove Store";
const GENERIC_TOAST_ERROR_MESSAGE = "Please try again. If the problem persists, please raise a support ticket.";
const ISSUE_REJECTED = "Rejected";
const ISSUE_NOT_IN_COVERAGE = "Not in Coverage";
const ISSUE_NOT_VERIFIED = "Verification Pending";
const ISSUE_UNKNOWN = "Unknown";
const LIST_TYPE_FAILED = "failed";
const LIST_TYPE_NOT_RUN = "notRun";
const LOGGER_STRING = `==================== ${COMPONENT_NAME} ====================`;
const LOGGER_STYLE_ERROR = "color: red; font-weight: bold;";
const LOGGER_STYLE_NORMAL = "color: red; font-weight: bold;";

const METHOD_NAME_ACCESSIBILITIES = "saveAccessibilities";
const METHOD_NAME_SKIP_STORE = "removeStoreFromUpload";


const REMOVE_STORE_CONFIRM_MSG = "Are you sure you would like to remove this store?";
const REMOVE_STORE_NO_STORES_REMAINING_ERROR = "Unable to proceed. You are attempting to remove all stores from the upload. Please ensure at least one store remains before continuing.";
const SKIP_STORES_CONFIRM_MSG = "Are you sure you would like to skip these not in coverage stores? They will need to be manually added to the Work Order later.";
const SEATTLE_ACCESSIBILITY_KEY = "accessibilities";
const SEATTLE_ACCESSIBILITY_ELEVATORS_KEY = "hasElevatorsOrRamps";
const SEATTLE_ACCESSIBILITY_STAIRS_KEY = "needToClimb";
const SEATTLE_ACCESSIBILITY_ANSWER_YES = "Yes";
const SEATTLE_ACCESSIBILITY_ANSWER_NO = "No";
const SEATTLE_ACCESSIBILITY_ANSWER_IDK = "Not Provided";
const STORE_LOAD_REFRESH_EVENT = "refresh";
const STORE_LOAD_ONLOAD_EVENT = "load";
const VERIFICATION_STATUS_LOWERCASE_VERIFIED = "verified";
const VERIFICATION_STATUS_LOWERCASE_UNVERIFIED = "unverified";
const VERIFICATION_STATUS_LOWERCASE_REJECTED = "rejected";
const COVERAGE_STATUS_LOWERCASE_NOT_IN_COVERAGE = "not in coverage";

export default class BulkOnboardingFinalErrorCheck extends NavigationMixin(LightningElement) {
    @api contractId;
    @track storeFailureDetails;
    @track failedStores = [];
    @track notRunStores = [];
    @track outOfCoverageStores = [];
    @track showMainComponentSpinner = true;
    @track showAccountTableSpinners = true;
    @track showMissingDetailsTableSpinner = true;
    @track showBusinessDetailsSectionSpinner = true;
    @track missingInfoTableClass = CSS_CLASS_DISABLED_TABLE;
    @track showSuccessMessage = false;
    @track isNextDisabled = true;
    @track isSaveDisabled = true;
    @track errorMessage;
    @track globalStairsValue;
    @track globalElevatorsValue;
    @track requiresCanadianDetails = false;
    numberOfStoresRemoved = 0;

    instructionalText = {
        successMessage,
        rejectedMessage,
        outOfCoverageMessage,
        unverifiedMessage,
        mainInstructions,
        accessibilitiesMessage
    };

    fields = {
        elevatorsAccessibilityField,
        stairsAccessibilityField,
        SEATTLE_ACCESSIBILITY_KEY,
        SEATTLE_ACCESSIBILITY_ELEVATORS_KEY,
        SEATTLE_ACCESSIBILITY_STAIRS_KEY
    };

    accessibilityOptions = [
        { label: SEATTLE_ACCESSIBILITY_ANSWER_YES, value: SEATTLE_ACCESSIBILITY_ANSWER_YES },
        { label: SEATTLE_ACCESSIBILITY_ANSWER_NO, value: SEATTLE_ACCESSIBILITY_ANSWER_NO },
        { label: SEATTLE_ACCESSIBILITY_ANSWER_IDK, value: SEATTLE_ACCESSIBILITY_ANSWER_IDK }
    ];

    @api
    set flowRequestId(value) {
        this._recordId = value;
        if (this._recordId) {
            this.getFailedStoreAccounts(STORE_LOAD_ONLOAD_EVENT);
        }
    }
    get flowRequestId() {
        return this._recordId;
    }

    @api
    set flowRequestObj(value) {
        this._recordObj = value;
    }

    get flowRequestObj() {
        return this._recordObj;
    }

    // getter for the private currentStep variable
    get currentStep() {
        return this._currentStep; // return the private property value
    }

    // @api setter for the private currentStep variable
    @api
    set currentStep(value) {
        this._currentStep = (value) ? value.toString() : "1"; // convert to string and store in private property
    }

    async getFailedStoreAccounts(actionType = STORE_LOAD_ONLOAD_EVENT) {
        // If the user refreshes one section, keep the unsaved data in the other sections
        let originalStoresRequiringMoreInfo = [];
        if (actionType === STORE_LOAD_REFRESH_EVENT && this.storeFailureDetails) {
            originalStoresRequiringMoreInfo = JSON.parse(JSON.stringify(this.storeFailureDetails.storesRequiringAdditionalInformation));
        }

        try {
            const result = await getFailedStoreDetails({ flowRequestId: this.flowRequestId });
            this.storeFailureDetails = result;

            if (originalStoresRequiringMoreInfo.length) {
                // Create a map from the original data for quick lookup
                const originalStoresMap = new Map(originalStoresRequiringMoreInfo.map(store => [store.Id, store]));

                // Merge logic - Add the stores requiring more information back
                this.storeFailureDetails.storesRequiringAdditionalInformation = result.storesRequiringAdditionalInformation.map(newStore => {
                    // If the store exists in the original data, use that to preserve user changes
                    if (originalStoresMap.has(newStore.Id)) {
                        return originalStoresMap.get(newStore.Id);
                    }
                    // Otherwise, use the new store data
                    return newStore;
                });
            }

            this.setFailedStores(this.storeFailureDetails); // TODO - We do not need this parameter
            this.setNextButtonStatus();
            this.setSaveButtonStatus();

            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_NORMAL}`);
            console.log(this.storeFailureDetails.allStoresVerified);
            console.log(this.storeFailureDetails.allStoresPassed);
            console.log(this.storeFailureDetails.allStoresFailed);
            console.log(this.storeFailureDetails.someStoresNotVerified);
            console.log(this.storeFailureDetails.failedStores);
            console.log(this.storeFailureDetails.storesRequiringAdditionalInformation);
            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_NORMAL}`);
        } catch (error) {
            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
            console.log("Unable to retrieve failed stores. See error below:");
            console.error(error);
            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
        } finally {
            this.showAccountTableSpinners = false;
            this.showMainComponentSpinner = false;
            this.showMissingDetailsTableSpinner = false;
            this.showBusinessDetailsSectionSpinner = false;
            this.missingInfoTableClass = "";
        }
    }

    async handleRemoveStore(event) {
        const storeId = event.target.dataset.accountId;
        const listType = event.target.dataset.listType;

        const confirmResult = await this.handleConfirmClick(REMOVE_STORE_CONFIRM_MSG);
        if (!confirmResult) {
            return;
        }

        // Edge case where the user tries to remove every store that they uploaded in this ANSO request.
        // We cannot let them proceed doing that since there would then be no stores left to onboard.
        if (this.numberOfStoresRemoved + 1 >= this.storeFailureDetails.totalStores) {
            this.errorMessage = REMOVE_STORE_NO_STORES_REMAINING_ERROR;
            this.showToast(GENERIC_TOAST_ERROR_TITLE, REMOVE_STORE_NO_STORES_REMAINING_ERROR, true);
            return;
        }

        // Note: this shouldn't be in the `then()` callback since there would be a delay in counting that would cause issues if done in quick succession
        this.numberOfStoresRemoved++;

        this.updateSavingStatus(storeId, listType, true);

        try {
            await deleteStore({ storeId: storeId, flowRequestId: this.flowRequestId });
            this.handleRemovalFromAddressLists(storeId, listType);
        } catch (error) {
            this.showToast(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, true);
            this.updateSavingStatus(storeId, listType, false);
            this.showAccountTableSpinners = false;
            // Do not include this store from the removed store count
            this.numberOfStoresRemoved--;

            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
            console.log("Error removing store. See message below:");
            console.error(error);
            console.log(`%c${LOGGER_STRING}`, `${LOGGER_STYLE_ERROR}`);
        }
    }

    // Sets the store to be ignored by the ANSO Batch so it does not immediately get added to the WO.
    // This will remove it from this page as well, so and will no longer be considered as part of the
    // ANSO request.
    async handleConfirmOutOfCoverage() {
        const confirmResult = await this.handleConfirmClick(SKIP_STORES_CONFIRM_MSG);

        if (!confirmResult || !this.outOfCoverageStores.length) {
            return;
        }

        // Set the general saving spinner
        this.showMainComponentSpinner = true;

        try {
            await confirmOutOfCoverage({ flowRequestId: this.flowRequestId });

            // Call to the original retrieval method to reset the state of the stores
            await this.getFailedStoreAccounts();
        } catch (error) {
            console.error(error);
            this.showToast(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, true);

            createLog({
                lwcName: COMPONENT_NAME,
                methodName: METHOD_NAME_SKIP_STORE,
                message: JSON.stringify(error.body)
            });
        } finally {
            this.showMainComponentSpinner = false;
        }
    }

    // Removes the removed store from the applicable address verification lists and resets the component
    handleRemovalFromAddressLists(storeId, listType = LIST_TYPE_FAILED) {
        if (listType === LIST_TYPE_FAILED) {
            this.failedStores = this.failedStores.filter(store => store.id !== storeId);
        } else if (listType === LIST_TYPE_NOT_RUN) {
            this.notRunStores = this.notRunStores.filter(store => store.id !== storeId);
        }

        // Remove from other lists, if applicable
        this.storeFailureDetails.storesRequiringAdditionalInformation = this.storeFailureDetails.storesRequiringAdditionalInformation.filter(store => store.Id !== storeId);
        this.showAccountTableSpinners = false;
        this.refreshIfApplicable();
    }

    // Updates the mini saving spinner for each store when the "Remove" link is clicked
    updateSavingStatus(storeId, listType, isSaving) {
        if (listType === LIST_TYPE_FAILED) {
            this.failedStores = this.failedStores.map(store => {
                if (store.id === storeId) {
                    return {
                        ...store,
                        isSaving: isSaving
                    };
                }
                return store;
            });
        } else if (listType === LIST_TYPE_NOT_RUN) {
            this.notRunStores = this.notRunStores.map(store => {
                if (store.id === storeId) {
                    return {
                        ...store,
                        isSaving: isSaving
                    };
                }
                return store;
            });
        }
    }

    // Save the Accessibilities values
    serializeAndSaveAccessibilities() {
        this.showMissingDetailsTableSpinner = true;
        const accessibilitiesData = {};

        // Parse the store data in the expected format
        this.storeFailureDetails.storesRequiringAdditionalInformation.forEach(store => {
            const lowerCaseNotProvided = SEATTLE_ACCESSIBILITY_ANSWER_IDK.toLowerCase();
            const lowerCaseYes = SEATTLE_ACCESSIBILITY_ANSWER_YES.toLowerCase();

            // Check if either value is "Not Provided" and handle accordingly
            if (store[SEATTLE_ACCESSIBILITY_STAIRS_KEY].toLowerCase() === lowerCaseNotProvided ||
                store[SEATTLE_ACCESSIBILITY_ELEVATORS_KEY].toLowerCase() === lowerCaseNotProvided) {
                accessibilitiesData[store.Id] = lowerCaseNotProvided;
            } else {
                // Convert the accessibility options to boolean
                const needToClimbForThisStore = store[SEATTLE_ACCESSIBILITY_STAIRS_KEY].toLowerCase() === lowerCaseYes;
                const hasElevatorOrRampForThisStore = store[SEATTLE_ACCESSIBILITY_ELEVATORS_KEY].toLowerCase() === lowerCaseYes;

                const storeAccessibility = {
                    [SEATTLE_ACCESSIBILITY_KEY]: {
                        [SEATTLE_ACCESSIBILITY_STAIRS_KEY]: needToClimbForThisStore,
                        [SEATTLE_ACCESSIBILITY_ELEVATORS_KEY]: hasElevatorOrRampForThisStore
                    }
                };

                accessibilitiesData[store.Id] = JSON.stringify(storeAccessibility);
            }
        });

        // Call Apex to save the missing data
        saveAccessibilitiesData({ accessibilitiesMap: accessibilitiesData })
            .then(() => {
                // Empty the array
                this.storeFailureDetails.storesRequiringAdditionalInformation = [];

                this.showMainComponentSpinner = true;
                this.showAccountTableSpinners = true;
                this.showMissingDetailsTableSpinner = true;
                this.refresh();
            })
            .catch(error => {
                // Reset the loading indicators
                this.showMissingDetailsTableSpinner = false;
                this.missingInfoTableClass = "";

                console.error(error);

                this.showToast(GENERIC_TOAST_REQUIRED_INFO_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, true);

                createLog({
                    lwcName: COMPONENT_NAME,
                    methodName: METHOD_NAME_ACCESSIBILITIES,
                    message: JSON.stringify(error.body)
                });
            });
    }

    // Handler function for when one of the "Set for all Stores" Accessibilities fields is updated
    updateAllFieldsWithSameValue(event) {
        const fieldName = event.target.name; // SEATTLE_ACCESSIBILITY_STAIRS_KEY or SEATTLE_ACCESSIBILITY_ELEVATORS_KEY
        const fieldValue = event.detail.value; // The selected option's value

        // Assuming storeFailureDetails.storesRequiringAdditionalInformation is already defined in your class
        // and it's the array of stores you're iterating over in your template
        this.storeFailureDetails.storesRequiringAdditionalInformation =
            this.storeFailureDetails.storesRequiringAdditionalInformation.map(store => {
                // Check which field to update based on the name of the target that triggered the event
                if (fieldName === SEATTLE_ACCESSIBILITY_STAIRS_KEY) {
                    store[SEATTLE_ACCESSIBILITY_STAIRS_KEY] = fieldValue; // Update the hasStairs property
                } else if (fieldName === SEATTLE_ACCESSIBILITY_ELEVATORS_KEY) {
                    store[SEATTLE_ACCESSIBILITY_ELEVATORS_KEY] = fieldValue; // Update the elevators property
                }

                this.updateSiblingFields(store.Id, fieldName, fieldValue);
                return store; // Return the updated store object
            });

        this.setSaveButtonStatus();
    }

    // Handler function for when one of the Accessibilities fields is updated
    updateAdditionalRequiredField(event) {
        const storeId = event.target.dataset.storeId; // Get the store ID
        const fieldName = event.target.name; // 'needToClimb' or 'hasElevatorsOrRamps'
        const fieldValue = event.detail.value; // The selected option's value

        // Find the store in the array and update the specified field
        const storeIndex = this.storeFailureDetails.storesRequiringAdditionalInformation.findIndex(store => store.Id === storeId);
        if (storeIndex !== -1) {
            this.storeFailureDetails.storesRequiringAdditionalInformation[storeIndex][fieldName] = fieldValue;
            this.updateSiblingFields(storeId, fieldName, fieldValue);
        }

        this.setSaveButtonStatus();
    }

    // When an "Accessibilities" field is updated, this keeps the "sibling" field(s) in sync.
    // This accommodates the requirement where a "Not Provided" value applies to the Accessibilites globally.
    // As a result, if "Not Provided" is selected for one field, we should apply that value to the other
    // fields for that store. Similarly, if a field is updated and is no longer "Not Provided", then we should
    // update the sibling fields to remove that old "Not Provided" value.
    updateSiblingFields(storeId, updatedFieldName, updatedValue) {
        const allFields = [SEATTLE_ACCESSIBILITY_ELEVATORS_KEY, SEATTLE_ACCESSIBILITY_STAIRS_KEY];

        const storeIndex = this.storeFailureDetails.storesRequiringAdditionalInformation.findIndex(store => store.Id === storeId);

        if (storeIndex !== -1) {
            const store = this.storeFailureDetails.storesRequiringAdditionalInformation[storeIndex];

            // When "Not Provided" is selected
            if (updatedValue === SEATTLE_ACCESSIBILITY_ANSWER_IDK) {
                // Set all sibling fields to "Not Provided"
                allFields.forEach(field => {
                    store[field] = SEATTLE_ACCESSIBILITY_ANSWER_IDK;
                });
                // When a value besides "Not Provided" is selected
            } else {
                // Update the field to the new value
                store[updatedFieldName] = updatedValue;

                // Reset any "Not Provided" siblings to null if the updated value is different
                allFields.forEach(field => {
                    if (store[field] === SEATTLE_ACCESSIBILITY_ANSWER_IDK) {
                        store[field] = null;
                    }
                });
            }
        }
    }

    handleBusinessContactFormCompletion() {
        this.storeFailureDetails.requiresCanadianDetails = false;
        this.setNextButtonStatus();
    }

    // Event handler invoked from the "Next" button
    handleNext() {
        this.dispatchEvent(new CustomEvent("navigatetocompletion"));
    }

    // Method to navigate to the record page of the linked failed Stores
    navigateToAccount(event) {
        event.preventDefault();
        const accountId = event.target.dataset.storeId;

        if (accountId) {
            // Call method to log the Store ID, without waiting for completion
            navigateToStore({ storeId: accountId, flowRequestId: this.flowRequestId })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error logging Store navigation',
                            message: error.body ? error.body.message : error.message,
                            variant: 'error',
                        }),
                    );
                });

            // Proceed with navigation
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    recordId: accountId,
                    objectApiName: "Account",
                    actionName: "view",
                },
            }).then(url => {
                window.open(url, "_blank");
            });
        }
    }

    // Sets the store arrays so the user can see which stores have not yet been completed
    setFailedStores(storeResults) {
        this.logger(storeResults);
        this.setStoreFailuresByType(storeResults.failedStores);

        // Set the notRunStores array by calling the createCustomObjects function
        this.notRunStores = this.createCustomObjects(storeResults.storesNotRun);

        // Shows required compliance details for Canadian businesses
        this.requiresCanadianDetails = storeResults.requiresCanadianDetails;

        this.logger(this.failedStores);
        this.logger(this.notRunStores);
        console.log("--------------------");
        console.log("--------------------");
    }

    getVerificationIssueString(storeRecord) {
        if (!storeRecord) {
            return ISSUE_UNKNOWN;
        }

        if (storeRecord.Coverage__c && storeRecord.Coverage__c.toLowerCase() === COVERAGE_STATUS_LOWERCASE_NOT_IN_COVERAGE) {
            return ISSUE_NOT_IN_COVERAGE;
        }
        if (storeRecord.Address_Verification_Status__c && storeRecord.Address_Verification_Status__c.toLowerCase() === VERIFICATION_STATUS_LOWERCASE_REJECTED) {
            return ISSUE_REJECTED;
        }
        if (storeRecord.Address_Verification_Status__c && storeRecord.Address_Verification_Status__c.toLowerCase() === VERIFICATION_STATUS_LOWERCASE_UNVERIFIED) {
            return ISSUE_NOT_VERIFIED;
        }

        return ISSUE_UNKNOWN;
    }

    // Separates the failed stores by rejected (`failedStores`) vs out of coverage (`notInCoverageStores`)
    setStoreFailuresByType(allFailedStores) {
        this.failedStores = [];
        this.outOfCoverageStores = [];

        allFailedStores.forEach((store) => {
            if (store.Coverage__c && store.Coverage__c.toLowerCase() === COVERAGE_STATUS_LOWERCASE_NOT_IN_COVERAGE) {
                this.outOfCoverageStores.push(store);
            } else if (store.Address_Verification_Status__c && store.Address_Verification_Status__c.toLowerCase() === VERIFICATION_STATUS_LOWERCASE_REJECTED) {
                this.failedStores.push(store);
            }
        });

        this.failedStores = this.createCustomObjects(this.failedStores);
        this.outOfCoverageStores = this.createCustomObjects(this.outOfCoverageStores);
    }

    // Returns a boolean if the Address Verification Status is set to `Verified`
    getVerificationBoolean(storeRecord) {
        return storeRecord.Address_Verification_Status__c && (storeRecord.Address_Verification_Status__c.toLowerCase() === VERIFICATION_STATUS_LOWERCASE_VERIFIED);
    }

    // Creates a custom object for each store to include attributes like the `isSaving` flag
    // so that the stores render appropriately in the UI
    createCustomObjects(storeRecords) {
        return storeRecords.map(storeRecord => {
            return {
                ...storeRecord, // Spread operator to include all Account fields and values
                id: storeRecord.Id,
                isSaving: false, // Include the isSaving boolean attribute set to false
                verificationIssue: this.getVerificationIssueString(storeRecord), // Set the verificationIssue attribute
                isVerifiedSuccessfully: this.getVerificationBoolean(storeRecord)
            };
        });
    }

    refreshIfApplicable() {
        // No more stores left to show - reset the component so it goes back to its success state
        if ((!this.failedStores || this.failedStores.length === 0) && (!this.notRunStores || this.notRunStores.length === 0)) {
            this.refresh();
        }
    }

    // Handler for the "Refresh" button to reset the stores grid
    refresh() {
        this.numberOfStoresRemoved = 0;
        this.errorMessage = null;
        this.showMainComponentSpinner = true;
        this.missingInfoTableClass = CSS_CLASS_DISABLED_TABLE;

        this.getFailedStoreAccounts(STORE_LOAD_REFRESH_EVENT);
    }

    // This enables/disables the `Next` button to advance past the Final Error Check screen into the
    // next step in the ANSO flow
    setNextButtonStatus() {
        this.isNextDisabled = !this.storeFailureDetails.allStoresPassed || this.storeFailureDetails.requiresCanadianDetails;
        this.showSuccessMessage = !this.isNextDisabled;
    }

    // This enables/disables the `Save` button for the `Accessibilities` section
    setSaveButtonStatus() {
        if (this.storeFailureDetails.storesRequiringAdditionalInformation.length) {
            let disableSave = false;

            for (let i = 0; i < this.storeFailureDetails.storesRequiringAdditionalInformation.length; i++) {
                const currentStore = this.storeFailureDetails.storesRequiringAdditionalInformation[i];

                if (!currentStore[SEATTLE_ACCESSIBILITY_STAIRS_KEY] || !currentStore[SEATTLE_ACCESSIBILITY_ELEVATORS_KEY]) {
                    disableSave = true;
                    break;
                }
            }

            this.isSaveDisabled = disableSave;
        }
    }

    handleConfirmClick(confirmMessage) {
        const result = LightningConfirm.open({
            label: "Remove Store",
            message: confirmMessage,
            variant: "header",
            theme: "warning"
        });

        return result;
    }

    showToast(title, message, isError) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: isError ? "error" : "success"
            })
        );
    }

    logger(obj) {
        console.log(JSON.parse(JSON.stringify(obj)));
    }
}