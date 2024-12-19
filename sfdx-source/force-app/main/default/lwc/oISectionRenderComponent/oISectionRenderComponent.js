import { LightningElement, api, track } from 'lwc';
import businessSectionIndicator from '@salesforce/label/c.Mx_Form_Business_Section_Name';
import paymentSectionIndicator from '@salesforce/label/c.Mx_Form_Payment_Section_Name';
import photoshootSectionIndicator from '@salesforce/label/c.Mx_Form_Photoshoot_Section_Name';
import selfDeliverySectionIndicator from '@salesforce/label/c.Mx_Form_Self_Delivery_Section_Name';
import storeSectionIndicator from '@salesforce/label/c.Mx_Form_Store_Section_Name';

const COUNTRY_AUSTRALIA = 'Australia';
const COUNTRY_NZ = 'New Zealand';
const COUNTRY_CANADA = 'Canada';
const COUNTRY_UNITED_STATES = 'United States';
export default class OISectionRenderComponent extends LightningElement {
    @api loadBackButtonInfo;
    @api selectedOrderProtocolValues;
    @api businessAccountInfo;
    @api backButtonSectionInfo;
    @api currentScreen;
    @api inputFields;
    @api contractInfo;
    @api payloadInfo;
    @track businessInfoSection;
    @track businessInfoSectionFields = [];
    @track storeSectionFields = [];
    @track storeSectionFieldsDisplay = [];
    @track isbusinessInfoLoad = false;
    @track isStoreInfoLoad = false;
    @track noOfStore = 0;
    @track storeSectionFieldValueMap = [];
    @track isRequiredMessageDisplay = false;
    @track isMaximumStore = false;
    autoApplyAllStores = [];
    isSeattleSectionAvailable = false;
    seattleSection;
    posProtocolSection;
    emailProtocolSection;
    tabletProtocolSection;
    @api isExternalCommunity = false;
    loadAllStore = false;
    allStoreSectionFieldsDisplay = [];
    @api sectionsEnteredByRep = 0;
    @api storeNames = [];
    orderProtocolValues = { isEmail: false, isTablet: false, isPOS: false, isSelfDelivery: false };


    connectedCallback() {
        this.handleFieldsMapSplit();

    }

    renderedCallback() {
        if (!this.isExternalCommunity) {
            this.handleFieldPrePopulation();
        }
        if (this.loadBackButtonInfo) {
            this.fillFormData();
        }

    }

