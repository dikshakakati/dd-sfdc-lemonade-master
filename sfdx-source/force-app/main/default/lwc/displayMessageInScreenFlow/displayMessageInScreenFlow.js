/**
 * @author Deloitte
 * @date 30/05/2022
 * @description JavaScript controller to set property of the display message seen in the flow.
 */
import { LightningElement, api } from 'lwc';

const ERROR = 'error';
const FAILURE_RESPONSE = 'slds-notify slds-notify_toast slds-theme_error';
const SUCCESS = 'success';
const SUCCESS_RESPONSE = 'slds-notify slds-notify_toast slds-theme_success';
const WARNING = 'warning';
const WARNING_RESPONSE = 'slds-notify slds-notify_toast slds-theme_warning';

export default class DisplayMessageInScreenFlow extends LightningElement {
  @api
  isError;
  @api
  isSuccess;
  @api
  message;

  /**
   * @description It applies CSS theme on basis of the success or failure.
   */
  get themeCSS() {
    if (this.isSuccess && !this.isError) {
      return SUCCESS_RESPONSE;
    } else if (this.isSuccess && this.isError) {
      return WARNING_RESPONSE;
    }
    return FAILURE_RESPONSE;
  }

  /**
   * @description It decides the type of the message on basis of the success or failure.
   */
  get type() {
    if (this.isSuccess && !this.isError) {
      return SUCCESS;
    } else if (this.isSuccess && this.isError) {
      return WARNING;
    }
    return ERROR;
  }
}
