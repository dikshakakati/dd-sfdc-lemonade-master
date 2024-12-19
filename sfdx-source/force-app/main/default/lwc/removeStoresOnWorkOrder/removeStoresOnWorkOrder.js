/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description JavaScript controller for removeStoresOnWorkOrder lightning web component.
 */
import { LightningElement, api, wire, track } from 'lwc';
import { reloadScreenAfterConfiguredDelay, setMessage, setVariant, showNotification } from 'c/utils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_FIELD from '@salesforce/schema/WorkOrder.AccountId';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/WorkOrder.Account_Type__c';
import STATUS_FIELD from '@salesforce/schema/WorkOrder.Status';
import createLog from '@salesforce/apex/LogController.createLog';
import removeStores from '@salesforce/apex/RemoveStoresOnWorkOrderController.removeStores';
import findStoresAddedBySearchKey from '@salesforce/apex/AddStoresOnWorkOrderController.findStoresAddedBySearchKey';
import fetchStoresAdded from '@salesforce/apex/AddStoresOnWorkOrderController.fetchStoresAdded';
import removeStoresAction from '@salesforce/label/c.Remove_Stores_Action';
import removeStoresQuickActionHeading from '@salesforce/label/c.Remove_Stores_Quick_Action_Heading';
import cancelAction from '@salesforce/label/c.Cancel_Action';
import storeRemovalSuccessMessage from '@salesforce/label/c.Remove_Stores_Success_Message';
import removeStoreOption1 from '@salesforce/label/c.Remove_Store_Option1_Message';
import removeStoreOption2 from '@salesforce/label/c.Remove_Store_Option2_Message';
import removeStoreWorkOrderMessage from '@salesforce/label/c.Remove_Store_WorkOrder_Message';
import removeStoreConfirm from '@salesforce/label/c.Remove_Store_Confirm_Message';
import removeStoreReason from '@salesforce/label/c.Remove_Store_Reason_Message';
import removeStoresLimit from '@salesforce/label/c.Remove_Stores_Limit';
import columnAccountName from '@salesforce/label/c.Add_Stores_Data_Table_Column_Account_Name';
import columnAccountAddress from '@salesforce/label/c.Add_Stores_Data_Table_Column_Account_Address';
import columnActivationStatus from '@salesforce/label/c.Add_Stores_Data_Table_Column_Activation_Status';
import columnExternalId from '@salesforce/label/c.Add_Stores_Data_Table_Column_External_ID';
import icon from '@salesforce/label/c.Stores_On_WorkPlan_Icon';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import delayInMilliseconds from '@salesforce/label/c.Add_Stores_Delay_In_Milliseconds';
import exceptionMessage from '@salesforce/label/c.Add_Stores_Exception_Message';
import noDataFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Data_Found_Message';
import notPlanningStatusMessage from '@salesforce/label/c.Remove_Store_WO_Status_Not_Planning_Message';
import noVerifiedStoresFoundForParentWorkOrder from '@salesforce/label/c.No_Stores_Found_To_Add_Stores_On_ParentWO';
import allowedStatues from '@salesforce/label/c.Remove_Stores_Allowed_WO_Status';
import searchBoxPlaceholder from '@salesforce/label/c.Add_Stores_Search_Box_Placeholder';
import serverSearchMessage from '@salesforce/label/c.Server_Search_Message';
import serverSearchMessageWithBlankKey from '@salesforce/label/c.Server_Search_Message_With_Blank_Key';
import searchKeyLength from '@salesforce/label/c.Search_Key_Minimum_Length';
import removeStoresLimitExceededInfoMessage from '@salesforce/label/c.Remove_Stores_Limit_Exceeded_Info_Message';
import successStatusMessage from '@salesforce/label/c.Remove_Stores_Message';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';

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
const REMOVE_STORES_METHOD_NAME = 'removeStores';
const CLOSE_MODAL_EVENT_NAME = 'closemodal';
const DATA_TABLE_STYLING_ON_SCROLL = 'dataTableStylingOnScroll';
const DATA_TABLE_STYLING_ON_SERVER_SEARCH = 'dataTableStylingOnSearch';
const DELAY_IN_MILLISECONDS = parseInt(delayInMilliseconds, 10);
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const FIND_VERIFIED_STORES_BY_SEARCH_KEY_METHOD_NAME = 'findStoresAddedBySearchKey';
const GET_RECORD_METHOD_NAME = 'errorCallback';
const GLOBAL_IGNORE_CASE_REG_EXP_PARAMETER = 'gi';
const LWC_NAME = 'RemoveStoresOnWorkOrder';
const VERIFIED_STORES_METHOD_NAME = 'fetchStoresAdded';
const REMOVE_OPTION1 = 'option1';
const REMOVE_OPTION2 = 'option2';
const SINGLE_PARENT_OPTION_YES = 'Yes';
const SINGLE_PARENT_OPTION_NO = 'No';
const CONTINUE = 'Continue';
const FINISH = 'Finish';

