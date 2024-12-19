/**
 * @author Deloitte
 * @date 04/29/2022
 * @description JavaScript controller for storesOnWorkPlan lightning web component.
 */
import { LightningElement, api, track, wire } from 'lwc';
import { setMessage, setTitle, setVariant, showNotification } from 'c/utils';
import heading from '@salesforce/label/c.Stores_On_WorkPlan_Heading';
import icon from '@salesforce/label/c.Stores_On_WorkPlan_Icon';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import noDataFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Data_Found_Message';
import noRecordFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Record_Found_Message';
import searchBoxPlaceholder from "@salesforce/label/c.Search_Box_Placeholder";
import sectionErrorMessage from '@salesforce/label/c.Stores_On_WorkPlan_Section_Error_Message';
import storesToBeDisplayedOnWorkPlan from '@salesforce/label/c.Number_Of_Stores_To_Be_Displayed_On_WorkPlan';
import separator from '@salesforce/label/c.Separator';
import toastTitle from '@salesforce/label/c.Toast_Title';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastVariant from '@salesforce/label/c.Toast_Variant_Error';
import getStoreDetails from '@salesforce/apex/StoresOnWorkPlanController.fetchStoresByWorkPlan';
import getSectionDetails from '@salesforce/apex/StoresOnWorkPlanController.fetchStoresData';
import createLog from '@salesforce/apex/LogController.createLog';
const CSS_CLASS_NAME_CARD_STYLING = '.cardStyling';
const ENCRYPTED_DETAILS_SECTION_NAME = 'Banking Details';
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const HIDE_RECORD_FORM_CLASS_NAME = 'hideRecordFormStyling';
const LWC_NAME = 'StoresOnWorkPlan';
const PAYMENT_ACCOUNT_OBJECT_NAME = 'Payment_Account__c';
const RECORD_FORM_DENSITY = 'comfy';
const SECTION_DETAILS_METHOD_NAME = 'getSectionDetails';
const STORE_DETAILS_METHOD_NAME = 'getStoreDetails';

export default class StoresOnWorkPlan extends LightningElement {
  @api recordId;
  @api objectApiName;
  @track allStores = [];
  @track filteredRecords;
  @track sectionDetails = [];
  @track storeDetails = [];
  @track storeRecords;
  businessAccountId;
  currentWorkOrderContractId = '';
  currentWorkOrderId;
  currentWorkOrderType;
  currentWorkPlanType;
  enableServerSearch = false;
  expandedStoreId;
  icon = icon;
  isSectionLoaded = false;
  loaded = false;
  loadingAlternativeText = loading;
  nameField = 'accountName';
  noDataFoundMessage = noDataFoundMessage;
  noRecordFoundMessage = noRecordFoundMessage;
  parentWorkOrderId;
  opportunityId;
  paymentAccountIds;
  recordFormDensity = RECORD_FORM_DENSITY;
  recordForms;
  recordNotFoundDiv;
  searchBoxPlaceholder = searchBoxPlaceholder;
  sectionError;
  separator = separator;
  showMessage = true;
  showSearchBar = false;
  storeError;
  title = heading;
  toastTitle = toastTitle;
  toastMessage = toastMessage;
  toastVariant = toastVariant;

  /**
   * @description It fires when the component has finished the rendering phase.
   * @JIRA# LEM-2255
   */
  renderedCallback() {
    // It stores lightning record forms instances.
    if (this.template.querySelectorAll('lightning-record-form')) {
      this.recordForms = this.template.querySelectorAll('lightning-record-form');
    }
    // It stores record not found div instances.
    if (this.template.querySelectorAll('[data-div-identifier="recordNotFoundDiv"]')) {
      this.recordNotFoundDiv = this.template.querySelectorAll('[data-div-identifier="recordNotFoundDiv"]');
    }
    this.collectPaymentAccountIds();
  }

  /**
   * @description It collects Payment Account Ids from the loaded record forms.
   * @JIRA# LEM-3794
   */
  collectPaymentAccountIds() {
    this.recordForms.forEach((eachElement) => {
      if (eachElement.dataset.sectionIdentifier === ENCRYPTED_DETAILS_SECTION_NAME && eachElement.dataset.objectIdentifier === PAYMENT_ACCOUNT_OBJECT_NAME) {
        if (!this.paymentAccountIds) {
          this.paymentAccountIds = eachElement.dataset.recordId;
        } else if (!this.paymentAccountIds.includes(eachElement.dataset.recordId)) {
          this.paymentAccountIds = this.paymentAccountIds + separator + eachElement.dataset.recordId;
        }
      }
    });
  }

