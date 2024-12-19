import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getAssociatedAccounts from "@salesforce/apex/ManageStoresContractController.selectAssociatedAccounts";
import getSelectedAccountsByStoreId from '@salesforce/apex/ManagePricingUploadScreenController.selectNonAssociatedAccountsByStoreId';
import getSelectedAccountsByBusinessId from '@salesforce/apex/ManagePricingUploadScreenController.selectNonAssociatedAccountsByBusinessId';
import getSelectedAccounts from '@salesforce/apex/ManagePricingUploadScreenController.selectNonAssociatedAccountsById';
import accountAssociatedLabel from '@salesforce/label/c.Manage_Stores_Already_Associated';
import selectedStoresLabel from '@salesforce/label/c.Manage_Stores_Selected_Stores';
import csvInstructionsLabel from '@salesforce/label/c.Manage_Pricing_CSV_Instrunctions';
import CSVTemplateResource from "@salesforce/resourceUrl/Manage_Pricing_CSV_Template";
import createLog from "@salesforce/apex/LogController.createLog";
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [
    {
        label: 'Store Name',
        fieldName: 'Name',
        sortable: false,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        initialWidth: 125,
        label: 'Activation Status',
        fieldName: 'Activation_Status__c',
        sortable: false,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        initialWidth: 145,
        label: 'Partnership Status',
        fieldName: 'Partnership_Status__c',
        sortable: false,
        hideDefaultActions: true
    }
];

const LWC_NAME = "lwcManagePricingUploadScreenARP";
const GET_ASSOCIATED_ACCOUNTS = "getAssociatedAccounts";
const GET_SELECTED_ACCOUNTS_BY_STOREID = "getSelectedAccountsByStoreId";
const GET_SELECTED_ACCOUNTS = "getSelectedAccounts";
const GET_SELECTED_ACCOUNTS_BY_BUSINESSID = "getSelectedAccountsByBusinessId";
const ASSOCIATED_ACCOUNTS_LOADING_ERROR =
    "An issue occurred while retrieving the subscriptions; the contract does not have any CCP enabled products/packages.\n Please reach out to your system administrator for assistance.";

export default class LwcManagePricingUploadScreenARP extends NavigationMixin(LightningElement) {

    @api
    set recordId(value) {
        this._recordId = value

        if (this._recordId) {
            this.fetchAssociatedAccounts();
        }
    }
    get recordId() {
        return this._recordId;
    }

    columns = columns;
    working = true;
    addAccountsDisabled;
    selectedStores = 0;
    showSuccess = false;
    showTabs = true;

    returnVariant = 'destructive';
    batchId;
    labels = {
        accountAssociatedLabel,
        selectedStoresLabel,
        csvInstructionsLabel,
        CSVTemplateResource
    };
    selectedAccounts = [];
    associatedAccounts = '';
    getAssociatedAccountsError;
    ShowGetAssociatedAccountsError;

    @track importDataTable = [];
    @track importDataTableAssociated = [];
    @track importShowTable = false;
    @track importShowTableSpinner = false;
    @track importShowTableAssociated = false;
    @track importShowError = false;
    @track importErrorMessages = [];
    @track filename;
    @track filecontents;
    @track showPricingScreenComponent = false;
    @track preSelectedRows = [];
    @track sendaccountIds;
    @track accountIds;
    accountsDataTable;

