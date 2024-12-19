import { LightningElement, api } from "lwc";
import fetchRecords from "@salesforce/apex/LookupSearchCtrl.fetchRecords";

const DELAY = 500; // The delay used when debouncing event handlers before invoking Apex

export default class LookupSearch extends LightningElement {
    @api helpText = "";
    @api label = "";
    @api required;
    @api selectedIconName;
    @api objectLabel;
    @api defaultSelection;
    @api doNotPersistSelection;
    recordsList = [];
    selectedRecordName;

    @api objectApiName = "Account";
    @api primaryFieldToSearch = "Name";
    @api secondaryField = "Entity_Type__c";
    @api fieldsToQuery = "";
    @api searchString = "";
    @api selectedRecordId = "";
    @api parentRecordId;
    @api parentFieldApiName;
    @api recordsLimit;

    preventClosingOfSerachPanel = false;

    @api
    clearInput() {
        const inputElement = this.template.querySelector('lightning-input');
        if (inputElement) {
            inputElement.value = ''; // Resetting the value directly
        }
    }

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            primaryFieldToSearch: this.primaryFieldToSearch,
            secondaryField: this.secondaryField,
            fieldsToQuery: this.fieldsToQuery,
            searchString: this.searchString,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName,
            recordsLimit: this.recordsLimit
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }

    // Get the default selected record
    connectedCallback() {
        if (this.defaultSelection) {
            this.selectedRecordId = this.defaultSelection.Id;
            this.selectedRecordName = this.defaultSelection.Name;
        }
        if (this.selectedRecordId) {
            this.fetchSobjectRecords(true);
        }
    }

    // Calls the Apex method with our search parameters
    fetchSobjectRecords(loadEvent) {
        fetchRecords({
            inputWrapper: this.methodInput
        }).then(result => {
            if (loadEvent && result) {
                this.selectedRecordName = result[0].mainField;
            } else if (result) {
                this.recordsList = JSON.parse(JSON.stringify(result));
            } else {
                this.recordsList = [];
            }
        }).catch(error => {
            console.log(error);
        })
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    // Handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;

        // Only fetch records if search string has at least 3 characters
        if (this.searchString && this.searchString.length >= 3) {
            this.fetchSobjectRecords(false);
        } else {
            // Clear records list if search string is less than 3 characters
            this.recordsList = [];
        }
    }

    // Handler for clicking outside the selection panel
    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSerachPanel = false;
    }

    // This handles the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    // The handler for deselection of the selected item
    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";
        this.dispatchEvent(new CustomEvent("valueremoved"));
    }

    // The handler for selection of records from lookup result list
    handleSelect(event) {
        const recordIndex = this.recordsList.findIndex(wrapperDetails => wrapperDetails.record.Id === event.currentTarget.dataset.id);
        let theRecord;

        if (recordIndex !== -1) {
            theRecord = this.recordsList[recordIndex];
        }

        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            record: theRecord,
            id: event.currentTarget.dataset.id
        };

        if (this.doNotPersistSelection !== "true") {
            this.selectedRecordId = selectedRecord.id;
            this.selectedRecordName = selectedRecord.mainField;
        } else {
            this.handleCommit();
        }

        this.recordsList = [];
        // Creates the event
        const selectedEvent = new CustomEvent("valueselected", {
            detail: selectedRecord
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    // Closes the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }
}