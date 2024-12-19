/**
 * @author Deloitte
 * @date 07/08/2024
 * @description Test class for PartnershipLevelMappingSelector class
 */
@isTest(seeAllData=false)
public class PartnershipLevelMappingSelectorTest {
    private static final String PARTNERSHIP_LEVEL_EXCLUSIVE = 'Exclusive';
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Partnership_Level_Mapping__mdt> customMetadataMocks = new List<Partnership_Level_Mapping__mdt>{
            new Partnership_Level_Mapping__mdt(
                Label = PARTNERSHIP_LEVEL_EXCLUSIVE,
                DeveloperName = PARTNERSHIP_LEVEL_EXCLUSIVE,
                Custom_Partnership_Type__c = PARTNERSHIP_LEVEL_EXCLUSIVE,
                Partnership_Level__c = PARTNERSHIP_LEVEL_EXCLUSIVE
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Partnership_Level_Mapping__mdt.Label,
            Partnership_Level_Mapping__mdt.DeveloperName,
            Partnership_Level_Mapping__mdt.Custom_Partnership_Type__c,
            Partnership_Level_Mapping__mdt.Partnership_Level__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PartnershipLevelMappingSelector mockPartnershipLevelMapping = (PartnershipLevelMappingSelector) mocks.mock(
            PartnershipLevelMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockPartnershipLevelMapping.getSObjectType())
            .thenReturn(Partnership_Level_Mapping__mdt.SObjectType);
        mocks.when(mockPartnershipLevelMapping.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockPartnershipLevelMapping.getSObjectFieldList()).thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockPartnershipLevelMapping);

        Schema.SObjectType typeOfObject = PartnershipLevelMappingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = PartnershipLevelMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Partnership_Level_Mapping__mdt> allPartnershipLevelMappingData = PartnershipLevelMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Partnership_Level_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Partnership Level Mapping Metadata'
        );
        System.assertEquals(
            Partnership_Level_Mapping__mdt.getAll().values().size(),
            allPartnershipLevelMappingData.size(),
            'Unexpected Error: Mismatch in list of Partnership Level Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
}