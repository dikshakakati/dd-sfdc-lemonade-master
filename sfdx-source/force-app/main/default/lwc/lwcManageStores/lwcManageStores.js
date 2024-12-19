import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAssociatedAccounts from '@salesforce/apex/ManageStoresController.selectAssociatedAccounts';
import getSelectedAccountsByStoreId from '@salesforce/apex/ManageStoresController.selectNonAssociatedAccountsByStoreId';
import getSelectedAccountsByBusinessId from '@salesforce/apex/ManageStoresController.selectNonAssociatedAccountsByBusinessId';
import getSelectedAccounts from '@salesforce/apex/ManageStoresController.selectNonAssociatedAccountsById';
import saveAssociatedAccounts from '@salesforce/apex/ManageStoresController.saveAssociatedAccounts';
import uploadFile from '@salesforce/apex/ManageStoresController.uploadFile';
import accountAssociatedLabel from '@salesforce/label/c.Manage_Stores_Already_Associated';
import selectedStoresLabel from '@salesforce/label/c.Manage_Stores_Selected_Stores';
import csvInstructionsLabel from '@salesforce/label/c.Manage_Stores_CSV_Instrunctions';
import manageStoresAccountSynchronousProcessingsLabel from '@salesforce/label/c.Manage_Stores_Processing_Limit';
import manageStoresRecordLimitInCsv from '@salesforce/label/c.Manage_Stores_Max_Limit_Csv';
import csvLimitInstructionLabel from '@salesforce/label/c.Manage_Stores_Csv_Limit_Instruction';

const columns = [
    {
        label: 'Store Name',
        fieldName: 'Name',
        sortable: false,
        hideDefaultActions: true
    },
    {
        initialWidth: 125,
        label: 'Activation Status',
        fieldName: 'Activation_Status__c',
        sortable: false,
        hideDefaultActions: true
    },
    {
        initialWidth: 145,
        label: 'Partnership Status',
        fieldName: 'Partnership_Status__c',
        sortable: false,
        hideDefaultActions: true
    }
];

