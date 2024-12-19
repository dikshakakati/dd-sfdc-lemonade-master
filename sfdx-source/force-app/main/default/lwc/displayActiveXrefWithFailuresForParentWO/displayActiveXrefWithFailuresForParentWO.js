import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/WorkOrder.Work_Order_Name__c";
import getFields from "@salesforce/apex/DisplayActiveXrefsParentWOController.getFields";
import getXrefDetails from "@salesforce/apex/DisplayActiveXrefsParentWOController.getXrefDetails";
import integrationFailures from "@salesforce/label/c.Integration_Status_On_Failure";
import provisioningFailures from "@salesforce/label/c.Provisioning_Failures";
import createLog from "@salesforce/apex/LogController.createLog";

const LWC_NAME = "displayActiveXrefWithFailuresForParentWO";
const GET_FIELD_SET_FIELDS = "Parent_WorkOrder_Xref_Related_List";
const GET_XREF_DETAILS = "getXrefDetails";
const UTILITY_TYPE = "utility:";
const TOAST_VARIANT = "error";
const SHOW_TOAST_MESSAGE_COMPONENT = "c-show-toast-message";

export default class DisplayActiveXrefWithFailuresForParentWO extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api viewAll;
  @track relatedData = [];
  @track columns = [];
  @track viewAllColumns = [];
  showComponent = false;
  labels = {
    integrationFailures,
    provisioningFailures
  };

  @api objectApiName;
  /**
   * @description This method is used to get object record details.
   */

  @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD] })
  record;

  /**
   * @description This method is used to get workOrder details.
   */
  get name() {
    let woName = getFieldValue(this.record.data, NAME_FIELD);
    return woName !== undefined ? woName : null;
  }

  /**
   * @description This method is used to render view all records page
   */
  get viewAllRecords() {
    return this.viewAll !== undefined ? this.viewAll : false;
  }

  /**
   * @description This method is used to get columns to display
   */
  @wire(getFields)
  setFields({ error, data }) {
    if (data) {
      let allColumns = JSON.parse(data);
      allColumns.forEach((obj) => {
        obj.hideDefaultActions = false;
        obj.sortable = true;
      });
      this.viewAllColumns = [...allColumns];
      this.columns = [...allColumns].splice(0, 7);
    } else if (error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_FIELD_SET_FIELDS,
        message: JSON.stringify(error.body)
      });
      this.showToastMessage(
        TOAST_VARIANT,
        error.body.message,
        UTILITY_TYPE + TOAST_VARIANT
      );
    }
  }

  /**
   * @description This method is used to get unique xrefs records to display
   */
  @wire(getXrefDetails, { recordId: "$recordId" })
  setXrefRecords({ error, data }) {
    if (data) {
      if (data === null) {
        this.relatedData = [];
        this.showComponent = true;
      }
      let failureData = [];
      let allData = data.map((xref) => ({
        ...xref
      }));
      allData.forEach((obj) => {
        const salesforceAccountId = obj.Salesforce_Account_Name__c;
        if (typeof salesforceAccountId !== "undefined") {
          obj.accountNameHyperLink = "/" + salesforceAccountId;
          obj.Salesforce_Account_Name__c = obj.Salesforce_Account_Name__r.Name;
        }
        const xrefId = obj.Id;
        if (typeof xrefId !== "undefined") {
          obj.xrefHyperLink = "/" + xrefId;
          obj.Id = obj.Name;
        }
        const businessReferenceId = obj.Business_Reference__c;
        if (typeof businessReferenceId !== "undefined") {
          obj.businessReferenceHyperlink = "/" + businessReferenceId;
          obj.Business_Reference__c = obj.Business_Reference__r.Name;
        }
      });

      allData.forEach((obj) => {
        if (
          this.labels.integrationFailures.includes(obj.Integration_Status__c)
        ) {
          failureData.push(obj);
        }
      });
      this.relatedData = [...failureData];
      this.showComponent = true;
    } else if (error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_XREF_DETAILS,
        message: JSON.stringify(error.body)
      });
      this.showToastMessage(
        TOAST_VARIANT,
        error.body.message,
        UTILITY_TYPE + TOAST_VARIANT
      );
    }
  }

  /**
   * @description This method is used to display toast message
   * @param titleVal
   * @param messageVal
   * @param variantVal
   * @param messageDataVal
   * @param modeVal
   */
  showToastMessage(taskVariant, messageVal, utilityType) {
    this.template
      .querySelector(SHOW_TOAST_MESSAGE_COMPONENT)
      .showToast(taskVariant, messageVal, utilityType, 10000);
  }
}
