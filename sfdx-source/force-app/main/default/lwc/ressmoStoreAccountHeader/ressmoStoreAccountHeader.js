import { LightningElement, api, wire } from 'lwc';
import createLog from "@salesforce/apex/LogController.createLog";
import { CurrentPageReference } from 'lightning/navigation';
import INVALID_STORE_HELPTEXT from '@salesforce/label/c.RESSMO_SendtoSSMO_StoreNotFound';
import getStoreWithActiveXref from '@salesforce/apex/sendSSMOQuickActionController.getStoresWithActiveXref';

const LWC_NAME = 'changeStoreAccount';
const INITIALIZE_METHOD = 'initialize';
const GET_ACTIVE_STORE = 'getStoreWithActiveXref';
const SOURCE_ELLIGIBILITY = 'eligibility';

export default class ressmoStoreAccountHeader extends LightningElement {

  @api recordId;

  @api source;
  @api storeAccount;
  @api quote;
  @api contract
  @api isOpenedFromContract
  @api fetchStoreScreen
  @api isStorePrepopulated;
  @api storeRecordTypeId;
  storeId;
  isRecordPickerDisabled = false;
  storeChangeDisabled = false;
  storeRecordPickerHelpText = INVALID_STORE_HELPTEXT;

  renderedCallback() {
    const accountLabel = this.template.querySelector('.account-label'); console.log('isStorePrepopulated' + this.isStorePrepopulated);
    if (accountLabel) {
      accountLabel.innerHTML = this.accountLabel;
    }
  }

  connectedCallback() {
    if (this.storeAccount === undefined || this.storeAccount === null) {
      this.isRecordPickerDisabled = true;
      this.storeChangeDisabled = true;
    }
    else if (Object.entries(this.storeAccount).length == 0) {
      this.isRecordPickerDisabled = true;
      this.storeChangeDisabled = true;
    }
    else {
      this.storeId = this.storeAccount.Id;
      this.buildFilter(this.quote, this.contract);
    }
  }
  get accountLabel() {
    if (this.isStorePrepopulated === false || !this.storeAccount) {
      return `Please confirm store below for SSMO eligibility`;
    }
    else {
      return !this.storeAccount || Object.keys(this.storeAccount).length === 0 ? `Store Account Details :` : `Store Account Details : <a href="/lightning/r/Account/${this.storeAccount.Id}/view" target="_blank">${this.storeAccount.Name}</a>`;
    }

  }

  get disbaleRefreshIcon() {
    return this.enabledRefresh === "true" ? true : false;
  }


  get accountUrl() {
    return `/lightning/r/Account/${this.accountName}/view`;
  }

  buildFilter(quote, contract) {
    getStoreWithActiveXref({ businessId: this.isOpenedFromContract ? this.contract.AccountId : this.quote.SBQQ__Account__c })
      .then(result => {
        this.filter = {
          criteria: [{
            fieldPath: "ParentId",
            operator: "eq",
            value: this.isOpenedFromContract ? contract.AccountId : quote.SBQQ__Account__c,
          },
          {
            fieldPath: "Ultimate_Parent_Account__c",
            operator: "eq",
            value: this.isOpenedFromContract ? contract.AccountId : quote.SBQQ__Account__c,
          },
          {
            fieldPath: "Coverage__c",
            operator: "eq",
            value: "In Coverage",
          },
          {
            fieldPath: "Address_Verification_Status__c",
            operator: "eq",
            value: "Verified",
          },
          {
            fieldPath: "RecordTypeId",
            operator: "eq",
            value: this.storeRecordTypeId,
          },
          {
            fieldPath: "Id",
            operator: "nin",
            value: !result ? [] : result
          }],
          filterLogic: "(1 OR 2) AND 3 AND 4 AND 5 AND 6",
        }
      })
      .catch(error => {
        console.log(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_ACTIVE_STORE,
          error: JSON.stringify(error)
        })
      })
  }

  onConfirmStoreChange() {
    this.dispatchEvent(new CustomEvent('confirm', {
      detail: {
        storeId: this.storeId
      }
    }));
  }

  handleRefresh() {
    if (this.source === 'eligibility') {
      this.dispatchEvent(new CustomEvent('refresheligibility'));
    } else {
      this.dispatchEvent(new CustomEvent('refreshressmoonboard'));
    }
  }

  fetchStore() {
    if (this.fetchStoreScreen && (this.storeAccount && Object.keys(this.storeAccount).length !== 0)) {
      this.storeChangeDisabled = false;
    }
    this.fetchStoreScreen = !this.fetchStoreScreen;
  }

  handleStoreRecordPicker(event) {
    if (event.detail.recordId == null) {
      this.storeChangeDisabled = true;
    }
    else {
      this.storeChangeDisabled = false;
      this.storeId = event.detail.recordId;
    }
  }

  handleCreateStoreLink(event) {
    event.preventDefault();
    let dynamicFieldString = this.isOpenedFromContract ? `ParentId=${this.contract.AccountId}` : `ParentId=${this.quote.SBQQ__Account__c}`;
    dynamicFieldString = encodeURIComponent(dynamicFieldString);
    const createAccountUrl = `/lightning/o/Account/new?recordTypeId=${this.storeRecordTypeId}&defaultFieldValues=${dynamicFieldString}`;
    window.open(createAccountUrl, '_blank');
  }

  get storeHeaderCSS() {
    if (this.source === SOURCE_ELLIGIBILITY) {
      return 'slds-box slds-box_x-small slds-list_horizontal doordashSectionHeaderEligibility'
    } else {
      return 'slds-box slds-box_x-small slds-text-heading_small slds-list_horizontal doordashSectionHeader'
    }
  }

  get iconSize() {
    if (this.source === SOURCE_ELLIGIBILITY) {
      return 'x-small'
    }
    else {
      return 'small'
    }
  }

}