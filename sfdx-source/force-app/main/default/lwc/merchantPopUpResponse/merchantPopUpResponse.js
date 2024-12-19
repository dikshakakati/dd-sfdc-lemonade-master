import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import MERCHANT_POP_UP_RESPONSE_OBJECT from "@salesforce/schema/Merchant_Pop_Up_Response__c";
import MARKETPLACE_OR_DRIVE from "@salesforce/schema/Merchant_Pop_Up_Response__c.Form_Type__c";
import MENU_UI_TYPE from "@salesforce/schema/Merchant_Pop_Up_Response__c.Menu_UI_Type__c";
import RESPONSE_ID from "@salesforce/schema/Merchant_Pop_Up_Response__c.Id";
import RESPONSE_URL from "@salesforce/schema/Merchant_Pop_Up_Response__c.URL__c";
import ENCRYPTED_ID from "@salesforce/schema/Merchant_Pop_Up_Response__c.Encrypted_Record_Id__c";
import CONTRACT_ACCOUNT_COUNTRY from "@salesforce/schema/Contract.Account.BillingCountryCode";
import CONTRACT_ACCOUNT_SEGMENT from "@salesforce/schema/Contract.Account.Segment__c";
import CONTRACT_ACCOUNT_PRIMARY_VERTICAL from "@salesforce/schema/Contract.Account.Primary_Vertical__c";
import PRIMARY_VERTICAL_VALUES_FOR_SSN from "@salesforce/label/c.Primary_Vertical_Values_For_SSN";
import CONTRACT_FSA from "@salesforce/schema/Contract.Franchise_Supplemental_Agreement_URL__c";
import CONTRACT_MSA from "@salesforce/schema/Contract.Master_Supplemental_Agreement_URL__c";
import CONTRACT_PRICING from "@salesforce/schema/Contract.Pricing_Summary_URL__c";
import POPULATE_AGREEMENTS from "@salesforce/label/c.Validation_Error_To_Populate_Agreements";
import CORPORATE_ACCOUNT_ID from "@salesforce/schema/Contract.AccountId";
import IsThisFormForMarketplaceOrDrive from "@salesforce/label/c.Is_this_form_for_Marketplace_or_Drive";
import MenuUIType from "@salesforce/label/c.Menu_UI_Type_Field_Label";
import FranchiseAmendmentType from "@salesforce/label/c.Franchise_Amendment_Type";
import IsItRateChangeOrAdditionOfProduct from "@salesforce/label/c.Is_this_Rate_Change_or_Amendment";
import URL_PARAMETER from "@salesforce/label/c.Url_Parameter";
import DRIVE from "@salesforce/label/c.Default_Form_Selector_As_Drive";
import RESTAURANT from "@salesforce/label/c.Default_Menu_UI_Type";
import DRIVE_USE_CASE_FIELD_SET_NAME from "@salesforce/label/c.Drive_Use_Case_Field_Set_Name";
import Not_RATE_CHANGE_USE_CASE_FIELD_SET_NAME from "@salesforce/label/c.Not_Rate_Change_Use_Case_Field_Set_Name";
import NON_RATE_CHANGE_USE_CASE_WITH_TABLET_FIELDS from "@salesforce/label/c.Non_Rate_Change_Use_Case_With_Tablet_Fields";
import COUNTRY_IS_NOT_POPULATED from "@salesforce/label/c.Country_Not_Populated_on_CorporateAccount";
import URL_NOT_GENERATED_MESSAGE from "@salesforce/label/c.URL_Not_Generated";
import RATE_CHANGE_FIELD_SET_NAME from "@salesforce/label/c.Rate_Change_Use_Case_Field_Set_Name";
import FORM_SUBMITTED from "@salesforce/label/c.Form_Submitted";
import RECORD_ID_LOG_EVENT from "@salesforce/label/c.Record_Id_Log_Event";
import VIEW from "@salesforce/label/c.View";
import TOAST_VARIENT_SUCCESS from "@salesforce/label/c.Toast_Variant_Success";
import TOAST_TITLE_ERROR from "@salesforce/label/c.Toast_Title";
import TOAST_VARIENT_ERROR from "@salesforce/label/c.Toast_Variant_Error";
import US from "@salesforce/label/c.US";
import CA from "@salesforce/label/c.CA";
import AU from "@salesforce/label/c.AU";
import NZ from "@salesforce/label/c.NZ";
import fetchUrls from "@salesforce/apex/MerchantPopUpResponseController.fetchUrls";
import getActiveFranchiseAgreementOnContract from "@salesforce/apex/MerchantPopUpResponseController.getActiveFranchiseAgreementOnContract";
import getEncryptedResponseId from "@salesforce/apex/MerchantPopUpResponseController.getEncryptedId";
import getFields from "@salesforce/apex/MerchantPopUpResponseController.getFields";
import getFranchiseAccounts from "@salesforce/apex/MerchantPopUpResponseController.getFranchiseAccounts";
import getCorporateAccounts from "@salesforce/apex/MerchantPopUpResponseController.getCorporateAccounts";
import getSubscriptionsWithCoDProduct from "@salesforce/apex/MerchantPopUpResponseController.getSubscriptionsWithCoDProduct";
import hasAlcoholProductsSubscription from "@salesforce/apex/MerchantPopUpResponseController.hasAlcoholProductsSubscription";
import getContractBrandAssociations from "@salesforce/apex/MerchantPopUpResponseController.getContractBrandAssociations";
import getDriveSubscriptions from "@salesforce/apex/MerchantPopUpResponseController.getDriveSubscriptions";
import createOpportunities from "@salesforce/apex/MerchantPopUpResponseController.createOpportunities";
import getSubscriptionsForOptionalProductSelection from "@salesforce/apex/MerchantPopUpResponseController.getSubscriptionsForOptionalProductSelection";
import getEmailsOfQueueMembers from "@salesforce/apex/MerchantPopUpResponseController.getEmailsOfQueueMembers";
import createLog from "@salesforce/apex/LogController.createLog";
import DRIVE_WITHHOLDING_FIELDSET_NAME from "@salesforce/label/c.Drive_Withholding_Fieldset_Name";
import PAYMENT_METHOD from "@salesforce/schema/Contract.Payment_Method__c";
import MP_BZ_ID from "@salesforce/schema/Contract.MP_Bz_Id__c";
import ARE_ALL_FRANCHISE_ACCOUNTS_PROCESSED from "@salesforce/schema/Contract.Account.Are_All_Franchise_Accounts_Processed__c";
import DAYS_FOR_OPT_OUT from "@salesforce/schema/Contract.Account.Number_of_Days_to_Opt_out__c";
import INTEGRATED_FRANCHISE from "@salesforce/label/c.FranchiseType_Integrated_Franchise";
import DRIVE_FORM_FRANCHISE from "@salesforce/label/c.FranchiseType_Drive_Form_Franchise";
import DRIVE_AMENDMENT from "@salesforce/label/c.FranchiseType_Drive_Amendment";
import WITHHOLDING_OPT_OUT from "@salesforce/label/c.FranchiseType_Withholding_Opt_out";
import WITHHOLDING_OPT_OUT_FIELDSET_NAME from "@salesforce/label/c.Withholding_Opt_out_Fieldset_Name";
import IS_MX_HAVING_MORE_THAN_ONE_BRAND from "@salesforce/schema/Merchant_Pop_Up_Response__c.Is_Mx_having_more_than_one_brand__c";
import getBusinessVerticals from "@salesforce/apex/MerchantPopUpResponseController.getBusinessVerticals";
import getMenuUITypeByBusinessVerticals from "@salesforce/apex/MerchantPopUpResponseController.getMenuUITypeByBusinessVerticals";
import POS_SERVICE_PROVIDERS_THAT_DO_NOT_SUPPORT_SELF_DELIVERY from "@salesforce/label/c.POS_Service_Providers_That_Do_Not_Support_Self_Delivery";
import POS_SERVICE_PROVIDERS_ERROR_MESSAGE from "@salesforce/label/c.POS_Service_Providers_Error_Message";
import POS_SERVICE_PROVIDERS_HELPTEXT from "@salesforce/label/c.POS_Service_Providers_Helptext";
import POS_SERVICE_PROVIDERS_HELPTEXT_LINK from "@salesforce/label/c.POS_Service_Providers_Helptext_Link";
import getSubscriptionsForOptionalPackageSelection from "@salesforce/apex/MerchantPopUpResponseController.getSubscriptionsForOptionalPackageSelection";

