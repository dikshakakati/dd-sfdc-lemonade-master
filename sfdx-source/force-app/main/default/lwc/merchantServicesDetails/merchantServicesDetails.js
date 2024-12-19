/**
  * @author Deloitte
  * @date 07/01/2024
  * @description The LWC application facilitates the retrieval and display merchant services records
  * and data below contract table.
*/
import { LightningElement, api, track, wire } from 'lwc';
import getAllMerchantServicesColumns from '@salesforce/apex/ContractsSummaryController.getAllMerchantServicesColumns';
import getAllMerchantServicesDetails from '@salesforce/apex/ContractsSummaryController.getAllMerchantServicesDetails';
import getReportId from '@salesforce/apex/ContractsSummaryController.getReportId';

const BLANK = '_blank';
const ERROT_FETCHING_RECORD = 'Error fetching report ID:';
const END_TAG = '</a>';
const FILTER_2 = '&fv1=';
const HREF = '<a href="';
const HTTPS = 'https://';
const ID = "id";
const LEFT_ALIGN = 'left';
const LOADING = "Loading";
const LIGHTNING_MERCHANT_SERVICE = '/lightning/r/Merchant_Service__c/';
const LIGHTNING_REPORT = '/lightning/r/Report/';
const NAME_API = 'Name';
const NO_CONTRACT_ERROR = 'Contract Id is not provided.';
const NO_SERVICES_ERROR = 'No services columns found.';
const NO_SERVICES_COLUMN_ERROR = 'Error fetching Service columns:';
const NO_SERVICES_FOUND = 'No stores are associated with the contract';
const NUMBER = 'number';
const SERVICE_URL = 'ServiceUrl';
const SPINNER_SIZE_MEDIUM = "medium";
const SPINS = "spins";
const STRING = 'string';
const TYPE_URL = 'url';
const TARGET = '" target="_blank">';
const VIEW = '/view';
const VIEW_FILTER_1 = '/view?fv0=';
const UNKNOWN_ERROR = 'Unknown error';
const FINAL_COMMISSION = 'Final_Commission__c';
const FINAL_FEE = 'Final_Fee__c';
const TRIAL_COMMISSION = 'Trial_Commission__c';
const TRIAL_FEE = 'Trial_Fee__c';

