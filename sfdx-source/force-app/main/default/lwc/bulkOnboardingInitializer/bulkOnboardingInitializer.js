import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACCOUNT_FIELD from "@salesforce/schema/Contract.AccountId";
import OPPORTUNITY_FIELD from "@salesforce/schema/Contract.SBQQ__Opportunity__c";
import submitRequest from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.submitRequest";
import closeExistingRequest from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.closeExistingRequest";
import linkExistingWorkOrder from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.linkExistingWorkOrder";
import linkRelatedRecords from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.linkRelatedRecords";
import saveUserFeedback from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.saveUserFeedback";
import navigateToCompletionStep from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.navigateToCompletionStep";
import validateAndLoadRequest from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.validateAndLoadRequest";

const STAGE_TO_STEP_MAPPING = {
  "Work Order Type Selection": 1,
  "Work Order Creation": 2,
  "Work Order Association": 2,
  "Account File Upload": 3,
  "Select Entitlement": 3,
  "Payment Account": 6,
  "Decision Maker": 7,
  "Final Error Check": 8,
  "Processing Stores": 9,
  "Upload Complete": 9
};

const VARIANT_ERROR = "error";
const ERROR_TITLE_FLOW_START = "An error occurred while starting the Bulk Store Onboarding Flow";
const ERROR_TITLE_CLOSE_REQUEST = "An error occurred while closing the existing Onboarding Request";
const ERROR_TITLE_WORK_ORDER_SELECTION = "An error occurred while linking the selected Work Order";
const ERROR_TITLE_RELATED_RECORD_SELECTION = "An error occurred while selecting the related records";
const ERROR_MSG_TRY_AGAIN = "Please try again. If the issue persists, please contact an administrator.";

export default class BulkOnboardingInitializer extends NavigationMixin(LightningElement) {
  @track accountId; // The Account's ID related to the Contract
  @track opportunityId; // The Opportunity's ID related to the Contract
  @track flowRequestObj;
  @track currentStep;
  @track isLoading = true;
  @track isSaving = false;
  @track showSpinner = true;
  @track spinnerLoadingMessage;
  @track createNewWorkOrder = false;
  @track hasOpportunityAccess = true;
  @track isCsvUploadSuccessful;

  @track isStep0 = false;
  @track isStep1 = true;
  @track isStep2 = false;
  @track isStep3 = false;
  @track isStep4 = false;
  @track isStep6 = false;
  @track isStep7 = false;
  @track isStep8 = false;
  @track isStep9 = false;
  @track showPaymentAccountSkipOption;
  @track workOrderTypeError;

  _userFeedback = {};

  @api
  set recordId(value) {
    this._recordId = value;
    if (this._recordId) {
      this.validateWoTypeAndLoadExistingRequest();
    }
  }
  get recordId() {
    return this._recordId;
  }

  validateWoTypeAndLoadExistingRequest() {
    validateAndLoadRequest({ type: 'Marketplace', contractId: this.recordId })
      .then(result => {
        this.flowRequestObj = result; // Process_Flow_Request__c record

        // Determine which Work Order page to open if they are on the Work Order step
        this.createNewWorkOrder = this.flowRequestObj && this.flowRequestObj.Stage__c === "Work Order Creation";
        // Determine if CSV upload is complete and user need to move to select entitlement
        this.isCsvUploadSuccessful = this.flowRequestObj && this.flowRequestObj.Stage__c === "Select Entitlement";
      })
      .catch(error => {
        this.workOrderTypeError = error.body.message;
      })
      .finally(() => {
        this.isLoading = false;
        this.setSteps();
        this.setShowSpinner();
      });
  }

