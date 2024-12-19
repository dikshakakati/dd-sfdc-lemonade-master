import getCorporateHierarchy from "@salesforce/apex/CorporateAccountHierarchyController.getCorporateHierarchy";
import getAccountDetails from "@salesforce/apex/CorporateAccountHierarchyController.getAccountDetails";
import getChildAccounts from "@salesforce/apex/CorporateAccountHierarchyController.getChildAccounts";
import contractMinimumLength from '@salesforce/label/c.Contract_Minimum_Length_On_AHV';

const BUSINESS = "Business";

const AccountHierarchyDetail = {
    state: {
        businessIdsByBusinessAccountId: new Map(),
        storeAccountsById: new Map(),
        gridData: [],
        newGridData: [],
        contractGridData: [],
        completeSearchData: [],
        isSearchFound: false,
        searchGridData: [],
        businessParentAccounts: [],
        businessAccounts: [],
        isLoading: false,
        businessRecordType: false,
        currentId: "",
        brandsInDetail: "",
        verticalsInDetail: "",
        productsInDetail: "",
        searchKey: '',
        isFiltered: false,
        isContractingEntities: false,
        isStoresPresent: false,
        isToggleEnabled: false
    },

    getCorporateAccountHierarchy(ultimateParentAccountId, callback) {
        if (!ultimateParentAccountId) return null;
        getCorporateHierarchy({ ultimateParentAccountId })
            .then((result) => {
                this.buildCorporateHierarchyMap(result);
                this.handle(callback);
            });
    },

    buildCorporateHierarchyMap(data) {
        if (!data) return;
        data.forEach(({ businessAccount, storeAssociatedXrefs }) => {
            const parsedAccount = this.parseEachAccount(businessAccount, storeAssociatedXrefs);
            this.state.businessIdsByBusinessAccountId.set(businessAccount.Id, parsedAccount);
        });
    },

    parseEachAccount(businessAccount) {
        businessAccount.associatedStoreAccounts = [];
        businessAccount.Url = `/${businessAccount.Id}`;
        businessAccount.RecordTypeName = businessAccount?.RecordType?.Name;
        businessAccount.OwnerName = businessAccount?.Owner?.Name;
        businessAccount.OwnerNameUrl = `/${businessAccount.Owner?.Id}`;
        businessAccount.BrandName = businessAccount?.Brand__r?.Name;
        businessAccount.BrandNameUrl = `/${businessAccount.Brand__r?.Id}`;
        businessAccount._HasContracts = businessAccount.Contracts?.length > 0;
        businessAccount._HasPaymentAccounts = businessAccount.Payment_Accounts__r?.length > 0;
        if (businessAccount.External_ID_Source__c) {
            if (businessAccount.External_ID_Source__c === 'MDS') {
                businessAccount = { ...businessAccount, 'ProductName': 'Marketplace' };
                businessAccount = { ...businessAccount, 'IconName': 'custom:custom93' };
            }
            if (businessAccount.External_ID_Source__c === 'DriveDb') {
                businessAccount = { ...businessAccount, 'ProductName': 'Drive' };
                businessAccount = { ...businessAccount, 'IconName': 'custom:custom31' };
            }
        }

        if (businessAccount.storeAccount) {
            if (businessAccount.storeAccount.External_ID_Source__c === 'MDS') {
                businessAccount.storeAccount = { ...businessAccount.storeAccount, 'ProductName': 'Marketplace' };
                businessAccount.storeAccount = { ...businessAccount.storeAccount, 'IconName': 'custom:custom93' };
            }
            if (businessAccount.storeAccount.External_ID_Source__c === 'DriveDb') {
                businessAccount.storeAccount = { ...businessAccount.storeAccount, 'ProductName': 'Drive' };
                businessAccount.storeAccount = { ...businessAccount.storeAccount, 'IconName': 'custom:custom31' };
            }
            if (businessAccount.storeAccount.Salesforce_Account_Name__r.Brand__r) {
                businessAccount.storeAccount = { ...businessAccount.storeAccount, 'BrandName': businessAccount.storeAccount.Salesforce_Account_Name__r.Brand__r.Name };
            }
        }

        if (businessAccount._HasContracts) {
            businessAccount = { ...businessAccount, 'showSeeMore': businessAccount.Contracts.length > contractMinimumLength };
            if (businessAccount.showSeeMore) {
                businessAccount.Contracts.splice(businessAccount.Contracts.length - 1, 1);
            }
        }
        return businessAccount;
    },

    handle(callback) {
        typeof callback === "function" && callback();
    },

    async getUtimateParentAccountForFilteredHierarchy(ultimateAccountId, currentRecordId, brands, verticals, products) {
        this.state.currentId = currentRecordId;
        return new Promise(async (resolve) => {
            try {
                if (brands || verticals || products) {
                    this.state.isFiltered = true;
                }
                this.state.brandsInDetail = brands;
                this.state.verticalsInDetail = verticals;
                this.state.productsInDetail = products;
                const data = await getAccountDetails({ recordId: ultimateAccountId });
                this.state.gridData = data.map((account) => ({ ...account }));
                if (data[0].RecordType.DeveloperName === BUSINESS) {
                    this.state.businessAccounts.push(data[0].Id);
                }
                const parentIds = [ultimateAccountId];
                await this.getDirectChildRecords(parentIds);
                this.state.gridData = await this.removeBusiness(this.state.gridData, [], undefined, []);
                resolve(this.state.gridData);
            } catch (error) {
            }
        });
    },

    async getBusinessHierarchyDataWithContract(isToggleEnabled) {
        this.state.isToggleEnabled = isToggleEnabled;
        this.state.isContractingEntities = true;
        this.state.newGridData = [];
        return new Promise(async (resolve) => {
            try {
                this.state.newGridData = this.state.gridData;
                this.state.contractGridData = [];
                this.state.contractGridData = await this.getContractingEntities(this.state.newGridData, this.state.contractGridData, undefined, []);
                this.state.isContractingEntities = false;
                resolve(this.state.contractGridData);
            } catch (error) {
            }
        })
    },

    async setGridData(preGridData) {
        this.state.gridData = JSON.parse(JSON.stringify(preGridData));
    },

    async getBusinessHierarchyWithSearchData(searchKey) {
        this.state.searchKey = searchKey;
        return new Promise(async (resolve) => {
            try {
                this.state.searchGridData = [];
                this.state.completeSearchData = [];
                this.state.isSearchFound = false;
                this.state.searchGridData = await this.getSearchStoreData(this.state.gridData, this.state.searchGridData, undefined, []);
                this.state.completeSearchData = await this.getSearchData(this.state.searchGridData, this.state.completeSearchData, undefined, []);
                if (!this.state.isSearchFound) {
                    this.state.completeSearchData = [];
                }
                resolve(this.state.completeSearchData);
            } catch (error) {
            }
        })
    },

    async getUtimateParentAccountFromDetail(ultimateAccountId, currentRecordId) {
        this.state.currentId = currentRecordId;
        return new Promise(async (resolve) => {
            try {
                const data = await getAccountDetails({ recordId: ultimateAccountId });
                this.state.gridData = data.map((account) => ({ ...account }));
                if (data[0].RecordType.DeveloperName === BUSINESS) {
                    this.state.businessAccounts.push(data[0].Id);
                }
                const parentIds = [ultimateAccountId];
                await this.getDirectChildRecords(parentIds);
                resolve(this.state.gridData);
            } catch (error) {
            }
        });
    },

    setFilteredFlag() {
        this.state.isFiltered = false;
    },

    setSearchFlag() {
        this.state.isSearchFound = false;
        this.state.searchKey = '';
    },

    setFilterValues(brand, product, vertical) {
        this.state.brandsInDetail = brand;
        this.state.productsInDetail = product;
        this.state.verticalsInDetail = vertical;
    },

    async getDirectChildRecords(parentIds) {
        const childAccountIds = [];
        await Promise.all(parentIds.map(async (parentId) => {
            let result;
            if (this.state.isFiltered) {
                result = await getChildAccounts({ recordIds: parentId, brands: this.state.brandsInDetail, verticals: this.state.verticalsInDetail, products: this.state.productsInDetail });
            } else {
                result = await getChildAccounts({ recordIds: parentId, brands: undefined, verticals: undefined, products: undefined });
            }
            if (result) {
                const newChildren = [];
                const storeChildren = [];
                let hasChildStoreAccounts = false;
                result.forEach((data) => {
                    if (data.businessAccount) {
                        let obj = data.businessAccount;
                        obj = this.parseEachAccount(obj);
                        if (obj.ParentId === parentId) {
                            this.state.businessAccounts.push(obj.Id);
                            childAccountIds.push(obj.Id);
                            newChildren.push(obj);
                        }
                    }
                    if (data.storeAccount) {
                        let obj = data.storeAccount;
                        obj = this.parseEachAccount(obj);
                        obj.showMoreContracts = obj.contracts?.length > contractMinimumLength;
                        if (obj.showMoreContracts) {
                            obj.contracts.splice(obj.contracts.length - 1, 1)
                        }
                        hasChildStoreAccounts = true;
                        if (storeChildren.length < 100 || obj.storeAccount.Salesforce_Account_Name__r.ParentId === this.state.currentId) {
                            storeChildren.push(obj);
                        }
                        
                    }
                });
                if (!hasChildStoreAccounts) {
                    this.state.businessParentAccounts.push(parentId);
                }
                this.state.gridData = this.getNewDataWithChildren(parentId, this.state.gridData, newChildren, storeChildren);
            }
        }));
        if (childAccountIds.length > 0) {
            await this.getDirectChildRecords(childAccountIds);
        }
    },

    getContractingEntities(data, contractingData, parentAccount, parentIdsInContractingData) {
        if (contractingData.length === 0) {
            contractingData = data;
        }
        return contractingData.map((row) => {
            if (row._children.length > 0) {
                this.getContractingEntities([], row._children, row, parentIdsInContractingData);
            }
            if (row._HasContracts) {
                if (!this.state.isToggleEnabled) {
                    // When Toggle is disabled
                    row.AssociatedXrefs = [];
                }
                if (parentAccount === undefined) {
                    return row;
                }
                if (!row._HasChildrenWithContracts) {
                    row._children = [];
                    if ((this.state.isFiltered || this.state.isSearchFound) && row.AssociatedXrefs.length < 1) {
                        return parentAccount;
                    }
                }
                if (!parentIdsInContractingData.includes(parentAccount.Id)) {
                    parentIdsInContractingData.push(parentAccount.Id);
                    parentAccount._children = [];
                    parentAccount._HasChildrenWithContracts = true;
                    parentAccount._children.push(row);
                    return parentAccount;
                }
                parentAccount._children.push(row);
                return parentAccount;
            }
            if (!row._HasContracts && row._HasChildrenWithContracts && row._children.length > 0) {
                if (!this.state.isToggleEnabled) {
                    row.AssociatedXrefs = [];
                }
                if (parentAccount !== undefined) {
                    parentAccount._children.push(row);
                } else {
                    return row;
                }
            }
            return parentAccount;
        });
    },

    getSearchData(completeSearchData, searchData, parentAccount, parentIdsInSearchData) {
        let nameKey = 'Name';
        if (searchData.length === 0) {
            searchData = completeSearchData;
        }
        return searchData.map((row) => {
            if (row._children.length > 0) {
                this.getSearchData([], row._children, row, parentIdsInSearchData);
            }
            if (row[nameKey].toUpperCase().includes(this.state.searchKey.toUpperCase()) || row._HasMatchingSearchCriteriaChildren || row._HasMatchingSearchCriteriaStore) {
                this.state.isSearchFound = true;
                if (!row._HasMatchingSearchCriteriaChildren) {
                    row._children = [];
                }
                if (parentAccount === undefined) {
                    return row;
                }
                if (!parentIdsInSearchData.includes(parentAccount.Id)) {
                    parentIdsInSearchData.push(parentAccount.Id);
                    parentAccount._children = [];
                    parentAccount._HasMatchingSearchCriteriaChildren = true;
                    parentAccount._children.push(row);
                    return parentAccount;
                }
                parentAccount._children.push(row);
                this.state.isSearchFound = true;
                return parentAccount;
            }
            return row;
        });
    },

    getSearchStoreData(data, searchData, parentAccount, parentIdsInSearchData) {
        if (searchData.length === 0) {
            searchData = data;
        }
        return searchData.map((row) => {
            if (row._children.length > 0) {
                this.getSearchStoreData([], row._children, row, parentIdsInSearchData);
            }
            for (let iterator = 0; iterator <= row.AssociatedXrefs.length; iterator++) {
                if (iterator !== row.AssociatedXrefs.length &&
                    !(
                        ((Object.prototype.hasOwnProperty.call(row.AssociatedXrefs[iterator].storeAccount, 'Salesforce_Account_Name__c') && row.AssociatedXrefs[iterator].storeAccount.Salesforce_Account_Name__r.Name.toUpperCase().includes(this.state.searchKey.toUpperCase()))) ||
                        ((Object.prototype.hasOwnProperty.call(row.AssociatedXrefs[iterator].storeAccount, 'External_ID__c') && row.AssociatedXrefs[iterator].storeAccount.External_ID__c.toUpperCase().includes(this.state.searchKey.toUpperCase()))) ||
                        ((Object.prototype.hasOwnProperty.call(row.AssociatedXrefs[iterator].storeAccount, 'BusinessID__c') && row.AssociatedXrefs[iterator].storeAccount.BusinessID__c.toUpperCase().includes(this.state.searchKey.toUpperCase())))
                    )
                ) {
                    row.AssociatedXrefs.splice(iterator, 1);
                    iterator = iterator - 1;
                }
            }
            if (row.AssociatedXrefs.length > 0) {
                row._HasMatchingSearchCriteriaStore = true;
                this.state.isSearchFound = true;
            }
            if (parentAccount === undefined) {
                return row;
            }
            if (!parentIdsInSearchData.includes(parentAccount.Id)) {
                parentIdsInSearchData.push(parentAccount.Id);
                parentAccount._children = [];
                parentAccount._children.push(row);
                return parentAccount;
            }
            parentAccount._children.push(row);
            return parentAccount;
        });
    },

    getNewDataWithChildren(rowName, data, children, stores) {
        return data.map((row) => {
            const hasChildrenContent = row._children && Array.isArray(row._children) && row._children.length > 0;
            if (row.Id === rowName) {
                row._children = children;
                row.AssociatedXrefs = stores;
                this.state.isStoresPresent = this.state.isStoresPresent || stores.length > 0;
                row.showCaratIcon = children.length > 0 || stores.length > 0;
                row.hasChildren = true;
            } else if (hasChildrenContent) {
                this.getNewDataWithChildren(rowName, row._children, children, stores);
            }
            return row;
        });
    },

    removeBusiness(data, filteredData, parentAccount, parentIdsWithXrefs) {
        if (filteredData.length === 0) {
            filteredData = data;
        }
        return filteredData.map((row) => {
            if (row._children.length > 0) {
                this.removeBusiness([], row._children, row, parentIdsWithXrefs);
            }
            if (row.AssociatedXrefs.length > 0 || row._HasChildrenWithXref) {
                if (!row._HasChildrenWithXref) {
                    row._children = [];
                }
                if (parentAccount === undefined) {
                    return row;
                }
                if (!parentIdsWithXrefs.includes(parentAccount.Id)) {
                    parentIdsWithXrefs.push(parentAccount.Id);
                    parentAccount._children = [];
                    parentAccount._HasChildrenWithXref = true;
                    parentAccount._children.push(row);
                    return parentAccount;
                }
                parentAccount._children.push(row);
                return parentAccount;
            }
            if (row.AssociatedXrefs.length < 1 && row._HasChildrenWithXref && row._children.length > 0) {
                if (parentAccount !== undefined) {
                    parentAccount._children.push(row);
                } else {
                    return row;
                }
            }
            return parentAccount;
        });
    }
};

export default AccountHierarchyDetail;