export default class LwcmerchantServicesDetails extends LightningElement {
    @track columns = [];
    @track servicesMap = new Map();
    @track storeEntries = [];
    @track loaded = false;
    @track errors;
    @track storeAccountName = '';
    @api contractId;
    @api splitCategory;
    @api businessAccountId;
    @api reportIdNew;
    sectionValues = {
        ID,
        LOADING,
        SPINNER_SIZE_MEDIUM,
        SPINS,
        BLANK,
        NO_SERVICES_FOUND
    }
    allStores = 'All Stores';
    viewAll = 'View All';
    storeAccount;
    servicesArray;
    connectedCallback() {
        if (this.businessAccountId) {
            this.executeInOrder();
        } else {
            this.errors = NO_CONTRACT_ERROR;
            console.error(NO_CONTRACT_ERROR);
        }
    }
    /**
     * Executes the methods in order using Promises.
     */
    executeInOrder() {
        this.fetchReportId()
            .then(() => this.fetchServicesColumns())
            .then(() => this.fetchServicesDetails())
            .then(() => this.loaded = true)

            .catch(error => {
                console.error(error);
                this.loaded = false;
            });
    }
    /**
     * @description It returns all the merchant services columns present in the metadata.
     */
    fetchServicesColumns() {
        return getAllMerchantServicesColumns({ businessAccountId: this.businessAccountId })
            .then(result => {
                if (result && result.contractDataTableMap) {
                    result.contractDataTableMap.forEach(column => {
                        if (column.API_Name__c === NAME_API) {
                            this.columns.push({
                                label: column.Label,
                                fieldName: SERVICE_URL,
                                type: TYPE_URL,
                                typeAttributes: {
                                    label: { fieldName: NAME_API },
                                    target: BLANK
                                },
                            });
                        } else if (column.API_Name__c === FINAL_COMMISSION || column.API_Name__c === FINAL_FEE || column.API_Name__c === TRIAL_COMMISSION || column.API_Name__c === TRIAL_FEE) {
                            this.columns.push({
                                label: column.Label,
                                fieldName: column.API_Name__c,
                                type: NUMBER,
                                cellAttributes: {
                                    alignment: LEFT_ALIGN
                                },
                                typeAttributes: {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                }
                            });
                        } else {
                            this.columns.push({
                                label: column.Label,
                                fieldName: column.API_Name__c
                            });
                        }
                    });
                } else {
                    this.errors = NO_SERVICES_ERROR;
                    console.error(NO_SERVICES_ERROR);
                }
            })
            .catch(error => {
                this.errors = NO_SERVICES_COLUMN_ERROR;
                console.error(NO_SERVICES_COLUMN_ERROR, error);
                throw error;
            });
    }
    /**
     * @description It fetches all the merchant services details.
     */
    fetchServicesDetails() {
        return getAllMerchantServicesDetails({ businessAccountId: this.businessAccountId, contractId: this.contractId })
            .then(result => {
                result.forEach(service => {
                    service.ServiceUrl = window.location.host + LIGHTNING_MERCHANT_SERVICE + service.Id + VIEW;
                });
                this.servicesMap = this.groupServicesByStore(result);
                this.storeEntries = Array.from(this.servicesMap, ([key, value]) => ({ key, value, accountName: value[0].Account__r.Name }));
            })
            .catch(error => {
                this.errors = NO_SERVICES_ERROR + this.getErrorMessage(error);
                console.error(NO_SERVICES_ERROR + this.getErrorMessage(error));
                throw error;
            })
            .finally(() => {
                //this.loaded = true;
            });
    }
    /**
     * @description It fetches the Report Id.
     */
    fetchReportId() {
        return getReportId()
            .then(data => {
                this.reportIdNew = data;
            })
            .catch(error => {
                console.error(ERROT_FETCHING_RECORD, error);
                this.errors = ERROT_FETCHING_RECORD + this.getErrorMessage(error);
                throw error;
            });
    }
    /**
     * @description It is used to group services by store account.
     */
    groupServicesByStore(services) {
        const map = new Map();
        this.mapAccountName = new Map();
        let bool = false;
        services.forEach(service => {
            const storeAccount = service.Account__c;
            const storeAccountName = service.Account__r.Name;
            if (!map.has(storeAccount)) {
                map.set(storeAccount, []);
            }
            if (!this.mapAccountName.has(storeAccount)) {
                this.mapAccountName.set(storeAccount, []);
            }
            map.get(storeAccount).push(service);
            if (!bool) {
                this.storeAccountName = storeAccountName;
                bool = true;
            }
            this.mapAccountName.get(storeAccount).push(storeAccountName);
        });
        if (map.size > 5) {
            const limitedEntriesMap = new Map();
            let count = 0;
            for (const [key, value] of map) {
                limitedEntriesMap.set(key, value);
                count++;
                if (count >= 5) {
                    break;
                }
            }
            return limitedEntriesMap;
        }
        return map;
    }
    /**
      * @description It creates the report url.
      */
    get reportURL() {
        return (HTTPS + window.location.host + LIGHTNING_REPORT + this.reportIdNew + VIEW_FILTER_1 + this.businessAccountId + FILTER_2 + this.contractId);
    }
    /**
      * @description It gets the report url.
      */
    get viewAllLink() {
        return (HREF + this.reportURL + TARGET + this.viewAll + END_TAG);
    }
    /**
     * @description It is a helper method to extract error message.
     */
    getErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === STRING) {
            return error.body.message;
        }
        return error.message || UNKNOWN_ERROR;

    }
}