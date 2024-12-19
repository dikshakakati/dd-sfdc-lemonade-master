/**
 * @author Deloitte
 * @date 26/07/2022
 * @description JavaScript controller for viewEncryptedData lightning web component.
 */
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { setMessage, setMode, setVariant, showNotification } from 'c/utils';
import hasEncryptedInformationAccess from '@salesforce/customPermission/View_Encrypted_Banking_Information';
import createLog from '@salesforce/apex/LogController.createLog';
import getEncryptedData from '@salesforce/apex/ViewEncryptedDataController.getEncryptedData';
import updateEncryptedData from '@salesforce/apex/ViewEncryptedDataController.updateEncryptedData';
import cancelAction from '@salesforce/label/c.Cancel_Action';
import encryptedDataUpdateSuccessMessage from '@salesforce/label/c.Encrypted_Data_Update_Success_Message';
import noEncryptedDataPermissionMessage from '@salesforce/label/c.No_Encrypted_Data_Permission_Message';
import noUpdateInEncryptedDataMessage from '@salesforce/label/c.No_EncryptedDataUpdate_Before_Saving_Data';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import separator from '@salesforce/label/c.Separator';
import toastModeSticky from '@salesforce/label/c.Toast_Mode_Sticky';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';
import toastVariantSuccess from '@salesforce/label/c.Toast_Variant_Success';
import workPlanObjectName from '@salesforce/schema/WorkPlan';

const BOOLEAN_TYPE = 'Boolean';
const BUTTON_VARIANT_BRAND = 'brand';
const BUTTON_VARIANT_NEUTRAL = 'Neutral';
const CHECKBOX_TYPE = 'checkbox';
const DATE_STYLE = 'short';
const DATE_TYPE = 'DATE';
const DOUBLE_TYPE = 'DOUBLE';
const EDIT_ICON = 'utility:edit';
const ENCRYPTEDSTRING_TYPE = 'ENCRYPTEDSTRING';
const ENCRYPTED_DATA_METHOD_NAME = 'getEncryptedData';
const ENCRYPTED_DATA_UPDATE_METHOD_NAME = 'updateEncryptedData';
const ERROR_LOCATION_TOP_OF_PAGE = 'Top of Page';
const GET_RECORD_METHOD_NAME = 'getRecord';
const HIDE_ENCRYPTED_FIELDS = 'Hide Encrypted Fields';
const LAYOUT_TYPE_FULL = 'Full';
const LWC_NAME = 'ViewEncryptedData';
const NUMBER_TYPE = 'number';
const PARENT_DIV_STYLING_ON_WORKPLAN = 'slds-p-top_x-small slds-p-bottom_x-small slds-p-right_x-small';
const PARENT_DIV_STYLING_ON_SOBJECT = 'slds-p-around_small';
const STRING_TYPE = 'String';
const TEXT_TYPE = 'text';
const TOGGLE_ENCRYPTED_FIELDS_EVENT_NAME = "toggleencrypteddata";
const VIEW_ENCRYPTED_FIELDS = 'View Encrypted Fields';
const WORK_PLAN = 'WorkPlan';

export default class ViewEncryptedData extends LightningElement {
  @api businessAccountId;
  @api componentLocation;
  @api objectApiName;
  @api paymentAccountIds;
  @api recordId;
  @api workOrderId;
  @track buttonLabel = VIEW_ENCRYPTED_FIELDS;
  @track encryptedDetails = [];
  buttonClicked;
  buttonVariantBrand = BUTTON_VARIANT_BRAND;
  buttonVariantNeutral = BUTTON_VARIANT_NEUTRAL;
  cancelAction = cancelAction;
  dateStyle = DATE_STYLE;
  editIcon = EDIT_ICON;
  encryptedDetailsError;
  hasEncryptedInformationAccess = hasEncryptedInformationAccess;
  inputs;
  loaded = false;
  loadingAlternativeText = loading;
  noEncryptedDataPermissionMessage = noEncryptedDataPermissionMessage;
  showButtons = false;
  showEncryptedFields = false;
  viewEncryptedDataWrapper;

