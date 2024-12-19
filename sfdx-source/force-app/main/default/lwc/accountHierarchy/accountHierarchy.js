import { api, LightningElement, track, wire } from 'lwc';
import modal_styles from "@salesforce/resourceUrl/ModalFormatting";
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import getUltimateParentAccount from "@salesforce/apex/CorporateAccountHierarchyController.getUltimateParentAccount";
import getBrandsAndVerticals from "@salesforce/apex/CorporateAccountHierarchyController.getBrandsAndVerticals";
import AccountHierarchyStore from "./accountHierarchyInDetail";
import noDataFoundMessage from '@salesforce/label/c.Stores_On_WorkPlan_No_Data_Found_Message';
import noSearchResultFoundMessage from '@salesforce/label/c.AHV_No_Search_Result_Found_Message';
import separator from '@salesforce/label/c.Separator';
import contractMinimumLength from '@salesforce/label/c.Contract_Minimum_Length_On_AHV';
import hasWorkOrderCreationAccess from '@salesforce/customPermission/Enable_Create_Work_Order_On_Business_Account';

const ENABLE_ACCORDION_CLASS_NAME = 'slds-is-open';
const PRODUCT_NAME_DRIVE = 'Drive';
const PRODUCT_NAME_MARKETPLACE = 'Marketplace';
const PARENT_DIV_STYLING_ON_OPEN_FILTER_PANEL = 'divStyling';
const PARENT_DIV_STYLING_ON_CLOSE_FILTER_PANEL = '';
export default class AccountHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
    @api accountRecordId;
    icon = '';
    @track isActiveSection;
    @track accountsAriaControls = {};
    @track allBrands = [];
    @track allProducts = [
        { label: PRODUCT_NAME_MARKETPLACE },
        { label: PRODUCT_NAME_DRIVE }
    ];
    @track activeChildComponent;
    @track allVerticals = [];
    @track brandSelectedRecords = [];
    @track businessIdsByBusinessAccountId = AccountHierarchyStore.state.businessIdsByBusinessAccountId;
    @track accountHierarchy = [];
    @track showChildHierarchy = false;
    @track brandSearchKey;
    @track productSearchKey;
    @track productSelectedRecords = [];
    @track searchKey = '';
    @track verticalSearchKey;
    @track verticalSelectedRecords = [];
    adsAndPromosIcon = 'standard:price_book_entries';
    applyFiltersButtonDisabled = true;
    businessAccountsByIdMap = new Map();
    isFiltered = false;
    filteredAccountsByParentId = new Map();
    iconBusinessAccount = 'standard:account';
    iconStoreAccount = 'standard:store';
    isPanelHidden = true;
    messageToBeDisplayed = noDataFoundMessage;
    showMessage = false;
    showFirstChildAccount = true;
    showStoreAccount = false;
    ultimateParentAccount;
    isLoading;
    formulateSearchKey = '';
    switchContracting = false;
    childSection;
    parentSection;
    businessSection;
    isSearched = false;
    searchBoxPlaceholder = 'Search Name, Business Id, Store Id';
    ultimateParentStoresSection;
    ultimateParentAccountId;
    completeAccountHierarchy = [];
    completeFilteredAccountHierarchy = [];
    firstBusinessSection;
    secondBusinessSection;
    thirdBusinessSection;
    fourthBusinessSection;
    fifthBusinessSection;
    firstbusinessSectionButton;
    secondBusinessSectionButton;
    thirdBusinessSectionButton;
    fourthBusinessSectionButton;
    secondBusiness;
    thirdBusiness;
    fourthBusiness;
    toggleButton;
    isContractingEntitiesEnabled;
    isToggleEnabled = false;
    isToggleEnabledManually = false;
    disableToggle = false;
    showToggleView = false;
    hasWorkOrderCreationAccess = hasWorkOrderCreationAccess;
    showContractingButton;

    connectedCallback() {
        loadStyle(this, modal_styles);
    }
    renderedCallback() {
        //It stores datatable instance
        if (this.template.querySelectorAll('[data-name="parent_section"]')) {
            this.parentSection = this.template.querySelectorAll('[data-name="parent_section"]');
            this.firstBusinessSection = this.template.querySelectorAll('[data-name="business_section"]');
            this.ultimateParentStoresSection = this.template.querySelectorAll('[data-name="ultimate_parent_stores_section"]');
            this.secondBusinessSection = this.template.querySelectorAll('[data-name="second_business_section"]');
            this.businessSection = this.template.querySelectorAll('[data-name="first_business_section"]');
            this.thirdBusinessSection = this.template.querySelectorAll('[data-name="third_business_section"]');
            this.fourthBusinessSection = this.template.querySelectorAll('[data-name="fourth_business_section"]');
            this.fifthBusinessSection = this.template.querySelectorAll('[data-name="fifth_business_section"]');
            this.firstbusinessSectionButton = this.template.querySelectorAll('[data-name="business_section_button"]');
            this.secondBusinessSectionButton = this.template.querySelectorAll('[data-name="second_business_name_button"]');
            this.thirdBusinessSectionButton = this.template.querySelectorAll('[data-name="third_business_section_button"]');
            this.fourthBusinessSectionButton = this.template.querySelectorAll('[data-name="fourth_business_section_button"]');
            this.secondBusiness = this.template.querySelectorAll('[data-name="second_business"]');
            this.thirdBusiness = this.template.querySelectorAll('[data-name="third_business"]');
            this.fourthBusiness = this.template.querySelectorAll('[data-name="fourth_business"]');
        }
        if (this.template.querySelectorAll('[data-name="toggleButton"]')) {
            this.toggleButton = this.template.querySelectorAll('[data-name="toggleButton"]');
        }
        if (this.template.querySelectorAll('[data-name="showContractingButton"]')) {
            this.showContractingButton = this.template.querySelectorAll('[data-name="showContractingButton"]');
        }
        if (this.ultimateParentAccountId) {
            this.parentSection.forEach((eachElement) => {
                eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
            });
            this.secondBusinessSection.forEach((eachElement) => {
                eachElement.classList.add('section-styling');
            });
            this.thirdBusinessSection.forEach((eachElement) => {
                eachElement.classList.add('section-styling');
            });
            this.fourthBusinessSection.forEach((eachElement) => {
                eachElement.classList.add('section-styling');
            });
            this.ultimateParentStoresSection.forEach((eachElement) => {
                eachElement.classList.add('section-styling');
            });
            this.fifthBusinessSection.forEach((eachElement) => {
                eachElement.classList.add('section-styling');
            });
        }
        this.initializeResizing();
        // enable/disable toggle store on search.
        if (this.isToggleEnabled || this.showToggleView) {
            // Enable toggle button only when Toggle Stores is enabled
            if (this.isToggleEnabled) {
                this.toggleButton.forEach((eachElement) => {
                    eachElement.checked = true;
                });
            }
            this.openToggle();
        } else if (!this.isToggleEnabled) {
            this.toggleButton.forEach((eachElement) => {
                eachElement.checked = false;
            });
        }
        //enable show contracting entities
        if (this.isContractingEntitiesEnabled) {
            this.showContractingButton.forEach((eachElement) => {
                eachElement.checked = true;
            });
        }
        AccountHierarchyStore.setFilterValues(this.brandSearchKey, this.productSearchKey, this.verticalSearchKey);
    }

    /**
      * @description It returns the SLDS class name(s) based on the component location.
     */
    get parentDivStyling() {
        if (!this.isPanelHidden) {
            return PARENT_DIV_STYLING_ON_OPEN_FILTER_PANEL;
        }
        return PARENT_DIV_STYLING_ON_CLOSE_FILTER_PANEL;
    }

    //This is for the resizing of the columns.
    initializeResizing() {
        const resizableColumns = this.template.querySelectorAll('.slds-is-resizable');

        resizableColumns.forEach((column, index) => {
            const handle = column.querySelector('.slds-resizable__handle');
            handle.addEventListener('mousedown', (event) => {
                event.preventDefault();
                let isResizing = true;

                document.addEventListener('mousemove', handleMouseMove);
                document.addEventListener('mouseup', () => {
                    isResizing = false;
                    document.removeEventListener('mousemove', handleMouseMove);
                });

                function handleMouseMove(event) {
                    if (isResizing) {
                        const newWidth = event.clientX - column.getBoundingClientRect().left;
                        column.style.width = `${newWidth}px`;
                    }
                }
            });
        });
    }

    @wire(getUltimateParentAccount, { accountId: "$recordId" })
    getBusinessHierarchy({ data, error }) {
        this.isLoading = true;
        if (!this.recordId) {
            return null;
        }
        if (data) {
            let currentAccount = data;
            if (currentAccount.Ultimate_Parent_Account__c != null && currentAccount.Ultimate_Parent_Account__c != '') {
                this.ultimateParentAccountId = currentAccount.Ultimate_Parent_Account__c;
            } else {
                this.ultimateParentAccountId = currentAccount.Id;
            }
            this.fetchBrandsAndVerticals();
            this.getBusinessHierarchyData();
        }
    }

    async getBusinessHierarchyData() {
        try {
            const results = await Promise.all([
                AccountHierarchyStore.getUtimateParentAccountFromDetail(this.ultimateParentAccountId, this.recordId)
            ]);
            if (results) {
                this.completeAccountHierarchy = JSON.parse(JSON.stringify(results[0]));
                this.isFiltered = false;
                this.accountHierarchy = results[0];
                this.accountHierarchy[0].showSeeMore = this.accountHierarchy[0].Contracts?.length > contractMinimumLength;
                if (this.accountHierarchy[0].showSeeMore) {
                    this.accountHierarchy[0].Contracts.slice(0, this.accountHierarchy[0].Contracts.length - 2);
                }
                this.isLoading = false;
                this.showChildHierarchy = false;
            }
        } catch (error) {
            console.log('======232=====',error);
        }
    }

    fetchBrandsAndVerticals() {
        getBrandsAndVerticals({
            ultimateParentAccountId: this.ultimateParentAccountId
        }).then((result) => {
            let brandData = [];
            let verticalData = [];
            if (result && result[0]) {
                result[0].brands.forEach(function (eachBrand) {
                    brandData.push({
                        label: eachBrand
                    });
                });
                this.allBrands = brandData;
                result[0].verticals.forEach(function (eachVertical) {
                    verticalData.push({
                        label: eachVertical
                    });
                });
                this.allVerticals = verticalData;
            }
        }).catch((error) => {
            console.log('=======257=====',error);
        });
    }

    async getFilteredBusinessHierarchyData() {
        AccountHierarchyStore.state.isStoresPresent = false;
        try {
            const results = await Promise.all([
                AccountHierarchyStore.getUtimateParentAccountForFilteredHierarchy(this.ultimateParentAccountId, this.recordId, this.brandSearchKey, this.verticalSearchKey, this.productSearchKey)
            ]);
            if (results) {
                this.completeFilteredAccountHierarchy = JSON.parse(JSON.stringify(results[0]));
                AccountHierarchyStore.setGridData(this.completeFilteredAccountHierarchy);
                this.isFiltered = true;
                this.showMessage = !AccountHierarchyStore.state.isStoresPresent;
                this.messageToBeDisplayed = noDataFoundMessage;
                if ((this.isContractingEntitiesEnabled && this.isToggleEnabled) || this.isSearched) {
                    this.switchContracting = this.isContractingEntitiesEnabled ? true : false;
                    this.handleLaterFiltering();
                } else {
                    this.accountHierarchy = results[0];
                }
                if( this.accountHierarchy[0]){
                this.accountHierarchy[0].showSeeMore = this.accountHierarchy[0].Contracts?.length > contractMinimumLength;
                if (this.accountHierarchy[0].showSeeMore) {
                   this.accountHierarchy[0].Contracts.splice(this.accountHierarchy[0].Contracts.length - 1, 1)
                }
            }
                this.isLoading = false;
                this.showChildHierarchy = false;
                this.isPanelHidden = true;
            }
        } catch (error) {
            console.log('=======288======',error);
        }
    }

    /**
     * @description To get search key for brand search.
     * @JIRA# LEM-10966
     * @param event
    */
    getBrandSearchKey(event) {
        this.brandSearchKey = event.detail;
        if (this.brandSearchKey || this.productSearchKey || this.verticalSearchKey) {
            this.applyFiltersButtonDisabled = false;
        } else {
            this.applyFiltersButtonDisabled = true;
        }
        let brandSearchKeys = this.brandSearchKey ? this.brandSearchKey.split(separator) : [];
        let brandkeys = [];
        brandSearchKeys.forEach(function (eachKey) {
            brandkeys.push({
                label: eachKey
            });
        });
        this.brandSelectedRecords = brandkeys;
    }

    /**
     * @description To get search key for product search.
     * @JIRA# LEM-10966
     * @param event
    */
    getProductSearchKey(event) {
        this.productSearchKey = event.detail;
        if (this.brandSearchKey || this.productSearchKey || this.verticalSearchKey) {
            this.applyFiltersButtonDisabled = false;
        } else {
            this.applyFiltersButtonDisabled = true;
        }
        let productSearchKeys = this.productSearchKey ? this.productSearchKey.split(separator) : [];
        let productsKeys = [];
        // Setting Product selected keys
        productSearchKeys.forEach(function (eachKey) {
            productsKeys.push({
                label: eachKey
            });
        });
        this.productSelectedRecords = productsKeys;
    }

    /**
     * @description To get search key for vertical search.
     * @JIRA# LEM-10966
     * @param event
    */
    getVerticalSearchKey(event) {
        this.verticalSearchKey = event.detail;
        if (this.brandSearchKey || this.productSearchKey || this.verticalSearchKey) {
            this.applyFiltersButtonDisabled = false;
        } else {
            this.applyFiltersButtonDisabled = true;
        }
        let verticalKeys = [];
        let verticalSearchKeys = this.verticalSearchKey ? this.verticalSearchKey.split(separator) : [];
        // Setting Vertical selected keys
        verticalSearchKeys.forEach(function (eachKey) {
            verticalKeys.push({
                label: eachKey
            });
        });
        this.verticalSelectedRecords = verticalKeys;
    }

    /**
     * @description To apply filters.
     * @JIRA# LEM-10966
     * @param event
    */
    handleApplyFilters() {
        this.isLoading = true;
        this.getFilteredBusinessHierarchyData();
        this.isToggleEnabled = true;
    }

    /**
     * @description To clear filters.
     * @JIRA# LEM-10966
     * @param event
    */
    async handleClearFilters() {
        this.isLoading = true;
        try {
            AccountHierarchyStore.setFilteredFlag();
            AccountHierarchyStore.setGridData(this.completeAccountHierarchy);
            if (this.isSearched || this.isContractingEntitiesEnabled) {
                this.checkSearch(AccountHierarchyStore.state.gridData);
                if (this.isContractingEntitiesEnabled && !this.isSearched) {
                    this.showContractingEntities();
                }
                this.accountHierarchy[0].showSeeMore = this.accountHierarchy[0].Contracts?.length > contractMinimumLength;
                if (this.accountHierarchy[0].showSeeMore) {
                    this.accountHierarchy[0].Contracts.splice(this.accountHierarchy[0].Contracts.length - 1, 1)
                }
                this.isLoading = false;
            } else {
                this.accountHierarchy = JSON.parse(JSON.stringify(this.completeAccountHierarchy));
            }
            this.isLoading = false;
            this.isFiltered = false;
            this.showChildHierarchy = false;
            this.isPanelHidden = true;
            this.showMessage = false;
            this.brandSearchKey = this.productSearchKey = this.verticalSearchKey = '';
            this.applyFiltersButtonDisabled = true;
            this.brandSelectedRecords = this.productSelectedRecords = this.verticalSelectedRecords = [];
        } catch (error) {
            this.isLoading = false;
        }
    }

    handleChildClick(event) {
        let storeId = event.target.dataset.id;
        let section = event.target.dataset.name;
        switch (section) {
            case 'business_section_button':
                this.secondBusinessSection.forEach((eachElement) => {
                    if (eachElement.dataset.parent === storeId) {
                        if (eachElement.classList.contains('section-styling')) {
                            eachElement.classList.remove('section-styling');
                        } else {
                            eachElement.classList.add('section-styling');
                            // Adjust accordion icon
                            this.secondBusiness.forEach((eachParentElement) => {
                                if (eachParentElement.dataset.parent === storeId && eachParentElement.classList.contains('slds-accordion__section')) {
                                    eachParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                                this.thirdBusiness.forEach((eachChildParentElement) => {
                                    if (eachChildParentElement.dataset.parent === eachParentElement.dataset.id && eachChildParentElement.classList.contains('slds-accordion__section')) {
                                        eachChildParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                    }
                                    this.fourthBusiness.forEach((eachGrandChildParentElement) => {
                                        if (eachGrandChildParentElement.dataset.parent === storeId && eachChildParentElement.classList.contains('slds-accordion__section')) {
                                            eachGrandChildParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                        }
                                    });
                                });
                            });
                            // Hide all children
                            this.thirdBusinessSection.forEach((eachChildElement) => {
                                if (eachChildElement.dataset.parent === eachElement.dataset.id) {
                                    eachChildElement.classList.add('section-styling');
                                    eachChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                                this.fourthBusinessSection.forEach((eachGrandChildElement) => {
                                    if (eachGrandChildElement.dataset.parent === eachChildElement.dataset.id) {
                                        eachGrandChildElement.classList.add('section-styling');
                                        eachGrandChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                    }
                                    this.fifthBusinessSection.forEach((eachSuperGrandChildElement) => {
                                        if (eachSuperGrandChildElement.dataset.parent === eachGrandChildElement.dataset.id) {
                                            eachSuperGrandChildElement.classList.add('section-styling');
                                            eachSuperGrandChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                        }
                                    });
                                });
                            });
                        }
                    }
                });
                this.firstBusinessSection.forEach((eachElement) => {
                    if (eachElement.dataset.id === storeId && eachElement.classList.contains('slds-accordion__section')) {
                        if (eachElement.classList.contains(ENABLE_ACCORDION_CLASS_NAME)) {
                            eachElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                        } else {
                            eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
                        }
                    }
                });
                break;
            case 'second_business_name_button':
                this.thirdBusinessSection.forEach((eachElement) => {
                    if (eachElement.dataset.parent === storeId) {
                        if (eachElement.classList.contains('section-styling')) {
                            eachElement.classList.remove('section-styling');
                        } else {
                            eachElement.classList.add('section-styling');
                            // Adjust accordion icon
                            this.thirdBusiness.forEach((eachParentElement) => {
                                if (eachParentElement.dataset.parent === storeId && eachParentElement.classList.contains('slds-accordion__section')) {
                                    eachParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                                this.fourthBusiness.forEach((eachChildParentElement) => {
                                    if (eachChildParentElement.dataset.parent === storeId && eachParentElement.classList.contains('slds-accordion__section')) {
                                        eachChildParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                    }
                                });
                            });
                            // Hide all children
                            this.fourthBusinessSection.forEach((eachChildElement) => {
                                if (eachChildElement.dataset.parent === eachElement.dataset.id) {
                                    eachChildElement.classList.add('section-styling');
                                    eachChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                                this.fifthBusinessSection.forEach((eachGrandChildElement) => {
                                    if (eachGrandChildElement.dataset.parent === eachChildElement.dataset.id) {
                                        eachGrandChildElement.classList.add('section-styling');
                                        eachGrandChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                    }
                                });
                            });
                        }
                    }
                });
                this.secondBusiness.forEach((eachElement) => {
                    if (eachElement.dataset.id === storeId && eachElement.classList.contains('slds-accordion__section')) {
                        if (eachElement.classList.contains(ENABLE_ACCORDION_CLASS_NAME)) {
                            eachElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                        } else {
                            eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
                        }
                    }
                });
                break;
            case 'third_business_section_button':
                this.fourthBusinessSection.forEach((eachElement) => {
                    if (eachElement.dataset.parent === storeId) {
                        if (eachElement.classList.contains('section-styling')) {
                            eachElement.classList.remove('section-styling');
                        } else {
                            eachElement.classList.add('section-styling');
                            // Adjust accordion icon
                            this.fourthBusiness.forEach((eachParentElement) => {
                                if (eachParentElement.dataset.parent === storeId && eachParentElement.classList.contains('slds-accordion__section')) {
                                    eachParentElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                            });
                            // Hide all children
                            this.fifthBusinessSection.forEach((eachChildElement) => {
                                if (eachChildElement.dataset.parent === eachElement.dataset.id) {
                                    eachChildElement.classList.add('section-styling');
                                    eachChildElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                                }
                            });
                        }
                    }
                });
                this.thirdBusiness.forEach((eachElement) => {
                    if (eachElement.dataset.id === storeId && eachElement.classList.contains('slds-accordion__section')) {
                        if (eachElement.classList.contains(ENABLE_ACCORDION_CLASS_NAME)) {
                            eachElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                        } else {
                            eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
                        }
                    }
                });
                break;
            case 'fourth_business_section_button':
                this.fifthBusinessSection.forEach((eachElement) => {
                    if (eachElement.dataset.parent === storeId) {
                        if (eachElement.classList.contains('section-styling')) {
                            eachElement.classList.remove('section-styling');
                        } else {
                            eachElement.classList.add('section-styling');
                        }
                    }
                });
                this.fourthBusiness.forEach((eachElement) => {
                    if (eachElement.dataset.id === storeId && eachElement.classList.contains('slds-accordion__section')) {
                        if (eachElement.classList.contains(ENABLE_ACCORDION_CLASS_NAME)) {
                            eachElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
                        } else {
                            eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
                        }
                    }
                });
                break;
            case 'ultimateParentStoresSection':
                this.ultimateParentStoresSection.forEach((eachElement) => {
                    if (eachElement.dataset.parent === storeId) {
                        if (eachElement.classList.contains('section-styling')) {
                            eachElement.classList.remove('section-styling');
                        } else {
                            eachElement.classList.add('section-styling');
                        }
                    }
                });
                break;
            default:
        }
    }

    handleParentClick(event) {
        this.parentSection.forEach((eachElement) => {
            if (eachElement.classList.contains(ENABLE_ACCORDION_CLASS_NAME)) {
                eachElement.classList.remove(ENABLE_ACCORDION_CLASS_NAME);
            } else {
                eachElement.classList.add(ENABLE_ACCORDION_CLASS_NAME);
            }
        });
        this.businessSection.forEach((eachElement) => {
            if (eachElement.classList.contains('section-styling')) {
                eachElement.classList.remove('section-styling');
            } else {
                eachElement.classList.add('section-styling');
            }
        });
    }

    /**
     * @description To close toogle stores checkbox.
     */
    closeToggle() {
        for (let iterator = 0; iterator < this.secondBusinessSection.length; iterator++) {
            this.secondBusinessSection[iterator].classList.add('section-styling');
        }
        for (let iterator = 0; iterator < this.thirdBusinessSection.length; iterator++) {
            this.thirdBusinessSection[iterator].classList.add('section-styling');
        }
        for (let iterator = 0; iterator < this.fourthBusinessSection.length; iterator++) {
            this.fourthBusinessSection[iterator].classList.add('section-styling');
        }
        for (let iterator = 0; iterator < this.fifthBusinessSection.length; iterator++) {
            this.fifthBusinessSection[iterator].classList.add('section-styling');
        }
        for (let iterator = 0; iterator < this.firstbusinessSectionButton.length; iterator++) {
            this.firstbusinessSectionButton[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.secondBusinessSectionButton.length; iterator++) {
            this.secondBusinessSectionButton[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.thirdBusinessSectionButton.length; iterator++) {
            this.thirdBusinessSectionButton[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.fourthBusinessSectionButton.length; iterator++) {
            this.fourthBusinessSectionButton[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.ultimateParentStoresSection.length; iterator++) {
            this.ultimateParentStoresSection[iterator].classList.add('section-styling');
            this.ultimateParentStoresSection[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.firstBusinessSection.length; iterator++) {
            if (this.firstBusinessSection[iterator].classList.contains('slds-accordion__section')) {
                this.firstBusinessSection[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
        for (let iterator = 0; iterator < this.secondBusiness.length; iterator++) {
            if (this.secondBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.secondBusiness[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
        for (let iterator = 0; iterator < this.thirdBusiness.length; iterator++) {
            if (this.thirdBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.thirdBusiness[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
        for (let iterator = 0; iterator < this.fourthBusiness.length; iterator++) {
            if (this.fourthBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.fourthBusiness[iterator].classList.remove(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
    }

    handleToggle(event) {
        const isChecked = event.target.checked;
        if (this.ultimateParentAccountId) {
            if (isChecked) {
                this.isToggleEnabled = true;
                this.isToggleEnabledManually = true;
                if (this.isContractingEntitiesEnabled) {
                    this.checkFiltered();
                    this.showContractingEntities();
                }
                this.openToggle();
            } else {
                this.isToggleEnabled = false;
                this.isToggleEnabledManually = false;
                if (this.isSearched || this.isContractingEntitiesEnabled) {
                    this.disableToggle = true;
                    this.checkSearch(AccountHierarchyStore.state.gridData);
                    if (this.isContractingEntitiesEnabled && !this.isSearched) {
                        this.checkFiltered();
                        this.showContractingEntities();
                    }
                }
                this.closeToggle();
            }
        }
    }

    handleShowContractingEntities(event) {
        const isChecked = event.target.checked;
        if (isChecked) {
            this.isContractingEntitiesEnabled = true;
            this.showContractingEntities();
            this.showToggleView = true;
        } else {
            this.isLoading = true;
            this.isContractingEntitiesEnabled = false;
            this.hideContractingEntities();
            if (!this.isToggleEnabled) {
                this.closeToggle();
            }
            this.showToggleView = false;
        }
    }

    // Hide contracting entities
    async hideContractingEntities() {
        try {
            await this.checkFiltered();
            this.accountHierarchy = this.isSearched ? this.checkSearch(AccountHierarchyStore.state.gridData) : AccountHierarchyStore.state.gridData;
            this.showMessage = false;
            this.isLoading = false;
            this.showChildHierarchy = false;
        } catch (error) {
            this.isLoading = false;
        }
    }

    // Show contracting entities
    async showContractingEntities() {
        try {
            const results = await Promise.all([
                AccountHierarchyStore.getBusinessHierarchyDataWithContract(this.isToggleEnabled)
            ]);
            if (results && Array.isArray(results) && results[0].length > 0 && results[0][0] !== undefined
            ) {
                this.switchContracting = true;
                this.accountHierarchy = this.isSearched ? this.checkSearch(results[0]) : results[0];
                this.switchContracting = false;
                this.isLoading = false;
                this.showChildHierarchy = false;
                this.showMessage = false;
            } else {
                this.showMessage = true;
                this.messageToBeDisplayed = noSearchResultFoundMessage;
            }
        } catch (error) {
            this.isLoading = false;
        }
    }

    // Handle the click event on the Account Name
    handleAccountNameClick(event) {
        event.preventDefault();
        const accountId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    /**
     * @description To handle filter box click.
     */
    handleFilterBoxClick(event) {
        event.preventDefault();
        this.activeChildComponent = null;
    }

    // Handle the click event on the NetSuite Id
    handleNetSuiteIdClick(event) {
        event.preventDefault();
        const netSuiteId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: netSuiteId,
                objectApiName: 'Payment_Account__c',
                actionName: 'view'
            },
        });
    }

    async handleLaterFiltering() {
        //show contracting & search
        if (this.switchContracting) {
            this.showContractingEntities();
            this.isContractingEntitiesEnabled = true;
            this.switchContracting = false;
        }
        if (this.isSearched && !this.switchContracting) {
            await this.showFilterData();
            this.openToggle();
            this.showToggleView = true;
        }
    }

    // Handle the click event on the Business Id
    handleBusinessIdClick(event) {
        event.preventDefault();
        const businessId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: businessId,
                objectApiName: 'Xref__c',
                actionName: 'view'
            },
        });
    }

    // Handle the click event on the NetSuite Id
    handleStoreIdClick(event) {
        event.preventDefault();
        const storeId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: storeId,
                objectApiName: 'Xref__c',
                actionName: 'view'
            },
        });
    }

    // Handle the click event on the NetSuite Id
    handleContractClick(event) {
        event.preventDefault();
        const contractId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contractId,
                objectApiName: 'Contract',
                actionName: 'view'
            },
        }).then(url => { window.open(url) });
    }

    /**
     * @description To open toogle stores checkbox.
     */
    openToggle() {
        for (let iterator = 0; iterator < this.secondBusinessSection.length; iterator++) {
            this.secondBusinessSection[iterator].classList.remove('section-styling');
        }
        for (let iterator = 0; iterator < this.thirdBusinessSection.length; iterator++) {
            this.thirdBusinessSection[iterator].classList.remove('section-styling');
        }
        for (let iterator = 0; iterator < this.fourthBusinessSection.length; iterator++) {
            this.fourthBusinessSection[iterator].classList.remove('section-styling');
        }
        for (let iterator = 0; iterator < this.fifthBusinessSection.length; iterator++) {
            this.fifthBusinessSection[iterator].classList.remove('section-styling');
        }
        for (let iterator = 0; iterator < this.firstbusinessSectionButton.length; iterator++) {
            this.firstbusinessSectionButton[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.secondBusinessSectionButton.length; iterator++) {
            this.secondBusinessSectionButton[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.thirdBusinessSectionButton.length; iterator++) {
            this.thirdBusinessSectionButton[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.fourthBusinessSectionButton.length; iterator++) {
            this.fourthBusinessSectionButton[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.parentSection.length; iterator++) {
            this.parentSection[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.ultimateParentStoresSection.length; iterator++) {
            this.ultimateParentStoresSection[iterator].classList.remove('section-styling');
            this.ultimateParentStoresSection[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.firstBusinessSection.length; iterator++) {
            this.firstBusinessSection[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
        }
        for (let iterator = 0; iterator < this.secondBusiness.length; iterator++) {
            if (this.secondBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.secondBusiness[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
        for (let iterator = 0; iterator < this.thirdBusiness.length; iterator++) {
            if (this.thirdBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.thirdBusiness[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
        for (let iterator = 0; iterator < this.fourthBusiness.length; iterator++) {
            if (this.fourthBusiness[iterator].classList.contains('slds-accordion__section')) {
                this.fourthBusiness[iterator].classList.add(ENABLE_ACCORDION_CLASS_NAME);
            }
        }
    }

    /**
     * @description To get label from child component.
     * @JIRA# LEM-12109
     * @param event
    */
    setActiveLabel(event) {
        this.activeChildComponent = event.detail;
    }

    /**
     * @description To toogle stores checkbox.
     */
    togglePanel() {
        if (this.isPanelHidden) {
            this.isPanelHidden = false;
        } else {
            this.isPanelHidden = true;
            this.brandSearchKey = '';
            this.productSearchKey = '';
            this.verticalSearchKey = '';
        }
    }

    /**
     * @description To fetch filtered data on commit.
     * @JIRA# LEM-10968
     * @param event
     */
    async handleKeyDown(event) {
        let valueinSearchBox = event.target.value;
        if (this.formulateSearchKey.length === 0 && valueinSearchBox.length > 0) {
            this.formulateSearchKey += valueinSearchBox;
        }
        if (event.key !== 'Enter' && event.key !== 'Backspace' && ((event.keyCode >= 65 && event.keyCode <= 90) || (event.keyCode >= 48 && event.keyCode <= 57) || event.keyCode === 32 || event.keyCode === 189 || event.keyCode === 188)) {
            this.formulateSearchKey += event.key;
        }
        if (event.key === 'Backspace') {
            this.formulateSearchKey = this.formulateSearchKey.substring(0, this.formulateSearchKey.length - 1);
            if (this.formulateSearchKey.length === 0 && valueinSearchBox.length === 1) {
                if (this.isFiltered) {
                    AccountHierarchyStore.setGridData(this.completeFilteredAccountHierarchy);
                } else {
                    AccountHierarchyStore.setGridData(this.completeAccountHierarchy);
                }
                this.clearSearch();
                this.closeToggle();
            }
        }
        if (event.key === 'Enter') {
            let currentSearchKeyLength = this.formulateSearchKey.length;
            if (this.formulateSearchKey !== valueinSearchBox) {
                this.formulateSearchKey = valueinSearchBox;
            }
            this.searchKey = this.formulateSearchKey;
            this.formulateSearchKey = '';
            this.checkFiltered();
            if (currentSearchKeyLength >= 3) {
                this.isToggleEnabled = true;
                this.performSearch();
            } else if (currentSearchKeyLength === 0) {
                this.clearSearch();
                this.closeToggle();
            }
        }

    }

    handleCommit(event) {
        let key = event.target.value;
        this.formulateSearchKey = '';
        if (key === '' && this.isSearched) {
            this.clearSearch();
            this.closeToggle();
        }
    }

    async performSearch() {
        this.checkContracting(AccountHierarchyStore.state.gridData);
        this.switchContracting = false;
        await this.showFilterData();
        this.openToggle();
        this.showToggleView = true;
    }

    clearSearch() {
        this.searchKey = "";
        this.isLoading = true;
        this.isToggleEnabled = (this.isFiltered || this.isContractingEntitiesEnabled || this.isToggleEnabledManually) ? true : false;
        if (!this.isContractingEntitiesEnabled) {
            this.showToggleView = false;
        }
        try {
            AccountHierarchyStore.setSearchFlag();
            this.isSearched = false;
            this.checkFiltered();
            this.accountHierarchy = this.isContractingEntitiesEnabled ? this.checkContracting(AccountHierarchyStore.state.gridData) : AccountHierarchyStore.state.gridData;
            this.accountHierarchy[0].showSeeMore = this.accountHierarchy[0].Contracts?.length > contractMinimumLength;
            if (this.accountHierarchy[0].showSeeMore) {
                this.accountHierarchy[0].Contracts.splice(this.accountHierarchy[0].Contracts.length - 1, 1)
            }
            this.switchContracting = false;
            this.isLoading = false;
            this.showChildHierarchy = false;
            this.isPanelHidden = true;
            this.searchKey = '';
            this.showMessage = false;
        } catch (error) {
            this.isLoading = false;
        }
    }


    checkFiltered() {
        if (this.isFiltered) {
            AccountHierarchyStore.setGridData(this.completeFilteredAccountHierarchy);
        } else {
            AccountHierarchyStore.setGridData(this.completeAccountHierarchy);
        }
    }

    checkContracting(data) {
        AccountHierarchyStore.setGridData(data);
        if (this.isContractingEntitiesEnabled && !this.switchContracting) {
            this.switchContracting = true;
            this.showContractingEntities();
        }
    }

    checkSearch(data) {
        AccountHierarchyStore.setGridData(data);
        if (this.isSearched) {
            this.performSearch();
        }
    }

    /**
     * @description To show filtered data in search.
     * @JIRA# LEM-10968
     */
    async showFilterData() {
        this.isSearched = true;
        try {
            const results = await Promise.all([
                AccountHierarchyStore.getBusinessHierarchyWithSearchData(this.searchKey)
            ]);
            if (results && Array.isArray(results) && results[0].length > 0
            ) {
                this.accountHierarchy = results[0];
                this.accountHierarchy[0].showSeeMore = this.accountHierarchy[0].Contracts?.length > contractMinimumLength;
                if (this.accountHierarchy[0].showSeeMore) {
                    this.accountHierarchy[0].Contracts.splice(this.accountHierarchy[0].Contracts.length - 1, 1)
                }
                this.showMessage = false;
                this.isLoading = false;
                this.showChildHierarchy = false;
                this.isSearched = true;
                if (!this.disableToggle) {
                    this.isToggleEnabled = true;
                }
            } else {
                this.showMessage = true;
                this.messageToBeDisplayed = noSearchResultFoundMessage;
            }
        } catch (error) {
            this.isLoading = false;
        }
    }

    /**
     * Handles the menu item selection and performs different actions based on the selected menu item.
     * @param {Event} event - The event containing the selected menu item information.
     */
    handleMenuAction(event) {
        const action = event.detail.value;
        const accountRecordId = event.currentTarget.dataset.recordId;
        // Perform different actions based on the selected menu item
        switch (action) {
            case 'createOpportunity':
                this.createOpportunity(accountRecordId);
                break;
            case 'createWorkOrder':
                this.createWorkOrder(accountRecordId);
                break;
            case 'createCase':
                this.createCase(accountRecordId);
                break;
            default:
                break;
        }
    }

    /**
     * Opens a new tab to create a new Case for the specified account record.
     * @param accountRecordId - The record ID of the account for which the Opportunity is being created.
     */
    createCase(accountRecordId) {
        const orgURL = window.location.origin;
        const quickActionUrl = orgURL + '/lightning/o/Case/new?defaultFieldValues=AccountId=' + accountRecordId + '&count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=RELATED_LIST&backgroundContext=%2Flightning%2Fr%2Fview';
        window.open(quickActionUrl, '_blank');
    }

    /**
     * Opens a new tab to create a new Opportunity for the specified account record.
     * @param accountRecordId - The record ID of the account for which the Opportunity is being created.
     */
    createOpportunity(accountRecordId) {
        const orgURL = window.location.origin;
        const quickActionUrl = orgURL + '/lightning/action/quick/Global.NewOpportunity?objectApiName=Opportunity&context=RECORD_DETAIL&recordId=';
        window.open(quickActionUrl + accountRecordId, '_blank');
    }

    /**
     * Opens a new tab to create a new Work Order for the specified account record.
     * @param accountRecordId - The record ID of the account for which the Work Order is being created.
     */
    createWorkOrder(accountRecordId) {
        const orgURL = window.location.origin;
        const quickActionUrl = orgURL + '/lightning/action/quick/Account.Create_Work_Order?objectApiName=WorkOrder&context=RECORD_DETAIL&recordId=';
        window.open(quickActionUrl + accountRecordId, '_blank');
    }

    // Handle the click event on the See More.
    handleSeeMore(event) {
        event.preventDefault();
        const accountId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the related list
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Contracts',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
    handleSeeMoreContract(event) {
        event.preventDefault();
        const accountId = event.currentTarget.dataset.id;
        window.open(window.location.origin+'/lightning/r/'+accountId+'/related/Agreements__r/view','_self');
    }
}