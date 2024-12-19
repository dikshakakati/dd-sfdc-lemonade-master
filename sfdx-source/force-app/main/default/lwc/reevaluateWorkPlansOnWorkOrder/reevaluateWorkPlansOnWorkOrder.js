/**
 * @author Deloitte
 * @date 13/07/2022
 * @description JavaScript controller for ReevaluateWorkPlansOnWorkOrder lightning web component.
 */
import { LightningElement, api } from 'lwc';
import { reloadScreenAfterConfiguredDelay, setMessage, setMode, setVariant, showNotification } from 'c/utils';
import createLog from '@salesforce/apex/LogController.createLog';
import reevaluateWorkPlans from '@salesforce/apex/ReevaluateWorkPlansOnWorkOrderController.reevaluateWorkPlans';
import noWorkPlansToReevaluate from '@salesforce/label/c.No_Work_Plans_To_Reevaluate_Message';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastModeSticky from '@salesforce/label/c.Toast_Mode_Sticky';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';
import workPlansReevaluationInitialMessage from '@salesforce/label/c.Work_Plans_Reevaluation_Initial_Message';
import workPlansReevaluationMessage from '@salesforce/label/c.Work_Plans_Reevaluation_Message';

const DELAY = 5000;
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const LWC_NAME = 'ReevaluateWorkPlansOnWorkOrder';
const REEVALUATE_WORK_PLANS_METHOD_NAME = 'reevaluateWorkPlans';
const SESSION_STORAGE_KEY = 'WorkOrderId';

export default class ReevaluateWorkPlansOnWorkOrder extends LightningElement {
  @api recordId;
  sessionKey;
  toastMessage = toastMessage;
  toastVariantError = toastVariantError;

  /**
   * @description To perform logic after component is inserted into the DOM.
   */
  connectedCallback() {
    if (this.recordId) {
      this.sessionKey = SESSION_STORAGE_KEY + this.recordId;
      // Session Storage is used to prevent re-evaluation on multiple simultaneous clicks
      let data = sessionStorage.getItem(this.sessionKey);
      if (data === null || data !== this.recordId) {
        sessionStorage.setItem(this.sessionKey, this.recordId);
        this.triggerWorkPlansReevaluation();
      } else {
        setMessage(workPlansReevaluationInitialMessage);
        setMode(toastModeSticky);
        setVariant(toastVariantInfo);
        showNotification(this);
      }
    }
  }

  /**
   * @description This will log & show error on UI if any error occurs.
   * @JIRA# LEM-1956
   * @param error
   * @param stack
   */
  errorCallback(error, stack) {
    //show error message when an error occurs
    setMessage(toastMessage);
    setVariant(toastVariantError);
    showNotification(this);
    createLog({
      lwcName: LWC_NAME,
      methodName: ERROR_CALLBACK_METHOD_NAME,
      message: JSON.stringify(error).concat(JSON.stringify(stack))
    });
  }

  /**
  * @description To re-evaluate Work Plans criteria for parent and child Work Orders.
  * @JIRA# LEM-1956
  */
  triggerWorkPlansReevaluation() {
    setMessage(workPlansReevaluationInitialMessage);
    setMode(toastModeSticky);
    setVariant(toastVariantInfo);
    showNotification(this);
    reevaluateWorkPlans({
      parentWorkOrderId: this.recordId
    })
      .then(() => {
        setMessage(workPlansReevaluationMessage);
        setMode(toastModeSticky);
        setVariant(toastVariantInfo);
        showNotification(this);
        // Remove key from session storage to allow re-evaluation next time
        sessionStorage.removeItem(this.sessionKey);
        reloadScreenAfterConfiguredDelay(DELAY);
      })
      .catch((error) => {
        // Show toast message when no WorkPlans are available for re-evaluation
        if (error.body.message === noWorkPlansToReevaluate) {
          setMessage(noWorkPlansToReevaluate);
          setMode(toastModeSticky);
          setVariant(toastVariantInfo);
          showNotification(this);
        }
        createLog({
          lwcName: LWC_NAME,
          methodName: REEVALUATE_WORK_PLANS_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
        // Remove key from sessionStorage to allow re-evaluation next time
        sessionStorage.removeItem(this.sessionKey);
        reloadScreenAfterConfiguredDelay(DELAY);
      });
  }
}