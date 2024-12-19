/**
 * @author Deloitte
 * @date 10/06/2022
 * @description Test class for StaticConfigurationsSelector class.
 */
@isTest(seeAllData=false)
private class StaticConfigurationsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_CONFIGURATION_VALUE = 'Unexpected result: There is a mismatch in configuration value.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_DEVELOPER_NAME = 'Unexpected result: There is a mismatch in developer name.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Static Configuartions Metadata.';
    private static final String METADATA_CONFIGURATION_VALUE = '15';
    private static final String METADATA_DEV_NAME = 'Queries_Allowed_Limit';
    private static final String METADATA_MASTER_LABEL = 'Queries_Allowed_Limit';

    @isTest
    private static void testWhenSelectByLabelCalledThenReturnAppropriateRecord() {
        List<Static_Configurations__mdt> customMetadataMocks = new List<Static_Configurations__mdt>{
            new Static_Configurations__mdt(
                Label = 'Corporate Hierarchy Report Id',
                DeveloperName = 'Corporate_Hierarchy_Report_Id'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Static_Configurations__mdt.Label,
            Static_Configurations__mdt.DeveloperName,
            Static_Configurations__mdt.Configuration_Value__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StaticConfigurationsSelector mockStaticConfigurations = (StaticConfigurationsSelector) mocks.mock(
            StaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.getSObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.selectByDeveloperName('Corporate_Hierarchy_Report_Id'))
            .thenReturn(customMetadataMocks);
        mocks.when(mockStaticConfigurations.getSObjectFieldList()).thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Schema.SObjectType typeOfObject = StaticConfigurationsSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = StaticConfigurationsSelector.newInstance()
            .getSObjectFieldList();
        List<Static_Configurations__mdt> staticConfigurationsSelectorResult = StaticConfigurationsSelector.newInstance()
            .selectByDeveloperName('Corporate_Hierarchy_Report_Id');
        System.assertEquals(
            Static_Configurations__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Static Configuration Metadata'
        );
        System.assertEquals(
            staticConfigurationsSelectorResult[0].DeveloperName,
            'Corporate_Hierarchy_Report_Id',
            'Unexpected Error: Mismatch in Static Configuration Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description To test Static Configurations Metadata query when instance developer name is passed.
     */
    @isTest
    private static void testWhenGetInstanceValueCalledThenCorrespondingCustomMetadataRecordReturned() {
        List<Static_Configurations__mdt> customMetadataMocks = new List<Static_Configurations__mdt>{
            new Static_Configurations__mdt(
                MasterLabel = METADATA_MASTER_LABEL,
                DeveloperName = METADATA_DEV_NAME,
                Configuration_Value__c = METADATA_CONFIGURATION_VALUE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StaticConfigurationsSelector mockStaticConfigurations = (StaticConfigurationsSelector) mocks.mock(
            StaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.getSObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(METADATA_DEV_NAME))
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Schema.SObjectType typeOfObject = StaticConfigurationsSelector.newInstance().SObjectType();
        Static_Configurations__mdt staticConfigurationsSelectorResult = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(METADATA_DEV_NAME);
        System.assertEquals(
            Static_Configurations__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            staticConfigurationsSelectorResult.DeveloperName,
            METADATA_DEV_NAME,
            ASSERT_MESSAGE_MISMATCH_IN_DEVELOPER_NAME
        );
        System.assertEquals(
            staticConfigurationsSelectorResult.Configuration_Value__c,
            METADATA_CONFIGURATION_VALUE,
            ASSERT_MESSAGE_MISMATCH_IN_CONFIGURATION_VALUE
        );
    }
}