/**
 * @author Deloitte
 * @date 20/07/2022
 * @description Test class for StoreReadinessCheckServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class StoreReadinessCheckServiceImplTest {
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String AGGREGATE_READINESS_FAILURE_COUNT_ALIAS = 'readinessCheckFailuresCount';
    private static final String AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS = 'childWorkOrderId';
    private static final String ERROR_MESSAGE_ORDER_PROTOCOL = 'Please ensure Order Protocol is populated.';
    private static final String FIELD_NAME_ORDER_PROTOCOL = 'Order_Protocol__c';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.WorkOrder.FieldSets.Store_Readiness_Check_Fields;
    private static final Integer NUMBER_OF_READINESS_FAILURES_COUNT_ONE = 1;
    private static final String ORDER_PROTOCOL_CONTAINS_POS = 'POS';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_FAILED = 'Readiness Check Failed';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String SERVICE_CLASS_NAME = 'IAccountValidationsService';
    private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE = 'validateNullFieldValuesOnStoreByWorkOrderType';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';
    private static final String WORK_ORDER_PARENT_WORKORDER_RELATIONSHIP_NAME = 'ParentWorkOrder';

    /**
     * @description To test when store readiness check failed on child Work Orders then provisioning
     * status is updated to "Readiness Check Failed".
     */
    @isTest
    private static void testWhenStoreReadinessCheckFailedThenWorkOrderProvisioningStatusUpdatedToFailed() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_ORDER_PROTOCOL,
                    FIELD_NAME_ORDER_PROTOCOL,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                    ACCOUNT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent(WORK_ORDER_PARENT_WORKORDER_RELATIONSHIP_NAME, parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        List<Aggregate> readinessFailuresCountOnWorkOrder = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS, childWorkOrder.Id)
                .put(
                    AGGREGATE_READINESS_FAILURE_COUNT_ALIAS,
                    NUMBER_OF_READINESS_FAILURES_COUNT_ONE
                )
        };
        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreReadinessValidationRulesSelector mockStoreReadinessRulesSelector = (IStoreReadinessValidationRulesSelector) mocks.mock(
            IStoreReadinessValidationRulesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        IHandleStoreReadinessValidations serviceMock = (IHandleStoreReadinessValidations) mocks.mock(
            IHandleStoreReadinessValidations.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreReadinessRulesSelector.sObjectType())
            .thenReturn(Store_Readiness_Validation_Rule__mdt.SObjectType);
        mocks.when(mockStoreReadinessRulesSelector.selectAllValidReadinessValidationRules())
            .thenReturn(storeReadinessValidationRules);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
                    new Set<Id>{ childWorkOrder.Id, childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(readinessFailuresCountOnWorkOrder);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreReadinessRulesSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(IHandleStoreReadinessValidations.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        StoreReadinessCheckService.runReadinessCheckOnWorkOrders(new Set<Id>{ childWorkOrder.Id },mockExistingReadinessCheckFailures);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => childWorkOrder.Id,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when store readiness check successful on child Work Orders
     * then provisioning status is updated to "Readiness Check Complete".
     */
    @isTest
    private static void testWhenStoreReadinessCheckSuccessfulThenWorkOrderProvisioningStatusUpdatedToComplete() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_ORDER_PROTOCOL,
                    FIELD_NAME_ORDER_PROTOCOL,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                    ACCOUNT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent(WORK_ORDER_PARENT_WORKORDER_RELATIONSHIP_NAME, parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Aggregate> readinessFailuresCountOnWorkOrder = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS, childWorkOrder.Id)
                .put(AGGREGATE_READINESS_FAILURE_COUNT_ALIAS, 0)
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreReadinessValidationRulesSelector mockStoreReadinessRulesSelector = (IStoreReadinessValidationRulesSelector) mocks.mock(
            IStoreReadinessValidationRulesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        IHandleStoreReadinessValidations serviceMock = (IHandleStoreReadinessValidations) mocks.mock(
            IHandleStoreReadinessValidations.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreReadinessRulesSelector.sObjectType())
            .thenReturn(Store_Readiness_Validation_Rule__mdt.SObjectType);
        mocks.when(mockStoreReadinessRulesSelector.selectAllValidReadinessValidationRules())
            .thenReturn(storeReadinessValidationRules);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
                    new Set<Id>{ childWorkOrder.Id, childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(readinessFailuresCountOnWorkOrder);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreReadinessRulesSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(IHandleStoreReadinessValidations.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        StoreReadinessCheckService.runReadinessCheckOnWorkOrders(new Set<Id>{ childWorkOrder.Id },mockExistingReadinessCheckFailures);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => childWorkOrder.Id,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when readiness check is successful on parent Work Order
     * then "Provisioning Status" is updated to "Readiness Check Complete".
     */
    @isTest
    private static void testWhenReadinessCheckSuccessfulOnParentWorkOrderThenWorkOrderProvisioningStatusUpdatedToReadinessCheckComplete() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_ORDER_PROTOCOL,
                    FIELD_NAME_ORDER_PROTOCOL,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                    ACCOUNT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Aggregate> readinessFailuresCountOnWorkOrder = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS, parentWorkOrder.Id)
                .put(AGGREGATE_READINESS_FAILURE_COUNT_ALIAS, 0)
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreReadinessValidationRulesSelector mockStoreReadinessRulesSelector = (IStoreReadinessValidationRulesSelector) mocks.mock(
            IStoreReadinessValidationRulesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        IHandleStoreReadinessValidations serviceMock = (IHandleStoreReadinessValidations) mocks.mock(
            IHandleStoreReadinessValidations.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(mockStoreReadinessRulesSelector.sObjectType())
            .thenReturn(Store_Readiness_Validation_Rule__mdt.SObjectType);
        mocks.when(mockStoreReadinessRulesSelector.selectAllValidReadinessValidationRules())
            .thenReturn(storeReadinessValidationRules);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(readinessFailuresCountOnWorkOrder);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreReadinessRulesSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(IHandleStoreReadinessValidations.class, serviceMock);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        StoreReadinessCheckService.runReadinessCheckOnWorkOrders(new Set<Id>{ parentWorkOrder.Id },mockExistingReadinessCheckFailures);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
    * @description - test specifically to test exception and query limit logic
    * @author Soumya Dash | 05-03-2024
    */
    @isTest
    private static void testWhenExceptionAndThenQueryLimitOccurs() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_ORDER_PROTOCOL,
                    FIELD_NAME_ORDER_PROTOCOL,
                    SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_BY_TYPE,
                    ACCOUNT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, parentAccountFakeInstance);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Aggregate> readinessFailuresCountOnWorkOrder = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS, parentWorkOrder.Id)
                .put(AGGREGATE_READINESS_FAILURE_COUNT_ALIAS, 0)
        };

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreReadinessValidationRulesSelector mockStoreReadinessRulesSelector = (IStoreReadinessValidationRulesSelector) mocks.mock(
            IStoreReadinessValidationRulesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        IHandleStoreReadinessValidations serviceMock = (IHandleStoreReadinessValidations) mocks.mock(
            IHandleStoreReadinessValidations.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mockStoreReadinessRulesSelector.sObjectType())
            .thenReturn(Store_Readiness_Validation_Rule__mdt.SObjectType);
        mocks.when(mockStoreReadinessRulesSelector.selectAllValidReadinessValidationRules())
            .thenReturn(storeReadinessValidationRules);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);

        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(readinessFailuresCountOnWorkOrder);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockStoreReadinessRulesSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(IHandleStoreReadinessValidations.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
         StoreReadinessCheckService.runReadinessCheckOnWorkOrders(new Set<Id>{ parentWorkOrder.Id },mockExistingReadinessCheckFailures);
        Test.stopTest();

    }

}