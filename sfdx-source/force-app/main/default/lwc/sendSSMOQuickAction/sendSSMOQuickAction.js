import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRecordsFromSSMOUI from '@salesforce/apex/SendSSMOQuickActionController.updateRecordsFromSSMOUI';
import initializeSendToSSMO from '@salesforce/apex/SendSSMOQuickActionController.initializeSendToSSMO';
import sendToSSMOQuoteUI from '@salesforce/apex/SendSSMOQuickActionController.sendToSSMOQuoteUI';
import generateMxRRelatedRecord from '@salesforce/apex/SendSSMOQuickActionController.generateMxLinkRecord'
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import HEADER_TEXT from '@salesforce/label/c.RESSMO_SendtoSSMO_HeaderText';
import INVALID_STORE_HELPTEXT from '@salesforce/label/c.RESSMO_SendtoSSMO_StoreNotFound';
import SSMO_NOT_ELIGIBLE from '@salesforce/label/c.RESSMO_SendtoSSMO_QuoteNotEligible';
import EMAIL_CHANGE_CONFIRMATION_MESSAGE from '@salesforce/label/c.RESSMO_SendtoSSMO_EmailChangeConfirmationMessage';
import getStoreDetailsByStoreId from '@salesforce/apex/SendSSMOQuickActionController.getStoreDetailsByStoreId';
import sendSSMOFromContract from '@salesforce/apex/SendSSMOQuickActionController.sendToSSMOContractUI';
import RESSMO_STORE_ID_QUOTE from '@salesforce/schema/SBQQ__Quote__c.RESSMO_Store_Account_Id__c';
import QUOTE_ID from '@salesforce/schema/SBQQ__Quote__c.Id'
import CONTRACT_ID from '@salesforce/schema/Contract.Id';
import RESSMO_STORE_ID_CONTRACT from '@salesforce/schema/Contract.RESSMO_Store_Account_Id__c';
import RESSMO_BankingInfo_Note from '@salesforce/label/c.RESSMO_Eligibility_Info_BankingPopulated';
import RESSMO_BankingInfo_Warning from '@salesforce/label/c.RESSMO_Eligibility_Warning_BankingNotPopulated';
import createLog from "@salesforce/apex/LogController.createLog";

const TOAST_INFO_VARIANT = "info";
const TOAST_ERROR_VARIANT = "error";
const TOAST_SUCCESS_VARIANT = "success";
const TOAST_SUCCESS_TITLE = "Success";
const TOAST_ERROR_TITLE = "Error";
const TOAST_NOT_ELIGIBLE_TITLE = 'Not Eligible';
const CONTACT_OBJECT = "Contact";
const ACCOUNT_OBJECT = "Account";
const CONTRACT_OBJECT = "Contract";
const PAYMENT_ACCOUNT_OBJECT = 'Payment_Account__c';
const LWC_NAME = 'SendSSMOQuickAction';
const UPDATE_METHOD = 'updateRecordsFromSSMOUI';
const GENERATE_MX_REALTED_METHOD = 'generateMxRRelatedRecord';
const SEND_METHOD = 'sendToSSMOQuoteUI';
const SEND_METHOD_FROM_CONTRACT = 'sendSSMOFromContract';
const INITIALIZE_METHOD = 'initialize';
const CHANGE_STORE_METHOD = 'getStoreDetailsByStoreId';
const INVALID_PAYMENT_ACCOUNT = 'N/A';
const INVALID_STORE_ACCOUNT = 'No store account found.'
const INVALID_CONTACT = 'No contract signatory found.'
const CONFIRMATION_SCREEN = 'confirmation';
const EDIT_SCREEN = 'edit';
const ACTIVE_MX_LINK_SCREEN = 'activeMxLink'
const GENERIC_ERROR_SCREEN = 'error';
const COUNTRY_FOR_ACCOUNT_ROUTING_LEGALBUSINESSNAME_VALIDATIONS = 'Australia,United States,Canada';
const COUNTRY_FOR_ACCOUNT_NUMBER_VALIDATION = 'New Zealand';
const PAYMENT_SECTION_ACCOUNT_FIELDS = 'Legal_Business_Name__c,TaxID__c,Id';
const TABLET_DELIVERY_METHOD_REQUIRED_FOR = 'Tablet (DoorDash Owns),Tablet and Printer (DoorDash Owns)';
const LIMIT_NUMBER_OF_STORES_ERROR_MESSAGE = 'Deals with Number of Stores above 3 are not supported';

//Section Name
const CONTACT_SECTION = 'Contract Signatory';
const QUOTE_SECTION = 'RESSMO Details';
const STORE_HOURS_SECTION = 'Store Hours';
const PHOTOSHOOT_CONTACT = 'Photoshoot Contact'
const PAYMENT_ACCOUNT = 'Payment Account';

export default class SendSSMOQuickAction extends LightningElement {

  @api recordId;
  @api objectApiName;
  isOpenedFromContract = false;

  //banking info variables
  bankingInfo = false;
  label = {
    RESSMO_BankingInfo_Note,
    RESSMO_BankingInfo_Warning
  };

  //section name
  contactSection = CONTACT_SECTION;
  quoteSection = QUOTE_SECTION;
  storeHoursSection = STORE_HOURS_SECTION;
  photoshootContactSection = PHOTOSHOOT_CONTACT;
  paymentAccountSection = PAYMENT_ACCOUNT;

