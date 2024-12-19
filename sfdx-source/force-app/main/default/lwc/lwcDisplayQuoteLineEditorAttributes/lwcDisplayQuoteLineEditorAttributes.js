import getValuesfromWrapper from "@salesforce/apex/DisplayQuoteLineAttributesController.getQLProductsWithAttributes";
import insertParentCode from "@salesforce/apex/DisplayQuoteLineAttributesController.insertParentProduct";
import LightningConfirm from "lightning/confirm";
import deliveryTypeError from '@salesforce/label/c.RequiredFieldsWhenDeliveryTypeDistanceBasedForDriveProducts';
import uomMilesError from '@salesforce/label/c.UOMNotAsMilesForDriveProducts';
import minMaxDeliveryFeeError from '@salesforce/label/c.MinMaxDeliveryFeeRequiredForDriveProducts';
import levelDeliveryError from '@salesforce/label/c.LevelNotDeliveryForDriveProducts';
import evaluationPeriodBiMonthlyError from '@salesforce/label/c.EvaluationPeriodNotBiMonthlyForDriveProducts';
import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import SEGMENT from "@salesforce/schema/SBQQ__Quote__c.Segment__c";
import COUNTRYCODE from "@salesforce/schema/SBQQ__Quote__c.Account_Billing_Country_Code__c";
const FIELDS = [SEGMENT, COUNTRYCODE];
const ALCOHOL_DELIVERY_PRODUCT = 'Alcohol Delivery';
const BI_MONTHLY_EVALUATION_PERIOD = 'Bi-Monthly';
const COMMISSION_FEE_TYPE = 'Commission';
const FEE_TYPE = 'Fee';
const COUNTRY_CODE_AU = 'AU';
const COUNTRY_CODE_CA = 'CA';
const DELIVERY_PRODUCT = 'Delivery';
const DELIVERY_TYPE = 'Distance Based (incl. tiered)';
const ERROR = "error";
const LABEL = "Configure Products";
const LEVEL = 'Delivery';
const LOF = 'Large Order Fulfillment (LOF)';
const LOF_PACKAGE = 'Large Order Fulfillment (LOF)';
const OPTIONAL_FIELDS = "optionalFields";
const PIPE = ' |';
const REQUIRED_FIELDS = "requiredFields";
const SOF = 'Small Order Fulfillment (SOF)';
const SEGMENT_SMB = 'SMB';
const UOM_MILE = 'Mile';


export default class LwcDisplayQuoteLineEditorAttributes extends LightningElement {
  @api dealdeskuser;
  @api productCode = "";
  @api recordId;
  @api quoteId;
  @api prodName;
  @api groupId;
  @api productId;
  @api poId;
  @api packageName;
  @api feeType;
  @api quoteType;
  @api packageProd;
  @api prodNumber;
  @api requiredBy;
  @track error;
  @track hasfields = false;
  @track hasRequiredFields = false;
  @track hasActivePrice = false;
  @track requiredFieldsList = [];
  @track optionalFieldsList = [];
  @track activePriceList = [];
  @track isSpinner = false;
  @track result;
  @track activeSections = ['Required_Fields', 'Optional_Fields', 'Active_Price'];
  @track prodPackage;
  @track quoteTypeAmendment = 'Amendment';
  @track insertedQuoteLineId;
  @track doInsert = false;
  @track mapOfValues = [];
  @track packageProduct;
  accountSegment;
  quoteCountryCode;
  fieldsValidationErrorMessage = '';

  connectedCallback() {
    this.isSpinner = true;
    if (this.packageName == undefined) {
      this.packageName = "";
      this.prodPackage = this.productCode;
    }
    else {
      this.prodPackage = this.productCode + this.packageName;
    }
  }
  validateDataAttribute(data, attributeName) {
    return data[attributeName] && data[attributeName][this.prodPackage];
  }
  getFieldList(data, attributeName) {
    return data[attributeName][this.prodPackage];
  }
  //This method is used to return the value account segment
  @wire(getRecord, {
    recordId: "$quoteId",
    fields: FIELDS,
  })
  quoteRecord({ data, error }) {
    if (data) {
      this.accountSegment = getFieldValue(data, SEGMENT);
      this.quoteCountryCode = getFieldValue(data, COUNTRYCODE);
      this.getValuesfromWrapperBySegment();
    } else if (error) {
      this.error = error;
      this.isSpinner = false;
    }
  };

