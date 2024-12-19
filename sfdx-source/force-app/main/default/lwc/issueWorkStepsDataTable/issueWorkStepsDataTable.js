/**
* @author Aethereus
* @date 02/06/2024
* @description JavaScript controller for issueWorkStepsDataTable lightning web component.
*/
import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import NAME_FIELD from "@salesforce/schema/WorkOrder.Work_Order_Name__c";
import createLog from "@salesforce/apex/LogController.createLog";
import getFields from "@salesforce/apex/DisplayBlockedWorkStepsController.getFields";
import getWorkStepDetails from "@salesforce/apex/DisplayBlockedWorkStepsController.getWorkStepDetails";
import getResolutionMap from "@salesforce/apex/DisplayBlockedWorkStepsController.getResolutionMap";
import viewAllText from "@salesforce/label/c.View_All_Link_In_LWC";
import workPlanBlockers from "@salesforce/label/c.Work_Plan_Blockers";
import { registerRefreshHandler, unregisterRefreshHandler, RefreshEvent } from "lightning/refresh";
import {loadStyle} from 'lightning/platformResourceLoader'
import IssueWorkStepsCss from '@salesforce/resourceUrl/IssueWorkStepsCss'

import {
  subscribe,
  MessageContext,
  APPLICATION_SCOPE,
} from 'lightning/messageService';
import publishEvent from '@salesforce/messageChannel/Publish_Event__c';
const ASCENDING = "asc";
const CLOSING_BRACKET = ")";
const COMPONENTDEF = "c:issueWorkStepsDataTable";
const EXTERNAL_ID_C = "WorkOrder.Store_Id__c";
const FORWARD_SLASH = "/";
const GET_FIELD_SET_FIELDS = "getFields";
const GET_WORK_STEP_DETAILS = "getWorkStepDetails";
const GET_RESOLUTION_MAP = "getResolutionMap";
const HANDLE_LIST_VIEW_NAVIGATION = "handleListViewNavigation";
const HANDLE_RECORD_NAVIGATION = "handleRecordNavigation";
const HREF = 'href="';
const ID = "Id";
const ITEMS = " item(s)";
const ITEMS_COUNT = "(5+)";
const LABEL = "Select Status";
const LIST = "list";
//const LWC_NAME = "DisplayBlockedWorkSteps";
const LWC_NAME = "IssueWorkStepsDataTable";
const NAVIGATE_TO_PAGE = "navigateToPage";
const OBJECT_PAGE = "standard__objectPage";
const OPENING_BRACKET = "(";
const PICKLIST_COLUMN = "picklistColumn";
const RECORD_PAGE = "standard__recordPage";
const STATUS = "Status";
const STATUS_FIELD_API_NAME = "Status__c";
const STORE_ID = "Store ID";
const STORE_MINT_PAGE = "storeMINTPage";
const TARGET = '" target';
const URL_LINK = "/one/one.app#";
const URL_TYPE = "url";
const VIEW = "view";
const WEB_PAGE = "standard__webPage";
const WORKORDER = "WorkOrder";
const FIX_IT_URL_NAME = "fixItUrl";
const FIX_IT_LABEL_NAME = "fixItName";
const FIX_IT_TEXT = "Fix It";
const XREF_LABEL = "Xref";