const ENGLISH_LANGUAGE = "English";
const FRENCH = "French";
const FRANCHISE = "Franchise";
const MARKETPLACE = "Marketplace";
const RATE_CHANGE = "RateChange";
const RATE_CHANGE_USE_CASE = "Rate Change";
const DRIVE_DB_SOURCE = "DriveDb";
const LWC_NAME = "MerchantPopUpResponse";
const GET_ACTIVE_FRANCHISE_AGREEMENT_ON_CONTRACT = "getActiveFranchiseAgreementOnContract";
const GET_FRANCHISE_ACCOUNT = "getFranchiseAccounts";
const GET_CORPORATE_ACCOUNT = "getCorporateAccounts";
const GET_SUBSCRIPTIONS_WITH_COD_PRODUCT = "getSubscriptionsWithCoDProduct";
const GET_SUBSCRIPTIONS_WITH_ALCOHOL_PRODUCT = "hasAlcoholProductsSubscription";
const GET_SUBSCRIPTIONS_WITH_DRIVE_PRODUCT = "getDriveSubscriptions";
const CREATE_OPPORTUNITIES = "createOpportunities";
const OPPORTUNITY_CREATION_SUCCESS_MESSAGE =
  "Opportunities have been created successfully.";
const YES_VALUE = "Yes";
const UPDATE_RESPONSE_WITH_URL = "updateUrlOnResponse";
const HANDLE_SUCCESS_METHOD_NAME = "handleSuccess";
const TABLET_ORDER_PROTOCOL_VALUES = "Tablet";
const ADDITIONAL_INFORMATION = "Additional Information";
const TABLET_INFORMATION = "Tablet Information";
const MENU_INFORMATION = "Menu Information";
const MDS_SOURCE = "MDS";
const GET_SUBSCRIPTIONS_FOR_OPTIONAL_PRODUCT_SELECTION =
  "getSubscriptionsForOptionalProductSelection";
const GET_SUBSCRIPTIONS_FOR_OPTIONAL_PACKAGE_SELECTION = "getSubscriptionsForOptionalPackageSelection";
const STOREFRONT = "Storefront";
const DELIVERY = "Delivery";
const PICKUP = "Pickup";
const DASHPASS = "Dashpass";
const POS_ORDER_PROTOCOL_VALUES = "POS";
const LINK_TO_EXISTING_MENU = "Link to Existing Menu(s)";
const CLONE_EXISTING_MENU = "Clone Existing Menu(s)";
const WITHHOLDING = "Withholding";
const WITHHOLDING_OPT_OUT_FRENCH = "Withholding_Opt_out_CA_French";
const OPT_OUT_DAYS_REMAINING = '0';
const RETAIL = "Retail"
const GET_BUSINESS_VERTICALS = "getBusinessVerticals";
const GET_MENU_UI_TYPE_BY_BUSINESS_VERTICALS = "getMenuUITypeByBusinessVerticals";
const ACCOUNT_SEGMENT_SMB = "SMB";

