import { LightningElement, api, wire } from "lwc";
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/Progress_indicator_Event__c';
import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import MX_ORDER_OBJECT from '@salesforce/schema/MX_Order__c';
import RETURN_REASON from '@salesforce/schema/MX_Order__c.Reason_for_Replacement__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
export default class GuidedFlowPickList extends LightningElement {
    @api options;
    @api pickListValue;
    @api pickListLabel;
    @api placeholder;
    @api isRequired;
    @api selectedValue;
    @api outPutValue;
    @api isDisabled;
    @api isProgressIndicator;
    @api errorMessage; //Please select a choice.
    @api objectName;
    @api pickListFieldName;
    @api parentPickListValue;
    @api otherOption;
    @api otherReason;
    @api otherReasonValue;
    @api otheOptionFieldLabel;
    @api otheOptionFieldVariant;
    @api pickListName;
    selectOther = false;
    valueForOtherPicklist = '';
    placeholder = '--None--';
    selectedOptions;
    _countries = [];
    _countryToStates = {};
    _ReturnReason = [];
    selectedCountry;
    selectedState;
    recordTypeDeafult;
    /**
    * @description Read message channel context
    */
    @wire(MessageContext)
    messageContext;
    /**
    * @description Validating Picklist values
    */
    connectedCallback() {
        console.log('this.otherOption=',this.otherOption);
        console.log('(this.pickListValue=',this.pickListValue);
        //if (this.otherReasonValue)

        if (this.otherOption && this.pickListValue && this.otherOption===this.pickListValue) {
            this.valueForOtherPicklist = this.otherReasonValue;
            this.selectOther = true;
        }
        if (this.options) {
            this.selectedOptions = JSON.parse(this.options);
        }
        if (this.pickListFieldName === 'Country') {
            this.selectedOptions = this.countries;
        }
        if (this.pickListFieldName === 'State') {
            this.selectedOptions = this.states;
        }
        if (this.pickListFieldName === 'ReturnReason') {
            //this.placeholder = '--None--';
            this.selectedOptions = this.ReturnReason;
        }
    }
    handleInputChange(event) {
        this.valueForOtherPicklist = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('otherReason', event.detail.value);
        this.dispatchEvent(attributeChangeEvent);
    }
    /**
    * @description Picklist Value change event
    */
    handleChange(event) {
        event.preventDefault();
        this.pickListValue = event.detail.value;
        if (this.pickListValue === this.otherOption) {
            this.selectOther = true;
        } else {
            this.selectOther = false;
            this.valueForOtherPicklist = '';
        }
        if (this.pickListLabel === 'Request Type') {
            const payload = { progressIndicator: this.pickListValue };
            publish(this.messageContext, recordSelected, payload);
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('outPutValue', event.detail.value);
        this.dispatchEvent(attributeChangeEvent);
    }
    /**
    * @description Get Object Inforamation
    */
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;
    get defaultRecordTypeId() {
        //this.placeholder = 'Select Progress';
        return this.objectInfo.data.defaultRecordTypeId;
    }
    /**
    * @description Get Object Record Type Details
    */
    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        this._countries = data?.values;
    }
    /**
    * @description Get default record type picklist
    */
    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }
        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));
        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];
            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
        if (this.pickListFieldName === 'State') {
            this.selectedOptions = this._countryToStates[this.parentPickListValue] || [];
        }
    }
    /*Get PickList Value From MX_ORDER*/
    @wire(getObjectInfo, { objectApiName: MX_ORDER_OBJECT })
    objectMxOrderInfo;
    get defaultMxOrderRecordTypeId() {
        return this.objectMxOrderInfo.data.defaultRecordTypeId;
    }
    @wire(getPicklistValues, {
        recordTypeId: '$defaultMxOrderRecordTypeId',
        fieldApiName: RETURN_REASON
    })
    wiredReturnReason({ data }) {
        this._ReturnReason = data?.values;
        if (this.pickListFieldName === 'ReturnReason') {
            this.selectedOptions = data?.values;
        }

    }

    /**
    * @description Get country detail
    */
    get countries() {
        return this._countries;
    }
    /**
    * @description Get state details
    */
    get states() {
        return this._countryToStates[this.parentPickListValue] || [];
    }
    /**
    * @description Get state details
    */
    get ReturnReason() {
        return this._ReturnReason;
    }

}