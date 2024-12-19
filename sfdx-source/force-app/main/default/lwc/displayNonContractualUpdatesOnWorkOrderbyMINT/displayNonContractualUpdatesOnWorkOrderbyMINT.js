import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import createLog from "@salesforce/apex/LogController.createLog";
import NAME_FIELD from "@salesforce/schema/WorkOrder.Work_Order_Name__c";
import NUMBER_FIELD from "@salesforce/schema/WorkOrder.WorkOrderNumber";
import CRMA_DASHBOARD_URL from '@salesforce/label/c.CRMA_Dashboard_URL';

import { exportCSVFile } from 'c/downloadCSVUtils';
import getData from '@salesforce/apex/NonContractualUpdatesWorkOrderMINTCtrl.getNonContractualDataByMINT';
const URL_TYPE = "url";
const STORE_ID = "Store ID";
const STORE_MINT_PAGE = "storeMINTPage";
const EXTERNAL_ID_C = "External_ID__c";
const HREF = 'href="';
const TARGET = '" target';
const FORWARD_SLASH = "/";

const COMPONENTDEF = "c:displayNonContractualUpdatesOnWorkOrderbyMINT";
const WEB_PAGE = "standard__webPage";
const URL_LINK = "/one/one.app#";
const LWC_NAME = "DisplayNonContractualUpdatesOnWorkOrderbyMINT";
const NAVIGATE_TO_PAGE = "navigateToPage";
const WORKORDER = "WorkOrder";
const OBJECT_PAGE = "standard__objectPage";
const LIST = "list";
const HANDLE_LIST_VIEW_NAVIGATION = "handleListViewNavigation";
const HANDLE_RECORD_NAVIGATION = "handleRecordNavigation";
const RECORD_PAGE = "standard__recordPage";
const VIEW = "view";
export default class DisplayNonContractualUpdatesOnWorkOrderbyMINT extends NavigationMixin(
    LightningElement
) {

    @api objectName = WORKORDER;
    @api recordId;
    @api viewAll;

    @track showComponent = false;
    @track noAccess = false;

    @track workOrderHistoriesToShow = [];
    @track xrefHistoriesToShow = [];
    @track recordsToBeDisplayed = [];
    @track workOrderHistories = [];
    @track refreshDatatable;
    @track fieldSetData = [];

    accountIdToNameMap = new Map();
    accountIdToExternalIdMap = new Map();
    accountIdToMINTLink = new Map();
    xrefIdToAccountIdMap = new Map();
    fieldApiNameToFieldLableMap = new Map();

    accIdSet = new Set();

    columnsToBeDisplayed = [
        {
            label: STORE_ID,
            fieldName: STORE_MINT_PAGE,
            type: URL_TYPE,
            wrapText: true,
            editable: false,
            hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: EXTERNAL_ID_C }
            }
            //storeMINTPage this should contain hyperLinkValue
            //External_ID__c should contain the store number to show on ui
        },
        {
            wrapText: true,
            value: null,
            typeAttributes: { label: { fieldName: "storeAccountName" } },
            type: URL_TYPE,
            sortable: null,
            label: 'Account',
            hideDefaultActions: true,
            fieldName: 'storeAccountHyperlink',
            apiName: null
        },
        {
            wrapText: true,
            value: null,
            typeAttributes: null,
            type: 'string',
            sortable: null,
            label: 'Field Name',
            hideDefaultActions: true,
            fieldName: 'FieldLable',
            apiName: null
        },
        {
            wrapText: true,
            value: null,
            typeAttributes: null,
            type: 'string',
            sortable: null,
            label: 'Old Value',
            hideDefaultActions: true,
            fieldName: 'OldValue',
            apiName: null
        },
        {
            wrapText: true,
            value: null,
            typeAttributes: null,
            type: 'string',
            sortable: null,
            label: 'New Value',
            hideDefaultActions: true,
            fieldName: 'NewValue',
            apiName: null
        },
        {
            wrapText: true,
            value: null,
            typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true },
            type: 'date',
            sortable: null,
            label: 'Date/time of change',
            hideDefaultActions: true,
            fieldName: 'CreatedDate',
            apiName: null
        },

    ];

    /**
    * @description It is used to get Work Order Name.
    */
    get numberOfItems() {
        return this.recordsToBeDisplayed.length;
    }

    /**
    * @description It is used to get Work Order record details.
    */
    @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD, NUMBER_FIELD] })
    record;

    /**
    * @description It is used to get Work Order Number.
    */
    get woNumber() {
        return getFieldValue(this.record.data, NUMBER_FIELD);
    }

    /**
    * @description It is used to display title.
    */
    get woLabel() {
        return 'WO ' + this.woNumber + ' MINT Update ' + '(' + this.numberOfItems + ')';
    }


    @wire(getData, { workOrderId: '$recordId' })
    setTheDataWrapper(result) {
        if (result.data) {
            if (result.data === null) {
            }
            this.processXrefs(result.data.xRefs);
            this.processRecordsToDisplay(result.data.accountHistories, result.data.accountFieldSetMap, result.data.xRefFieldSetMap);
            this.processEntityId(this.recordsToBeDisplayed, result.data.entityIdWithValues, result.data.replaceEntityLabel);
            this.showComponent = true;
        } else if (result.error) {
            this.noAccess = true;
            createLog({
                lwcName: LWC_NAME,
                methodName: 'setTheDataWrapper',
                message: JSON.stringify(result.error.body)
            });
        }
    }



    processEntityId(historyList, entityIdWithValues, replaceEntityLabel) {
        historyList.forEach((item, index) => {
            ['OldValue', 'NewValue', 'Field'].forEach(key => {
                if (item[key] in entityIdWithValues) {
                    item[key] = entityIdWithValues[item[key]];
                }
                if (item[key] in replaceEntityLabel) {
                    item['FieldLable'] = 'Business Id';
                }
            });
        });
    }

    processRecordsToDisplay(accountHistories, accountFieldSet, xRefFieldSet) {
        this.recordsToBeDisplayed.push(...accountHistories);

        let assignFinal = this.recordsToBeDisplayed.map(rec => {
            let accId;
            let fieldReplacement = rec.Field;
            if (rec.hasOwnProperty('ParentId')) {
                accId = rec.Parent.Salesforce_Account_Name__c;
                if (rec.Field in xRefFieldSet) {
                    fieldReplacement = xRefFieldSet[fieldReplacement]
                }
            }
            else {
                accId = rec.AccountId;
                if (!this.accountIdToNameMap.has(accId)) {
                    this.accountIdToNameMap.set(accId, rec.Account.Name);
                }
                if (rec.Field in accountFieldSet) {
                    fieldReplacement = accountFieldSet[fieldReplacement]
                }
            }
            return Object.assign(
                {
                    "FieldLable": fieldReplacement,
                    "storeMINTPage": this.accountIdToMINTLink.get(accId),
                    "External_ID__c": this.accountIdToExternalIdMap.get(accId),
                    "storeAccountHyperlink": FORWARD_SLASH + accId,
                    "storeAccountName": this.accountIdToNameMap.get(accId)
                },
                rec
            );

        });

        this.recordsToBeDisplayed = assignFinal;
        assignFinal.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));

    }

    processXrefs(xrefRecords) {
        this.xrefHistoriesToShow = [];
        xrefRecords.forEach(xrefRecord => {
            let mintStoreID = xrefRecord.MINT_Store_Page__c;
            if (mintStoreID) {
                let mintPageLink = mintStoreID.substring(
                    mintStoreID.indexOf(HREF) + 6,
                    mintStoreID.indexOf(TARGET));
                this.accountIdToMINTLink.set(xrefRecord.Salesforce_Account_Name__c, mintPageLink);
            }
            this.xrefIdToAccountIdMap.set(xrefRecord.Id, xrefRecord.Salesforce_Account_Name__c);
            this.accountIdToNameMap.set(xrefRecord.Salesforce_Account_Name__c, xrefRecord.Salesforce_Account_Name__r.Name);
            this.accountIdToExternalIdMap.set(xrefRecord.Salesforce_Account_Name__c, xrefRecord.External_ID__c);
            if (xrefRecord.Histories != undefined)
                this.recordsToBeDisplayed.push(...xrefRecord.Histories);

        });
    }


    /**
    * @description It is used to get Work Order Name.
    */
    get name() {
        let workOrderName = getFieldValue(this.record.data, NAME_FIELD);
        return workOrderName !== undefined ? workOrderName : null;
    }

    navigateToPage() {
        try {
            let definition = {
                componentDef: COMPONENTDEF,
                attributes: {
                    recordId: this.recordId,
                    viewAll: true
                }
            };
            this[NavigationMixin.Navigate]({
                type: WEB_PAGE,
                attributes: {
                    url: URL_LINK + btoa(JSON.stringify(definition))
                }
            });
        } catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: NAVIGATE_TO_PAGE,
                message: JSON.stringify(error)
            });
        }
    }

    /**
    * @description It is used to navigate to Work Order's pinned list view.
    */
    handleListViewNavigation() {
        try {
            this[NavigationMixin.Navigate]({
                type: OBJECT_PAGE,
                attributes: {
                    objectApiName: WORKORDER,
                    actionName: LIST
                }
            });
        } catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: HANDLE_LIST_VIEW_NAVIGATION,
                message: JSON.stringify(error)
            });
        }
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

    /**
    * @description It is used to call the utility class which if for the download of CSV File by passing data, columns(labe,fieldApi name)
    */
    handleDownloadClick() {
        const updatedColumns = this.columnsToBeDisplayed.map(item => {
            if (item.type === URL_TYPE) {
                item.fieldName = item.typeAttributes.label.fieldName;
            }
            return item;
        });
        exportCSVFile(this.recordsToBeDisplayed, updatedColumns, getFieldValue(this.record.data, NAME_FIELD));
    }

    /**
    * @description It is used to view all the MINT Updates by redirecting to CRMA Dashboard.
    */
    handleViewAllClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: CRMA_DASHBOARD_URL
            }
        });
    }
}