export default class MerchantPopUpResponse extends NavigationMixin(
  LightningElement
) {
  dashpassOption = { label: DASHPASS, value: DASHPASS };
  deliveryOption = { label: DELIVERY, value: DELIVERY };
  pickupOption = { label: PICKUP, value: PICKUP };
  marketplacePackageOption = { label: MARKETPLACE, value: MARKETPLACE };
  storefrontPackageOption = { label: STOREFRONT, value: STOREFRONT };
  productOptions = [];
  packageOptions = [];
  requiredPackages = [MARKETPLACE];
  selectedProducts = [];
  selectedPackages = [];
  showPackageField = false;
  showSelectedOptions = "";
  viewOptionalProductSelection = false;
  @api contractId;
  @track isSaveDisabled;
  globalEncryptedId;
  globalResponseRecordId;
  urlToGetApproval;
  useCase = DRIVE;
  countries = [CA, AU, US, NZ];
  urlMappings = [];
  franchiseAccounts = [];
  corporateAccounts = [];
  contractBrandAssociations = [];
  popupCorporateAccount;
  selectedFranchiseAccounts = [];
  loaded = true;
  selectedBrand = "";
  selectedBrandName = "";
  urlParameter = URL_PARAMETER;
  englishLanguage = ENGLISH_LANGUAGE;
  formSelector = DRIVE;
  defaultMenuUITypeValue = RESTAURANT;
  menuSetupMethod = "";
  @track selectedBusinessVertical = "";
  showSSNfield = false;
  corporatePrimaryVertical = "";
  primaryVerticalValueForSSN = PRIMARY_VERTICAL_VALUES_FOR_SSN;
  posServiceProvidersThatDoNotSupportSelfDelivery = POS_SERVICE_PROVIDERS_THAT_DO_NOT_SUPPORT_SELF_DELIVERY.split(",");
  posServiceProvidersErrorMessage = POS_SERVICE_PROVIDERS_ERROR_MESSAGE;
  posServiceProvidersHelptext = POS_SERVICE_PROVIDERS_HELPTEXT;
  posServiceProvidersHelptext1 = "Refer here ";
  posServiceProvidersHelptextLink = POS_SERVICE_PROVIDERS_HELPTEXT_LINK;
  applicablePosIntegrationValue = "";
  selfDeliveryValue = "";
  showPosServiceError = false;

  labels = {
    IsThisFormForMarketplaceOrDrive,
    IsItRateChangeOrAdditionOfProduct,
    FranchiseAmendmentType,
    MenuUIType
  };
  sectionHeaders = {
    ADDITIONAL_INFORMATION,
    TABLET_INFORMATION,
    MENU_INFORMATION
  };
  isDriveFormFrachise = true;
  marketplaceOrDrive = MARKETPLACE_OR_DRIVE;
  dynamicFiedSet = DRIVE_USE_CASE_FIELD_SET_NAME;
  dynamicFields;
  isRateChange = false;
  isAmendmentTypePermitted = false;
  isDriveIntegratedFranchise = false;
  amendmentType = "";
  externalIdSource = "";
  corporateCountryValue;
  areAgreementsPopulated = false;
  contractRecord;
  isOrderProtocolRelatedToTablet = false;
  isMenuInformationRequired = false;
  isOrderProtocolNotPOS = true;
  isDrive = true;
  showRateChangeCheckBox = false;
  showFormLanguage = false;
  isExternalBusinessIdRequired = false;
  numberOfColumns = "1";
  showAllLayout = true;
  showFranchiseOptions = false;
  isPaymentInfoRequired = false;
  isMarketplaceAlcoholSubscription = false;
  refinedStringOfEmails = "";
  formLanguage = "English";
  isMxHavingMoreThanOneBrand = "Does your Mx Group have more than one brand";
  isEachFranchiseHavingItsOwnBrand = "Do you want each Franchsiee to select their own brand?";
  shouldDashPassBeIncluded = false;
  shouldPickUpBeIncluded = false;
  shouldDeliveryBeIncluded = false;
  isHavingMultipleBrands = false;
  isEachFranchiseHavingOwnBrand = false;
  corporateAccountIdFromRecord;
  inputFields = [];
  showBrandQuery2 = true;
  showSelectBrand = true;
  emails = '';
  isOrderProtocolRelatedToPOS = false;
  orderProtocolValue = '';
  oppoortunityStageValue;
  showMPBzId = false;
  showSelfDeliveryOption = false;
  isDriveAmendment = false;
  @track optyClosedWonDays = "";
  paymentMethod = '';
  contractAccountSegment = '';
  mpBizId = '';
  areAllFranchiseAccountsUpdatedToWithholding = false;
  noOfDaysToOptOut = 0;
  isFranchiseTypeNotWithholdingOptOut = true;
  isWithholdingOptoutValueAdded = false;
  isActiveFranchiseAgreementOnContract = false;
  franchiseTypes = [
    { label: INTEGRATED_FRANCHISE, value: INTEGRATED_FRANCHISE },
    { label: DRIVE_FORM_FRANCHISE, value: DRIVE_FORM_FRANCHISE },
    { label: DRIVE_AMENDMENT, value: DRIVE_AMENDMENT }];

  @track isMenuUITypeRetail = false;

  rateChangeOrProductAdditionChecked = false;
  objectApiName =
    MERCHANT_POP_UP_RESPONSE_OBJECT[
    Object.keys(MERCHANT_POP_UP_RESPONSE_OBJECT)[0]
    ];
  formTypeToURLMapping = new Map();
  contractIdsFranchiseAgreements = [];

  /**
   * @description This method used to list fields names from the passed fieldset of the passed object.
   */
  @wire(getFields, {
    objectApiName: "$objectApiName",
    fieldSetName: "$dynamicFiedSet"
  })
  getDynamicFields({ error, data }) {
    if (data) {
      this.dynamicFields = [...data];
    }
  }

  @track isOrderProtocolNotPOS = false;
  @track showURLField = false;
  /**
   * @description This method used to get ObjectInfo.
   */
  @wire(getObjectInfo, { objectApiName: MERCHANT_POP_UP_RESPONSE_OBJECT })
  objectInfo;

  /**
   * @description This method used to get picklist values of the passed field.
   */
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: MARKETPLACE_OR_DRIVE
  })
  picklistValues;

  /**
     * @description It is used to get picklist values of the Menu UI Type field.
     */
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: MENU_UI_TYPE
  })
  menuPicklistValues;

  /**
   * @description This method is used to get picklist values of Select Franchise Type.
   */
  get franchiseType() {
    return [
      { label: DRIVE_FORM_FRANCHISE, value: DRIVE_FORM_FRANCHISE },
      { label: INTEGRATED_FRANCHISE, value: INTEGRATED_FRANCHISE }
    ];
  }

  /**
   * @description This method used to get Nintex URL Mapping custom metadata records.
   */
  @wire(fetchUrls, {})
  retrieveURLMappings({ error, data }) {
    if (data) {
      this.urlMappings.push(data);
      this.generateMappings();
    }
  }

  /**
 * @description This method used to get Nintex_COO_Store_No_Match_Exception_Log queue member emails.
 */
  @wire(getEmailsOfQueueMembers, {})
  retrieveEmails({ error, data }) {
    if (data) {
      this.emails = data;
    }
  }

  /**
   * @description This method used to get country of the corporate Account related to the Contract.
   */
  @wire(getRecord, {
    recordId: "$contractId",
    fields: [
      CONTRACT_ACCOUNT_COUNTRY,
      CONTRACT_FSA,
      CONTRACT_MSA,
      CONTRACT_PRICING,
      CORPORATE_ACCOUNT_ID,
      PAYMENT_METHOD,
      MP_BZ_ID,
      DAYS_FOR_OPT_OUT,
      ARE_ALL_FRANCHISE_ACCOUNTS_PROCESSED,
      CONTRACT_ACCOUNT_PRIMARY_VERTICAL,
      CONTRACT_ACCOUNT_SEGMENT
    ]
  })
  wiredContractRecord({ data, error }) {
    if (data) {
      this.contractRecord = "$contractId";
      this.corporateCountryValue = getFieldValue(
        data,
        CONTRACT_ACCOUNT_COUNTRY
      );
      this.corporateAccountIdFromRecord = getFieldValue(
        data,
        CORPORATE_ACCOUNT_ID
      );
      this.paymentMethod = getFieldValue(
        data,
        PAYMENT_METHOD
      );
      this.mpBizId = getFieldValue(
        data,
        MP_BZ_ID
      );
      this.noOfDaysToOptOut = getFieldValue(
        data,
        DAYS_FOR_OPT_OUT
      );
      this.areAllFranchiseAccountsUpdatedToWithholding = getFieldValue(
        data,
        ARE_ALL_FRANCHISE_ACCOUNTS_PROCESSED
      );
      this.corporatePrimaryVertical = getFieldValue(
        data,
        CONTRACT_ACCOUNT_PRIMARY_VERTICAL
      );
      this.contractAccountSegment = getFieldValue(
        data,
        CONTRACT_ACCOUNT_SEGMENT
      );
      if (
        getFieldValue(data, CONTRACT_PRICING) === null
        || (getFieldValue(data, CONTRACT_MSA) === null
          && getFieldValue(data, CONTRACT_FSA) === null)
        || (getFieldValue(data, CONTRACT_MSA) !== null
          && getFieldValue(data, CONTRACT_MSA).includes("drive"))
        || (getFieldValue(data, CONTRACT_FSA) !== null
          && getFieldValue(data, CONTRACT_FSA).includes("drive"))
      ) {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.contractId,
            objectApiName: MERCHANT_POP_UP_RESPONSE_OBJECT,
            actionName: VIEW
          }
        });
        const toastEventForFailure = new ShowToastEvent({
          title: TOAST_TITLE_ERROR,
          variant: TOAST_VARIENT_ERROR,
          message: POPULATE_AGREEMENTS
        });
        this.dispatchEvent(toastEventForFailure);
      } else {
        this.areAgreementsPopulated = true;
      }
      if (this.corporateCountryValue === CA) {
        this.showFormLanguage = true;
      }
      this.contractIdsFranchiseAgreements.push(this.contractId);
      this.getFranchiseAgreements();
      this.getSubscriptionsOfContractForOptionalPackage(this.contractId);
      this.getSubscriptionsOfContractForOptionalProduct(this.contractId);
      this.getSubscriptionsOfContract(this.contractId);
      this.getAlcoholSubscriptionsOfContract(this.contractId);
      this.getDriveSubscriptionsOfContract(this.contractId);
      this.externalIdSource = DRIVE_DB_SOURCE;
      this.getCorporateChildAccountsOnContractCorporateAccount(
        this.corporateAccountIdFromRecord
      );
      if (this.corporateCountryValue === US) {
        this.showSelfDeliveryOption = true;
        if (this.primaryVerticalValueForSSN.includes(this.corporatePrimaryVertical)) {
          this.showSSNfield = true;
        }

      }
      this.getBusinessVerticalRecord();
    }
  }

  /**
   * @description It is used to render withholding opt out picklist value conditionally.
   */
  get addFranchiseTypeWithholdingOptOut() {
    if (this.isWithholdingOptOutEligible()) {
      this.franchiseTypes.push(
        { label: WITHHOLDING_OPT_OUT, value: WITHHOLDING_OPT_OUT }
      )
      this.isWithholdingOptoutValueAdded = true;
    }
    return this.franchiseTypes;
  }

  /**
   * @description It is used to check the eligibility to show the Withholding Opt-out picklist value
   * in 'Select the Franchise Type' pop-up field.
   */
  isWithholdingOptOutEligible() {
    return !this.isWithholdingOptoutValueAdded && this.paymentMethod === WITHHOLDING
      && this.mpBizId && this.areAllFranchiseAccountsUpdatedToWithholding
      && ((this.noOfDaysToOptOut === OPT_OUT_DAYS_REMAINING
        && this.isActiveFranchiseAgreementOnContract) || !this.noOfDaysToOptOut);
  }

  /**
   * @description Fetches Subscriptions related to the Contract
   */
  getSubscriptionsOfContract(currentContractId) {
    getSubscriptionsWithCoDProduct({
      contractId: currentContractId
    })
      .then((result) => {
        this.isPaymentInfoRequired = result;
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_SUBSCRIPTIONS_WITH_COD_PRODUCT,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
     * @description Fetches Subscriptions related to the Contract
     */
  getAlcoholSubscriptionsOfContract(currentContractId) {
    hasAlcoholProductsSubscription({
      contractId: currentContractId
    })
      .then((result) => {
        this.isMarketplaceAlcoholSubscription = result;
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_SUBSCRIPTIONS_WITH_ALCOHOL_PRODUCT,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description Fetches Subscriptions related to the Contract
   */
  getDriveSubscriptionsOfContract(currentContractId) {
    getDriveSubscriptions({
      contractId: currentContractId
    })
      .then((result) => {
        if (result.length > 0) {
          this.isAmendmentTypePermitted = true;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_SUBSCRIPTIONS_WITH_DRIVE_PRODUCT,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description Validate email Ids
   */
  validateEmailIdsEntered(stringOfEmails) {
    var emailList = stringOfEmails.split(";");
    this.refinedStringOfEmails = "";
    const emailRegex =
      /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    emailList.forEach((eachMail) => {
      eachMail = eachMail.trim();
      if (eachMail.match(emailRegex)) {
        if (this.refinedStringOfEmails === "") {
          this.refinedStringOfEmails = eachMail;
        } else {
          this.refinedStringOfEmails =
            this.refinedStringOfEmails + ";" + eachMail;
        }
      }
    });
  }

  /**
   * @description It is used to get the Active Franchise Agreements on the Contract
   * where the Franchise Account's payment method is not Withholding.
   * It will update the flag 'isActiveFranchiseAgreementOnContract' to true when a record is found and the flag will be used to
   * conditionally show/hide the picklist value Withholding Opt-out on the Franchise Form.
  */
  getFranchiseAgreements() {
    getActiveFranchiseAgreementOnContract({
      contractIds: this.contractIdsFranchiseAgreements
    })
      .then((result) => {
        if (result.length > 0) {
          this.isActiveFranchiseAgreementOnContract = true;
        }
        else {
          this.isActiveFranchiseAgreementOnContract = false;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_ACTIVE_FRANCHISE_AGREEMENT_ON_CONTRACT,
          message: JSON.stringify(error.body)
        });
      });

  }

  /**
   * @description Fetches all the Franchise Accounts of the selected Corporate Account
   * and display the fetched results on the Pop-Up as multi select picklist.
   */
  getFranchiseAccountsOnCorporateAccountSelection(corporateAccountsId) {
    getFranchiseAccounts({
      corporateAccountId: corporateAccountsId,
      externalIdSource: this.externalIdSource,
      contractId: this.contractId
    })
      .then((result) => {
        var uniqueIds = [];
        this.franchiseAccounts = [];
        result.forEach((eachAccount) => {
          if (!uniqueIds.includes(eachAccount.Franchise_Parent__c)) {
            uniqueIds.push(eachAccount.Franchise_Parent__c);
            this.franchiseAccounts.push({
              label: eachAccount.Franchise_Parent__r.Name,
              value: eachAccount.Franchise_Parent__c
            });
          }
        });
        this.loaded = true;
        this.isMxCorporateAccountSelected = true;
      })
      .catch((error) => {
        this.loaded = true;
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_FRANCHISE_ACCOUNT,
          message: JSON.stringify(error.body)
        });
      });
  }

  getContractBrandAssociationsForCurrentContract(currentContractId) {
    getContractBrandAssociations({ contractId: currentContractId }).then((result) => {
      var uniqueIds = [];
      this.contractBrandAssociations = [];

      result.forEach((eachAssociation) => {
        if (!uniqueIds.includes(eachAssociation.Id)) {
          uniqueIds.push(eachAssociation.Id);
          this.contractBrandAssociations.push({
            label: eachAssociation.Brand__r.Name,
            value: eachAssociation.Brand_Id__c
          });
        }
      });
    })
  }

  /**
 * @description Fetches all the child Corporate Accounts of the selected Corporate Account
 * and display the fetched results on the Pop-Up as picklist.
 */
  getCorporateChildAccountsOnContractCorporateAccount(corporateAccountsId) {
    getCorporateAccounts({
      corporateAccountId: corporateAccountsId
    })
      .then((result) => {
        var uniqueIds = [];
        this.corporateAccounts = [];

        result.forEach((eachAccount) => {
          if (!uniqueIds.includes(eachAccount.Id)) {
            uniqueIds.push(eachAccount.Id);
            this.corporateAccounts.push({
              label: eachAccount.Name,
              value: eachAccount.Id
            });
          }
        });
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_CORPORATE_ACCOUNT,
          message: JSON.stringify(error.body)
        });
      });
  }
  /**
   * @description It stamps the generated Nintex form URL to the Response object.
   */
  updateUrlOnResponse() {
    const fields = {};
    fields[RESPONSE_ID.fieldApiName] = this.globalResponseRecordId;
    fields[RESPONSE_URL.fieldApiName] = this.urlToGetApproval;
    fields[ENCRYPTED_ID.fieldApiName] = this.globalEncryptedId;
    //Added the below condition in case of the type Withholding Opt-out to blank out
    //the default value of the field 'Is_Mx_having_more_than_one_brand__c' on update
    //as Salesforce doesn't allow to programatically change the lightning input field default value.
    if (this.amendmentType === WITHHOLDING_OPT_OUT) {
      fields[IS_MX_HAVING_MORE_THAN_ONE_BRAND.fieldApiName] = '';
    }

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => { })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: UPDATE_RESPONSE_WITH_URL,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description Fetches the selected Franchise Accounts and routes to Opportunity creation
   */
  createOpportunitiesAssociatedToSelectedFranchises() {
    createOpportunities({
      selectedFranchiseAccountIds: this.selectedFranchiseAccounts,
      currenctContractId: this.contractId,
      franchiseUseCase: this.useCase,
      daysToAdd: this.optyClosedWonDays
    })
      .then(() => { })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: CREATE_OPPORTUNITIES,
          message: JSON.stringify(error.body)
        });
      });
    if (this.selectedFranchiseAccounts.length > 0) {
      const toastEvent = new ShowToastEvent({
        message: OPPORTUNITY_CREATION_SUCCESS_MESSAGE,
        variant: TOAST_VARIENT_SUCCESS
      });
      this.dispatchEvent(toastEvent);
    }
  }

  /**
   * @description Selects all franchise Accounts related to the selected corporate Account for Opportunity creation.
   */
  selectAllFranchiseAccounts() {
    this.franchiseAccounts.forEach((eachAccount) => {
      this.selectedFranchiseAccounts.push(eachAccount.value);
    });
    if (this.selectedFranchiseAccounts.length === 0) {
      this.isSaveDisabled = true;
    } else {
      this.isSaveDisabled = false;
    }
  }

  /**
   * @description It generates url mapping on basis of form selector, use-case & country code.
   */
  generateMappings() {
    this.formTypeToURLMapping.set(
      DRIVE + FRANCHISE + CA,
      this.urlMappings[0].Drive_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      DRIVE + FRANCHISE + US,
      this.urlMappings[0].Drive_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      DRIVE + FRANCHISE + NZ,
      this.urlMappings[0].Drive_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      DRIVE + FRANCHISE + AU,
      this.urlMappings[0].Drive_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + RATE_CHANGE + CA,
      this.urlMappings[0].Rate_Change_US_CA
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + RATE_CHANGE + US,
      this.urlMappings[0].Rate_Change_US_CA
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + RATE_CHANGE + NZ,
      this.urlMappings[0].Rate_Change_NZ
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + RATE_CHANGE + AU,
      this.urlMappings[0].Rate_Change_AU
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + FRANCHISE + CA,
      this.urlMappings[0].Franchise_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + FRANCHISE + US,
      this.urlMappings[0].Franchise_Use_Case_US_CA
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + FRANCHISE + NZ,
      this.urlMappings[0].Franchise_Use_Case_NZ
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + FRANCHISE + AU,
      this.urlMappings[0].Franchise_Use_Case_AU
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + FRANCHISE + CA + FRENCH,
      this.urlMappings[0].Franchise_Use_Case_CA_French
    );
    this.formTypeToURLMapping.set(
      MARKETPLACE + RATE_CHANGE + CA + FRENCH,
      this.urlMappings[0].Rate_Change_CA_French
    );
    this.formTypeToURLMapping.set(
      DRIVE + FRANCHISE + CA + FRENCH,
      this.urlMappings[0].Drive_Use_Case_CA_French
    );
    this.formTypeToURLMapping.set(
      WITHHOLDING_OPT_OUT,
      this.urlMappings[0].Withholding_Opt_out
    );
    this.formTypeToURLMapping.set(
      WITHHOLDING_OPT_OUT_FRENCH,
      this.urlMappings[0].Withholding_Opt_out_CA_French
    );
  }

  /**
   * @description This method used to set name of field set(Rate change/Not Rate change) and number of columns in popup.
   */
  handleChange(event) {
    this.franchiseAccounts = [];
    this.rateChangeOrProductAdditionChecked = event.target.checked;
    if (this.rateChangeOrProductAdditionChecked) {
      this.numberOfColumns = "1";
      this.isRateChange = true;
      this.isSaveDisabled = true;
      this.dynamicFiedSet = RATE_CHANGE_FIELD_SET_NAME;
      this.externalIdSource = MDS_SOURCE;
    } else {
      this.numberOfColumns = "2";
      this.isRateChange = false;
      this.isSaveDisabled = false;
      this.dynamicFiedSet = Not_RATE_CHANGE_USE_CASE_FIELD_SET_NAME;
      this.isMenuInformationRequired = false;
    }
  }

  /**
   * @description This method used to set name of field set(Drive/Not rate change) and number of columns in popup.
   */
  handlePickListChange(event) {
    this.formSelector = event.detail.value;
    if (this.formSelector === DRIVE) {
      this.rateChangeOrProductAdditionChecked = false;
      this.dynamicFiedSet = DRIVE_USE_CASE_FIELD_SET_NAME;
      this.showRateChangeCheckBox = false;
      this.isDrive = true;
      this.numberOfColumns = "1";
      this.isRateChange = false;
      this.externalIdSource = DRIVE_DB_SOURCE;
      this.getSubscriptionsOfContract(this.contractId);
      this.getAlcoholSubscriptionsOfContract(this.contractId);
      this.getDriveSubscriptionsOfContract(this.contractId);
    } else {
      this.dynamicFiedSet = Not_RATE_CHANGE_USE_CASE_FIELD_SET_NAME;
      this.showRateChangeCheckBox = true;
      this.rateChangeOrProductAdditionChecked = false;
      this.isDrive = false;
      this.isSaveDisabled = false;
      this.numberOfColumns = "2";
      this.isMenuInformationRequired = false;
    }
    this.selectedFranchiseAccounts = [];
    this.franchiseAccounts = [];
  }

  /**
   * @description This method used to set franchise type
   */
  handleFranchiseTypeChange(event) {
    this.amendmentType = event.detail.value;
    if (this.amendmentType === INTEGRATED_FRANCHISE) {
      this.isDriveIntegratedFranchise = true;
    } else {
      this.isDriveIntegratedFranchise = false;
    }
    this.showMPBzId = this.isDriveIntegratedFranchise && this.paymentMethod === WITHHOLDING;
    if (this.amendmentType === DRIVE_AMENDMENT) {
      this.selectAllFranchiseAccounts();
      this.isDriveAmendment = true;
    } else {
      this.selectedFranchiseAccounts = [];
      this.isDriveAmendment = false;
    }

    if (this.amendmentType === DRIVE_FORM_FRANCHISE) {
      this.isDriveFormFrachise = true;
    } else {
      this.isDriveFormFrachise = false;
    }

    if (this.amendmentType != WITHHOLDING_OPT_OUT) {
      this.isFranchiseTypeNotWithholdingOptOut = true;
    } else {
      this.isFranchiseTypeNotWithholdingOptOut = false;
    }

  }

  handleBrandSelection(event) {
    this.selectedBrand = event.detail.value;
    this.contractBrandAssociations.forEach((eachAssociation) => {
      if (eachAssociation["value"] === this.selectedBrand) {
        this.selectedBrandName = eachAssociation["label"];
      }
    });
  }

  /**
   * @description This method is used to control visibility of Brand related fields
   */
  handleChangeForMultipleBrands(event) {
    this.isHavingMultipleBrands = event.detail.value;
    this.getContractBrandAssociationsForCurrentContract(this.contractId);
    if (this.isHavingMultipleBrands === YES_VALUE) {
      this.showBrandQuery2 = true;
      this.showSelectBrand = true;
      this.selectedBrandName = null;
    } else {
      this.showBrandQuery2 = false;
      this.showSelectBrand = false;
    }

  }

  /**
   * @description This method is used to control visibility of Select Brand picklist
   */
  handleChangeToDisplayBrandSelection(event) {
    this.getContractBrandAssociationsForCurrentContract(this.contractId);
    this.isEachFranchiseHavingOwnBrand = event.detail.value;
    if (this.isEachFranchiseHavingOwnBrand === YES_VALUE) {
      this.showSelectBrand = true;
      this.selectedBrandName = null;
    } else {
      this.showSelectBrand = false;
    }
  }

  /**
   * @description This method is used to show Menu Information section if checkbox is checked
   */
  handleIsMenuInformationRequiredChange(event) {
    this.isMenuInformationRequired = !this.isMenuInformationRequired;
  }

  /**
   * @description This method is used to show Tablet Information section based on Order Protocol value
   */
  handleOrderProtocolChange(event) {
    let orderProtocolValue = event.detail.value;
    this.orderProtocolValue = orderProtocolValue;
    this.dynamicFiedSet = Not_RATE_CHANGE_USE_CASE_FIELD_SET_NAME;
    this.isOrderProtocolRelatedToTablet = false;
    if (orderProtocolValue.includes(TABLET_ORDER_PROTOCOL_VALUES)) {
      this.isOrderProtocolRelatedToTablet = true;
      this.dynamicFiedSet = NON_RATE_CHANGE_USE_CASE_WITH_TABLET_FIELDS;
    }
    this.showURLField = false;
    this.isOrderProtocolNotPOS = false;
    this.isOrderProtocolRelatedToPOS = false;
    if (!orderProtocolValue.includes(POS_ORDER_PROTOCOL_VALUES)) {
      this.isOrderProtocolNotPOS = true;
      this.handleReset();
    }
    else {
      this.isOrderProtocolNotPOS = false;
      if (this.oppoortunityStageValue === YES_VALUE) {
        this.isOrderProtocolRelatedToPOS = true;
      }
    }
  }
  /**
   * @description This method used to display the field Default POS Integration ID? when Create Opportunity in "Closed/Won" Stage is set to YES and Order Protocol contains POS values
   */
  handleOpportunityStage(event) {
    let oppoortunityStageValue = event.detail.value;
    this.oppoortunityStageValue = oppoortunityStageValue;
    this.isOrderProtocolRelatedToPOS = false;
    if ((oppoortunityStageValue === YES_VALUE) && (this.orderProtocolValue.includes(POS_ORDER_PROTOCOL_VALUES))) {
      this.isOrderProtocolRelatedToPOS = true;
    }
    else
      this.isOrderProtocolRelatedToPOS = false;
  }
  /**
   * @description This method used to Reset menu setup value on change of Order Protocol field
   */
  handleReset() {
    const inputFields = this.template.querySelectorAll(
      '.menuSetupMethod'
    );
    if (inputFields) {
      inputFields.forEach(field => {
        field.reset();
      });
    }
  }


  /**
   * @description This method used to toast success message and calling urlSelector method.
   */
  handleSuccess(event) {
    var url;
    const toastEvent = new ShowToastEvent({
      title: FORM_SUBMITTED,
      variant: TOAST_VARIENT_SUCCESS
    });
    const responseRecordId = event.detail.id;
    this.globalResponseRecordId = responseRecordId;
    getEncryptedResponseId({
      merchantPopUpResponseId: this.globalResponseRecordId
    })
      .then((data) => {
        this.globalEncryptedId = data;
        const parmeterWithResponseId =
          this.urlParameter + this.globalEncryptedId;
        this.dispatchEvent(toastEvent);
        this.urlSelector(this.corporateCountryValue);
        if (this.countries.includes(this.corporateCountryValue)) {
          url = this.urlToGetApproval + parmeterWithResponseId;
          this.urlToGetApproval = url;
          this.updateUrlOnResponse();
          const valueChangeEvent = new CustomEvent(RECORD_ID_LOG_EVENT, {
            detail: {
              url
            }
          });
          this.dispatchEvent(valueChangeEvent);
        } else {
          createLog({
            lwcName: LWC_NAME,
            methodName: HANDLE_SUCCESS_METHOD_NAME,
            message: COUNTRY_IS_NOT_POPULATED
          });
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: HANDLE_SUCCESS_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
        const toastEventForFailure = new ShowToastEvent({
          title: TOAST_TITLE_ERROR,
          variant: TOAST_VARIENT_ERROR
        });
        this.dispatchEvent(toastEventForFailure);
      });
  }

  /**
   * @description Captures event triggered on change of MX Corporate Account.
   */
  fetchChildFranchiseAccounts(event) {
    // eslint-disable-next-line eqeqeq
    this.franchiseAccounts = [];
    this.popupCorporateAccount = event.detail.value;
    if (event.target.value) {
      this.externalIdSource = MDS_SOURCE;
      this.getFranchiseAccountsOnCorporateAccountSelection(event.target.value);
    } else {
      this.franchiseAccounts = [];
    }
  }

  /**
   * @description Captures the event dispatched on updates to selected list of values in
   * the multi select picklist.
   */
  handleFranchiseAccountsSelection(event) {
    this.selectedFranchiseAccounts = [];
    event.detail.value.forEach((eachValue) => {
      this.selectedFranchiseAccounts.push(eachValue);
    });
    if (this.selectedFranchiseAccounts.length > 0) {
      this.isSaveDisabled = false;
    }
  }

  /**
   * @description Captures the event dispatched on updates to selected list of values in
   * the multi select picklist.
   */
  handleChangeOnPrefillBusinessName(event) {
    if (event.detail.value === YES_VALUE) {
      this.isExternalBusinessIdRequired = true;
    } else {
      this.isExternalBusinessIdRequired = false;
    }
  }

  /**
   * @description This method used to submit record into database.
   */
  handleSubmit(event) {
    this.dispatchEvent(new CloseActionScreenEvent());
    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;
    fields.Contract__c = this.contractId;
    fields.Form_Type__c = this.formSelector;
    this.showAllLayout = false;
    fields.Mx_Corporate_Account__c = this.popupCorporateAccount;
    this.template.querySelector("lightning-record-form").submit(fields);
  }

  /**
   * @description This method used to submit record into database.
   */
  handleRecordEditFormSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    if (this.isInputValid()) {
      const fields = event.detail.fields;
      fields.Contract__c = this.contractId;
      fields.Form_Type__c = this.formSelector;
      fields.Menu_UI_Type__c = this.defaultMenuUITypeValue;
      fields.Should_DashPass_be_included__c = this.shouldDashPassBeIncluded;
      fields.Should_Delivery_be_included__c = this.shouldDeliveryBeIncluded;
      fields.Should_Pickup_be_included__c = this.shouldPickUpBeIncluded;
      fields.Is_Marketplace_Alcohol_Subscription__c = this.isMarketplaceAlcoholSubscription;
      fields.Brand__c = this.selectedBrand;
      fields.Selected_Brand__c = this.selectedBrandName;
      fields.Mx_Corporate_Account__c = this.popupCorporateAccount;
      fields.COO_Exception_Log_Queue_Member_Emails__c = this.emails;
      fields.Business_Vertical__c = this.selectedBusinessVertical;
      fields.Packages_with_Products__c = (this.formSelector === MARKETPLACE) ? this.generateJSON() : null;
      if (fields.Form_Language__c !== FRENCH) {
        fields.Form_Language__c = ENGLISH_LANGUAGE;
      }
      this.formLanguage = fields.Form_Language__c;
      if (
        fields.Send_submission_confirmation_to_emails__c !== null
      ) {
        this.validateEmailIdsEntered(
          fields.Send_submission_confirmation_to_emails__c
        );
        fields.Send_submission_confirmation_to_emails__c =
          this.refinedStringOfEmails;
      }
      if (this.isDrive) {
        fields.Is_Payment_Information_Required__c = this.isPaymentInfoRequired;
      }
      fields.Select_the_Franchise_Type__c = this.amendmentType;
      this.showAllLayout = false;
      this.template.querySelector("lightning-record-edit-form").submit(fields);
      if (this.isRateChange) {
        this.optyClosedWonDays = (fields.Closed_Date_for_Opportunities__c).replace("days", "");
        this.useCase = RATE_CHANGE_USE_CASE;
        this.createOpportunitiesAssociatedToSelectedFranchises();
      }
      if (
        this.isAmendmentTypePermitted &&
        fields.Select_the_Franchise_Type__c === DRIVE_AMENDMENT
      ) {
        this.optyClosedWonDays = (fields.Closed_Date_for_Opportunities__c).replace("days", "");
        this.useCase = fields.Select_the_Franchise_Type__c;
        this.createOpportunitiesAssociatedToSelectedFranchises();
      }
      if (this.showMPBzId) {
        this.dynamicFiedSet = DRIVE_WITHHOLDING_FIELDSET_NAME;
      }
      if (this.amendmentType === WITHHOLDING_OPT_OUT) {
        this.dynamicFiedSet = WITHHOLDING_OPT_OUT_FIELDSET_NAME;
      }
    }
  }

  /**
   * @description This method navigates to the Contract record page on click of the cancel button.
   */
  handleCancel(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.contractId,
        objectApiName: MERCHANT_POP_UP_RESPONSE_OBJECT,
        actionName: VIEW
      }
    });
  }

  /**
   * @description It provides Franchise Account options to users based on their selection.
   */
  handleFranchiseAccountVisibility(event) {
    this.selectedFranchiseAccounts = [];
    if (event.target.value === YES_VALUE) {
      this.showFranchiseOptions = false;
      this.selectAllFranchiseAccounts();
      this.isSaveDisabled = false;
    } else {
      this.showFranchiseOptions = true;
      this.isSaveDisabled = true;
    }
  }

  /**
   * @description This method used to select url based on country and usecase
   */
  urlSelector(countryOfCorporateAccount) {
    var useCase = this.rateChangeOrProductAdditionChecked
      ? RATE_CHANGE
      : FRANCHISE;
    var urlIdentifier = this.formSelector + useCase + countryOfCorporateAccount;
    this.urlToGetApproval = this.formTypeToURLMapping.get(urlIdentifier);
    if (this.formLanguage === FRENCH) {
      urlIdentifier =
        this.formSelector + useCase + countryOfCorporateAccount + FRENCH;
      this.urlToGetApproval = this.formTypeToURLMapping.get(urlIdentifier);
    }
    if (!this.countries.includes(countryOfCorporateAccount)) {
      this.urlToGetApproval = URL_NOT_GENERATED_MESSAGE;
    }
    if (this.amendmentType === WITHHOLDING_OPT_OUT) {
      this.urlToGetApproval = this.formTypeToURLMapping.get(WITHHOLDING_OPT_OUT);
    }
    if ((this.amendmentType === WITHHOLDING_OPT_OUT) && this.formLanguage === FRENCH) {
      this.urlToGetApproval = this.formTypeToURLMapping.get(WITHHOLDING_OPT_OUT_FRENCH);
    }
  }
  optionalProductSelection(event) {
    if (event.target.value === YES_VALUE) {
      this.viewOptionalProductSelection = true;
    } else {
      this.viewOptionalProductSelection = false;
      this.shouldDashPassBeIncluded = false;
      this.shouldPickUpBeIncluded = false;
      this.shouldDeliveryBeIncluded = false;
    }
  }

  /**
   * @description Fetches Subscriptions related to the Contract with following Package(Storefront)
   */
  getSubscriptionsOfContractForOptionalPackage(currentContractId) {
    this.packageOptions.push(this.marketplacePackageOption);
    getSubscriptionsForOptionalPackageSelection({
      contractId: currentContractId
    })
      .then((result) => {
        result.forEach((eachPackage) => {
          const eachPack = { label: eachPackage.toString(), value: eachPackage.toString() };
          switch (eachPackage) {
            case STOREFRONT:
              this.selectedPackages.push(eachPackage.toString());
              this.packageOptions.push(eachPack);
              if (this.contractAccountSegment !== ACCOUNT_SEGMENT_SMB) {
                this.showPackageField = true;
              }
              break;
            case MARKETPLACE:
              this.selectedPackages.push(eachPackage.toString());
              break;
            default:
            //do nothing
          }
        });
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_SUBSCRIPTIONS_FOR_OPTIONAL_PACKAGE_SELECTION,
          message: JSON.stringify(error.body)
        });
      });
  }

  handlePackageChange(event) {
    this.selectedPackages = event.detail.value;
  }

  generateJSON() {
    let packageDetails = [];
    let allPackageValues = this.selectedPackages;
    allPackageValues.forEach(pkg => {
      packageDetails.push({
        packageName: pkg,
        products: (pkg === MARKETPLACE) ? this.showSelectedOptions : ""
      });
    });
    let jsonResult = { packageDetails: packageDetails };
    return JSON.stringify(jsonResult);
  }

  /**
   * @description Fetches Subscriptions related to the Contract with following products(Pickup, Delivery, DashPass)
   */
  getSubscriptionsOfContractForOptionalProduct(currentContractId) {
    getSubscriptionsForOptionalProductSelection({
      contractId: currentContractId
    })
      .then((result) => {
        result.forEach((eachProduct) => {
          switch (eachProduct) {
            case DELIVERY:
              this.productOptions.push(this.deliveryOption);
              break;
            case PICKUP:
              this.productOptions.push(this.pickupOption);
              break;
            case DASHPASS:
              this.productOptions.push(this.dashpassOption);
              break;
            default:
            //do nothing
          }
        });
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_SUBSCRIPTIONS_FOR_OPTIONAL_PRODUCT_SELECTION,
          message: JSON.stringify(error.body)
        });
      });
  }

  handleChangeDualList(e) {
    this.selectedProducts = e.detail.value;
    this.showSelectedOptions = (this.selectedProducts).toString();
    this.selectedProducts.includes(DASHPASS) ? this.shouldDashPassBeIncluded = true : this.shouldDashPassBeIncluded = false;
    this.selectedProducts.includes(PICKUP) ? this.shouldPickUpBeIncluded = true : this.shouldPickUpBeIncluded = false;
    this.selectedProducts.includes(DELIVERY) ? this.shouldDeliveryBeIncluded = true : this.shouldDeliveryBeIncluded = false;
  }

  corporateAccountSelected(event) {
    this.franchiseAccounts = [];
    this.popupCorporateAccount = event.detail.value;
    this.getFranchiseAccountsOnCorporateAccountSelection(
      event.detail.value
    );
    this.loaded = false;
  }
  /**
 * @description Validates the MX Corporate Account and select franchise type lightning comboboxes.
 */
  isInputValid() {
    let isValid = true;
    this.inputFields = this.template.querySelectorAll(".validate");
    this.inputFields.forEach((inputField) => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
      if (this.showPosServiceError) {
        isValid = false;
      }
    });
    return isValid;
  }


  /**
   * @description this shows the field to enter URL if link to existing menu or clone existing menu is selected.
   */
  handleChangeMenuSetupMethod(event) {
    this.menuSetupMethod = event.detail.value;

    if ((this.menuSetupMethod === LINK_TO_EXISTING_MENU) || (this.menuSetupMethod === CLONE_EXISTING_MENU)) {
      this.showURLField = true;
    }
    else {
      this.showURLField = false;
    }
  }

  /**
  * @description Fetches the default Business Vertical of all Marketplace Record
  * and display the fetched result on the Business Vertical field.
  */
  getBusinessVerticalRecord() {
    getBusinessVerticals()
      .then((result) => {
        result.forEach((eachBV) => {
          if (eachBV.Name === RESTAURANT) {
            this.selectedBusinessVertical = eachBV.Id;
          }
        });
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_BUSINESS_VERTICALS,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description This method is used to set Business Vertical and Menu UI Type as per the user selection value
   */
  handleBusinessVerticalSelection(event) {
    const selectedBV = event.detail;
    this.selectedBusinessVertical = selectedBV.id;
    this.getMenuUITypeByBusinessVerticalId(selectedBV.id);
  }

  /**
   * @description Fetches Menu UI Type related to the Business Verticals
   */
  getMenuUITypeByBusinessVerticalId(currentId) {
    getMenuUITypeByBusinessVerticals({
      businessVerticalId: currentId
    })
      .then((result) => {
        this.defaultMenuUITypeValue = result;
        this.isMenuUITypeRetail = false;
        if (this.defaultMenuUITypeValue === RETAIL) {
          this.isMenuUITypeRetail = true;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_MENU_UI_TYPE_BY_BUSINESS_VERTICALS,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description This method is used to get the Applicable Pos Integration field Value.
   */
  getPosIntegrationValue(event) {
    this.applicablePosIntegrationValue = event.detail.value;
    this.handlePosServiceProviderDoNotSupportSelfDelivery();
  }

  /**
   * @description This method is used to get the Self-Delivery field Value.
   */
  getSelfDeliveryValue(event) {
    this.selfDeliveryValue = event.detail.value;
    this.handlePosServiceProviderDoNotSupportSelfDelivery();
  }

  /**
   * @description This Method is used to Validate the Applicable Pos Integration Value
   * which does not support Self delivery and Show Error.
   */
  handlePosServiceProviderDoNotSupportSelfDelivery() {
    if ((this.posServiceProvidersThatDoNotSupportSelfDelivery.includes(this.applicablePosIntegrationValue)
      && this.selfDeliveryValue === YES_VALUE) || this.applicablePosIntegrationValue === '' || this.selfDeliveryValue !== YES_VALUE) {
      this.showPosServiceError = false;
    }
    else {
      this.showPosServiceError = true;
    }
  }
}