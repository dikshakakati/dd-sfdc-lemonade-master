/**
 * @author Deloitte
 * @date 04/14/2022
 * @description Test class for CountryAttributesMappingSelector class
 */
@isTest(seeAllData=false)
public class CountryAttributesMappingSelectorTest {
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Country_Attributes_Mapping__mdt> customMetadataMocks = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country_Record',
                DeveloperName = 'Country_Record',
                Country__c = 'Cyprus',
                Country_Code__c = 'CY',
                Currency__c = 'European euro',
                Currency_Code__c = 'EUR'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Country_Attributes_Mapping__mdt.Country__c,
            Country_Attributes_Mapping__mdt.Country_Code__c,
            Country_Attributes_Mapping__mdt.Currency__c,
            Country_Attributes_Mapping__mdt.Currency_Code__c,
            Country_Attributes_Mapping__mdt.Phone_Maximum_Digits__c,
            Country_Attributes_Mapping__mdt.Phone_Minimum_Digits__c,
            Country_Attributes_Mapping__mdt.Phone_Country_Code__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CountryAttributesMappingSelector mockCountryAttributesMapping = (CountryAttributesMappingSelector) mocks.mock(
            CountryAttributesMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockCountryAttributesMapping.getSObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(mockCountryAttributesMapping.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockCountryAttributesMapping.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCountryAttributesMapping);

        Schema.SObjectType typeOfObject = CountryAttributesMappingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = CountryAttributesMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Country_Attributes_Mapping__mdt> allCountryData = CountryAttributesMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Country_Attributes_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            Country_Attributes_Mapping__mdt.getAll().values(),
            allCountryData,
            'Unexpected Error: Mismatch in list of  Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
}