/*
*@author Deloitte
*@date 26 June 2024
*@description LEM-16419 JavaScript controller for DisplayRelatedReadinessCheckFailure lightning web component.
*/
import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { setMessage, setVariant, showNotification } from 'c/utils';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import WORK_ORDER_NUMBER_FIELD from "@salesforce/schema/WorkOrder.WorkOrderNumber";
import getFields from "@salesforce/apex/DisplayRelatedReadinessCheckController.getFields";
import getReadinessCheckFailureDetails from "@salesforce/apex/DisplayRelatedReadinessCheckController.getReadinessCheckFailureDetails";
import getReadinessCheckFailureUpdatedDetails from "@salesforce/apex/DisplayRelatedReadinessCheckController.getReadinessCheckFailureUpdatedDetails";
import createLog from "@salesforce/apex/LogController.createLog";
import spinnerAltenativeText from '@salesforce/label/c.Spinner_Alternative_Text';
import viewAllText from "@salesforce/label/c.View_All_Link_In_LWC";

const LWC_NAME = "DisplayRelatedReadinessCheckFailure";
const GET_FIELD_SET_FIELDS = "getFields";
const OBJECT_API_NAME_WORK_ORDER = "WorkOrder";
const GET_READINESS_CHECK_FAILURE_DETAILS = "getReadinessCheckFailureDetails";
const TOAST_VARIANT = "error";
const TARGET_INDEX = '" target';
const HREF_INDEX = 'href="';
const OBJECT_INDEX = '>';
const OBJECT_INDEX_END = '</';
const HREF_START_INDEX = '<a';
const NAVIGATE_TO_PAGE = "navigateToPage";
const OBJECT_PAGE = "standard__objectPage"
const WEB_PAGE = "standard__webPage"
const HANDLE_LIST_VIEW_NAVIGATION = "handleListViewNavigation";
const RECORD_PAGE = "standard__recordPage";
const WORKORDER = "WorkOrder";
const VIEW = "view";
const HANDLE_RECORD_NAVIGATION = "handleRecordNavigation";

export default class DisplayRelatedReadinessCheckFailure extends NavigationMixin(LightningElement) {
    @api recordId;
    @api viewAll;
    @track recordsToBeDisplayed = [];
    @track columns = [];
    @track viewAllColumns = [];
    @track data = [];
    parentComponentName = "c:displayRelatedreadinessCheckFailure";
    showComponent = false;
    defaultSortDirection = "asc";
    sortDirection = "asc";
    sortedBy;
    showTable = false;
    numberOfItems;
    title = "Readiness Check Corrections";
    loading = true;
    loadingAlternativeText = spinnerAltenativeText;
    objectName = OBJECT_API_NAME_WORK_ORDER;
    labels = { viewAllText };


