/**
 * @author Deloitte
 * @date 11/10/2023
 * @description JavaScript controller for bulkOnboardingDuplicateAccounts lightning web component.
 */
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import COLUMN_HEADER_ADDRESS from "@salesforce/label/c.Match_Accounts_Column_Header_Address";
import COLUMN_HEADER_NAME from "@salesforce/label/c.Match_Accounts_Column_Header_Name";
import COLUMN_HEADER_PARENT_ACCOUNT from "@salesforce/label/c.Match_Accounts_Column_Header_Parent_Account";
const ACTION_NAME = 'view';
const OBJECT_API_NAME = 'Account';
const TARGET = "_blank";
const TYPE = 'standard__recordPage';
export default class BulkOnboardingDuplicateAccounts extends NavigationMixin(LightningElement) {
    label = {
        COLUMN_HEADER_NAME,
        COLUMN_HEADER_ADDRESS,
        COLUMN_HEADER_PARENT_ACCOUNT
    };
    isMatchRecordsLoading = true;
    @track accountIdToOpen;
    @track matchRecords = [];
    @api rowNumber;
    @api rowName;
    @api hasNonDuplicateErrors;

    /**
     * @description setter for potentialMatches
     * @param matchResults
     */    
    @api
    set potentialMatches(matchResults) {
        this.addMatchedRecords(matchResults);
    }

    get potentialMatches() {
        return this.matchRecords;
    }

    /**
     * @description Getter for the remove button label
     */      
    get removeButtonLabel() {
        return `Remove ${this.rowName} from the Upload File`;
    }

    /**
     * @description Getter for the continue button label
     */    
    get continueButtonLabel() {
        return `Continue Uploading ${this.rowName}`;
    }

    /**
     * @description It is used to get the matching accounts to show in the table.
     * @param matchResults
     */
    addMatchedRecords(matchResults) {
        if (Array.isArray(matchResults) && matchResults.length > 0) {
            this.matchRecords = matchResults;
            this.isMatchRecordsLoading = false;
        }
    }

    /**
     * @description Event handler for "Remove Store from Upload File" button
     */
    removeStore() {
        const removeEvent = new CustomEvent("removestore", {
            detail: this.rowNumber,
        });

        this.dispatchEvent(removeEvent);
        this.navigateToUploadCsvPage();
    }

    /**
     * @description Event handler for "Insert Store" button
     */
    forceUpload() {
        const uploadEvent = new CustomEvent("forceupload", {
            detail: this.rowNumber,
        });

        this.dispatchEvent(uploadEvent);
        this.navigateToUploadCsvPage();
    }
    
    /**
     * @description It is used to navigate back to the error list on the upload csv page.
     */
    navigateToUploadCsvPage() {
        const backToErrorsList = new CustomEvent('backtoerrormessage');
        this.dispatchEvent(backToErrorsList);
    }

    /**
     * @description It is used to navigate to the account record on click of the corresponding link.
     * @param event
     */
    navigateToAccountRecordPage(event) {
        this.accountIdToOpen = event.target.dataset.row;
        this[NavigationMixin.GenerateUrl]({
            type: TYPE,
            attributes: {
                recordId: this.accountIdToOpen,
                objectApiName: OBJECT_API_NAME,
                actionName: ACTION_NAME,
            },
        }).then(url => {
            window.open(url, TARGET);
        });
    }
}