import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import getMxOnboarding from '@salesforce/apex/MxOnboardingCommunityController.getMxOnboardingLink';
import getMxFieldMetadata from '@salesforce/apex/OIDataController.fetchOIMetadataRecordsMxForm';
import getCountryAttributes from '@salesforce/apex/OIDataController.fetchCountryAttributesMetadata';
//import emailNotify from '@salesforce/apex/MxOnboardingCommunityController.sendEmail';
import saveMXFormDetails from '@salesforce/apex/MxOnboardingCommunityController.submitMXForm';
import { label } from 'c/customLabelUtility';

const ADDRESS_CITY = 'Address__City__s';
const ADDRESS_COUNTRY_CODE = 'Address__CountryCode__s';
const ADDRESS_POSTAL_CODE = 'Address__PostalCode__s';
const ADDRESS_STATE_CODE = 'Address__StateCode__s';
const ADDRESS_STREET = 'Address__Street__s';
const PROVINCIAL_TAX_ID = 'Provincial_Tax_ID__c';
const CANADA = 'Canada';
const ENGLISH_LANGUAGE = 'en';
const HYPHEN = '-';
const MERCHANT_LINK = 'merchants/';
const QUESTION_MARK_STRING = '?';
const REP_COLLECTING_MX_BEHALF_SCREEN = 'repCollectingOnMxBehalfScreen';
const REQUIRED_MESSAGE = 'Please fill all the required details!';
const VALIDATION_MESSAGE_MX = 'Please fill out all fields in required format.';
const STORE_DETAILS_SCREEN = 'storeDetailsScreen';
const GENERIC_ERROR_MSG_PLACEHOLDER = 'XXX';
const BUSINESS_NAME_PLACEHOLDER = '{businessName}';
const EMAIL_REGEX = '^[A-Za-z0-9\\._%+\\-]+@[A-Za-z0-9\\.\\-]+\\.[A-Za-z]{2,}$';
const COUNTRY_AUSTRALIA = 'Australia';
const COUNTRY_NZ = 'New Zealand';
const COUNTRY_CANADA = 'Canada';
const COUNTRY_UNITED_STATES = 'United States';

const mapCountryToPhoneValidationError = new Map([
    [COUNTRY_AUSTRALIA, label.australiaPhoneValidationError],
    [COUNTRY_CANADA, label.canadaPhoneValidationError],
    [COUNTRY_NZ, label.newZealandPhoneValidationError],
    [COUNTRY_UNITED_STATES, label.unitedStatesPhoneValidationError]
]);

export default class LwcMxOnBoardingCommunity extends LightningElement {
    @track customLabel = label;
    formType = 'Mx FORM';
    formURL = '';
    productsOnContract = '';
    mxFormLanguage = '';
    currentPageReference = null;
    linkId = null;

    inputfields;
    emailRecipientElement;
    tempinputfields = [];
    generalInstructionWithBusinessName;
    @api uuId;
    businessName;
    cityValue;
    countryValue;
    postalCodeValue;

    stateValue;
    storeAddresses = [];
    streetValue;
    loadBackButtonInfo = false;
    backButtonSectionInfo = [];

    businessInfoFieldValueMap = [];
    storeSectionFieldValueMap = [];

    errorMessage;
    formDataValidity;
    isRequiredMessageDisplay = false;

    noOfStore = 0;
    storeSectionCount = 0;
    storeNames = [];
    currentStoreScreen = 0;
    isMaxStore = false;
    currentScreen;

    requiredMessage;
    showErrorMessage = false;

    totalNumberOfStoresAdded = 0;
    isExternalCommunity = true;
    MXOnBoardingLinkData;
    resultPayload;
    parentStoreDetailMap = [];
    loaded = false;
    isFirstScreen = false;
    showInactiveLinkText = false;
    showBack = false;
    titleToDisplay;
    showBannerText = false;

    showSubmitButton = false;
    showAddStore = false;
    showNextButton = true;
    //disableDeleteButton = true;

