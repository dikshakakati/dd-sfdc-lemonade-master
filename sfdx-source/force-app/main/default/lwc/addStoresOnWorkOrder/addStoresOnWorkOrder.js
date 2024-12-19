/**
 * @author Deloitte
 * @date 27/06/2022
 * @description JavaScript controller for addStoresOnWorkOrder lightning web component.
 */
import { LightningElement, api, wire, track } from 'lwc';
import { reloadScreenAfterConfiguredDelay, setMessage, setVariant, showNotification } from 'c/utils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_FIELD from '@salesforce/schema/WorkOrder.AccountId';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/WorkOrder.Account_Type__c';
import STATUS_FIELD from '@salesforce/schema/WorkOrder.Status';
import createLog from '@salesforce/apex/LogController.createLog';
import createChildWorkOrders from '@salesforce/apex/AddStoresOnWorkOrderController.createChildWorkOrders';
import findVerifiedStoresBySearchKey from '@salesforce/apex/AddStoresOnWorkOrderController.findVerifiedStoresBySearchKey';
import getVerifiedStores from '@salesforce/apex/AddStoresOnWorkOrderController.fetchVerifiedStores';
import addStoresAction from '@salesforce/label/c.Add_Stores_Action';
import addStoresQuickActionHeading from '@salesforce/label/c.Add_Stores_Quick_Action_Heading';
import cancelAction from '@salesforce/label/c.Cancel_Action';
import childWorkOrdersCreationSuccessMessage from '@salesforce/label/c.Child_Work_Orders_Creation_Success_Message';
import childWorkOrdersSelectionLimit from '@salesforce/label/c.Child_Work_Orders_Selection_Limit';
import columnAccountName from '@salesforce/label/c.Add_Stores_Data_Table_Column_Account_Name';
import columnAccountAddress from '@salesforce/label/c.Add_Stores_Data_Table_Column_Account_Address';
import columnActivationStatus from '@salesforce/label/c.Add_Stores_Data_Table_Column_Activation_Status';
import columnExternalId from '@salesforce/label/c.Add_Stores_Data_Table_Column_External_ID';
import icon from '@salesforce/label/c.Stores_On_WorkPlan_Icon';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import delayInMilliseconds from '@salesforce/label/c.Add_Stores_Delay_In_Milliseconds';
import exceptionMessage from '@salesforce/label/c.Add_Stores_Exception_Message';
import noDataFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Data_Found_Message';
import notPlanningStatusMessage from '@salesforce/label/c.WO_Status_Not_Planning_Warning_Message';
import noVerifiedStoresFoundForParentWorkOrder from '@salesforce/label/c.No_Stores_Found_To_Add_Stores_On_ParentWO';
import planningStatus from '@salesforce/label/c.Work_Order_Status_Planning';
import searchBoxPlaceholder from '@salesforce/label/c.Add_Stores_Search_Box_Placeholder';
import serverSearchMessage from '@salesforce/label/c.Server_Search_Message';
import serverSearchMessageWithBlankKey from '@salesforce/label/c.Server_Search_Message_With_Blank_Key';
import searchKeyLength from '@salesforce/label/c.Search_Key_Minimum_Length';
import selectedStoresExceedingLimitInfoMessage from '@salesforce/label/c.Selected_Stores_Exceeding_Limit_Info_Message';
import successStatusMessage from '@salesforce/label/c.Verified_Stores_Message';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';
import validateStores from '@salesforce/apex/AddStoresOnWorkOrderController.validateStores';

const buttonVariant = 'brand';
const columns = [
  {
    label: columnAccountName, type: 'customText', typeAttributes: {
      customTextColumn: { fieldName: 'accountName' }
    }
  },
  {
    label: columnAccountAddress, type: 'customText', typeAttributes: {
      customTextColumn: { fieldName: 'address' }
    }
  },
  { label: columnActivationStatus, fieldName: 'activationStatus' },
  {
    label: columnExternalId, type: 'customText', typeAttributes: {
      customTextColumn: { fieldName: 'externalIds' }
    }
  }
];
const fields = [ACCOUNT_FIELD, ACCOUNT_TYPE_FIELD, STATUS_FIELD];
const dataTableoffset = '10';
const CREATE_CHILD_WORKORDER_METHOD_NAME = 'createChildWorkOrders';
const CLOSE_MODAL_EVENT_NAME = 'closemodal';
const DATA_TABLE_STYLING_ON_SCROLL = 'dataTableStylingOnScroll';
const DATA_TABLE_STYLING_ON_SERVER_SEARCH = 'dataTableStylingOnSearch';
const DELAY_IN_MILLISECONDS = parseInt(delayInMilliseconds, 10);
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const FIND_VERIFIED_STORES_BY_SEARCH_KEY_METHOD_NAME = 'findVerifiedStoresBySearchKey';
const GET_RECORD_METHOD_NAME = 'errorCallback';
const GLOBAL_IGNORE_CASE_REG_EXP_PARAMETER = 'gi';
const LWC_NAME = 'AddStoresOnWorkOrder';
const VERIFIED_STORES_METHOD_NAME = 'getVerifiedStores';

