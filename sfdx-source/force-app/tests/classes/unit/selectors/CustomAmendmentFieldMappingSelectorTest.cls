/**
 * @author Aetheueus
 * @date 06/07/2024
 * @description Test class for CustomAmendmentFieldMappingSelector class.
 */
@isTest(seeAllData=false)
private class CustomAmendmentFieldMappingSelectorTest {
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Custom_Amendment_Field_Mapping__mdt> customMetadataMocks = new List<Custom_Amendment_Field_Mapping__mdt>{
            new Custom_Amendment_Field_Mapping__mdt(
                MasterLabel = 'QuoteLine.Affinity_Target_Audience__c',
                DeveloperName = 'QuoteLine_Affinity_Target_Audience_c',
                Field_API_Name__c = 'Affinity_Target_Audience__c',
                Type_of_Mapping__c = 'Copy from Source',
                sObject_Type__c = 'SBQQ__QuoteLine__c',
                Source_Field__c = 'Affinity_Target_Audience__c',
                Source_Object__c = 'SBQQ__Subscription__c',
                Static_Value__c = ''
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Custom_Amendment_Field_Mapping__mdt.Active__c,
            Custom_Amendment_Field_Mapping__mdt.DeveloperName,
            Custom_Amendment_Field_Mapping__mdt.Field_API_Name__c,
            Custom_Amendment_Field_Mapping__mdt.Type_of_Mapping__c,
            Custom_Amendment_Field_Mapping__mdt.sObject_Type__c,
            Custom_Amendment_Field_Mapping__mdt.Source_Field__c,
            Custom_Amendment_Field_Mapping__mdt.Source_Object__c,
            Custom_Amendment_Field_Mapping__mdt.Static_Value__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomAmendmentFieldMappingSelector mockCustomAmendmentFieldMapping = (CustomAmendmentFieldMappingSelector) mocks.mock(
            CustomAmendmentFieldMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockCustomAmendmentFieldMapping.getSObjectType())
            .thenReturn(Custom_Amendment_Field_Mapping__mdt.SObjectType);
        mocks.when(mockCustomAmendmentFieldMapping.selectAllCustomAmendmentFieldsMapping()).thenReturn(customMetadataMocks);
        mocks.when(mockCustomAmendmentFieldMapping.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCustomAmendmentFieldMapping);

        Schema.SObjectType typeOfObject = CustomAmendmentFieldMappingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = CustomAmendmentFieldMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Custom_Amendment_Field_Mapping__mdt> allCustomAmendmentfield = CustomAmendmentFieldMappingSelector.newInstance()
            .selectAllCustomAmendmentFieldsMapping();

        System.assertEquals(
            Custom_Amendment_Field_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Country Attributes Mapping Metadata'
        );
        Assert.isNotNull(allCustomAmendmentfield, 'Expected');
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
}