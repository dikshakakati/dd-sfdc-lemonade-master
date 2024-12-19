/**
 * @author Deloitte
 * @date 04/28/2023
 * @description Test class for BrandValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class BrandValidationsServiceImplTest {
    private static final String ACCOUNT_PARENT_RELATIONSHIP_NAME = 'Parent';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String BRAND_OBJECT_NAME = 'Brand';
    private static final String BRAND_OBJECT_API_NAME = 'Brand__c';
    private static final String BRAND_NAME = 'Kfc Brand';
    private static final String ERROR_MESSAGE_PRICE_RANGE = 'Please ensure Price Range is populated on the Brand.';
    private static final String FIELD_API_NAME_PRICE_RANGE = 'Price_Range__c';
    private static final String FIELD_LABEL_PRICE_RANGE = 'Price Range';
    private static final String PRICE_RANGE_FIELD_VALUE = '$';
    private static final String SERVICE_CLASS_NAME = 'IBrandValidationsService';
    private static final String SERVICE_METHOD_VALIDATE_PRICERANGE = 'validateNullFieldValuesByWorkOrderType';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_ORDER_ACCOUNT_RELATIONSHIP_NAME = 'Account';

    /**
     * @description To test Readiness Check Failures creation
     * when 'Price Range' field value is not populated on Brand associated to store.
     */
    @isTest
    private static void testWhenPriceRangeNullOnBrandThenReadinessCheckFailuresCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PRICE_RANGE,
                        FIELD_LABEL_PRICE_RANGE,
                        SERVICE_METHOD_VALIDATE_PRICERANGE,
                        BRAND_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_API_NAME_PRICE_RANGE
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
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setFakeId();
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Brand__c, brandInstance.Id)
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
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        mocks.startStubbing();
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(mockBrandSelector.selectById(new Set<Id>{ brandInstance.Id }))
            .thenReturn(new List<Brand__c>{ brandInstance });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBrandSelector);
        BrandValidationsServiceImpl brandValidationsSrvcImplInstance = new BrandValidationsServiceImpl();
        brandValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            BRAND_OBJECT_API_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessCheckFailures);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failures not created
     * when 'Price Range' field value is populated on Brand associated to store.
     */
    @isTest
    private static void testWhenPriceRangePopulatedOnBrandThenReadinessCheckFailuresNotCreated() {
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                        ERROR_MESSAGE_PRICE_RANGE,
                        FIELD_LABEL_PRICE_RANGE,
                        SERVICE_METHOD_VALIDATE_PRICERANGE,
                        BRAND_OBJECT_NAME,
                        SERVICE_CLASS_NAME
                    )
                    .setField(
                        Store_Readiness_Validation_Rule__mdt.Field_Name__c,
                        FIELD_API_NAME_PRICE_RANGE
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
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentAccount.Id)
            .setField(Brand__c.Price_Range__c, PRICE_RANGE_FIELD_VALUE)
            .setField(Brand__c.Name, BRAND_NAME)
            .setFakeId();
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.Brand__c, brandInstance.Id)
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

        List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        mocks.startStubbing();
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(mockBrandSelector.selectById(new Set<Id>{ brandInstance.Id }))
            .thenReturn(new List<Brand__c>{ brandInstance });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBrandSelector);
        BrandValidationsServiceImpl brandValidationsSrvcImplInstance = new BrandValidationsServiceImpl();
        brandValidationsSrvcImplInstance.validate(
            new List<WorkOrder>{ workOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockExistingReadinessCheckFailures,
            BRAND_OBJECT_API_NAME
        );
        // Readiness Check Failures not created as the Price Range is populated in Brand.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}