    fetchAssociatedAccounts() {
        this.addAccountsDisabled = true;
        this.activeTab = 3;
        if (this.recordId != undefined) {
            getAssociatedAccounts({ contractId: this.recordId })
                .then((result) => {
                    if (result.length > 0) {
                        this.importDataTableAssociated = result;
                    }
                    if (this.importDataTableAssociated.length == 0) {
                        this.importShowTableAssociated = false;
                    } else {
                        this.importShowTableAssociated = true;
                        let associatedAccountIds = this.importDataTableAssociated.map(function (account) { return account.Id; });
                        this.associatedAccounts = associatedAccountIds.toString();
                    }

                    this.toggleWorking();
                })
                .catch((error) => {
                    this.ShowGetAssociatedAccountsError = true;
                    this.getAssociatedAccountsError = ASSOCIATED_ACCOUNTS_LOADING_ERROR;
                    this.toggleWorking();
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: GET_ASSOCIATED_ACCOUNTS,
                        message: JSON.stringify(error.body)
                    });
                });
        }
    }

    getSelectedRows() {
        if (this.activeTab == 3) {
            return this.template.querySelector('[data-id="Table3"]').getSelectedRows();
        }
        return null;
    }

    addAccounts() {
        this.activeTab = 3;
        let accountIds = this.getSelectedRows()
            .map(function (data) {
                return data.Id;
            });
        this.sendaccountIds = accountIds.toString();
        this.accountsDataTable = JSON.stringify(this.getSelectedRows());
        this.showPricingScreenComponent = true;

    }

    selectedRowHandler(event) {
        let details = event.detail;

        if (details.selectedRows.length > 0) {
            this.addAccountsDisabled = false;
            let storeData = this.getSelectedRows();
            if (storeData) {
                let storeIds = storeData.map(function (store) {
                    return store.Id;
                });
                this.selectedStores = storeIds.length;
            }
        } else {
            this.addAccountsDisabled = true;
            this.selectedStores = 0;
        }
        this.checkFullDisable();
    }

    handleActive(event) {
        this.activeTab = event.target.value;
        this.checkFullDisable();
    }

    toggleWorking() {
        this.working = !this.working;
    }

    checkFullDisable() {
        if (this.errorHeader || this.showSuccess) {
            this.addAccountsDisabled = true;
            this.showTabs = false;
        }
    }

    handleSubmit(event) {
        event.preventDefault();
    }

    handleBackButton(event) {
        this.showPricingScreenComponent = event.detail.showPricingScreenComponent;
        let accountIds = event.detail.accountRecords.split(",");
        this.preSelectedRows = accountIds;
    }

    handleFileAdded(event) {
        this.importShowTableSpinner = true;
        this.filename = event.detail.filename;
        this.filecontents = event.detail.filecontents;
        const accountIdObjects = this.filterRowsByProperty(event.detail.data, "Id");
        const storeIdsObjects = this.filterRowsByProperty(
            event.detail.data,
            "StoreId"
        );
        const businessIdsObjects = this.filterRowsByProperty(
            event.detail.data,
            "BusinessId"
        );

        this.checkAndHandleMutuallyExclusiveIds(accountIdObjects, storeIdsObjects, businessIdsObjects);
    }

    filterRowsByProperty(data, propertyName) {
        return data.filter((row) => row[propertyName] != null);
    }

    checkAndHandleMutuallyExclusiveIds(accountIdObjects, storeIdsObjects, businessIdsObjects) {
        let isAccountIdsIncluded = accountIdObjects && accountIdObjects.length > 0;
        let isstoreIdsIncluded = storeIdsObjects && storeIdsObjects.length > 0;
        let isbusinessIdsIncluded = businessIdsObjects && businessIdsObjects.length > 0;

        if ((isAccountIdsIncluded && (isstoreIdsIncluded || isbusinessIdsIncluded)) ||
            (isstoreIdsIncluded && (isAccountIdsIncluded || isbusinessIdsIncluded)) ||
            (isbusinessIdsIncluded && (isAccountIdsIncluded || isstoreIdsIncluded))) {
            this.importShowTable = false;
            this.importDataTable = [];
            this.importShowError = true;
        }
        else if (isAccountIdsIncluded) {
            this.accountIds = accountIdObjects.map(row => row.Id);
            getSelectedAccounts({ accountIds: this.accountIds, parentId: this.recordId })
                .then(data => {
                    this.handleImportData(data);
                })
                .catch(error => {
                    this.handleImportError(error);
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: GET_SELECTED_ACCOUNTS,
                        message: JSON.stringify(error.body)
                    });
                });
        }
        else if (isstoreIdsIncluded) {
            const storeIds = storeIdsObjects.map(row => row.StoreId);
            getSelectedAccountsByStoreId({ storeIds: storeIds, parentId: this.recordId })
                .then(data => {
                    this.handleImportData(data);
                })
                .catch(error => {
                    this.handleImportError(error);
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: GET_SELECTED_ACCOUNTS_BY_STOREID,
                        message: JSON.stringify(error.body)
                    });
                });
        }
        else if (isbusinessIdsIncluded) {
            const businessIds = businessIdsObjects.map(row => row.BusinessId);
            getSelectedAccountsByBusinessId({ businessIds: businessIds, parentId: this.recordId })
                .then(data => {
                    this.handleImportData(data);
                })
                .catch(error => {
                    this.handleImportError(error);
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: GET_SELECTED_ACCOUNTS_BY_BUSINESSID,
                        message: JSON.stringify(error.body)
                    });
                });
        }
    }

    handleImportData(data) {
        if (data.length > 0) {
            this.importDataTable = data;
            this.preSelectedRows = this.accountIds;
            this.selectedStores = this.importDataTable.length;
            this.importShowTableSpinner = false;
            this.addAccountsDisabled = false;
            this.importShowTable = true;
            this.importShowError = false;
            this.importErrorMessages = [];
        } else {
            this.importShowTable = false;
            this.importShowError = true;
            this.importErrorMessages = [];
            this.importErrorMessages.push('No accounts Found');
            this.importShowTableSpinner = false;
        }
    }

    handleImportError(error) {
        this.importShowTable = false;
        this.importShowTableSpinner = false;
        this.importShowError = true;
        this.importErrorMessages = [];
        if (Array.isArray(error.body)) {
            this.importErrorMessages.push(error.body.map(e => e.message));
        } else if (typeof error.body.message === 'string') {
            this.importErrorMessages.push(error.body.message);
        }
    }


    handleFileReadError(event) {
        this.importShowError = true;
        this.importErrorMessages = [];
        this.importShowTableSpinner = false;
        if (Array.isArray(event.body)) {
            this.importErrorMessages.push(event.body.map(e => e.message));
        } else if (typeof event.body.message === 'string') {
            this.importErrorMessages.push(event.body.message);
        }
    }

    handleFileRemoved(event) {
        this.importShowTable = false;
        this.importDataTable = [];
        this.addAccountsDisabled = true;
        this.importShowTableSpinner = false;
        this.selectedStores = 0;
    }

    handleCloseParent() {
        this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
    }
}