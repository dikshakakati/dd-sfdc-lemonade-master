import { LightningElement, api, wire, track } from 'lwc';
import validateQuoteForSSMO from '@salesforce/apex/RESSMOEligibilityController.quoteEligibilityForRESSMO';
import validateContractForSSMO from '@salesforce/apex/RESSMOEligibilityController.contractEligibilityForRESSMO';
import { getRecord } from 'lightning/uiRecordApi';
import RESSMO_BankingInfo_Note from '@salesforce/label/c.RESSMO_Eligibility_Info_BankingPopulated';
import RESSMO_BankingInfo_Warning from '@salesforce/label/c.RESSMO_Eligibility_Warning_BankingNotPopulated';
import ID_CONTRACT_OBJECT from '@salesforce/schema/Contract.Id';
import updateRecordWithNewStoreId from '@salesforce/apex/RESSMOEligibilityController.updateRecordWithNewStoreId';
import getStoresAccount from '@salesforce/apex/RESSMOEligibilityController.getStoresToPrepopulate';

const QUOTE_STATUS_OUT_FOR_SIGNATURE = 'Out for Signature';
const QUOTE_STATUS_CONTRACT_SIGNED = 'Contract Signed';
const OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
const QUOTE_STATUS_APPROVED = 'Approved';

const CONTRACT_OBJECT = "Contract";
const QUOTE_OBJECT = "SBQQ__Quote__c";
const LWC_UI_LOCATION_VISIBLE = 'ContractTab|QuotePage';
const LWC_UI_LOCATION_Hidden = 'ContractPage';
const ELIGIBILITY_SECTION_LABEL = 'Eligibility Details'

export default class DisplaySSMOEligibilityForQuote extends LightningElement {
    label = {
        RESSMO_BankingInfo_Note,
        RESSMO_BankingInfo_Warning
    };
    storeRecordTypeId
    @api recordId;
    @api ui;
    validations;
    SSMOLink;
    showCopySSMOLink = false;
    ShowEligibility = true;
    randomParam = 1;
    bankingInfo = false;
    @track dynamicInitialClasss;
    @track dynamicObjectFields = [];
    objectApiName = '';
    isRefresh = false;
    storeAccount = {};
    activeSection = '';
    contract;
    quote;
    isOpenedFromContract = false;
    loaded = false;
    eligibilitySectionLabel = ELIGIBILITY_SECTION_LABEL;
    storeId;
    showAddStore = false;
    storePresent = false;


    connectedCallback() {
        if (LWC_UI_LOCATION_Hidden.includes(this.ui)) {
            this.dynamicInitialClasss = 'hide';
        }
        else if (LWC_UI_LOCATION_VISIBLE.includes(this.ui)) {
            this.dynamicInitialClasss = 'show';
        }

    }

    @wire(getRecord, { recordId: '$recordId', fields: [ID_CONTRACT_OBJECT] })
    wiredRecord({ data, error }) {
        if (error) {
            console.error(error);
        } else if (data) {
            this.objectApiName = data.apiName;
            this.handleObjectApiNameChange();
        }
    }
    handleObjectApiNameChange() {
        if (this.objectApiName === CONTRACT_OBJECT) {
            this.isOpenedFromContract = true;
            this.ressmoContractEligibility();
        } else if (this.objectApiName === QUOTE_OBJECT) {
            this.ressmoQuoteEligibility();
        }
    }