  //recordTYpe
  storeRecordTypeId;

  //data used in UI
  @track uiErrorMessages = [];
  @track storeAccount = {};
  @track mxOnboardingLinkId = null;
  @track quote = {};
  @track contact = {};
  @track contract = {};
  @track photoshootContact = {};
  @track eligibilityMessages;
  @track allInputMetadata = {};
  @track businessAccount = {};
  @track paymentAccount = {};
  paymentAccountLink;
  decisionMakerBefore = {};

  //booleans to handle logics
  showComponent = false;
  showEmailChangeConfirmation = false;
  accountLoad = false;
  contactLoad = false;
  photoshootLoad = false;
  quoteLoad = false;
  storeHoursLoad = false;
  isUUIdPresent = false;
  isChecked = false;
  isQuickSaveNotInitated = true;
  isLatestquickSave = true;
  isEmailUpdated = false;
  isStoreHoursValid = true;
  showUIError = false;
  fetchStoreScreen = false;
  storeChangeDisabled = false;
  isOrderProtocolPOS;
  isEligibile = true;
  isRecordPickerDisabled = false;
  iscontactRoleFound;
  isStoreFound;
  errorMessage;
  reloadAccountHeader = true;
  showPaymentForm = false;

  //toggles
  samePhotoshootAndContact = false;

  //invalid/not found data text
  invalidStore = INVALID_STORE_ACCOUNT;
  invalidContact = INVALID_CONTACT;
  invalidPaymentAccount = INVALID_PAYMENT_ACCOUNT;

  //custom Labels
  headerText = HEADER_TEXT;
  emailConfirmText = EMAIL_CHANGE_CONFIRMATION_MESSAGE;
  invalidStoreHelpText = INVALID_STORE_HELPTEXT;

  //objectApiNames
  accountObjectApi = ACCOUNT_OBJECT;
  contactObjectApi = CONTACT_OBJECT;
  quoteObjectApi = QUOTE_OBJECT;

  SSMO_link;
  storeId;
  brandFilter;

  //soumya change
  genericInputs = {};

  //current Screen variable
  screenName = EDIT_SCREEN;

  connectedCallback() {
    this.initializeData();
  }

  handleRefresh() {
    this.showComponent = false;
    this.resetBooleanParamentrers();
    this.initializeData();
  }


  initializeData() {
    setTimeout(() => {
      this.isOpenedFromContract = this.objectApiName == 'Contract' ? true : false;
      var openedFrom = this.isOpenedFromContract ? 'Contract' : 'Quote';
      initializeSendToSSMO({ recordId: this.recordId, openedFrom: openedFrom })
        .then((data) => {

          if (this.isOpenedFromContract && data.hasMxOnboardingLink) {
            this.screenName = ACTIVE_MX_LINK_SCREEN;
            this.mxOnboardingLinkId = data.hasMxOnboardingLink.Id;
            this.showComponent = true;
          }
          else {
            let objectWrapper = data.objectWrapper;
            this.allInputMetadata = data.sectiontoInputMetadata;
            this.storeRecordTypeId = data.storeRecordTypeId;
            this.quote = objectWrapper.quote;

            //Store account
            if (!objectWrapper.hasOwnProperty('storeAccount')) {
              this.isRecordPickerDisabled = true;
              this.storeChangeDisabled = true;
              this.accountLoad = true;
              this.isOrderProtocolPOS = true;
              this.storeHoursLoad = true;
              this.isStoreFound = false;
              this.isLatestquickSave = false;
            }
            else {
              this.checkBankingInfoPopulated(objectWrapper);
              this.paymentAccount = objectWrapper.paymentAccount ? objectWrapper.paymentAccount : {};
              this.isRecordPickerDisabled = false;
              this.storeChangeDisabled = false;
              if (objectWrapper.hasOwnProperty('photoshootContact')) {
                this.photoshootContact = objectWrapper.photoshootContact;
              }
              objectWrapper.storeAccount.Order_Protocol__c == 'POS' ? (this.isOrderProtocolPOS = true, this.storeHoursLoad = true) : this.isOrderProtocolPOS = false;
              this.isStoreFound = true;
              this.storeId = objectWrapper.storeAccount.Id;
              this.storeAccount = objectWrapper.storeAccount;
            }

            //Contract signatory
            if (!objectWrapper.hasOwnProperty('contact')) {
              this.contactLoad = true;
              this.iscontactRoleFound = false;
              this.isLatestquickSave = false;
            }
            else {
              this.iscontactRoleFound = true;
              this.contact = objectWrapper.contact;
              Object.assign(this.decisionMakerBefore, objectWrapper.contact);
            }
            this.showComponent = true;
            this.iscontactRoleFound == true ? ((objectWrapper.contact.Unique_Identifier__c != null || objectWrapper.contact.Unique_Identifier__c != undefined) ? this.isUUIdPresent = true : null) : null;

            //genric input initialization
            if (objectWrapper.hasOwnProperty('genericInput')) {
              this.genericInputs = objectWrapper.genericInput;
            }
            else {
              this.genericInputs = Object.fromEntries(
                Object.keys(this.allInputMetadata).map(currentItem => {
                  return [currentItem, {}];
                })
              );
            }
            if (this.isOpenedFromContract) {
              this.contract = objectWrapper.contract;
              this.brandFilter = this.createBrandRecordPickerFilter(objectWrapper.contract.Contract_Brand_Associations__r)
              this.mxOnboardingLinkId = objectWrapper.mxOnboardingLinkId;
              !this.genericInputs.Quote.SSMOExpirationDate ? this.genericInputs.Quote.SSMOExpirationDate = this.addDaysToSSMOExpiration(new Date(), 14) : null;
              !this.genericInputs.Quote.NumberOfStores ? this.genericInputs.Quote.NumberOfStores = this.contract.Number_of_Stores__c : null;
            }
          }
        })
        .catch((error) => {
          console.log(JSON.stringify(error));
          createLog({
            lwcName: LWC_NAME,
            methodName: INITIALIZE_METHOD,
            error: JSON.stringify(error)
          })
        })
    }, 4);
  }

