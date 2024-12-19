import { LightningElement, api, wire } from "lwc";
import hasActivationsCheckListForSelectedWorkPlan from '@salesforce/apex/ActivationCheckValidationController.hasActivationsCheckListForSelectedWorkPlan';
import checkListValidateMessage from '@salesforce/label/c.Activation_Checklist_No_WorkStep_Found';
export default class LwcWorkPlanActivationCheckListValidation extends LightningElement {
	@api recordId;
	@api objectApiName;
	checkListValidateMessage = checkListValidateMessage;

	/**
	 * @description It is used to check if a Work Plan has the Activation Checklist workstep.
	 */
	@wire(hasActivationsCheckListForSelectedWorkPlan, {
		workPlanID: "$recordId"
	})
	hasActivationCheckListWorkStep;

	/**
	 * @description It is used to control visibility of Activation Checklist Validation data.
	 */
	get doNotShowActivationCheckList() {
		return !this.hasActivationCheckListWorkStep.data;
	}
}