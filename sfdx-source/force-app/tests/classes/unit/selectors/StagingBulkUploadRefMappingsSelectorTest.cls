/**
* @author Deloitte
* @date 08/08/2024
* @description Test class for the Selector class for the Staging_Bulk_Upload_Reference_Mapping__mdt custom metadata object
**/
@isTest(SeeAllData=false)
private class StagingBulkUploadRefMappingsSelectorTest{
    private static final String TYPE_TABLET = 'Tablet';
    private static final String REQUEST_TYPE_TABLET = 'Net-New';
    private static final String OBJECT_TYPE_MISMATCH_ERROR = 'The object type must match Staging_Bulk_Upload_Reference_Mapping__mdt';
    private static final String FIELD_MISMATCH_ERROR = 'Mismatch in field list';
    private static final String INACTIVE_REFERENCE_RECORDS_ERROR = 'All reference records should be active';
    private static final String NULL_RETURN_ERROR = 'Null should not be returned';
	
    /**
    * @description Tests if correct fields are returned
    * @jira #LEM-15978
    */    
    @isTest
    private static void testWhenClassInstantiatesThenCall(){
        StagingBulkUploadRefMappingsSelector selectorInstance = new StagingBulkUploadRefMappingsSelector();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        System.assertEquals(Schema.Staging_Bulk_Upload_Reference_Mapping__mdt.SObjectType, typeOfObject, OBJECT_TYPE_MISMATCH_ERROR);
        Test.startTest();
        List<Schema.SObjectField> fields = selectorInstance.getSObjectFieldList();
	Test.stopTest();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Staging_Bulk_Upload_Reference_Mapping__mdt.Type__c,
                    Staging_Bulk_Upload_Reference_Mapping__mdt.Request_Type__c,
                    Staging_Bulk_Upload_Reference_Mapping__mdt.Record_Limit__c,
                    Staging_Bulk_Upload_Reference_Mapping__mdt.Active__c,
                    Staging_Bulk_Upload_Reference_Mapping__mdt.Error_Message__c
            },
            fields,
            FIELD_MISMATCH_ERROR
        );
    }
    
    /**
    * @description Tests if active records of Staging_Bulk_Upload_Reference_Mapping__mdt are returned
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenCallingGetAllActiveValuesThenRetrieveActiveMetadata(){
        String referenceType = TYPE_TABLET;
        String referenceRequestType = REQUEST_TYPE_TABLET;
	Test.startTest();
        List<Staging_Bulk_Upload_Reference_Mapping__mdt> activeValues = StagingBulkUploadRefMappingsSelector.newInstance().getAllActiveReferenceAndRequestValues(referenceType, referenceRequestType);
        Test.stopTest();
        for(Staging_Bulk_Upload_Reference_Mapping__mdt thisValue : activeValues){
            System.assert(thisValue.Active__c, INACTIVE_REFERENCE_RECORDS_ERROR);
        }
        
        System.assertNotEquals(null, activeValues, NULL_RETURN_ERROR);
    }
}
