import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFailedStores from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getFailedStores";
import getFlowDetails from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getFlowRequestById";
import retryBatch from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.handleBatchRetry";

export default class BulkOnboardingProgressTracker extends NavigationMixin(LightningElement) {
    _currentStep; // For currentStep string value
    @api flowRequestId;
    @track showFeedbackSection = false;
    @track satisfactionRating;
    @track feedbackText = ""; // To hold the user feedback
    @track failedStores = [];
    @track workOrderObj;
    @track isLoading = false;
    
    @api
    set flowRequestObj(value) {
        this._recordObj = value;

        if (this._recordObj) {
            this.getFailedStoreAccounts();
            this.getRecordDetails();
        }
    }

    get flowRequestObj() {
        return this._recordObj;
    }

    // @api setter for the private currentStep variable
    @api
    set currentStep(value) {
        this._currentStep = (value) ? value.toString() : "1"; // convert to string and store in private property
    }

    // getter for the private currentStep variable
    get currentStep() {
        return this._currentStep; // return the private property value
    }

    // getter that returns true if ANY of the Stores have failed
    get hasFailures() {
        return !this.isRunning && (this.flowRequestObj && (this.flowRequestObj.Result__c == "Failure" || this.flowRequestObj.Result__c == "Partial Success"));
    }

    // getter that determines if the Process Flow Request's batch job is still running
    get isRunning() {
        return this.flowRequestObj && this.flowRequestObj.Status__c == "In Progress";
    }

    getFailedStoreAccounts() {
        if (!this.hasFailures) {
            return;
        }
        
        this.isLoading = true;
        
        getFailedStores({ flowRequestId: this.flowRequestId })
            .then(result => {
                this.failedStores = result;
            })
            .catch(error => {
                console.log("%c================ BulkOnboardingProgressTracker ================", "color: red; font-weight: bold;");
                console.log("Unable to retrieve failed stores. See error below:");
                console.error(error);
                console.log("%c================ BulkOnboardingProgressTracker ================", "color: red; font-weight: bold;");
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getRecordDetails() {
        if (this.hasFailures) {
            return;
        }

        getFlowDetails({ flowRequestId: this.flowRequestId })
            .then(result => {
                this.workOrderObj = result.Work_Order__r;
            })
            .catch(error => {
                let errorStyling = "color: red; font-weight: bold;";
                console.log("%c================ BulkOnboardingProgressTracker ================", errorStyling);
                console.log("Unable to retrieve Work Order for Process Flow Request. See error below:", errorStyling);
                console.error(error);
                console.log("%c================ BulkOnboardingProgressTracker ================", errorStyling);
            });
    }

    // Shows the Feedback section if the user is interested
    toggleFeedbackSection() {
        this.showFeedbackSection = !this.showFeedbackSection;
    }

    // Updates the feedbackText variable when the user enters Feedback Notes
    handleFeedbackChange(event) {
        if (event && event.detail) {
            this.feedbackText = event.detail.feedbackText; // Storing the user feedback
        }
    }

    // Called when the Star ratings are clicked to update the satisfactionRating value.
    updateRating(event) {
        if(event && event.detail && event.detail.rating) {
            this.satisfactionRating = parseInt(event.detail.rating);
        } else {
            this.satisfactionRating = null;
        }
    }

    // Event handler invoked from the "Finish" button 
    handleFinish() {
        const submittedFeedback = this.showFeedbackSection && (this.satisfactionRating || this.feedbackText);
        
        // Dispatch an event so the parent can handle the PFR save
        const finishOnboardingEvent = new CustomEvent("finishonboarding", {
            detail: {
                submittedFeedback: submittedFeedback,
                feedback: {
                    "rating": this.satisfactionRating,
                    "notes": this.feedbackText
                }
            }
        });
        
        this.dispatchEvent(finishOnboardingEvent);        
    }

    // Invokes the Batch
    handleRetry() {
        if(this.disableRetryButton) {
            return;
        }

        // Disable the Retry button to prevent multiple clicks
        this.disableRetryButton = true;
        this.isLoading = true;
    
        // Call the Apex method to retry the batch
        retryBatch({ flowRequestId: this.flowRequestId })
            .then(() => {
                // Dispatch Toast Error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Processing Stores",
                        message: "The remaining stores are being processed",
                        variant: "success",
                    })
                );                
            })
            .finally(() => {
                // Enable the Retry button after the process is completed
                this.disableRetryButton = false;
                this.isLoading = false;
            });
    }

    // Method to navigate to the record page of the linked failed Stores
    navigateToAccount(event) {
        event.preventDefault();
        const accountId = event.target.dataset.accountId;
        if(accountId) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: accountId,
                    actionName: "view",
                },
            });
        }
    }

    // Navigates to the linked Work Order
    navigateToWorkOrder(event) {
        event.preventDefault();
        const workOrderId = event.target.dataset.woId;
        if(workOrderId) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: workOrderId,
                    actionName: "view",
                },
            });
        }
    }
}