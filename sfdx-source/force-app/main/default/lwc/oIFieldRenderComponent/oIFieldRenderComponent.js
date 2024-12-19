import { LightningElement, api, track, wire } from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import emailValidationError from '@salesforce/label/c.OI_Email_Validation_Error';
import SEPARATOR from '@salesforce/label/c.Separator';
import prePopulateFieldName from '@salesforce/label/c.PrePopulateFieldName';
import seattleZipcodes from '@salesforce/label/c.Seattle_Zipcodes';
import getCountryMetadataFromStore from '@salesforce/apex/OIDataController.fetchCountryStatePicklistValues';
import phoneFormatError from '@salesforce/label/c.OI_Phone_Validation_Error';

const autoPopulateFieldsMapping = new Map([
    ['Address__City__s', 'BillingCity'],
    ['Address__Street__s', 'BillingStreet'],
    ['Address__StateCode__s', 'BillingState'],
    ['Address__CountryCode__s', 'BillingCountry'],
    ['Address__PostalCode__s', 'BillingPostalCode']
]);
const BRAND_API_NAME = 'Brand__c';
const STORE_DETAILS_SCREEN = 'storeDetailsScreen';
export default class OIFieldRenderComponent extends LightningElement {
    @api autoApplyFields;
    @api currentScreen;
    @api sectionFields;
    @track _contractInfo;
    emailValidationError = emailValidationError;
    phoneFormatValidationError = phoneFormatError;
    get contractInfo() {
        return this._contractInfo;
    }

    get countries() {
        return this._countries;
    }

    get states() {
        let stateMap = [];
        if (this._countryToStates && this._countryToStates[this.selectedCountry]) {
            this._countryToStates[this.selectedCountry].forEach(stateName => {
                let stateOption = { label: stateName, value: stateName };
                stateMap.push(stateOption);
            })
        }
        return stateMap;
    }

    @api set contractInfo(contractInfoFromVariable) {
        this._contractInfo = contractInfoFromVariable;
    }
    @track _countries = [];
    _countryToStates = {};
    accountRecordTypeId;
    selectedCountry;
    selectedState;
    accountCountry;

    @api countriesMapTemp;
    @api countryToStatesTemp;

    /*@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    results({ error, data }) {
        if (data) {
            this.accountRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
            //this.accountRecordTypeId = undefined;
        }
    }*/

    /*@wire(getPicklistValues, {
        recordTypeId: "$accountRecordTypeId",
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        console.log('$$ country data ' + data);
        this._countries = data?.values;
        //this._countries = ['United States'];
    }*/

    @wire(getCountryMetadataFromStore)
    wiredCountiresMetadataFromStore({ data, error }) {
        if (data) {
            console.log('== Data : ' + data);
            let countriesMap = [];
            Object.keys(data).forEach(countryName => {
                let countryOption = { label: countryName, value: countryName };
                countriesMap.push(countryOption);
            })
            this._countries = countriesMap;
            this._countryToStates = data;
        }
    }

    /*@wire(getPicklistValues, { recordTypeId: "$accountRecordTypeId", fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }
        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));
        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];

            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }*/


    connectedCallback() {
        console.log(' this.sectionFields ' + JSON.stringify(this.sectionFields));
        if (this.sectionFields) {
            this.sectionFields = this.sectionFields.map(eachData =>
            ({
                ...eachData,
                isText: eachData.OIAttribute__r.Data_Type__c === 'Text',
                isNumber: eachData.OIAttribute__r.Data_Type__c === 'Number',
                isDate: eachData.OIAttribute__r.Data_Type__c === 'Date',
                defaultValue: eachData.OIAttribute__r.Data_Type__c === 'Picklist' ? this.defineDefaultValue(this.definePicklistValue(eachData.OIAttribute__r.Picklist_Values__c, eachData.OIAttribute__r.Field_API_Name__c)) : '',
                isEmail: eachData.OIAttribute__r.Data_Type__c === 'Email', isLongText: eachData.OIAttribute__r.Data_Type__c === 'Long TextArea', isPickList: eachData.OIAttribute__r.Data_Type__c === 'Picklist',
                isPhone: eachData.OIAttribute__r.Data_Type__c === 'Phone',
                isCheckbox: eachData.OIAttribute__r.Data_Type__c === 'Checkbox',
                isDateTime: eachData.OIAttribute__r.Data_Type__c === 'Datetime',
                isPercent: eachData.OIAttribute__r.Data_Type__c === 'Percent',
                isTextArea: eachData.OIAttribute__r.Data_Type__c === 'TextArea',
                isTime: eachData.OIAttribute__r.Data_Type__c === 'Time',
                isURL: eachData.OIAttribute__r.Data_Type__c === 'URL',
                isCountryField: eachData.OIAttribute__r.Data_Type__c === 'AddressCountry',
                isStateField: eachData.OIAttribute__r.Data_Type__c === 'AddressState',
                picklistValues: this.definePicklistValue(eachData.OIAttribute__r.Picklist_Values__c, eachData.OIAttribute__r.Field_API_Name__c),
                isHelptextAvailable: eachData.Attribute_HelpText__c !== undefined
            }));
        }

    }

