
import { LightningElement, wire, api } from 'lwc';
import { setMessage, setVariant, showNotification } from 'c/utils';
import createLog from '@salesforce/apex/LogController.createLog';
import getFieldMetadata from '@salesforce/apex/OIDataController.fetchOIMetadataRecords';
import fetchContractDetails from '@salesforce/apex/OIDataController.fetchContractDetails';
import saveMxOnboardingLinkRecord from '@salesforce/apex/OIDataController.saveMxOnboardingLinkRecord';
import getCountryAttributes from '@salesforce/apex/OIDataController.fetchCountryAttributesMetadata';
import fetchOpportunityBasedOnOnboardingScenario from '@salesforce/apex/OIDataController.fetchOpportunityBasedOnOnboardingScenario';
//import getCountryMetadataFromStore from '@salesforce/apex/OIDataController.fetchCountryStateMetadata';

import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import addressValidationError from '@salesforce/label/c.OI_Address_Validation_Error';
import emailValidationError from '@salesforce/label/c.OI_Email_Validation_Error';
import menuURLError from '@salesforce/label/c.OI_Menu_URL_Validation_Error';
import pdoaValidationError from '@salesforce/label/c.OI_PDOA_Validation_Error';
import pdoaBusinessDaysValidationError from '@salesforce/label/c.OI_PDOA_Business_Days_Validation_Error';
import storeFrontWebsiteError from '@salesforce/label/c.OI_Storefront_Website_Validation_Error';
import storeFrontWebsitecharacterError from '@salesforce/label/c.OI_Storefront_Website_Character_Error';
import activateCentrallyError from '@salesforce/label/c.OI_AC_Validation_Error';
import mxRequestedPhotoshootError from '@salesforce/label/c.OI_Photoshoot_Requested_Validation_Error';
import photoshootRequiredFieldsError from '@salesforce/label/c.OI_Photoshoot_Fields_Validation_Error';
import photoshootDateTimeError from '@salesforce/label/c.OI_Photoshoot_Date_Time_Validation_Error';
import birthdateError from '@salesforce/label/c.OI_Birthdate_Validation_Error';
import mxRequestedPhotoshootYesLabel from '@salesforce/label/c.OI_MX_RequestedPhotoshoot_SalesForm_Yes';
import activateCentrallyNoLabel from '@salesforce/label/c.OI_ActivateCentrally_No';
import backButtonWarningMessage from '@salesforce/label/c.Warning_Message_On_Back_Button_in_Onboarding_Inputs';
import backButtonWarningMessageForSelectedPage from '@salesforce/label/c.Warning_Message_For_Selected_OI_Page'
import phoneFormatError from '@salesforce/label/c.OI_Phone_Validation_Error';
import LightningConfirm from 'lightning/confirm';
const ADD_STORE_TITLE = 'addstoretitle';
const ADDRESS_CITY = 'Address__City__s';
const ADDRESS_COUNTRY_CODE = 'Address__CountryCode__s';
const ADDRESS_POSTAL_CODE = 'Address__PostalCode__s';
const ADDRESS_STATE_CODE = 'Address__StateCode__s';
const ADDRESS_STREET = 'Address__Street__s';
const BRAND_API_NAME = 'Brand__c';
const HYPHEN = '-';
const FIELD_VALUE = 'fieldValue';
const NET_NEW_MX_ONBOARDING = 'Net-New Mx Onboarding';
const NET_NEW_MX_ONBOARDING_VALUE = 'Net-New';
const NET_STORE_EXPANSION = 'New Store Expansion';
const NET_STORE_EXPANSION_VALUE = 'NSE';
const PRODUCT_ADDITION = 'Product Addition';
const PRODUCT_ADDITION_VALUE = 'Product Addition';
const LWC_NAME = 'OIBaseComponent';
const PRODUCT_ERROR_MESSAGE = 'The products listed on this contract are not supported in the Onboarding form. Please ensure you are on the correct contract or raise a ticket with BizApps.';
const REP_COLLECTING_MX_BEHALF_SCREEN = 'repCollectingOnMxBehalfScreen';
const REQUIRED_MESSAGE = 'Please fill all the required details!';
const REQUIRED_MESSAGE_MX = 'If you’ve opted to provide Mx details, please fill out all required fields';
const VALIDATION_MESSAGE_MX = 'Please fill out all fields in required format.';
const SAVE_MX_ONBOARDING_LINK_RECORD_METHOD_NAME = 'saveMxOnboardingLinkRecord';
const SEND_MX_ONBOARDING_LINK_SUCCESS_EVENT_NAME = 'sendmxonboardingsuccess';
const MAX_NUMBER_OF_STORES = 10;
const ORDER_PROTOCOL_POS = 'POS';
const YES = 'Yes';
const BACK_BUTTON_WARNING_VARIANT = 'header';
const BACK_BUTTON_WARNING_LABEL = 'Warning';
const BACK_BUTTON_WARNING_THEME = 'warning';
const STORE_DETAILS_SCREEN = 'storeDetailsScreen';
const CONTRACT_OBJECT = 'Contract';
const onboardingScenarios = new Map([
    [NET_NEW_MX_ONBOARDING_VALUE, NET_NEW_MX_ONBOARDING],
    [NET_STORE_EXPANSION_VALUE, NET_STORE_EXPANSION],
    [PRODUCT_ADDITION_VALUE, PRODUCT_ADDITION]
]);
const EMAIL_REGEX = '^[A-Za-z0-9\\._%+\\-]+@[A-Za-z0-9\\.\\-]+\\.[A-Za-z]{2,}$';
export default class OIBaseComponent extends LightningElement {
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    addStoreMessage;
    activateCentrallyValue;
    brandValue;
    emailRecipientElement;
    emailValidationError = emailValidationError;
    loadBackButtonInfo = false;
    backButtonSectionInfo = [];
    backButtonStoreInfo = false;
    businessAccountId;
    businessInfoFieldValueMap = [];
    cityValue;
    contractData;
    countryValue;
    currentScreen = REP_COLLECTING_MX_BEHALF_SCREEN;
    currentStoreScreen = 0;
    disableNextButton = true;
    disableAddStoreButton = true;
    disableMXlinkButton = true;
    errorMessage;
    emailValue = '';
    infoMessage = '';
    showinfoMessage = false;
    isMxInputRequired;
    externalValidationMessage;
    formDataValidity;
    formType = 'SALES FORM';
    inputfields;
    isRequiredMessageDisplay = false;
    loaded = false;
    menuURLValue;
    mxRequestedPhotoshootValue;
    noOfStore = 0;
    orderProtocolValue;
    photoshootDateValue;
    photoshootTimeValue;
    postalCodeValue;
    repCollectingOnMxBehalf;
    requiredMessage;

