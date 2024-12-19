/**
 * @author DoorDash
 * @date 06/19/2023
 * @description Test class for XrefValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class XrefValidationServiceImplTest {
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String XREF_OBJECT_NAME = 'XREF';
    private static final String XREF_OBJECT_API_NAME = 'Xref__c';
    private static final String ERROR_MESSAGE_XREF_EXISTS = 'Xref Already Exists. Please submit a COO';
    private static final String SERVICE_CLASS_NAME = 'IXrefValidationService';
    private static final String SERVICE_METHOD_VALIDATE_XREF = 'validateXrefsOnAccount';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVE_MDS_XREF_ON_STORE = 'validateActiveMDSXrefOnStore';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';

    /**
     * @description To test Readiness Check Failures creation
     * when Active Xref associated to store for Marketplace WO
     */
    @isTest
    private static void testWhenXrefExistOnStoreThenReadinessCheckFailuresCreated() {
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_XREF_EXISTS,
                    '',
                    SERVICE_METHOD_VALIDATE_XREF,
                    XREF_OBJECT_NAME,
                    SERVICE_CLASS_NAME
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
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setFakeId()
            .toSObject();

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID_Source__c, 'MDS')
            .setField(Xref__c.Xref_Status__c, 'Active')
            .setField(Xref__c.External_ID__c, '12345')
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, businessReference.Id)
            .setParent('Salesforce_Account_Name__r', childAccountFakeInstance)
            .setFakeId()
            .toSObject();
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
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent('Account', childAccountFakeInstance);
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
        IXrefsSelector mockxrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();
        accountIdToWorkOrder.put(workOrder.AccountId, workOrder);

        mocks.startStubbing();
        mocks.when(mockxrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockxrefsSelector.selectActiveMDSXrefsByStoreIds(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockxrefsSelector);
        XrefValidationServiceImpl xrefValidationsSrvcImplInstance = new XrefValidationServiceImpl();
        xrefValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            XREF_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }


    /**
     * @description To test Readiness Check Failures creation
     * when there is no Xref associated to store
     */
    @isTest
    private static void testWhenXrefDoesntExistThenFailuresCreated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_XREF_EXISTS,
                    '',
                    SERVICE_METHOD_VALIDATE_XREF,
                    XREF_OBJECT_NAME,
                    SERVICE_CLASS_NAME
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
            .setField(Account.Id, storeAccountId)
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
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent('Account', childAccountFakeInstance);
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
        IXrefsSelector mockxrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();
        accountIdToWorkOrder.put(workOrder.AccountId, workOrder);

        mocks.startStubbing();
        mocks.when(mockxrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);


        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockxrefsSelector);
        XrefValidationServiceImpl xrefValidationsSrvcImplInstance = new XrefValidationServiceImpl();
        xrefValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            XREF_OBJECT_API_NAME
        );
        mocks.stopStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

     /**
     * @description To test when workorder of type storefront bundled with marketplace is received then
     * validation of active xref on store is skipped.
     */
    @isTest
    private static void testWhenStorefrontWorkOrderBundledWithMarketplaceReceivedThenActiveXrefValidationSkipped() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_XREF_EXISTS,
                    '',
                    SERVICE_METHOD_VALIDATE_ACTIVE_MDS_XREF_ON_STORE,
                    XREF_OBJECT_NAME,
                    SERVICE_CLASS_NAME
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
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
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
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent('Account', childAccountFakeInstance);
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
        IXrefsSelector mockxrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();
        accountIdToWorkOrder.put(workOrder.AccountId, workOrder);
        mocks.startStubbing();
        mocks.when(mockxrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockxrefsSelector);
        XrefValidationServiceImpl xrefValidationsSrvcImplInstance = new XrefValidationServiceImpl();
        xrefValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            XREF_OBJECT_API_NAME
        );
        mocks.stopStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures creation on Storefront Work Order
     * when there is no Active 'MDS' Xref associated to store.
     */
    @isTest
    private static void testWhenNoActiveMDSXrefExistOnStorefrontWorkOrderThenReadinessCheckFailuresCreated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_XREF_EXISTS,
                    '',
                    SERVICE_METHOD_VALIDATE_ACTIVE_MDS_XREF_ON_STORE,
                    XREF_OBJECT_NAME,
                    SERVICE_CLASS_NAME
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
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent(ACCOUNT_PARENT_RELATIONSHIP_NAME, parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
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
            .setParent(WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME, childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent('Account', childAccountFakeInstance);
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
        IXrefsSelector mockxrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        Map<Id, WorkOrder> accountIdToWorkOrder = new Map<Id, WorkOrder>();
        accountIdToWorkOrder.put(workOrder.AccountId, workOrder);
        mocks.startStubbing();
        mocks.when(mockxrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockxrefsSelector);
        XrefValidationServiceImpl xrefValidationsSrvcImplInstance = new XrefValidationServiceImpl();
        xrefValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            XREF_OBJECT_API_NAME
        );
        mocks.stopStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}