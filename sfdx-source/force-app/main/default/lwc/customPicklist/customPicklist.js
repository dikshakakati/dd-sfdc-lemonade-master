/**
 * @author Deloitte
 * @date 10/15/2023
 * @description JavaScript controller for customPicklist lightning web component.
 */
import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { setMessage, setVariant, showNotification } from "c/utils";
import ID_FIELD from "@salesforce/schema/WorkStep.Id";
import STATUS_FIELD from "@salesforce/schema/WorkStep.Status__c";
import TYPE_FIELD from "@salesforce/schema/WorkStep.Type__c";
import WORK_STEP_OBJECT from "@salesforce/schema/WorkStep";
import cancelAction from "@salesforce/label/c.Cancel_Action";
import toastVariantSuccess from "@salesforce/label/c.Toast_Variant_Success";
import toastSuccessMessage from "@salesforce/label/c.Toast_Success_Message";
import toastVariantError from "@salesforce/label/c.Toast_Variant_Error";

const buttonVariant = "brand";
const buttonVariantNeutral = "neutral";
const confirmAction = "Save";

export default class CustomPicklist extends LightningElement {
  @api context;
  @api fieldName;
  @api label;
  @api value;
  @track statusOptions;
  @track workStepId;
  buttonVariant = buttonVariant;
  buttonVariantNeutral = buttonVariantNeutral;
  cancelAction = cancelAction;
  confirmAction = confirmAction;
  currentWorkStepRecord;
  selectedValue = "";
  showModal = false;
  showWaiting = false;
  picklistValues;

  /**
   * @description It is used to get Work Step object details.
   * @JIRA# LEM-9934
   */
  @wire(getObjectInfo, { objectApiName: WORK_STEP_OBJECT })
  objectInfo;

  /**
   * @description It is used to get the picklist values for Status field on Work Step object.
   * @JIRA# LEM-9934
   */
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: STATUS_FIELD
  })
  retrievePicklistValues({ data }) {
    if (data) {
      this.picklistValues = data;
      this.workStepId = this.context;
    }
  }

  /**
   * @description It is used to get the current Work Step record.
   * @JIRA# LEM-9934
   */
  @wire(getRecord, { recordId: "$workStepId", fields: [TYPE_FIELD] })
  currentWorkStepRecord;

  /**
   * @description To close the quick action panel.
   * @JIRA# LEM-9934
   */
  closeModal() {
    this.showModal = false;
  }

  /**
   * @description To edit picklist values and pass Status options values based to Type of Work Step
   * @JIRA# LEM-9934
   */
  editPicklist() {
    this.showModal = true;
    this.statusOptions = this.picklistValues.values.filter((options) =>
      options.validFor.includes(
        this.picklistValues.controllerValues[
        getFieldValue(this.currentWorkStepRecord.data, TYPE_FIELD)
        ]
      )
    );
  }

  /**
   * @description It handles picklist value change.
   * @JIRA# LEM-9934
   */
  handleChange(event) {
    this.selectedValue = event.detail.value;
  }

  /**
   * @description To confirm picklist values on click of Confirm button.
   * @JIRA# LEM-9934
   */
  handleConfirm() {
    if (this.selectedValue !== "" && this.selectedValue !== this.value) {
      let fields = {};
      fields[ID_FIELD.fieldApiName] = this.context;
      fields[STATUS_FIELD.fieldApiName] = this.selectedValue;
      let recordInput = { fields };
      this.showWaiting = true;
      updateRecord(recordInput)
        .then(() => {
          this.value = this.selectedValue;
          setMessage(toastSuccessMessage);
          setVariant(toastVariantSuccess);
        })
        .catch((error) => {
          setMessage(error.body.message);
          setVariant(toastVariantError);
        })
        .finally(() => {
          this.closeModal();
          this.showWaiting = false;
          showNotification(this);
          this.dispatchEvent(
            new CustomEvent("refreshdatatable", {
              composed: true,
              bubbles: true,
              cancelable: true
            })
          );
        });
    }
  }
}