  /**
   * @description This will log & show error on UI if any error occurs.
   * @JIRA# LEM-1397
   * @param error
   * @param stack
   */
  errorCallback(error, stack) {
    setMessage(toastMessage);
    setTitle(toastTitle);
    setVariant(toastVariant);
    showNotification(this);
    createLog({
      lwcName: LWC_NAME, methodName: ERROR_CALLBACK_METHOD_NAME,
      message: JSON.stringify(error).concat(JSON.stringify(stack))
    });
  }

  /**
   * @description This will return filtered list of data.
   * @JIRA# LEM-1158
   * @param event
   */
  fetchFilteredDetails(event) {
    this.filteredRecords = event.detail;
    if (this.filteredRecords &&
      Array.isArray(this.filteredRecords) &&
      this.filteredRecords.length > 0) {
      this.showMessage = false;
      this.expandedStoreId = this.filteredRecords[0].accountId;
      this.currentWorkOrderId = this.filteredRecords[0].workOrderId;
      this.storeRecords = this.filteredRecords.map((eachRecord) => {
        return {
          'storeData': eachRecord,
          'isActive': eachRecord.accountId === this.expandedStoreId
        }
      });
      this.fetchSectionDetails(this.expandedStoreId, this.currentWorkOrderId);
    } else {
      this.showMessage = true;
      this.storeRecords = this.filteredRecords.map((eachRecord) => {
        return {
          'storeData': eachRecord,
          'isActive': false
        }
      });
    }
  }

  /**
   * @description This will clear search result.
   * @JIRA# LEM-1158
   * @param event
   */
  clearSearch(event) {
    this.filteredRecords = event.detail;
    if (this.filteredRecords) {
      this.filteredRecords = this.storeDetails;
      this.expandedStoreId = this.filteredRecords[0].accountId;
      this.currentWorkOrderId = this.filteredRecords[0].workOrderId;
      this.storeRecords = this.filteredRecords.map((eachRecord) => {
        return {
          'storeData': eachRecord,
          'isActive': eachRecord.accountId === this.expandedStoreId
        }
      });
      this.fetchSectionDetails(this.expandedStoreId, this.currentWorkOrderId);
      this.showMessage = false;
    }
  }

  /**
   * @description To fetch unique stores details from current WorkPlan.
   * @JIRA# LEM-1158
   * @param currentWorkPlanRecordId
   * @return List<AccountWrapper>
   */
  @wire(getStoreDetails, { currentWorkPlanRecordId: '$recordId' })
  wiredStores({ data, error }) {
    if (data) {
      this.loaded = true;
      try {
        let storeAccounts = data.accountWrappers;
        this.currentWorkPlanType = data.currentWorkPlanType;
        this.parentWorkOrderId = data.accountWrappers[0].parentWorkOrderId;
        this.currentWorkOrderType = data.accountWrappers[0].workOrderType;
        this.showSearchBar = data.showSearchBar;
        this.storeDetails = storeAccounts;
        this.currentWorkOrderContractId = data.accountWrappers[0].workOrderContractId;
        // To show number of store according to number in custom label on load
        if (storeAccounts !== undefined && storeAccounts.length >= storesToBeDisplayedOnWorkPlan) {
          this.filteredRecords = storeAccounts.slice(-storesToBeDisplayedOnWorkPlan);
        } else {
          this.filteredRecords = storeAccounts;
        }
        if (this.filteredRecords !== undefined && this.filteredRecords.length > 0) {
          this.showMessage = false;
          this.expandedStoreId = this.filteredRecords[0].accountId;
          this.businessAccountId = this.filteredRecords[0].businessAccountId;
          this.currentWorkOrderId = this.filteredRecords[0].workOrderId;
          this.opportunityId = this.filteredRecords[0].opportunityId;
          /**
           * Lazy loading is not supported by lightning-accordion (known limitation)
           * therefore, setting isActive attribute for the current store record
           * to render data only for active accordion section.
           */
          this.storeRecords = this.filteredRecords.map((eachRecord) => {
            return {
              'storeData': eachRecord,
              'isActive': eachRecord.accountId === this.expandedStoreId
            }
          });
          this.fetchSectionDetails(this.expandedStoreId, this.currentWorkOrderId);
        }
        this.storeError = undefined;
      } catch (storeException) {
        this.showMessage = true;
        this.storeError = error;
        this.storeDetails = undefined;
        this.filteredRecords = [];
        this.showSearchBar = false;
        //Commenting to control logging due to wire method loading
        //createLog(LWC_NAME, STORE_DETAILS_METHOD_NAME, storeException);
      }
    } else if (error) {
      this.showMessage = true;
      this.loaded = true;
      this.storeError = error;
      this.storeDetails = undefined;
      this.filteredRecords = [];
      createLog({
        lwcName: LWC_NAME, methodName: STORE_DETAILS_METHOD_NAME,
        message: JSON.stringify(error.body)
      });
    }
  }