export default class LwcManageStores extends LightningElement {
    @api recordId;
    @api sobjectName;

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
        csvInstructionsLabel
    };
    selectedAccounts = [];
    selectedAccountdata = [];
    selectedAccountsFromLookUp = [];
    associatedAccounts = '';

    @track importDataTable = [];
    @track importDataTableAssociated = [];
    @track importShowTable = false;
    @track importShowTableAssociated = false;
    @track importShowError = false;
    @track importErrorMessages = [];
    @track filename;
    @track filecontents;
    @track filedataraw;
    @track batchProcessing;
    @track maximumAccountOnCsvLimitReached = false;


    connectedCallback() {
        this.addAccountsDisabled = true;
        this.activeTab = 3;
        getAssociatedAccounts({ parentId: this.recordId })
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
                this.errorHeader = true;
                if (Array.isArray(error.body)) {
                    this.errorHeaderMessages.push(error.body.map(e => e.message));
                } else if (typeof error.body.message === 'string') {
                    this.errorHeaderMessages.push(error.body.message);
                }
                this.toggleWorking();
            });
    }

    renderedCallback() {
    }

    getSelectedRows() {
        if (this.activeTab == 0) {
            return this.template.querySelector('[data-id="Table0"]').getSelectedRows();
        } else if (this.activeTab == 1) {
            return this.template.querySelector('[data-id="Table1"]').getSelectedRows();
        } else if (this.activeTab == 2) {
            return this.template.querySelector('[data-id="Table2"]').getSelectedRows();
        } else if (this.activeTab == 3) {
            return this.template.querySelector('[data-id="Table3"]').getSelectedRows();
        }
        return null;
    }

    addAccounts() {
        this.batchProcessing = false;
        if (this.maximumAccountOnCsvLimitReached) {
            this.ShowToast('Error!!', csvLimitInstructionLabel, 'error', 'dismissable');
        } else {
            this.toggleWorking();
            let accountIds = this.getSelectedRows()
                .map(function (account) {
                    return account.Id;
                });
            // to show toast that Accounts are processed in the background
            if (accountIds.length > parseInt(manageStoresAccountSynchronousProcessingsLabel)) {
                this.batchProcessing = true;
            }
            let accountsString = '';
            if (this.associatedAccounts.length > 0) {
                accountsString = this.associatedAccounts + ',';
            }
            accountsString += accountIds.toString();
            saveAssociatedAccounts({ parentId: this.recordId, accounts: accountsString })
                .then((result) => {
                    this.closeAction();
                })
                .catch((error) => {
                    this.handleImportError(error);
                }).finally(() => {
                    this.toggleWorking();
                });
            uploadFile({ base64: this.filecontents, filename: this.filename, recordId: this.recordId }).then(result => {
                let title = `${filename} uploaded successfully!!`;
                this.ShowToast('Success!', title, 'success', 'dismissable');
                this.updateRecordView(this.recordId);
            }).catch(err => {
                this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
            }).finally(() => {
                this.toggleWorking();
            })
        }
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


    //handle event from child component when a csv has been loaded
    handleFileAdded(event) {
        this.maximumAccountOnCsvLimitReached = false;
        this.filename = event.detail.filename;
        this.filecontents = event.detail.filecontents;
        let accountJson = [...event.detail.data];
        this.filedataraw = accountJson;
        const accountIdObjects = accountJson.filter(row => row.Id != null);
        const storeIdsObjects = accountJson.filter(row => row.StoreId != null);
        const businessIdsObjects = accountJson.filter(row => row.BusinessId != null);
        let isAccountIdsIncluded = accountIdObjects && accountIdObjects.length > 0;
        let isstoreIdsIncluded = storeIdsObjects && storeIdsObjects.length > 0;
        let isbusinessIdsIncluded = businessIdsObjects && businessIdsObjects.length > 0;
        const csvRecordLimit = parseInt(manageStoresRecordLimitInCsv);
        if ((isAccountIdsIncluded && accountIdObjects.length > csvRecordLimit)
            || (isstoreIdsIncluded && storeIdsObjects.length > csvRecordLimit)
            || (isbusinessIdsIncluded && businessIdsObjects.length > csvRecordLimit)
        ) {
            this.maximumAccountOnCsvLimitReached = true;
            this.ShowToast('Error!!', csvLimitInstructionLabel, 'error', 'dismissable');
        }
        if ((isAccountIdsIncluded && (isstoreIdsIncluded || isbusinessIdsIncluded)) ||
            (isstoreIdsIncluded && (isAccountIdsIncluded || isbusinessIdsIncluded)) ||
            (isbusinessIdsIncluded && (isAccountIdsIncluded || isstoreIdsIncluded))) {
            this.importShowTable = false;
            this.importDataTable = [];
            this.importShowError = true;
            this.importErrorMessages.push(csvImportErrorLabel);
        }
        else if (isAccountIdsIncluded) {
            const accountIds = accountIdObjects.map(row => row.Id);
            getSelectedAccounts({ accountIds: accountIds, parentId: this.recordId })
                .then(data => {
                    this.handleImportData(data);
                })
                .catch(error => {
                    this.handleImportError(error);
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
                });
        }
    }

    handleImportData(data) {
        if (data.length > 0) {
            this.importDataTable = data;

            if (this.importDataTable.length == 0) {
                this.importShowTable = false;
            } else {
                this.importShowTable = true;
            }
            this.importShowError = false;
            this.importErrorMessages = [];
        } else {
            this.importShowTable = false;
            this.importShowError = true;
            this.importErrorMessages.push('No accounts Found');
        }
    }

    handleImportError(error) {
        this.importShowTable = false;
        this.importShowTableAssociated = false;
        this.importShowError = true;
        if (Array.isArray(error.body)) {
            this.importErrorMessages.push(error.body.map(e => e.message));
        } else if (typeof error.body.message === 'string') {
            this.importErrorMessages.push(error.body.message);
        }
    }


    handleFileReadError(event) {
        this.importShowError = true;
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
        this.selectedStores = 0;
    }

    closeAction() {
        let successmessage = 'Accounts Associated to ' + this.sobjectName + '. Please refresh the page to view the changes.';
        if (this.sobjectName == 'Contract' && this.batchProcessing) {
            successmessage += 'The Accounts are processed in the background, Please check back after 5 mnts.';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: successmessage,
                variant: 'Success',
            }),
        );

        const closeQA = new CustomEvent('close');
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

    //update the record page
    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

}