  /**
  * @description brand record picker filter
  */
  createBrandRecordPickerFilter(listRecords) {
    let filter;
    let brandIds = listRecords == undefined ? [] : listRecords.map(currItem => {
      return currItem.Brand__r.Id
    })
    if (!brandIds.includes(this.storeAccount.Brand__c)) {
      this.storeAccount.Brand__c = '';
    }
    filter = {
      criteria: [
        {
          fieldPath: "Id",
          operator: "in",
          value: brandIds
        }
      ]
    }
    return filter;
  }

  /**
  * @description add days to a given date
  */
  addDaysToSSMOExpiration(Date, days) {
    Date.setDate(Date.getDate() + days);
    const year = Date.getFullYear();
    let month = Date.getMonth() + 1;
    let date = Date.getDate();
    date = date < 10 ? '0' + date : date;
    month = month < 10 ? '0' + month : month;
    return `${year}-${month}-${date}`;
  }


  /**
  * @description - pencil icon click handler
  */
  fetchStore() {
    if (this.fetchStoreScreen) {
      this.storeChangeDisabled = false;
    }
    this.fetchStoreScreen = !this.fetchStoreScreen;
  }


  /**
  * @description - handle confirm button for store change
  */
  onConfirmStoreChange(event) {
    this.storeId = event.detail.storeId;
    const fields = {};
    this.isOpenedFromContract ? fields[CONTRACT_ID.fieldApiName] = this.recordId : fields[QUOTE_ID.fieldApiName] = this.recordId;
    this.isOpenedFromContract ? fields[RESSMO_STORE_ID_CONTRACT.fieldApiName] = this.storeId : fields[RESSMO_STORE_ID_QUOTE.fieldApiName] = this.storeId;
    this.isOpenedFromContract == false ? this.quote.RESSMO_Store_Account_Id__c = this.storeId : this.contract[RESSMO_STORE_ID_CONTRACT.fieldApiName] = this.storeId;
    const recordInput = { fields };

    this.showComponent = false;
    updateRecord(recordInput)
      .then(() => {
        this.handleSelectionChange();
      })
      .catch(error => {
        this.showComponent = true;
        console.log(JSON.stringify(error));
      })
  }