  /**
   * @description To handle toggle section.
   * @JIRA# LEM-1158
   * @param event
   */
  handleToggleSection(event) {
    let currentStoreId = event.target.dataset.id;
    let currentWorkOrderId = event.target.dataset.workorderid;
    if (this.expandedStoreId === undefined || currentStoreId !== this.expandedStoreId) {
      this.isSectionLoaded = false;
      this.sectionDetails = [];
      this.fetchSectionDetails(currentStoreId, currentWorkOrderId);
    }
    this.expandedStoreId = event.target.dataset.id;
    this.storeRecords = this.filteredRecords.map((eachRecord) => {
      return {
        'storeData': eachRecord,
        'isActive': eachRecord.accountId === this.expandedStoreId
      }
    });
  }

  /**
   * @description To fetch stores details on basis of passed storeId and WorkPlan type.
   * @JIRA# LEM-1158
   * @param storeId
   * @param workOrderId
   * @return List<SectionWrapper>
   */
  fetchSectionDetails(storeId, workOrderId) {
    let acccountWrapper = [];
    acccountWrapper.push(
      {
        accountId: storeId,
        businessAccountId: this.businessAccountId,
        opportunityId: this.opportunityId,
        parentWorkOrderId: this.parentWorkOrderId,
        workOrderId: workOrderId,
        workOrderType: this.currentWorkOrderType,
        workPlanId: this.recordId,
        workPlanType: this.currentWorkPlanType,
        workOrderContractId: this.currentWorkOrderContractId
      });
    getSectionDetails({
      accountWrapper: JSON.stringify(acccountWrapper)
    })
      .then(result => {
        this.sectionDetails = result;
        this.sectionError = undefined;
        this.isSectionLoaded = true;
        // It stores accordion instances for changing the active section as per the expanded store Id.
        const storeAccordions = this.template.querySelectorAll(CSS_CLASS_NAME_CARD_STYLING);
        storeAccordions.forEach((eachElement) => {
          eachElement.activeSectionName = this.expandedStoreId;
        });
      })
      .catch(error => {
        this.showMessage = false;
        this.isSectionLoaded = true;
        this.sectionError = sectionErrorMessage;
        this.sectionDetails = undefined;
        createLog({
          lwcName: LWC_NAME,
          methodName: SECTION_DETAILS_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description It toggles visibilty of the passed elements.
   * @JIRA# LEM-3342
   * @param elements
   * @param isEnabled - viewEncryptedData component enabled
   */
  toggleElementsVisibility(elements, isEnabled) {
    elements.forEach(function (eachElement) {
      if (eachElement.dataset.sectionIdentifier === ENCRYPTED_DETAILS_SECTION_NAME) {
        if (isEnabled) {
          eachElement.classList.add(HIDE_RECORD_FORM_CLASS_NAME);
        } else {
          eachElement.classList.remove(HIDE_RECORD_FORM_CLASS_NAME);
        }
      }
    }, this);
  }

  /**
   * @description It handles toggle event to show/hide the encrypted data.
   * @JIRA# LEM-2255
   * @param event
   */
  toggleEncryptedData(event) {
    this.toggleElementsVisibility(this.recordForms, event.detail);
    this.toggleElementsVisibility(this.recordNotFoundDiv, event.detail);
  }
}