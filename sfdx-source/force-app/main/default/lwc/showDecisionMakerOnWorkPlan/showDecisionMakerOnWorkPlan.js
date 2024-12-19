/**
  * @author Deloitte
  * @date 07/12/2024
  * @description JavaScript controller for showDecisionMakerOnWorkPlan lightning web component.
  */
import { LightningElement, track, api, wire } from 'lwc';
import { setMessage, setVariant, showNotification } from 'c/utils';
import getWorkPlanDetails from "@salesforce/apex/ShowDecisionMakersOnWorkPlanController.getDecisionMakerPhoneDetails";
import updateNumberOfCallAttemptsOnWorkPlan from "@salesforce/apex/ShowDecisionMakersOnWorkPlanController.updateNumberOfCallAttemptsOnWorkPlan";
import storeUpdateMessage from '@salesforce/label/c.NumberOfCallUpdateSuccessMessage';
import noStoreForCall from '@salesforce/label/c.NoStoreAvailableForCallMessage';
import toastVariantSuccess from '@salesforce/label/c.Toast_Variant_Success';
import { refreshApex } from '@salesforce/apex';
const COLUMNS = [
    { label: 'Store Name', fieldName: 'accountName' },
    { label: 'MINT Store ID', fieldName: 'storeId' },
    { label: 'Number of Call Attempts', fieldName: 'numberCallAttempts', type: 'Number', editable: true }
];
export default class ShowDecisionMakerOnWorkPlan extends LightningElement {
    @api recordId;
    @track columns = COLUMNS;
    @track numberofCallAttempts;
    @track workPlanDetails = [];
    checkListValidateMessage = noStoreForCall;
    draftValues = [];
    refreshRecord;

    /*
     *@description It is used to set the Work Plan details to be displayed on lightning datatable.
     */
    @wire(getWorkPlanDetails, { workPlanId: '$recordId' })
    setWorkPlanDetails(result) {
        this.refreshRecord = result;
        if (result.data) {
            this.workPlanDetails = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.workPlanDetails = undefined;
            this.error = result.error;
        }
    }

    /*
     *@description It is used to set the Work Plan details to be displayed.
     */
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.recordId } });
        const result = await updateNumberOfCallAttemptsOnWorkPlan({ decisionMakerDetailsJSON: JSON.stringify(updatedFields) });
        setMessage(storeUpdateMessage);
        setVariant(toastVariantSuccess);
        showNotification(this);
        await refreshApex(this.refreshRecord);
        this.draftValues = [];
    }
}