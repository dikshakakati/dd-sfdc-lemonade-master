/**
* @author Aethereus
* @date 02/06/2024
* @description JavaScript controller for issueWorkSteps lightning web component.
*/
import { LightningElement, api, wire, track } from 'lwc';
import getFields from "@salesforce/apex/DisplayBlockedWorkStepsController.getFields";
import getWorkStepCountFilteredByConditionGroupedByWorkOrderIds from "@salesforce/apex/DisplayBlockedWorkStepsController.getWorkStepCountFilteredByConditionGroupedByWorkOrderIds";
import NAME_FIELD from "@salesforce/schema/WorkOrder.Work_Order_Name__c";
import viewAllText from "@salesforce/label/c.View_All_Link_In_LWC";
import workPlanBlockers from "@salesforce/label/c.Work_Plan_Blockers";
import workPlanEscalated from "@salesforce/label/c.Work_Plan_Escalations";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import createLog from "@salesforce/apex/LogController.createLog";


const STATUS = "Status";
const STATUS_FIELD_API_NAME = "Status__c";
const PICKLIST_COLUMN = "picklistColumn";
const ID = "Id";
const LABEL = "Select Status";
const STORE_ID = "Store ID";
const STORE_MINT_PAGE = "storeMINTPage";
const URL_TYPE = "url";
const EXTERNAL_ID_C = "WorkOrder.Store_Id__c";
const FIX_IT_URL_NAME = "fixItUrl";
const FIX_IT_LABEL_NAME = "fixItName";
const LWC_NAME = "IssueWorkSteps";
const GET_FIELD_SET_FIELDS = "getFields";
const XREF_LABEL = "Xref";
const OPENING_BRACKET = "(";
const CLOSING_BRACKET = ")";



export default class IssueWorkSteps extends LightningElement {
  @track columns = [];
  @api recordId;
  workStepStatus;
  title;
  workOrderName;
  workOrderId = this.recordId;
  currentTab;
  blockedCount = 0;
  escalatedCount = 0;
  isComponentVisible = false;
  @track showComponent = false;
  labels = {
    viewAllText,
    workPlanBlockers,
    workPlanEscalated
  };
  helpText = {
    blocked: 'These work plans have been blocked by the Merchant Services Vendor Team and require <b> Account Owner </b> assistance to review & unblock the work steps - <b>it is the Account Owner’s responsibility to unblock these work steps.</b>',
    escalated: 'These work plans have been escalated due to a provisioning error. It is the <b>Merchant Services Vendor Teams’s</b> responsibility to unblock these work steps. Account Owners can see these escalations for visibility purposes only. '
  }

  /**
     * @description It is used to get Work Order record details.
     */
  @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD] })
  record;

  /**
    * @description It is used to get Work Order Name.
    */
  get name() {
    let workOrderName = getFieldValue(this.record.data, NAME_FIELD);
    return workOrderName !== undefined ? workOrderName : null;
  }

  /**
     * @description It also gets the columns for the datatable to be displayed.
  */
  @wire(getFields)
  setDatatableColumns({ error, data }) {
    if (data) {
      let allColumns = JSON.parse(data);
      allColumns.forEach((column) => {
        column.hideDefaultActions = false;
        column.sortable = true;
        column.editable = false;
        column.wrapText = true;
        if (column.label === XREF_LABEL) {
          column.cellAttributes = { class: { fieldName: 'hrefclass' } };
        }
      });
      this.columns = allColumns;
      //adding the custom picklist type column in the columns to be displayed in datatable
      const PICKLIST_COLUMN_DETAILS = {
        label: STATUS,
        fieldName: STATUS_FIELD_API_NAME,
        type: PICKLIST_COLUMN,
        wrapText: true,
        editable: false,
        typeAttributes: {
          value: { fieldName: STATUS_FIELD_API_NAME },
          label: LABEL,
          context: { fieldName: ID }
        }
      };
      this.columns.splice(3, 0, PICKLIST_COLUMN_DETAILS);

      //adding the Store ID column in the columns to be displayed
      const STORE_ID_COLUMN = {
        label: STORE_ID,
        fieldName: STORE_MINT_PAGE,
        type: URL_TYPE,
        wrapText: true,
        editable: false,
        typeAttributes: {
          label: { fieldName: EXTERNAL_ID_C }
        }
      };
      this.columns.splice(1, 0, STORE_ID_COLUMN);

      //add the fix it URL column in the columns to be displayed in datatable
      const FIX_IT_COLUMN = {
        label: '',
        fieldName: FIX_IT_URL_NAME,
        type: URL_TYPE,
        wrapText: true,
        editable: false,
        fixedWidth: 50,
        typeAttributes: {
          label: { fieldName: FIX_IT_LABEL_NAME }
        },
      };
      this.columns.push(FIX_IT_COLUMN);

      // placing the xref column right to the store id.
      const xrefIndex = this.columns.findIndex(item => item.label === XREF_LABEL);
      if (xrefIndex !== -1) {
        const removedXref = this.columns.splice(xrefIndex, 1)[0];
        this.columns.splice(2, 0, removedXref);
      }
      this.loadComplete = true;
    } else if (error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_FIELD_SET_FIELDS,
        message: JSON.stringify(result.error.body)
      });
    }
  }

  /**
     * @description It is used to count blocked and escalated work steps.
  */
  @wire(getWorkStepCountFilteredByConditionGroupedByWorkOrderIds, { recordId: "$recordId" })
  getWorkStepCount({ error, data }) {
    if (data) {
      let blockedMapKey = 'Blocked';
      let escalatedMapKey = 'Escalated';
      let statusToCountMap = new Map();
      for (let key in data) {
        statusToCountMap.set(key, data[key]);
      }
      if (statusToCountMap.has(blockedMapKey)) {
        this.blockedCount = statusToCountMap.get(blockedMapKey);
      }
      if (statusToCountMap.has(escalatedMapKey)) {
        this.escalatedCount = statusToCountMap.get(escalatedMapKey);
      }
      this.isComponentVisible = true;
    } else if (error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_FIELD_SET_FIELDS,
        message: JSON.stringify(result.error.body)
      });
    }
  }

  tabChangeHandler(event) {
    this.currentTab = event.target.title;
    this.showComponent = false;
  }

  get workPlanstatus() {
    return this.currentTab == 'Work Plan Blockers' ? 'Blocked' : 'Escalated';
  }

  get tableTitle() {
    return this.currentTab == 'Work Plan Blockers' ? this.labels.workPlanBlockers : this.labels.workPlanEscalated;
  }

  get showWorkPlanBlockers() {
    return this.currentTab === 'Work Plan Blockers' ? true : false;
  }

  get showWorkPlanEscalations() {
    return this.currentTab === 'Work Plan Escalations' ? true : false;
  }

  get blockedLabel() {
    return 'Work Plan Blockers ' + OPENING_BRACKET + this.blockedCount + CLOSING_BRACKET;
  }

  get escalatedLabel() {
    return 'Work Plan Escalations ' + OPENING_BRACKET + this.escalatedCount + CLOSING_BRACKET;
  }

  get isBlockedCountGreaterThanZero() {
    return this.blockedCount > 0 ? true : false;
  }

  get isEscalatedCountCountGreaterThanZero() {
    return this.escalatedCount > 0 ? true : false;
  }

}