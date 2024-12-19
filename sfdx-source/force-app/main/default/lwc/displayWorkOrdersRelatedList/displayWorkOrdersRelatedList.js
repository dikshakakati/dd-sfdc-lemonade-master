import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getFields from "@salesforce/apex/DisplayWorkOrdersController.getFields";
import getWorkOrderDetails from "@salesforce/apex/DisplayWorkOrdersController.getWorkOrderDetails";
import relatedWorkOrders from "@salesforce/label/c.Related_Work_Orders";
import createLog from "@salesforce/apex/LogController.createLog";

const LWC_NAME = "DisplayWorkOrdersRelatedList";
const GET_FIELD_SET_FIELDS = "getFieldSetFields";
const GET_WORK_ORDER_DETAILS = "getWorkOrderDetails";
const UTILITY_TYPE = "utility:";
const TOAST_VARIANT = "error";
const SHOW_TOAST_MESSAGE_COMPONENT = "c-show-toast-message";
const FIELDS = [
    "Account.Name",
    "Opportunity.Name"
];

export default class DisplayWorkOrdersRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api viewAll;
    @track relatedData = [];
    @track columns = [];
    @track viewAllColumns = [];
    showComponent = false;
    labels = {
        relatedWorkOrders
    };

    @api objectApiName;
    /**
     * @description This method is used to get object record details.
     */

    @wire(getRecord, { recordId: '$recordId', optionalFields: FIELDS })
    record;

    /**
     * @description This method is used to get Account details.
     */
    get name() {
        if (this.record.data) {
            return this.record.data.fields.Name.value;
        }

        return null;
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
            this.columns = [...allColumns].splice(0, 5);
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_FIELD_SET_FIELDS,
                message: JSON.stringify(error.body)
            });
            this.showToastMessage(TOAST_VARIANT, error.body.message, UTILITY_TYPE + TOAST_VARIANT);
        }
    }

    /**
     * @description This method is used to get parent work order records.
     */
    @wire(getWorkOrderDetails, { recordId: '$recordId' })
    setParentWorkOrderDetails({ error, data }) {
        if (data) {
            let allData = data.map((workOrder) => ({
                ...workOrder
            }));
            allData.forEach((obj) => {
                obj.workOrderNumberHyperlink = '/' + obj.Id;
                obj.workOrderNameHyperlink = '/' + obj.Id;
                obj.workOrderCreatedByHyperlink = '/' + obj.CreatedById;
                obj.CreatedById = obj.CreatedBy.Name;
            });
            this.relatedData = [...allData];
            this.showComponent = true;
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_WORK_ORDER_DETAILS,
                message: JSON.stringify(error.body)
            });
            this.showToastMessage(TOAST_VARIANT, error.body.message, UTILITY_TYPE + TOAST_VARIANT);
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
        this.template.querySelector(
            SHOW_TOAST_MESSAGE_COMPONENT).showToast(
                taskVariant,
                messageVal,
                utilityType,
                10000
            );
    }
}