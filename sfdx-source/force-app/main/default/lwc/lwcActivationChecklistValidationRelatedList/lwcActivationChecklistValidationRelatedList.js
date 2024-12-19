import { LightningElement, api, wire } from "lwc";
import { refreshApex } from "@salesforce/apex"
import { gql, graphql, refreshGraphQL } from "lightning/uiGraphQLApi"
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import {
	subscribe,
	unsubscribe,
	APPLICATION_SCOPE,
	MessageContext,
} from "lightning/messageService";
import lastValidationRunOn from '@salesforce/label/c.Activation_Checklist_Last_Validation_Run_On';
import checkListValidateMessage from '@salesforce/label/c.Activation_Checklist_Validate_Message';
import activationsChecklistReport from '@salesforce/label/c.Activation_Checklist_Report_Details';
import activationChecklistDepenentWorkSteps from '@salesforce/label/c.Activation_Checklist_Dependent_Work_Steps';
import activationChecklistSystemFailure from '@salesforce/label/c.Activation_Checklist_System_Error';
import activationsChecklistsuccess from '@salesforce/label/c.Activation_Checklist_Validation_Success';
import displayValidationInProgressmessage from '@salesforce/label/c.Activation_Checklist_Validation_In_progress';
import LAST_VALIDATION_EXECUTION from "@salesforce/schema/WorkPlan.Last_Validation_Execution__c";
import ACTIVATION_CHECKLIST_VALIDATION from "@salesforce/schema/WorkPlan.Activation_Checklist_Validation__c";
import ID_FIELD from "@salesforce/schema/WorkPlan.Id";
import WORK_PLAN_NAME from "@salesforce/schema/WorkPlan.Name";
import { NavigationMixin } from "lightning/navigation";
import collectChildActivationChecklistWorkSteps from '@salesforce/apex/ActivationCheckValidationController.getChildActivationChecklistWorkSteps';
import hasOpenDependentWorkPlan from '@salesforce/apex/ActivationCheckValidationController.hasOpenDependentWorkPlan';
import activationChecklistMessageChannel from "@salesforce/messageChannel/Activation_Checklist__c";

const columns = [
	{ label: 'Validation', fieldName: 'Validation' },
	{ label: 'Result', fieldName: 'Result' },
	{ label: 'Target', fieldName: 'Target' },
	{
		label: 'Records', fieldName: 'Records', type: 'button',
		cellAttributes: {
			alignment: 'center'
		},
		typeAttributes: {
			label: {
				fieldName: 'Records'
			},
			name: 'openReport',
			variant: 'base'

		}
	}

];
const WORK_ORDER_STATUS_DEAD = 'Dead';
export default class LwcActivationChecklistValidationRelatedList extends NavigationMixin(LightningElement) {
	toastVariant;
	toastMessage;
	responseStatus = 'status';
	utilityType = 'utility:';
	escalatedStatus = 'Escalated';
	showToastMessagecomponent = 'c-show-toast-message';
	showActivationChecklistDependentWorkStepMessage = false;
	reportRecordId;
	activationsChecklistReportDetails = activationsChecklistReport.split(',');
	displayValidationInProgressmessage = displayValidationInProgressmessage;
	disableValidate = false;
	activationsChecklistsuccess = activationsChecklistsuccess;
	activationChecklistDepenentWorkSteps = activationChecklistDepenentWorkSteps;
	@api validationType;
	@api recordId;
	@api objectApiName;
	@api activationCheckListFolderName = 'Public Reports';
	@api activationCheckListReportName = 'Activation_Checklist_Validation_Report';

	showToast = {
		title: "Activation CheckList In Progress",
		message: this.displayValidationInProgressmessage,
		variant: "info",
		position: "top-center",
		mode: "sticky"
	}
	isValidate = false;
	isLoading = true;
	activationCheckListResults;
	columns = columns;
	subscription = null;
	successRecords = [];
	failedRecords = [];
	dataList = [];
	lastValidationExecution;
	lastValidationRunOn = lastValidationRunOn;
	checkListValidateMessage = checkListValidateMessage;
	validationInProgress = false;
	hasRendered = false;
	isSystemFailure = false;
	systemErrorMessage = activationChecklistSystemFailure;

	connectedCallback() {
		this.subscribeToMessageChannel();
	}

