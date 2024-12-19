import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dateformatcss from '@salesforce/resourceUrl/RemoveDateFormatcss';

const INVALID_PAYMENT_ACCOUNT = 'Create';
const BRAND_RECORD_PICKER_HELP_TEXT = 'Brands associated with this contract will show up';

export default class SsmoInput extends LightningElement {

@api metadata ={};
@api objectrec = {};
@api allmetadata = [];
@track metadataToDisplay = [];
@api objectapiname = '';
@api genericinput = {};
@api simpleDataDisabled = false;
@api brandfilter;
brandHelpText = BRAND_RECORD_PICKER_HELP_TEXT;
objrec = {...this.objectrec};
fieldName = '';
inputLabel = '';
inputType = '';
isLoaded = false;
invalidPaymentAccount = INVALID_PAYMENT_ACCOUNT;
paymentAccountLink;
paymentAccountName;
returngenericinput = {};
genericPicklistValues = [];


  renderedCallback(){
    Promise.all([
      loadStyle(this, dateformatcss)
    ]).then(() => {
      window.console.log('Files loaded.');
    }).catch(error => {
      window.console.log("Error " + error.body.message);
    });
  }

  connectedCallback() {
    //mapping field values with meta data array
    Object.assign(this.returngenericinput, this.genericinput);
    this.metadataToDisplay = this.allmetadata.map(currentItem => {
      return { ...currentItem,
          value : currentItem.Type__c  == 'Generic Input' ? this.genericinput[currentItem.Field_API_Name__c] : this.objectrec[currentItem.Field_API_Name__c],
          simpleMetadata : currentItem.Type__c  == 'Simple' ? true : false,
          addressMetadata : currentItem.Type__c  == 'Address' ? true : false,
          genericInput : currentItem.Type__c  == 'Generic Input' ? true : false,
          brandRecordPicker : currentItem.Type__c == 'brand record picker' ? true : false,
          genericPicklistInput : currentItem.Type__c  == 'Generic Input' && currentItem.Input_Type__c  == 'picklist' ? true : false,
          genericPicklistInputValues : currentItem.Picklist_Values__c != '' && currentItem.Picklist_Values__c!=null  ? this.generateGenericPicklistValueSet(currentItem.Picklist_Values__c):[],
          emptyBlock : currentItem.Type__c  == 'Empty Block' ? true : false,
          paymentLink : currentItem.Type__c  == 'PaymentAccountLink' ? true : false,
          required : currentItem.Validation__c == 'Required on UI' ? true : false
        };
    });
    this.isLoaded = true;
  }

  /**
  * @description - handle brand record picker event
  */
  handleBrandRecordPicker(event){
    this.dispatchEvent(new CustomEvent('brandrecordpickerchange',{
      detail : {
        Id : event.detail.recordId,
      }
    }))
  }


  /**
  * @description - handle lightning input field change
  */
  handleValueChange(event){
    const fieldName = event.target.dataset.api;
    const fieldValue = event.target.value;
    this.objrec[fieldName] = fieldValue;

    this.dispatchEvent(new CustomEvent('valuechange',{
      detail : {
        objectrec: this.objrec,
        objectapiname : this.objectapiname,
        fieldModified : fieldName,
        isPhototshoot : this.allmetadata[0].Section__c == 'Photoshoot' ? true : false
      }
    }))
  }

  /**
  * @description - handle generic input change
  */
  handleGenericInputChange(event){
    this.returngenericinput[event.target.name] = event.target.value;
    this.dispatchEvent(new CustomEvent('genericvaluechange',{
      detail : {
        section : this.allmetadata[0].Section__c,
        genericdata : this.returngenericinput,
      }
    }))
  }

  /**
  * @description - Handle address change in UI
  */
  handleAddressChange(event){
    let strStreet = event.target.street;
    let strCity = event.target.city;
    let strState = event.target.province;
    let strCountry = event.target.country;
    let strPostalCode = event.target.postalCode;
    this.objrec.BillingAddress = {
      BillingStreet : strStreet,
      BillingCity : strCity,
      BillingState : strState,
      BillingCountry : strCountry,
      BillingPostalCode : strPostalCode
    }
  }

  get simpleMetadata(){
    return this.metadata.Type__c == 'Simple' ? true : false;
  }
  get addressMetadata(){
    return this.metadata.Type__c == 'Address' ? true : false;
  }
  get emptyBlock(){
    return this.metadata.Type__c == 'Empty Block' ? true : false;
  }
  get genericInput(){
    return this.metadata.Type__c == 'Generic Input' ? true : false;
  }
  get paymentLink(){
      return this.metadata.Type__c == 'PaymentAccountLink' ? true : false;
  }

  /**
  * @description - payament account found or not for store
  */
  get isPaymentAccountFound(){
    if(this.objectrec.hasOwnProperty('Account_Payment_Account_Relations__r')){
      this.paymentAccountLink = `${window.location.origin}/${this.objectrec.Account_Payment_Account_Relations__r[0].Payment_Account__r.Id}`;
      this.paymentAccountName = this.objectrec.Account_Payment_Account_Relations__r[0].Payment_Account__r.Name;
      return true;
    }
    return false;
  }

  /**
  * @description - redirect to the payement account on UI
  */
  handlePayementAccountLinkClick(event){
    event.preventDefault();
    window.open(this.paymentAccountLink, '_blank');
  }

  /**
  * @description redirect to create a new payment account
  */
   handleCreatePaymentAccount(event){
    event.preventDefault();
    this.dispatchEvent(new CustomEvent('createpayment'));
  }

  /**
  * @description - send event once the current form loads on UI
  */
  setFormLoad(){
    this.dispatchEvent(new CustomEvent('formload',{
      detail : {
        objectapiname : this.objectapiname,
        isPhototshoot : this.allmetadata[0].Section__c == 'Photoshoot' ? true : false
      }
    }))
  }

  /**
  * @description - generate picklist value set according to string
  */
  generateGenericPicklistValueSet(picklistValueString){
    const valuesArray = picklistValueString.split(';');
    // Map the array to the format required by LWC combobox
    const picklistValues = valuesArray.map(value => {
        return {
            label: value.trim(), // Remove any extra spaces around the value
            value: value.trim()  // Use the trimmed value as both label and value
        };
    });

    return picklistValues;
  }
}