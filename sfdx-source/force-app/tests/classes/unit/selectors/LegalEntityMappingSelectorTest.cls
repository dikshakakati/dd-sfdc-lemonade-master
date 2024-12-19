/**
 * @author Deloitte
 * @date 04/14/2022
 * @description Test class for LegalEntityMappingSelector class
 */
@isTest(seeAllData=false)
public class LegalEntityMappingSelectorTest {
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Legal_Entity_Mapping__mdt> customMetadataMocks = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United States',
                Legal_Entity_Name__c = 'Doordash Inc',
                Billing_State_Code__c = 'PR',
                Primary_Vertical__c = 'Alcohol',
                Record_Type_Name__c = 'Business'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Legal_Entity_Mapping__mdt.Label,
            Legal_Entity_Mapping__mdt.DeveloperName,
            Legal_Entity_Mapping__mdt.Legal_Entity_Name__c,
            Legal_Entity_Mapping__mdt.Billing_State_Code__c,
            Legal_Entity_Mapping__mdt.Primary_Vertical__c,
            Legal_Entity_Mapping__mdt.Record_Type_Name__c,
            Legal_Entity_Mapping__mdt.Currency_ISO_Code__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LegalEntityMappingSelector mockLegalEntityMapping = (LegalEntityMappingSelector) mocks.mock(
            LegalEntityMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockLegalEntityMapping.getSObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(mockLegalEntityMapping.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockLegalEntityMapping.getSObjectFieldList()).thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockLegalEntityMapping);

        Schema.SObjectType typeOfObject = LegalEntityMappingSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = LegalEntityMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Legal_Entity_Mapping__mdt> allLegalEntityData = LegalEntityMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Legal_Entity_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            Legal_Entity_Mapping__mdt.getAll().values().size(),
            allLegalEntityData.size(),
            'Unexpected Error: Mismatch in list of  Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
}