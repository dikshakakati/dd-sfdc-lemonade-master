/**
* @description This is test class for MDSSyncMappingsSelector class
* added new field MDS_Sync_Mapping__mdt to the class & test class
*/
@isTest
public with sharing class MDSSyncMappingsSelectorTest {
        private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
	private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be OrderProtocolMapping custom metadata';
    private static final String ASSERT_MESSAGE_COUNT_NOT_MATCHING = 'assert count not matching';

/**
* @description This method used to test MDSSyncMappingsSelector class
*/
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
             MDS_Sync_Mapping__mdt.Active__c,
                    MDS_Sync_Mapping__mdt.MasterLabel,
                    MDS_Sync_Mapping__mdt.DeveloperName,
                    MDS_Sync_Mapping__mdt.DDMx_Update_Type__c,
                    MDS_Sync_Mapping__mdt.DDMx_Object_Name__c,
                    MDS_Sync_Mapping__mdt.DDMx_Field_to_Update__c,
                    MDS_Sync_Mapping__mdt.Target_Field_Data_Type__c
        };

        MDSSyncMappingsSelector mdsSyncMappingsSelectorInstance = new MDSSyncMappingsSelector();
        Schema.SObjectType typeOfObject = mdsSyncMappingsSelectorInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = mdsSyncMappingsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            MDS_Sync_Mapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );

    }

    @isTest
    private static void testWhenGetActiveMDSSyncMappingsThenReturnMetadata() {
        MDSSyncMappingsSelector selector = new MDSSyncMappingsSelector();
        List<MDS_Sync_Mapping__mdt> mdsSyncMapping = selector.getActiveMDSSyncMappings();
        Assert.isTrue(!mdsSyncMapping.isEmpty(), 'MDS sync mappings are not returned as expected');
    }

     /**
     * @description To test Order Protocol Mapping selector standard methods.
     */
    @isTest
    private static void testWhenGetActiveMdsRecsThenReturnMetatdata() {
        List<MDS_Sync_Mapping__mdt> settingList = getMDSSyncMapping();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
        fflib_ISObjectUnitOfWork.class
        );
        IMDSSyncMappingsSelector metaDataMappingSelector =
        (IMDSSyncMappingsSelector) mocks.mock(MDSSyncMappingsSelector.class);

        mocks.startStubbing();
        mocks.when(metaDataMappingSelector.SObjectType()).thenReturn(MDS_Sync_Mapping__mdt.SObjectType);
        mocks.when(metaDataMappingSelector.getActiveMDSSyncMappings()).thenReturn(settingList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(metaDataMappingSelector);
        Application.UnitOfWork.setMock(mockUow);

        List<MDS_Sync_Mapping__mdt> settingResult = MDSSyncMappingsSelector.newInstance().getActiveMDSSyncMappings();
            System.assertEquals(1,settingResult.size(),ASSERT_MESSAGE_COUNT_NOT_MATCHING);
    }

    private static List<MDS_Sync_Mapping__mdt> getMDSSyncMapping(){
        return new List<MDS_Sync_Mapping__mdt>{
            new MDS_Sync_Mapping__mdt(
                MasterLabel = 'MDS Sync Mapping',
                Active__c = true
            )
        };
    }
}