  /**
   * @description It fires when the component is inserted into the DOM.
   * @JIRA# LEM-3184
   */
  connectedCallback() {
    /* eslint-disable @lwc/lwc/no-api-reassignments */
    if (this.template.isConnected) {
      /** It prevents from sending null or undefined businessAccountId when the component is rendered
       * on sObjects other than WorkPlan.
       */
      if (!this.businessAccountId) {
        this.businessAccountId = this.recordId;
      }
      /** It prevents from sending null or undefined componentLocation when the component is rendered
       * on sObjects other than WorkPlan.
       */
      if (!this.componentLocation) {
        this.componentLocation = this.objectApiName;
      }
    }
  }

  /**
   * @description It fires when the component has finished the rendering phase.
   * @JIRA# LEM-2255
   */
  renderedCallback() {
    this.viewEncryptedDataWrapper = {
      businessAccountId: this.businessAccountId,
      componentLocation: this.componentLocation,
      paymentRecordIds: this.paymentAccountIds,
      recordId: this.recordId,
      workOrderId: this.workOrderId
    };
    //It stores text input instance
    if (this.template.querySelectorAll('[data-identifier="encryptedDataInput"]')) {
      this.inputs = this.template.querySelectorAll('[data-identifier="encryptedDataInput"]');
    }
  }