    hasBusinessInfoFields = false;
    hasStoreInfoFields = false;
    storeDetailCount;
    countryValidationsMetadata;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    connectedCallback() {
        //Fetch the MX onboarding link details from the server
        if (this.linkId != null && this.linkId != undefined && this.mxLinkRecordId === undefined) {
            getMxOnboarding({ uniqueIdentifier: this.linkId })
                .then(result => {
                    if (result != null && result.Status__c === 'Active') {
                        this.MXOnBoardingLinkData = result;
                        this.resultPayload = JSON.parse(result.Payload__c);
                        this.businessName = JSON.parse(result.Payload__c)['accountName'];
                        this.generalInstructionWithBusinessName = this.customLabel.generalInstructionWithBusinessName.replace(BUSINESS_NAME_PLACEHOLDER, this.businessName);
                        this.productsOnContract = JSON.parse(result.Payload__c)['packageName'];
                        this.getMxFormLanguageFromUrl();
                        //get the count of sections which have been entered by MX rep
                        this.sectionsEnteredByRep = this.MXOnBoardingLinkData.Store_Count__c;
                        //Get the name of each store enetered by Sales rep
                        if (result.Store_Details__r != null) {
                            this.storeDetailCount = 0;
                            result.Store_Details__r.forEach(store => {
                                let parentStoreJSON = { storeNumber: this.storeDetailCount, storeId: store.Id, storeName: store.Store_Name__c, isStoreForNoRepScenario: store.Is_Store_For_No_Rep_Scenario__c };
                                this.parentStoreDetailMap.push(parentStoreJSON);
                                this.storeNames.push(store.Store_Name__c);
                                this.storeDetailCount++;
                            })
                        }
                        //Logic to display header
                        if (this.currentScreen === STORE_DETAILS_SCREEN) {
                            this.titleToDisplay = this.customLabel.storeDetails;
                        }
                        else {
                            this.titleToDisplay = this.customLabel.businessDetails;
                        }
                        this.fetchMetadataDetails();
                        this.fetchCountryAttributeDetails();
                    } else {
                        this.showInactiveLinkText = true;
                        this.loaded = true;
                        this.showNextButton = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                });
        } else {
            this.showInactiveLinkText = true;
            this.loaded = true;
            this.showNextButton = false;
        }

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

    //Fetch the metadata details based on Product on Contract, Onboardin Scenario, Rep Collection on Behalf of MX, form type
    fetchMetadataDetails() {
        getMxFieldMetadata({
            productsOnContract: this.productsOnContract,
            onboardingScenario: this.MXOnBoardingLinkData.Onboarding_Scenario__c,
            repCollectingOnMxBehalf: this.MXOnBoardingLinkData.Rep_Collecting_On_Mx_Behalf__c,
            formType: this.formType,
            formLanguage: this.mxFormLanguage
        })
            .then(result => {
                if (Object.keys(result.oISectionConditions).length === 0) {
                    this.showAddStore = false;
                    this.showSubmitButton = false;
                    this.loaded = true;
                }
                else {
                    this.loaded = true;
                    this.isFirstScreen = true;

                    for (let element = 0; element < result.oISectionConditions.length; element++) {
                        if (this.resultPayload !== undefined
                            && result.oISectionConditions[element].Section__c === this.customLabel.paymentContactDetailsSection
                            && this.resultPayload['billingCountry'] != 'Canada') {
                            continue;
                        } else {
                            if (this.productsOnContract.includes('Drive')) {
                                if (result.oISectionConditions[element].Payment_Method__c != 'None'
                                    && result.oISectionConditions[element].Payment_Method__c.includes(this.resultPayload['paymentMethod'])) {
                                    this.tempinputfields.push(result.oISectionConditions[element]);
                                } else if (result.oISectionConditions[element].Payment_Method__c == 'None') {
                                    this.tempinputfields.push(result.oISectionConditions[element]);
                                }
                            } else {
                                this.tempinputfields.push(result.oISectionConditions[element]);
                            }
                            if (result.oISectionConditions[element].Is_it_Store_Section__c == false) {
                                this.hasBusinessInfoFields = true;
                            }
                            if (result.oISectionConditions[element].Is_it_Store_Section__c == true) {
                                this.hasStoreInfoFields = true;
                            }
                        }
                    }
                    this.inputfields = this.tempinputfields;
                    //Logic to hide / show buttons
                    if (!this.hasBusinessInfoFields) {
                        this.currentScreen = STORE_DETAILS_SCREEN;
                        this.showNextButton = false;
                        this.showSubmitButton = true;
                        this.titleToDisplay = this.customLabel.storeDetails;
                        if (this.MXOnBoardingLinkData.Store_Count__c == 0) {
                            this.showAddStore = true;
                            this.currentStoreScreen = 1;
                        } else {
                            this.showAllSectionDetails();
                        }
                    } else if (!this.hasStoreInfoFields) {
                        this.showSubmitButton = true;
                        this.showNextButton = false;
                    } else if (!this.hasBusinessInfoFields && !this.hasStoreInfoFields) {
                        this.showNextButton = false;
                        this.showSubmitButton = false;
                    }
                }
            })
            .catch(error => {
                this.error = error;
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

    //Method to get the URL parameter details
    setParametersBasedOnUrl() {
        this.linkId = this.urlStateParameters.formId || null;
    }

    //Method to be called when Submit button is clicked to store business info and store detail records
    handleSubmit() {
        window.scrollTo(0, 0);
        let isValidForm = this.validateFormData();
        if (isValidForm === false) {
            this.handleErrorMessage();
        } else {
            this.isFirstScreen = false;
            this.titleToDisplay = '';
            this.showBannerText = true;
            this.inputfields = false;
            this.isRequiredMessageDisplay = false;
            this.showSubmitButton = false;
            this.showAddStore = false;

            let sectionDetails = [];
            //storeFieldInfo : stores array of field values from each section
            let storeFieldInfo = this.template.querySelector('c-o-i-section-render-component').getSectionFieldInfo();
            let i = 1;
            let storeCount = 0;

            //Iterate on each section element
            storeFieldInfo.forEach((element) => {
                //Iterate on fields in a section and add it to list "sectionDetails"
                element.formDataArray.forEach((eachFormElement) => {
                    if ((Object.prototype.hasOwnProperty.call(eachFormElement, 'fieldValue')) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '') {
                        sectionDetails.push(eachFormElement);
                    }
                });
                //If there are more than 1 stores entered by Sales Rep, all the stores would be shown on the page
                if (this.MXOnBoardingLinkData.Store_Count__c > 0 && this.hasStoreInfoFields) {
                    //Count of sections in each store is stored in variable storeSectionCount
                    //If the iterator has reached the count of sections, which means all the sections in one store have been parsed
                    //then push the value in storeSectionFieldValueMap and reset sectionDetails and incrementer to start again for next store
                    if (i == this.storeSectionCount) {
                        let storeWrapper = { storeNumber: i, oiFieldWrappers: sectionDetails, parentStoreId: this.parentStoreDetailMap[storeCount].storeId };
                        this.storeSectionFieldValueMap.push(storeWrapper);
                        sectionDetails = [];
                        i = 1;
                        storeCount++;
                    } else {
                        i++;
                    }
                }

            });

            //If there are no stores entered by Sales rep, storeSectionFieldValueMap would have value for all the previous strores added,
            // we need to add details only for the store on the last page
            if (this.MXOnBoardingLinkData.Store_Count__c == 0 && this.hasStoreInfoFields) {
                let noRepScenarioStoreID;
                if (this.parentStoreDetailMap != null && this.parentStoreDetailMap[0].isStoreForNoRepScenario) {
                    noRepScenarioStoreID = this.parentStoreDetailMap[0].storeId;
                }
                let storeWrapper = { storeNumber: this.totalNumberOfStoresAdded + 1, oiFieldWrappers: sectionDetails, parentStoreId: noRepScenarioStoreID };
                this.storeSectionFieldValueMap.push(storeWrapper);
            }
            //If there are no store sections, then business section is the last one,
            //in such scenario do not enter storeSectionFieldValueMap,
            //capture values in businessInfoFieldValueMap
            else if (this.hasBusinessInfoFields && !this.hasStoreInfoFields) {
                this.businessInfoFieldValueMap = sectionDetails;
            }

            let oiMainDataWrapper = [];
            oiMainDataWrapper.push(
                {
                    businessInfoWrappers: this.businessInfoFieldValueMap,
                    storeDataWrappers: this.storeSectionFieldValueMap,
                });
            this.getMxFormLanguageFromUrl();
            saveMXFormDetails({
                oiMainDataWrapperJSON: JSON.stringify(oiMainDataWrapper), mxOnboardingLinkId: this.MXOnBoardingLinkData.Id, emailId: (this.emailRecipientElement !== undefined ? this.emailRecipientElement.value : ''), mxFormLanguage: this.mxFormLanguage
            })
                .then((result) => {
                    this.loaded = true;
                })
                .catch((error) => {
                    this.loaded = true;
                });

        }
    }

    handleEmailChange(event) {
        this.emailRecipientElement = event.target;
    }

    hideLanguageSelector() {
        var languageSelector = document.querySelector(".lwc-7mu983ddh6e-host");
        if (languageSelector) {
            languageSelector.style.display = 'none';
        }
    }

    //Method to capture Next button clicked from business info screen
    handleNext() {
        window.scrollTo(0, 0);
        this.loaded = true;
        let isValidForm = this.validateFormData();
        //let isValidForm = true;
        if (isValidForm === false) {
            this.handleErrorMessage();
        } else {
            this.hideLanguageSelector();
            this.titleToDisplay = this.customLabel.storeDetails;
            this.isRequiredMessageDisplay = false;
            this.showNextButton = false;
            this.isFirstScreen = false;
            this.hideBusinessDetailsScreen();
            if (this.MXOnBoardingLinkData.Store_Count__c > 0) {
                this.showAllSectionDetails();
                this.showSubmitButton = true;
                this.showAddStore = false;
            } else {
                this.showAddStore = true;
                this.showSubmitButton = true;
                this.handleAddStore();
            }
            this.currentScreen = STORE_DETAILS_SCREEN;
        }
    }

    //method to hide business info screen when next button is clicked
    hideBusinessDetailsScreen() {

        this.formDataValidity.forEach((element) => {
            element.formDataArray.forEach((eachFormElement) => {
                if ((Object.prototype.hasOwnProperty.call(eachFormElement, 'fieldValue')) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '' && eachFormElement.fieldValue !== null) {
                    this.businessInfoFieldValueMap.push(eachFormElement);
                }
            });
        });
        this.isRequiredMessageDisplay = false;
        this.template.querySelector('c-o-i-section-render-component').hideBusinessInfoSection();

    }

    //method to show details for all the sections if mx onboarding link has stores entered by Sales rep
    showAllSectionDetails() {
        this.template.querySelector('c-o-i-section-render-component').setLoadAllStoreInfo(this.MXOnBoardingLinkData.Store_Count__c, this.storeNames);
    }


    //Method to add new store, scenario when there are no stores enetered by Sales rep
    handleAddStore() {
        window.scrollTo(0, 0);
        this.isFirstScreen = false;
        let isValidForm = this.validateFormData();
        if (isValidForm === false) {
            this.handleErrorMessage();
        } else {
            this.hideLanguageSelector();
            this.isRequiredMessageDisplay = false;
            let addstore = this.template.querySelector('c-o-i-section-render-component').addStoreSection();
            if (this.totalNumberOfStoresAdded === 0) {
                this.currentStoreScreen = 1;
                //this.disableDeleteButton = true;
            }
            else if (this.totalNumberOfStoresAdded === this.currentStoreScreen) {
                this.showBack = true;
                this.currentStoreScreen += 1
                //this.disableDeleteButton = false;
            }

            if (this.currentStoreScreen == 10) {
                this.isMaxStore = true;
                this.showSubmitButton = true;
            }
        }
    }

    //Validate the form for all the required fields
    validateFormData() {
        let isValidForm = true;
        this.showExternalValidationMessage = false;
        let storeAddressKey = '';
        this.formDataValidity = this.template.querySelector('c-o-i-section-render-component').getSectionFieldInfo();
        let hasMXReqPhotoshootField = false;
        let hasMenuURLField = false;
        let currentDate = new Date();
        let paymentCountry = this.resultPayload['billingCountry'];
        let selectedCountry = this.resultPayload['billingCountry'];
        isValidForm = this.validateMxRecipientEmail();

        this.formDataValidity.forEach((element) => {
            if (element.isValidForm === false) {
                isValidForm = false;
            }
            element.formDataArray.forEach((eachElement) => {
                if (eachElement.fieldApiName === 'Menu_URL__c') {
                    hasMenuURLField = true;
                    this.menuURLValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Mx_Requested_Photoshoot__c') {
                    hasMXReqPhotoshootField = true;
                    this.mxRequestedPhotoshootValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Storefront_Mx_Has_Website__c') {
                    this.storefrontMxHasWebsiteValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Storefront_Website__c') {
                    this.storefrontWebsiteValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Photoshoot_Date__c') {
                    this.photoshootDateValue = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Photoshoot_Time__c') {
                    this.photoshootTimeValue = eachElement.fieldValue;
                } if (eachElement.fieldApiName === 'Photoshoot_Contact_Email__c') {
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
                //Validate SSN Last 4 digits
                if (eachElement.fieldApiName === 'SSN_Last_4Digits__c' && eachElement.fieldValue != null &&
                    eachElement.fieldValue != undefined && eachElement.fieldValue != '') {
                    if (eachElement.fieldValue.length != 4) {
                        this.showExternalValidationMessage = true;
                        eachElement.inputElement.setCustomValidity(this.customLabel.ssnError);
                    } else {
                        eachElement.inputElement.setCustomValidity('');
                    }
                }
                //Validate birthdate as future date
                if (eachElement.fieldApiName === 'Birthdate__c' || eachElement.fieldApiName === 'Representative_Date_of_Birth__c') {
                    if (eachElement.fieldValue != null &&
                        eachElement.fieldValue != undefined && eachElement.fieldValue != '') {
                        if (new Date(eachElement.fieldValue) > currentDate) {
                            this.showExternalValidationMessage = true;
                            eachElement.inputElement.setCustomValidity(this.customLabel.birthdateError);
                        } else {
                            eachElement.inputElement.setCustomValidity('');
                        }
                    }
                }
                if (eachElement.fieldApiName === 'Address__CountryCode__s') {
                    if (eachElement.fieldValue !== undefined && eachElement.fieldValue !== null && eachElement.fieldValue !== '') {
                        selectedCountry = eachElement.fieldValue;
                    }
                }
                if (eachElement.fieldApiName === 'Payment_Address__CountryCode__s') {
                    if (eachElement.fieldValue !== undefined && eachElement.fieldValue !== null && eachElement.fieldValue !== '') {
                        paymentCountry = eachElement.fieldValue;
                    }
                }
                if (eachElement.fieldApiName === PROVINCIAL_TAX_ID) {
                    if (selectedCountry == CANADA) {
                        this.validateProvincialTaxId(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                    }
                }
                if (eachElement.fieldApiName === 'Tax_ID__c') {
                    this.validateTaxId(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                } if (eachElement.fieldApiName === 'Institution_Number__c') {
                    this.validateInstitutionNumber(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                } if (eachElement.fieldApiName === 'Routing_Number__c') {
                    this.validateRoutingNumber(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                } if (eachElement.fieldApiName === 'Bank_Account_Number__c') {
                    this.validateBankAccountNumber(eachElement.fieldValue, selectedCountry, eachElement.inputElement);
                } if (eachElement.fieldType === 'Phone') {
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
                eachElement.inputElement.reportValidity();
            });
        });
        if (this.currentScreen === STORE_DETAILS_SCREEN) {
            storeAddressKey = '' + this.streetValue + HYPHEN + this.cityValue + HYPHEN + this.stateValue + HYPHEN + this.countryValue + HYPHEN + this.postalCodeValue;
            storeAddressKey = storeAddressKey.toLowerCase().trim();
        }

        // External Message for unique Address
        if (this.currentScreen === STORE_DETAILS_SCREEN && this.storeAddresses.includes(storeAddressKey) && (this.storeAddresses.length < this.currentStoreScreen)) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = this.customLabel.addressValidationError;
        }
        // External validation for Menu URL
        if (this.currentScreen === STORE_DETAILS_SCREEN && ((this.resultPayload['orderProtocol'].includes('POS') && this.mxRequestedPhotoshootValue === this.customLabel.mxRequestedPhotoshootYesLabel) || !this.resultPayload['orderProtocol'].includes('POS'))
            && hasMenuURLField && (this.menuURLValue === undefined || this.menuURLValue === null || this.menuURLValue === '')) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = this.customLabel.menuURLError;
        }
        // External validation for Storefront Website
        if (this.currentScreen === STORE_DETAILS_SCREEN && this.storefrontMxHasWebsiteValue == 'Yes' && (this.storefrontWebsiteValue === undefined || this.storefrontWebsiteValue === null || this.storefrontWebsiteValue === '')) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = this.customLabel.storeFrontWebsiteError;
        }
        // External validation for Mx Requested Photoshoot
        if (this.currentScreen !== STORE_DETAILS_SCREEN && this.resultPayload['isActivateCentrallyValue'] === this.customLabel.activateCentrallyNoLabel && hasMXReqPhotoshootField && (this.mxRequestedPhotoshootValue === undefined || this.mxRequestedPhotoshootValue === '')) {
            isValidForm = false;
            this.showExternalValidationMessage = true;
            this.externalValidationMessage = this.customLabel.mxRequestedPhotoshootError;
        }
        // External validation for Photoshoot section fields
        if (this.mxRequestedPhotoshootValue === this.customLabel.mxRequestedPhotoshootYesLabel) {
            if (this.photoshootContactEmail === '' || this.photoshootContactFirstName === '' || this.photoshootContactLastName === '' ||
                this.photoshootContactPhone === '') {
                isValidForm = false;
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.photoshootRequiredFieldsError;
            }
            if (this.photoshootTimeValue != null && this.photoshootDateValue != null) {
                let hourDifference = this.getDateDiffereneFromTodayByExcludingSunday(this.photoshootDateValue, this.photoshootTimeValue);
                if (hourDifference < 49 || !this.isSunday(new Date(this.photoshootDateValue))) {
                    isValidForm = false;
                    this.showExternalValidationMessage = true;
                    this.externalValidationMessage = this.customLabel.photoshootDateTimeError;
                }
            }
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
    }

    /**
     * @description It validates tax ID format.
     */
    validateTaxId(taxIdValue, selectedCountry, element) {
        // External validation for Tax ID
        if (taxIdValue !== undefined) {
            let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
            let taxIDTotalDigits = selectedCountryValidations.Tax_ID_Total_Digits__c;
            if (isNaN(taxIdValue) || taxIdValue.length != taxIDTotalDigits) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                let error = this.customLabel.genericTaxIdValidationError.replace(GENERIC_ERROR_MSG_PLACEHOLDER, taxIDTotalDigits);
                element.setCustomValidity(error);
            } else {
                element.setCustomValidity('');
            }
        }
    }

    /**
     * @description It validates Provincial Tax Id format.
     */
    validateProvincialTaxId(provincialTaxIdValue, selectedCountry, element) {
        if (provincialTaxIdValue !== undefined) {
            let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
            let provincialTaxIdValidated = provincialTaxIdValue.match(selectedCountryValidations.Provincial_Tax_ID_Regex__c);
            if (provincialTaxIdValidated == null) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                element.setCustomValidity(this.customLabel.genericProvincialTaxIdValidationError);
            } else {
                element.setCustomValidity('');
            }
        }
    }

    /**
     * @description It validates bank account number format.
     */
    validateBankAccountNumber(bankAccountNumber, selectedCountry, element) {
        // External validation for Bank Account Number
        if (bankAccountNumber !== undefined) {
            let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
            let bankAccountNumberValidated = bankAccountNumber.match(selectedCountryValidations.Bank_Account_Number_Regex__c);
            if (bankAccountNumberValidated == null) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                element.setCustomValidity(this.customLabel.genericBankAccountNumberValidationError);
            } else {
                element.setCustomValidity('');
            }
        }
    }

    /**
     * @description It validates institution number.
     */
    validateInstitutionNumber(institutionNumberValue, selectedCountry, element) {
        // External validation for Institution Number
        if (institutionNumberValue !== undefined) {
            let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
            let instituteTotalDigits = selectedCountryValidations.Institution_Number_Total_Digits__c;
            if (isNaN(institutionNumberValue) || institutionNumberValue.length != instituteTotalDigits) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                let error = this.customLabel.genericnstitutionNumberValidationError.replace(GENERIC_ERROR_MSG_PLACEHOLDER, instituteTotalDigits);
                element.setCustomValidity(error);
            } else {
                element.setCustomValidity('');
            }
        }
    }

    /**
     * @description It validates routing number format.
     */
    validateRoutingNumber(routingNumberValue, selectedCountry, element) {
        // External validation for Routing Number
        if (routingNumberValue !== undefined) {
            let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
            let routingNumberTotalDigits = selectedCountryValidations.Routing_Number_Total_Digits__c;
            let routingRestrictedStartingNumber;
            if (selectedCountryValidations.Routing_Number_Restricted_Starting_Digit__c !== undefined) {
                routingRestrictedStartingNumber = selectedCountryValidations.Routing_Number_Restricted_Starting_Digit__c.split(',');
            }
            if (isNaN(routingNumberValue) || routingNumberValue.length != routingNumberTotalDigits) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                let error = this.customLabel.genericRoutingNumberValidationError.replace(GENERIC_ERROR_MSG_PLACEHOLDER, routingNumberTotalDigits);
                element.setCustomValidity(error);
            } else if (routingRestrictedStartingNumber != null && routingRestrictedStartingNumber.includes(routingNumberValue[0])) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                let startingDigitsText = '';
                routingRestrictedStartingNumber.forEach(number => {
                    startingDigitsText += '"' + number + '" or ';
                });
                startingDigitsText = startingDigitsText.substring(0, startingDigitsText.length - 4);
                let error = this.customLabel.genericRoutingNumberStartDigitsValidationError.replace(GENERIC_ERROR_MSG_PLACEHOLDER, startingDigitsText);
                element.setCustomValidity(error);
            } else {
                element.setCustomValidity('');
            }
        }
    }

    /**
     * @description It validates phone number format.
     */
    validatePhoneNumber(phoneNumberEntered, selectedCountry, element) {
        if (phoneNumberEntered != '' && phoneNumberEntered != null) {
            if (isNaN(phoneNumberEntered)) {
                this.showExternalValidationMessage = true;
                this.externalValidationMessage = this.customLabel.phoneFormatError;
                element.setCustomValidity(this.customLabel.phoneFormatError);
            } else {
                let selectedCountryValidations = this.countryValidationsMetadata[selectedCountry];
                let phoneNumberValidated = phoneNumberEntered.match(selectedCountryValidations.Phone_Regex_Match__c);
                if (phoneNumberValidated == null) {
                    this.showExternalValidationMessage = true;
                    this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                    element.setCustomValidity(mapCountryToPhoneValidationError.get(selectedCountry));
                } else {
                    element.setCustomValidity('');
                }
            }
        } else {
            element.setCustomValidity('');
        }
    }

    /**
     * @description It validates the Mx Email recipient.
     * @returns True if the email is valid, false otherwise.
     */
    validateMxRecipientEmail() {
        if (this.emailRecipientElement !== undefined) {
            if (this.emailRecipientElement.value != null && this.emailRecipientElement.value.match(EMAIL_REGEX) == null) {
                this.emailRecipientElement.setCustomValidity(this.customLabel.emailValidationError);
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
                this.externalValidationMessage = this.customLabel.requiredFormatValidationError;
                element.setCustomValidity(this.customLabel.emailValidationError);
            } else {
                element.setCustomValidity('');
            }
        }
        element.reportValidity();
    }

    //Once the next section is rendered, update storeSectionFieldValueMap with the values from all the previous stores and update the store count
    handleStoreSection(event) {
        let noRepScenarioStoreID;
        if (this.parentStoreDetailMap != null && this.parentStoreDetailMap[0].isStoreForNoRepScenario) {
            noRepScenarioStoreID = this.parentStoreDetailMap[0].storeId;
        }
        let storeWrapper = { storeNumber: event.detail.storeNumber, oiFieldWrappers: event.detail.oiFieldWrappers, parentStoreId: noRepScenarioStoreID };
        this.storeSectionFieldValueMap.push(storeWrapper);
        this.totalNumberOfStoresAdded = this.storeSectionFieldValueMap.length;
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
     * @description To check whether the passed date is a Sunday.
     * @param dateToValidate
     * @return Boolean
     */
    isSunday(dateToValidate) {
        return dateToValidate.getDay() !== 0;
    }

    //Method to store error message on page
    handleErrorMessage() {
        if (this.showExternalValidationMessage) {
            this.isRequiredMessageDisplay = true;
            this.requiredMessage = this.externalValidationMessage;
        } else {
            this.isRequiredMessageDisplay = true;
            this.requiredMessage = this.customLabel.requiredValidationError;
        }
    }

    /**
     * @description It is used to get the current Mx From Language from the form URL.
     */
    getMxFormLanguageFromUrl() {
        this.formURL = window.location.href;
        this.mxFormLanguage = this.formURL.substring((this.formURL.indexOf(MERCHANT_LINK) + 10), (this.formURL.indexOf(MERCHANT_LINK) + 12));
        if (this.mxFormLanguage.includes(QUESTION_MARK_STRING)) {
            this.mxFormLanguage = ENGLISH_LANGUAGE;
        }
    }

    saveDisplayedStoreSectionCount(event) {
        this.storeSectionCount = event.detail.message;
    }
}
