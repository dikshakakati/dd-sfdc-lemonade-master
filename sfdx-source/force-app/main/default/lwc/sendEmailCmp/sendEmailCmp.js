import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import fetchAccountDetails from "@salesforce/apex/SendEmailCmpController.fetchAccountDetails";
import updateEmailReferenceId from "@salesforce/apex/SendEmailCmpController.updateEmailReferenceId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


const BASE_URL = window.location.origin;
const NONE_OPTION = '--none--';
const NONE_OBJECT = { label: '--none--', value: null };
const GENERIC_TOAST_ERROR_TITLE = "Work Plan is not a parent work plan.";
const GENERIC_TOAST_ERROR_MESSAGE = "Please select a parent work plan.";
const GENERIC_TOAST_ERROR_VARIANT = "warning";
const GENERIC_TOAST_ERROR_TITLE_ACCOUNT_ID = "Business Account not found.";
const GENERIC_TOAST_ERROR_MESSAGE_ACCOUNT_ID = "Please select a WorkPlan which holds a Business Account.";

export default class SendEmailCmp extends NavigationMixin(LightningElement) {
    @api recordId;
    @track storeAccounts;
    @track storeIdToWorkPlan;
    showSpinner = false;
    isNextDisabled = true;
    storeAccountSelectionScreen = false;
    accountId;
    businessAccount;
    selectedStoreAccount;
    emailSubject;
    htmlBody = '<p style="line-height: 1.38; text-align: center;"><img alt="DoorDash_icon_RGB" src="https://doordashmx--sprintqa2.sandbox.file.force.com/file-asset-public/DoorDash_icon_RGB?oid=00DO1000001q7NA" style="max-width: 881.134px; width: 145px; height: 80px;" title="DoorDash_icon_RGB"></p><hr style="height:1.38px;border-width:0;color:#ff0000;background-color:#ff0000">';
    fromEmailAddress = "merchant-support@doordash.com";
    businessAccountLabel = 'Business Account';
    storeAccountLabel = 'Store Account';

    /**
    * @description it makes a call to apex method when send email button is clicked,
    * which fetches storeAccounts, workplan related to store Accounts and emails related to those workplans.
    */
    handleClick() {
        this.showSpinner = true;
        fetchAccountDetails({ workplanId: this.recordId })
            .then(result => {
                if (result) {
                    if (!result.isParentWorkPlan) {
                        this.showToastError(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, GENERIC_TOAST_ERROR_VARIANT);
                        this.showSpinner = false;
                    }
                    else if (result.businessAccountId == null) {
                        this.showToastError(GENERIC_TOAST_ERROR_TITLE_ACCOUNT_ID, GENERIC_TOAST_ERROR_MESSAGE_ACCOUNT_ID, GENERIC_TOAST_ERROR_VARIANT);
                        this.showSpinner = false;
                    }
                    else {
                        this.storeAccounts = [NONE_OBJECT, ...result.storeAccounts.map(account => ({
                            label: account.Name,
                            value: account.Id
                        }))];
                        // scenario if only one store account is present.
                        if (this.storeAccounts.length === 2) {
                            this.storeAccounts.shift();
                            this.isNextDisabled = false;
                            this.selectedStoreAccount = this.storeAccounts[0].value;
                        }

                        // maps business account
                        this.businessAccount = {
                            name: result.businessAccountName,
                            id: result.businessAccountId,
                            url: BASE_URL + '/' + result.businessAccountId
                        }

                        // maps store id to child work plan
                        this.storeIdToWorkPlan = Object.entries(result.storeIdToWorkPlans).map(([storeId, workPlan]) => ({
                            storeId,
                            workPlan
                        }));
                        this.showSpinner = false;
                        this.storeAccountSelectionScreen = true;
                    }

                }
            })
            .catch((error) => {
                console.log(error);
                this.showSpinner = false;
            });
    }

    /**
    * @description it is used to find workplan id from store id.
    */
    findWorkPlanId(storeId) {
        const workPlan = this.storeIdToWorkPlan.find(eachWorkPlan => eachWorkPlan.storeId == storeId);
        return workPlan ? workPlan.workPlan.Id : null;
    }

    /**
    * @description it is used to find decision maker email.
    */
    findDecisionMakerEmail(storeId) {
        const workPlan = this.storeIdToWorkPlan.find(eachWorkPlan => eachWorkPlan.storeId == storeId);
        return workPlan ? workPlan.workPlan.Decision_Maker_Email__c : null;
    }

    /**
    * @description this method navigates to email component.
    */
    navigateToEmail(workPlanId, decisionMakerEmail) {
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName: "Global.SendEmail",
            },
            state: {
                recordId: this.recordId,
                defaultFieldValues: encodeDefaultFieldValues({
                    HtmlBody: this.htmlBody,
                    Subject: this.emailSubject,
                    RelatedToId: workPlanId,
                    ValidatedFromAddress: 'merchant-support@doordash.com',
                    ToAddress: decisionMakerEmail
                }),
            },
        };
        this[NavigationMixin.Navigate](pageRef);
    }

    /**
    * @description it is used to cancel the selection of store account.
    */
    cancelModalBox() {
        this.storeAccountSelectionScreen = false;
        this.selectedStoreAccount = NONE_OPTION;
    }

    /**
    * @description this is a handler for store account selection change.
    */
    handleStoreChange(event) {
        this.selectedStoreAccount = event.detail.value;
        this.isNextDisabled = this.selectedStoreAccount == NONE_OPTION ? true : false;
    }

    /**
    * @description this is a handler for next button. This hides select store account screen and call standard send email component.
    */
    handleNextAction(event) {
        this.storeAccountSelectionScreen = false;
        this.updateWorkPlanEmailReferenceId(this.findWorkPlanId(this.selectedStoreAccount));
        this.navigateToEmail(this.findWorkPlanId(this.selectedStoreAccount), this.findDecisionMakerEmail(this.selectedStoreAccount));
    }

    /**
    * @description It is used to show toast error.
    */
    showToastError(title, message, variant) {
        // Dispatch Toast Error
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    updateWorkPlanEmailReferenceId(childWorkPlan) {
        updateEmailReferenceId({ workplanId: childWorkPlan })
            .then(result => {
                console.log(result);
            })
            .catch((error) => {
                console.log(error);
            });
    }
}