    /*
    *@description It is used to get parent Work Order's details.
    */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [WORK_ORDER_NUMBER_FIELD]
    })
    parentWorkOrder;

    /*
    *@description It returns parent Work Order's auto-number.
    */
    get workOrderNumber() {
        let workOrderNumberFieldValue = getFieldValue(this.parentWorkOrder.data, WORK_ORDER_NUMBER_FIELD);
        return workOrderNumberFieldValue !== undefined ? workOrderNumberFieldValue : null;
    }

    /*
    *@description It is used to render view all records page.
    */
    viewAllRecords() {
        this.viewAll !== undefined ? this.viewAll : false;
    }

    /*
    *@description It is used to get columns to displayed in the datatable.
    */
    @wire(getFields)
    setFields({ error, data }) {
        try {
            if (data) {
                let allColumns = JSON.parse(data);
                allColumns.forEach((retrievedRecord) => {
                    retrievedRecord.hideDefaultActions = false;
                    retrievedRecord.sortable = true;
                    retrievedRecord.wrapText = true;
                });
                this.viewAllColumns = [...allColumns];
                this.columns = [...allColumns].splice(0, 9);
            }
        }
        catch (error) {
            createLog({ lwcName: LWC_NAME, methodName: GET_FIELD_SET_FIELDS, message: JSON.stringify(error.body) });
            setMessage(error.body?.message);
            setVariant(TOAST_VARIANT);
            showNotification(this);
        }
    }

    /*
    *@description It is used to set the readiness check details to be displayed.
    */
    @wire(getReadinessCheckFailureDetails, { recordId: '$recordId' })
    setReadinessCheckFailureDetails({ error, data }) {
        try {
            if (data) {
                this.initializeTableData(data);
                this.viewAllRecords();
                this.recordCount();
                this.showComponent = true;
                this.loading = false;
            }
        }
        catch (error) {
            createLog({ lwcName: LWC_NAME, methodName: GET_READINESS_CHECK_FAILURE_DETAILS, message: JSON.stringify(error.body) });
            setMessage(error.body?.message);
            setVariant(TOAST_VARIANT);
            showNotification(this);
        }
    }

    /*
    *@description It is used to get the hyperlink for URL column.
    */
    getHyperLink(idToEvaluate) {
        if (typeof idToEvaluate == "undefined") {
            return '';
        }
        const hyperLink = idToEvaluate.substring(
            idToEvaluate.indexOf(HREF_INDEX) + 6,
            idToEvaluate.indexOf(TARGET_INDEX)
        );
        return hyperLink;

    }

    /*
    *@description To get total no. of records.
    */
    recordCount() {
        let count = this.recordsToBeDisplayed.length;
        if (count > 0) {
            this.showTable = true;
        }
        if (this.viewAll) {
            this.data = [...this.recordsToBeDisplayed];
            if (count > 1) {
                this.numberOfItems = count + " items";
            } else {
                this.numberOfItems = count + " item";
            }

        } else {
            if (count > 6) {
                this.numberOfItems = "(6+)";
                this.data = this.recordsToBeDisplayed.slice(0, 6);
            } else {
                this.numberOfItems = "(" + count + ")";
                this.data = this.recordsToBeDisplayed.slice();
            }
        }
    }


    /*
    *@description To sort table by selected column.
    */
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    /*
    *@description To Navigate to the display view all records page.
    */
    navigateToPage() {
        try {
            let definition = {
                componentDef: this.parentComponentName,
                attributes: {
                    recordId: this.recordId,
                    viewAll: true
                }
            };
            this[NavigationMixin.Navigate]({
                type: WEB_PAGE,
                attributes: {
                    url: "/one/one.app#" + btoa(JSON.stringify(definition))
                }
            });
        }
        catch (error) {
            createLog({ lwcName: LWC_NAME, methodName: NAVIGATE_TO_PAGE, message: JSON.stringify(error) });
        }
    }

    /*
    *@description To Navigate to the object's pinned list view.
    */
    handleListViewNavigation() {
        try {
            this[NavigationMixin.Navigate]({
                type: OBJECT_PAGE,
                attributes: {
                    objectApiName: this.objectName,
                    actionName: "list"
                }
            });
        } catch (error) {
            createLog({ lwcName: LWC_NAME, methodName: HANDLE_LIST_VIEW_NAVIGATION, message: JSON.stringify(error) });
        }
    }

    /*
    *@description-To fetch updated readiness check record.
    */
    handleRefresh() {
        this.loading = true;
        this.showComponent = false;
        getReadinessCheckFailureUpdatedDetails({
            recordId: this.recordId
        }).then(result => {
            this.initializeTableData(result);
            setTimeout(() => {
                this.viewAllRecords();
                this.recordCount();
                this.showComponent = true;
                this.loading = false;
            }, 3000);

        }).catch(error => {
            createLog({ lwcName: LWC_NAME, methodName: NAVIGATE_TO_PAGE, message: JSON.stringify(error) });
        });
    }

    /*
    *@description Processes the an array of Readiness Check Failure records and prepares them for display in the datatable.
    *This method updates the records with hyperlinks for certain fields and formats the data to be displayed in the component.
    */
    initializeTableData(data) {
        let retrievedRecords = data.map((Readiness_Check_Failure__c) => ({
            ...Readiness_Check_Failure__c
        }));
        retrievedRecords.forEach((retrievedRecord) => {
            retrievedRecord.accountNameHyperlink = '/' + retrievedRecord.Account_Name__c;
            retrievedRecord.Account_Name__c = retrievedRecord.Account_Name__r.Name;
            const objectNameLink = retrievedRecord.Object_Link__c;
            const fixErrorLink = retrievedRecord.Fix_Error_Link__c;
            if (objectNameLink !== "undefined") {
                retrievedRecord.objectNameHyperlink = this.getHyperLink(objectNameLink);
                retrievedRecord.Object_Link__c = objectNameLink.substring(objectNameLink.indexOf(OBJECT_INDEX) + 1, objectNameLink.indexOf(OBJECT_INDEX_END));
            }
            if (fixErrorLink !== "undefined") {
                retrievedRecord.fixErrorLinkHyperlink = this.getHyperLink(fixErrorLink);
                retrievedRecord.Fix_Error_Link__c = fixErrorLink?.substring(0, fixErrorLink.indexOf(HREF_START_INDEX)) + fixErrorLink?.substring(fixErrorLink.indexOf(OBJECT_INDEX) + 1, fixErrorLink.indexOf(OBJECT_INDEX_END));
            }
        });
        this.recordsToBeDisplayed = [...retrievedRecords];
    }

    /**
       * @description It is used to navigate to the Work Order record page.
       */
    handleRecordNavigation() {
        try {
            this[NavigationMixin.Navigate]({
                type: RECORD_PAGE,
                attributes: {
                    recordId: this.recordId,
                    objectApiName: WORKORDER,
                    actionName: VIEW
                }
            });
        } catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: HANDLE_RECORD_NAVIGATION,
                message: JSON.stringify(error)
            });
        }
    }
}