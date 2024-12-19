/* @author Shiva Pochamalla
 * @description test class for ReprocessSSMOFailedIngestionBatch
 */
@isTest
public with sharing class ReprocessSSMOFailedIngestionBatchTest {
    private static final String STATUS_FAILED = 'Failed';
    private static final String SSMO_UUID = 'a123456c-595d-4891-99d8-3d8c931d9f82';
    /**
     * @description To test failed status update to pending
     */
    @isTest
    private static void testWhenInboundIngestionLogFailedThenReprocessToUpdateStatusToPending() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Integration_Type__c = 'Onboarding Event',
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED,
            Source__c = 'SSMO'
        );
        insert parentInboundIngestionLog;

        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            parent_log__c = parentInboundIngestionLog.id,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED,
            Integration_Type__c = 'Onboarding Event',
            Source__c = 'SSMO'
        );
        insert childInboundIngestionLog;

        test.startTest();

        Database.executeBatch(new ReprocessSSMOFailedIngestionLogsBatch());

        test.stopTest();
        Inbound_Ingestion_Log__c ilog = [
            SELECT id, status__c, retry_count__c, Stack_Trace__c, Error_Message__c
            FROM Inbound_Ingestion_Log__c
            WHERE id = :parentInboundIngestionLog.Id
            LIMIT 1
        ];
        system.assertEquals('Pending', ilog.status__c, 'Log Status updated to Pending');
    }

    /**
     * @description To test schedule job for reprocessing ssmo errors
     */
    @isTest
    private static void testWhenInboundIngestionLogFailedThenScheduleReprocessToUpdateBatch() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Integration_Type__c = 'Onboarding Event',
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED,
            Source__c = 'SSMO'
        );
        insert parentInboundIngestionLog;

        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            parent_log__c = parentInboundIngestionLog.id,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED,
            Integration_Type__c = 'Onboarding Event',
            Source__c = 'SSMO'
        );
        insert childInboundIngestionLog;
        test.startTest();

        SchedulableContext sc = null;
        ReprocessSSMOFailedIngestionLogsBatch tsc = new ReprocessSSMOFailedIngestionLogsBatch();
        tsc.execute(sc);

        test.stopTest();
        Inbound_Ingestion_Log__c ilog = [
            SELECT id, status__c, retry_count__c
            FROM Inbound_Ingestion_Log__c
            WHERE id = :parentInboundIngestionLog.Id
            LIMIT 1
        ];
        system.assertEquals('Pending', ilog.status__c, 'Log Status updated to Pending');
    }
}