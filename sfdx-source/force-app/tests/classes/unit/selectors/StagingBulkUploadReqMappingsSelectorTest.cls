/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for the Selector class for the Staging_Bulk_Upload_Request_Mapping__mdt custom metadata object.
 **/
@isTest(SeeAllData=false)
private class StagingBulkUploadReqMappingsSelectorTest {
    private static final String FIELD_MISMATCH_ERROR = 'Mismatch in field list';
    private static final String INACTIVE_REQUEST_RECORDS_ERROR = 'All request records should be active';
    private static final String NULL_RETURN_ERROR = 'Null should not be returned';
    private static final String OBJECT_TYPE_MISMATCH_ERROR = 'The object type must match Staging_Bulk_Upload_Request_Mapping__mdt';

    /**
     * @description Tests if correct fields are returned
     * @jira #LEM-15978
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        StagingBulkUploadReqMappingsSelector selectorInstance = new StagingBulkUploadReqMappingsSelector();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        System.assertEquals(
            Schema.Staging_Bulk_Upload_Request_Mapping__mdt.SObjectType,
            typeOfObject,
            OBJECT_TYPE_MISMATCH_ERROR
        );
        Test.startTest();
        List<Schema.SObjectField> fields = selectorInstance.getSObjectFieldList();
        Test.stopTest();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Staging_Bulk_Upload_Request_Mapping__mdt.CSV_Column_Name__c,
                Staging_Bulk_Upload_Request_Mapping__mdt.API_Name__c,
                Staging_Bulk_Upload_Request_Mapping__mdt.Datatype__c,
                Staging_Bulk_Upload_Request_Mapping__mdt.Active__c
            },
            fields,
            FIELD_MISMATCH_ERROR
        );
    }

    /**
     * @description Tests if active records of Staging_Bulk_Upload_Request_Mapping__mdt are returned
     * @jira #LEM-15978
     */
    @isTest
    private static void testWhenCallingGetAllActiveValuesThenRetrieveActiveMetadata() {
        Test.startTest();
        List<Staging_Bulk_Upload_Request_Mapping__mdt> activeValues = StagingBulkUploadReqMappingsSelector.newInstance()
            .getAllActiveRequestValues();
        Test.stopTest();
        for (Staging_Bulk_Upload_Request_Mapping__mdt thisValue : activeValues) {
            System.assert(thisValue.Active__c, INACTIVE_REQUEST_RECORDS_ERROR);
        }
        System.assertNotEquals(null, activeValues, NULL_RETURN_ERROR);
    }
}