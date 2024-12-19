import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getAssociatedAccounts from "@salesforce/apex/ManageStoresContractController.selectAssociatedAccounts";
import getSelectedAccountsByStoreId from "@salesforce/apex/ManageStoresContractController.selectAccountsByStoreId";
import getSelectedAccountsByBusinessId from "@salesforce/apex/ManageStoresContractController.selectAccountsByBusinessId";
import selectAccountsById from "@salesforce/apex/ManageStoresContractController.selectAccountsById";
import areAllBusinessAccounts from "@salesforce/apex/ManageStoresContractController.areAllBusinessAccounts";
import calculateNewStoresAndCOO from "@salesforce/apex/ManageStoresContractController.calculateNewStoresAndCOO";
import accountAssociatedLabel from "@salesforce/label/c.Manage_Stores_Already_Associated";
import selectedStoresLabel from "@salesforce/label/c.Manage_Stores_Selected_Stores";
import csvInstructionsLabel from "@salesforce/label/c.Manage_Stores_CSV_Instrunctions";
import popUpInstructionsLabel from "@salesforce/label/c.Manage_Stores_Pop_Up_Instructions";
import manageStoresHeadingLabel from "@salesforce/label/c.Manage_Stores_Heading";
import manageStoresCSVTemplateLabel from "@salesforce/label/c.Manage_Stores_CSV_Template";
import CSVTemplateResource from "@salesforce/resourceUrl/Manage_Stores_CSV_Template";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import createLog from "@salesforce/apex/LogController.createLog";

const columns = [
  {
    label: "Store Name",
    fieldName: "Name",
    sortable: false,
    hideDefaultActions: true
  },
  {
    initialWidth: 125,
    label: "Activation Status",
    fieldName: "Activation_Status__c",
    sortable: false,
    hideDefaultActions: true
  },
  {
    initialWidth: 145,
    label: "Partnership Status",
    fieldName: "Partnership_Status__c",
    sortable: false,
    hideDefaultActions: true
  }
];

const uploadColumns = [
  {
    label: "Store Name",
    fieldName: "Name",
    sortable: false,
    hideDefaultActions: true
  },
  {
    initialWidth: 125,
    label: "Activation Status",
    fieldName: "Activation_Status__c",
    sortable: false,
    hideDefaultActions: true
  }
];
const LWC_NAME = "LwcManageStoresContractCCP";
const GET_ASSOCIATED_ACCOUNTS = "getAssociatedAccounts";
const ARE_ALL_BUSINESS_ACCOUNTS = "areAllBusinessAccounts";
const CALCULATING_NEW_STORES_AND_COO = 'calculateNewStoresAndCOO';
const GET_SELECTED_ACCOUNTS_BY_ACCOUNTID = "getSelectedAccountsByStoreId";

const ASSOCIATED_ACCOUNTS_LOADING_ERROR =
  "An issue occurred while retrieving the associated contract records. Please reach out to your system administrator for assistance.";

export default class LwcManageStoresContractCCP extends LightningElement {
  sendaccountIds;
  accountsDataTable = [];
  @track filename;
  @track filecontents;
  @track showEntitlementScreenComponent = false;
  @track isProcessingExistingAccounts;
  @track isProcessingNewAndCoo = false;
  @track isProcessingOnlyCoo = false;
  @track isProcessingOnlyNew = false;

  columns = columns;
  uploadColumns = uploadColumns;
  loadSpinner = true;
  disableNextButton;
  selectedStores = 0;

  accountIds;

  labels = {
    accountAssociatedLabel,
    selectedStoresLabel,
    csvInstructionsLabel,
    CSVTemplateResource,
    popUpInstructionsLabel,
    manageStoresHeadingLabel,
    manageStoresCSVTemplateLabel
  };
  showUploadScreen = false;
  isBusinessIdsImported = false;
  getAssociatedAccountsError;
  ShowGetAssociatedAccountsError;

  @track importDataTable;
  @track preSelectedRows = [];
  @track importDataTableAssociated = [];
  @track importShowTable = false;
  @track importShowTableSpinner = false;
  @track importShowTableAssociated = false;
  @track importShowError = false;
  @track importErrorMessages = [];
  @track filedataraw;
  @track numberOfStores;
  @track accountSegmentForContract;
  @wire(CurrentPageReference) currentPageReference;

  get recordId() {
    return this.currentPageReference.state.recordId;
  }

  get totalStores() {
    return this.importDataTableAssociated.length + this.selectedStores;
  }