    /**
     * @description It is used to define default picklist values.
     * @param options
     * @returns
     */
    defineDefaultValue(options) {
        return options.length === 1 ? options[0].value : '';
    }

    /**
     * @description It is used to define picklist values for picklist fields.
     * @param values
     * @param apiName
     * @returns
     */
    definePicklistValue(values, apiName) {
        let options = [];
        let picklistValues = apiName === BRAND_API_NAME ? this._contractInfo.associatedBrands : values;
        if (picklistValues) {
            for (const list of picklistValues.split(';')) {
                const option = {
                    label: list.includes(SEPARATOR) ? list.split(SEPARATOR)[0] : list,
                    value: list.includes(SEPARATOR) ? list.split(SEPARATOR)[1] : list
                };
                options.push(option);
            }
        }
        return options;
    }

    @api getFieldInfo() {
        let formDataArray = [];
        let isValidFormField = true;
        //Read all combo-box fields
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });
        //Read all textbox type fields
        const inputElements = this.template.querySelectorAll('lightning-input'); // Use LWC:Ref
        inputElements.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
                //return { isValidForm: false, formDataArray };
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.checked ? element.checked : element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });
        //Read all textarea fields
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });

        return { isValidForm: isValidFormField, formDataArray };
    }

    @api clearStoreFields() {
        console.log(' === clear field s : this.autoApplyFields ' + JSON.stringify(this.autoApplyFields));
        const inputElements = this.template.querySelectorAll('lightning-input');
        inputElements.forEach((element) => {

            if (this.autoApplyFields === undefined || !this.autoApplyFields.includes(element.dataset.apiName)) {
                console.log(' input fueld : ' + element.dataset.apiName);
                element.value = '';
            }
        });
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((element) => {

            if (this.autoApplyFields === undefined || !this.autoApplyFields.includes(element.dataset.apiName)) {
                console.log(' text area fueld : ' + element.dataset.apiName);
                element.value = '';
            }
        });
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((element) => {

            if (this.autoApplyFields === undefined || !this.autoApplyFields.includes(element.dataset.apiName)) {
                console.log(' combobox fueld : ' + element.dataset.apiName);
                element.value = '';
            }
        });
        this.selectedCountry = '';
        this.selectedState = '';
    }

    @api fillFromInfoFields(dataInfoValues) {
        const inputElements = this.template.querySelectorAll('lightning-input');
        inputElements.forEach((element) => {
            dataInfoValues.forEach((eachElement) => {
                if (eachElement.fieldApiName === element.dataset.apiName) {
                    element.value = eachElement.fieldValue;
                }
            });
        });
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((element) => {
            dataInfoValues.forEach((eachElement) => {
                if (eachElement.fieldApiName === element.dataset.apiName) {
                    element.value = eachElement.fieldValue;
                }
            });
        });
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((element) => {
            dataInfoValues.forEach((eachElement) => {
                if (eachElement.fieldApiName === element.dataset.apiName) {
                    element.value = eachElement.fieldValue;
                }
                if (eachElement.fieldApiName === 'Address__CountryCode__s') {
                    this.selectedCountry = eachElement.fieldValue;
                }
            });
        });
    }

    /**
     * @description It is used to pre populate configured fields from business info.
     * @param businessAccountInfo
     */
    @api prePopulateFields(businessAccountInfo) {
        let autoPopulateFields = prePopulateFieldName.split(',');
        const inputElements = this.template.querySelectorAll('lightning-input');
        inputElements.forEach((element) => {
            if (autoPopulateFields.includes(element.dataset.apiName)) {
                element.value = businessAccountInfo[element.dataset.apiName];
                if (autoPopulateFieldsMapping.has(element.dataset.apiName)) {
                    element.value = businessAccountInfo[autoPopulateFieldsMapping.get(element.dataset.apiName)];
                }
            }
        });
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((element) => {
            if (autoPopulateFields.includes(element.dataset.apiName)) {
                element.value = businessAccountInfo[element.dataset.apiName];
                if (autoPopulateFieldsMapping.has(element.dataset.apiName)) {
                    element.value = businessAccountInfo[autoPopulateFieldsMapping.get(element.dataset.apiName)];
                }
            }
        });
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((element) => {
            if (autoPopulateFields.includes(element.dataset.apiName)) {
                element.value = businessAccountInfo[element.dataset.apiName];
                if (autoPopulateFieldsMapping.has(element.dataset.apiName)) {
                    element.value = businessAccountInfo[autoPopulateFieldsMapping.get(element.dataset.apiName)];
                    if (element.dataset.apiName === 'Address__CountryCode__s') {
                        this.selectedCountry = businessAccountInfo[autoPopulateFieldsMapping.get(element.dataset.apiName)];
                    }
                    if (element.dataset.apiName === 'Address__StateCode__s') {
                        this.selectedState = businessAccountInfo[autoPopulateFieldsMapping.get(element.dataset.apiName)];
                    }
                }
            }
        });
    }

    /**
     * @description It handles input change on conutry field.
     * @param {*} event
     */
    handleCountry(event) {
        this.selectedCountry = event.detail.value;

    }

    /**
     * @description It handles input change on text field.
     * @param {*} event
     */
    handleInputChange(event) {
        let value = event.target.value;
        let seattleZipcodesList = seattleZipcodes.split(',');
        if (this.currentScreen === STORE_DETAILS_SCREEN && event.target.dataset.apiName === 'Address__PostalCode__s' && seattleZipcodesList.includes(value)) {
            this.dispatchEvent(new CustomEvent('showseattledasherdetailssection', {
                detail: true
            }));
        } else if (this.currentScreen === STORE_DETAILS_SCREEN && event.target.dataset.apiName === 'Address__PostalCode__s' && !seattleZipcodesList.includes(value)) {
            this.dispatchEvent(new CustomEvent('showseattledasherdetailssection', {
                detail: false
            }));
        }
    }

    handlePicklistChange(event) {
        if (event.target.dataset.apiName === 'Order_Protocol__c') {
            console.log('order protocol ');
            this.dispatchEvent(new CustomEvent('populateorderprotocolinformation', {
                detail: event.target.value
            }));
        }
    }
    /**
     * @description It handles input change on State field.
     * @param {*} event
     */
    handleState(event) {
        this.selectedState = event.detail.value;
    }

    @api cloneSectionValues(fieldAPIToValueMap) {
        const inputElements = this.template.querySelectorAll('lightning-input');
        inputElements.forEach((inputElements) => {
            inputElements.value = fieldAPIToValueMap.get(inputElements.dataset.apiName);
        });
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((inputElements) => {
            inputElements.value = fieldAPIToValueMap.get(inputElements.dataset.apiName);
        });
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((inputElements) => {
            inputElements.value = fieldAPIToValueMap.get(inputElements.dataset.apiName);
        });
    }

    @api getSectionFieldDetails(index) {
        let formDataArray = [];
        let isValidFormField = true;
        //Read all combo-box fields
        const comboBoxElement = this.template.querySelectorAll('lightning-combobox');
        comboBoxElement.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });
        //Read all textbox type fields
        const inputElements = this.template.querySelectorAll('lightning-input'); // Use LWC:Ref
        inputElements.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
                //return { isValidForm: false, formDataArray };
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.checked ? element.checked : element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });
        //Read all textarea fields
        const textAreaElement = this.template.querySelectorAll('lightning-textarea');
        textAreaElement.forEach((element) => {
            element.setCustomValidity('');
            if (element.validity.valid === false) {
                isValidFormField = false;
            }
            let objStoreData = { inputElement: element, fieldApiName: element.dataset.apiName, fieldValue: element.value, fieldType: element.dataset.fieldType, isNoScenarioSection: element.dataset.noScenarioSection };
            formDataArray.push(objStoreData);
        });


        return { isValidForm: isValidFormField, formDataArray };
    }
}