export default class AddStoresOnWorkOrder extends LightningElement {
  @api recordId;
  @track filteredRecords;
  @track formattedRecords;
  @track searchKey;
  @track verifiedStores = [];
  addStoresAction = addStoresAction;
  addStoresButtonDisabled = true;
  addStoresContainer;
  addStoresQuickActionHeading = addStoresQuickActionHeading;
  buttonVariant = buttonVariant;
  cancelAction = cancelAction;
  cancelButton;
  currentBusinessAccountId;
  currentBusinessAccountType;
  currentWorkOrderStatus;
  columns = columns;
  enableServerSearch = false;
  icon = icon;
  isClearSearchCalled = false;
  isPreviousSearchNoDataFound = false;
  isServerSearchCalled = false;
  messageToBeDisplayed = notPlanningStatusMessage;
  noDataFoundMessage = noDataFoundMessage;
  nameField = 'accountName';
  lastReturnedId = '';
  lastReturnedParentIds = [];
  loaded = false;
  loadingAlternativeText = loading;
  loadMoreOffset = dataTableoffset;
  parentAccountIds = [];
  rowOffset = 0;
  successStatusMessage = successStatusMessage;
  searchBoxPlaceholder = searchBoxPlaceholder;
  searchCount = 0;
  serverSearchMessage = serverSearchMessage;
  serverSearchMessageWithBlankKey = serverSearchMessageWithBlankKey;
  selection = [];
  showMessage = true;
  showSearchBar = true;
  showServerSearchMessage = false;
  showStores = true;
  storeClicked;
  targetDatatable;
  toastMessageOnChildWorkOrderCreation = childWorkOrdersCreationSuccessMessage;
  toastMessageOnError = toastMessage;
  verifiedStoresError;
  validateStoresError;
  workOrderError;

  /**
   * @description To perform logic after a component has finished the rendering phase.
   */
  renderedCallback() {
    //It stores Cancel button instance
    if (this.template.querySelector('[data-id="cancel"]')) {
      this.cancelButton = this.template.querySelector('[data-id="cancel"]');
    }
    //It stores datatable instance
    if (this.template.querySelector('[data-id="datarow"]')) {
      this.targetDatatable = this.template.querySelector('[data-id="datarow"]');
    }
  }

  /**
   * @description To fetch Work Order record details from recordId.
   * @JIRA# LEM-2013
   * @param recordId
   * @param fields
   * @return WorkOrder
   */
  @wire(getRecord, { recordId: '$recordId', fields })
  wiredWorkOrder({ data, error }) {
    if (data) {
      this.workOrderError = undefined;
      try {
        this.currentBusinessAccountId = getFieldValue(data, ACCOUNT_FIELD);
        this.currentBusinessAccountType = getFieldValue(data, ACCOUNT_TYPE_FIELD);
        this.currentWorkOrderStatus = getFieldValue(data, STATUS_FIELD);
        this.parentAccountIds.push(this.currentBusinessAccountId);
        if (this.currentWorkOrderStatus === planningStatus) {
          //if status is Planning then fetch incoverage verified stores which doesn't have child Work Order
          this.fetchVerifiedAccounts();
          this.messageToBeDisplayed = successStatusMessage;
        } else {
          //if status is not planning then show message & hide search bar & datatable
          this.showStores = false;
          this.loaded = true;
          this.showSearchBar = false;
          this.messageToBeDisplayed = notPlanningStatusMessage;
        }
      } catch (workOrderException) {
        this.workOrderError = workOrderException;
        this.showStores = false;
        this.loaded = true;
        this.showSearchBar = false;
        this.messageToBeDisplayed = exceptionMessage;
        //Commenting to control logging due to wire method loading
        //createLog(LWC_NAME, STORE_DETAILS_METHOD_NAME, storeException);
      }
    } else if (error) {
      this.workOrderError = error;
      this.showStores = false;
      this.loaded = true;
      this.showSearchBar = false;
      this.messageToBeDisplayed = exceptionMessage;
      createLog({
        lwcName: LWC_NAME,
        methodName: GET_RECORD_METHOD_NAME,
        message: JSON.stringify(error.body)
      });
    }
  }

