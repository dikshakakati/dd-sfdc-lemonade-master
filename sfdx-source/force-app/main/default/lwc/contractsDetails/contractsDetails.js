import { LightningElement, api, track } from 'lwc';
import createAmendmentFromOpportunity from "@salesforce/apex/AmendmentServiceImpl.createAmendmentFromOpportunity";
import createLog from "@salesforce/apex/LogController.createLog";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const HANDLE_AMENDMENT = "handleAmendButton";
const LWC_NAME = "ContractsDetails";
const TRUE_FLAG = true;
const CORE_PRODUCT_TAB = "Core Products";
export default class ContractsDetails extends NavigationMixin(LightningElement) {
    @api columns = [];
    @api tabName;
    @api rowsToBeDisplayed = [];
    @api recordId;
    @api disableChangeRates = false;
    @api initiatedFrom;
    @track passcontractid;
    @track passaccountid;
    @track showChangeRatePopup = false;
    @api tabIdentifier;
    showComponent = TRUE_FLAG;
    sampleText = 'Component to be placed';
    loadingHelpText = 'Please wait while the record gets created.';
    @api businessAccountId;
    @api isCustomerSegmentSmb;

    /**
    * @description this will dynamically increase column span
    */
    get expandedColsLength() {
        return this.columns.length + 2;
    }

    /**
     * @description this will provide accordion title and provide disabled title, if the current tab is Ads & Promo.
     */
    get accordionTitle() {
        return this.tabIdentifier == CORE_PRODUCT_TAB
            ? "Accordion Enabled"
            : "Accordion Disabled";
    }

    /**
     * @description this will check whether component initiated from account or not
     */
    get isAccount() {
        return this.initiatedFrom === "Account";
    }

    /**
     * @description this is responsible to open the accordion.
     */
    accordionHandler(event) {
        if ((this.tabIdentifier == CORE_PRODUCT_TAB && !this.isCustomerSegmentSmb) || this.isCustomerSegmentSmb) {
            let index = parseInt(event.target.dataset.rowIndex, 10);
            this.rowsToBeDisplayed = this.rowsToBeDisplayed.map((row, i) =>
                i == index
                    ? {
                        ...row,
                        isAccordionExtended:
                            !this.rowsToBeDisplayed[index].isAccordionExtended
                    }
                    : row
            );
        }
    }

    /**
     * @description show change rate popup
     */
    handleShowChangeRate(event) {
        this.passcontractid = event.target.dataset.contractId;
        this.passaccountid = this.recordId;
        this.showChangeRatePopup = true;
    }

    /**
     * @description close change rate popup
     */
    handleCloseChangeRate() {
        this.showChangeRatePopup = false;
        this.showComponent = TRUE_FLAG;
    }

    /**
     * @description this is the handler for contract amend button.
     */
    handleAmendButton(event) {
        this.showComponent = false;
        const contractId = event.target.dataset.contractId;
        createAmendmentFromOpportunity({
            opportunityId: this.recordId,
            contractId: contractId
        })
            .then((result) => {
                if (result) {
                    let amendResult = JSON.parse(result);
                    if (amendResult.isSuccessful == TRUE_FLAG) {
                        this.navigateToWebPage(amendResult.quoteId);
                    }
                    else {
                        this.showToast('Error', amendResult.message, 'error');
                    }
                    this.showComponent = TRUE_FLAG;
                }

            })
            .catch((error) => {
                this.error = error;
                createLog({
                    lwcName: LWC_NAME,
                    methodName: HANDLE_AMENDMENT,
                    message: JSON.stringify(error)
                });
            });
    }

    /**
    * @description this is the method to navigate to quote line editor.
    */
    navigateToWebPage(quoteId) {
        // Navigate to a quote line editor URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/sbqq__sb?id=' + quoteId
            }
        },
            TRUE_FLAG
        );
    }

    /**
    * @description this is the generic method to show toast message.
    */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);

    }
}