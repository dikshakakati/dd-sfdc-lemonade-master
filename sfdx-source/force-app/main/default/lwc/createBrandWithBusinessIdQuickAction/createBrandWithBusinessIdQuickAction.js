import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import fetchExistingBrands from "@salesforce/apex/CreateBrandAndBusinessIdController.fetchExistingAssociatedBrands";
import fetchBGGroupIDs from "@salesforce/apex/CreateBrandAndBusinessIdController.fetchBGGroupIdsAssociatedWithAccount";
import createFlowRequest from "@salesforce/apex/CreateBrandAndBusinessIdController.createFlowRequest";
import createBrandAndBizRefs from "@salesforce/apex/CreateBrandAndBusinessIdController.createBrandAndBizRefs";
import insertBrands from "@salesforce/apex/CreateBrandAndBusinessIdController.insertBrands";
import checkIfBusinessReferenceUnique from "@salesforce/apex/CreateBrandAndBusinessIdController.checkIfBusinessReferenceUnique";
import validateBrands from "@salesforce/apex/CreateBrandAndBusinessIdController.validateBrands";
import OWNER_FIELD from "@salesforce/schema/Opportunity.AccountId";
import OWNER_NAME from "@salesforce/schema/Opportunity.Account.Name";
import CURRENCY_FIELD from "@salesforce/schema/Opportunity.Account.CurrencyIsoCode";
import PRIMARY_VERTICAL from "@salesforce/schema/Opportunity.Account.Primary_Vertical__c";
import BILLING_COUNTRY_CODE_FIELD from "@salesforce/schema/Opportunity.Account.BillingCountryCode";
import OWNER_FIELD_CONTRACT from "@salesforce/schema/Contract.AccountId";
import CURRENCY_FIELD_CONTRACT from "@salesforce/schema/Contract.Account.CurrencyIsoCode";
import PRIMARY_VERTICAL_CONTRACT from "@salesforce/schema/Contract.Account.Primary_Vertical__c";
import BILLING_COUNTRY_CODE_FIELD_CONTRACT from "@salesforce/schema/Contract.Account.BillingCountryCode";
import { exportCSVFile } from 'c/downloadCSVUtils';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';
import createBrandWithBusinessIdQuickActionCss from '@salesforce/resourceUrl/createBrandWithBusinessIdQuickAction';
import updateFlowRequestStatus from "@salesforce/apex/CreateBrandAndBusinessIdController.updateFlowRequestStatus";
import createLog from "@salesforce/apex/LogController.createLog";
import getBusinessVertical from '@salesforce/apex/CreateBrandAndBusinessIdController.getBusinessVerticals';



const INITIAL_INPUT_SCREEN = "initialInputScreen";
const OPPORTUNITY_OBJECT = "Opportunity";
const CONTRACT_OBJECT = "Contract";
const URL_TYPE = "url";
const NEWLY_CREATED_BRAND_FILE_NAME = "NewlyCreatedBrands";
const GENERIC_TOAST_ERROR_TITLE = "Validation Failed";
const GENERIC_TOAST_ERROR_MESSAGE = "Review and correct errors.";
const GENERIC_TOAST_ERROR_VARIANT = "error";
const LWC_NAME = "CreateBrandWithBusinessIdQuickAction";
const INSERT_FLOW_REQUEST = "insertFlowRequest";
const UPDATE_FLOW_REQUEST = "updateFlowReqest";
const INSERT_BRANDS = "insertBrands";
const CREATE_BRAND_AND_BIZ_REFS = "createBrandAndBizRefs";
const RELATION_TYPE_LICENSOR = "Licensor";
const FETCH_BUSINESS_GROUP_ID = "fetchBGGroupIDs";
const GET_BUSINESS_VERTICAL = "getBusinessVertical";
const MARKETPLACE_PRODUCT = "Marketplace";
const PRICE_RANGE = "$$";