  /**
   * @description To clear search result.
   * @JIRA# LEM-2013
   * @param event
   */
  clearSearch(event) {
    // setting the search count as zero on clear search
    this.searchCount = 0;
    this.isClearSearchCalled = true;
    this.filteredRecords = event.detail;
    this.targetDatatable.selectedRows = this.selection;
    // clear search key when clear search is called
    this.searchKey = undefined;
    // remove the search key highlighting in the filtered records
    this.getFormattedRecords(this.filteredRecords);
    // disable server search when clear search called
    this.enableServerSearch = false;
    this.showServerSearchMessage = false;
    if (
      this.filteredRecords &&
      Array.isArray(this.filteredRecords) &&
      this.filteredRecords.length > 0
    ) {
      this.showStores = true;
      this.messageToBeDisplayed = successStatusMessage;
      // enable Infinite Loading when cleared search
      if (this.targetDatatable) this.enableInfiniteLoading();
    } else {
      this.showStores = false;
      this.messageToBeDisplayed = noDataFoundMessage;
    }
  }

  /**
   * @description To get search key for enabling server search.
   * @JIRA# LEM-3495
   * @param event
   */
  getSearchKey(event) {
    this.searchKey = event.detail;
    // enable server search when search key length is greater than or equal to search key length
    if (this.searchKey && this.searchKey.length >= searchKeyLength) {
      this.enableServerSearch = true;
      this.showServerSearchMessage = true;
    } else {
      this.enableServerSearch = false;
      this.showServerSearchMessage = false;
    }
  }

  /**
   * @description To close the quick action panel after adding the selected stores.
   * @JIRA# LEM-2013
   */
  closeModal() {
    this.dispatchEvent(new CustomEvent(CLOSE_MODAL_EVENT_NAME));
  }

  /**
   * @description To create child Work Order for selected store Accounts.
   * @JIRA# LEM-2013
   * @param selectedStoreAccountIds
   */
  createChildWorkOrders(selectedStoreAccountIds) {
    const selectedStores = selectedStoreAccountIds.split(',');
    if (selectedStores.length > parseInt(childWorkOrdersSelectionLimit, 10)) {
      this.toastMessageOnChildWorkOrderCreation = selectedStoresExceedingLimitInfoMessage;
    } else {
      this.cancelButton.disabled = true;
      this.loaded = false;
      createChildWorkOrders({
        parentWorkOrderId: this.recordId,
        storeAccountIds: selectedStoreAccountIds
      })
        .then((result) => {
          if (result) {
            setMessage(JSON.stringify(result));
            setVariant(toastVariantInfo);
            showNotification(this);
          }
          this.closeModal();
          // JIRA#: LEM-3041 - Added delay to ensure that the validation message is displayed.
          reloadScreenAfterConfiguredDelay(DELAY_IN_MILLISECONDS);
        })
        .catch((error) => {
          createLog({
            lwcName: LWC_NAME,
            methodName: CREATE_CHILD_WORKORDER_METHOD_NAME,
            message: JSON.stringify(error.body)
          });
          this.closeModal();
        });
    }
    // show info message after successful creation of child WorkOrders
    setMessage(this.toastMessageOnChildWorkOrderCreation);
    setVariant(toastVariantInfo);
    showNotification(this);
  }

  /**
   * @description To disable infinite loading in datatable.
   */
  disableInfiniteLoading() {
    this.targetDatatable.enableInfiniteLoading = false;
  }

  /**
   * @description To enable infinite loading in datatable.
   */
  enableInfiniteLoading() {
    this.targetDatatable.enableInfiniteLoading = true;
  }

  /**
   * @description This will log & show error on UI if any error occurs.
   * @JIRA# LEM-2013
   * @param error
   * @param stack
   */
  errorCallback(error, stack) {
    // show error message when an error occurs
    setMessage(this.toastMessageOnError);
    setVariant(toastVariantError);
    showNotification(this);
    createLog({
      lwcName: LWC_NAME,
      methodName: ERROR_CALLBACK_METHOD_NAME,
      message: JSON.stringify(error).concat(JSON.stringify(stack))
    });
  }

