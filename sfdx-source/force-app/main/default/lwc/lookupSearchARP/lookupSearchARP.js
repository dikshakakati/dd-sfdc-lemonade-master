import fetchRecords from "@salesforce/apex/ManagePricingScreenController.fetchRecords";
import { LightningElement, api } from "lwc";

const DELAY = 500; // The delay used when debouncing event handlers before invoking Apex

export default class LookupSearch extends LightningElement {
    @api helpText = "";
    @api label = "";
    @api required;
    @api selectedIconName;
    @api objectLabel;
    recordsList = [];
    selectedRecordName;

    @api objectApiName = "Account";
    @api fieldApiName = "Name";
    @api otherFieldApiName = "Entity_Type__c";
    @api searchString = "";
    @api selectedRecordId = "";
    @api parentRecordId;
    @api parentFieldApiName;

    preventClosingOfSerachPanel = false;

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            otherFieldApiName: this.otherFieldApiName,
            searchString: this.searchString,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName
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
        if(this.searchString && this.searchString.length >= 3) {
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

        // Creates the event
        const removeEvent = new CustomEvent("valueremoved", {
        });
        //dispatching the custom event
        this.dispatchEvent(removeEvent);
    }

    // The handler for selection of records from lookup result list
    handleSelect(event) {
        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            id: event.currentTarget.dataset.id
        };
        this.selectedRecordId = selectedRecord.id;
        this.selectedRecordName = selectedRecord.mainField;
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