    showErrorMessage = false;
    showExternalValidationMessage = false;
    showRepCollectingOnMxBehalfScreen = true;
    stateValue;
    storeAddresses = [];
    streetValue;
    storefrontWebsiteValue;
    storefrontMxHasWebsiteValue = false;
    storeSectionFieldValueMap = [];
    totalNumberOfStoresAdded;
    @api contractId;
    @api selectedOnboardingScenario;
    @api opportunityId;
    @api accountId;
    @api objectName;
    tempinputfields = [];
    countriesMap = [];
    countryToStates = [];
    storeNumbers = [];
    disableSubmitInputs = true;
    disableOptions = false;
    countryValidationsMetadata;
    maxStoreCountReached = false;

    /*Get contract object data
    @wire(fetchContractDetails, { contractId: '$contractId' })
    wiredContractData({ data, error }) {
        if (data) {
            this.businessAccountId = data.businessAccountId;
            if (data.productsOnContract !== '') {
                this.loaded = true;
                this.contractData = data;
            }
            else {
                this.disableNextButton = true;
                this.disableAddStoreButton = true;
                this.disableMXlinkButton = true;
                this.loaded = true;
                this.showErrorMessage = true;
                this.errorMessage = PRODUCT_ERROR_MESSAGE;
            }
        } else {
            console.log('error => ' + JSON.stringify(error));
            this.error = error;
        }
    }*/

    /*@wire(getCountryMetadataFromStore)
    wiredCountiresMetadataFromStore({ data,error }) {
        if(data){
            console.log('== Data : ' + data);
            Object.keys(data).forEach(countryName => {
                let countryOption = {label: countryName, value: countryName };
                this.countriesMap.push(countryOption);
            })
            this.countryToStates = data;
        }
    }*/
    connectedCallback() {
        this.fetchContractInfo();
    }

    fetchContractInfo() {
        fetchContractDetails({ contractId: this.contractId, onboardingScenario: this.selectedOnboardingScenario })
            .then(result => {
                console.log('result' + JSON.stringify(result));
                if (result) {
                    this.businessAccountId = result.businessAccountId;
                    console.log('63 ==data==' + JSON.stringify(result));
                    if (result.productsOnContract !== '') {
                        this.loaded = true;
                        this.contractData = result;
                        if (this.onlySalesInputNeeded()) {
                            this.repCollectingOnMxBehalf = 'Yes';
                            this.handleGetData();
                            this.loaded = true;
                            this.disableOptions = true;
                        }
                    }
                    else {
                        this.disableNextButton = true;
                        this.disableAddStoreButton = true;
                        this.disableMXlinkButton = true;
                        this.loaded = true;
                        this.showErrorMessage = true;
                        this.errorMessage = PRODUCT_ERROR_MESSAGE;
                    }
                } else {
                    console.log('error => ' + JSON.stringify(error));
                    this.error = error;
                }
            });
        if (this.objectName == CONTRACT_OBJECT &&
            (this.selectedOnboardingScenario == NET_STORE_EXPANSION_VALUE ||
                this.selectedOnboardingScenario == PRODUCT_ADDITION_VALUE)
        ) {
            this.fetchOpportunityId();
        }
    }

    /**
   * @description To fetch Opportunity Id based on onboarding scenario.
   * @param contractId
   * @param accountId
   * @param onboardingScenario
   * @return Opportunity Id
   */
    fetchOpportunityId() {
        fetchOpportunityBasedOnOnboardingScenario({ contractId: this.contractId, accountId: this.accountId, onboardingScenario: this.selectedOnboardingScenario })
            .then(result => {
                if (result) {
                    this.opportunityId = result;
                } else {
                    this.error = error;
                }
            });
    }
    //Fetch the metadata details based on Product on Contract, Onboardin Scenario, Rep Collection on Behalf of MX, form type
    fetchCountryAttributeDetails() {
        getCountryAttributes().then(result => {
            this.countryValidationsMetadata = result;
        }).catch(error => {
            this.error = error;
        })
    }