  /**
   * @description It fetches record details using "Full" layout type
   * to keep the fetching logic generic.
   * @JIRA# LEM-3342
   */
  @wire(getRecord,
    {
      recordId: '$recordId',
      layoutTypes: LAYOUT_TYPE_FULL
    })
  getRecordOutput({ data, error }) {
    if (data) {
      this.loaded = true;
      this.fetchEncryptedData();
    } else if (error) {
      this.loaded = true;
      createLog(
        {
          lwcName: LWC_NAME,
          methodName: GET_RECORD_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
    }
  }

  /**
   * @description It fetches encrypted banking details using passed componentLocation,
   * recordId and businessAccountId.
   * @JIRA# LEM-3342
   */
  fetchEncryptedData() {
    getEncryptedData({
      viewEncryptedDataWrapper: this.viewEncryptedDataWrapper
    })
      .then((result) => {
        this.encryptedDetailsError = undefined;
        if (result.length === 0) {
          this.hasEncryptedInformationAccess = false;
        }
        this.encryptedDetails = result.map((eachRecord) => {
          return {
            'encryptedData': eachRecord,
            'isReadOnly': true,
            'showEditIcon': eachRecord.isEditable,
            'inputType': this.getFieldType(eachRecord.fieldType)
          };
        });
      })
      .catch((error) => {
        this.encryptedDetailsError = error;
        this.encryptedDetails = undefined;
        createLog({
          lwcName: LWC_NAME,
          methodName: ENCRYPTED_DATA_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description It returns the SLDS class name(s) based on the component location.
   * @JIRA# LEM-3004 & LEM-3108
   */
  get parentDivStyling() {
    if (this.componentLocation === workPlanObjectName.objectApiName) {
      return PARENT_DIV_STYLING_ON_WORKPLAN;
    }
    return PARENT_DIV_STYLING_ON_SOBJECT;
  }

  /**
   * @description It returns input type on basis of the field type.
   * @JIRA# LEM-2255
   */
  getFieldType(fieldType) {
    let inputType = TEXT_TYPE;
    switch (fieldType) {
      case BOOLEAN_TYPE:
        inputType = CHECKBOX_TYPE;
        break;
      case DOUBLE_TYPE:
        inputType = NUMBER_TYPE;
        break;
      case DATE_TYPE:
        inputType = DATE_TYPE.toLocaleLowerCase();
        break;
      case ENCRYPTEDSTRING_TYPE:
        inputType = TEXT_TYPE;
        break;
      case STRING_TYPE:
        inputType = TEXT_TYPE;
        break;
      default: inputType = TEXT_TYPE;
    }
    return inputType;
  }

  /**
   * @description It resets data on click of the cancel button.
   * @JIRA# LEM-2255
   */
  handleCancel() {
    this.showButtons = false;
    this.encryptedDetails = this.encryptedDetails.map((eachRecord) => {
      return {
        'encryptedData': eachRecord.encryptedData,
        'isReadOnly': true,
        'showEditIcon': this.componentLocation === WORK_PLAN ? false : true,
        'inputType': eachRecord.inputType
      }
    });
    // Removing custom exception from input element
    this.inputs.forEach(function (eachElement) {
      eachElement.setCustomValidity('');
      eachElement.reportValidity();
    });
  }

  /**
   * @description It handles click on edit button to allow editing on the encrypted data.
   * @JIRA# LEM-2255
   */
  handleEdit() {
    this.showButtons = true;
    this.encryptedDetails = this.encryptedDetails.map((eachRecord) => {
      return {
        'encryptedData': eachRecord.encryptedData,
        'isReadOnly': !eachRecord.encryptedData.isEditable,
        'showEditIcon': false,
        'inputType': eachRecord.inputType
      }
    });
  }

  /**
   * @description It handles click on the save button to trigger the update on encrypted data.
   * @JIRA# LEM-2255
   */
  handleSave() {
    let isValueUpdated = false;
    let updatedEncryptedData = [];
    this.inputs.forEach(function (eachElement) {
      // Removing custom exception from input element
      eachElement.setCustomValidity('');
      eachElement.reportValidity();
      this.encryptedDetails.forEach(function (eachEncryptedData) {
        if (
          eachEncryptedData.encryptedData.fieldApiName === eachElement.dataset.apiName
          && eachEncryptedData.encryptedData.fieldValue !== eachElement.value) {
          isValueUpdated = true;
          updatedEncryptedData.push(
            {
              fieldApiName: eachElement.dataset.apiName,
              fieldLabel: eachElement.label,
              fieldType: eachElement.dataset.inputType,
              fieldValue: eachElement.value,
            });
        }
      });
    }, this);
    if (isValueUpdated) {
      this.triggerEncryptedDataUpdate(updatedEncryptedData);
    } else {
      this.handleCancel();
      setMessage(noUpdateInEncryptedDataMessage);
      setVariant(toastVariantInfo);
      showNotification(this);
    }
  }

  /**
   * @description It handles toggle to show/hide the encrypted data.
   * @JIRA# LEM-2255
   */
  handleToggle() {
    this.buttonClicked = !this.buttonClicked;
    this.buttonLabel = this.buttonClicked ? HIDE_ENCRYPTED_FIELDS : VIEW_ENCRYPTED_FIELDS;
    this.showEncryptedFields = this.buttonClicked;
    if (this.buttonClicked && this.paymentAccountIds) {
      this.fetchEncryptedData();
    }
    if (!this.showEncryptedFields) {
      this.showButtons = false;
      this.encryptedDetails = this.encryptedDetails.map((eachRecord) => {
        return {
          'encryptedData': eachRecord.encryptedData,
          'isReadOnly': true,
          'showEditIcon': this.componentLocation === WORK_PLAN ? false : eachRecord.encryptedData.isEditable,
          'inputType': eachRecord.inputType
        }
      });
    }
    this.dispatchEvent(
      new CustomEvent(TOGGLE_ENCRYPTED_FIELDS_EVENT_NAME, {
        detail: this.buttonClicked
      })
    );
  }

  /**
   * @description To trigger update on the encrypted data.
   * @JIRA# LEM-2255
   */
  triggerEncryptedDataUpdate(updatedEncryptedData) {
    updateEncryptedData({
      recordId: this.recordId,
      updatedEncryptedData: JSON.stringify(updatedEncryptedData)
    })
      .then(() => {
        setMessage(encryptedDataUpdateSuccessMessage);
        setVariant(toastVariantSuccess);
        showNotification(this);
        this.handleCancel();
      })
      .catch((error) => {
        let exceptionDetails = error.body.message.split(separator);
        if (exceptionDetails[0] === ERROR_LOCATION_TOP_OF_PAGE) {
          setMessage(exceptionDetails[1]);
          setMode(toastModeSticky);
          setVariant(toastVariantError);
          showNotification(this);
        } else {
          this.inputs.forEach(function (eachElement) {
            if (eachElement.dataset.apiName === exceptionDetails[0]) {
              eachElement.setCustomValidity(exceptionDetails[1]);
              eachElement.reportValidity();
            }
          });
        }
        createLog({
          lwcName: LWC_NAME,
          methodName: ENCRYPTED_DATA_UPDATE_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
  }
}