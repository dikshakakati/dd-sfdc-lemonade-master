import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createLog from "@salesforce/apex/LogController.createLog";
import getAllContracts from "@salesforce/apex/ContractsSummaryController.getAllContracts";

const LWC_NAME = "contractsSummary";
const FETCH_CONTRACTS = "fetchAllContracts";
const FORWARD_SLASH = "/";
const ENTERPRISE = "Enterprise";
const ACCOUNT_SEGMENT_SMB = 'SMB';

export default class ContractsSummary extends LightningElement {

    @api recordId;
    @track contractWrapper = [];
    @track columnsForContract = [];
    @track dataForContract = [];
    showComponent = false;
    error;
    currentTab = 'Core Products';
    productLabel = {
        coreProductLabel: 'Core Products',
        promoProductLabel: 'Ads & Promos'
    }
    dataUnavailableText = 'Data not available';
    existingContractsLabel = 'Existing Contracts';
    segment;
    initiatedfrom;
    disableChangeRates = false;
    businessAccountId;

    /**
    * @description connectedcallback, used to fetch the contracts and do initial setup.
    */
    connectedCallback() {
        this.fetchAllContracts();
    }

    /**
    * @description It is used to track current tab.
    */
    tabChangeHandler(event) {
        if (this.currentTab != event.target.title) {
            this.currentTab = event.target.title;
            if (this.currentTab == 'Ads & Promos') {
                this.disableChangeRates = true;
            }
            else {
                this.disableChangeRates = false;
            }
            this.dataForContract = [];
            let productsOpted = this.currentTab == this.productLabel.coreProductLabel ? this.contractWrapper.coreProducts : this.contractWrapper.promoProducts;
            this.processContractRecords(this.contractWrapper.contractDataTableMap, productsOpted);
        }
    }

    /**
    * @description It is used to fetch name of opportunity/Account.
    */
    get getLabel() {
        let label = this.contractWrapper.recordDetails[0].Name ? this.contractWrapper.recordDetails[0].Name : '';
        return label;
    }

    /**
    * @description It is used to determine if the records are available to place in the table.
    */
    get contractsAreAvailable() {
        return this.dataForContract.length > 0 ? true : false;
    }

    /**
    * @description It is used to get the account id.
    */
    get accountId() {
        if (this.contractWrapper.initiatedFromSobject) {
            return this.contractWrapper.initiatedFromSobject == 'Account' ? this.contractWrapper.recordDetails[0].Id : this.contractWrapper.recordDetails[0].AccountId
        }
    }

    /**
    * @description It fetches all the contracts.
    */
    fetchAllContracts() {
        getAllContracts({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    this.contractWrapper = result;
                    this.segment = result.segment;
                    this.columnsForContract = result.contractDataTableMap;
                    this.processContractRecords(result.contractDataTableMap, result.coreProducts);
                    this.currentTab = this.productLabel.coreProductLabel;
                    this.showComponent = true;
                    this.initiatedFrom = result.initiatedFromSobject;
                }
            })
            .catch((error) => {
                this.error = error;
                createLog({
                    lwcName: LWC_NAME,
                    methodName: FETCH_CONTRACTS,
                    message: JSON.stringify(error)
                });
            });
    }

    /**
   * @description this will determine if the segment is enterprise or not.
   */
    get isCustomerSegmentEnterprise() {
        return this.segment == ENTERPRISE ? true : false;
    }
    get isCustomerSegmentSmb() {
        return this.segment == ACCOUNT_SEGMENT_SMB ? true : false;
    }

    /**
   * @description It process the row for the datatable.
   */
    processContractRecords(retrievedFieldSetMap, retrievedRecords) {
        try {
            this.businessAccountId = this.accountId;
            retrievedRecords.forEach(eachProduct => {
                const mapList = {
                    "isAccordionExtended": (this.currentTab == this.productLabel.coreProductLabel && this.isCustomerSegmentEnterprise) ? true : false,
                    "isSegmentEnterprise": this.isCustomerSegmentEnterprise,
                    "rowData": [],
                    "contractId": eachProduct.contract.Id
                };
                retrievedFieldSetMap.forEach(field => {
                    const mappedData = {};
                    mappedData['isHyperLinked'] = (field.Type__c == 'Hyperlink' || field.Type__c == 'Report') ? true : false;
                    if (field.Type__c != 'Report') {
                        // Check if the field is a nested field, then process the nested fields.

                        if (field.hasOwnProperty('Hyper_Link_Display_Field__c') && field.Hyper_Link_Display_Field__c.includes('.')) {
                            let isNestedFieldAvailable = true;
                            const nestedFields = field.Hyper_Link_Display_Field__c.split('.');
                            let nestedValue = eachProduct.contract;
                            nestedFields.forEach(nestedField => {
                                if (nestedValue[nestedField]) {
                                    nestedValue = nestedValue[nestedField];
                                }
                                else {
                                    isNestedFieldAvailable = false;
                                }
                            });

                            mappedData['hyperLinkDisplayField'] = isNestedFieldAvailable ? nestedValue : " ";
                            mappedData['link'] = FORWARD_SLASH + eachProduct.contract[field.API_Name__c];
                        } else {
                            mappedData['hyperLinkDisplayField'] = eachProduct.contract[field.Hyper_Link_Display_Field__c];
                        }
                        if (field.hasOwnProperty('Hyper_Link_Display_Field__c') && field.Hyper_Link_Display_Field__c === 'ContractNumber' && field.Segment__c === 'SMB') {
                            mappedData['hyperLinkDisplayField'] = eachProduct.contract[field.Hyper_Link_Display_Field__c];
                            mappedData['link'] = FORWARD_SLASH + eachProduct.contract[field.API_Name__c];
                        }
                        mappedData['value'] = eachProduct.contract[field.API_Name__c];
                        mappedData['isAccordionExtended'] = false;
                        mapList['rowData'].push(mappedData);
                    }
                    else {
                        let reportIds = field.API_Name__c.split(';');

                        mappedData['hyperLinkDisplayField'] = eachProduct[field.Hyper_Link_Display_Field__c];
                        if (this.currentTab === this.productLabel.promoProductLabel || field.Segment__c !== ACCOUNT_SEGMENT_SMB) {
                            mappedData['link'] = 'https://' + window.location.host + '/lightning/r/Report/' + reportIds[0] + '/view' + '?fv0=' + eachProduct.contract.Id + '&fv1=' + this.accountId;
                        }
                        if (this.currentTab != this.productLabel.promoProductLabel && field.Segment__c === ACCOUNT_SEGMENT_SMB) {
                            mappedData['link'] = 'https://' + window.location.host + '/lightning/r/Report/' + reportIds[1] + '/view' + '?fv0=' + this.accountId + '&fv1=' + eachProduct.contract.Id;
                        }
                        mapList['rowData'].push(mappedData);
                    }

                });
                this.dataForContract.push(mapList);
            });
        }
        catch (error) {
            console.log('error ' + error);
        }
    }

}