  connectedCallback() {
    this.disableNextButton = true;
    getAssociatedAccounts({ contractId: this.recordId })
      .then((result) => {
        if (result.length > 0) {
          this.importDataTableAssociated = result;
        }

        this.importShowTableAssociated =
          this.importDataTableAssociated.length > 0;
        this.loadSpinner = !this.loadSpinner;
      })
      .catch((error) => {
        if (error) {
          this.ShowGetAssociatedAccountsError = true;
          this.getAssociatedAccountsError = ASSOCIATED_ACCOUNTS_LOADING_ERROR;
          this.loadSpinner = !this.loadSpinner;
          createLog({
            lwcName: LWC_NAME,
            methodName: GET_ASSOCIATED_ACCOUNTS,
            message: JSON.stringify(error.body)
          });
        }
      });
  }

  getSelectedRows() {
    if (this.activeTab === 0) {
      return this.template
        .querySelector('[data-id="Table0"]')
        .getSelectedRows();
    } else if (this.activeTab === 1) {
      return this.template
        .querySelector('[data-id="Table1"]')
        .getSelectedRows();
    }
    return null;
  }

  addAccounts() {
    calculateNewStoresAndCOO({ accountIds: this.accountIds })
      .then((data) => {
        if (data) {
          this.isProcessingNewAndCoo = data.isProcessingNewAndCoo;
          this.isProcessingOnlyCoo = data.isProcessingOnlyCoo;
          this.isProcessingOnlyNew = data.isProcessingOnlyNew;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: CALCULATING_NEW_STORES_AND_COO,
          message: JSON.stringify(error.body)
        });
      });

