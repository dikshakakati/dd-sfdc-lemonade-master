import { LightningElement, track, api } from 'lwc';
import createOpportunityAndWorkOrder from "@salesforce/apex/AmendmentServiceImpl.createOpportunityAndWorkOrder";
import createAmendmentFromOpportunity from "@salesforce/apex/AmendmentServiceImpl.createAmendmentFromOpportunity";
import createLog from "@salesforce/apex/LogController.createLog";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const UPGRADE = "Upgrade";
const DOWNGRADE = "Downgrade";

const HANDLE_NEXT = "handleNext";
const HANDLE_FINAL_NEXT = "handleFinalNext";
const LWC_NAME = "ChangeRatePopup";
const TRUE_FLAG = true;

export default class ChangeRatePopup extends NavigationMixin(LightningElement) {
    @api accountid;
    @api contractid;
    @track recordId;
    @track ismodalopen = false;
    @track showForm = true;
    @track opportunitySubType;
    @track opportunityLink;
    @track newOpportunityId;
    @track newWorkorderId;
    @track workOrderLink;
    @track isLoading = false;
    @track messageText;

    picklistOptions = [
        { label: UPGRADE, value: UPGRADE },
        { label: DOWNGRADE, value: DOWNGRADE }
    ];

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
        this.ismodalopen = false;
        this.showForm = true;
        this.showConfirmation = false;
    }

    handleInputChange(event) {
        this.opportunitySubType = event.detail.value;
    }

    handleNext() {
        if (this.opportunitySubType !== undefined && this.opportunitySubType != null) {
            this.isLoading = true;
            createOpportunityAndWorkOrder({ opportunitySubType: this.opportunitySubType, accountId: this.accountid, contractId: this.contractid })
                .then(result => {
                    if (result.error) {
                        const errorMessage = JSON.parse(result.error);
                        this.isLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: errorMessage.message,
                                variant: 'error'
                            })
                        );
                        return;
                    }

                    this.newOpportunityId = result.opportunityId;
                    this.newWorkorderId = result.opportunityId;
                    return Promise.all([
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result.opportunityId,
                                actionName: 'view'
                            }
                        }),
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result.workOrderId,
                                actionName: 'view'
                            }
                        })
                    ]);
                })
                .then(urls => {
                    this.opportunityLink = urls[0];
                    this.workOrderLink = urls[1];
                    if (this.newOpportunityId != null && this.newWorkorderId != null) {
                        this.isLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Opportunity and Work Order created successfully',
                                variant: 'success'
                            })
                        );
                        this.handleFinalNext();
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: HANDLE_NEXT,
                        message: JSON.stringify(error)
                    });
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while creating records: ' + error.body.message,
                            variant: 'error'
                        })
                    );
                });
        }
    }

    handleFinalNext() {
        this.isLoading = true;
        createAmendmentFromOpportunity({ opportunityId: this.newOpportunityId, contractId: this.contractid })
            .then(result => {
                this.closeModal();
                this.isLoading = false;
                if (result) {
                    let amendResult = JSON.parse(result);
                    if (amendResult.isSuccessful == TRUE_FLAG) {
                        this.navigateToWebPage(amendResult.quoteId);
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: amendResult.message,
                                variant: 'error'
                            })
                        );
                    }
                }
            })
            .catch((error) => {
                this.error = error;
                createLog({
                    lwcName: LWC_NAME,
                    methodName: HANDLE_FINAL_NEXT,
                    message: JSON.stringify(error)
                });
            });
    }

    /**
    * @description this is the  method to navigate to the quote line editor.
    */
    navigateToWebPage(quoteId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/sbqq__sb?id=' + quoteId
            }
        },
            TRUE_FLAG
        );
        this.messageText = 'Here is the {0} and the {1} that have been created for this Rate Change.';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: this.messageText,
                "messageData": [
                    {
                        url: this.opportunityLink,
                        label: 'Opportunity'
                    },
                    {
                        url: this.workOrderLink,
                        label: 'Work Order'
                    }
                ],
                variant: 'success',
                mode: 'sticky'
            })
        );
    }
}