    ressmoQuoteEligibility() {
        validateQuoteForSSMO({ quoteId: this.recordId, isRefresh: this.isRefresh, randomParam: this.randomParam })
            .then(result => {
                console.log(result);
                if (typeof result !== 'undefined' && result !== null) {
                    this.storeRecordTypeId = result.storeRecordTypeId;
                    this.validations = result.eligibilityMessages;
                    this.bankingInfo = result.bankingInfo;
                    this.storeAccount = result.storeAccount;
                    if (this.storeAccount != null && this.storeAccount != undefined) {
                        this.storeId = this.storeAccount.Id;
                        this.storePresent = true;
                    }
                    this.quote = result.quote;
                    if ((result.quote != null && result.quote != undefined) && (result.storeAccount == null || result.storeAccount == undefined)) {
                        this.showAddStore = true
                        this.getStoreAccount();
                        this.storePresent = false;
                    }
                    if (result.ressmoLink != null &&
                        result.expirationDate != null && result.status == QUOTE_STATUS_APPROVED) {
                        this.ShowEligibility = true;
                        this.showCopySSMOLink = false;
                    }
                    this.SSMOLink = result.ressmoLink;
                    if (result.ressmoLink != null && result.isPrimaryQuote == true && (result.status == QUOTE_STATUS_OUT_FOR_SIGNATURE || result.status == QUOTE_STATUS_CONTRACT_SIGNED || result.oppStageName == OPPORTUNITY_STAGE_CLOSED_WON)) {
                        this.showCopySSMOLink = true;
                        if (result.messages.length === 0) {
                            this.ShowEligibility = false;
                        }
                    }
                } else {
                    console.log(error);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    ressmoContractEligibility() {
        validateContractForSSMO({ contractId: this.recordId, isRefresh: this.isRefresh, randomParam: this.randomParam })
            .then(result => {
                if (typeof result !== 'undefined' && result !== null) {
                    this.contract = result.contract;
                    this.storeRecordTypeId = result.storeRecordTypeId;
                    this.storeAccount = result.storeAccount;
                    if (result.storeAccount == null || result.storeAccount == undefined || this.contract.RESSMO_Store_Account_Id__c == null || this.contract.RESSMO_Store_Account_Id__c == undefined) {
                        this.showAddStore = true;
                        this.storePresent = false;
                    } else {
                        this.storePresent = true;
                    }
                    if (result.refreshUI == true) {
                        window.location.reload();
                    }
                    else {
                        if(result.ressmoLink){
                            this.SSMOLink = result.ressmoLink;
                            this.showCopySSMOLink = true;
                        }
                        else{
                            this.SSMOLink = 'No';
                            this.showCopySSMOLink = false;
                        }
                        this.validations = result.eligibilityMessages;
                    }
                } else {
                    console.log(error);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleConfirm(event) {
        this.loaded = true;
        this.storeId = event.detail.storeId;
        this.showAddStore = false;
        updateRecordWithNewStoreId({ recordId: this.recordId, ressmoStoreId: this.storeId, calledFromContract: this.isOpenedFromContract })
            .then(result => {
                this.storeAccount = result.storeAccount;
                this.refreshEligibility();
                this.loaded = false;
            })
            .catch(error => {
                console.log(error);
            });
    }

    getStoreAccount() {
        this.loaded = true;
        getStoresAccount({ businessAccountId: this.quote.SBQQ__Account__c })
            .then(result => {
                if (result.storeAccount != null || result.storeAccount != undefined) {
                    this.storeAccount = result.storeAccount;
                }
                else {
                    this.storePresent = false;
                }
                this.loaded = false;
            })
            .catch(error => {
                console.log(error);
            });
    }


    //Removed renderComponent() method and added this comment as Git is not recorgnizing the changes

    refreshEligibility() {
        this.SSMOLink = undefined;
        this.validations = undefined;
        this.ShowEligibility = true;
        this.showCopySSMOLink = false;
        this.isRefresh = true;
        this.randomParam = Math.random(); // change the randomParam to force a re-run
        if (this.objectApiName == CONTRACT_OBJECT) {
            this.ressmoContractEligibility();
        } else {
            this.ressmoQuoteEligibility();
        }


    }
    refresh() {
        // This will force a refresh of the @wire
        this.randomParam = Math.random();
    }

    get loadSpinner() {
        return this.validations === undefined || this.loaded;
    }

    get showValidations() {
        return this.validations !== undefined && this.validations.length != 0 && this.showAddStore == false;
    }

    get noValidations() {
        return this.validations !== undefined && this.validations.length == 0;
    }

    get title() {
        if (this.showValidations) {
            return 'Not Eligible for SSMO'
        }
        if (this.noValidations) {
            return 'Eligible for SSMO'
        }
    }

    get titleColor() {
        if (this.showValidations) {
            return 'error-color'
        }
        if (this.noValidations) {
            return 'success-color'
        }
    }

    get flagVariant() {
        if (this.showValidations) {
            return 'error'
        }
        if (this.noValidations) {
            return 'success'
        }
    }

    get showBankingMessage() {
        return this.loadSpinner == false && (this.SSMOLink == null);
    }

    handleToggleSection(event) {
        this.activeSection = event.detail.openSections;
    }

}