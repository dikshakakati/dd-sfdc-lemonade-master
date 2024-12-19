import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import addStoreSubHeadingMessage from '@salesforce/label/c.Add_Store_Sub_Heading_Message';
import mxOnboardingLinkSubHeading from '@salesforce/label/c.Mx_Onboarding_Link_Sub_Heading';
import smbStoreLabel from '@salesforce/label/c.Onboard_SMB_Stores_Sub_Heading';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import OPPORTUNITY_CONTRACTID from "@salesforce/schema/Opportunity.ContractId";
import CONTRACT_OPPORTUNITYID from "@salesforce/schema/Contract.SBQQ__Opportunity__c";
import CONTRACT_ACCOUNTID from "@salesforce/schema/Contract.AccountId";
const ADD_STORES_LINK_TITLE = 'Enter Store Details';
const ENTER_ONBOARDING_DETAILS_TITLE = 'Enter Onboarding Details';
const MX_ONBOARDING_LINK_TITLE = 'Mx Onboarding Link';
const NET_NEW_MX_ONBOARDING = 'Net-New Mx Onboarding';
const NET_NEW_MX_ONBOARDING_VALUE = 'Net-New';
const NET_NEW_MX_ONBOARDING_HELP_TEXT = 'Select this option if you are onboarding a new business to DoorDash';
const NET_STORE_EXPANSION = 'New Store Expansion';
const NET_STORE_EXPANSION_VALUE = 'NSE';
const NET_STORE_EXPANSION_HELP_TEXT = 'Select this option if you are adding stores to an existing business';
const PRODUCT_ADDITION = 'Product Addition';
const PRODUCT_ADDITION_VALUE = 'Product Addition';
const OPPORTUNITY_OBJECT = 'Opportunity';
const CONTRACT_OBJECT = 'Contract';
const PRODUCT_ADDITION_HELP_TEXT = 'Select this option if you are adding one of these products (Marketplace, Storefront, or Drive) to an existing business';
const OPPORTUNITY_FIELDS = ["Opportunity.ContractId"];
const CONTRACT_FIELDS = ["Contract.AccountId", "Contract.SBQQ__Opportunity__c"];
export default class onboardSMBStores extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    contractId;
    opportunityId;
    accountId;
    selectedOnboardingScenario;
    nextButtonDisabled = true;
    mxOnboardingLink;
    hasActiveMxOnboardingLink = true;
    showActiveMxOnboardingLink = false;
    showBaseComponent = false;
    showMxOnboardingLinkComponent = true;
    showOnboardingScenarioSelectionScreen = false;
    subHeadingToDisplay = smbStoreLabel;
    titleToDisplay = ENTER_ONBOARDING_DETAILS_TITLE;
    noMxInputNeeded = false;

    // Options array with labels, values, and help text
    options = [
        { label: NET_NEW_MX_ONBOARDING, value: NET_NEW_MX_ONBOARDING_VALUE, helpText: NET_NEW_MX_ONBOARDING_HELP_TEXT },
        { label: NET_STORE_EXPANSION, value: NET_STORE_EXPANSION_VALUE, helpText: NET_STORE_EXPANSION_HELP_TEXT },
        { label: PRODUCT_ADDITION, value: PRODUCT_ADDITION_VALUE, helpText: PRODUCT_ADDITION_HELP_TEXT }
    ];

    connectedCallback() {
        // Initialize the checked status when the component is inserted into the DOM
        this.updateCheckedStatus();
    }

    /**
    * @description To fetch Opportunity/Contract record details from recordId.
    * @param recordId
    * @param fields
    * @return wiredRecord
    */
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            switch (this.objectApiName) {
                case OPPORTUNITY_OBJECT:
                    this.contractId = getFieldValue(data, OPPORTUNITY_CONTRACTID);
                    this.opportunityId = this.recordId;
                    break;
                case CONTRACT_OBJECT:
                    this.contractId = this.recordId;
                    this.opportunityId = getFieldValue(data, CONTRACT_OPPORTUNITYID);
                    this.accountId = getFieldValue(data, CONTRACT_ACCOUNTID);
                    break;
                default:
                    break;
            }
        }
    }

    //It returns Opportunity or Contract fields based on Object value.
    get fields() {
        if (this.objectApiName == OPPORTUNITY_OBJECT) {
            return OPPORTUNITY_FIELDS;
        } else if (this.objectApiName == CONTRACT_OBJECT) {
            return CONTRACT_FIELDS;
        }
    }

    /**
     * @description It is used to handle Add Store button click.
     * @param event
     */
    handleAddStore(event) {
        if (event.detail) {
            this.titleToDisplay = ADD_STORES_LINK_TITLE;
            this.subHeadingToDisplay = addStoreSubHeadingMessage;
        } else {
            this.titleToDisplay = ENTER_ONBOARDING_DETAILS_TITLE;
            this.subHeadingToDisplay = '';
        }

    }

    // Function to handle change in radio button selection
    handleChange(event) {
        this.selectedOnboardingScenario = event.target.value;
        this.value = event.target.value;
        this.nextButtonDisabled = false;
        this.updateCheckedStatus();
    }

    handleHereClick(event) {
        event.preventDefault();
        const mxOnboardingLinkId = event.currentTarget.dataset.id;
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: mxOnboardingLinkId,
                objectApiName: 'Mx_Onboarding_Link__c',
                actionName: 'view'
            },
        }).then(url => { window.open(url) });
    }

    handleClose() {
        // Dispatching the standard close action event to close the quick action screen
        const closeActionEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeActionEvent);
    }

    handleNext() {
        this.showOnboardingScenarioSelectionScreen = false;
        this.showBaseComponent = true;
        this.showMxOnboardingLinkComponent = false;
        this.subHeadingToDisplay = '';
    }

    handleMxOnboardingLink(event) {
        this.mxOnboardingLink = event.detail;
        this.hasActiveMxOnboardingLink = (Object.prototype.hasOwnProperty.call(this.mxOnboardingLink, 'Id'));
        this.showActiveMxOnboardingLink = this.hasActiveMxOnboardingLink;
        this.showMxOnboardingLinkComponent = this.hasActiveMxOnboardingLink;
        this.showOnboardingScenarioSelectionScreen = !this.hasActiveMxOnboardingLink;
        if (this.hasActiveMxOnboardingLink) {
            this.subHeadingToDisplay = mxOnboardingLinkSubHeading;
            this.titleToDisplay = MX_ONBOARDING_LINK_TITLE;
        }
    }

    /**
     * @description It is used to handle successful creation of Mx Onboarding Link record.
     * @param event
     */
    handleMxOnboardingLinkSuccess(event) {
        this.mxOnboardingLink = event.detail;
        this.showActiveMxOnboardingLink = true;
        this.hasActiveMxOnboardingLink = true;
        this.showOnboardingScenarioSelectionScreen = false;
        this.showBaseComponent = false;
        this.showMxOnboardingLinkComponent = true;
    }

    handleMxOnboardingLinkCreation(event) {
        this.noMxInputNeeded = true;
        this.titleToDisplay = 'Onboarding has been initiated';
        this.subHeadingToDisplay = '';
        this.showBaseComponent = false;
    }

    /**
     * @description It is used to hide OI Base component on back button.
     * @param event
     */
    hideOIBaseComponent(event) {
        this.showBaseComponent = false;
        this.showOnboardingScenarioSelectionScreen = true;
        this.subHeadingToDisplay = smbStoreLabel;

    }
    // Function to update the 'checked' status of each option based on the current value
    updateCheckedStatus() {
        this.options = this.options.map(option => ({
            ...option,
            checked: option.value === this.value
        }));
    }
}