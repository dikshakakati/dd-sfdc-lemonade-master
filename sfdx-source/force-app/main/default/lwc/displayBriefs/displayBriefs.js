import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getFields from "@salesforce/apex/DisplayBriefsController.getFields";
import getBriefDetails from "@salesforce/apex/DisplayBriefsController.getBriefDetails";
import briefsRelatedListLabel from "@salesforce/label/c.Briefs_Related_List";
import createLog from "@salesforce/apex/LogController.createLog";

const LWC_NAME = "DisplayBriefs";
const GET_FIELD_SET_FIELDS = "getFieldSetFields";
const GET_BRIEF_DETAILS = "getBriefDetails";
const UTILITY_TYPE = "utility:";
const TOAST_VARIANT = "error";
const SHOW_TOAST_MESSAGE_COMPONENT = "c-show-toast-message";
const FIELDS = [
    "Opportunity.Name"
];
const OBJECTNAME = "Opportunity";
const TOAST_DISPLAYTIME = 10000;

export default class DisplayBriefsRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api viewAll;
    @track relatedData = [];
    @track columns = [];
    @track viewAllColumns = [];
    showComponent = false;
    labels = {
        briefsRelatedListLabel
    };
    objectName = OBJECTNAME;
    /**
     * @description This method is used to get details of record with passed recordId.
     */
    @wire(getRecord, { recordId: '$recordId', optionalFields: FIELDS })
    record;

    /**
     * @description This method is used to get object details.
     */
    get name() {
        if (this.record.data) {
            return this.record.data.fields.Name.value;
        }
        return null;
    }

    /**
     * @description This method is used to render view all records page.
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
            allColumns.forEach((eachColumn) => {
                eachColumn.hideDefaultActions = false;
                eachColumn.sortable = true;
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
     * @description This method is used to get brief records.
     */
    @wire(getBriefDetails, { recordId: '$recordId' })
    setBriefDetails({ error, data }) {
        if (data) {
            let allData = data.map((brief) => ({
                ...brief
            }));
            allData.forEach((eachBrief) => {
                eachBrief.briefNameHyperlink = '/' + eachBrief.Id;
            });
            this.relatedData = [...allData];
            this.showComponent = true;
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_BRIEF_DETAILS,
                message: JSON.stringify(error.body)
            });
            this.showToastMessage(TOAST_VARIANT, error.body.message, UTILITY_TYPE + TOAST_VARIANT);
        }
    }

    /**
      * @description This method is used to display toast message
      * @param toastVariant
      * @param toastMessage
      * @param utilityType
      */
    showToastMessage(toastVariant, toastMessage, utilityType) {
        this.template.querySelector(
            SHOW_TOAST_MESSAGE_COMPONENT).showToast(
                toastVariant,
                toastMessage,
                utilityType,
                TOAST_DISPLAYTIME
            );
    }
}