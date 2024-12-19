/**
 * @author Deloitte
 * @date 02/03/2023
 * @description JavaScript controller for dynamicRecordViewForm lightning web component.
 */
import { LightningElement, api } from 'lwc';

export default class DynamicRecordViewForm extends LightningElement {
  @api objectName;
  @api outputFields;
  @api recordId;
}