/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Test class for NintexUrlMappingSelector
 */
@isTest(seeAllData=false)
private class NintexUrlMappingSelectorTest {
    @isTest
    private static void testWhenSelectorsAreCalledThenMetadataMappingsAreReturned() {
        List<Nintex_URL_Mapping__mdt> customMetadataMocks = new List<Nintex_URL_Mapping__mdt>{
            new Nintex_URL_Mapping__mdt(
                MasterLabel = 'Franchise US',
                DeveloperName = 'Franchise_US',
                URL__c = 'https://www.google.com'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Nintex_URL_Mapping__mdt.MasterLabel,
            Nintex_URL_Mapping__mdt.URL__c,
            Nintex_URL_Mapping__mdt.DeveloperName
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        NintexUrlMappingSelector mockNintexUrlMappingSelector = (NintexUrlMappingSelector) mocks.mock(
            NintexUrlMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockNintexUrlMappingSelector.getSObjectType())
            .thenReturn(Nintex_URL_Mapping__mdt.SObjectType);
        mocks.when(mockNintexUrlMappingSelector.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockNintexUrlMappingSelector.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockNintexUrlMappingSelector);

        Schema.SObjectType typeOfObject = NintexUrlMappingSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = NintexUrlMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Nintex_URL_Mapping__mdt> allNintexUrlMappings = NintexUrlMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Nintex_URL_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Nintex_URL_Mapping Metadata.'
        );
        System.assertEquals(
            Nintex_URL_Mapping__mdt.getAll().values(),
            allNintexUrlMappings,
            'Unexpected Error: Mismatch in list of Nintex URL Mappings Metadata.'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list.'
        );
    }
}