  //This method is used to get the required and optional fields attributes by account segment.
  getValuesfromWrapperBySegment() {
    getValuesfromWrapper({
      prodCode: this.productCode,
      pkgName: this.packageName,
      accountSegment: this.accountSegment
    })
      .then((data) => {
        if (data) {
          this.isSpinner = true;
          let requiredFieldAttribute = REQUIRED_FIELDS;
          let optionalFieldAttribute = OPTIONAL_FIELDS;
          let activePriceAttribute = "activePrices";
          if (this.validateDataAttribute(data, requiredFieldAttribute)) {
            this.requiredFieldsList = this.getFieldList(
              data,
              requiredFieldAttribute
            );
            this.hasRequiredFields = true;
          }
          if (this.validateDataAttribute(data, optionalFieldAttribute)) {
            this.optionalFieldsList = this.getFieldList(
              data,
              optionalFieldAttribute
            );
            this.hasfields = true;
          }
          if (this.validateDataAttribute(data, activePriceAttribute) && this.quoteType === this.quoteTypeAmendment) {
            this.activePriceList = this.getFieldList(
              data,
              activePriceAttribute
            );
            this.hasActivePrice = true;
          }
        } else if (error) {
          this.error = error;
          if (Array.isArray(error.body)) {
            this.error = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            this.error = error.body.message;
          }
          this.template.querySelector('[data-id="message"]').setError(this.error);
          this.hasfields = false;
          this.hasRequiredFields = false;
          this.hasActivePrice = false;
        }
        this.isSpinner = false;
      })
      .catch((error) => {
        console.error(error);
      });
  }
  get hasAnyFieldstoDisplay() {
    return this.hasRequiredFields || this.hasfields || this.hasActivePrice;
  }
  async handleSubmit(event) {
    event.preventDefault(); // stop the default behaviour of the event - submit the record
    let fields = event.detail.fields;
    if (this.recordId !== undefined && this.recordId != null) {
      fields.Id = this.recordId;
      this.doInsert = false;
      this.fieldsValidationErrorMessage = '';
      this.validateDriveProductFields(fields);
      if (this.fieldsValidationErrorMessage !== '') {
        await LightningConfirm.open({
          message: this.fieldsValidationErrorMessage,
          theme: ERROR,
          label: LABEL
        });
        return;
      }

    } else {
      this.doInsert = true;
      fields.SBQQ__Quote__c = this.quoteId;
      fields.SBQQ__Product__c = this.productId;
      fields.SBQQ__PricebookEntryId__c = this.poId;
      fields.SBQQ__ProductOption__c = this.packageProd;
      fields.SBQQ__Number__c = this.prodNumber;
    }
    if (this.groupId !== undefined) {
      fields.SBQQ__Group__c = this.groupId;
    }
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  /**
   * @description It is used to throw validations by checking Drive product field values for various conditions.
   * @param fields
   */
  validateDriveProductFields(fields) {

    switch (this.packageName) {
      case LOF:
      case SOF:
        this.validateBiMonthlyEvaluation(fields);
        this.validateDeliveryLevel(fields);
        this.validateMinMaxDeliveryFee(fields);
        this.validateUOMMiles(fields);
        this.validateDistanceBasedDelivery(fields);
        this.fieldsValidationErrorMessage = this.fieldsValidationErrorMessage.slice(0, -1);
        break;
    }
  }

  /**
   * @description It is used to check if 'Evaluation Period' is 'Bi-Monthly' on Drive Products for 'SMB' Segment.
   * @param fields
   */
  validateBiMonthlyEvaluation(fields) {
    if (fields.Evaluation_Period__c === BI_MONTHLY_EVALUATION_PERIOD && this.accountSegment === SEGMENT_SMB) {
      this.fieldsValidationErrorMessage += ` ${evaluationPeriodBiMonthlyError} ${PIPE}`;
    }
  }

  /**
   * @description This method is used to check if 'Level' is 'Delivery' on Drive Products for 'SMB' Segment.
   * @param fields
   */
  validateDeliveryLevel(fields) {
    if (fields.Level__c === LEVEL && this.accountSegment === SEGMENT_SMB) {
      this.fieldsValidationErrorMessage += ` ${levelDeliveryError} ${PIPE}`;
    }
  }

  /**
   * @description It is used to check if 'Min Delivery Fee' and 'Max Delivery Fee' for Delivery/Alcohol Delivery product options under LOF is blank for 'SMB' Segment.
   * @param fields
   */
  validateMinMaxDeliveryFee(fields) {
    if (this.feeType === COMMISSION_FEE_TYPE && this.packageName === LOF_PACKAGE &&
      (this.prodName === DELIVERY_PRODUCT || this.prodName === ALCOHOL_DELIVERY_PRODUCT) &&
      (fields.Min__c === null || fields.Max__c === null) &&
      this.accountSegment === SEGMENT_SMB) {
      this.fieldsValidationErrorMessage += ` ${minMaxDeliveryFeeError} ${PIPE}`;
    }
  }

  /**
   * @description It is used to check if 'UOM' is 'Miles' on AUS/CAD country code for 'SMB' Segment.
   * @param fields
   */
  validateUOMMiles(fields) {
    if (fields.Radius_UOM_miles_km__c === UOM_MILE &&
      (this.quoteCountryCode === COUNTRY_CODE_AU || this.quoteCountryCode === COUNTRY_CODE_CA) &&
      this.accountSegment === SEGMENT_SMB) {
      this.fieldsValidationErrorMessage += ` ${uomMilesError} ${PIPE}`;
    }
  }

  /**
   * @description It is used to check if Requested Fee/Requested Commission, Base Fee Distance, Incremental Fee per Mile Driven,
   * Max Distance fields are populated when 'Delivery Type' is 'Distance Based (incl. tiered)' for 'SMB' Segment.
   * @param fields
   */
  validateDistanceBasedDelivery(fields) {
    if (fields.Delivery_Type__c === DELIVERY_TYPE &&
      ((fields.Requested_Commission__c === null && fields.SBQQ__SpecialPrice__c === null) ||
        fields.Base_Fee_Distance__c === null || fields.Incremental_Fee_Per_Mile_Driven__c === null ||
        fields.Radius_UOM_miles_km__c === null) && this.accountSegment === SEGMENT_SMB) {
      this.fieldsValidationErrorMessage += ` ${deliveryTypeError} ${PIPE}`;
    }
  }

  async handleSuccess(event) {
    let quoteIdvar = this.quoteId;
    this.insertedQuoteLineId = event.detail.id;
    if (this.doInsert == true && (this.packageName != null || this.packageName !== undefined)) {
      this.parentProductInsert();
    }
    const result = await LightningConfirm.open({
      message: "Quote Lines are Updated Successfully!!!",
      theme: "success",
      label: "Configure Products"
    });
    if (result) {
      let url =
        window.location !== window.parent.location
          ? document.referrer
          : document.location.href;
      let value = url + "apex/sb?scontrolCaching=1&id=" + quoteIdvar;
      window.open(value, "_top");
    }
  }
  handleError(event) {
    this.template
      .querySelector('[data-id="message"]')
      .setError(event.detail.detail);
    event.preventDefault();
  }

  parentProductInsert() {
    insertParentCode({
      quoteId: this.quoteId,
      parentProductName: this.packageName,
      quoteLineId: this.insertedQuoteLineId,
      lineNumber: this.prodNumber,
      requiredBy: this.requiredBy,
      groupId: this.groupId
    })
  }

}