    handleFieldsMapSplit() {
        //this.inputFields.forEach((element, index) => {
        for (let index = 0; index < this.inputFields.length; index++) {
            let element = this.inputFields[index];
            let tempElement = JSON.parse(JSON.stringify(element));
            let billingCountry = this.contractInfo !== undefined ? this.contractInfo.payload.billingCountry : (this.payloadInfo !== undefined ? this.payloadInfo['billingCountry'] : '');
            if (element.Is_it_Store_Section__c == false) {
                if (element.Section__c.includes(photoshootSectionIndicator) &&
                    (billingCountry === COUNTRY_AUSTRALIA || billingCountry === COUNTRY_NZ)) {
                    let newArray = element.OIAttributesConfigs__r.filter(item => {
                        return (item.OIAttribute__r.Field_API_Name__c !== 'Photoshoot_Date__c' && item.OIAttribute__r.Field_API_Name__c !== 'Photoshoot_Time__c')
                    });
                    tempElement.OIAttributesConfigs__r = newArray;
                }
                //Conditionally show certain fields on Business section
                else if (element.Section__c.includes(businessSectionIndicator)) {
                    //Iterate on all the attributes from the metadata
                    let newArray = element.OIAttributesConfigs__r.filter(item => {
                        //If field API name is Routing_Number__c, only show it when country is not New Zealand
                        if (item.OIAttribute__r.Field_API_Name__c == 'Routing_Number__c') {
                            return (billingCountry != COUNTRY_NZ);
                        }
                        //No condition for other attributes, show them on the page
                        else {
                            return true;
                        }
                    });
                    tempElement.OIAttributesConfigs__r = newArray;
                }

                if (element.Section__c.includes(paymentSectionIndicator) && billingCountry !== COUNTRY_CANADA) {
                    let newArray = element.OIAttributesConfigs__r.filter(item => {
                        return (item.OIAttribute__r.Field_API_Name__c !== 'Institution_Number__c')
                    });
                    tempElement.OIAttributesConfigs__r = newArray;
                }
                if (element.Store_Section_For_No_Rep_Scenario__c) {
                    if (element.Section__c === 'Store Info -> Self Delivery Details' && !this.contractInfo.isSelfDelivery) {
                        continue;
                    } if (element.Order_Protocol__c === 'POS') {
                        this.posProtocolSection = element;
                        continue;
                    } if (element.Order_Protocol__c === 'Email') {
                        this.emailProtocolSection = element;
                        continue;
                    } if (element.Order_Protocol__c === 'Tablet') {
                        this.tabletProtocolSection = element;
                        continue;
                    }
                }

                this.businessInfoSectionFields.push(tempElement);
                this.isbusinessInfoLoad = true;
            } else {
                //Conditionally show certain fields on Store section
                if (element.Section__c.includes(storeSectionIndicator)) {
                    let newArray = element.OIAttributesConfigs__r.filter(item => {
                        //If field API name is Provincial_Tax_ID__c, only show it when country is canada
                        if (item.OIAttribute__r.Field_API_Name__c == 'Provincial_Tax_ID__c') {
                            return (billingCountry == COUNTRY_CANADA);
                        }
                        //If field API name is Institution_Number__c, only show it when country is canada
                        if (item.OIAttribute__r.Field_API_Name__c == 'Institution_Number__c') {
                            return (billingCountry == COUNTRY_CANADA);
                        }
                        //If field API name is Routing_Number__c, only show it when country is not New Zealand
                        if (item.OIAttribute__r.Field_API_Name__c == 'Routing_Number__c') {
                            return (billingCountry != COUNTRY_NZ);
                        }
                        //For all other fields display it
                        return true;
                    });
                    tempElement.OIAttributesConfigs__r = newArray;
                }

                this.storeSectionFields.push(tempElement);
            }
        }
        // To load data on back
        if (this.loadBackButtonInfo) {
            if ((Object.prototype.hasOwnProperty.call(this.backButtonSectionInfo, 'storeNumber'))) {
                this.populateOrderProtocolInformationBack();
                this.noOfStore = this.backButtonSectionInfo.storeNumber;
                this.isbusinessInfoLoad = false;
                this.isStoreInfoLoad = true;
                this.backButtonSectionInfo = this.backButtonSectionInfo.oiFieldWrappers;
                let contrInfo = this.contractInfo;
                this.storeSectionFields.forEach((element) => {
                    this.handleShowConditionalSections(element, contrInfo);
                });
            }
        }
        if (this.isExternalCommunity && !this.isbusinessInfoLoad) {
            if (this.sectionsEnteredByRep == 0) {
                this.loadStoreInfo();
            } else {
                this.setLoadAllStoreInfo(this.sectionsEnteredByRep, this.storeNames);
            }
        }
    }
    @api getSectionFieldInfo() {
        let allFieldInfo = [];
        this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
            allFieldInfo.push(element.getFieldInfo());
        });
        return allFieldInfo;
    }

    @api hideBusinessInfoSection() {
        this.isbusinessInfoLoad = false;
    }

    @api addStoreSection() {
        this.populateOrderProtocolInformationBack();
        let storeSectionDetails = [];
        if (this.isSeattleSectionAvailable) {
            this.isSeattleSectionAvailable = false;
            this.storeSectionFieldsDisplay.pop();
        }
        //Save added store information
        if (this.noOfStore > 0) {
            let storeFieldInfo = this.getSectionFieldInfo();
            let isValidForm = true;
            storeFieldInfo.forEach((element, index) => {
                if (element.isValidForm === false) {
                    isValidForm = false;
                }
            });
            if (isValidForm === false) {
                this.isRequiredMessageDisplay = true;
            } else {
                storeFieldInfo.forEach((element, index) => {
                    element.formDataArray.forEach((eachFormElement) => {
                        if ((Object.prototype.hasOwnProperty.call(eachFormElement, 'fieldValue')) && eachFormElement.fieldValue !== undefined && eachFormElement.fieldValue !== '') {
                            storeSectionDetails.push(eachFormElement);
                        }
                    }
                    );
                });
                this.isRequiredMessageDisplay = false;
                //this.handleFieldEmpty();
            }
            this.dispatchEvent(new CustomEvent('sendstoresection', {
                detail: { storeNumber: this.noOfStore, oiFieldWrappers: storeSectionDetails }
            }));
        }
        if (this.noOfStore == 10) {
            this.isStoreInfoLoad = false;
            this.isMaximumStore = true;
            this.dispatchEvent(new CustomEvent('increasestorecount', {
                detail: { message: this.storeSectionFieldValueMap }
            }));
        }
        else {
            this.loadStoreInfo();
        }
    }

    loadStoreInfo() {
        this.handleFieldEmpty();
        //Load store sections
        this.isStoreInfoLoad = true;
        //if(!this.isExternalCommunity)
        this.isbusinessInfoLoad = false;
        if (this.isExternalCommunity) {
            this.contractInfo = [];
        }
        let contrInfo = this.contractInfo;

        let autoApplyStores = [];
        if (this.noOfStore == 0) {
            this.storeSectionFields.forEach((element, index) => {
                this.handleShowConditionalSections(element, contrInfo);
                element.OIAttributesConfigs__r.forEach((eachElement) => {
                    if (eachElement.Auto_Applied_To_All_Store__c == true) {
                        autoApplyStores.push(eachElement.OIAttribute__r.Field_API_Name__c);
                    }
                });
            });
            this.autoApplyAllStores = autoApplyStores;
        }

        this.noOfStore = this.noOfStore + 1;
    }

    handleFieldEmpty() {
        this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
            element.clearStoreFields();
        });
    }

    /**
     * @description It is used to prepopulate configured fields from Business details.
     */
    handleFieldPrePopulation() {
        if (this.currentScreen !== 'storeDetailsScreen') {
            this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
                element.prePopulateFields(this.businessAccountInfo);
            });
        }
    }

    fillFormData() {
        this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
            element.fillFromInfoFields(this.backButtonSectionInfo);
        });
        this.loadBackButtonInfo = false;
    }

    /**
     * @description It handle Seattle Dasher Details section visibility.
     * @param event
     */
    handleSeattleDasherDetailsSectionVisibility(event) {
        if (event.detail && !this.isSeattleSectionAvailable) {
            this.storeSectionFieldsDisplay.push(this.seattleSection);
            this.isSeattleSectionAvailable = true;
        } else if (!event.detail && this.isSeattleSectionAvailable) {
            this.storeSectionFieldsDisplay.pop();
            this.isSeattleSectionAvailable = false;
        }
    }

    @api setLoadAllStoreInfo(numberOfStores, storeNames) {

        this.loadAllStore = true;
        this.isStoreInfoLoad = true;
        //if(!this.isExternalCommunity)
        this.isbusinessInfoLoad = false;
        let isFirstStore = false;
        let autoApplyStores = [];
        let contrInfo = this.contractInfo;
        for (let i = 0; i < numberOfStores; i++) {
            if (i === 0 && numberOfStores > 1) {
                isFirstStore = true;
            } else {
                isFirstStore = false;
            }
            this.storeSectionFieldsDisplay = [];
            this.storeSectionFields.forEach((element, index) => {
                this.handleShowConditionalSections(element, contrInfo);
                element.OIAttributesConfigs__r.forEach((eachElement) => {
                    if (eachElement.Auto_Applied_To_All_Store__c == true) {
                        autoApplyStores.push(eachElement.OIAttribute__r.Field_API_Name__c);
                    }
                });
            });

            let storeName = storeNames[i];
            let storeWrapper = { storeNumber: i, oiFieldWrappers: this.storeSectionFieldsDisplay, showCloneCheckbox: isFirstStore, storeName: storeName };
            this.allStoreSectionFieldsDisplay.push(storeWrapper);
        }
        this.dispatchEvent(new CustomEvent('senddisplayedstoresectioncount', {
            detail: {
                message: this.allStoreSectionFieldsDisplay[0].oiFieldWrappers.length,
                storeName: this.allStoreSectionFieldsDisplay[0].oiFieldWrappers.storeName
            }
        }));
    }

    copyDetailsToAllStores(event) {
        let sectionsCountInEachStore = this.allStoreSectionFieldsDisplay[0].oiFieldWrappers.length;
        let allFieldInfo = [];
        const fieldAPIToValueMap = new Map();
        let i = 0;
        this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
            if (i < sectionsCountInEachStore) {
                let temp = element.getSectionFieldDetails(i);
                allFieldInfo.push(temp);
                i++;
            }
        });

        allFieldInfo.forEach(sectionInfo => {
            sectionInfo.formDataArray.forEach(item => {
                fieldAPIToValueMap.set(item.fieldApiName, item.fieldValue);
            })
        })
        this.template.querySelectorAll('c-o-i-field-render-component').forEach(element => {
            element.cloneSectionValues(fieldAPIToValueMap);
        });
    }

    handleShowConditionalSections(element, contrInfo) {

        let doNotShowEmailCondition = (!this.isExternalCommunity && this.orderProtocolValues.isEmail == false) || (this.isExternalCommunity && this.payloadInfo['orderProtocol'] != 'Email');
        let doNotShowPOSCondition = (!this.isExternalCommunity && this.orderProtocolValues.isPOS == false) || (this.isExternalCommunity && !this.payloadInfo['orderProtocol'].includes('POS'));
        let doNotShowTabletCondition = (!this.isExternalCommunity && this.orderProtocolValues.isTablet == false) || (this.isExternalCommunity && !this.payloadInfo['orderProtocol'].includes('Tablet'));
        let doNotShowAlcoholCondition = (this.isExternalCommunity && (this.payloadInfo['hasAlcoholPackage'] != true || this.payloadInfo['billingCountry'] != COUNTRY_UNITED_STATES));
        let doNotShowSelfDeliverySection = (!this.isExternalCommunity && this.contractInfo.isSelfDelivery == false) || (this.isExternalCommunity && this.payloadInfo['isSelfDelivery'] != true);
        if (element.Order_Protocol__c == 'Email' && doNotShowEmailCondition) { return; }
        else if (element.Order_Protocol__c == 'POS' && doNotShowPOSCondition) { return; }
        else if (element.Order_Protocol__c == 'Tablet' && doNotShowTabletCondition) { return; }
        else if (element.Alcohol__c == true && doNotShowAlcoholCondition) { return; }
        else if ((element.Section__c == selfDeliverySectionIndicator) && doNotShowSelfDeliverySection) { return; }
        else if (element.Seattle__c) { this.seattleSection = element; return; }
        else { this.storeSectionFieldsDisplay.push(element); }
    }

    populateOrderProtocolInformation(event) {
        //const orderProtocolValue = event.detail;
        this.selectedOrderProtocolValues = event.detail;
        this.populateOrderProtocolInformationBack();
    }

    populateOrderProtocolInformationBack() {
        if (this.selectedOrderProtocolValues != null && this.selectedOrderProtocolValues != '') {
            this.selectedOrderProtocolValues.includes('POS') ? this.orderProtocolValues.isPOS = true : this.orderProtocolValues.isPOS = false;
            this.selectedOrderProtocolValues.includes('Email') ? this.orderProtocolValues.isEmail = true : this.orderProtocolValues.isEmail = false;
            this.selectedOrderProtocolValues.includes('Tablet') ? this.orderProtocolValues.isTablet = true : this.orderProtocolValues.isTablet = false;
        }

        if (this.isbusinessInfoLoad) {
            let orderProtocolSections = { hasEmailSection: false, hasPOSSection: false, hasTabletSection: false }
            let hasStorefrontSection = false;
            let storefrontElement;
            let filteredBusinessFields = this.businessInfoSectionFields.filter(element => {
                if (element.Order_Protocol__c == 'Email') {
                    orderProtocolSections.hasEmailSection = this.orderProtocolValues.isEmail; return orderProtocolSections.hasEmailSection;
                } if (element.Order_Protocol__c == 'POS') {
                    orderProtocolSections.hasPOSSection = this.orderProtocolValues.isPOS; return orderProtocolSections.hasPOSSection;
                } if (element.Order_Protocol__c == 'Tablet') {
                    orderProtocolSections.hasTabletSection = this.orderProtocolValues.isTablet; return orderProtocolSections.hasTabletSection;
                } if (element.Order_Protocol__c == null) {
                    if (element.Section__c.includes('Storefront')) {
                        hasStorefrontSection = true;
                    }
                    return true;
                }
            });

            if (hasStorefrontSection) {
                storefrontElement = filteredBusinessFields.pop();
            }
            if (this.orderProtocolValues.isEmail && !orderProtocolSections.hasEmailSection && this.emailProtocolSection !== undefined) {
                filteredBusinessFields.push(this.emailProtocolSection);
            }
            if (this.orderProtocolValues.isPOS && !orderProtocolSections.hasPOSSection && this.posProtocolSection !== undefined) {
                filteredBusinessFields.push(this.posProtocolSection);
            }
            if (this.orderProtocolValues.isTablet && !orderProtocolSections.hasTabletSection && this.tabletProtocolSection !== undefined) {
                filteredBusinessFields.push(this.tabletProtocolSection);
            }
            if (hasStorefrontSection) {
                filteredBusinessFields.push(storefrontElement);
            }
            this.businessInfoSectionFields = filteredBusinessFields;
        }
    }
}