  @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_FIELD] })
  wiredAccountField({ error, data }) {
    if (data) {
      this.accountId = getFieldValue(data, ACCOUNT_FIELD);
    } else if (error) {
      console.error('Error retrieving account field:', error);
    }
  }
  @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_FIELD] })
  wiredOpportunityField({ error, data }) {
    if (data) {
      this.opportunityId = getFieldValue(data, OPPORTUNITY_FIELD);
    } else if (error) {
      this.hasOpportunityAccess = false;
      console.error('Error retrieving opportunity field:', error);
    }
  }

  setSteps() {
    this.setStepsToFalse();

    if (this.flowRequestObj || (this.workOrderTypeError !== null && this.workOrderTypeError !== undefined)) {
      this.isStep0 = true;
      this.currentStep = 0;
    } else {
      this.isStep1 = true;
      this.currentStep = 1;
    }
  }

  setStepsToFalse() {
    this.isStep0 = false;
    this.isStep1 = false;
    this.isStep2 = false;
    this.isStep3 = false;
    this.isStep4 = false;
    this.isStep6 = false;
    this.isStep7 = false;
    this.isStep8 = false;
    this.isStep9 = false;
  }

  setCurrentStepFlag() {
    switch (this.currentStep) {
      case 1:
        this.isStep1 = true;
        break;
      case 2:
        this.isStep2 = true;
        break;
      case 3:
        this.isStep3 = true;
        break;
      case 6:
        this.isStep6 = true;
        break;
      case 7:
        this.isStep7 = true;
        break;
      case 8:
        this.isStep8 = true;
        break;
      case 9:
        this.isStep9 = true;
        break;
      default:
        this.isStep1 = true;
        break;
    }
  }

  updateSteps() {
    this.setStepsToFalse();

    this.currentStep = STAGE_TO_STEP_MAPPING[this.flowRequestObj.Stage__c];
    this.setCurrentStepFlag();
  }

  handleCreateNewWorkOrder() {
    this.initializeFlowRequest(true);
  }

  handleSelectExistingWorkOrder() {
    this.initializeFlowRequest(false);
  }

  // When a user is on one of the Work Order pages (like WO creation) and wants to switch to selection
  handleSwitchWorkOrderMethod(event) {
    // Call with the "workOrderCreated" flag
    this.initializeFlowRequest(event.detail && event.detail.newType === "creation");
  }

  handleAddExistingWorkOrder(event) {
    const selectedWorkOrderId = event.detail;
    this.isSaving = true;
    this.setShowSpinner();

    linkExistingWorkOrder({ flowRequestId: this.flowRequestObj.Id, selectedWorkOrderId: selectedWorkOrderId })
      .then(result => {
        this.flowRequestObj = result;
      })
      .catch(error => {
        this.handleError(error, ERROR_TITLE_WORK_ORDER_SELECTION);
      })
      .finally(() => {
        this.completeSavingProcess();
      });
  }

  // Called on Work Order Options
  initializeFlowRequest(createNewWorkOrder) {
    this.isSaving = true;
    this.setShowSpinner();

    submitRequest({ flowRequestId: this.flowRequestObj?.Id, contractId: this.recordId, creatingNewWorkOrder: createNewWorkOrder })
      .then(result => {
        console.log("result", JSON.parse(JSON.stringify(result)));
        this.flowRequestObj = result;

        this.isSaving = false;
        this.setShowSpinner();

        this.errors = {}; // clear out any existing errors
        this.createNewWorkOrder = createNewWorkOrder;
      })
      .catch(error => {
        this.isSaving = false;
        this.setShowSpinner();
        this.handleError(error, ERROR_TITLE_FLOW_START);
      })
      .finally(() => {
        this.isSaving = false;
        this.setShowSpinner();
        this.updateSteps();
      });
  }

  handleGoToNext(event) {
    this.flowRequestObj = event.detail.flowRequestValue;
    if (Object.hasOwn(event.detail, 'skipStepValue')) {
      this.showPaymentAccountSkipOption = event.detail.skipStepValue;
    }
    this.updateSteps();
  }

  handleManagePackages() {
    this.setStepsToFalse();
  }

  // Links related records, such as Payment Accounts and Decision Makers.
  // The Apex method, linkRelatedRecords(), handles the different object
  // types dynamically, so we can use the same client logic to call in
  // both instances.
  handleSelectPaymentAccountOrDecisionMaker(event) {
    const relatedRecordId = event.detail.recordId;
    const skipRecordLinking = event.detail.skipRecordLinking;

    this.isSaving = true;
    this.setShowSpinner();

    linkRelatedRecords({ flowRequestId: this.flowRequestObj.Id, relatedRecordId: relatedRecordId, skipRecordLinking: skipRecordLinking })
      .then(result => {
        this.flowRequestObj = result;
      })
      .catch(error => {
        this.handleError(error, ERROR_TITLE_RELATED_RECORD_SELECTION);
      })
      .finally(() => {
        this.completeSavingProcess();
      });
  }

  handleNavigateToFinalScreen() {
    this.isSaving = true;
    this.setShowSpinner();

    navigateToCompletionStep({ flowRequestId: this.flowRequestObj.Id })
      .then(result => {
        this.flowRequestObj = result;
      })
      .catch(error => {
        this.handleError(error, ERROR_MSG_TRY_AGAIN);
      })
      .finally(() => {
        this.completeSavingProcess();
      });
  }

  completeSavingProcess() {
    this.isLoading = false;
    this.isSaving = false;
    this.spinnerLoadingMessage = undefined;
    this.setShowSpinner();
    this.updateSteps();
  }

  // Called at the conclusion of the process to close the modal
  closeModal() {
    // This replicates the standard "X" functionality provided by the `lightning__RecordAction` component
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        actionName: "view"
      },
    });
  }

  handleFinishOnboarding(event) {
    console.log("%cIn bulkOnboardingInitializer.handleFinishOnboarding()", "font-weight: bold;");
    console.log(event.detail);

    this.isSaving = true;
    this.setShowSpinner();

    const finishOnboardingEvent = event.detail;

    this._userFeedback = {
      "rating": finishOnboardingEvent.feedback.rating,
      "notes": finishOnboardingEvent.feedback.notes
    };

    if (finishOnboardingEvent.submittedFeedback) {
      this.callApexToSaveFeedback();
    } else {
      this.finish();
    }
  }

  handleUseExistingRequest() {
    this.updateSteps();
  }

  handleResetExistingRequest() {
    this.isSaving = true;
    this.setShowSpinner();
    this.isCsvUploadSuccessful = false;

    closeExistingRequest({ flowRequestId: this.flowRequestObj.Id })
      .then(result => {
        console.log("result", result);

        this.flowRequestObj = null;
      })
      .catch(error => {
        this.handleError(error, ERROR_TITLE_CLOSE_REQUEST);
      })
      .finally(() => {
        this.isLoading = false;
        this.isSaving = false;
        this.setSteps();
        this.setShowSpinner();
      });
  }

  // Used for calling the Apex method, saveUserFeedback(), to save User_Feedback__c details.
  callApexToSaveFeedback() {
    const feedbackStr = JSON.stringify(this._userFeedback);

    // Save the feedback and rating through Apex
    saveUserFeedback({
      flowRequestId: this.flowRequestObj.Id,
      userFeedbackStr: feedbackStr
    })
      .then(result => {
        // Handle success - you can add logic here
        this.flowRequestObj = result;
      })
      .catch(error => {
        // Handle error - you can add logic here
        console.error(error);
      })
      .finally(() => {
        this.finish();
      });
  }

  // Called from the resolved Promise returned by the Apex methods - this will terminate the process.
  finish() {
    // Dispatching a custom event
    this.isSaving = false;
    this.setShowSpinner();
    this.closeModal();
  }

  // Called in the catch blocks to display an error message and output error details to the development team
  // Can be extended to call a controller method that will insert a Log__c with the error details
  handleError(error, toastTitle) {
    console.log("%c================ BULK STORE ONBOARDING - ERROR DETAILS ================", "color: red; font-weight: bold;");
    console.error("The following error has been thrown during the Bulk Store Onboarding Flow:");
    console.log(error);

    if (error) {
      console.log("Error Body: ", error.body);

      if (error.body) {
        console.log("Error Message: ", error.body.message);
      }
    }

    let errorMessage = `${ERROR_MSG_TRY_AGAIN}`;
    // Add the error message if we have it
    if (error && error.body && error.body.message) {
      errorMessage += ` Error Details: ${error.body.message}`;
    }

    console.log("Error Message to User: " + toastTitle + " " + errorMessage);
    console.log("%c================ BULK STORE ONBOARDING - ERROR DETAILS ================", "color: red; font-weight: bold;");

    // Dispatch Toast Error
    this.dispatchEvent(
      new ShowToastEvent({
        title: toastTitle,
        message: errorMessage,
        variant: VARIANT_ERROR,
      })
    );
  }

  setShowSpinner() {
    this.showSpinner = this.isLoading || this.isSaving;
  }
}