	/**
	 * @description It is used to auto refresh page whenever the page is opened.
	 */
	renderedCallback() {
		if (!this.hasRendered || this.validationInProgress || this.isSystemFailure) {
			this.refreshPage();
			this.hasRendered = true;
		}
	}
	//doNotShowActivationCheckList;
	/*
	Define variables for GraphQL paramemters
	*/
	get variables() {
		return {
			wpRecordId: this.recordId,
			workOrderStatusDead: WORK_ORDER_STATUS_DEAD,
			reportFolderName: this.activationsChecklistReportDetails[0],
			reportName: this.activationsChecklistReportDetails[1]
		}
	}
	/*
	Get last validate execution date & time from WorkPlan Object
	*/
	@wire(getRecord, {
		recordId: "$recordId",
		fields: [LAST_VALIDATION_EXECUTION, ACTIVATION_CHECKLIST_VALIDATION, WORK_PLAN_NAME]
	})
	workplan;
	get LastValidationExecution() {
		return getFieldValue(this.workplan.data, LAST_VALIDATION_EXECUTION);
	}
	get ExecuteActivationExecution() {
		return getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === 'In Progress';
	}
	get ExecuteActivationExecutionComplete() {
		return getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === 'Completed';
	}
	get displayIllustrationScreen() {
		return getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === 'Pending';
	}
	get executeActivationEscalation() {

		return getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === this.escalatedStatus;
	}
	get enableSpinner() {
		return this.isLoading || getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === 'In Progress';
	}
	get isDisableValidate() {
		return getFieldValue(this.workplan.data, ACTIVATION_CHECKLIST_VALIDATION) === 'In Progress' ? true : this.disableValidate;
	}

	/**
	* @description To fetch dependent work steps for activation check validatio.
	* @JIRA# LEM-14485
	* @param currentWorkPlanRecordId
	* @return List<AccountWrapper>
	*/
	@wire(hasOpenDependentWorkPlan, { workPlanId: '$recordId' })
	wiredWorkSteps({ data, error }) {
		if (data) {
			this.showActivationChecklistDependentWorkStepMessage = data;
			this.disableValidate = data;
		} else if (error) {
		}
	}

	/*
	Get Report Id To natigate to the Report
	*/
	@wire(graphql, {
		query: gql`
		query Reports (
			$reportFolderName: String,
			$reportName: String
		){
			uiapi {
				query {
				  Report ( where : { FolderName: { eq: $reportFolderName }
					DeveloperName: { eq: $reportName }}){
					edges {
					  node {
						Id
						Name {
						  value
						}

					  }
					}
				  }
				}
			  }
		}
	  `,
		variables: '$variables',
	})
	reportResult({ data, errors }) {
		if (data) {
			this.records = data.uiapi.query.Report.edges.map((edge) => edge.node);
			this.reportRecordId = this.records[0].Id;
		}
		this.errors = errors;
	}
	/*
	Get activation checklist records for the selected Work Plan record Id
	*/
	@wire(graphql, {
		query: gql`
      query aggregates(
        $wpRecordId : ID,
		$workOrderStatusDead: Picklist
      ) {
        uiapi {
          aggregate {
            Activation_Checklist__c(
              where: {
                Work_Plan__c: { eq: $wpRecordId },
				Work_Step__r: {
					WorkOrder: {
						Status: { ne: $workOrderStatusDead}
					}
			    },
				Work_Step__c: { ne: null },
				Work_Step__r: {
					WorkPlan: {
						Parent_Work_Plan__c: { eq: $wpRecordId}
					}
			    }
              }
              groupBy: {
                Activation_Validation_Name__c: { group: true },
                Result__c: { group: true },
                Target__c: { group: true },
				Source__c: { group: true },
                Status__c: { group: true }
              }) {
              edges {
                node {
                  aggregate {
                    Activation_Validation_Name__c {
                      value
                      grouping {
                        value
                      }
                    }
                    Result__c {
                      value
                      grouping {
                        value
                      }
                    }
                    Target__c {
                      value
                      grouping {
                        value
                      }
                    }
					Source__c {
						value
						grouping {
						  value
						}
					  }
                    Status__c {
                      value
                      grouping {
                        value
                      }
                    }
                    Id {
                      count {
                        value
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      `,
		variables: '$variables'
	})
	wiredGraphQLActivationCheckList(result) {
		const { data, error } = result;
		this.activationCheckListResults = result;
		this.successRecords = [];
		this.dataList = [];
		this.failedRecords = [];
		this.isLoading = true;
		if (data) {
			let dataListArray = data.uiapi.aggregate.Activation_Checklist__c.edges.map((item) => {
				return {
					Validation: item.node.aggregate.Activation_Validation_Name__c.value,
					Result: item.node.aggregate.Result__c.value,
					Target: item.node.aggregate.Target__c.value,
					Status: item.node.aggregate.Status__c.value,
					Source: item.node.aggregate.Source__c.value,
					Records: item.node.aggregate.Id.count.value
				}
			});
			this.dataList = [...new Set(dataListArray)];
			if (this.dataList) {
				this.successRecords = this.dataList.filter((item) => item.Status === 'Passed');
				this.failedRecords = this.dataList.filter((item) => item.Status === 'Failed');
			}
		} else if (error) {
			this.errors = error;
			//log(msg);
		}
		this.isLoading = false;
	}
	/*
	Get property to check Display failure section in the Activation Checklist Placeholder
	*/
	get displayFailure() {
		return this.failedRecords.length > 0;
	}
	/*
	Get property to check Display success section in the Activation Checklist Placeholder
	*/
	get displaySuccess() {
		return this.successRecords.length > 0;
	}
	/*
	Get property for count of success validation records
	*/
	get totalSuccessRecords() {
		let totalCount = 0;
		this.successRecords.forEach(function (item) {
			totalCount = totalCount + item.Records;
		});
		return totalCount;
	}
	/*
	Get property for count of failure validation records
	*/
	get totalFailedRecords() {
		let totalCount = 0;
		this.failedRecords.forEach(function (item) {
			totalCount = totalCount + item.Records;
		});
		return totalCount;
	}
	get displayValidationMessage() {
		if (this.LastValidationExecution && !this.displayIllustrationScreen) {
			let totalCount = this.totalSuccessRecords + this.totalFailedRecords;
			return 'Total Validations (' + totalCount + ')';

		}
		return 'Total Validations';
	}
	async refreshActivationCheckListResults() {
		await refreshGraphQL(this.activationCheckListResults);
	}

