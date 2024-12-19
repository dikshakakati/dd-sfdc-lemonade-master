/**
 * @description       :
 * @author            : Aethereus
 * @group             :
 * @last modified on  : 05-09-2024
 * @description Test StoreReadinessModificationServiceImpl class.
**/
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class StoreReadinessModificationServicImplTest {

    private static final String STATUS_RESOLVED = 'Resolved';
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY = 'Please ensure Activate Centrally (AC) is populated as No.';
    private static final String FIELD_LABEL_ACTIVATED_CENTRALLY = 'Activated Centrally (AC)';
    private static final String FIELD_NAME_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String FIELD_NAME_SHOPPING_PROTOCOL = 'Shopping_Protocol__c';
    private static final String FIELD_NAME_TAX_ID = 'TaxID__c';
    private static final String FIELD_LABEL_ACCESSIBILITIES='Accessibilities';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final String MX_PICK_SHOPPING_PROTOCOL = 'Mx Pick';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String ORDER_PROTOCOL_CONTAINS_POS = 'POS';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String POS_INTEGRATION_TYPE_NON_INTEGRATED_MX = 'non_integrated_mx';
    private static final String POS_INTEGRATION_TYPE_FUTUREPOS = 'FuturePOS';
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
    private static final String SERVICE_METHOD_VALIDATE_ACCESSIBILITIES='validateAccessibilities';
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
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME = 'Account';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME = 'Legal_Business_Name__c';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE = 'Please ensure Legal Business Name is populated.';
	private static final String CLASS_NAME = 'AccountValidationsServiceImpl';

    /**
     * @description It checks for new readiness check failures being inserted
     * @JIRA# LEM-13963
     */
    @isTest
    private static void testWhenProcessReadinessCheckFailuresThenValidateReadinessCheck() {
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
        StoreReadinessModificationServiceImpl storeReadinessModificationServiceImplInstance = new StoreReadinessModificationServiceImpl();
        StoreReadinessModificationServiceImplInstance.processReadinessCheckFailures(
            mockExistingReadinessCheckFailures,
            mockReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME,
            CLASS_NAME
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It checks existing readiness checks that have been resolved and updates them accordingly.
     * @JIRA# LEM-13963
     */
    @isTest
    private static void testWhenNoNewReadinessErrorThenUpdateExistingReadinessError() {
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
        List<Readiness_Check_Failure__c> mockReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId,
                Status__c = 'Active'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        StoreReadinessModificationServiceImpl storeReadinessModificationServiceImplInstance = new StoreReadinessModificationServiceImpl();
        StoreReadinessModificationServiceImplInstance.processReadinessCheckFailures(
            mockExistingReadinessCheckFailures,
            mockReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME,
            CLASS_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerDirty(mockExistingReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It checks if the Object_Name__c field of the new readiness check record is blank; those records will not be processed.
     * @JIRA# LEM-13963
     */
    @isTest
    private static void testWhenNoNewReadinessErrorHasNoObjectThenNotInsertThatReadinessMessage() {
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
                Account_Name__c = workOrder.AccountId,
                Status__c = 'Active'
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = '',
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId,
                Child_Work_Order__c = workOrder.Id,
                Account_Name__c = workOrder.AccountId,
                Status__c = 'Active'
            )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        StoreReadinessModificationServiceImpl storeReadinessModificationServiceImplInstance = new StoreReadinessModificationServiceImpl();
        StoreReadinessModificationServiceImplInstance.processReadinessCheckFailures(
            mockExistingReadinessCheckFailures,
            mockReadinessCheckFailures,
            ACCOUNT_OBJECT_NAME,
            CLASS_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}