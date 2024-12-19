/**
 * @author Deloitte
 * @date 20/07/2022
 * @description Test class for AccountValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class AccountValidationsServiceImplTest {
    private static final String ACCOUNT_BILLING_COUNTRY_CODE_CA = 'CA';
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY_YES = 'Yes';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
    private static final String DELAY_TABLET_SHIPMENT_NO = 'No';
    private static final String DELAY_TABLET_SHIPMENT_YES = 'Yes';
    private static final String HAS_STOREFRONT_WEBSITE_YES = 'Yes';
    private static final String DEVELOPER_NAME_VALIDATE_PDOA = 'PDOA_on_COO_WO_cannot_be_in_past';
    private static final String DUPLICATE_STATUS_DUPLICATE = 'Duplicate';
    private static final String DUPLICATE_STATUS_NON_DUPLICATE = 'Non-Duplicate';
    private static final String DUPLICATE_STATUS_UNVERIFIED = 'Unverified';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY = 'Please ensure Activate Centrally (AC) is populated as No.';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE = 'Please ensure Activate Centrally (AC) is populated.';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY_WORK_ORDER = 'Please ensure the Activated Centrally flag on the Store Account matches with the Parent Work Order.';
    private static final String ERROR_MESSAGE_BRAND_NOT_ASSOCIATED = 'Please ensure Brand is associated to the store account.';
    private static final String ERROR_MESSAGE_COOED = 'Please ensure Change of Ownership Effective Date is populated and not equals or greater then Proposed Date of Activation.';
    private static final String ERROR_MESSAGE_COOED_ON_WEEKEND = 'Please ensure the COO Effective Date is not on a Saturday or Sunday.';
    private static final String ERROR_MESSAGE_DUPLICATE_STATUS = 'This account is a duplicate of an existing account. Please open a ticket with the Data Ops team.';
    private static final String ERROR_MESSAGE_LEGAL_BUSINESS_NAME = 'Please ensure Legal Business Name is populated.';
    private static final String ERROR_MESSAGE_HOURS_OF_OPERATION = 'Please ensure Hours of Operation is populated.';
    private static final String ERROR_MESSAGE_PHONE = 'Please ensure Phone number is populated.';
    private static final String ERROR_MESSAGE_MENU_COMPLETED_BY = 'Please populate "Menu to be Completed By" as Marketplace type is selected.';
    private static final String ERROR_MESSAGE_MENU_COMPLETED_BY_WORK_ORDER = 'Please ensure the Menu to be Completed By on the Store Account matches with the Parent Work Order.';
    private static final String ERROR_MESSAGE_MENU_UI_TYPE = 'Please ensure Menu UI Type is populated.';
    private static final String ERROR_MESSAGE_MENU_URL_BLANK = 'Please enter the Store’s Menu URL.';
    private static final String ERROR_MESSAGE_MERCHANT_SUPPLIED_ID = 'Please ensure the MSID matches with the POS Integration ID on the Store Account.';
    private static final String ERROR_MESSAGE_MIN_PREP_TIME = 'Please ensure Minimum Prep Time is populated.';
    private static final String ERROR_MESSAGE_ORDER_PROTOCOL = 'Please ensure Order Protocol is populated.';
    private static final String ERROR_MESSAGE_ORDER_PROTOCOL_WORK_ORDER = 'Please ensure the Order Protocol on the Store Account matches with the Parent Work Order.';
    private static final String ERROR_MESSAGE_POS_INTEGRATION_ID = 'Please ensure POS Integration ID is populated.';
    private static final String ERROR_MESSAGE_POS_INTEGRATION_TYPE = 'Please ensure POS Integration Type is populated.';
    private static final String ERROR_MESSAGE_PDOA = 'Please ensure the PDOA do not occur in the past. The Proposed Date of Activation must be set to at least 4 business days into the future.';
    private static final String ERROR_MESSAGE_PDOA_ON_WEEKEND = 'Please ensure the Proposed Date of Activation is not on a Saturday or Sunday.';
    private static final String ERROR_MESSAGE_PDOT = 'Please ensure Proposed Date of Tablet is populated.';
    private static final String ERROR_MESSAGE_SHOPPING_PROTOCOL = 'Please ensure Shopping Protocol is populated with Dasher Pick or Shopper Pick.';
    private static final String ERROR_MESSAGE_SHOPPING_PROTOCOL_BLANK = 'Please ensure there is no Shopping Protocol populated if the Menu UI Type is Restaurant.';
    private static final String ERROR_MESSAGE_SHOPPING_PROTOCOL_REQUIRED = 'Please ensure Shopping Protocol is populated.';
    private static final String ERROR_MESSAGE_BUSINESS_REF_NOT_FOUND = 'Business reference not found.';
    private static final String ERROR_MESSAGE_TAX_ID = 'Please ensure Tax ID is populated.';
    private static final String ERROR_MESSAGE_ACCESSIBILITIES = 'Please ensure Accessibilities is populated.';
    private static final String ERROR_MESSAGE_ORDER_PROTOCOL_PRINTER = 'The Mx is not eligible to receive a printer. Please update Order Protocol.';
    private static final String ERROR_MESSAGE_STOREFRONT_WEBSITE_BLANK = 'Please enter the Storefront Website since it is indicated that the store has a website.';
    private static final String FIELD_LABEL_ACTIVATED_CENTRALLY = 'Activated Centrally (AC)';
    private static final String FIELD_LABEL_BRAND = 'Brand';
    private static final String FIELD_LABEL_CHANGE_OWNERSHIP_DATE = 'Change of Ownership Effective Date';
    private static final String FIELD_LABEL_DUPLICATE_STATUS = 'Duplicate Status';
    private static final String FIELD_LABEL_LEGAL_BUSINESS_NAME = 'Legal Business Name';
    private static final String FIELD_LABEL_HOURS_OF_OPERATION = 'Hours of Operation';
    private static final String FIELD_LABEL_PHONE = 'Phone';
    private static final String FIELD_LABEL_MENU_COMPLETED_BY = 'Menu to be Completed By';
    private static final String FIELD_LABEL_MENU_UI_TYPE = 'Menu UI Type';
    private static final String FIELD_LABEL_MENU_URL = 'Menu URL';
    private static final String FIELD_LABEL_MERCHANT_SUPPLIED_ID = 'Merchant Supplied ID';
    private static final String FIELD_LABEL_MIN_PREP_TIME = 'Minimum Prep Time';
    private static final String FIELD_LABEL_ORDER_PROTOCOL = 'Order Protocol';
    private static final String FIELD_LABEL_POS_INTEGRATION_ID = 'POS Integration ID';
    private static final String FIELD_LABEL_POS_INTEGRATION_TYPE = 'POS Integration Type';
    private static final String FIELD_LABEL_PDOA = 'Proposed Date of Activation';
    private static final String FIELD_LABEL_PDOT = 'Proposed Date of Tablet';
    private static final String FIELD_LABEL_SHOPPING_PROTOCOL = 'Shopping Protocol';
    private static final String FIELD_LABEL_TAX_ID = 'Tax ID';
    private static final String FIELD_LABEL_STOREFRONT_WEBSITE = 'Storefront Website';
    private static final String FIELD_NAME_STOREFRONT_WEBSITE = 'Storefront_Website__c';
    private static final String FIELD_NAME_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String FIELD_NAME_ACCESSIBILITIES = 'Accessibilities__c';
    private static final String FIELD_NAME_BRAND = 'Brand__c';
    private static final String FIELD_NAME_CHANGE_OWNERSHIP_DATE = 'Change_of_Ownership_Effective_Date__c';
    private static final String FIELD_NAME_DUPLICATE_STATUS = 'Duplicate_Status__c';
    private static final String FIELD_NAME_LEGAL_BUSINESS_NAME = 'Legal_Business_Name__c';
    private static final String FIELD_NAME_HOURS_OF_OPERATION = 'Hours_of_Operation__c';
    private static final String FIELD_NAME_PHONE = 'Phone';
    private static final String FIELD_NAME_MENU_COMPLETED_BY = 'Menu_to_be_Completed_By__c';
    private static final String FIELD_NAME_MENU_UI_TYPE = 'Menu_UI_Type__c';
    private static final String FIELD_NAME_MERCHANT_SUPPLIED_ID = 'Merchant_Supplied_ID__c';
    private static final String FIELD_NAME_MIN_PREP_TIME = 'Minimum_Prep_Time__c';
    private static final String FIELD_NAME_ORDER_PROTOCOL = 'Order_Protocol__c';
    private static final String FIELD_NAME_PDOT = 'Proposed_Date_of_Tablet__c';
    private static final String FIELD_NAME_POS_INTEGRATION_ID = 'POS_Integration_ID__c';
    private static final String FIELD_NAME_POS_INTEGRATION_TYPE = 'POS_Integration_Type__c';
    private static final String FIELD_NAME_PDOA = 'Proposed_Date_of_Activation__c';
    private static final String FIELD_NAME_SHOPPING_PROTOCOL = 'Shopping_Protocol__c';
    private static final String FIELD_NAME_TAX_ID = 'TaxID__c';
    private static final String FILED_NAME_NAME = 'Name';
    private static final String FIELD_LABEL_ACCESSIBILITIES = 'Accessibilities';
    private static final String FILED_NAME_MENU_URL = 'Menu_URL__c';
    private static final String FIELD_NAME_SEGMENT = 'Segment__c';
    private static final String FIELD_NAME_DECK_RANK = 'Deck_Rank__c';
    private static final String FIELD_NAME_EXPERIENCE = 'Experience__c';
    private static final String SELECTED_ORDER_PROTOCOL = 'Tablet and Printer (DoorDash Owns)';
    private static final String SELECTED_SEGMENT = 'SMB';
    private static final String SELECTED_DECK_RANK = 'Queen';
    private static final String SELECTED_EXPERIENCE = 'Drive';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final String MX_PICK_SHOPPING_PROTOCOL = 'Mx Pick';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String ORDER_PROTOCOL_CONTAINS_POS = 'POS';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String POS_INTEGRATION_TYPE_NON_INTEGRATED_MX = 'non_integrated_mx';
    private static final String POS_INTEGRATION_TYPE_FUTUREPOS = 'FuturePOS';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SERVICE_CLASS_NAME = 'IAccountValidationsService';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY = 'validateActivateCentrally';
    private static final String SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_BUSINESS = 'validateDuplicateStatusOnBusiness';
    private static final String SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_STORE = 'validateDuplicateStatusOnStore';
    private static final String SERVICE_METHOD_VALIDATE_COOED = 'validateCOOED';
    private static final String SERVICE_METHOD_VALIDATE_COOED_ON_WEEKEND = 'validateCOOEDOnWeekend';
    private static final String SERVICE_METHOD_VALIDATE_MINPREPTIME = 'validateMinimumPrepTime';
    private static final String SERVICE_METHOD_VALIDATE_MSID = 'validateMerchantSuppliedId';
    private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE = 'validateNullFieldValuesOnStoreByWorkOrderType';
    private static final String SERVICE_METHOD_VALIDATE_NULLVALUES_ON_STORE = 'validateNullFieldValuesOnStore';
    private static final String SERVICE_METHOD_VALIDATE_NULLVALUES_ON_BUSINESS = 'validateNullFieldValuesOnBusiness';
    private static final String SERVICE_METHOD_VALIDATE_POSINTEGRATION = 'validatePOSIntegrationFields';
    private static final String SERVICE_METHOD_VALIDATE_PDOA = 'validatePDOA';
    private static final String SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND = 'validatePDOAOnWeekend';
    private static final String SERVICE_METHOD_VALIDATE_PDOT = 'validateProposedDateOfTablet';
    private static final String SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOL = 'validateShoppingProtocol';
    private static final String SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOLBLANK = 'validateShoppingProtocolBlankOnRxMenuUIType';
    private static final String SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOLMANDATORY = 'validateShoppingProtocolMandatoryOnRetailMenuUIType';
    private static final String SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER = 'validateStoreAccountFieldValueMatchWithParentWorkOrderFieldValue';
    private static final String SERVICE_METHOD_VALIDATE_TAXID_BY_SHOPPING_PROTOCOL = 'validateTaxIdByShoppingProtocol';
    private static final String SERVICE_METHOD_VALIDATE_MATCHING_BUSINESS_REF_EXITS = 'validateMatchingBusinessReferenceExists';
    private static final String SERVICE_METHOD_VALIDATE_ACCESSIBILITIES = 'validateAccessibilities';
    private static final String SERVICE_METHOD_VALIDATE_ACCOUNT_ORDER_PROTOCOL_FOR_PRINTER = 'validateOrderProtocolForPrinter';
    private static final String SERVICE_METHOD_VALIDATE_STOREFRONT_WEBSITE_BLANK = 'validateStoreAccountStorefrontWebsiteIsPopulatedWhenStorefrontMxhasWebsiteIsYesForSmbAccount';
    private static final String SERVICE_METHOD_VALIDATE_MENU_URL_BLANK = 'validateStoreAccountMenuUrlPopulatedWhenOrderProtocolNotPosForSmbAccount';
    private static final String STOREFRONT_WEBSITE_DUMMY = 'www.abcdummy.com';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POSTSALES = 'Post-Sales';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String SUB_TYPE_MENU_UPDATES = 'Menu Updates';
    private static final String VERTICAL = 'Rx';
    private static final String VERTICAL_FLORAL = 'Floral';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';
    private static final String WORKORDER_OBJECT_NAME = 'WorkOrder';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';

    /**
     * @description To test Readiness Check Failures creation
     * when Account 'Menu to be Completed By' field equals 'Account Owner'
     * and Activated Centrally equals 'Yes'.
     */
    @isTest
    private static void testWhenValidateActivatedCentrallyThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
            )
        };

        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Menu to be Completed By' field is null for Marketplace Work Order.
     */
    @isTest
    private static void testWhenNullActivatedCentrallyOnStoretWithMarketplaceTypeThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_TYPE,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of Change Ownership Effective Date field
     * on store Account having COO Work Order type.
     */
    @isTest
    private static void testWhenValidateChangeOwnershipDateThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED,
                        FIELD_LABEL_CHANGE_OWNERSHIP_DATE,
                        SERVICE_METHOD_VALIDATE_COOED,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                ),
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            WORKORDER_TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Change_of_Ownership_Effective_Date__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Sub_Type__c, TYPE_COO)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when store Account's
     * 'Change Ownership Effective Date' occurs on weekend for COO Work Order type.
     */
    @isTest
    private static void testWhenStoreAccountCOOEDOnWeekendWithCOOWorkOrderTypeThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED_ON_WEEKEND,
                        FIELD_LABEL_CHANGE_OWNERSHIP_DATE,
                        SERVICE_METHOD_VALIDATE_COOED_ON_WEEKEND,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                ),
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            WORKORDER_TYPE_DRIVE
                                        )
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Change_of_Ownership_Effective_Date__c, Date.newInstance(2122, 1, 4))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Sub_Type__c, TYPE_COO)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created
     * when 'Change Ownership Effective Date' and 'Proposed Date of Activation'
     * occurs on weekday in future.
     */
    @isTest
    private static void testWhenStoreAccountCOOEDAndPDOAOnFutureWeekdayThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_COOED_ON_WEEKEND,
                        FIELD_LABEL_CHANGE_OWNERSHIP_DATE,
                        SERVICE_METHOD_VALIDATE_COOED_ON_WEEKEND,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_CHANGE_OWNERSHIP_DATE
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        DEVELOPER_NAME_VALIDATE_PDOA
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                ),
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Change_of_Ownership_Effective_Date__c, Date.newInstance(2122, 1, 1))
            .setField(Account.Proposed_Date_of_Activation__c, Date.newInstance(2122, 1, 1))
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        Map<String, Map<String, Set<String>>> readinessValidationRuleTypeSubTypes = new Map<String, Map<String, Set<String>>>{
            DEVELOPER_NAME_VALIDATE_PDOA => new Map<String, Set<String>>{
                TYPE_COO => new Set<String>()
            }
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRules[1].DeveloperName,
                    workOrder
                )
            )
            .thenReturn(true);
        mocks.when(
                mockReadinessValidationRulesService.collectReadinessValidationRuleMappings(
                    storeReadinessValidationRules
                )
            )
            .thenReturn(readinessValidationRuleTypeSubTypes);
        mocks.when(
                mockReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
                    readinessValidationRuleTypeSubTypes,
                    storeReadinessValidationRules[0],
                    workOrder
                )
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        // PDOA and COOED occurs on a weekday in future, no Readiness Check Failures created.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when store Account's
     * 'Menu to be Completed By' field is null for Work Order Marketplace type.
     */
    @isTest
    private static void testWhenNullMenuCompletedByOnStoreWithMarketplaceWorkOrderTypeThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_COMPLETED_BY,
                        FIELD_LABEL_MENU_COMPLETED_BY,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MENU_COMPLETED_BY
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Menu_to_be_Completed_By__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when businessAccount 'Menu UI Type' field is null for Floral primary vertical.
     */
    @isTest
    private static void testWhenNullMenuUITypeOnStoreWithMarketplaceWorkOrderTypeThenThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_UI_TYPE,
                        FIELD_LABEL_MENU_UI_TYPE,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MENU_UI_TYPE
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Menu_UI_Type__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = storeAccount.Id
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when store Account's
     * 'Merchant Supplied Id' field does not match with POS Integration Id when:
     * 1. Work Order Type is Marketplace or COO
     * 2. Menu UI Type is Retail and
     * 3. POS Integration Type is not non_integrated_mx or local_grocery
     */
    @isTest
    private static void testWhenMerchantSuppliedIdAndPOSIntegrationIdDoesNotMatchThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MERCHANT_SUPPLIED_ID,
                        FIELD_LABEL_MERCHANT_SUPPLIED_ID,
                        SERVICE_METHOD_VALIDATE_MSID,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MERCHANT_SUPPLIED_ID
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Account.Merchant_Supplied_ID__c, 456)
            .setField(Account.POS_Integration_ID__c, 123)
            .setField(Account.POS_Integration_Type__c, POS_INTEGRATION_TYPE_FUTUREPOS)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created when store Account's
     * 'Merchant Supplied Id' field matches with POS Integration Id for criteria:
     * 1. Work Order Type is Marketplace or COO
     * 2. Menu UI Type is Retail and
     * 3. POS Integration Type is non_integrated_mx
     */
    @isTest
    private static void testWhenPOSIntegrationTypeIsNonIntegratedMxThenReadinessCheckFailureNotCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MERCHANT_SUPPLIED_ID,
                        FIELD_LABEL_MERCHANT_SUPPLIED_ID,
                        SERVICE_METHOD_VALIDATE_MSID,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MERCHANT_SUPPLIED_ID
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Account.Merchant_Supplied_ID__c, 456)
            .setField(Account.POS_Integration_ID__c, 123)
            .setField(Account.POS_Integration_Type__c, POS_INTEGRATION_TYPE_NON_INTEGRATED_MX)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when store Account's 'Minimum Prep Time' field is null for Floral primary vertical.
     */
    @isTest
    private static void testWhenValidateMinimumPrepTimeThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MIN_PREP_TIME,
                        FIELD_LABEL_MIN_PREP_TIME,
                        SERVICE_METHOD_VALIDATE_MINPREPTIME,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MIN_PREP_TIME
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL_FLORAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Minimum_Prep_Time__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Account has configured fields with null value.
     */
    @isTest
    private static void testWhenValidateNullValuesThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_HOURS_OF_OPERATION,
                        FIELD_LABEL_HOURS_OF_OPERATION,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_HOURS_OF_OPERATION
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_LEGAL_BUSINESS_NAME,
                        FIELD_LABEL_LEGAL_BUSINESS_NAME,
                        SERVICE_METHOD_VALIDATE_NULLVALUES_ON_BUSINESS,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_LEGAL_BUSINESS_NAME
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PHONE,
                        FIELD_LABEL_PHONE,
                        SERVICE_METHOD_VALIDATE_NULLVALUES_ON_STORE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PHONE)
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_LEGAL_BUSINESS_NAME,
                        FIELD_LABEL_LEGAL_BUSINESS_NAME,
                        SERVICE_METHOD_VALIDATE_NULLVALUES_ON_STORE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_LEGAL_BUSINESS_NAME
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, null)
            .setField(Account.Phone, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Hours_of_Operation__c, null)
            .setField(Account.Phone, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.ParentWorkOrderId,
                Account_Name__c = parentAccount.Id
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[2].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[2].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[2].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[3].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[3].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[3].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order Type is 'Marketplace' Or 'COO' and Account's Order Protocol is not populated.
     */
    @isTest
    private static void testWhenNullOrderProtocolOnStoreWithCOOWorkOrderTypeThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ORDER_PROTOCOL,
                        FIELD_LABEL_ORDER_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ORDER_PROTOCOL
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        storeReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when for store Account's POS integration related fields.
     */
    @isTest
    private static void testWhenValidatePOSIntegrationsThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_POS_INTEGRATION_ID,
                        FIELD_LABEL_POS_INTEGRATION_ID,
                        SERVICE_METHOD_VALIDATE_POSINTEGRATION,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_POS_INTEGRATION_ID
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_POS_INTEGRATION_TYPE,
                        FIELD_LABEL_POS_INTEGRATION_TYPE,
                        SERVICE_METHOD_VALIDATE_POSINTEGRATION,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_POS_INTEGRATION_TYPE
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.POS_Integration_ID__c, null)
            .setField(Account.POS_Integration_Type__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when store Account's
     * PDOA is less then 4 days from future.
     */
    @isTest
    private static void testWhenValidatePDOAThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        DEVELOPER_NAME_VALIDATE_PDOA
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, System.today().addDays(3))
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        Map<String, Map<String, Set<String>>> readinessValidationRuleTypeSubTypes = new Map<String, Map<String, Set<String>>>{
            DEVELOPER_NAME_VALIDATE_PDOA => new Map<String, Set<String>>{
                TYPE_COO => new Set<String>()
            }
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockReadinessValidationRulesService.collectReadinessValidationRuleMappings(
                    storeReadinessValidationRules
                )
            )
            .thenReturn(readinessValidationRuleTypeSubTypes);
        mocks.when(
                mockReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
                    readinessValidationRuleTypeSubTypes,
                    storeReadinessValidationRules[0],
                    workOrder
                )
            )
            .thenReturn(storeReadinessValidationRules[0]);
        mocks.when(
                mockReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRules[0].DeveloperName,
                    workOrder
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when store Account's
     * 'Proposed Date Of Activation' occurs on weekend.
     */
    @isTest
    private static void testWhenStoreAccountsPDOAOnWeekendThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PDOA_ON_WEEKEND,
                        FIELD_LABEL_PDOA,
                        SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_PDOA)
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.DeveloperName,
                        DEVELOPER_NAME_VALIDATE_PDOA
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Proposed_Date_of_Activation__c, Date.newInstance(2122, 1, 4))
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        Map<String, Map<String, Set<String>>> readinessValidationRuleTypeSubTypes = new Map<String, Map<String, Set<String>>>{
            DEVELOPER_NAME_VALIDATE_PDOA => new Map<String, Set<String>>{
                TYPE_COO => new Set<String>()
            }
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockReadinessValidationRulesService.collectReadinessValidationRuleMappings(
                    storeReadinessValidationRules
                )
            )
            .thenReturn(readinessValidationRuleTypeSubTypes);
        mocks.when(
                mockReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
                    readinessValidationRuleTypeSubTypes,
                    storeReadinessValidationRules[0],
                    workOrder
                )
            )
            .thenReturn(storeReadinessValidationRules[0]);
        mocks.when(
                mockReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRules[0].DeveloperName,
                    workOrder
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation with incorrect value
     * for 'Shopping Protocol' field related validations on store Account.
     */
    @isTest
    private static void testWhenValidateShoppingProtocolThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_SHOPPING_PROTOCOL,
                        FIELD_LABEL_SHOPPING_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOL,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_SHOPPING_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, MX_PICK_SHOPPING_PROTOCOL)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation when Shopping Protocol is null
     * on store Account when Menu UI Type is Retail.
     */
    @isTest
    private static void testWhenValidateShoppingProtocolRequiredThenCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_SHOPPING_PROTOCOL_REQUIRED,
                        FIELD_LABEL_SHOPPING_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOLMANDATORY,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_SHOPPING_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Shopping_Protocol__c, null)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of Tax Id field when custom metadata
     * records and WorkOrders are received with shopping protocol as blank.
     */
    @isTest
    private static void testWhenValidateTaxIdByShoppingProtocolNotAsShopperPickAndDasherPickThenCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_TAX_ID,
                        FIELD_LABEL_TAX_ID,
                        SERVICE_METHOD_VALIDATE_TAXID_BY_SHOPPING_PROTOCOL,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_TAX_ID)
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.TaxID__c, null)
            .setField(Account.Segment__c, SEGMENT_SMB);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of Tax Id field when custom metadata
     * records and WorkOrders with segment Enterprise are received with shopping protocol as blank.
     */
    @isTest
    private static void testWhenValidateTaxIdByShoppingProtocolNotAsShopperPickAndDasherPickForEnterpriseThenCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_TAX_ID,
                        FIELD_LABEL_TAX_ID,
                        SERVICE_METHOD_VALIDATE_TAXID_BY_SHOPPING_PROTOCOL,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_TAX_ID)
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.TaxID__c, null)
            .setField(Account.Segment__c, SEGMENT_ENTERPRISE);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Segment__c, SEGMENT_ENTERPRISE)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test readiness check validation of Tax Id field
     * not invoked when work orders received has store account with shopping protocol field's value
     * as 'Dasher Pick'.
     */
    @isTest
    private static void testWhenValidateTaxIdWithShoppingProtocolAsDasherPickThenDoNotCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_TAX_ID,
                        FIELD_LABEL_TAX_ID,
                        SERVICE_METHOD_VALIDATE_TAXID_BY_SHOPPING_PROTOCOL,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_TAX_ID)
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.TaxID__c, null);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when Account's
     * configured field values not matches with Marketplace parent Work Order field values.
     */
    @isTest
    private static void testWhenStoreAccountFieldValuesDoesNotMatchWithMarketplaceParentWorkOrderFieldValuesThenReadinessCheckFailuresCreated() {
        Id activatedCentrallyReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id mtbcReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id orderProtocolReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_WORK_ORDER,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        activatedCentrallyReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    activatedCentrallyReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_COMPLETED_BY_WORK_ORDER,
                        FIELD_LABEL_MENU_COMPLETED_BY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MENU_COMPLETED_BY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        mtbcReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    mtbcReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ORDER_PROTOCOL_WORK_ORDER,
                        FIELD_LABEL_ORDER_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ORDER_PROTOCOL
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        orderProtocolReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    orderProtocolReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, null)
            .setField(Account.Phone, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRules[2].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[2].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[2].Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created for ‘Shopping Protocol’ field
     * when store Account satisfied the ShoppingProtocol criteria.
     */
    @isTest
    private static void testWhenStoreSatisfiesShoppingProtocolCriteriaThenReadinessCheckFailuresNotCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_SHOPPING_PROTOCOL,
                        FIELD_LABEL_SHOPPING_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOL,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_SHOPPING_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when 'Delay Tablet Shipment' is 'Yes' and PDOT is not populated on store Account
     * with 'Marketplace' Work Order.
     */
    @isTest
    private static void testWhenTabletShipmentDelayedOnStoreAccountWithBlankPDOTOnMarketPlaceWorkOrderThenReadinessCheckFailureCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Delay_Tablet_Shipment__c, DELAY_TABLET_SHIPMENT_YES)
            .setField(Account.Proposed_Date_of_Tablet__c, null);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c, true)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_PDOT,
                    FIELD_LABEL_PDOT,
                    SERVICE_METHOD_VALIDATE_PDOT,
                    ACCOUNT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
                .setField(Store_Readiness_Validation_Rule__mdt.Id, storeReadinessValidationRuleId)
                .setChildren(
                    'ReadinessValidationSobjectTypeBindings__r',
                    new List<Fake>{
                        new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                            .setField(
                                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                storeReadinessValidationRuleId
                            )
                            .setField(
                                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                sobjectTypeSubTypeMappingId
                            )
                            .setParent(
                                'Sobject_Type_Sub_Type_Mapping__r',
                                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                    .setField(
                                        Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                        WORKORDER_TYPE_MARKETPLACE
                                    )
                            )
                    }
                )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOT;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created
     * when 'Delay Tablet Shipment' is 'No' and PDOT is not populated on store Account.
     */
    @isTest
    private static void testWhenTabletShipmentNotDelayedOnStoreAccountWithBlankPDOTThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Delay_Tablet_Shipment__c, DELAY_TABLET_SHIPMENT_NO)
            .setField(Account.Proposed_Date_of_Tablet__c, null);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c, false)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                ERROR_MESSAGE_PDOT,
                FIELD_LABEL_PDOT,
                SERVICE_METHOD_VALIDATE_PDOT,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created
     * when 'Delay Tablet Shipment' is 'Yes' and PDOT is populated on store Account.
     */
    @isTest
    private static void testWhenTabletShipmentDelayedOnStoreAccountHavingPDOTThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Delay_Tablet_Shipment__c, DELAY_TABLET_SHIPMENT_NO)
            .setField(Account.Proposed_Date_of_Tablet__c, null);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c, false)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(5));
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                ERROR_MESSAGE_PDOT,
                FIELD_LABEL_PDOT,
                SERVICE_METHOD_VALIDATE_PDOT,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures created when "Shopping Protocol" field
     * is populated on store Account having "Menu UI Type" as Restaurant.
     */
    @isTest
    private static void testWhenStoreAccountWithShoppingProtocolHavingRxMenuUITypeThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_SHOPPING_PROTOCOL_BLANK,
                        FIELD_LABEL_SHOPPING_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOLBLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_SHOPPING_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, MX_PICK_SHOPPING_PROTOCOL)
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RESTAURANT)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created when "Shopping Protocol" field
     * is blank on store Account having "Menu UI Type" as Restaurant.
     */
    @isTest
    private static void testWhenStoreAccountWithBlankShoppingProtocolHavingRxMenuUITypeThenReadinessCheckFailuresNotCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_SHOPPING_PROTOCOL_BLANK,
                        FIELD_LABEL_SHOPPING_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_SHOPPINGPROTOCOLBLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_SHOPPING_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Menu_UI_Type__c, MENU_UI_TYPE_RESTAURANT);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Shopping_Protocol__c, null)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when Account's
     * configured field values not matches with COO parent Work Order field values.
     */
    @isTest
    private static void testWhenStoreAccountFieldValuesDoesNotMatchWithCOOParentWorkOrderFieldValuesThenReadinessCheckFailuresCreated() {
        Id activatedCentrallyReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id mtbcReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id orderProtocolReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_WORK_ORDER,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        activatedCentrallyReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    activatedCentrallyReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_COMPLETED_BY_WORK_ORDER,
                        FIELD_LABEL_MENU_COMPLETED_BY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MENU_COMPLETED_BY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        mtbcReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    mtbcReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ORDER_PROTOCOL_WORK_ORDER,
                        FIELD_LABEL_ORDER_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ORDER_PROTOCOL
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        orderProtocolReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    orderProtocolReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, null)
            .setField(Account.Phone, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = childWorkOrder.AccountId,
                Child_Work_Order__c = childWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = childWorkOrder.AccountId,
                Child_Work_Order__c = childWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = childWorkOrder.AccountId,
                Child_Work_Order__c = childWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRules[2].Error_Message__c,
                Field_Name__c = storeReadinessValidationRules[2].Field_Label__c,
                Object_Name__c = storeReadinessValidationRules[2].Object_Label__c,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created when Account's
     * configured field values not matches with Drive parent Work Order field values.
     */
    @isTest
    private static void testWhenStoreAccountFieldValuesDoesNotMatchWithDriveParentWorkOrderFieldValuesThenReadinessCheckFailuresNotCreated() {
        Id activatedCentrallyReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id mtbcReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id orderProtocolReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACTIVATED_CENTRALLY_WORK_ORDER,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACTIVATED_CENTRALLY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        activatedCentrallyReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    activatedCentrallyReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_COMPLETED_BY_WORK_ORDER,
                        FIELD_LABEL_MENU_COMPLETED_BY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_MENU_COMPLETED_BY
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        mtbcReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    mtbcReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ORDER_PROTOCOL_WORK_ORDER,
                        FIELD_LABEL_ORDER_PROTOCOL,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_FIELD_VALUE_MATCH_WITH_WORK_ORDER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ORDER_PROTOCOL
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Id,
                        orderProtocolReadinessValidationRuleId
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    orderProtocolReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, null)
            .setField(Account.Phone, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test validation of 'Duplicate Status' field on store Account with Unverified
     * value when custom metadata records and Work Orders are received.
     */
    @isTest
    private static void testWhenValidateDuplicateStatusOnStoreAccountThenCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_DUPLICATE_STATUS,
                        FIELD_LABEL_DUPLICATE_STATUS,
                        SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_STORE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_DUPLICATE_STATUS
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Duplicate_Status__c, DUPLICATE_STATUS_UNVERIFIED)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of 'Duplicate Status' field on store Account with
     * Non-Duplicate value when custom metadata records and Work Orders are received.
     */
    @isTest
    private static void testWhenValidateNonDuplicateStatusOnStoreAccountThenReadinessFailureRecordsNotCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_DUPLICATE_STATUS,
                        FIELD_LABEL_DUPLICATE_STATUS,
                        SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_STORE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_DUPLICATE_STATUS
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Duplicate_Status__c, DUPLICATE_STATUS_NON_DUPLICATE)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test validation of 'Duplicate Status' field on business and store Account
     * with Duplicate value when custom metadata records and Work Orders are received.
     */
    @isTest
    private static void testWhenValidateDuplicateStatusOnBusinessAndStoreAccountThenCreateReadinessFailureRecords() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_DUPLICATE_STATUS,
                        FIELD_LABEL_DUPLICATE_STATUS,
                        SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_STORE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_DUPLICATE_STATUS
                    )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_DUPLICATE_STATUS,
                        FIELD_LABEL_DUPLICATE_STATUS,
                        SERVICE_METHOD_VALIDATE_DUPLICATE_STATUS_ON_BUSINESS,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_DUPLICATE_STATUS
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Duplicate_Status__c, DUPLICATE_STATUS_DUPLICATE);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Duplicate_Status__c, DUPLICATE_STATUS_DUPLICATE)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure for Tax Id field on Business Account not created
     * when custom metadata records and Drive parent Work Order received.
     */
    @isTest
    private static void testWhenValidateTaxIdForDriveTypeThenReadinessFailureRecordsNotCreated() {
        Id taxIdReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_TAX_ID,
                        FIELD_LABEL_TAX_ID,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_TAX_ID)
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    taxIdReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.TaxID__c, null);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        // Readiness check failure is not created for Drive Work Order Type.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Brand is not linked to Store associated with Marketplace Work Order.
     */
    @isTest
    private static void testWhenBrandNotAssociatedOnStoreForMarketplaceThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_BRAND_NOT_ASSOCIATED,
                        FIELD_LABEL_BRAND,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_BRAND)
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Brand is not linked to Store associated with COO Work Order.
     */
    @isTest
    private static void testWhenBrandNotAssociatedOnStoreForCOOThenReadinessCheckFailuresCreated() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_BRAND_NOT_ASSOCIATED,
                        FIELD_LABEL_BRAND,
                        SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, FIELD_NAME_BRAND)
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_COO
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test Readiness Check Failures creation
     * When matching bizref not found for the account then throw validation.
     */
    @isTest
    private static void testWhenMatchingBusinessrefnotFoundThenReturnReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_BUSINESS_REF_NOT_FOUND,
                        FILED_NAME_NAME,
                        SERVICE_METHOD_VALIDATE_MATCHING_BUSINESS_REF_EXITS,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, 'Name')
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefAndBizRefMatchingService xrefBizRefMatchingService = (IXrefAndBizRefMatchingService) mocks.mock(
            IXrefAndBizRefMatchingService.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<String>{ storeAccount.Id }))
            .thenReturn(null);
        mocks.when(xrefBizRefMatchingService.findMatchingBizRefForReadinesCheck(null))
            .thenReturn(
                new Map<Id, String>{ storeAccount.Id => ERROR_MESSAGE_BUSINESS_REF_NOT_FOUND }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IXrefAndBizRefMatchingService.class, xrefBizRefMatchingService);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test Readiness Check Failures creation
     * When the 'Accessibilities' field is blank or null for a store account in the Seattle region, create a readiness check failure message.
     */
    @isTest
    private static void testWhenAccessibilitiesisNotOnStoreThenReadinessCheckFailuresCreated() {
        String billingPostalCode = '98134';
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ACCESSIBILITIES,
                        FIELD_LABEL_ACCESSIBILITIES,
                        SERVICE_METHOD_VALIDATE_ACCESSIBILITIES,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ACCESSIBILITIES
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.Accessibilities__c, null)
            .setField(Account.BillingPostalCode, billingPostalCode)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test Readiness Check Failures Bypass
     * When matching bizref not found for the account where segment is SMB then bypass validation.
     */
    @isTest
    private static void testWhenSegmentSmbAndMatchingBusinessrefnotFoundThenBypassReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_BUSINESS_REF_NOT_FOUND,
                        FILED_NAME_NAME,
                        SERVICE_METHOD_VALIDATE_MATCHING_BUSINESS_REF_EXITS,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(Store_Readiness_Validation_Rule__mdt.Field_Name__c, 'Name')
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefAndBizRefMatchingService xrefBizRefMatchingService = (IXrefAndBizRefMatchingService) mocks.mock(
            IXrefAndBizRefMatchingService.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<String>{ storeAccount.Id }))
            .thenReturn(null);
        mocks.when(xrefBizRefMatchingService.findMatchingBizRefForReadinesCheck(null))
            .thenReturn(new Map<Id, String>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IXrefAndBizRefMatchingService.class, xrefBizRefMatchingService);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /** @JIRA LEM-14284
     * @description To test Readiness Check Failures for Order Protocol contains Printer for store account
     * **/
    @isTest
    private static void testWhenStoreAccountOrderProtocolAndOtherValuesdoesNotMatchThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_ORDER_PROTOCOL_PRINTER,
                        FIELD_LABEL_ACTIVATED_CENTRALLY,
                        SERVICE_METHOD_VALIDATE_ACCOUNT_ORDER_PROTOCOL_FOR_PRINTER,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_ORDER_PROTOCOL
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setChildren(
                'Mx_Tags_Association__r',
                new List<Fake>{ new Fake(Mx_Tag_Association__c.class).setFakeId() }
            );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Order_Protocol__c, SELECTED_ORDER_PROTOCOL)
            .setField(Account.Segment__c, SELECTED_SEGMENT)
            .setField(Account.Deck_Rank__c, SELECTED_DECK_RANK)
            .setField(Account.Experience__c, SELECTED_EXPERIENCE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setField(WorkOrder.Order_Protocol__c, SELECTED_ORDER_PROTOCOL)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsWithMxTagAssociation(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * When Menu URL is blank on Store Account for Segment = SMB.
     */
    @isTest
    private static void testWhenMenuUrlBlankThenCreatesReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_URL_BLANK,
                        FIELD_LABEL_MENU_URL,
                        SERVICE_METHOD_VALIDATE_MENU_URL_BLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FILED_NAME_MENU_URL
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, SEGMENT_SMB);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To Negative test Readiness Check Failures creation
     * When Menu URL is blank And Order Protocol is POS on Store Account for Segment = SMB.
     */
    @isTest
    private static void testWhenMenuUrlBlankOrderPRotocolPosThenNotCreatesReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_MENU_URL_BLANK,
                        FIELD_LABEL_MENU_URL,
                        SERVICE_METHOD_VALIDATE_MENU_URL_BLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FILED_NAME_MENU_URL
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_MARKETPLACE
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, SEGMENT_SMB);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
    /**
     * @description To test Readiness Check Failures creation
     * When Storefront Mx Has Website? = Yes and Storefront Website blank on Store Account for Segment = SMB.
     */
    @isTest
    private static void testWhenStorefrontWebsiteBlankThenCreatesReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_STOREFRONT_WEBSITE_BLANK,
                        FIELD_LABEL_STOREFRONT_WEBSITE,
                        SERVICE_METHOD_VALIDATE_STOREFRONT_WEBSITE_BLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_STOREFRONT_WEBSITE
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_STOREFRONT
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, SEGMENT_SMB);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.Storefront_Mx_Has_Website__c, HAS_STOREFRONT_WEBSITE_YES)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To Negative test Readiness Check Failures creation
     * When Storefront Mx Has Website? = Yes and Storefront Website not blank on Store Account for Segment = SMB.
     */
    @isTest
    private static void testWhenStorefrontWebsiteNotBlankThenNotCreatesReadinessCheckFailures() {
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_STOREFRONT_WEBSITE_BLANK,
                        FIELD_LABEL_STOREFRONT_WEBSITE,
                        SERVICE_METHOD_VALIDATE_STOREFRONT_WEBSITE_BLANK,
                        ACCOUNT_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_NAME_STOREFRONT_WEBSITE
                    )
                    .setChildren(
                        'ReadinessValidationSobjectTypeBindings__r',
                        new List<Fake>{
                            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                                    storeReadinessValidationRuleId
                                )
                                .setField(
                                    ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                                    sobjectTypeSubTypeMappingId
                                )
                                .setParent(
                                    'Sobject_Type_Sub_Type_Mapping__r',
                                    new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                                        .setField(
                                            Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                                            TYPE_STOREFRONT
                                        )
                                )
                        }
                    )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, SEGMENT_SMB);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setField(Account.Storefront_Mx_Has_Website__c, HAS_STOREFRONT_WEBSITE_YES)
            .setField(Account.Storefront_Website__c, STOREFRONT_WEBSITE_DUMMY)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_TO_BE_COMPLETED_BY_MERCHANT)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_CONTAINS_POS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_YES)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance);
        WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        AccountValidationsServiceImpl accountValidationsSrvcImplInstance = new AccountValidationsServiceImpl();
        accountValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}