  /**
  * @description - when store is changes from record picker re-Initialize variables
  */
  handleSelectionChange() {
    var businessAccountId = this.isOpenedFromContract ? this.contract.AccountId : this.quote.SBQQ__Account__c;
    let uiInputMetadata = [...this.allInputMetadata.Account, ...this.allInputMetadata.Contact];
    getStoreDetailsByStoreId({ storeId: this.storeId, businessId: businessAccountId, uiInputs: uiInputMetadata })
      .then(result => {
        this.resetBooleanParamentrers();
        this.storeAccount = result.storeAccount;
        this.paymentAccount = result.paymentAccount ? result.paymentAccount : {};
        this.checkBankingInfoPopulated(result);
        this.iscontactRoleFound == false ? null : Object.assign(this.contact, this.decisionMakerBefore);
        this.iscontactRoleFound == false ? (this.contactLoad = true, this.isLatestquickSave = false) : this.contactLoad = false;
        result.hasOwnProperty('photoshootContact') ? this.photoshootContact = result.photoshootContact : this.photoshootContact = {};
        this.storeHoursLoad = false;
        this.showComponent = true;
        result.storeAccount.Order_Protocol__c == 'POS' ? (this.isOrderProtocolPOS = true, this.storeHoursLoad = true) : this.isOrderProtocolPOS = false;
      })
      .catch(error => {
        console.log(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: CHANGE_STORE_METHOD,
          error: JSON.stringify(error)
        })
      })
  }

  resetBooleanParamentrers() {
    this.samePhotoshootAndContact = false;
    (!this.isPhotoshootContactFound && (this.photoshootContact = {}));
    this.showPaymentForm = false;
    this.isEligibile = true;
    this.fetchStoreScreen = false;
    this.accountLoad = false;
    this.photoshootLoad = false;
    this.quoteLoad = false;
    this.isEmailUpdated = false;
    this.isChecked = false;
    this.isStoreHoursValid = true;
    this.showUIError = false;
    this.isLatestquickSave = true;
    this.showEmailChangeConfirmation = false;
  }


  /**
  * @description getter to show spinner untill all forms are loaded
  */
  get editScreenSpinner() {
    return this.accountLoad && this.contactLoad && this.photoshootLoad && this.quoteLoad && this.storeHoursLoad && this.isQuickSaveNotInitated;
  }

  /**
  * @description - Controls screens to show on UI
  */
  get editScreen() {
    return this.screenName == EDIT_SCREEN ? true : false;
  }

  get confirmationScreen() {
    return this.screenName == CONFIRMATION_SCREEN ? true : false;
  }

  get errorScreen() {
    return this.screenName == GENERIC_ERROR_SCREEN ? true : false;
  }

  get activeMxLinkScreen() {
    return this.screenName == ACTIVE_MX_LINK_SCREEN ? true : false;
  }

  /**
  * @description getter for submit button
  */
  get isSubmitDisabled() {
    return !this.isLatestquickSave;
  }

  /**
  * @description getter for quic Save button
  */
  get isQuickSaveDisabled() {
    if (this.showEmailChangeConfirmation) {
      return this.isChecked == false ? true : false;
    }
    else {
      return false;
    }
  }

  get isPhotoshootAndContractSignatorySame() {
    if (this.photoshootContact) {
      return this.contact.Id === this.photoshootContact.Id ? true : false;
    }
    return false;
  }

  /**
  * @description getter for account section title
  */
  get accountLabel() {
    let storeAccountName = this.storeAccount.Name != undefined ? this.storeAccount.Name : '';
    return 'Store Account Details : ' + storeAccountName;
  }

  /**
  * @description getter for metadata of fields and send to child compoenent
  */
  get accountMetadata() {
    return this.allInputMetadata.Account;
  }
  get contactMetadata() {
    return this.allInputMetadata.Contact;
  }
  get quoteMetadata() {
    return this.allInputMetadata.Quote;
  }
  get photoshootMetadata() {
    return this.allInputMetadata.Photoshoot;
  }
  get isPaymentAccountFound() {
    if (Object.keys(this.paymentAccount).length !== 0 && this.paymentAccount.Id) {
      this.paymentAccountLink = `${window.location.origin}/${this.paymentAccount.Id}`;
      return true;
    }
    return false;
  }
  get isPhotoshootContactFound() {
    if (Object.keys(this.photoshootContact).length !== 0 && this.photoshootContact.Id) {
      return true;
    }
    return false;
  }
  get businessAccountId() {
    return this.isOpenedFromContract ? this.contract.AccountId : this.quote.SBQQ__Account__c;
  }

  /**
  * @description method to determine height of page.
  */
  get heightCSS() {
    return "height: 60vh;";
  }

  /**
 * @description handle generipc input value changes
 */
  handleGenericValueChange(event) {
    this.isLatestquickSave = false;
    this.genericInputs[event.detail.section] = event.detail.genericdata;
  }

  /**
  * @description disable confirm and submit on any change in store hours
  */
  handleStoreHoursChange() {
    this.isLatestquickSave = false;
  }


  /**
  * @description handle Photoshoot Contract Signatory Same toggle button
  */
  handlePhotoshootContractSignatoryToggle() {
    this.isLatestquickSave = false;
    this.samePhotoshootAndContact = !this.samePhotoshootAndContact;
    this.photoshootContact = Object.keys(this.contact).reduce((acc, key) => {
      if (key !== 'Id') {
        acc[key] = this.contact[key];
      }
      return acc;
    }, {});
    if (!this.samePhotoshootAndContact) {
      this.photoshootContact = {};
    }
    console.log(this.photoshootContact);
  }


  /**
  * @description handle payment toggle button
  */
  handlePaymentToggle() {
    this.isLatestquickSave = false;
    this.showPaymentForm = !this.showPaymentForm;
  }

  /**
  * @description handle payment account section change
  */
  handlePaymentAccountChange(event) {
    this.isLatestquickSave = false;
    let objectApiName = event.target.dataset.objectapi;
    let fieldName = event.target.dataset.fieldname;
    if (objectApiName === PAYMENT_ACCOUNT_OBJECT) {
      this.paymentAccount[fieldName] = event.target.value;
    }
    else if (objectApiName === 'Store Account') {
      this.storeAccount[fieldName] = event.target.value;
    }
  }

  /**
  * @description method to handle chnage in fields value in child componenent
  */
  handleValueChange(event) {
    this.isLatestquickSave = false;
    const fieldName = event.detail.fieldModified
    const objectrec = event.detail.objectrec;
    const objectAPIName = event.detail.objectapiname;
    if (objectAPIName == this.accountObjectApi) {
      this.storeAccount[fieldName] = objectrec[fieldName];
      if (fieldName == 'Order_Protocol__c') {
        if (this.storeAccount[fieldName] == 'POS') {
          this.isOrderProtocolPOS = true;
          this.storeHoursLoad = true;
        }
        else {
          this.isOrderProtocolPOS = false;
        }
      }
    }
    if (objectAPIName == 'SBQQ__Quote__c') {
      this.quote[fieldName] = objectrec[fieldName];
    }
    if (objectAPIName == this.contactObjectApi) {
      if (this.isPhotoshootAndContractSignatorySame) {
        this.contact[fieldName] = objectrec[fieldName];
        this.photoshootContact[fieldName] = objectrec[fieldName];
      }
      else {
        event.detail.isPhototshoot == true ? this.photoshootContact[fieldName] = objectrec[fieldName] : this.contact[fieldName] = objectrec[fieldName];
      }
      if (fieldName == 'Email' && !event.detail.isPhototshoot) {
        if (this.contact.Email != this.decisionMakerBefore.Email && this.isUUIdPresent) {
          this.showEmailChangeConfirmation = true;
          this.isEmailUpdated = true;
          this.isChecked == true ? null : this.isChecked = false;
        }
        else {
          this.showEmailChangeConfirmation = false;
          this.isEmailUpdated = false;
          this.isChecked = false;
        }
      }
    }
  }

  /**
  * @description handle brand record picker change
  */
  handleBrandRecordPickerChange(event) {
    this.isLatestquickSave = false;
    this.storeAccount.Brand__c = event.detail.Id == null ? '' : event.detail.Id;
  }

  /**
  * @description handle email check box event
  */
  handleCheckBoxChange(event) {
    return event.target.checked ? this.isChecked = true : this.isChecked = false;
  }

  /**
  * @description method to handle apex controller api error and enable error screen
  */
  handleApexError(error) {
    console.log(error);
    if (error[0].includes(this.storeAccount.Id)) {
      error = '{"message": "HTTP POST on resource \'https://internal-dd-dev-lb.lb.anypointdns.net:443/mx-services-sys-api-dd-int/api/offers\' failed: internal server error (500).{\n  \"message\": \"SSMO was unsuccessful for this case, please try again one more time before switching to Pactsafe.\"\n}"}'
    }
    this.errorMessage = error;
    this.showComponent = true;
    this.screenName = GENERIC_ERROR_SCREEN;
  }

  /*
  * @description close error icon in footer
  */
  closeUIError() {
    this.showUIError = false;
  }

  /**
  * @description method to validate required fields etc before sending for update and enable error icon
  */
  validateFields() {
    this.uiErrorMessages.splice(0, this.uiErrorMessages.length);
    let allValid = true;


    //dynamic validation
    this.allInputMetadata.Account.forEach(metadata => {
      if (metadata.Validation__c == 'Required on UI' && (this.storeAccount[metadata.Field_API_Name__c] == '' || !this.storeAccount.hasOwnProperty(metadata.Field_API_Name__c))) {
        this.uiErrorMessages.push(metadata.UI_Validation_Message__c);
        allValid = false;
      }
    })

    this.allInputMetadata.Contact.forEach(metadata => {
      if (metadata.Validation__c == 'Required on UI' && (this.contact[metadata.Field_API_Name__c] == '' || !this.contact.hasOwnProperty(metadata.Field_API_Name__c))) {
        this.uiErrorMessages.push(metadata.UI_Validation_Message__c);
        allValid = false;
      }
    })

    this.allInputMetadata.Quote.forEach(metadata => {
      if (metadata.Validation__c == 'Required on UI' && (this.quote[metadata.Field_API_Name__c] == '' || !this.quote.hasOwnProperty(metadata.Field_API_Name__c))) {
        this.uiErrorMessages.push(metadata.UI_Validation_Message__c);
        allValid = false;
      }
    })

    //Email Format Validation
    if (this.contact.hasOwnProperty('Email') && this.contact['Email'] != '' && this.contact.Email.match(/[A-Za-z0-9\._%+\-]+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,}/) === null) {
      this.uiErrorMessages.push('Email');
      allValid = false;
    }

    //Photoshoot contact validations
    if (this.photoshootContact.LastName || this.photoshootContact.Email) {
      if (!this.photoshootContact.Email || this.photoshootContact.Email.match(/[A-Za-z0-9\._%+\-]+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,}/) === null) {
        this.uiErrorMessages.push('Email (Photoshoot Contact)');
        allValid = false;
      }
      if (!this.photoshootContact.LastName) {
        this.uiErrorMessages.push('Last Name (Photoshoot Contact)');
        allValid = false;
      }
    }

    if (this.isOpenedFromContract) {
      //order protocol email validation
      if (this.storeAccount.hasOwnProperty('Order_Protocol_Email__c') && this.storeAccount['Order_Protocol_Email__c'] != '' && this.storeAccount.Order_Protocol_Email__c.match(/[A-Za-z0-9\._%+\-]+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,}/) === null) {
        this.uiErrorMessages.push('Order Protocol Email');
        allValid = false;
      }

      //SSMO Expiration Date Contract
      this.validateSSMOExpirationDate(this.genericInputs.Quote, 'SSMOExpirationDate') == false ? allValid = false : null;

      //Number of Stores Contract
      if (this.genericInputs.Quote.NumberOfStores > 3) {
        this.uiErrorMessages.push(LIMIT_NUMBER_OF_STORES_ERROR_MESSAGE);
        allValid = false;
      }
    }
    else {
      //SSMO Expiration Date Quote
      this.validateSSMOExpirationDate(this.quote, 'SSMO_Expiration_Date__c') == false ? allValid = false : null;

      //Number of Stores Quote
      if (this.quote.Number_of_Stores__c > 3) {
        this.uiErrorMessages.push(LIMIT_NUMBER_OF_STORES_ERROR_MESSAGE);
        allValid = false;
      }
    }

    //store hours valid input validation
    if (this.isOrderProtocolPOS) {
      this.isStoreHoursValid = true;
    }
    else if (!this.isStoreHoursValid) {
      this.uiErrorMessages.push('Store Hours');
      allValid = false;
    }

    //payment account (already present)
    if (!this.storeAccount.Legal_Business_Name__c || this.storeAccount.Legal_Business_Name__c == '') {
      this.uiErrorMessages.push('Legal business name');
      allValid = false;
    }
    if (this.showPaymentForm) {
      //creating case
      if (COUNTRY_FOR_ACCOUNT_ROUTING_LEGALBUSINESSNAME_VALIDATIONS.includes(this.storeAccount.BillingCountry)) {
        if ((!this.paymentAccount.Bank_Account_Number__c || this.paymentAccount.Bank_Account_Number__c == '') || (!this.paymentAccount.RoutingNumber__c || this.paymentAccount.RoutingNumber__c == '')) {
          this.uiErrorMessages.push('Bank account number,Routing number is required when country is United States,Australia,Canada');
          allValid = false;
        }
      }
      if (COUNTRY_FOR_ACCOUNT_NUMBER_VALIDATION.includes(this.storeAccount.BillingCountry)) {
        if (!this.paymentAccount.Bank_Account_Number__c || this.paymentAccount.Bank_Account_Number__c == '') {
          this.uiErrorMessages.push('Bank account number is required when country is New Zealand');
          allValid = false;
        }
      }
    }

    //OrderProtocol Tablet
    if (TABLET_DELIVERY_METHOD_REQUIRED_FOR.includes(this.storeAccount.Order_Protocol__c) && (!this.storeAccount.Tablet_Delivery_Method__c || this.storeAccount.Tablet_Delivery_Method__c == '')) {
      this.uiErrorMessages.push('Tablet Delivery Method');
      allValid = false;
    }

    if (!allValid) {
      this.showUIError = true;
      return false;
    }
    else {
      this.showUIError = false;
      return true;
    }
  }


  /**
  * @description validate ssmo expiration date on UI (genric)
  */
  validateSSMOExpirationDate(key, fieldName) {
    let todayDate = new Date().setHours(0, 0, 0, 0);
    if (key[fieldName] == null) {
      this.uiErrorMessages.push('Expiration Date');
      return false;
    }
    else if (new Date(key[fieldName]) < todayDate) {
      this.uiErrorMessages.push('Expiration date cannot be in past');
      return false;
    }
    return true;
  }

  /**
  * @description handle generate mx link ,method to create/update mx onboarding realted records
  */
  handleGenerateMxLInk() {
    this.showComponent = false;
    generateMxRRelatedRecord({ mxLinkId: this.mxOnboardingLinkId })
      .then(data => {
        this.showComponent = true;
        if (data == true) {
          this.genricToastEventHandler(TOAST_SUCCESS_VARIANT, TOAST_SUCCESS_TITLE, "Mx Record Generated");
          this.closeQuickAction();
        }
      })
      .catch(error => {
        this.showComponent = true;
        this.genricToastEventHandler(TOAST_ERROR_VARIANT, TOAST_ERROR_TITLE, "failed")
        console.log(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: GENERATE_MX_REALTED_METHOD,
          message: JSON.stringify(error)
        });

      })
  }

  /**
  * @description method to handle confirm and submit button
  */
  handleConfirmAndSubmit() {
    this.storeAccount.Activated_Centrally_AC__c = 'Yes';
    this.isOrderProtocolPOS == false ? this.getStoreHours() : this.storeAccount.Hours_of_Operation__c = null;
    let isValid = this.validateFields();
    if (isValid) {
      this.saveAndSubmit(true);
      this.isQuickSaveNotInitated = false;
    }
  }


  /**
  * @description method to handle quick save button
  */
  handleQuickSave() {
    if (!this.isStoreFound) {
      this.genricToastEventHandler(TOAST_ERROR_VARIANT, TOAST_ERROR_TITLE, "No Store Account Found");
    }
    else if (!this.iscontactRoleFound) {
      this.genricToastEventHandler(TOAST_ERROR_VARIANT, TOAST_ERROR_TITLE, "No Contact Signatory Found");
    }
    else {
      this.isOrderProtocolPOS == false ? this.getStoreHours() : this.storeAccount.Hours_of_Operation__c = null;
      let isValid = this.validateFields();
      if (isValid) {
        if (this.checkConditionstoRenderPhotoshootContact()) {
          this.showComponent = false;
          this.resetSectionLoadParameters();
        }
        this.saveAndSubmit(false);
        this.isQuickSaveNotInitated = false;
      }
    }
  }

  /**
  * @description IF UUID presnt and email is updated and user has checked the checkbox blank uuid
  */
  checkEmailIsChangedWithUUID(sObjectData) {
    if (this.isEmailUpdated && this.isUUIdPresent) {
      sObjectData.storeAccount.Unique_Identifier__c = '';
      if (this.isPhotoshootAndContractSignatorySame) {
        sObjectData.contact = { ...this.contact, Unique_Identifier__c: '', RESSMO_Link__c: '' };
        sObjectData.photoshootContact = { ...this.contact, Unique_Identifier__c: '', RESSMO_Link__c: '' };
      }
      else {
        sObjectData.contact = { ...this.contact, Unique_Identifier__c: '', RESSMO_Link__c: '' };
      }
      if (!this.isOpenedFromContract) {
        sObjectData.quote.Unique_Identifier__c = '';
      }
      this.isUUIdPresent = false;
      this.isEmailUpdated = false;
      sObjectData.resetSSMOLogin = true;
    }
    else {
      sObjectData.resetSSMOLogin = false;
    }
  }

  /**
 * @description check conditions to fire duplicate check method
 */
  checkConditionstoRenderPhotoshootContact() {
    let returnValue = false;
    if (this.photoshootContact.LastName && this.photoshootContact.Email) {
      returnValue = this.photoshootContact.Id ? false : true;
    }
    return returnValue;
  }

  /**
  * @description reset section load parameters (for overlay spinner to work as expected)
  */
  resetSectionLoadParameters() {
    this.accountLoad = false;
    this.contactLoad = false;
    this.photoshootLoad = false;
    this.quoteLoad = false;
  }

  /**
  * @description send data to apex for update
  */
  saveAndSubmit(sendToSSMO) {
    let openedFrom = this.isOpenedFromContract ? 'Contract' : 'SBQQ__Quote__c';
    let sObjectData = this.createWrapper(openedFrom);
    this.checkEmailIsChangedWithUUID(sObjectData);
    this.isEligibile = true;
    this.fetchStoreScreen = false;
    this.reloadAccountHeader = false;
    updateRecordsFromSSMOUI({ sObjectData: sObjectData })
      .then(Data => {
        this.reloadAccountHeader = true;
        this.showComponent = true;
        Object.assign(this.decisionMakerBefore, this.contact);
        this.showEmailChangeConfirmation = false;
        let ressmoResponse = Data.ressmoResponse;
        let objectWrapper = Data.objectWrapper;
        this.mxOnboardingLinkId = objectWrapper.mxOnboardingLinkId;
        objectWrapper.photoshootContact ? this.photoshootContact = objectWrapper.photoshootContact : null;
        objectWrapper.paymentAccount ? (this.paymentAccount = objectWrapper.paymentAccount, this.showPaymentForm = false) : null;
        if (ressmoResponse.status == 'Success') {
          this.isLatestquickSave = true;
          if (sendToSSMO) {
            //call code to send to SSMO
            this.isOpenedFromContract ? this.submitFromContract() : this.submitFromQuote();
          }
          else {
            this.isEligibile = true;
            this.isQuickSaveNotInitated = true;
            this.genricToastEventHandler(TOAST_SUCCESS_VARIANT, TOAST_SUCCESS_TITLE, "Eligible For SSMO");
          }
        }
        else if (ressmoResponse.status == 'Failed') {
          this.showElligibilityMessages(ressmoResponse.messages);
        }
        if (!this.isOrderProtocolPOS && this.template.querySelector('c-store-hours')) {
          this.template.querySelector('c-store-hours').resetValueChanged();
        }
      })
      .catch(error => {
        this.reloadAccountHeader = true;
        this.showComponent = true;
        this.isLatestquickSave = false;
        this.uiErrorMessages.splice(0, this.uiErrorMessages.length);
        let index = error.body.message.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
        if (index !== -1) {
          // Extract substring starting from the end of FIELD_CUSTOM_VALIDATION_EXCEPTION
          let substring = error.body.message.substring(index + 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length);
          substring = substring.trim();
          this.uiErrorMessages.push(substring);
        } else {
          this.uiErrorMessages.push(error.body.message);
        }
        this.isQuickSaveNotInitated = true;
        this.showUIError = true;
        createLog({
          lwcName: LWC_NAME,
          methodName: UPDATE_METHOD,
          message: JSON.stringify(error)
        })
      })
  }

  /**
  * @description create wrapper to update in backend
  */
  createWrapper(openedFrom) {

    let sendPhotoshootDetails = true;
    if (!this.photoshootContact.LastName &&
      !this.photoshootContact.Email) {
      sendPhotoshootDetails = false;
    }

    let saveData = {};
    if (this.showPaymentForm) {
      saveData.paymentAccount = this.paymentAccount;
    }
    saveData.businessAccount = this.businessAccount;
    saveData.storeAccount = this.storeAccount;
    saveData.contact = this.contact;
    saveData.contract = this.contract;
    saveData.quote = this.quote;
    saveData.mxOnboardingLinkId = !this.mxOnboardingLinkId ? null : this.mxOnboardingLinkId;
    if (sendPhotoshootDetails) {
      saveData.photoshootContact = this.photoshootContact;
    }
    saveData.openedFrom = openedFrom;
    saveData.genericInput = this.genericInputs;
    return saveData;
  }


  /**
  * @description send data to apex for SSMO from quote
  */
  submitFromQuote() {
    sendToSSMOQuoteUI({ quoteId: this.quote.Id })
      .then(Data => {
        this.isQuickSaveNotInitated = true;
        if (Data.status == 'Success') {
          this.SSMO_link = Data.onboardingLink;
          this.showComponent = true;
          this.screenName = CONFIRMATION_SCREEN;
          this.genricToastEventHandler(TOAST_SUCCESS_VARIANT, TOAST_SUCCESS_TITLE, "Onboarding Link Generated");
        }
        else if (Data.status == 'Failed') {
          console.log(Data.messages);
          this.handleApexError(Data.messages);
        }
      })
      .catch(error => {
        console.log(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: SEND_METHOD,
          message: JSON.stringify(error)
        })
      })
  }

  /**
  * @description send data to apex for new store expansion from contract
  */
  submitFromContract() {
    let openedFrom = this.isOpenedFromContract ? 'Contract' : 'SBQQ__Quote__c';
    this.isEligibile = true;
    sendSSMOFromContract({ sObjectData: this.createWrapper(openedFrom) })
      .then(data => {
        this.isQuickSaveNotInitated = true;
        //link generated
        if (data.status == 'Success') {
          this.SSMO_link = data.onboardingLink;
          this.showComponent = true;
          this.screenName = CONFIRMATION_SCREEN;
          this.genricToastEventHandler(TOAST_SUCCESS_VARIANT, TOAST_SUCCESS_TITLE, "Onboarding Link Generated");
        }
        //api failed
        else if (data.status == 'Failed') {
          console.log(data.messages);
          this.handleApexError(data.messages);
        }
      })
      .catch(error => {
        console.log(JSON.stringify(error));
        createLog({
          lwcName: LWC_NAME,
          methodName: SEND_METHOD_FROM_CONTRACT,
          message: JSON.stringify(error)
        })
      })
  }

  /**
  * @description shandle eligibility messages from backend
  */
  showElligibilityMessages(messages) {
    this.isLatestquickSave = false;
    this.isEligibile = false;
    this.eligibilityMessages = messages;
    this.isQuickSaveNotInitated = true;
    const scroll = this.template.querySelector(".scroll-to-section");
    this.genricToastEventHandler(TOAST_INFO_VARIANT, TOAST_NOT_ELIGIBLE_TITLE, SSMO_NOT_ELIGIBLE);
    if (scroll) {
      setTimeout(() => { scroll.scrollIntoView({ behavior: 'smooth', block: 'end' }) }, 400);
    }
  }

  /**
  * @description method to fire event in the child component to get hours of operation string
  */
  getStoreHours() {
    const storeHoursComponent = this.template.querySelector('c-store-hours');
    storeHoursComponent.getHoursOfOperationInString();
  }


  /**
  * @description handle event from child component and update hours of operation if any update has happened
  */
  handleHoursOfOperation(event) {
    const hoursOfOperation = event.detail;
    if (hoursOfOperation != 'Invalid Input') {
      this.isStoreHoursValid = true;
      this.storeAccount.Hours_of_Operation__c = event.detail;
    }
    else {
      this.isStoreHoursValid = false;
    }
  }

  /**
  * @description remove spinner once the store hours compnenet is loaded
  */
  setStoreHoursLoader() {
    this.storeHoursLoad = true;
  }
  /**
  * @description redirect screen to create a new store
  */
  handleCreateStoreLink(event) {
    event.preventDefault();
    let dynamicFieldString = this.isOpenedFromContract ? `ParentId=${this.contract.AccountId}` : `ParentId=${this.quote.SBQQ__Account__c}`;
    dynamicFieldString = encodeURIComponent(dynamicFieldString);
    const createAccountUrl = `/lightning/o/Account/new?recordTypeId=${this.storeRecordTypeId}&defaultFieldValues=${dynamicFieldString}`;
    window.open(createAccountUrl, '_blank');
  }

  /**
 * @description redirect to create a new payment account
 */
  handleCreatePaymentAccount(event) {
    const defaultFieldValues = encodeURIComponent(`Account__c=${this.storeAccount.Id}`);
    const createAccountUrl = `/lightning/o/Account_Payment_Account_Relation__c/new?defaultFieldValues=${defaultFieldValues}`;
    window.open(createAccountUrl, '_blank');
  }

  /**
  * @description remove spinner once the record edit form is loaded
  */
  handleFormLoad(event) {
    const objectAPIName = event.detail.objectapiname;

    if (objectAPIName == this.accountObjectApi) {
      this.accountLoad = true;
    }
    if (objectAPIName == 'SBQQ__Quote__c') {
      this.quoteLoad = true;
    }
    if (objectAPIName == this.contactObjectApi) {
      if (event.detail.isPhototshoot == true) {
        this.photoshootLoad = true;
      }
      else {
        this.contactLoad = true;
      }
    }

  }

  /**
  * @description intialize business account object upon record edit form load
  */
  setStorePaymentSectionFields(event) {
    let fields = event.detail.records[this.storeAccount.Id].fields;
    let storefields = Object.keys(fields)
      .filter(key => PAYMENT_SECTION_ACCOUNT_FIELDS.includes(key))
      .reduce((acc, key) => {
        acc[key] = fields[key].value;
        return acc;
      }, {});
    this.storeAccount = {...this.storeAccount,...storefields};
  }

  /**
  * @description It is used to close the screen on button click.
  */
  closeQuickAction() {
    let recordurl;
    if (this.isOpenedFromContract == true) {
      recordurl = window.location.origin + '/' + this.recordId;
      this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
    }
    else {
      recordurl = window.location.origin + '/' + this.recordId;
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    window.location.href = recordurl;
  }


  /**
  * @description - generate toast events
  */
  genricToastEventHandler(TOAST_VARIANT, TOAST_TITLE, TOAST_MESSAGE) {
    this.dispatchEvent(new ShowToastEvent({
      title: TOAST_TITLE,
      variant: TOAST_VARIANT,
      message: TOAST_MESSAGE
    }))
  }
  /**
  * @description - banking
  */
  checkBankingInfoPopulated(objectWrapper) {
    if (this.isOpenedFromContract) {
      this.bankingInfo = objectWrapper.isBankingInfoPopulated;
    } else {
      this.bankingInfo = (this.quote.SBQQ__Opportunity2__r.RESSMO_Link__c == null || this.quote.SBQQ__Opportunity2__r.RESSMO_Link__c === undefined) ? objectWrapper.isBankingInfoPopulated : false;
    }
  }

}