/**
 * @author Deloitte
 * @date 20/07/2022
 * @description Test class for StoreReadinessValidationRulesSelector class.
 */
@isTest(seeAllData=false)
private class StoreReadinessValidationRulesSelectTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be Store Readiness Validation Rules custom metadata';
    private static final String ASSERT_MESSAGE_NO_VALIDATION_FAILURES_RETURNED = 'Unexpected result: there were no Store Readiness Validation Rules custom metadata records returned';
    private static final String ERROR_MESSAGE_ACTIVATED_CENTRALLY = 'Please ensure Activate Centrally (AC) is populated as No.';
    private static final String FIELD_NAME_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String WORKORDER_OBJECT_NAME = 'WorkOrder';
    private static final String SERVICE_CLASS_NAME = 'StoreReadinessValidationRulesSelectTest';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY = 'validateActivateCentrallyTest';

    /**
     * @description To test Store Readiness Validation Rule selector methods.
     */
    @isTest
    private static void testWhenSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Store_Readiness_Validation_Rule__mdt.Description__c,
            Store_Readiness_Validation_Rule__mdt.DeveloperName,
            Store_Readiness_Validation_Rule__mdt.Error_Message__c,
            Store_Readiness_Validation_Rule__mdt.Field_Label__c,
            Store_Readiness_Validation_Rule__mdt.Field_Name__c,
            Store_Readiness_Validation_Rule__mdt.Is_Active__c,
            Store_Readiness_Validation_Rule__mdt.Object_Label__c,
            Store_Readiness_Validation_Rule__mdt.Object_Name__c,
            Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c,
            Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c
        };
        StoreReadinessValidationRulesSelector storeReadinessRulesInstance = new StoreReadinessValidationRulesSelector();
        Schema.SObjectType typeOfObject = storeReadinessRulesInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = storeReadinessRulesInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Store_Readiness_Validation_Rule__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test query on Store_Readiness_Validation_Rule__mdt to fetch
     * active store readiness validation rules having service class and method name populated.
     */
    @isTest
    private static void testWhenSelectAllValidReadinessValidationRulesCalledThenStoreReadinessValidationRulesReturned() {
        List<Store_Readiness_Validation_Rule__mdt> customMetadataMocks = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    ERROR_MESSAGE_ACTIVATED_CENTRALLY,
                    FIELD_NAME_ACTIVATED_CENTRALLY,
                    SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY,
                    WORKORDER_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StoreReadinessValidationRulesSelector mockStoreReadinessValidationSelector = (StoreReadinessValidationRulesSelector) mocks.mock(
            StoreReadinessValidationRulesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreReadinessValidationSelector.getSObjectType())
            .thenReturn(Store_Readiness_Validation_Rule__mdt.SObjectType);
        mocks.when(mockStoreReadinessValidationSelector.selectAllValidReadinessValidationRules())
            .thenReturn(customMetadataMocks);
        Application.SELECTOR.setMock(mockStoreReadinessValidationSelector);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRulesResult = StoreReadinessValidationRulesSelector.newInstance()
            .selectAllValidReadinessValidationRules();
        System.assertEquals(
            true,
            !storeReadinessValidationRulesResult.isEmpty(),
            ASSERT_MESSAGE_NO_VALIDATION_FAILURES_RETURNED
        );
    }
}