export default class CreateBrandAndBusinessIdQuickAction extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track existingBrands = [];
    @api isBrandSelected;
    @track brandOptions = [];
    @track businessRefOptions = [];
    @track listOfBrands = [];
    initialInputScreen = false;
    createBrandScreen = false;
    showComponent = false;
    loading = true;
    existingBrandsSelectionScreen;
    selectedBrand;
    selectedBrandName;
    selectedBrandAssociation;
    confirmationScreen = false;
    finalConfirmationScreen = false;
    isRendered = false;
    successMsg;
    existingScreenLabel = 'The system had found that there were already Brand(s) associated with this Account. If you would like to use one of these existing Brand(s) and only create a new Business ID(s), please select the existing Brand you would like to use.' +
        '<p class="slds-p-top_small"> If you would like to create a new Brand and not use any of the existing Brands, please click <b> "Next"</b>.</p> ';
    showToggleOption = true;
    @track brandInput = 1;
    brandLabel = 'How many Brands would you like to create?';
    //brandNameHelpText = "Please enter the name of the brand that you’re creating. Note that you cannot use the same name of a Brand that already exists in the system.";
    brandNameHelpText = '<p class="slds-p-bottom_xx-small">Please input the brand name for creation. This brand will represent a unique Business ID in the system. If the name is already in use, please append a unique identifier as a suffix. </p>' +
        '<p>  For instance, if "Albertsons" requires separate business IDs for its Seattle and Portland branches, create separate brands named "Albertsons (Seattle)" or "Albertsons (Portland)".</p>';
    relationTypeHelpText = 'Please choose “Licensor” if this Merchant owns the Brand you are creating. Please choose “Licensee” if this Merchant does not own the Brand you are creating. ';
    brandTypeHelpText = 'Indicate if this is a virtual brand'
    brandTypeGuideText = '<p>  Please use the Brand Type field to indicate if the Brand you are creating is a Virtual Brand. For guidelines on how a virtual brand is defined, please refer to <a href="https://docs.google.com/presentation/d/11JloHsz75fdu9OyeaFqXxSDoErrPuMJrteujLVgRyDU/edit#slide=id.g13da369951e_0_4"> guide </a> and <a href="https://doordash.atlassian.net/wiki/spaces/VB/pages/2202206446/Virtual+Brand+Intake+Process"> wiki</a>.</p>';
    toggleLabel = 'Would you like to create a New Business Id(s)?';
    createdCaseId;
    recordsToDisplay = [];
    brandRecordsToDisplay = [];
    columns = [
        { label: 'Brand', fieldName: 'Name_URL', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Business Reference', fieldName: 'BusinessName_URL', type: 'url', typeAttributes: { label: { fieldName: 'Business_Name__c' }, target: '_blank' } }
    ];
    columnToDisplayBrands = [
        { label: 'Brand', fieldName: 'Name_URL', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    ];
    JSONDataforProcessFlowRequest = { "brandAndBizRefsList": [], "caseRecord": {} };
    isBrandsWithBizRefsToBeCreated = false;
    isSingleBrandsToBeCreated = false;
    driveHelpGuidanceText = "<p> If this Merchant is a CPG Partner or only onboarding onto Drive, you do not need to create a Marketplace Business ID. </p>"
    businessNameHelpText = '<p class="slds-p-bottom_xx-small"> Please input Cx facing MINT Business Name. The business name should mirror the brand name provided above, excluding any unique identifiers. </p>' +
        ' <p> For instance, if the brand name is "Albertsons (Seattle)", the business name should be "Albertsons" to maintain consistency for the customer.</p>';
    businessGroupIdHelpText = '<p class="slds-p-bottom_xx-small"> If a new Business Group ID is needed, please file a Business Hierarchy Assistance S&O support request with the name of the new business group. Once the request is complete, enter the new BGID here. </p>';
    businessVerticalGuidanceText = '<p>  Independently confirm reasonableness of BVID; validate with GM if necessary. See current BVID SOT and governance guide <a href="https://doordash.atlassian.net/wiki/spaces/NM1/pages/3204251920/Business+Vertical+IDs+BVID">here</a>.</p>';
    priceRangeHelpText = 'Sales must align with the GM team to determine price range for brand ($-$$$$). This value will affect filtering on the Marketplace app.';
    businessGroupIdOptions;
    existingGroupIdsExist;
    errorMessage;
    businessVerticalEligibiltyMessage = '<p>The business vertical you have selected is for Drive. You can only select Marketplace Business Vertical for your new Brand & Business ID. If you want a drive Business ID created, please submit a request <a href="https://doordash.atlassian.net/wiki/spaces/~5f49cf236db35e0039b79629/pages/3310060389/Drive+Activations+Team+DAT+Wiki">here</a>.</p>';



    /**
    * @description Rendered callback, dispatching the events that needs to be handled for respective screens.
    */
    renderedCallback() {
        // removing the standard helptext.
        const style = document.createElement('style');
        style.innerText = ".clshelptexthide div.slds-form-element__icon { display: none; }";
        let qs = this.template.querySelectorAll('.clshelptexthide');

        for (let i = 0; i < qs.length; i++) {
            const element = qs[i];
            element.appendChild(style);
        }
    }

    /**
    * @description Connected callback, initializing brandOptions.
    */
    connectedCallback() {
        loadStyle(this, createBrandWithBusinessIdQuickActionCss).then(() => {
        }).catch(error => {
            console.error("Error in loading the CSS")
        })

        // Initialize options with maximum available brandOptions (20)
        this.brandOptions = Array.from({ length: 20 }, (_, index) => ({
            label: index + 1,
            value: index + 1,
        }));

        var businessRefOptions = Array.from({ length: 20 }, (_, index) => ({
            label: index + 1,
            value: index + 1,
        }));

        var businessRefList = Array.from({ length: 1 }, (_, index) => ({
            id: index,
            index: index + 1,
            businessName: '',
            businessVertical: '',
            cssClass: 'slds-box slds-var-m-vertical_small',
            errorMsg: '',
            showErrorMsg: false,
            showBusinessVerticalError: false,
        }));

        // initializing listOfBrands with one index.
        if (this.brandInput) {
            this.listOfBrands = Array.from({ length: this.brandInput }, (_, index) => ({
                id: index,
                index: index + 1,
                name: '',
                cssClass: 'slds-box slds-var-m-vertical_small',
                errorMsg: '',
                showErrorMsg: false,
                bizRefToBeCreated: true,
                businessRefOptions: businessRefOptions,
                listOfBusinessRef: businessRefList,
            }));
        }
    }

    /**
    * @description fetches the column to display in the datatable.
    */
    get columnToDisplay() {
        return !this.isBrandsWithBizRefsToBeCreated && this.isSingleBrandsToBeCreated ? this.columnToDisplayBrands : this.columns;
    }

    /**
    * @description fetches the data to display in the datatable.
    */
    get dataToDisplay() {
        return !this.isBrandsWithBizRefsToBeCreated && this.isSingleBrandsToBeCreated ? this.brandRecordsToDisplay : this.recordsToDisplay;
    }

    /**
    * @description create the success label with appending created case link.
    */
    get successLabel() {
        var opportunitySuccessLabel = 'You have successfully created a new Brand(s) and Business Reference(s). This <a href="/' + this.createdCaseId + '"> S&O Support Case </a> has been created for Business Group Confirmation. The Business ID(s) are being generated, you will receive an email once it has been successfully created.';
        var opportunitySuccessLabelWithoutBizRefs = 'You have successfully created a new Brand(s)';
        var opportunitySuccessLabelWhenExistingBrandSelected = "You have successfully created new Business Reference(s) with existing Brand."
        var contractSuccessLabel = 'You have successfully created a new Brand(s) and Business Reference(s).';
        var contractSuccessLabelWhenExistingBrandSelected = 'You have successfully created new Business Reference(s) with existing Brand.';

        if (this.isOpenedFromContract) {
            return this.isBrandSelected ? contractSuccessLabelWhenExistingBrandSelected : contractSuccessLabel;
        }
        else {
            return this.isBrandsWithBizRefsToBeCreated ? opportunitySuccessLabel : this.isBrandSelected ? opportunitySuccessLabelWhenExistingBrandSelected : opportunitySuccessLabelWithoutBizRefs;
        }
    }

    /**
    * @description get the success label css.
    */
    get successLabelCss() {
        var centralAlignCss = 'slds-align_absolute-center';
        if (this.isOpenedFromContract) {
            return centralAlignCss;
        }
        else {
            return this.isBrandsWithBizRefsToBeCreated ? '' : centralAlignCss;
        }
    }

    /**
    * @description method to determine height of page.
    */
    get heightCSS() {
        return "height: 60vh; overflow-y: auto;";
    }

    /**
    * @description method to determine if the componenet is opened from the contract page.
    */
    get isOpenedFromContract() {
        let sObject = this.objectApiName == CONTRACT_OBJECT ? true : false;
        return sObject;
    }

    /**
    * @description It is used to insert flow request record in the database.
    */
    insertFlowRequest() {
        createFlowRequest({ recordId: this.recordId, sObjectType: this.objectApiName })
            .then(result => {
                if (result) {
                    // flow request inserted
                }
            }).catch(error => {
                this.error = error;
                createLog({
                    lwcName: LWC_NAME,
                    methodName: INSERT_FLOW_REQUEST,
                    message: JSON.stringify(error)
                });
            });
    }

    /**
    * @description It is used to update flow request and modify the status and stamping accordingly.
    */
    updateFlowReqest(serializeDataToBeStamped) {
        updateFlowRequestStatus({
            recordId: this.recordId,
            sObjectType: this.isOpenedFromContract ? CONTRACT_OBJECT : OPPORTUNITY_OBJECT,
            serializedData: serializeDataToBeStamped
        })
            .then((result) => {
                if (result) {
                    // flow request updated.
                }
            }).catch(error => {
                this.error = error;
                createLog({
                    lwcName: LWC_NAME,
                    methodName: UPDATE_FLOW_REQUEST,
                    message: JSON.stringify(error)
                });
            });
    }

    /**
    * @description It is used to determine opportunity or contract.
    */
    get isOpportunity() {
        return this.recordId.startsWith('006');
    }

    /**
    * @description It is used to get Opportunity record details .
    */
    @wire(getRecord, { recordId: '$recordId', fields: [OWNER_FIELD, CURRENCY_FIELD, OWNER_NAME, BILLING_COUNTRY_CODE_FIELD, PRIMARY_VERTICAL] })
    opportunityRecord;

    /**
    * @description It is used to get Contract record details.
    */
    @wire(getRecord, { recordId: '$recordId', fields: [OWNER_FIELD_CONTRACT, CURRENCY_FIELD_CONTRACT, BILLING_COUNTRY_CODE_FIELD_CONTRACT, PRIMARY_VERTICAL_CONTRACT] })
    contractRecord;

    /**
    * @description It is used to fetch account id.
    */
    get accountId() {
        return getFieldValue(this.isOpportunity ? this.opportunityRecord.data : this.contractRecord.data, this.isOpportunity ? OWNER_FIELD : OWNER_FIELD_CONTRACT);
    }

    /**
    * @description It is used to fetch currency.
    */
    get currency() {
        return getFieldValue(this.isOpportunity ? this.opportunityRecord.data : this.contractRecord.data, this.isOpportunity ? CURRENCY_FIELD : CURRENCY_FIELD_CONTRACT);
    }

    /**
     * Description - it is used to decide visibility of brand type input field based on primary vertical of account
     */
    get isPrimaryVerticalRx() {
        const primaryVertical = getFieldValue(this.isOpportunity ? this.opportunityRecord.data : this.contractRecord.data, this.isOpportunity ? PRIMARY_VERTICAL : PRIMARY_VERTICAL_CONTRACT);
        return primaryVertical == 'Rx' ? true : false;
    }

    /**
    * @description It is used to fetch country code.
    */
    get countryCode() {
        return getFieldValue(this.isOpportunity ? this.opportunityRecord.data : this.contractRecord.data, this.isOpportunity ? BILLING_COUNTRY_CODE_FIELD : BILLING_COUNTRY_CODE_FIELD_CONTRACT);
    }

    /**
    * @description fetches existing brands.
    */
    @wire(fetchExistingBrands, { accountId: '$accountId' })
    setDatatableColumns({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.brandData = data;
                this.mapBrandList(data);
                this.showComponent = true;
                this.existingBrandsSelectionScreen = true;
            }
            else {
                this.existingBrandsSelectionScreen = false;
                this.initialInputScreen = true;
                // get the existing group ids, and populates in the business group id picklist field.
                this.isOpenedFromContract ? this.fetchAllGroupIDs(this.accountId) : this.showComponent = true;
            }
            this.insertFlowRequest();

        } else if (error) {
            console.error('error ' + JSON.stringify(error));
            this.showComponent = true;
        }
    }


    /**
    * @description It is used to map brand list based on wire response.
    */
    mapBrandList(existingList) {
        const newBrandList = existingList.map(item => ({
            brandAssociationId: item.Id,
            brandId: item.Brand_Name__r.Id,
            BrandName: item.Brand_Name__r.Name,
            isChecked: false,
        }));
        this.existingBrands = newBrandList;
    }

    /**
    * @description It is used to handle cancel button event.
    */
    handleCancel() {
        let recordurl = window.location.origin + '/' + this.recordId;
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.href = recordurl;
    }

    /**
    * @description next button handler from existingAssocitateBrand screen.
    */
    nextEventHandler(event) {
        this.showComponent = false;
        if (event.detail.rowSelected) {
            this.existingBrandsSelectionScreen = false;
            this.selectedBrand = event.detail.selectedBrand;
            this.selectedBrandAssociation = event.detail.selectedBrandAssociation;
            this.selectedBrandName = event.detail.selectedBrandName;

            // below line is added to append create brand and biz refs in single screen
            this.isBrandSelected = true;
            this.initialInputScreen = true;
        }
        else {
            this.existingBrandsSelectionScreen = false;
            this.initialInputScreen = true;
        }

        this.isOpenedFromContract ? this.fetchAllGroupIDs(this.accountId) : this.showComponent = true;
    }

    /**
    * @description fetches existing group id if exists.
    */
    fetchAllGroupIDs(accountId) {
        fetchBGGroupIDs({ accountId: accountId })
            .then(data => {
                if (data) {
                    if (data.length > 0) {
                        this.existingGroupIdsExist = true;
                        const uniqueGroupIds = new Set(
                            data.map((record) => record.Business_Group_Id__c)
                        );
                        this.businessGroupIdOptions = [
                            ...Array.from(uniqueGroupIds).map((id) => ({
                                label: id,
                                value: id,
                            }))
                        ];

                    }
                    else {
                        this.existingGroupIdsExist = false;
                        this.businessGroupIdOptions = [];
                    }
                    this.showComponent = true;
                }
            })
            .catch(error => {
                createLog({
                    lwcName: LWC_NAME,
                    methodName: FETCH_BUSINESS_GROUP_ID,
                    message: JSON.stringify(error)
                });
                this.showComponent = true;
            })
    }

    /**
    * @description This is to handle when back button is used.
    */
    backEventHandler() {
        this.createBrandScreen = false;
        this.initialInputScreen = true;
        this.showToggleOption = true;
    }

    /**
    * @description It is used to update brandInput.
    */
    handleBrandInput(event) {
        const selectedValue = parseInt(event.detail.value, 10);
        const existingBrandCount = this.listOfBrands.length;
        const newBrandCount = selectedValue - existingBrandCount;

        if (newBrandCount > 0) {
            const businessRefOptions = Array.from({ length: 20 }, (_, index) => ({
                label: index + 1,
                value: index + 1,
            }));

            const businessRefList = Array.from({ length: 1 }, (_, index) => ({
                id: index,
                index: index + 1,
                businessName: '',
                businessVertical: '',
                cssClass: 'slds-box slds-var-m-vertical_small',
                errorMsg: '',
                showErrorMsg: false,
            }));

            for (let i = 0; i < newBrandCount; i++) {
                this.listOfBrands.push({
                    id: existingBrandCount + i,
                    index: existingBrandCount + i + 1,
                    name: '',
                    cssClass: 'slds-box slds-var-m-vertical_small',
                    errorMsg: '',
                    showErrorMsg: false,
                    bizRefToBeCreated: true,
                    businessRefOptions: businessRefOptions,
                    listOfBusinessRef: businessRefList,

                });
            }
            this.brandInput = selectedValue;
        }
        else if (newBrandCount < 0) {
            // If the new value is smaller than the current list, remove excess brands
            this.listOfBrands.splice(selectedValue);
            this.brandInput = selectedValue;
        }
        else {
            const targetCombobox = this.template.querySelector('[data-id="brand-combobox"]');
            targetCombobox.value = selectedValue;
        }
    }

    /**
    * @description It is used to update brandName in their respective order.
    */
    handleBrandName(event) {
        const inputValue = event.target.value;
        const brandId = event.target.dataset.brandId;
        this.removeCSSValidation();
        // Find the corresponding brand in listOfBrands and update its name
        const updatedList = this.listOfBrands.map(brand => {
            if (brand.id == brandId) {
                return { ...brand, name: inputValue };
            }
            return brand;
        });
        // Updated the listOfBrands with the new list
        this.listOfBrands = updatedList;
    }

    /**
    * @description It is used to handle toogle shift event.
    */
    handleToggleShift(event) {
        const brandId = event.target.dataset.brandId;
        this.removeCSSValidation();
        // Find the corresponding brand in listOfBrands and update its toggle shift
        const updatedList = this.listOfBrands.map(brand => {
            if (brand.id == brandId) {
                return { ...brand, bizRefToBeCreated: !brand.bizRefToBeCreated };
            }
            return brand;
        });
        // Updated the listOfBrands with the new list
        this.listOfBrands = updatedList;
    }

    /**
    * @description It is used to update price range.
    */
    handlePriceRange(event) {
        const inputValue = event.target.value;
        const brandId = event.target.dataset.brandId;
        this.removeCSSValidation();
        // Find the corresponding brand in listOfBrands and update its relationType
        const updatedList = this.listOfBrands.map(brand => {
            if (brand.id == brandId) {
                return { ...brand, selectedPriceRange: inputValue };
            }
            return brand;
        });
        // Updated the listOfBrands with the new list
        this.listOfBrands = updatedList;
    }

    /**
    * @description It is used to update brand type.
    */
    handleBrandType(event) {
        const inputValue = event.target.value;
        const brandId = event.target.dataset.brandId;
        this.removeCSSValidation();
        // Find the corresponding brand in listOfBrands and update its brandType
        const updatedList = this.listOfBrands.map(brand => {
            if (brand.id == brandId) {
                return { ...brand, selectedBrandType: inputValue };
            }
            return brand;
        });
        // Updated the listOfBrands with the new list
        this.listOfBrands = updatedList;
    }

    /**
    * @description It is the handler for update the input provided by user for business name and further map to respective index.
    */
    handleBusinessRefName(event) {
        const brandId = event.target.dataset.brandId;  // Get brand ID from data attribute
        const bizId = event.target.dataset.bizId;      // Get business reference ID from data attribute
        const newBusinessName = event.target.value;   // Get updated business name
        this.removeValidation(brandId, bizId);

        // Find the brand and business reference object to update
        const brandIndex = this.listOfBrands.findIndex(brand => brand.id == brandId);
        if (brandIndex != -1) {
            const bizIndex = this.listOfBrands[brandIndex].listOfBusinessRef.findIndex(biz => biz.id == bizId);
            if (bizIndex != -1) {
                this.listOfBrands[brandIndex].listOfBusinessRef[bizIndex].businessName = newBusinessName;
            }
        }
    }

    /**
    * @description It is the handler for update the input provided by user for business name and further map to respective index.
    */
    handleBusinessVertical(event) {
        const brandId = event.target.dataset.brandId;  // Get brand ID from data attribute
        const bizId = event.target.dataset.bizId;      // Get business reference ID from data attribute
        const newBusinessVertical = event.target.value;   // Get updated vertical id
        let isVerticalEmpty = false;

        this.removeValidation(brandId, bizId);
        this.showComponent = true;

        // Check if the selected business vertical is eligible
        if (newBusinessVertical) {
            this.isBusinessVerticalEligible(newBusinessVertical, brandId, bizId);
        }
        else {
            isVerticalEmpty = true;
        }

        // Find the brand and business reference object to update
        const brandIndex = this.listOfBrands.findIndex(brand => brand.id == brandId);
        if (brandIndex !== -1) {
            const bizIndex = this.listOfBrands[brandIndex].listOfBusinessRef.findIndex(biz => biz.id == bizId);
            if (bizIndex !== -1) {
                this.listOfBrands[brandIndex].listOfBusinessRef[bizIndex].businessVertical = newBusinessVertical;
            }
            if (bizIndex !== -1 && isVerticalEmpty) {
                this.listOfBrands[brandIndex].listOfBusinessRef[bizIndex].showBusinessVerticalError = false;
            }
        }
    }

    /**
    * @description It will check if the particular business vertical is eligible to be selected or not.
    */
    isBusinessVerticalEligible(businessVertical, brandId, bizId) {
        let flag;
        this.showComponent = false;
        getBusinessVertical({ recordId: businessVertical })
            .then(data => {
                if (data) {
                    flag = data.Product__c == MARKETPLACE_PRODUCT ? false : true;
                    this.showComponent = true;

                    // mapping the error in the business vertical, if the flag is true (product is marketplace)
                    const brandIndex = this.listOfBrands.findIndex(brand => brand.id == brandId);
                    if (brandIndex !== -1) {
                        const bizIndex = this.listOfBrands[brandIndex].listOfBusinessRef.findIndex(biz => biz.id == bizId);
                        if (bizIndex !== -1) {
                            this.listOfBrands[brandIndex].listOfBusinessRef[bizIndex].showBusinessVerticalError = flag;
                        }
                    }

                }
            })
            .catch(error => {
                createLog({
                    lwcName: LWC_NAME,
                    methodName: GET_BUSINESS_VERTICAL,
                    message: JSON.stringify(error)
                });
                this.showComponent = true;
            });
    }


    /**
    * @description It is the handler for update the input provided by user for business group id and further map to respective index.
    */
    handleBusinessRefGroupId(event) {
        const brandId = event.target.dataset.brandId;  // Get brand ID from data attribute
        const bizId = event.target.dataset.bizId;      // Get business reference ID from data attribute
        const newBusinessGroupId = event.target.value;   // Get updated business group id
        this.removeValidation(brandId, bizId);
        // Find the brand and business reference object to update
        const brandIndex = this.listOfBrands.findIndex(brand => brand.id == brandId);
        if (brandIndex !== -1) {
            const bizIndex = this.listOfBrands[brandIndex].listOfBusinessRef.findIndex(biz => biz.id == bizId);
            if (bizIndex !== -1) {
                this.listOfBrands[brandIndex].listOfBusinessRef[bizIndex].businessGroupId = newBusinessGroupId;
            }
        }
    }

    /**
    * @description It is used to remove the CSS validation from the input form.
    */
    removeCSSValidation() {
        const updatedList = this.listOfBrands.map(brand => {
            return { ...brand, cssClass: 'slds-box slds-var-m-vertical_small', errorMsg: '', showErrorMsg: false };
        });
        // Updated the listOfBusinessRef with the new list
        this.listOfBrands = updatedList;
    }

    /**
    * @description  this method used to remove the validation.
    */
    removeValidation(brandId, bizId) {
        // Find the brand and business reference object to update
        const brandIndex = this.listOfBrands.findIndex(brand => brand.id == brandId);
        if (brandIndex !== -1) {
            let updatedBizRef = this.listOfBrands[brandIndex].listOfBusinessRef.map(biz => {
                return { ...biz, cssClass: 'slds-box slds-var-m-vertical_small', errorMsg: '', showErrorMsg: false };
            });

            this.listOfBrands[brandIndex].listOfBusinessRef = updatedBizRef;
        }
    }

    /**
    * @description It is used to check if the next button should be disabled or not.
    */
    get isNextButtonDisabled() {
        if (this.existingBrandsSelectionScreen) {
            return false;
        }
        // Check if any brand has an empty name or missing relation type
        let hasEmptyBrand;
        if (!this.isBrandSelected) {
            // Assign default value
            this.listOfBrands.forEach(brand => {
                if (!brand.selectedPriceRange) {
                    brand.selectedPriceRange = PRICE_RANGE;
                }
            });
            hasEmptyBrand = this.listOfBrands.some(brand => !brand.name.trim() || !brand.selectedPriceRange);
        }

        const hasEmptyBusinessRef = this.listOfBrands.some(brand => {
            if (brand.bizRefToBeCreated) {
                return this.isOpenedFromContract ? brand.listOfBusinessRef.some(bizRef => !bizRef.businessName.trim() || !bizRef.businessVertical || !bizRef.businessGroupId) : brand.listOfBusinessRef.some(bizRef => !bizRef.businessName.trim() || !bizRef.businessVertical);
            }
            else {
                // If bizRefToBeCreated is false, no need to check listOfBusinessRef
                return false;
            }
        });

        const hasBusinessVerticalError = this.listOfBrands.some(brand => brand.listOfBusinessRef.some(bizRef => bizRef.showBusinessVerticalError));

        if (this.isBrandSelected ? hasEmptyBusinessRef || hasBusinessVerticalError : hasEmptyBrand || hasEmptyBusinessRef || hasBusinessVerticalError) {
            return true;
        }
        else {
            return false;
        }

    }

    /**
    * @description logic to call respective child methods, when next button is clicked.
    */
    handleNextButton() {
        this.showComponent = false;
        if (this.existingBrandsSelectionScreen) {
            this.template.querySelector("c-existing-associated-brand-selectionfrom-o-c").handleNext();
        }
        else {
            this.showComponent = false;
            let listOfBrandNames = this.listOfBrands.map(brand => brand.name);
            let areBizRefUnique = this.validateBusinessVerticalUniqueness();
            if (this.isBrandSelected ? areBizRefUnique : this.areBrandNamesUnique() && areBizRefUnique) {
                this.isBrandSelected ? this.validateBizRefFromApex() : this.validateApexValidation(listOfBrandNames);
            } else {
                // Show an error message
                this.highlightNonUniqueBrands();
            }
        }
    }

    /**
    * @description used to validate biz ref from the database.
    */
    validateBizRefFromApex() {
        // mapping the selected biz items before sending it to validate uniqueness.
        var BusinessRefList = [];
        this.listOfBrands[0].listOfBusinessRef.forEach(item => {
            var BusinessRef = {
                'Business_Name__c': item.businessName,
                'Business_Vertical__c': item.businessVertical,
                'CurrencyIsoCode': this.currency,
                'Brand__c': this.selectedBrand,
                'Default_Type__c': 'Corporate',
                'Integration_Status__c': 'Ready For Integration',
                'External_Id_Source__c': 'MDS',
                'Created_Source_Id__c': this.recordId,
                'Created_Source_Object__c': this.isOpenedFromContract ? CONTRACT_OBJECT : OPPORTUNITY_OBJECT,
                ...(this.isOpenedFromContract && { 'businessGroupId': item.businessGroupId }), // Conditional inclusion of Group_Id

            };
            BusinessRefList.push(BusinessRef);
        });

        checkIfBusinessReferenceUnique({ businessRefListJSON: JSON.stringify(BusinessRefList) })
            .then(result => {
                const extractedData = [];

                // validate the key(comibnaton of all uniquness identifier fields) received from the apex validation
                // fetch the business vertical id from the key and match with selected refs, if the error found.
                for (const key in result) {
                    if (result[key]) {
                        // fetching the business vertical id from the key
                        const truncatedKey = key.substring(0, 18);
                        extractedData.push({ key: truncatedKey, value: result[key] });
                    }
                }
                // Update listOfRefs with error messages.
                const updatedListOfRefs = this.listOfBrands[0].listOfBusinessRef.map(ref => {
                    const matchingEntry = extractedData.find(item => item.key === ref.businessVertical);
                    if (matchingEntry) {
                        return {
                            ...ref,
                            errorMsg: matchingEntry.value,
                            showErrorMsg: true,
                            cssClass: "slds-box slds-var-m-vertical_small non-unique",
                        };
                    } else {
                        return ref;
                    }
                });
                this.listOfBrands[0].listOfBusinessRef = updatedListOfRefs;

                // if there is validation error , show the error and if not proceed with saving the record.
                // extractedData  contains the key(business vertical id) and error to be shown
                if (extractedData.length == 0) {
                    this.mapBrandsWithBusinessRefForExistingBrands();
                }
                else {
                    this.showToastError(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, GENERIC_TOAST_ERROR_VARIANT);
                    this.showComponent = true;  //changes after removal of add more options.
                }
            })
            .catch((error) => {
                console.error('error' + JSON.stringify(error));
                this.error = error;
                this.showComponent = true;
            });


    }

    /**
    * @description It will map the selected input values and prepare the structure before sending to apex.
    */
    mapBrandsWithBusinessRefForExistingBrands() {
        let selectedBusinessRef = [];
        const newItem = {
            "brandName": '',
            "brandId": this.selectedBrand,
            "createBrandAssociations": false,
            "recordId": this.recordId,
            "createdSource": this.isOpenedFromContract ? CONTRACT_OBJECT : OPPORTUNITY_OBJECT,
            "accountId": this.accountId,
            "currencyOfAccount": this.currency,
            "bizRefList": this.listOfBrands[0].listOfBusinessRef.map(dataItem => ({
                businessName: dataItem.businessName,
                businessVerticalId: dataItem.businessVertical,
                businessGroupId: this.isOpenedFromContract ? dataItem.businessGroupId : null,
                sellingCountryCode: this.countryCode,
            }))
        };
        // Push the new item into the original list
        selectedBusinessRef.push(newItem);

        // Create a promise for each method
        const handleBrandsPromise = this.createBizRefs(selectedBusinessRef);

        // Execute both promises sequentially
        handleBrandsPromise
            .then(() => {
                this.updateFlowReqest(JSON.stringify(this.JSONDataforProcessFlowRequest));
                // Both methods have completed, stop the spinner
                this.showComponent = true;
            });
    }

    /**
    * @description used to validate biz vertical uniqueness.
    */
    validateBusinessVerticalUniqueness() {
        var flag = true;
        this.listOfBrands.forEach(brand => {
            if (brand.bizRefToBeCreated) {
                const uniqueVerticals = new Set();

                brand.listOfBusinessRef.forEach(businessRef => {
                    const key = JSON.stringify(businessRef.businessVertical); // Convert object to string
                    if (uniqueVerticals.has(key)) {
                        businessRef.errorMsg = 'You have already entered this combination';
                        businessRef.cssClass = "slds-box slds-var-m-vertical_small non-unique";
                        businessRef.showErrorMsg = true;
                        flag = false;
                    } else {
                        businessRef.errorMsg = '';
                        businessRef.showErrorMsg = false;
                        uniqueVerticals.add(key);
                    }
                });
            }
        });
        return flag;

    }

    /**
    * @description It is used to validate if the brand names are unique against the input provided from the user interface.
    */
    areBrandNamesUnique() {
        const brandNames = this.listOfBrands.map(brand => brand.name.toLowerCase());
        const uniqueBrandNames = new Set(brandNames);
        return brandNames.length == uniqueBrandNames.size;
    }

    /**
   * @description It is used to validate if the brand names are unique.
   */
    validateApexValidation(listOfBrandNames) {
        validateBrands({ brandNames: listOfBrandNames })
            .then(result => {
                if (result) {
                    if (result.length === 0) {
                        //Process ahead...
                        this.mapBrandsWithBusinessRef();
                    } else {
                        //Some brand names are not valid. Handle accordingly.
                        let brandNames = result.map(brand => {
                            return brand.Name.trim().toLowerCase()
                        });
                        this.highlightNonUniqueBrandsFromApex(JSON.stringify(brandNames));
                    }
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    /**
    * @description It will map the selected input values and prepare the structure before sending to apex.
    */
    mapBrandsWithBusinessRef() {
        let selectedBusinessRef = [];
        let brandNames = [];
        let brandNameVsPriceRange = {};

        this.listOfBrands.forEach(brand => {
            if (brand.bizRefToBeCreated) {
                // mapping for brand creation with biz refs.
                const newItem = {
                    "brandName": brand.name,
                    "brandId": null,
                    "priceRange": brand.selectedPriceRange,
                    "brandType": brand.selectedBrandType,
                    "createBrandAssociations": true,
                    "recordId": this.recordId,
                    "createdSource": this.isOpenedFromContract ? CONTRACT_OBJECT : OPPORTUNITY_OBJECT,
                    "accountId": this.accountId,
                    "currencyOfAccount": this.currency,
                    "bizRefList": brand.listOfBusinessRef.map(dataItem => ({
                        businessName: dataItem.businessName,
                        businessVerticalId: dataItem.businessVertical,
                        businessGroupId: this.isOpenedFromContract ? dataItem.businessGroupId : null,
                        sellingCountryCode: this.countryCode,
                    }))
                };
                selectedBusinessRef.push(newItem)
                this.isBrandsWithBizRefsToBeCreated = true;
            }
            else {
                // mapping for brand creation.
                brandNames.push(brand.name);
                brandNameVsPriceRange[brand.name] = String(brand.selectedPriceRange);

                this.isSingleBrandsToBeCreated = true;
            }
        })

        // Create a promise for each method
        const handleBrandsPromise = this.isSingleBrandsToBeCreated ? this.handleBrandsInsertion(brandNameVsPriceRange) : Promise.resolve();
        const createBizRefsPromise = this.isBrandsWithBizRefsToBeCreated ? this.createBizRefs(selectedBusinessRef) : Promise.resolve();

        // Execute both promises sequentially
        handleBrandsPromise
            .then(() => createBizRefsPromise)
            .then(() => {
                this.updateFlowReqest(JSON.stringify(this.JSONDataforProcessFlowRequest));
                // Both methods have completed, stop the spinner
                this.showComponent = true;

            });

    }

    /**
     * @description It is used to insert brands.
     */
    handleBrandsInsertion(brandNameVsPriceRangeMap) {
        return new Promise((resolve, reject) => {
            let ownerId = getFieldValue(this.opportunityRecord.data, OWNER_FIELD);
            let ownerName = getFieldValue(this.opportunityRecord.data, OWNER_NAME);

            insertBrands({ brandNamesVsPriceRange: JSON.stringify(brandNameVsPriceRangeMap), ownerID: ownerId })
                .then(result => {
                    if (result) {
                        let existingRecordToDisplay = [];
                        var resultsToCombine = [];
                        result.forEach(item => {
                            var bzRefsListandBrand = { "bizRefs": [], "brand": {} };
                            bzRefsListandBrand.brand = item;
                            resultsToCombine.push(bzRefsListandBrand);
                            existingRecordToDisplay.push({
                                ...item,
                                OwnerName: ownerName,
                                OwnerName_URL: '/' + item.Brand_Owner__c,
                                Name_URL: '/' + item.Id,
                            });
                        });
                        this.recordsToDisplay = existingRecordToDisplay;
                        this.brandRecordsToDisplay = [...existingRecordToDisplay];
                        this.initialInputScreen = false;
                        this.existingBrandsSelectionScreen = false;
                        this.confirmationScreen = true;
                        resultsToCombine.forEach(item => {
                            this.JSONDataforProcessFlowRequest.brandAndBizRefsList.push(item);
                        });
                        resolve(); // Resolve the promise
                    }
                })
                .catch((error) => {
                    this.error = error;
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: INSERT_BRANDS,
                        message: JSON.stringify(result.error)
                    });
                    reject(error); // Reject the promise with error
                });
        });
    }

    /**
     * @description It is used to create biz refs records and further create the structure to display datatable for created records.
     */
    createBizRefs(selectedBusinessRef) {
        return new Promise((resolve, reject) => {
            this.showComponent = false;
            createBrandAndBizRefs({ jsonString: JSON.stringify(selectedBusinessRef), isCalledFromOpportunity: !this.isOpenedFromContract })
                .then(result => {
                    if (result) {
                        this.createdCaseId = result.caseRecord ? result.caseRecord.Id : null;
                        result.brandAndBizRefsList.forEach(record => {
                            const brandName = record.brand.Name;
                            const brandId = record.brand.Id;
                            record.bizRefs.forEach(bizRef => {
                                const newItem = {
                                    "Name": brandName ? brandName : this.selectedBrandName,
                                    "Name_URL": '/' + brandId,
                                    "Business_Name__c": bizRef.Business_Name__c,
                                    "BusinessName_URL": '/' + bizRef.Id,
                                };
                                this.recordsToDisplay.push(newItem);
                            });
                        });

                        // update the process flow request, with the json result and status.
                        this.initialInputScreen = false;
                        this.existingBrandsSelectionScreen = false;
                        this.confirmationScreen = true;
                        result.brandAndBizRefsList.forEach(record => {
                            this.JSONDataforProcessFlowRequest.brandAndBizRefsList.push(record);
                        });
                        if (this.createdCaseId) {
                            this.JSONDataforProcessFlowRequest.caseRecord = result.caseRecord;
                        }
                        resolve(); // Resolve the promise
                    } else {
                        console.error('something went wrong');
                        reject(new Error("Failed to create biz refs")); // Reject the promise with error
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "info!",
                            message: error.body.message,
                            variant: "info",
                        })
                    );
                    createLog({
                        lwcName: LWC_NAME,
                        methodName: CREATE_BRAND_AND_BIZ_REFS,
                        message: JSON.stringify(result.error)
                    });
                    reject(error); // Reject the promise with error
                });
        });
    }


    /**
  * @description It is used to highlight the box whose brand name is not unique.
  */
    highlightNonUniqueBrandsFromApex(duplicateBrandNames) {
        let uniqueBrandNamesVal = new Set();
        // Identify duplicate brands and unique brand names
        this.listOfBrands.forEach(brand => {
            if (duplicateBrandNames.includes(brand.name.trim().toLowerCase())) {
                brand.cssClass = "slds-box slds-var-m-vertical_small non-unique";
                brand.errorMsg = 'Brand Name already exists in the database.';
                brand.showErrorMsg = true;
            }
            brand.bizRefToBeCreated = true;
        });
        this.showToastError(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, GENERIC_TOAST_ERROR_VARIANT);
        this.showComponent = true;
    }


    /**
    * @description It is used to highlight the box whose brand name is not unique.
    */
    highlightNonUniqueBrands() {
        let uniqueBrandNames = new Set();
        // Identify duplicate brands and unique brand names
        this.listOfBrands.forEach(brand => {
            const name = brand.name.toLowerCase();
            if (uniqueBrandNames.has(name)) {
                brand.cssClass = "slds-box slds-var-m-vertical_small non-unique";
                brand.errorMsg = 'This brand name is already selected.';
                brand.showErrorMsg = true;
            } else {
                uniqueBrandNames.add(name);
            }
        });
        this.showToastError(GENERIC_TOAST_ERROR_TITLE, GENERIC_TOAST_ERROR_MESSAGE, GENERIC_TOAST_ERROR_VARIANT);
        this.showComponent = true;
    }

    /**
    * @description It is used to call the utility class which if for the download of CSV File by passing data, columns(labe,fieldApi name)
    */
    handleDownloadClick() {
        const updatedColumns = this.columns.map(item => {
            if (item.type === URL_TYPE) {
                item.fieldName = item.typeAttributes.label.fieldName;
            }
            return item;
        });
        exportCSVFile(this.recordsToDisplay, updatedColumns, NEWLY_CREATED_BRAND_FILE_NAME);
    }

    /**
    * @description It is used to show toast error.
    */
    showToastError(title, message, variant) {
        // Dispatch Toast Error
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

}