/**
 * @author Deloitte
 * @date 07/12/2022
 * @description Test class for WorkOrderValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class WorkOrderValidationsServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACTIVATE_CENTRALLY_YES = 'Yes';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_ACTIVATED_CENTRALLY = 'Please ensure Activate Centrally (AC) is populated as No.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_ACTIVATED_CENTRALLY_EMPTY = 'Please ensure Activate Centrally (AC) is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_CONTRACTONMARKETPLACE = 'Please ensure Contract is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_MENU_TO_BE_COMPLETED_BY = 'Please populate “Menu to be Completed By” as Marketplace type is selected.';
    private static final String CUSTOM_METADATA_ERROR_NUMBER_OF_STORES = 'The number of stores on the Work Order is greater than the number of stores quoted on the contract. Please use the “Remove Stores” button to remove any stores that are not applicable for ads & promos and re-run Readiness Check.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_ORDER_PROTOCOL = 'Please ensure Order Protocol is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOA = 'Please ensure the PDOA, PDOM, PDOT do not occur in the past.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOA_ON_WEEKEND = 'Please ensure the Proposed Date of Activation is not on a Saturday or Sunday.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOA_EMPTY = 'PDOA is required for Marketplace and COO Work Orders.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOM = 'Please ensure the Proposed Date of Menu does not occur in the past. The Proposed Date of Activation cannot occur in the past and must be set to at least 4 business days into the future.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOT = 'Please ensure Proposed Date of Tablet is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PDOT_IN_PAST = 'Please ensure the PDOA, PDOT do not occur in the past. The Proposed Date of Activation must be set to at least 4 business days into the future.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_PROVISIONING_PROCESS_EMPTY = 'Please ensure Provisioning Process is indicated as automated or manual.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_STAGE = 'Please ensure the opportunity on the work order is Closed/Won.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL = 'Please ensure that a valida Google Sheet URL is populated on WorkOrder';
    private static final String ERROR_MESSAGE_ACTIVATE_CENTRALLY_NO = 'Activate Centrally (AC) = No is not available for SMB Mxs. Please update Activate Centrally (AC) = Yes on the Work Order.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_BUSINESS_ID = 'There is no Business ID in Salesforce matching the Business ID provided. Please ensure the correct Business ID is provided or if a new Business ID needs to be created, delete the value from this field.';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_MPBZID = 'Please ensure associated Opportunity has MP Biz Id configured, as this is a Drive Withholding Mx';
    private static final String FIELD_LABEL_ACTIVATED_CENTRALLY = 'Activated Centrally (AC)';
    private static final String FIELD_LABEL_BUSINESS_ID = 'Business Id';
    private static final String FIELD_LABEL_CONTRACTONMARKETPLACE = 'Contract';
    private static final String FIELD_LABEL_MENU_TO_BE_COMPLETED_BY = 'Menu to be Completed By';
    private static final String FIELD_LABEL_NUMBER_OF_STORES = 'Actual Number Of Stores';
    private static final String FIELD_LABEL_ORDER_PROTOCOL = 'Order Protocol';
    private static final String FIELD_LABEL_PDOA = 'Proposed Date of Activation';
    private static final String FIELD_LABEL_PDOM = 'Proposed Date of Menu';
    private static final String FIELD_LABEL_PDOT = 'Proposed Date of Tablet';
    private static final String FIELD_LABEL_PROVISIONING_PROCESS = 'Provisioning Process';
    private static final String FIELD_LABEL_OPPORTUNITY = 'Opportunity';
    private static final String FIELD_LABEL_GOOGLE_SHEET_URL = 'Google Sheet URL';
    private static final String FIELD_LABEL_MPBZID = 'MP Bz Id';
    private static final String FIELD_NAME_MPBZID = 'MP_Bz_Id__c';
    private static final String FIELD_NAME_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String FIELD_NAME_BUSINESS_ID = 'Business_Id__c';
    private static final String FIELD_NAME_MENU_TO_BE_COMPLETED_BY = 'Menu_to_be_Completed_By__c';
    private static final String FIELD_NAME_NUMBER_OF_STORES = 'Actual_Number_Of_Stores__c';
    private static final String FIELD_NAME_ORDER_PROTOCOL = 'Order_Protocol__c';
    private static final String FIELD_NAME_PDOA = 'Proposed_Date_of_Activation__c';
    private static final String FIELD_NAME_PDOM = 'Proposed_Date_of_Menu__c';
    private static final String FIELD_NAME_PDOT = 'Proposed_Date_of_Tablet__c';
    private static final String FIELD_NAME_PROVISIONING_PROCESS = 'Business_to_Store_Assignment__c';
    private static final String FIELD_NAME_OPPORTUNITY = 'Opportunity__c';
    private static final String FIELD_NAME_GOOGLE_SHEET_URL = 'Google_Sheet_URL__c';
    private static final String INTEGRATED_FRANCHISE = 'Integrated Franchise';
    private static final String INVALID_GOOGLE_SHEET_URL = 'mock.com';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String MOCK_BUSINESS_ID = 'mockId';
    private static final String MOCK_EXTERNAL_ID = 'mockExternalId';
    private static final String MOCK_USER_ALIAS = 'MockUser';
    private static final String MOCK_USER_EMAIL_ID = 'mockUser@WorkOrderValidationsServiceImpl.com';
    private static final String MOCK_USER_FIRST_NAME = 'Sherlock';
    private static final String MOCK_USER_LAST_NAME = 'Holmes';
    private static final String MOCK_USER_NAME = 'Sherlock Holmes';
    private static final String MOCK_USER_USERNAME = 'mockUser@WorkOrderValidationsServiceImpl.com.test';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String OPPORTUNITY_NAME = 'Opportunity Readiness Check';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String SERVICE_CLASS_NAME = 'IWorkOrderValidationsService';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY = 'validateActivateCentrally';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY_NOT_EMPTY = 'validateActivateCentrallyOnMarketplaceAndCOO';
    private static final String SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL = 'validateGoogleSheetURL';
    private static final String SERVICE_METHOD_VALIDATE_CONTRACTONMARKETPLACE = 'validateContractOnMarketplace';
    private static final String SERVICE_METHOD_VALIDATE_VALIDATEBUSINESSID = 'validateBusinessId';
    private static final String SERVICE_METHOD_VALIDATE_MENU_TO_BE_COMPLETED_BY = 'validateMenuToBeCompletedBy';
    private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES = 'validateNullFieldValues';
    private static final String SERVICE_METHOD_VALIDATE_NUMBER_OF_STORES = 'validateNumberOfStores';
    private static final String SERVICE_METHOD_VALIDATE_ORDER_PROTOCOL = 'validateOrderProtocol';
    private static final String SERVICE_METHOD_VALIDATE_PDOA = 'validatePDOA';
    private static final String SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND = 'validatePDOAOnWeekend';
    private static final String SERVICE_METHOD_VALIDATE_PDOA_NOT_EMPTY = 'validatePDOAOnMarketplaceAndCOO';
    private static final String SERVICE_METHOD_VALIDATE_PDOM = 'validateProposedDateOfMenu';
    private static final String SERVICE_METHOD_VALIDATE_PDOT = 'validateProposedDateOfTablet';
    private static final String SERVICE_METHOD_VALIDATE_PDOT_IN_PAST = 'validateProposedDateOfTabletInPast';
    private static final String SERVICE_METHOD_OPPORTUNITY_REQUIRED_STAGE = 'validateOpportunityStage';
    private static final String SERVICE_METHOD_OPPORTUNITY_MPBZID = 'validateMPBZIdOnDriveWithholding';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'America/Los_Angeles';
    private static final String VERTICAL_RX = 'Rx';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';
    private static final String VALIDATION_RULE_DEVELOPER_NAME = 'ReadinessValidationRule';
    private static final String WORKORDER_DELAY_TABLET_SHIPMENT_YES = 'Yes';
    private static final String WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String WORKORDER_OBJECT_NAME = 'Work Order';
    private static final String WORKORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORKORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORKORDER_TYPE_COO = 'COO';
    private static final String WORKORDER_TYPE_DRIVE = 'DRIVE';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORKORDER_SUB_TYPE_WITHHOLDING = 'Withholding';
    private static final String PROVISIONING_PROCESS_AUTOMATIC = 'Automatic';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String WORKORDER_OBJECT_API_NAME = 'WorkOrder';

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Menu to be Completed By' field equals 'Account Owner'
     * and Activated Centrally equals 'Yes'.
     */
    @isTest
    private static void testWhenValidateActivateCentrallyThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(
                WorkOrder.Menu_to_be_Completed_By__c,
                WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_ACTIVATED_CENTRALLY,
                FIELD_LABEL_ACTIVATED_CENTRALLY,
                SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_ACTIVATED_CENTRALLY;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order Type is 'Marketplace' Or 'COO' and Activated Centrally is not populated.
     */
    @isTest
    private static void testWhenActivateCentrallyNullThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_ACTIVATED_CENTRALLY_EMPTY,
                    FIELD_LABEL_ACTIVATED_CENTRALLY,
                    SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY_NOT_EMPTY,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_ACTIVATED_CENTRALLY;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Menu to be Completed By' field is null for Marketplace Work Order.
     */
    @isTest
    private static void testWhenMenuToBeCompletedByNullThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_MENU_TO_BE_COMPLETED_BY,
                FIELD_LABEL_MENU_TO_BE_COMPLETED_BY,
                SERVICE_METHOD_VALIDATE_MENU_TO_BE_COMPLETED_BY,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_MENU_TO_BE_COMPLETED_BY;
        storeReadinessValidationRule.Object_Name__c = WORKORDER_OBJECT_API_NAME;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order Type is 'Marketplace' Or 'COO' and Order Protocol is not populated.
     */
    @isTest
    private static void testWhenOrderProtocolNullThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Order_Protocol__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_ORDER_PROTOCOL,
                FIELD_LABEL_ORDER_PROTOCOL,
                SERVICE_METHOD_VALIDATE_ORDER_PROTOCOL,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_ORDER_PROTOCOL;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when PDOA is less than the configured business days limit (current value = 4) from future.
     */
    @isTest
    private static void testWhenWorkOrderPDOAOccursWithinConfiguredBusinessDaysLimitThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(2))
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOA,
                FIELD_LABEL_PDOA,
                SERVICE_METHOD_VALIDATE_PDOA,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOA;
        storeReadinessValidationRule.Object_Name__c = WORKORDER_OBJECT_API_NAME;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order's PDOA occurs on weekend.
     */
    @isTest
    private static void testWhenWorkOrderPDOAOnWeekendThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, Date.newInstance(2122, 1, 4))
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_DRIVE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOA_ON_WEEKEND,
                FIELD_LABEL_PDOA,
                SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOA;
        storeReadinessValidationRule.Object_Name__c = WORKORDER_OBJECT_API_NAME;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created
     * when Work Order's PDOA occurs on weekday in future.
     */
    @isTest
    private static void testWhenWorkOrderPDOAOnFutureWeekdayThenReadinessCheckFailuresNotCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, Date.newInstance(2122, 1, 1))
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOA_ON_WEEKEND,
                FIELD_LABEL_PDOA,
                SERVICE_METHOD_VALIDATE_PDOA_ON_WEEKEND,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOA;

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        // PDOA occurs on a weekday in future, no Readiness Check Failures created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when PDOM occurs in the past.
     */
    @isTest
    private static void testWhenValidatePDOMThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today().addDays(-5))
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOM,
                FIELD_LABEL_PDOM,
                SERVICE_METHOD_VALIDATE_PDOM,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOM;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when 'HasTabletChildWorkPlans' is
     * enabled and PDOT is null on parent Work Order.
     */
    @isTest
    private static void testWhenPDOTNullWithTabletChildWorkPlansOnParentWorkOrderThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c, true)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOT,
                FIELD_LABEL_PDOT,
                SERVICE_METHOD_VALIDATE_PDOT,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOT;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{},
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure is not created when 'HasTabletChildWorkPlans' is
     * disabled and PDOT is null on parent Work Order.
     */
    @isTest
    private static void testWhenPDOTNullWithoutTabletChildWorkPlansOnParentWorkOrderThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.HasTabletWorkPlan__c, false)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOT,
                FIELD_LABEL_PDOT,
                SERVICE_METHOD_VALIDATE_PDOT,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOT;

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{},
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure is not created when 'HasTabletChildWorkPlans' is
     * enabled and PDOT is populated on parent Work Order.
     */
    @isTest
    private static void testWhenPDOTPopulatedWithTabletChildWorkPlansOnParentWorkOrderThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.HasTabletWorkPlan__c, true)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, Date.newInstance(2023, 10, 10));
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOT,
                FIELD_LABEL_PDOT,
                SERVICE_METHOD_VALIDATE_PDOT,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOT;

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{},
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when PDOT occurs in the past on 'Marketplace' Work Order.
     */
    @isTest
    private static void testWhenValidatePDOTOccursInPastOnMarketPlaceWorkOrderThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(-5));
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_PDOT_IN_PAST,
                    FIELD_LABEL_PDOT,
                    SERVICE_METHOD_VALIDATE_PDOT_IN_PAST,
                    WORKORDER_OBJECT_NAME,
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
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order Type is 'Marketplace' and Proposed Date of Activation is not populated.
     */
    @isTest
    private static void testWhenPDOANullOnMarketPlaceWorkOrderThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_PDOA_EMPTY,
                    FIELD_LABEL_PDOA,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_PDOA;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order Type is 'COO' and Activated Centrally &
     * Proposed Date of Activation are not populated.
     */
    @isTest
    private static void testWhenACAndPDOANullOnCOOWorkOrderThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_COO
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, null)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_COO,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidateAC = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_ACTIVATED_CENTRALLY_EMPTY,
                FIELD_LABEL_ACTIVATED_CENTRALLY,
                SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY_NOT_EMPTY,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRuleToValidateAC.Field_Name__c = FIELD_NAME_ACTIVATED_CENTRALLY;
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidatePDOA = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_PDOA_EMPTY,
                FIELD_LABEL_PDOA,
                SERVICE_METHOD_VALIDATE_PDOA_NOT_EMPTY,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRuleToValidatePDOA.Field_Name__c = FIELD_NAME_PDOA;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidateAC.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidateAC.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidateAC.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidatePDOA.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidatePDOA.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidatePDOA.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidateAC,
                storeReadinessValidationRuleToValidatePDOA
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Provisioning Process"
     * is not populated for configured Type Sub-Type mapping.
     */
    @isTest
    private static void testWhenProvisioningProcessIsNullThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Business_to_Store_Assignment__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_COO,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_PROVISIONING_PROCESS_EMPTY,
                    FIELD_LABEL_PROVISIONING_PROCESS,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_PROVISIONING_PROCESS;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidate.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidate.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidate.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Provisioning Process"
     * is not populated with multiple configured Drive Type Sub-Type mappings.
     */
    @isTest
    private static void testWhenProvisioningProcessIsNullWithMultipleConfiguredDriveSubTypesThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Business_to_Store_Assignment__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_SUB_TYPE_AUTO_ACTIVATIONS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_PROVISIONING_PROCESS_EMPTY,
                    FIELD_LABEL_PROVISIONING_PROCESS,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(
                                        Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                        WORKORDER_SUB_TYPE_NET_NEW_BUSINESS
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
                                        WORKORDER_SUB_TYPE_AUTO_ACTIVATIONS
                                    )
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_PROVISIONING_PROCESS;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidate.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidate.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidate.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Type' field equals 'Marketplace'
     * and Contract equals null.
     */
    @isTest
    private static void testWhenValidateContractOnMarketplaceThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(
                WorkOrder.Menu_to_be_Completed_By__c,
                WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_MESSAGE_CONTRACTONMARKETPLACE,
                FIELD_LABEL_CONTRACTONMARKETPLACE,
                SERVICE_METHOD_VALIDATE_CONTRACTONMARKETPLACE,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_ACTIVATED_CENTRALLY;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Opportunity Stage is not 'Closed/Won' on Work Order type is 'Marketplace'.
     */
    @isTest
    private static void testWhenOpportunityStageNotEqualToClosedWonOnParentWorkOrdersThenReadinessCheckFailuresCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CONTRACTING);
        Opportunity corporateOpportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(-5))
            .setParent('Opportunity__r', opportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);

        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_STAGE,
                    FIELD_LABEL_OPPORTUNITY,
                    SERVICE_METHOD_OPPORTUNITY_REQUIRED_STAGE,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_OPPORTUNITY;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test that no Readiness Check Failures are created
     * when Opportunity Stage is 'Closed/Won' on Work Order type as 'Marketplace'.
     */
    private static void testWhenOpportunityStageEqualToClosedWonOnParentWorkOrdersThenReadinessCheckFailuresNotCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON);
        Opportunity corporateOpportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(-5))
            .setParent('Opportunity__r', opportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_STAGE,
                    FIELD_LABEL_OPPORTUNITY,
                    SERVICE_METHOD_OPPORTUNITY_REQUIRED_STAGE,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_OPPORTUNITY;

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when invalid "Google Sheet URL"
     * is populated on an eligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLInvalidThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, INVALID_GOOGLE_SHEET_URL)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_TYPE_COO)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, MOCK_USER_NAME)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_USERNAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidate.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidate.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidate.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            )
        };
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Google Sheet URL"
     * is not populated on an eligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLBlankThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, null)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_TYPE_COO)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, MOCK_USER_NAME)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_USERNAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = parentWorkOrder.AccountId,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = storeReadinessValidationRuleToValidate.Error_Message__c,
                Field_Name__c = storeReadinessValidationRuleToValidate.Field_Label__c,
                Object_Name__c = storeReadinessValidationRuleToValidate.Object_Label__c,
                Parent_Work_Order__c = parentWorkOrder.Id
            )
        };
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Google Sheet URL"
     * is not populated on an ineligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLBlankOnWorkOrderCreatedByProcessAutomationUserThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, null)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_TYPE_COO)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, System.Label.Automated_Process_User_Full_Name)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_USERNAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Google Sheet URL"
     * is not populated on an ineligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLBlankOnDriveAutoActivationsWorkOrderThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, null)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, MOCK_USER_NAME)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_NAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Google Sheet URL"
     * is not populated on an ineligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLBlankOnDriveWithholdingWithAutoActivationsWorkOrderThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, null)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_SUB_TYPE_WITHHOLDING)
            .setField(WorkOrder.Withholding_with_Auto_Activations__c, true)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, MOCK_USER_NAME)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_NAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when "Google Sheet URL"
     * is not populated on an ineligible Work Order.
     */
    @isTest
    private static void testWhenGoogleSheetURLBlankOnMarketplaceWorkOrderThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Google_Sheet_URL__c, null)
            .setField(WorkOrder.CreatedById, mockUserId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(
                'CreatedBy',
                new Fake(User.class)
                    .setField(User.Id, mockUserId)
                    .setField(User.Email, MOCK_USER_EMAIL_ID)
                    .setField(User.EmailEncodingKey, USER_ENCODING)
                    .setField(User.FirstName, MOCK_USER_FIRST_NAME)
                    .setField(User.LanguageLocaleKey, USER_LOCALE)
                    .setField(User.LastName, MOCK_USER_LAST_NAME)
                    .setField(User.LocaleSidKey, USER_LOCALE)
                    .setField(User.Name, MOCK_USER_NAME)
                    .setField(User.ProfileId, fflib_IDGenerator.generate(Profile.SObjectType))
                    .setField(User.TimeZoneSidKey, USER_TIMEZONE)
                    .setField(User.UserName, MOCK_USER_NAME)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_GOOGLE_SHEET_URL,
                    FIELD_LABEL_GOOGLE_SHEET_URL,
                    SERVICE_METHOD_VALIDATE_GOOGLE_SHEET_URL,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
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
                                    .setField(Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c, null)
                            )
                    }
                )
        );
        storeReadinessValidationRuleToValidate.Field_Name__c = FIELD_NAME_GOOGLE_SHEET_URL;
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{
                storeReadinessValidationRuleToValidate
            },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test that no Readiness Check Failures are created
     * when Opportunity Mp Bz Id is null on Work Order type as 'Drive' and Sub type as Withholding.
     */
    @isTest
    private static void testWhenOpportunityMpBzIdIsNullThenReadinessCheckFailuresCreated() {
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

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Nintex_Use_Case__c, INTEGRATED_FRANCHISE);
        Opportunity corporateOpportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Opportunity__c, corporateOpportunity.Id)
            .setField(WorkOrder.Sub_Type__c, WORKORDER_SUB_TYPE_WITHHOLDING)
            .setParent(
                'Opportunity__r',
                new Fake(Opportunity.class)
                    .setField(Opportunity.Id, corporateOpportunity.Id)
                    .setField(Opportunity.Nintex_Use_Case__c, INTEGRATED_FRANCHISE)
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        String opportunityObjectApiName = 'Opportunity';
        String className = 'WorkOrderValidationsServiceImpl';

        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_OPPORTUNITY_REQUIRED_MPBZID,
                    FIELD_LABEL_MPBZID,
                    SERVICE_METHOD_OPPORTUNITY_MPBZID,
                    OPPORTUNITY_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
                .setField(Store_Readiness_Validation_Rule__mdt.Id, storeReadinessValidationRuleId)
                .setField(
                    Store_Readiness_Validation_Rule__mdt.DeveloperName,
                    VALIDATION_RULE_DEVELOPER_NAME
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
                                        WORKORDER_TYPE_DRIVE
                                    )
                                    .setField(
                                        Sobject_Type_Sub_Type_Mapping__mdt.Sub_Type__c,
                                        WORKORDER_SUB_TYPE_WITHHOLDING
                                    )
                            )
                    }
                )
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_MPBZID;
        storeReadinessValidationRule.Object_Name__c = OPPORTUNITY_OBJECT_NAME;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStoreReadinessModificationService storeReadinessServiceMock = (IStoreReadinessModificationService) mocks.mock(
            IStoreReadinessModificationService.class
        );
        Application.SERVICE.setMock(
            IStoreReadinessModificationService.class,
            storeReadinessServiceMock
        );

        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>(),
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            opportunityObjectApiName
        );
        ((IStoreReadinessModificationService) mocks.verify(storeReadinessServiceMock, 1))
            .processReadinessCheckFailures(
                existingReadinessCheckFailures,
                mockReadinessValidationRuleFailures,
                opportunityObjectApiName,
                className
            );
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Business Id' field not equals 'External Id'
     * field of Business Reference
     */
    @isTest
    private static void testWhenBusinessIdOnWorkOrderEqualtoExternalIdOnBusinessReferenceThenReadinessCheckFailuresNotCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB);

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Business_to_Store_Assignment__c, PROVISIONING_PROCESS_AUTOMATIC)
            .setField(WorkOrder.Business_Id__c, MOCK_BUSINESS_ID)
            .setField(WorkOrder.AccountId, businessAccount.Id)
            .setField(workOrder.contract__c, contractId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 7)
            .setField(workOrder.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(
                WorkOrder.Menu_to_be_Completed_By__c,
                WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BUSINESS_ID,
                    FIELD_LABEL_BUSINESS_ID,
                    SERVICE_METHOD_VALIDATE_VALIDATEBUSINESSID,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_BUSINESS_ID;
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(Business_Reference__c.External_Id__c, MOCK_BUSINESS_ID)
            .toSObject();
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                    new Set<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(businessRefSelectorMock);

        Test.startTest();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Test.stopTest();

        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation
     * when Work Order 'Business Id' field equals 'External Id'
     * field of Business Reference
     */
    @isTest
    private static void testWhenBusinessIdOnWorkOrderNotEqualtoExternalIdOnBusinessReferenceThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB);

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Business_to_Store_Assignment__c, PROVISIONING_PROCESS_AUTOMATIC)
            .setField(WorkOrder.Business_Id__c, MOCK_BUSINESS_ID)
            .setField(WorkOrder.AccountId, businessAccount.Id)
            .setField(workOrder.contract__c, contractId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 7)
            .setField(workOrder.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(
                WorkOrder.Menu_to_be_Completed_By__c,
                WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BUSINESS_ID,
                    FIELD_LABEL_BUSINESS_ID,
                    SERVICE_METHOD_VALIDATE_VALIDATEBUSINESSID,
                    WORKORDER_OBJECT_NAME,
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
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_BUSINESS_ID;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(Business_Reference__c.External_Id__c, MOCK_EXTERNAL_ID)
            .toSObject();
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                    new Set<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Test.startTest();
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Test.stopTest();
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation when Work Order Type is 'Ads & Promos'
     * and Actual Number of Stores is greater than Number of Stores on Quote.
     */
    @isTest
    private static void testWhenNumberOfStoresOnAdsPromosWorkOrderGreaterThanQuotesThenReadinessCheckFailuresCreated() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
        Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
            Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_ADS_AND_PROMOS
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Actual_Number_Of_Stores__c, 10)
            .setField(WorkOrder.Number_of_Stores_on_Quote__c, 0)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_ADS_AND_PROMOS,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        // LEM-18591 - validate Number of Stores on Quote should be less than or equal to Actual Number of Stores
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_NUMBER_OF_STORES,
                    FIELD_LABEL_NUMBER_OF_STORES,
                    SERVICE_METHOD_VALIDATE_NUMBER_OF_STORES,
                    WORKORDER_OBJECT_NAME,
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
                                        WORKORDER_TYPE_ADS_AND_PROMOS
                                    )
                            )
                    }
                )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_NUMBER_OF_STORES;
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId
            )
        };
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures are not created
     * when Work Order's Type is 'Marketplace'.
     */
    @isTest
    private static void testWhenMarketplaceWorkOrderThenReadinessCheckFailuresNotCreated() {
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
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Actual_Number_Of_Stores__c, 10)
            .setField(WorkOrder.Number_of_Stores_on_Quote__c, 7)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                CUSTOM_METADATA_ERROR_NUMBER_OF_STORES,
                FIELD_LABEL_NUMBER_OF_STORES,
                SERVICE_METHOD_VALIDATE_NUMBER_OF_STORES,
                WORKORDER_OBJECT_NAME,
                SERVICE_CLASS_NAME
            )
        );
        storeReadinessValidationRule.Field_Name__c = FIELD_NAME_NUMBER_OF_STORES;
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderValidationsServiceImpl workOrderValidationsServiceImplInstance = new WorkOrderValidationsServiceImpl();
        Application.UNITOFWORK.setMock(mockUOW);
        workOrderValidationsServiceImplInstance.validate(
            new List<Workorder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            new List<Store_Readiness_Validation_Rule__mdt>{ storeReadinessValidationRule },
            existingReadinessCheckFailures,
            WORKORDER_OBJECT_API_NAME
        );
        // Work Order Type is 'Marketplace', no Readiness Check Failures created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}