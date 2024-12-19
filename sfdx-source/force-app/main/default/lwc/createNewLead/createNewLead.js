/**
 * @author Deloitte
 * @date 04/16/2024
 * @description JavaScript controller for createNewLead lightning web component.
 */
import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { openTab, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import COUNTRY_CODE from "@salesforce/schema/Lead.CountryCode";
import STATE_CODE from "@salesforce/schema/Lead.StateCode";
import MASTER_RECORD_TYPE_ID from "@salesforce/label/c.MasterRecordTypeId";
const ACTION_NAME_LIST = "list";
const ERROR_TITLE = "Error";
const SUCCESS_TITLE = "Success";
const SUCCESS_MESSAGE = "Lead created";
const LEAD_OBJECT_API_NAME = "Lead";
const LEAD_URL_PREFIX = "/lightning/r/Lead/";
const LEAD_URL_SUFFIX = "/view";
const RECENT_LIST_VIEW = "Recent";
const PAGE_TYPE = "standard__objectPage";

export default class CreateLeadOverride extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectAPIName;
  streetValue;
  cityValue;
  countryValue;
  leadName;
  loaded = false;
  loadingAlternativeText = loading;
  strState;
  postalCodeValue;
  currentTabId;
  countries = [];
  countriesToStates = {};
  states = [];
  createdRecordId;

  /**
  * @description It is used to get the country picklist values.
  * @JIRA# LEM-13415
  */
  @wire(getPicklistValues, {
    recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: COUNTRY_CODE
  })
  wiredCountires({ data }) {
    this.countries = data?.values;
  }

  /**
  * @description It is used to get the state picklist values corresponding to the country selected.
  * @JIRA# LEM-13415
  */
  @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: STATE_CODE })
  wiredStates({ data }) {
    if (!data) {
      return;
    }
    const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));
    this.countriesToStates = data.values.reduce((accumulatedStates, state) => {
      const countryIsoCode = validForNumberToCountry[state.validFor[0]];
      return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
    }, {});
  }

  /**
  * @description It is used to handle the change event of address.
  * @JIRA# LEM-13415
  */
  addressInputChange(event) {
    this.streetValue = event.target.street;
    this.cityValue = event.target.city;
    this.countryValue = event.target.country;
    this.strState = event.target.province;
    this.postalCodeValue = event.target.postalCode;
    this.states = this.countriesToStates[this.countryValue] || [];
  }

  /**
  * @description It is used to handle connected callback.
  * @JIRA# LEM-13415
  */
  connectedCallback() {
    this.loaded = true;
    getFocusedTabInfo().then((tabInfo) => {
      this.currentTabId = tabInfo.tabId;
    }).catch(function (error) {
      console.log(error);
    });
  }

  /**
  * @description It is used to handle the success event.
  * @JIRA# LEM-13415
  */
  handleSuccess(event) {
    this.loaded = true;
    this.createdRecordId = event.detail.id;
    this.dispatchEvent(
      new ShowToastEvent({
        title: SUCCESS_TITLE,
        message: SUCCESS_MESSAGE,
        variant: SUCCESS_TITLE
      })
    );
    this.loaded = false;
    this.redirectToLead();
    setTimeout(() => {
      closeTab(this.currentTabId);
    }, 2000);
  }

  /**
  * @description It is used to redirect to the newly opened Lead tab.
  * @JIRA# LEM-13415
  */
  redirectToLead() {
    openTab({
      url: LEAD_URL_PREFIX + this.createdRecordId + LEAD_URL_SUFFIX,
      label: this.leadName,
      focus: true
    }).catch(function (error) {
      console.log(error);
    });

  }

  /**
  * @description It is used to handle the error event.
  * @JIRA# LEM-13415
  */
  handleError(event) {
    this.loaded = false;
    this.dispatchEvent(
      new ShowToastEvent({
        title: ERROR_TITLE,
        message: event.detail.detail,
        variant: 'error'
      })
    );
    this.loaded = true;
  }

  /**
  * @description It is used to handle the loading of record form.
  * @JIRA# LEM-13415
  */
  handleLoad(event) {
    this.loaded = true;
  }

  /**
  * @description It is used to handle the submit event.
  * @JIRA# LEM-13415
  */
  handleSubmit(event) {
    event.preventDefault();
    let fields = event.detail.fields;
    fields.City = this.cityValue;
    fields.CountryCode = this.countryValue;
    fields.Street = this.streetValue;
    fields.StateCode = this.strState;
    fields.PostalCode = this.postalCodeValue;
    this.leadName = fields.FirstName + ' ' + fields.LastName;
    this.loaded = false;
    let result = this.template.querySelector('lightning-input-address').reportValidity();
    if (result)
      this.template.querySelector('lightning-record-edit-form').submit(fields);
  }

  /**
  * @description It is used to handle the click of Cancel button.
  * @JIRA# LEM-13415
  */
  clickCancel() {
    this[NavigationMixin.Navigate]({
      type: PAGE_TYPE,
      attributes: {
        objectApiName: LEAD_OBJECT_API_NAME,
        actionName: ACTION_NAME_LIST
      },
      state: {
        filterName: RECENT_LIST_VIEW
      }
    });
    closeTab(this.currentTabId);
  }
}