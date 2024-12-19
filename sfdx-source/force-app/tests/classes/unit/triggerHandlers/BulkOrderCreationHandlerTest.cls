/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for BulkOrderCreationsHandler class.
 */
@isTest
private class BulkOrderCreationHandlerTest {
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String SUB_TYPE_NET_NEW = 'Net-New';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String BATCH_JOB_STATUS_MISMATCH = 'Unexpected result: Batch Job Status does not match';
    /**
     * @description It is used to test the bulk order creation batch execution on insertion of bulk order creation
     * platform event with the referenceIds.
     */
    @isTest
    private static void testWhenPlatformEventPublishedThenInvokeBulkOrderCreationBatch() {
        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Bulk_Order_Creation__e bulkOrderEventId = (Bulk_Order_Creation__e) new Fake(Bulk_Order_Creation__e.class)
        .setField(Bulk_Order_Creation__e.Bulk_Order_Reference_Id__c, stagingReferenceRec.Id)
        .toSObject();

        fflib_SObjectDomain.Test.Database.onInsert(new List<Bulk_Order_Creation__e>{ bulkOrderEventId });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(BulkOrderCreationsHandler.class);
        Test.startTest();
        BulkOrderCreationBatch bulkOrderCreationBatch = new BulkOrderCreationBatch(new Set<String>{stagingBulkReferenceId});
        Id batchJobId = Database.executeBatch(bulkOrderCreationBatch);
        Test.stopTest();
        AsyncApexJob asyncJobId = [select id,status from AsyncApexJob where id =:batchJobId];
        System.assertEquals(
            'Completed',
            asyncJobId.status,
            BATCH_JOB_STATUS_MISMATCH
        );
    }
}