export default class RemoveStoresOnWorkOrder extends LightningElement {
    @api recordId;
    @track filteredRecords;
    @track formattedRecords;
    @track searchKey;
    @track verifiedStores = [];
    removeStoresAction = removeStoresAction;
    removeStoresButtonDisabled = true;
    removeStoresContainer;
    removeStoresQuickActionHeading = removeStoresQuickActionHeading;
    removeStoreOption1 = removeStoreOption1;
    removeStoreOption2 = removeStoreOption2;
    removeStoreWorkOrderMessage = removeStoreWorkOrderMessage;
    removeStoreConfirm = removeStoreConfirm;
    removeStoreReason = removeStoreReason;
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
    toastMessageOnStoreDelete = storeRemovalSuccessMessage;
    toastMessageOnError = toastMessage;
    verifiedStoresError;
    workOrderError;
    removeStoreOption;
    parentWorkOrderOption;
    noOptionSelected;
    selectedPDOA;
    @track continueFinishLabel = CONTINUE;
    @track isShowModal = false;
    @track showOptions = true;
    @track showParentWorkOrderOption = false;
    @track showConfirmation = false;
    @track recordsToBeDeleted = [];

    storeRemoveOptions = [
        { label: this.removeStoreOption1, value: 'option1' },
        { label: this.removeStoreOption2, value: 'option2' },
    ];
    parentWorkOrderOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
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
                if (allowedStatues.includes(this.currentWorkOrderStatus)) {
                    //if status is Planning, Confirmed, In Progress, At Risk or Past Due then fetch stores
                    this.fetchStoresAdded();
                    this.messageToBeDisplayed = successStatusMessage;
                } else {
                    //if status is Planning, Confirmed, In Progress, At Risk or Past Due then show message & hide search bar & datatable
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
     * @description To close the quick action panel after removing the selected stores.
     */
    closeModal() {
        this.dispatchEvent(new CustomEvent(CLOSE_MODAL_EVENT_NAME));
    }

    /**
     * @description To remove child Work Order for selected store Accounts.
     * @param selectedStoreAccountIds
     */
    removeStores(selectedStoreAccountIds) {
        this.cancelButton.disabled = true;
        this.loaded = false;
        removeStores({
            parentWorkOrderId: this.recordId,
            storeAccountIds: selectedStoreAccountIds,
            markAsDead: this.removeStoreOption === REMOVE_OPTION1 ? true : false,
            workOrderPDOA: this.selectedPDOA
        })
            .then((result) => {
                if (result) {
                    setMessage(JSON.stringify(result));
                    setVariant(toastVariantInfo);
                    showNotification(this);
                }
                this.hideModalBox();
                this.closeModal();
                //Added delay to ensure that the validation message is displayed.
                reloadScreenAfterConfiguredDelay(DELAY_IN_MILLISECONDS);
            })
            .catch((error) => {
                createLog({
                    lwcName: LWC_NAME,
                    methodName: REMOVE_STORES_METHOD_NAME,
                    message: JSON.stringify(error.body)
                });
                this.hideModalBox();
                this.closeModal();
            });
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
     * @description To fetch stores added to current WorkOrder.
     * @return List<AccountWrapper>
     */
    fetchStoresAdded() {
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
        return fetchStoresAdded({
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
                    console.log('here 0 ' + this.lastReturnedId);
                    console.log('here 0.1 ' + storeAccounts.length);
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
                    console.log('here 1 ' + this.targetDatatable);
                    console.log('here 1.1 ' + storeAccounts.length);
                    if (this.targetDatatable && storeAccounts.length === 0) {
                        // stop infinite loading when no more data to load
                        this.disableInfiniteLoading();
                        this.targetDatatable.isLoading = false;
                    }
                    if (this.targetDatatable) this.targetDatatable.isLoading = false;

                    console.log('here 2' + this.targetDatatable.isLoading);
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
     * @description To search store Accounts addded and related Xrefs
     * which are related to the business Account attached to parent Work Order by matching the
     * passed search key with the Account's Name or Address
     * or Xref's External Id.
     * @return List<AccountWrapper>
     */
    findStoresAddedBySearchKey() {
        this.addStoresContainer.searchKey = this.searchKey;
        this.addStoresContainer.parentIds = this.parentAccountIds;
        findStoresAddedBySearchKey({
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
     * @description It is used to remove selected stores from the current WorkOrder.
     */
    handleRemoveStores() {
        if (this.selection && Array.isArray(this.selection) && this.selection.length > 0) {
            let selectedRecordIds = '';
            this.selection.forEach((eachSelection) => {
                if (eachSelection) {
                    selectedRecordIds = selectedRecordIds + ',' + eachSelection;
                }
            });

            // replacing starting comma with a blank string to avoid undefined Id exception
            selectedRecordIds = selectedRecordIds.replace(/^,/, '');

            //console.log(result['validation-message']);
            this.removeStores(selectedRecordIds);

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
     * @param event
     */
    loadMoreData(event) {
        this.targetDatatable = event.target;
        if (allowedStatues.includes(this.currentWorkOrderStatus)) {
            this.targetDatatable.isLoading = true;
            this.fetchStoresAdded().then(() => {
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
        // enable/disable Remove Stores button according to the number of current selections
        this.removeStoresButtonDisabled = this.selection.length <= 0;
    }

    /**
     * @description To find stores through server search.
     */
    triggerServerSearch(event) {
        this.isServerSearchCalled = true;
        if (event.detail) {
            if (this.searchKey) {
                this.loaded = false;
                this.findStoresAddedBySearchKey();
            } else {
                // show toast message when server search is initiated without any search key
                setMessage(serverSearchMessageWithBlankKey);
                setVariant(toastVariantInfo);
                showNotification(this);
            }
        }
    }

    showModalBox(event) {
        if (this.hasSelectedStoresExceededLimit()) {
            return;
        }
        this.isShowModal = true;
        this.showOptions = true;
        this.showParentWorkOrderOption = false;
        this.showConfirmation = false;
        this.continueFinishLabel = CONTINUE;
        this.noOptionSelected = false;
        this.removeStoreOption = '';
        this.selectedPDOA = null;
        this.recordsToBeDeleted = [];
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    handleOptionChange(event) {
        if (event.detail.value === REMOVE_OPTION1 || event.detail.value === REMOVE_OPTION2) {
            this.removeStoreOption = event.detail.value;
            this.showParentWorkOrderOption = false;
            if (event.detail.value === REMOVE_OPTION2) {
                this.showParentWorkOrderOption = true;
            }
        } else {
            this.selectedPDOA = event.detail.value;
        }

    }

    handleNextAction(event) {
        if (this.continueFinishLabel === CONTINUE) {
            if (!(this.removeStoreOption === REMOVE_OPTION1 || this.removeStoreOption === REMOVE_OPTION2) ||
                (this.removeStoreOption === REMOVE_OPTION2 &&
                    !(this.selectedPDOA)
                )
            ) {
                this.noOptionSelected = true;
            } else {
                this.noOptionSelected = false;
                this.continueFinishLabel = FINISH;
                this.showOptions = false;
                this.showConfirmation = true;
                this.filteredRecords.forEach((eachRecord) => {
                    if (this.selection.includes(eachRecord.accountId)) {
                        this.recordsToBeDeleted.push(eachRecord);
                    }
                });

            }
        } else {
            this.handleRemoveStores();
        }
    }

    /**
     * @description It validates the selected rows limit.
     * @JIRA# LEM-10804
     * @return Boolean
     */
    hasSelectedStoresExceededLimit() {
        let isLimitExceeding = false;
        if (this.selection && Array.isArray(this.selection) && this.selection.length > removeStoresLimit) {
            setMessage(removeStoresLimitExceededInfoMessage);
            setVariant(toastVariantInfo);
            showNotification(this);
            isLimitExceeding = true;
        }
        return isLimitExceeding;
    }
}