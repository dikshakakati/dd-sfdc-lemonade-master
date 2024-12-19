/**
 * @author Deloitte
 * @date 15/07/2022
 * @description JavaScript controller for readinessCheckOnStores lightning web component.
 */
import { LightningElement, api } from 'lwc';
import { reloadScreenAfterConfiguredDelay, setMessage, setMode, setVariant, showNotification } from 'c/utils';
import createLog from '@salesforce/apex/LogController.createLog';
import validateStoresReadiness from '@salesforce/apex/StoreReadinessCheckController.validateStoresReadiness';
import storeReadinessValidationMessage from '@salesforce/label/c.Store_Readiness_Validation_Message';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';
import toastModeSticky from '@salesforce/label/c.Toast_Mode_Sticky';

const DELAY_IN_FIVE_SECONDS = 5000;
const DELAY_IN_TEN_SECONDS = 10000;
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const LWC_NAME = 'readinessCheckOnStores';
const VALIDATE_STORE_READINESS_METHOD_NAME = 'validateStoresReadiness';

export default class ReadinessCheckOnStores extends LightningElement {
  @api recordId;
  delay = DELAY_IN_FIVE_SECONDS;
  toastMessage = toastMessage;
  toastVariantError = toastVariantError;

  /**
   * @description To perform logic after component is inserted into the DOM.
   */
  connectedCallback() {
    if (this.recordId) {
      this.runReadinessCheckValidations();
    }
  }

  /**
   * @description This will log & show error on UI if any error occurs.
   * @JIRA# LEM-1684
   * @param error
   * @param stack
   */
  errorCallback(error, stack) {
    //show error message when an error occurs
    setMessage(toastMessage);
    setMode(toastModeSticky);
    setVariant(toastVariantError);
    showNotification(this);
    createLog({
      lwcName: LWC_NAME,
      methodName: ERROR_CALLBACK_METHOD_NAME,
      message: JSON.stringify(error).concat(JSON.stringify(stack))
    });
  }

  /**
   * @description To re-run store readiness check on child WorkOrders based on ParentWorkOrder Id.
   * @JIRA# LEM-1684
   */
  runReadinessCheckValidations() {
    validateStoresReadiness({
      parentWorkOrderId: this.recordId
    })
      .then((result) => {
        if (result) {
          this.delay = DELAY_IN_TEN_SECONDS
        }
        reloadScreenAfterConfiguredDelay(this.delay);
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: VALIDATE_STORE_READINESS_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
    setMessage(storeReadinessValidationMessage);
    setMode(toastModeSticky);
    setVariant(toastVariantInfo);
    showNotification(this);
  }
}
