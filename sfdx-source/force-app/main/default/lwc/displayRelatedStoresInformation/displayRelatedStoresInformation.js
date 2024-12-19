/**
 * @author Deloitte
 * @date 12/12/2023
 * @description LEM-11509 JavaScript controller for displayRelatedStoreInformation lightning web component.
 */
import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { setMessage, setVariant, showNotification } from 'c/utils';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/WorkOrder.Work_Order_Name__c";
import WORK_ORDER_NUMBER_FIELD from "@salesforce/schema/WorkOrder.WorkOrderNumber";
import WORK_ORDER_TYPE from "@salesforce/schema/WorkOrder.Type__c";
import getFields from "@salesforce/apex/DisplayRelatedStoresInformationCtrl.getFields";
import getAccountDetails from "@salesforce/apex/DisplayRelatedStoresInformationCtrl.getAccountDetails";
import createLog from "@salesforce/apex/LogController.createLog";
import exportButtonLabel from "@salesforce/label/c.Export_Button_Label_On_Work_Order";
import spinnerAltenativeText from '@salesforce/label/c.Spinner_Alternative_Text';
import relatedStoreAccounts from "@salesforce/label/c.Related_Store_Accounts";
import fileName from "@salesforce/label/c.RelatedStoresInformationOnWO_File_Title";

const CSV_EXTENSION = '.csv';
const LWC_NAME = "DisplayRelatedStoresInformation";
const GET_FIELD_SET_FIELDS = "getFields";
const GET_ACCOUNT_DETAILS = "getAccountDetails";
const HYPHEN_DELIMETER = "-";
const OBJECT_API_NAME_WORK_ORDER = "WorkOrder";
const TARGET_INDEX = '" target';
const TOAST_VARIANT = "error";
const HREF_INDEX = 'href="';
const STORE_INDEX = 'store/';
const BUSINESS_INDEX = 'business/';
const STORE_ID_INDEX = 'store_id=';
const EXTERNAL_ID_SOURCE_MDS = 'MDS';
const WORK_ORDER_TYPES_TO_DISPLAY_ONLY_MDS_XREFS = ['Ads & Promos'];

export default class DisplayRelatedStoresInformation extends NavigationMixin(LightningElement) {
    @api recordId;
    @api viewAll;
    @track recordsToBeDisplayed = [];
    @track columns = [];
    @track viewAllColumns = [];
    showComponent = false;
    showExportButton = false;
    exportFileTitle;
    labels = {
        exportButtonLabel,
        relatedStoreAccounts,
        fileName
    };
    loading = true;
    loadingAlternativeText = spinnerAltenativeText;
    objectApiName = OBJECT_API_NAME_WORK_ORDER;

