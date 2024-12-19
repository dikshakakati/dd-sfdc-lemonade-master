/**
 * @author Deloitte
 * @date 04/19/2024
 * @description Test class for ActivationChecklistValidationSelector class.
 */
@isTest(seeAllData=false)
private class ActivationCheckValidationSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be Activation Checklist Validation custom metadata';
    private static final String ASSERT_MESSAGE_RECORDS_NOT_FETCHED = 'Unexpected result: custom metadata records not retrieved.';
    private static final String METADATA_ERROR_MESSAGE = 'PDOA is in the future';
    private static final String METADATA_METHOD_NAME = 'validatePDOA';
    private static final String METADATA_NAME = 'PDOA';
    private static final String METADATA_SUCCESS_MESSAGE = 'PDOA is today or in the past';
    private static final Integer RECORD_COUNT_ONE = 1;

    /**
     * @description To test Activation Checklist Validation selector methods.
     */
    @isTest
    private static void testWhenSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Activation_Checklist_Validation__mdt.Success_Message__c,
            Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
            Activation_Checklist_Validation__mdt.DeveloperName,
            Activation_Checklist_Validation__mdt.Error_Message__c,
            Activation_Checklist_Validation__mdt.Is_Active__c,
            Activation_Checklist_Validation__mdt.Object_Name__c,
            Activation_Checklist_Validation__mdt.Service_Class_Name__c,
            Activation_Checklist_Validation__mdt.Service_Method_Name__c,
            Activation_Checklist_Validation__mdt.Source__c
        };
        Schema.SObjectType typeOfObject = ActivationChecklistValidationSelector.newInstance()
            .SObjectType();
        ActivationChecklistValidationSelector activationChecklistValidationSelectorInstance = new ActivationChecklistValidationSelector();
        List<Schema.SObjectField> sObjectFields = activationChecklistValidationSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Activation_Checklist_Validation__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test Readiness Validation Binding Type selector methods.
     */
    @isTest
    private static void testWhenGetAllActiveValidationsCalledThenReturnActiveRecords() {
        Fake mockFakeActivationChecklistValidation = new Fake(
                Activation_Checklist_Validation__mdt.class
            )
            .setField(
                Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
                METADATA_NAME
            )
            .setField(Activation_Checklist_Validation__mdt.Is_Active__c, true)
            .setField(Activation_Checklist_Validation__mdt.Error_Message__c, METADATA_ERROR_MESSAGE)
            .setField(
                Activation_Checklist_Validation__mdt.Success_Message__c,
                METADATA_SUCCESS_MESSAGE
            )
            .setField(
                Activation_Checklist_Validation__mdt.Service_Method_Name__c,
                METADATA_METHOD_NAME
            )
            .setFakeId();
        Activation_Checklist_Validation__mdt mockActivationChecklistValidation = (Activation_Checklist_Validation__mdt) ServiceMockDataBuilder.convertToSObject(
            mockFakeActivationChecklistValidation
        );
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations = new List<Activation_Checklist_Validation__mdt>{
            mockActivationChecklistValidation
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ActivationChecklistValidationSelector mockActivationChecklistValidationSelector = (ActivationChecklistValidationSelector) mocks.mock(
            ActivationChecklistValidationSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockActivationChecklistValidationSelector.getSObjectType())
            .thenReturn(Activation_Checklist_Validation__mdt.SObjectType);
        mocks.when(mockActivationChecklistValidationSelector.getAllActiveValidations())
            .thenReturn(activationChecklistValidations);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockActivationChecklistValidationSelector);
        List<Activation_Checklist_Validation__mdt> selectorResult = ActivationChecklistValidationSelector.newInstance()
            .getAllActiveValidations();
        System.assertEquals(true, !selectorResult.isEmpty(), ASSERT_MESSAGE_RECORDS_NOT_FETCHED);
    }
}