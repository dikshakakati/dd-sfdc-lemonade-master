/**
 * @author Deloitte
 * @date 09/12/2022
 * @description Test class for ReadinessValidationTypeBindingsSelector class.
 */
@isTest(SeeAllData=false)
private class ReadinessValidationBindingsSelectTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be ReadinessValidation SobjectType Binding custom metadata';

    /**
     * @description To test Readiness Validation Binding Type selector methods.
     */
    @isTest
    private static void testWhenSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
            ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c
        };
        Schema.SObjectType typeOfObject = ReadinessValidationTypeBindingsSelector.newInstance()
            .SObjectType();
        ReadinessValidationTypeBindingsSelector readinessValidationTypeBindingsInstance = new ReadinessValidationTypeBindingsSelector();
        List<Schema.SObjectField> sObjectFields = readinessValidationTypeBindingsInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            ReadinessValidation_SobjectType_Binding__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
}