    this.checkAllBusinessAccounts()
      .then(() => {
        this.processSelectedRows();
        this.showEntitlementScreenComponent = true;
      })
      .catch((error) => {
        this.handleImportError(error);
      });
  }

  checkAllBusinessAccounts() {
    return areAllBusinessAccounts({ accountIds: this.accountIds })
      .then((data) => {
        if (data) {
          this.isBusinessIdsImported = true;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: ARE_ALL_BUSINESS_ACCOUNTS,
          message: JSON.stringify(error.body)
        });
      });
  }

  processSelectedRows() {
    this.activeTab = 1;
    this.accountIds = this.getSelectedRows().map((data) => data.Id);
    this.sendaccountIds = this.accountIds.toString();
    this.accountsDataTable = JSON.stringify(this.getSelectedRows());
  }

  selectedRowHandler(event) {
    let details = event.detail;

    if (details.selectedRows.length > 0) {
      this.disableNextButton = false;
      const storeData = this.getSelectedRows();
      if (storeData) {
        const storeIds = storeData.map(function (store) {
          return store.Id;
        });
        this.selectedStores = storeIds.length;
      }
    } else {
      this.disableNextButton = true;
      this.selectedStores = 0;
    }
    this.checkFullDisable();
  }

  handleExistingAccounts() {
    this.showTabs = true;
    this.showUploadScreen = true;
    this.isProcessingExistingAccounts = true;
  }

  handleNewAccounts() {
    this.showTabs = true;
    this.showUploadScreen = true;
    this.isProcessingExistingAccounts = false;
  }
  viewSelectionPopUp() {
    this.showTabs = false;
    this.showUploadScreen = false;
    this.importErrorMessages = [];
    this.importShowTable = false;
    this.importDataTable = [];
  }

  handleActive(event) {
    this.activeTab = event.target.value;

    this.checkFullDisable();
  }
  checkFullDisable() {
    if (this.errorHeader) {
      this.disableNextButton = true;
      this.showTabs = false;
    }
  }
  handleSubmit(event) {
    event.preventDefault();
  }
  handleBackButton(event) {
    this.showEntitlementScreenComponent =
      event.detail.showPricingScreenComponent;
    let accountIds = event.detail.accountRecords.split(",");
    this.preSelectedRows = accountIds;
  }

  //handle event from child component when a csv has been loaded
  handleFileAdded(event) {
    this.importShowTableSpinner = true;
    this.filename = event.detail.filename;
    this.filecontents = event.detail.filecontents;
    this.importErrorMessages = [];
    this.isBusinessIdsImported = false;
    const accountIdObjects = this.filterRowsByProperty(event.detail.data, "Id");
    const storeIdsObjects = this.filterRowsByProperty(
      event.detail.data,
      "StoreId"
    );
    const businessIdsObjects = this.filterRowsByProperty(
      event.detail.data,
      "BusinessId"
    );

    this.checkAndHandleMutuallyExclusiveIds(
      accountIdObjects,
      storeIdsObjects,
      businessIdsObjects
    );
  }

  filterRowsByProperty(data, propertyName) {
    return data.filter((row) => row[propertyName] != null);
  }

  checkAndHandleMutuallyExclusiveIds(
    accountIdObjects,
    storeIdsObjects,
    businessIdsObjects
  ) {
    let isAccountIdsIncluded = accountIdObjects && accountIdObjects.length > 0;
    let isstoreIdsIncluded = storeIdsObjects && storeIdsObjects.length > 0;
    let isbusinessIdsIncluded =
      businessIdsObjects && businessIdsObjects.length > 0;

    if (
      (isAccountIdsIncluded && (isstoreIdsIncluded || isbusinessIdsIncluded)) ||
      (isstoreIdsIncluded && (isAccountIdsIncluded || isbusinessIdsIncluded)) ||
      (isbusinessIdsIncluded && (isAccountIdsIncluded || isstoreIdsIncluded))
    ) {
      this.importShowTable = false;
      this.importDataTable = [];
      this.importShowError = true;
    } else if (isAccountIdsIncluded) {
      this.accountIds = accountIdObjects.map((row) => row.Id.trim());
      selectAccountsById({
        accountIds: this.accountIds,
        contractId: this.recordId,
        isProcessingExistingAccounts: this.isProcessingExistingAccounts
      })
        .then((data) => {
          this.handleImportData(data);
        })
        .catch((error) => {
          this.handleImportError(error);
        });
    } else if (isstoreIdsIncluded) {
      const storeIds = storeIdsObjects.map((row) => row.StoreId);

      getSelectedAccountsByStoreId({
        storeIds: storeIds,
        contractId: this.recordId,
        isProcessingExistingAccounts: this.isProcessingExistingAccounts
      })
        .then((data) => {
          this.handleImportData(data);
        })
        .catch((error) => {
          this.handleImportError(error);
          createLog({
            lwcName: LWC_NAME,
            methodName: GET_SELECTED_ACCOUNTS_BY_ACCOUNTID,
            message: JSON.stringify(error.body)
          });
        });
    } else if (isbusinessIdsIncluded) {
      const businessIds = businessIdsObjects.map((row) => row.BusinessId);

      getSelectedAccountsByBusinessId({
        businessIds: businessIds,
        contractId: this.recordId,
        isProcessingExistingAccounts: this.isProcessingExistingAccounts
      })
        .then((data) => {
          this.handleImportData(data);
        })
        .catch((error) => {
          this.handleImportError(error);
        });
    }
  }

  handleImportData(data) {
    if (data.length > 0) {
      this.importDataTable = [];
      this.importDataTable = data;
      this.preSelectedRows = this.accountIds;
      this.selectedStores = this.importDataTable.length;
      this.importShowTableSpinner = false;
      this.disableNextButton = false;

      if (this.importDataTable.length === 0) {
        this.importShowTable = false;
      } else {
        this.importShowTable = true;
      }
      this.importShowError = false;
      this.importErrorMessages = [];
    } else {
      this.importShowTable = false;
      this.importShowError = true;
      this.importShowTableSpinner = false;
    }
  }

  handleImportError(error) {
    this.importShowTable = false;
    this.importShowTableSpinner = false;
    this.importShowError = true;
    if (error.body === undefined) {
      this.importErrorMessages.push(error.message);
    } else if (Array.isArray(error.body)) {
      this.importErrorMessages.push(error.body.map((e) => e.message));
    } else if (typeof error.body.message === "string") {
      this.importErrorMessages.push(error.body.message);
    }
  }

  handleFileReadError(event) {
    this.importShowError = true;
    if (Array.isArray(event.body)) {
      this.importErrorMessages.push(event.body.map((e) => e.message));
    } else if (typeof event.body.message === "string") {
      this.importErrorMessages.push(event.body.message);
    }
  }

  handleFileRemoved(event) {
    if (event) {
      this.importShowTable = false;
      this.importDataTable = [];
      this.disableNextButton = true;
      this.importShowTableSpinner = false;
      this.selectedStores = 0;
    }
  }

  closeAction() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message:
          "Accounts Associated to . Please refresh the page to view the changes.",
        variant: "Success"
      })
    );

    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }
  ShowToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
  handleCloseParent() {
    // Logic to close the parent component
    const closeParentAction = new CloseActionScreenEvent();
    this.dispatchEvent(closeParentAction);
  }
}