//export default class DisplayBlockedWorkSteps extends NavigationMixin(
export default class IssueWorkStepsDataTable extends NavigationMixin(
  LightningElement
) {
  @api objectName = WORKORDER;
  @api viewAll;
  @api columns = [];
  @api workOrderId;
  @api workOrderName;
  @api workStepStatus;
  @api recordId;
  @track count = 0;
  @track recordsToBeDisplayed = [];
  @track refreshDatatable;
  @track statusOptions;
  @track showTable = false;
  @track truncatedRecords = [];
  refreshHandlerID;
  defaultSortDirection = ASCENDING;
  numberOfItems;
  labels = {
    viewAllText,
    workPlanBlockers
  };
  loadComplete = false;
  @api showComponent =false;
  sortedBy;
  sortDirection = ASCENDING;
  @api title = this.labels.workPlanBlockers;
 
  /**
   * @description It is used to get Work Steps records to be displayed.
   */
  @wire(getWorkStepDetails, { recordId: "$workOrderId", workStepStatus: "$workStepStatus" })
  setWorkStepRecords(result) {
    this.refreshDatatable = result;
    if (result.data) {
      if (result.data === null) {
        this.recordsToBeDisplayed = [];
        this.showComponent = true;       
      }
      this.retrieveResolutionMap(this.refreshDatatable);
      this.loadComplete = true; 
    } else if (result.error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_WORK_STEP_DETAILS,
        message: JSON.stringify(result.error.body)
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
          recordId: this.workOrderId,
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
   * @description To refresh the datatable records after Status is updated for a record.
   */
  handleRefresh() {
    refreshApex(this.refreshDatatable);
  }
 
  /**
   * @description To Navigate to the display view all records page.
   */
  navigateToPage() {
    try {
      let definition = {
        componentDef: COMPONENTDEF,
        attributes: {
          recordId: this.workOrderId,
          viewAll: true,
          workOrderId : this.workOrderId,
          workStepStatus : this.workStepStatus,
          columns : this.columns,
          title : this.title,
          showComponent : this.showComponent,
          workOrderName : this.workOrderName
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
   * @description It is used to sort table by selected column.
   * @param event
   */
  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.recordsToBeDisplayed];
    cloneData.sort(this.sortBy(sortedBy, sortDirection === ASCENDING ? 1 : -1));
    this.recordsToBeDisplayed = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }
 
  /**
   * @description It sorts data table columns.
   * @param field
   * @param reverse
   * @param primer
   * @returns
   */
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
 
  /**
   * @description it retrieves the resolution Map
   */
  retrieveResolutionMap(workStepData) {
    getResolutionMap()
      .then((result) => {
        let resolutionMap = new Map();
        for (let key in result) {
          resolutionMap.set(key, result[key]);
        }
        this.processWorkStepRecords(workStepData.data, resolutionMap);
      })
      .catch((error) => {
        console.error(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_RESOLUTION_MAP,
          message: JSON.stringify(error)
        });
      });
  }
 
  connectedCallback() {
    this.subscribeMessage();
    this.refreshHandlerID = registerRefreshHandler(
      this.template.host,
      this.refreshHandler.bind(this),
    );
    loadStyle(this, IssueWorkStepsCss).then(()=>{
    }).catch(error=>{ 
        console.error("Error in loading the CSS")
    })
  }
  disconnectedCallback() {
    unregisterRefreshHandler(this.refreshHandlerID);
  }
  refreshHandler() {
    return refreshApex(this.refreshDatatable)
      .then(() => {
        this.retrieveResolutionMap(this.refreshDatatable);
      });
  }
 
  processWorkStepRecords(workStepData, resolutionMap) {
    this.showTable = false;
    let retrievedRecords = workStepData.map((record) =>
 
      Object.assign(
        {
          "WorkOrder.Store_Id__c": record.WorkOrder.Store_Id__c
        },
        record
      )
    );
    retrievedRecords.forEach((retrievedRecord) => {
      const storeAccountId = retrievedRecord.WorkOrder.AccountId;
      if (storeAccountId) {
        retrievedRecord.storeAccountHyperlink = FORWARD_SLASH + storeAccountId;
        retrievedRecord.Store_Account__c = retrievedRecord.WorkOrder.Account.Name;
      }
      const workStepId = retrievedRecord.Id;
      if (workStepId) {
        retrievedRecord.workStepHyperLink = FORWARD_SLASH + workStepId;
      }
      const workPlanId = retrievedRecord.WorkPlanId;
      if (workPlanId) {
        retrievedRecord.workPlanHyperlink = FORWARD_SLASH + workPlanId;
        retrievedRecord.WorkPlanId = retrievedRecord.WorkPlan.Name;
      }
      const xrefId = retrievedRecord.WorkPlan.Xref__c;
      if (xrefId) {
        retrievedRecord.xrefHyperlink = FORWARD_SLASH + xrefId;
        retrievedRecord["hrefclass"] = '';
        retrievedRecord["WorkPlan.Xref__c"] = retrievedRecord.WorkPlan.Xref__r.Name;
      }
      else{
       retrievedRecord.xrefHyperlink = '#' ;
        retrievedRecord["WorkPlan.Xref__c"] = 'N/A';
        retrievedRecord["hrefclass"] = 'disable-url-click';
      }
 
      const mintStoreID = retrievedRecord.WorkOrder.MINT_Store_Page__c;
      if (mintStoreID) {
        retrievedRecord.storeMINTPage = mintStoreID.substring(
          mintStoreID.indexOf(HREF) + 6,
          mintStoreID.indexOf(TARGET)
        );
      }
 
      //hardcode URL for now
      let quickActionName = this.getQuickAction(retrievedRecord, resolutionMap);
      if (quickActionName) {
        retrievedRecord[FIX_IT_LABEL_NAME] = FIX_IT_TEXT;
        retrievedRecord[FIX_IT_URL_NAME] = '/lightning/action/quick/WorkStep.' + quickActionName + '?recordId=' + retrievedRecord.Id;
      }
    });
 
    this.recordsToBeDisplayed = [...retrievedRecords];
    this.showComponent = true;
 
    //To show the number of items and to display only 5 records in table view.
    this.count = this.recordsToBeDisplayed.length;
    if (this.count > 0) {
      this.showTable = true;
    }
    if (this.viewAll) {
      this.numberOfItems = this.count + ITEMS;
    } else {
      if (this.count > 5) {
        this.numberOfItems = ITEMS_COUNT;
        this.truncatedRecords = this.recordsToBeDisplayed.slice(0, 5);
      } else {
        this.numberOfItems = OPENING_BRACKET + this.count + CLOSING_BRACKET;
        this.truncatedRecords = this.recordsToBeDisplayed.slice();
      }
    }
    this.showComponent = true;
  }
 
  getQuickAction(retrievedRecord, resolutionMap) {
    let priorityMapKey = retrievedRecord.Name + '-' + retrievedRecord.Status_Reason__c + '-' + retrievedRecord.Status_Reason_Details__c;
    let secondaryMapKey = retrievedRecord.Name + '-' + retrievedRecord.Status_Reason__c;
    let quickActionName;
    if (resolutionMap.has(priorityMapKey)) {
      quickActionName = resolutionMap.get(priorityMapKey);
    } else if (resolutionMap.has(secondaryMapKey)) {
      quickActionName = resolutionMap.get(secondaryMapKey);
    }
    return quickActionName;
  }
  //LMS Call
  @wire(MessageContext)
  messageContext;
  subscribeMessage() {
    subscribe(this.messageContext, publishEvent, (message) => { this.handleMessage(message) }, { scope: APPLICATION_SCOPE });
  }
  handleMessage(message) {
    if (message.refreshPage) {
      this.dispatchEvent(new RefreshEvent());
    }
  }
}