	@wire(MessageContext)
	messageContext;

	// Encapsulate logic for Lightning message service subscribe and unsubsubscribe
	subscribeToMessageChannel() {
		if (!this.subscription) {
			console.log('******subscribeToMessageChannel***');
			this.subscription = subscribe(
				this.messageContext,
				activationChecklistMessageChannel,
				(message) => this.handleMessage(message),
				{ scope: APPLICATION_SCOPE },
			);
		}
	}

	unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

	// Handler for message received by component
	handleMessage(message) {
		if (this.recordId === message.parentWorkPlanId) {
			this.disableValidate = message.enableValidateButton;
			this.validationInProgress = message.isValidationInProgress;
			this.refreshPage();
			this.isLoading = message.isValidationInProgress;
			console.log('******handleMessage');
		}
	}

	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (actionName) {
			case 'openReport':
				this.openRowReport(row);
				break;
			default:
		}
	}
	openRowReport(row) {
		var obj = {};
		obj["fv0"] = row.Validation;
		obj["fv1"] = row.Status;
		obj["fv2"] = this.recordId;
		obj["fv5"] = this.recordId;
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: this.reportRecordId,
				objectApiName: "Report",
				actionName: "view"
			},
			state: obj
		});
	}
	refreshActivationChecklist(event) {
		this.isLoading = true;
		this.refreshPage();
		this.isLoading = false;
	}
	updateWorkPlanActivationValidationWithInProgress() {
		this.isValidate = true;
		this.disableValidate = true;
		this.validationInProgress = true;
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[ACTIVATION_CHECKLIST_VALIDATION.fieldApiName] = "In Progress";
		fields[LAST_VALIDATION_EXECUTION.fieldApiName] = new Date();
		const recordInput = {
			fields: fields
		};
		updateRecord(recordInput).then((record) => {
			this.sendActivationsChecklistWorkStepsForValidation();
		}).catch((error) => {
			this.toastVariant = 'error';
			this.toastMessage = 'System Error : Something went wrong.  Please try validate again.';
		});
	}

	/*
	* @description - This method is being used for send all Activations Checklist worksteps to MINT(Through MuleSoft API)
	*/
	sendActivationsChecklistWorkStepsForValidation() {
		collectChildActivationChecklistWorkSteps({ workPlanID: this.recordId })
			.then(result => {
				this.toastVariant = result['status'];
				this.toastMessage = result['message'];
			})
			.catch(error => {
				this.toastVariant = 'error';
				this.toastMessage = 'System Error : Something went wrong.  Please try validate again.';
			});
	}
	/*
	* @description - Validate button click event
	*/
	updateLastValidationExecution(event) {
		this.updateWorkPlanActivationValidationWithInProgress();
	}
	/*
	* @description - Refresh Page on post validation or Refresh page
	*/
	refreshPage() {
		getRecordNotifyChange([{ recordId: this.recordId }]);
		refreshApex(this.workplan);
		this.refreshActivationCheckListResults();
	}
	/**
	* @description Generic method to display toast message
	* @param titleVal
	* @param messageVal
	* @param variantVal
	* @param messageDataVal
	* @param modeVal
	*/
	showToastMessage(taskVariant, messageVal, utilityType) {
		this.template.querySelector(
			this.showToastMessagecomponent).showToast(
				taskVariant,
				messageVal,
				utilityType,
				10000
			);
	}
}