/**
 * @author ATG
 * @date 11/01/23
 * @description test class for the BriefItemTrackingSelector
 */
@isTest(SeeAllData=false)
private class BriefItemTrackingSelectorTest {
    /**
     * @description this method tests the instantiation of the tracking selector
     */
    @isTest
    private static void testWhenClassInstatiatesThenCall(){
        BriefItemTrackingSelector selector = new BriefItemTrackingSelector();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            Schema.Brief_Item_Tracking__mdt.SObjectType,
            typeOfObj,
            'The object type must be brief Item Tracking meta data'
        );
    }
    /**
     *@description tests that the metadata is retrieved successfully
     */
    @isTest
    private static void testWhenMetadataIsRetrievedThenValidate(){
        Map<Schema.SObjectField,Boolean> testMap = BriefItemTrackingSelector.newInstance().getAllTrackingFields();
        System.assert(testMap.keySet().size() > 0, 'No Metadata was retrieved');

    }
    /**
     * @description tests that api names exist in the metadata
     */
    @isTest
    private static void testWhenMetadataIsRetrievedThenValidateTrackingAPINames(){
        List<Schema.SObjectField> trackingList = BriefItemTrackingSelector.newInstance().getSObjectFieldList();
        System.assertEquals(2, trackingList.size(),'No API fields were retrieved from Metadata');
    }
    /**
     * @description tests that when metadata is retrieved, all values are accessible
     */
    @isTest
    private static void testWhenMetadataIsRetrievedThenValidateAllTrackingFieldsReturned(){
        List<Brief_Item_Tracking__mdt> trackingMetaData = BriefItemTrackingSelector.newInstance().getAllValues();
        System.assert(trackingMetaData != null, 'No tracking metadata was retrieved');
    }
}