    onlySalesInputNeeded() {
        if (this.selectedOnboardingScenario == 'Product Addition' &&
            (this.contractData.productsOnContract == 'Storefront')) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description It gets date after adding the number of passed days.
     * @param dateToAdd
     * @param daysToAdd
     * @return Date
     */
    addDaysToDate(dateToAdd, daysToAdd) {
        let dateOutput = new Date(dateToAdd);
        dateOutput.setDate(dateToAdd.getDate() + daysToAdd);
        return dateOutput;
    }

    /**
     * @description To get address fields value.
     * @param eachElement
     */
    getAddress(eachElement) {
        let apiName = eachElement.fieldApiName;
        switch (apiName) {
            case ADDRESS_CITY:
                this.cityValue = eachElement.fieldValue;
                break;
            case ADDRESS_COUNTRY_CODE:
                this.countryValue = eachElement.fieldValue;
                break;
            case ADDRESS_POSTAL_CODE:
                this.postalCodeValue = eachElement.fieldValue;
                break;
            case ADDRESS_STATE_CODE:
                this.stateValue = eachElement.fieldValue;
                break;
            case ADDRESS_STREET:
                this.streetValue = eachElement.fieldValue;
                break;
            default: this.cityValue = '';
        }
    }

    /**
     * @description It validates that the passed date value is in future by excluding the passed
     * day of the week.
     * @param dateToValidate
     * @return Number
     */
    getDateDiffereneFromTodayByExcludingSunday(dateToValidate, timeToValidate) {
        const todayDate = new Date();
        let endDate = dateToValidate.split('-');
        let arrTime = timeToValidate.split(':');
        let endDateToValidate = new Date(endDate[0], endDate[1] - 1, endDate[2], arrTime[0], arrTime[1]);
        let diff = (endDateToValidate.getTime() - todayDate.getTime()) / 3600000;
        return diff;
    }

    /**
     * @description It is used to get data when Generate Mx Link is called.
     */
    getRecordData() {
        let storeSectionDetails = [];
        if (this.currentScreen === REP_COLLECTING_MX_BEHALF_SCREEN && this.infoMessage === '') {
            this.formDataValidity.forEach((element) => {
                element.formDataArray.forEach((eachFormElement) => {
                    if ((Object.prototype.hasOwnProperty.call(eachFormElement, FIELD_VALUE)) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '') {
                        if (Object.prototype.hasOwnProperty.call(eachFormElement, 'isNoScenarioSection') && eachFormElement.isNoScenarioSection == 'false') {
                            this.businessInfoFieldValueMap.push(eachFormElement);
                        } else if (Object.prototype.hasOwnProperty.call(eachFormElement, 'isNoScenarioSection') && eachFormElement.isNoScenarioSection == 'true') {
                            storeSectionDetails.push(eachFormElement);
                        }
                    }
                });
            });
            if (storeSectionDetails.length > 0) {
                let storeWrapper = { storeNumber: 1, oiFieldWrappers: storeSectionDetails, isStoreForNoRepScenario: true };
                this.storeSectionFieldValueMap.push(storeWrapper);
            }
        } else if (this.currentScreen === STORE_DETAILS_SCREEN && !this.maxStoreCountReached) {
            let storeFieldInfo = this.template.querySelector('c-o-i-section-render-component').getSectionFieldInfo();
            storeFieldInfo.forEach((element) => {
                element.formDataArray.forEach((eachFormElement) => {
                    if ((Object.prototype.hasOwnProperty.call(eachFormElement, FIELD_VALUE)) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '') {
                        storeSectionDetails.push(eachFormElement);
                    }
                }
                );
            });
            let storeWrapper;
            let isWrapperUpdated = false;
            this.storeSectionFieldValueMap.forEach(eachStoreSection => {
                for (const key in eachStoreSection) {
                    // To update existing details
                    if (key === 'storeNumber' && eachStoreSection[key] === this.currentStoreScreen) {
                        eachStoreSection.storeNumber = this.currentStoreScreen;
                        eachStoreSection.oiFieldWrappers = storeSectionDetails;
                        eachStoreSection.isStoreForNoRepScenario = false;
                        isWrapperUpdated = true;
                    }
                }
            })
            if (!isWrapperUpdated) {
                storeWrapper = { storeNumber: this.storeSectionFieldValueMap.length + 1, oiFieldWrappers: storeSectionDetails, isStoreForNoRepScenario: false };
            }
            if (!this.storeNumbers.includes(this.currentStoreScreen) && !isWrapperUpdated) {
                this.storeSectionFieldValueMap.push(storeWrapper);
            }
        }
    }

    /**
     * @description It manages store adding part(collect all saved store and generate new store form).
     */
    handleAddStore() {
        this.scrollToTop();
        let isValidForm = this.validateFormData();
        if (isValidForm === false) {
            this.displayErrorMessage();
        } else {
            this.currentScreen = STORE_DETAILS_SCREEN;
            if (this.currentStoreScreen === 0) {
                this.fetchBusinessInfoSectionDetails();
            }
            this.isRequiredMessageDisplay = false;
            this.template.querySelector('c-o-i-section-render-component').hideBusinessInfoSection();
            this.showRepCollectingOnMxBehalfScreen = false;
            this.dispatchEvent(new CustomEvent(ADD_STORE_TITLE, {
                detail: true
            }));
            // IMPORTANT: To enable store selection screen
            let addstore = this.template.querySelector('c-o-i-section-render-component').addStoreSection(this.orderProtocolValue);
            if (this.isMxInputRequired) {
                this.disableMXlinkButton = false;
            } else {
                this.disableSubmitInputs = false;
            }
            if (this.totalNumberOfStoresAdded === undefined) {
                this.currentStoreScreen = 1;
            }
            else if (this.totalNumberOfStoresAdded === this.currentStoreScreen) {
                this.currentStoreScreen += 1
            }
        }
    }

    /**
     * @description It handles back functionality.
     * @param event
     */
    handleBack(event) {
        const result = LightningConfirm.open({
            message: backButtonWarningMessage,
            variant: BACK_BUTTON_WARNING_VARIANT,
            label: BACK_BUTTON_WARNING_LABEL,
            theme: BACK_BUTTON_WARNING_THEME,
        }).then((result) => {
            if (result || !backButtonWarningMessageForSelectedPage.includes(this.currentScreen)) {
                this.switchToBackPage();
            }
        })

    }
    switchToBackPage() {
        this.scrollToTop();
        this.showExternalValidationMessage = false;
        this.isRequiredMessageDisplay = false;
        this.disableNextButton = false;

        switch (this.currentScreen) {
            case REP_COLLECTING_MX_BEHALF_SCREEN:
                if (this.storeSectionFieldValueMap.length > 0) {
                    this.disableNextButton = false;
                    this.disableAddStoreButton = true;
                } else {
                    this.disableNextButton = true;
                    this.disableAddStoreButton = false;
                }
                this.dispatchEvent(new CustomEvent('hideoibasecomponent', {
                    detail: true
                }));
                break;
            case STORE_DETAILS_SCREEN:

                if (this.currentStoreScreen <= this.storeSectionFieldValueMap.length) {
                    if (this.validateFormData()) {
                        this.fetchStoreInfoSectionDetails();
                    }
                }
                this.currentStoreScreen -= 1;
                if (this.currentStoreScreen === 0) {
                    this.showRepCollectingOnMxBehalfScreen = true;
                    this.dispatchEvent(new CustomEvent(ADD_STORE_TITLE, {
                        detail: false
                    }));
                    if (this.storeSectionFieldValueMap.length === this.currentStoreScreen) {
                        this.disableNextButton = true;
                        this.disableAddStoreButton = false;
                    } else {
                        this.disableNextButton = false;
                        this.disableAddStoreButton = true;
                    }
                    //this.setButtonsVisibility();
                    if (this.storeSectionFieldValueMap.length == 0 && this.repCollectingOnMxBehalf === 'Yes') {
                        this.disableMXlinkButton = true;
                    }
                    this.loaded = false;
                    this.handleGetData();
                    this.currentScreen = REP_COLLECTING_MX_BEHALF_SCREEN;
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.businessInfoFieldValueMap;
                } else {
                    if (this.storeSectionFieldValueMap.length === this.currentStoreScreen) {
                        this.disableNextButton = true;
                        this.disableAddStoreButton = false;
                    } else {
                        this.disableNextButton = false;
                        this.disableAddStoreButton = true;
                    }
                    this.loaded = false;
                    this.handleGetData();
                    this.showRepCollectingOnMxBehalfScreen = false;
                    this.currentScreen = STORE_DETAILS_SCREEN;
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.storeSectionFieldValueMap[this.currentStoreScreen - 1];
                }
                break;
            default: this.showRepCollectingOnMxBehalfScreen = true;
        }

    }

    /**
     * @description It handles cancel functionality.
     */
    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel', {
            detail: true
        }));
    }



    handleEmailChange(event) {
        this.emailRecipientElement = event.target;
        this.emailValue = this.emailRecipientElement.value;
    }

    /**
     * @description It is used to handle rep collecting on mx behalf.
     * @param event
     */
    handleChange(event) {
        this.repCollectingOnMxBehalf = event.target.value;
        this.setButtonsVisibility();
        this.loaded = false;
        this.handleGetData();
        this.fetchCountryAttributeDetails();
    }

    //Fetch metadata configuration info for each sections on radio button(Sales rep filling on behalf mx?) selection
    handleGetData() {
        console.log('**query** this.contractData.productsOnContract' + this.contractData.productsOnContract);
        console.log('**query** this.selectedOnboardingScenario' + this.selectedOnboardingScenario);
        console.log('**query** this.repCollectingOnMxBehalf' + this.repCollectingOnMxBehalf);
        console.log('**query** this.formType' + this.formType);
        getFieldMetadata({ productsOnContract: this.contractData.productsOnContract, onboardingScenario: this.selectedOnboardingScenario, repCollectingOnMxBehalf: this.repCollectingOnMxBehalf, formType: this.formType })
            .then(result => {
                console.log('**query** result' + JSON.stringify(result));
                this.loaded = true;
                if (Object.keys(result.oISectionConditions).length === 0) {
                    console.log('**query** result' + JSON.stringify(result.oISectionConditions));
                    this.disableNextButton = true;
                    this.disableAddStoreButton = true;
                    this.disableMXlinkButton = true;
                    this.showErrorMessage = true;
                    this.errorMessage = PRODUCT_ERROR_MESSAGE;
                    this.loaded = true;
                } else {
                    this.tempinputfields = [];
                    this.inputfields = [];
                    result.oISectionConditions.forEach((element) => {
                        if ((element.Payment_Method__c == 'None' || element.Payment_Method__c.includes(this.contractData.payload['paymentMethod']))
                            && (element.OIAttributesConfigs__r == undefined || element.OIAttributesConfigs__r == null)) {
                            this.infoMessage = 'No inputs are required from you in this scenario. Please generate the Mx form and send to the Mx to gather inputs to initiate onboarding.'
                            this.loaded = true;
                            this.showinfoMessage = true;
                            this.disableAddStoreButton = true;
                            this.disableSubmitInputs = true;
                            this.isMxInputRequired = true;
                            return;
                        } else {
                            this.showinfoMessage = false;
                            this.infoMessage = '';
                            if (element.Mx_Input_Not_Needed__c) {
                                this.isMxInputRequired = false;
                                this.disableMXlinkButton = true;
                                this.disableSubmitInputs = false;
                                this.disableAddStoreButton = true;
                                this.tempinputfields.push(element);
                            } else {
                                if (element.Payment_Method__c != 'None'
                                    && element.Payment_Method__c.includes(this.contractData.payload['paymentMethod'])) {
                                    this.isMxInputRequired = true;
                                    this.tempinputfields.push(element);
                                } else if (element.Payment_Method__c == 'None') {
                                    this.tempinputfields.push(element);
                                    this.isMxInputRequired = true;
                                }
                            }
                        }

                    });
                }
                if (this.tempinputfields.length > 0) {
                    this.inputfields = this.tempinputfields;
                } else if (this.infoMessage == '') {
                    this.disableNextButton = true;
                    this.disableAddStoreButton = true;
                    this.disableMXlinkButton = true;
                    this.showErrorMessage = true;
                    this.disableSubmitInputs = true;
                    this.errorMessage = PRODUCT_ERROR_MESSAGE;
                    this.loaded = true;
                }
                console.log(' this.inputfields ' + JSON.stringify(this.inputfields));
            })
            .catch(error => {
                console.log('168 ==error handlegetdata ==' + JSON.stringify(error));
                this.error = error;
                this.contractData = undefined;
            });
    }

    /**
     * @description It generates Mx Onboarding Link.
     */
    handleGenerateLink() {
        let isValidForm = this.validateFormData();
        if (isValidForm === false) {
            this.scrollToTop();
            this.displayErrorMessage();
        } else {
            this.loaded = false;
            this.triggerMxOnboardingLinkCreation();
        }
    }

    /**
     * @description It handles next functionality.
     */
    handleNext(event) {
        this.scrollToTop();
        this.showExternalValidationMessage = false;
        this.isRequiredMessageDisplay = false;
        let isValidForm = this.validateFormData();
        if (isValidForm === false) {
            this.displayErrorMessage();
        } else {
            switch (this.currentScreen) {
                case REP_COLLECTING_MX_BEHALF_SCREEN:
                    this.currentStoreScreen += 1;
                    if (this.storeSectionFieldValueMap.length > this.currentStoreScreen) {
                        this.disableNextButton = false;
                        this.disableAddStoreButton = true;
                    } else {
                        this.disableNextButton = true;
                        this.disableAddStoreButton = false;
                    }
                    this.showRepCollectingOnMxBehalfScreen = false;
                    this.dispatchEvent(new CustomEvent(ADD_STORE_TITLE, {
                        detail: true
                    }));
                    //this.setButtonsVisibility();
                    this.loaded = false;
                    this.handleGetData();
                    this.currentScreen = STORE_DETAILS_SCREEN;
                    this.businessInfoFieldValueMap = [];
                    this.fetchBusinessInfoSectionDetails();
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.storeSectionFieldValueMap[this.currentStoreScreen - 1];
                    break;
                case STORE_DETAILS_SCREEN:
                    this.fetchStoreInfoSectionDetails();
                    this.currentStoreScreen += 1;
                    this.dispatchEvent(new CustomEvent(ADD_STORE_TITLE, {
                        detail: true
                    }));
                    if (this.storeSectionFieldValueMap.length === this.currentStoreScreen) {
                        this.disableNextButton = true;
                        this.disableAddStoreButton = false;
                    } else {
                        this.disableAddStoreButton = true;
                    }
                    this.loaded = false;
                    this.handleGetData();
                    this.showRepCollectingOnMxBehalfScreen = false;
                    this.currentScreen = STORE_DETAILS_SCREEN;
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.storeSectionFieldValueMap[this.currentStoreScreen - 1];
                default: this.showRepCollectingOnMxBehalfScreen = false;
            }
        }
    }

    /**
     * @description It hides add store functionality.
     * @param event
     */
    hideAddStore(event) {
        this.disableAddStoreButton = true;
        this.maxStoreCountReached = true;
    }

    /**
     * @description It handle store section.
     * @param event
     */
    handleStoreSection(event) {
        if (!this.storeNumbers.includes(event.detail.storeNumber)) {
            let storeWrapper = { storeNumber: event.detail.storeNumber, oiFieldWrappers: event.detail.oiFieldWrappers };
            this.storeSectionFieldValueMap.push(storeWrapper);
            this.totalNumberOfStoresAdded = this.storeSectionFieldValueMap.length;
            this.storeNumbers.push(event.detail.storeNumber);
        } else if (this.storeNumbers.includes(event.detail.storeNumber)) {
            this.storeSectionFieldValueMap[event.detail.storeNumber - 1].oiFieldWrappers = event.detail.oiFieldWrappers;
        }
    }

    /**
     * @description To check whether the passed date is a Sunday.
     * @param dateToValidate
     * @return Boolean
     */
    isSunday(dateToValidate) {
        return dateToValidate.getDay() !== 0;
    }

    populateBusinessDetails() {
        this.template.querySelector('c-o-i-section-render-component').handleFieldPrePopulation(this.contractData.businessAccountInstance);
    }

    /**
     * @description It sets the button(s) visibility on basis of repCollectingOnMxBehalf and Products on Contract.
     */
    setButtonsVisibility() {
        if (this.repCollectingOnMxBehalf === 'Yes' && this.contractData.productsOnContract === 'Drive') {
            this.disableAddStoreButton = true;
            this.disableMXlinkButton = false;
        }
        else if (this.repCollectingOnMxBehalf === 'Yes' && (this.contractData.isMarketplace || this.contractData.isStorefront)) {
            if (this.storeSectionFieldValueMap.length < 1) {
                this.disableMXlinkButton = true;
            }
            this.disableAddStoreButton = false;
        }
        if (this.repCollectingOnMxBehalf === 'No') {
            this.disableAddStoreButton = true;
            this.disableMXlinkButton = false;
        }

        if (this.currentScreen === STORE_DETAILS_SCREEN) {
            if (this.isMxInputRequired) {
                this.disableMXlinkButton = false;
            } else {
                this.disableSubmitInputs = false;
            }
        }

    }

    /**
     * @description It triggers Mx Onboarding Link creation.
     */
    triggerMxOnboardingLinkCreation() {
        this.getRecordData();
        let oiMainDataWrapper = [];
        let mxEmailId;
        if (this.emailRecipientElement != undefined && this.emailRecipientElement != null && this.emailRecipientElement != '') {
            mxEmailId = this.emailRecipientElement.value;
        } else {
            mxEmailId = '';
        }

        let formPayload = {
            accountName: this.contractData.payload.accountName,
            accountId: this.contractData.payload.accountId,
            primaryVertical: this.contractData.payload.primaryVertical,
            paymentMethod: this.contractData.payload.paymentMethod,
            orderProtocol: this.orderProtocolValue,
            isSelfDelivery: this.contractData.payload.isSelfDelivery,
            hasAlcoholPackage: this.contractData.payload.hasAlcoholPackage,
            isActivateCentrallyValue: this.activateCentrallyValue,
            packageName: this.contractData.payload.packageName,
            contractId: this.contractData.payload.contractId,
            brandName: this.brandValue,
            billingCountry: this.contractData.payload.billingCountry,
            billingState: this.contractData.payload.billingState
        };
        oiMainDataWrapper.push(
            {
                businessAccountId: this.businessAccountId,
                isMxInputRequired: this.isMxInputRequired,
                contractId: this.contractId,
                businessInfoWrappers: this.businessInfoFieldValueMap,
                onboardingScenario: this.selectedOnboardingScenario,
                repCollectingOnMxBehalf: this.repCollectingOnMxBehalf,
                storeDataWrappers: this.storeSectionFieldValueMap,
                payload: formPayload,
                emailRecipient: mxEmailId,
                opportunityId: this.opportunityId

            });
        saveMxOnboardingLinkRecord({
            oiMainDataWrapperJSON: JSON.stringify(oiMainDataWrapper)
        })
            .then((result) => {
                // Send active Mx Onboarding Link record.
                if (this.disableSubmitInputs) {
                    this.loaded = true;
                    this.dispatchEvent(
                        new CustomEvent(SEND_MX_ONBOARDING_LINK_SUCCESS_EVENT_NAME, {
                            detail: result
                        })
                    );
                } else {
                    this.loaded = false;
                    this.dispatchEvent(
                        new CustomEvent('mxlinkcreation', {
                            detail: result
                        })
                    );
                }
            })
            .catch((error) => {
                this.loaded = true;
                // To load current screen when Mx Onboarding Link creation failed
                if (this.disableAddStoreButton) {
                    this.currentScreen = REP_COLLECTING_MX_BEHALF_SCREEN;
                    this.showRepCollectingOnMxBehalfScreen = true;
                    this.dispatchEvent(new CustomEvent(ADD_STORE_TITLE, {
                        detail: false
                    }));
                    this.loaded = false;
                    this.handleGetData();
                    this.currentScreen = REP_COLLECTING_MX_BEHALF_SCREEN;
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.businessInfoFieldValueMap;
                } else {
                    this.loaded = false;
                    this.handleGetData();
                    this.showRepCollectingOnMxBehalfScreen = false;
                    this.currentScreen = STORE_DETAILS_SCREEN;
                    this.loadBackButtonInfo = true;
                    this.backButtonSectionInfo = this.storeSectionFieldValueMap[this.currentStoreScreen - 1];
                }
                setMessage(JSON.stringify(error.body.message));
                setVariant(toastVariantError);
                showNotification(this);
                this.setButtonsVisibility();
                createLog({
                    lwcName: LWC_NAME,
                    methodName: SAVE_MX_ONBOARDING_LINK_RECORD_METHOD_NAME,
                    message: JSON.stringify(error.body)
                });
            });
    }

    /**
     * @description It validates form data.
     * @return Boolean
     */
    validateFormData() {
        let isValidForm = true;
        this.showExternalValidationMessage = false;
        this.externalValidationMessage = '';
        let storeAddressKey = '';
        let validBirthDate = false;
        let hasMXReqPhotoshootField = false;
        let currentDate = new Date();
        this.formDataValidity = this.template.querySelector('c-o-i-section-render-component').getSectionFieldInfo();
        let selectedCountry = this.contractData.payload['billingCountry'];
        let paymentCountry = this.contractData.payload['billingCountry'];
        isValidForm = this.validateMxRecipientEmail();

        this.formDataValidity.forEach((element) => {
            if (element.isValidForm === false) {
                isValidForm = false;
            }
            element.formDataArray.forEach((eachElement) => {
                if (eachElement.fieldApiName === BRAND_API_NAME) {
                    this.brandValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Menu_URL__c') {
                    this.menuURLValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Mx_Requested_Photoshoot__c') {
                    hasMXReqPhotoshootField = true;
                    this.mxRequestedPhotoshootValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Order_Protocol__c') {
                    this.orderProtocolValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Storefront_Mx_Has_Website__c') {
                    this.storefrontMxHasWebsiteValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Storefront_Website__c') {
                    this.storefrontWebsiteValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Activated_Centrally_AC__c') {
                    this.activateCentrallyValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Photoshoot_Date__c') {
                    this.photoshootDateValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Photoshoot_Time__c') {
                    this.photoshootTimeValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Photoshoot_Contact_Email__c') {
                    this.photoshootContactEmail = eachElement.fieldValue;
                } if (eachElement.fieldApiName === 'Photoshoot_Contact_First_Name__c') {
                    this.photoshootContactFirstName = eachElement.fieldValue;
                } if (eachElement.fieldApiName === 'Photoshoot_Contact_Last_Name__c') {
                    this.photoshootContactLastName = eachElement.fieldValue;
                } if (eachElement.fieldApiName === 'Photoshoot_Contact_Phone__c') {
                    this.photoshootContactPhone = eachElement.fieldValue;
                } if (eachElement.fieldApiName === 'Photoshoot_Contact_Mobile_Phone__c') {
                    this.photoshootContactMobilePhone = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Address__CountryCode__s') {
                    if (eachElement.fieldValue !== undefined) {
                        selectedCountry = eachElement.fieldValue;
                    }
                } if (eachElement.fieldApiName === 'Payment_Address__CountryCode__s') {
                    if (eachElement.fieldValue !== undefined) {
                        paymentCountry = eachElement.fieldValue;
                    }
                }
                if (eachElement.fieldApiName === 'Birthdate__c' || eachElement.fieldApiName === 'Representative_Date_of_Birth__c') {
                    if (eachElement.fieldValue != null &&
                        eachElement.fieldValue != undefined && eachElement.fieldValue != '') {
                        if (new Date(eachElement.fieldValue) > currentDate) {
                            validBirthDate = true;
                        }
                    }
                }
                if (eachElement.fieldApiName === 'Proposed_Date_of_Activation__c') {
                    this.validateProposedDateOfActivation(eachElement.fieldValue, eachElement.inputElement);
                }
                if (eachElement.fieldType === 'Phone') {
                    if (eachElement.fieldApiName == 'Billing_Contact_Phone__c') {
                        this.validatePhoneNumber(eachElement.fieldValue, paymentCountry, eachElement.inputElement);
                    } else {
                        this.validatePhoneNumber(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                    }
                }
                if (eachElement.fieldType === 'Email') {
                    this.validateEmailField(eachElement.fieldValue, eachElement.inputElement);
                }
                if (this.currentScreen === STORE_DETAILS_SCREEN) {
                    this.getAddress(eachElement);
                }
            });
        });
        if (this.currentScreen === STORE_DETAILS_SCREEN) {
            storeAddressKey = '' + this.streetValue + HYPHEN + this.cityValue + HYPHEN + this.stateValue + HYPHEN + this.countryValue + HYPHEN + this.postalCodeValue;
            storeAddressKey = storeAddressKey.toLowerCase().trim();
        }
        // External Message for unique Address
        if (this.currentScreen === STORE_DETAILS_SCREEN && this.storeAddresses.includes(storeAddressKey) && (this.storeAddresses.length < this.currentStoreScreen && this.currentStoreScreen <= MAX_NUMBER_OF_STORES)) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = addressValidationError;
        }
        // External validation for Menu URL
        if (this.currentScreen === STORE_DETAILS_SCREEN && (this.menuURLValue === undefined || this.menuURLValue === null) &&
            this.orderProtocolValue != null && this.orderProtocolValue != undefined &&
            ((this.orderProtocolValue.includes(ORDER_PROTOCOL_POS) && this.mxRequestedPhotoshootValue === mxRequestedPhotoshootYesLabel) || !this.orderProtocolValue.includes(ORDER_PROTOCOL_POS))) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = menuURLError;
        }
        // External validation for Storefront Website
        if (this.storefrontMxHasWebsiteValue === YES && (this.storefrontWebsiteValue === undefined || this.storefrontWebsiteValue === null || this.storefrontWebsiteValue === '')) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = storeFrontWebsiteError;
        }
        // External validation for Storefront Website character limit
        if (this.storefrontWebsiteValue && this.storefrontWebsiteValue.length > 255) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = storeFrontWebsitecharacterError;
        }
        // External validation for Activated Centrally With Top Mx Account
        if (this.currentScreen === REP_COLLECTING_MX_BEHALF_SCREEN && this.activateCentrallyValue === activateCentrallyNoLabel && this.contractData.hasTopMXTagAccount) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = activateCentrallyError;
        }

        // External validation for Mx Requested Photoshoot
        if (this.currentScreen === REP_COLLECTING_MX_BEHALF_SCREEN && this.activateCentrallyValue === activateCentrallyNoLabel && hasMXReqPhotoshootField && (this.mxRequestedPhotoshootValue === undefined || this.mxRequestedPhotoshootValue == '' || this.mxRequestedPhotoshootValue == null)) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = mxRequestedPhotoshootError;
        }
        // External validation for Photoshoot section fields
        if (this.currentScreen === REP_COLLECTING_MX_BEHALF_SCREEN && this.mxRequestedPhotoshootValue === mxRequestedPhotoshootYesLabel) {
            if (this.photoshootContactEmail === '' || this.photoshootContactFirstName === '' || this.photoshootContactLastName === '' ||
                this.photoshootContactPhone === '') {
                isValidForm = false;
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = photoshootRequiredFieldsError;
            }
            if (this.photoshootTimeValue != null && this.photoshootDateValue != null) {
                let hourDifference = this.getDateDiffereneFromTodayByExcludingSunday(this.photoshootDateValue, this.photoshootTimeValue);
                if (hourDifference < 49 || !this.isSunday(new Date(this.photoshootDateValue))) {
                    isValidForm = false;
                    this.showExternalValidationMessage = true;
                    this.externalValidationMessage = photoshootDateTimeError;
                }
            }
        }
        if (validBirthDate) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = birthdateError;
        }
        // Collecting all unique addresses
        if (this.currentScreen === STORE_DETAILS_SCREEN && storeAddressKey !== '' && !this.storeAddresses.includes(storeAddressKey) && isValidForm) {
            this.storeAddresses.push(storeAddressKey);
        }
        if (this.showExternalValidationMessage || !isValidForm) {
            return false;
        } else {
            return true;
        }
        //return isValidForm;
    }

    /**
     * @description It validates PDOA date.
     * @param proposedDateOfActivation : PDOA date entered bu user.
     * @param element : input element being validated.
     */
    validateProposedDateOfActivation(proposedDateOfActivation, element) {
        let daysDifference = -1; //Number of days between PDOA and current date
        let currentDate = new Date(); //Today's date
        let [year, month, day] = proposedDateOfActivation.split('-');
        let proposedDateOfActivationDate = new Date(year, month - 1, day); //Create date from PDOA value entered by user
        proposedDateOfActivationDate.setHours(currentDate.getHours());
        //Adding 1 minute to round off the time
        proposedDateOfActivationDate.setMinutes(currentDate.getMinutes() + 1);
        //Calculate the difference between current date and PDOA date
        while (currentDate <= proposedDateOfActivationDate) {
            let dayOfWeek = currentDate.getDay();
            if (dayOfWeek !== 0 && dayOfWeek !== 6) {
                daysDifference++;
            }
            currentDate.setDate(currentDate.getDate() + 1);
        }
        //Check if the date is falling on weekend or if it is a past date.
        if (daysDifference < 0) {
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = VALIDATION_MESSAGE_MX;
            element.setCustomValidity(pdoaValidationError);
        }
        //Check if the date is 4 business days in future.
        else if (daysDifference <= 4) {
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = VALIDATION_MESSAGE_MX;
            element.setCustomValidity(pdoaBusinessDaysValidationError);
        } else {
            element.setCustomValidity('');
        }
        element.reportValidity();
    }

    /**
     * @description It validates phone number format.
     */
    validatePhoneNumber(phoneNumberEntered, selectedCountry, element) {
        if (phoneNumberEntered != '' && phoneNumberEntered != null) {
            if (isNaN(phoneNumberEntered)) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = phoneFormatError;
                element.setCustomValidity(phoneFormatError);
            } else {
                let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
                let phoneNumberValidated = phoneNumberEntered.match(selectedCountryValidations.Phone_Regex_Match__c);
                if (phoneNumberValidated == null) {
                    this.showExternalValidationMessage = true;
                    this.externalValidationMessage = VALIDATION_MESSAGE_MX;
                    element.setCustomValidity(selectedCountryValidations.Phone_Validation_Error__c);
                } else {
                    element.setCustomValidity('');
                }
            }
        } else {
            element.setCustomValidity('');
        }
        element.reportValidity();
    }

    /**
     * @description It validates the Mx Email recipient.
     * @returns True if the email is valid, false otherwise.
     */
    validateMxRecipientEmail() {
        if (this.isMxInputRequired) {
            if (this.emailRecipientElement === undefined ||
                (this.emailRecipientElement !== undefined && this.emailRecipientElement.value == null)) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = REQUIRED_MESSAGE_MX;
                return false;
            } else if (this.emailRecipientElement.value.match(EMAIL_REGEX) == null) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = VALIDATION_MESSAGE_MX;
                this.emailRecipientElement.setCustomValidity(emailValidationError);
                this.emailRecipientElement.reportValidity();
                return false;
            } else {
                this.emailRecipientElement.setCustomValidity('');
                this.emailRecipientElement.reportValidity();
                return true;
            }
        }
        return true;
    }

    /**
     * @description It validates email field format.
     * @param emailEntered - The email entered by the user.
     * @param element - The element where the error message will be displayed.
     */
    validateEmailField(emailEntered, element) {
        if (emailEntered != '') {
            if (emailEntered.match(EMAIL_REGEX) == null) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = VALIDATION_MESSAGE_MX;
                element.setCustomValidity(emailValidationError);
            } else {
                element.setCustomValidity('');
            }
        }
        element.reportValidity();
    }

    /**
     * @description It is used to shift user focus to top of screen in case of error.
     */
    scrollToTop() {
        this.template.querySelector('.scrollpointerdiv').scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    fetchBusinessInfoSectionDetails() {
        this.formDataValidity.forEach((element) => {
            element.formDataArray.forEach((eachFormElement) => {
                if ((Object.prototype.hasOwnProperty.call(eachFormElement, 'fieldValue')) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '' && eachFormElement.fieldValue !== null) {
                    this.businessInfoFieldValueMap.push(eachFormElement);
                }
            });
        });
    }

    fetchStoreInfoSectionDetails() {
        let storeSectionDetails = [];
        this.formDataValidity.forEach((element) => {
            element.formDataArray.forEach((eachFormElement) => {
                if ((Object.prototype.hasOwnProperty.call(eachFormElement, 'fieldValue')) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '' && eachFormElement.fieldValue !== null) {
                    storeSectionDetails.push(eachFormElement);
                }
            });
        });
        this.storeSectionFieldValueMap[this.currentStoreScreen - 1].oiFieldWrappers = storeSectionDetails;
    }

    displayErrorMessage() {
        if (this.showExternalValidationMessage) {
            this.isRequiredMessageDisplay = true;
            this.requiredMessage = this.externalValidationMessage;
        } else {
            this.isRequiredMessageDisplay = true;
            this.requiredMessage = REQUIRED_MESSAGE_MX;
        }
    }
}