  /**
   * @description This filter data on basis of search.
   * @JIRA# LEM-2013
   * @param event
   */
  fetchFilteredDetails(event) {
    // increasing the search count by one on local search
    this.searchCount += 1;
    this.filteredRecords = event.detail;
    // highlight the search key in the filtered records
    this.getFormattedRecords(this.filteredRecords);
    this.targetDatatable.selectedRows = this.selection;
    if (
      this.filteredRecords &&
      Array.isArray(this.filteredRecords) &&
      this.filteredRecords.length > 0
    ) {
      this.showStores = true;
      this.messageToBeDisplayed = successStatusMessage;
      // stop infinite loading while searching
      if (this.targetDatatable) {
        this.disableInfiniteLoading();
      }
    } else {
      // stop infinite loading when no data found
      if (this.targetDatatable) {
        this.disableInfiniteLoading();
      }
      this.showStores = false;
      this.messageToBeDisplayed = noDataFoundMessage;
      this.isPreviousSearchNoDataFound = true;
    }
  }

  /**
   * @description To fetch verified stores related to business Account of current WorkOrder.
   * @JIRA# LEM-2013
   * @return List<AccountWrapper>
   */
  fetchVerifiedAccounts() {
    // stop Infinite Loading when clear search or server search is called
    if (this.isEligibleToDisableInfiniteLoading()) {
      this.isClearSearchCalled = false;
      // stop infinite loading when no data found for last search or server search is called
      if (this.isEligibleToDisableInfiniteLoadingOnSearch()) {
        this.disableInfiniteLoading();
      }
      this.isPreviousSearchNoDataFound = false;
      this.isServerSearchCalled = false;
      return Promise.resolve();
    }
    let workOrder = {
      Id: this.recordId,
      AccountId: this.currentBusinessAccountId,
      Account_Type__c: this.currentBusinessAccountType
    };
    this.addStoresContainer = {
      parentWorkOrder: workOrder,
      parentIds: this.parentAccountIds,
      lastReturnedParentIds: this.lastReturnedParentIds,
      lastReturnedStoreAccountId: this.lastReturnedId
    }
    return getVerifiedStores({
      addStoresContainerJSON: JSON.stringify(this.addStoresContainer)
    })
      .then((result) => {
        try {
          let storeAccounts = result.storeAccountWrappers;
          this.parentAccountIds = result.parentIds;
          this.lastReturnedParentIds = result.lastReturnedParentIds;
          if (storeAccounts && storeAccounts.length > 0) {
            // it maintains id of last returned store to utilize in lazy loading
            this.lastReturnedId = storeAccounts[storeAccounts.length - 1].accountId;
          }
          let updatedRecords = [...this.verifiedStores, ...storeAccounts];
          if (this.selection.length !== 0) {
            this.targetDatatable.selectedRows = this.selection;
          }
          // it get unique elements from the passed source
          this.verifiedStores = this.filteredRecords = this.getUniqueElements(updatedRecords);
          // remove the search key highlighting in the filtered records
          this.getFormattedRecords(this.filteredRecords);
          this.verifiedStoresError = undefined;
          this.loaded = true;
          // hide datatable, search bar when no matching verified store found for parent WorkOrder
          this.showStores = this.verifiedStores && this.verifiedStores.length === 0 ? false : true;
          if (!this.showStores) {
            this.showSearchBar = false;
            this.messageToBeDisplayed = noVerifiedStoresFoundForParentWorkOrder;
          }
          if (this.targetDatatable && storeAccounts.length === 0) {
            // stop infinite loading when no more data to load
            this.disableInfiniteLoading();
            this.targetDatatable.isLoading = false;
          }
          if (this.targetDatatable) this.targetDatatable.isLoading = false;
        } catch (verifiedStoredException) {
          createLog({
            lwcName: LWC_NAME,
            methodName: VERIFIED_STORES_METHOD_NAME,
            message: JSON.stringify(verifiedStoredException)
          });
        }
      })
      .catch((error) => {
        this.verifiedStoresError = error;
        this.verifiedStores = undefined;
        this.filteredRecords = undefined;
        createLog({
          lwcName: LWC_NAME,
          methodName: VERIFIED_STORES_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description To search in-coverage and verified store Accounts and related Xrefs
   * which are related to the business Account attached to parent Work Order and doesn't have
   * any child Work Order by matching the passed search key with the Account's Name or Address
   * or Xref's External Id.
   * @JIRA# LEM-3495
   * @return List<AccountWrapper>
   */
  findVerifiedAccounts() {
    this.addStoresContainer.searchKey = this.searchKey;
    this.addStoresContainer.parentIds = this.parentAccountIds;
    findVerifiedStoresBySearchKey({
      addStoresContainerJSON: JSON.stringify(this.addStoresContainer)
    })
      .then((result) => {
        try {
          let storeAccounts = result.storeAccountWrappers;
          let updatedRecords = [...storeAccounts];
          // set the filtered records for server search result
          this.filteredRecords = updatedRecords;
          // highlight the search key in the filtered records
          this.getFormattedRecords(this.filteredRecords);
          // append the verified stores list with filtered stores list
          this.verifiedStores = [...this.verifiedStores, ...this.filteredRecords];
          // it get unique elements from the passed source
          this.verifiedStores = this.getUniqueElements(this.verifiedStores);
          this.verifiedStoresError = undefined;
          this.loaded = true;
          this.messageToBeDisplayed = successStatusMessage;
          // disable infinite loading on server search
          if (this.targetDatatable) {
            this.disableInfiniteLoading();
            this.targetDatatable.isLoading = false;
          }
          // hide datatable when no matching verified store found as per search key
          this.showStores = this.filteredRecords && this.filteredRecords.length === 0 ? false : true;
          if (!this.showStores) {
            this.messageToBeDisplayed = noDataFoundMessage;
          }
        } catch (verifiedStoredException) {
          createLog({
            lwcName: LWC_NAME,
            methodName: FIND_VERIFIED_STORES_BY_SEARCH_KEY_METHOD_NAME,
            message: JSON.stringify(verifiedStoredException)
          });
        }
      })
      .catch((error) => {
        this.verifiedStoresError = error;
        this.verifiedStores = undefined;
        this.filteredRecords = undefined;
        createLog({
          lwcName: LWC_NAME,
          methodName: FIND_VERIFIED_STORES_BY_SEARCH_KEY_METHOD_NAME,
          message: JSON.stringify(error.body)
        });
      });
  }

  /**
   * @description It returns the SLDS class name(s) based on the search.
   * @JIRA# LEM-3495
   */
  get dataTableStyling() {
    if (this.enableServerSearch) {
      return DATA_TABLE_STYLING_ON_SERVER_SEARCH;
    }
    return DATA_TABLE_STYLING_ON_SCROLL;
  }

  /**
   * @description To get the formatted records from the passed records on basis of search key.
   * @param records
   */
  getFormattedRecords(records) {
    this.formattedRecords = records.map((record) => {
      return {
        'accountId': record.accountId,
        'accountName': record.accountName.replace(new RegExp(this.searchKey, GLOBAL_IGNORE_CASE_REG_EXP_PARAMETER), (matchedKey) => `<b>${matchedKey}</b>`),
        'activationStatus': record.activationStatus,
        'address': record.address.replace(new RegExp(this.searchKey, GLOBAL_IGNORE_CASE_REG_EXP_PARAMETER), (matchedKey) => `<b>${matchedKey}</b>`),
        'externalIds': record.externalIds.replace(new RegExp(this.searchKey, GLOBAL_IGNORE_CASE_REG_EXP_PARAMETER), (matchedKey) => `<b>${matchedKey}</b>`)
      }
    });
  }

  /**
   * @desciption To remove duplicate stores from the list of passed records collected
   * from the server.
   * @param records
   * @returns uniqueElements
   */
  getUniqueElements(records) {
    var uniqueElements = [];
    var uniqueIds = [];
    records.filter(element => {
      var isDuplicate = uniqueIds.includes(element.accountId);
      if (!isDuplicate) {
        uniqueIds.push(element.accountId);
        uniqueElements.push(element);
      }
      return false;
    });
    return uniqueElements;
  }

  /**
   * @description It is used to create child Work Order for the selected stores.
   * @JIRA# LEM-2013
   */
  handleAddStores() {
    this.loaded = false;
    if (this.selection && Array.isArray(this.selection) && this.selection.length > 0) {
      let selectedRecordIds = '';
      this.selection.forEach((eachSelection) => {
        if (eachSelection) {
          selectedRecordIds = selectedRecordIds + ',' + eachSelection;
        }
      });

      // replacing starting comma with a blank string to avoid undefined Id exception
      selectedRecordIds = selectedRecordIds.replace(/^,/, '');

      validateStores({
        parentWorkOrderId: this.recordId,
        storeAccountIds: selectedRecordIds
      })
        .then(result => {
          let validationMessagesByResult = undefined;
          if (result['validation'] == 'Success') {
            this.loaded = true;
            this.createChildWorkOrders(selectedRecordIds);
          }
          else if (result['validation'] == 'Failure') {
            this.loaded = true;
            validationMessagesByResult = result['validation-message'];
            this.validateStoresError = validationMessagesByResult.join('<br/>');
          }
        })
        .catch(error => {
          this.validateStoresError = error;
        });

      // replacing starting comma with a blank string to avoid undefined Id exception
      //this.createChildWorkOrders(selectedRecordIds.replace(/^,/, ''));


    }
  }

  /**
   * @description To check criteria for disabling infinite loading.
   * @return Boolean
   */
  isEligibleToDisableInfiniteLoading() {
    return this.isClearSearchCalled || this.isPreviousSearchNoDataFound || this.isServerSearchCalled;
  }

  /**
   * @description To check criteria for disabling infinite loading on server search or no data found on
   * previous search.
   * @return Boolean
   */
  isEligibleToDisableInfiniteLoadingOnSearch() {
    return this.isPreviousSearchNoDataFound || this.isServerSearchCalled;
  }

  /**
   * @description This will load more data while scrolling datatable.
   * @JIRA# LEM-2013
   * @param event
   */
  loadMoreData(event) {
    this.targetDatatable = event.target;
    if (this.currentWorkOrderStatus === planningStatus) {
      this.targetDatatable.isLoading = true;
      this.fetchVerifiedAccounts().then(() => {
        this.targetDatatable.isLoading = false;
      });
    }
  }

  /**
   * @description To remove passed element from an array.
   * @param arrayToFilter
   * @param valueToFilter
   */
  removeArray(arrayToFilter, valueToFilter) {
    return arrayToFilter.filter(function (eachElement) {
      return eachElement !== valueToFilter;
    });
  }

  /**
   * @description This will handle datatable row selection/deselection.
   * @JIRA# LEM-2013
   * @param event
   */
  rowSelection(event) {
    // remove all the selections from datatable when all selected items are removed
    if (event.detail.selectedRows.length === 0 && this.filteredRecords.length === this.verifiedStores.length) {
      this.verifiedStores.forEach((eachVerifiedStore) => {
        if (Array.isArray(this.selection) && this.selection.includes(eachVerifiedStore.accountId)) {
          this.selection = this.removeArray(this.selection, eachVerifiedStore.accountId);
        }
      });
    }
    // to control row selection/deselection when local search is called for the first time
    if (this.searchCount > 1 || (this.searchCount === 0 && event.detail.selectedRows.length > 0)) {
      let selectedItems = new Set();
      let filteredItems = new Set();
      this.filteredRecords.forEach((eachFilteredStore) => {
        filteredItems.add(eachFilteredStore.accountId);
      });
      // removing filtered items
      filteredItems.forEach((eachFilterId) => {
        if (Array.isArray(this.selection) && this.selection.includes(eachFilterId)) {
          this.selection = this.removeArray(this.selection, eachFilterId);
        }
      });
      if (event.detail.selectedRows) {
        event.detail.selectedRows.forEach((eachSelectedRow) => {
          selectedItems.add(eachSelectedRow.accountId);
        });
        // add any new items to the selection list
        selectedItems.forEach((eachSelectedId) => {
          // adding selected item in selection
          if (Array.isArray(this.selection) && !this.selection.includes(eachSelectedId)) {
            this.selection.push(eachSelectedId);
          }
        });
      }
    }
    // enable/disable Add Stores button according to the number of current selections
    this.addStoresButtonDisabled = this.selection.length <= 0;
  }

  /**
   * @description To find stores through server search.
   * @JIRA# LEM-3495
   * @param event
   */
  triggerServerSearch(event) {
    this.isServerSearchCalled = true;
    if (event.detail) {
      if (this.searchKey) {
        this.loaded = false;
        this.findVerifiedAccounts();
      } else {
        // show toast message when server search is initiated without any search key
        setMessage(serverSearchMessageWithBlankKey);
        setVariant(toastVariantInfo);
        showNotification(this);
      }
    }
  }
}