    /**
     * @description It is used to get parent Work Order's details.
     */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [NAME_FIELD, WORK_ORDER_NUMBER_FIELD, WORK_ORDER_TYPE]
    })
    parentWorkOrder;

    /**
     * @description It returns parent Work Order's name.
     */
    get recordName() {
        let nameFieldValue = getFieldValue(this.parentWorkOrder.data, NAME_FIELD);
        return nameFieldValue !== undefined ? nameFieldValue : null;
    }

    /**
     * @description It returns parent Work Order's auto-number.
     */
    get workOrderNumber() {
        let workOrderNumberFieldValue = getFieldValue(this.parentWorkOrder.data, WORK_ORDER_NUMBER_FIELD);
        return workOrderNumberFieldValue !== undefined ? workOrderNumberFieldValue : null;
    }

    /**
     * @description It returns parent Work Order's Type.
     */
    get workOrderType() {
        let workOrderTypeFieldValue = getFieldValue(this.parentWorkOrder.data, WORK_ORDER_TYPE);
        return workOrderTypeFieldValue !== undefined ? workOrderTypeFieldValue : null;
    }

    /**
     * @description It is used to render view all records page.
     */
    get viewAllRecords() {
        return this.viewAll !== undefined ? this.viewAll : false;
    }

    /**
    * @description It is used to get columns to displayed in the datatable.
    */
    @wire(getFields)
    setFields({ error, data }) {
        if (data) {
            let allColumns = JSON.parse(data);
            allColumns.forEach((retrievedRecord) => {
                retrievedRecord.hideDefaultActions = false;
                retrievedRecord.sortable = true;
            });
            this.viewAllColumns = [...allColumns];
            this.columns = [...allColumns].splice(0, 9);
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_FIELD_SET_FIELDS,
                message: JSON.stringify(error.body)
            });
            setMessage(error.body.message);
            setVariant(TOAST_VARIANT);
            showNotification(this);
        }
    }

    /**
    * @description It is used to set the account and Xref details to be displayed.
    */
    @wire(getAccountDetails, { recordId: '$recordId' })
    setAccountDetails({ error, data }) {
        if (data) {
            let retrievedRecords = data.map((account) => ({
                ...account
            }));
            retrievedRecords.forEach((retrievedRecord) => {
                retrievedRecord.accountNameHyperlink = '/' + retrievedRecord.Id;
                if (retrievedRecord.Xrefs__r != null) {
                    if (WORK_ORDER_TYPES_TO_DISPLAY_ONLY_MDS_XREFS.includes(this.workOrderType)) {
                        retrievedRecord.Xrefs__r.forEach((eachXref) => {
                            if (eachXref.External_ID_Source__c === EXTERNAL_ID_SOURCE_MDS) {
                                this.handleHyperLinkValues(eachXref, retrievedRecord);
                            }
                        });
                    } else {
                        this.handleHyperLinkValues(retrievedRecord.Xrefs__r[0], retrievedRecord);
                    }
                }
            });
            this.recordsToBeDisplayed = [...retrievedRecords];
            this.showComponent = true;
            this.showExportButton = this.recordsToBeDisplayed.length > 0 ? true : false;
            let workOrderNumberInFileTitle = this.workOrderNumber ? HYPHEN_DELIMETER + this.workOrderNumber : '';
            this.exportFileTitle = this.labels.fileName + workOrderNumberInFileTitle + HYPHEN_DELIMETER + Date.now() + CSV_EXTENSION;
            this.loading = false;
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_ACCOUNT_DETAILS,
                message: JSON.stringify(error.body)
            });
            setMessage(error.body.message);
            setVariant(TOAST_VARIANT);
            showNotification(this);
        }
    }

    /**
      * @description It is used to get the hyperlink.
      * @param idToEvaluate
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

    /**
      * @description To display spinner till the data is exported in a file.
      */
    handleExport() {
        this.loading = !this.loading;
    }

    /**
      * @description To collect hyperlinks from Xref to display in Store Account related list.
      * @param xref
      * @param retrievedRecord
      */
    handleHyperLinkValues(xref, retrievedRecord) {
        const mintStoreID = xref.MINT_Store_Page__c;
        if (typeof mintStoreID !== "undefined") {
            retrievedRecord.mintStorePageHyperlink = this.getHyperLink(mintStoreID);
            retrievedRecord.MINT_Store_Page__c = mintStoreID.substring(
                mintStoreID.indexOf(STORE_INDEX) + 6,
                mintStoreID.indexOf(TARGET_INDEX));
        }
        const mintBusinessID = xref.Mint_BusinessPage__c;
        if (typeof mintBusinessID !== "undefined") {
            retrievedRecord.mintBusinessPageHyperlink = this.getHyperLink(mintBusinessID);
            retrievedRecord.Mint_BusinessPage__c = mintBusinessID.substring(
                mintBusinessID.indexOf(BUSINESS_INDEX) + 9,
                mintBusinessID.indexOf(TARGET_INDEX));
        }
        const posPageID = xref.POS_Page__c;
        if (typeof posPageID !== "undefined") {
            retrievedRecord.posPageHyperlink = this.getHyperLink(posPageID);
            retrievedRecord.POS_Page__c = posPageID.substring(
                posPageID.indexOf(STORE_ID_INDEX) + 9,
                posPageID.indexOf(TARGET_INDEX));
        }
    }
}