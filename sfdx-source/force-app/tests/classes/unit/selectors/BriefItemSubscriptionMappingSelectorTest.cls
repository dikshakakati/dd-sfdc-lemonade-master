@isTest(SeeAllData=false)
public class BriefItemSubscriptionMappingSelectorTest {
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Brief_Item_To_Subscription_Sync_Mapping__mdt> customMetadataMocks = new List<Brief_Item_To_Subscription_Sync_Mapping__mdt>{
            new Brief_Item_To_Subscription_Sync_Mapping__mdt(
                MasterLabel = 'Audience Targeting',
                DeveloperName = 'Adience_Targeting',
                BriefItemFieldAPIName__c = 'Audience_Targeting__c',
                SubscriptionFieldAPIName__c = 'Audience_Target_Audience__c'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Brief_Item_To_Subscription_Sync_Mapping__mdt.BriefItemFieldAPIName__c,
            Brief_Item_To_Subscription_Sync_Mapping__mdt.SubscriptionFieldAPIName__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BriefItemSubscriptionMappingSelector mockBriefItemSubscriptionMapping = (BriefItemSubscriptionMappingSelector) mocks.mock(
            BriefItemSubscriptionMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBriefItemSubscriptionMapping.getSObjectType())
            .thenReturn(Brief_Item_To_Subscription_Sync_Mapping__mdt.SObjectType);
        mocks.when(mockBriefItemSubscriptionMapping.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockBriefItemSubscriptionMapping.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBriefItemSubscriptionMapping);

        Schema.SObjectType typeOfObject = BriefItemSubscriptionMappingSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = BriefItemSubscriptionMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Brief_Item_To_Subscription_Sync_Mapping__mdt> allSyncData = BriefItemSubscriptionMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Brief_Item_To_Subscription_Sync_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Brief Item To Subscription Sync Mapping Metadata'
        );
        System.assertEquals(
            Brief_Item_To_Subscription_Sync_Mapping__mdt.getAll().values(),
            allSyncData,
            'Unexpected Error: Mismatch in list of  Brief Item To Subscription Sync Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }
    /**
     *@description tests that the metadata is retrieved successfully
     */
    @isTest
    private static void testWhenMetadataIsRetrievedThenValidate(){
        Map<Schema.SObjectField,Boolean> testMap = BriefItemSubscriptionMappingSelector.newInstance().getAllBriefItemFields();
        System.assert(testMap.keySet().size() > 0, 'No Metadata was retrieved');

    }
}