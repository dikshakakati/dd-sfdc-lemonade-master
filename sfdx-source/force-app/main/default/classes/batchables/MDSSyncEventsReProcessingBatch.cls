/**
 * @author DoorDash
 * @date 04/04/2024
 * @description Batch class the process the failed/pending MDSSyncEvents
 */
public with sharing class MDSSyncEventsReProcessingBatch implements Database.Batchable<SObject>, Schedulable {
    private static final String LOG_DOMAIN_NAME = 'Provisioning';
    private static final String LOG_SERVICE_MDS_STORE_SYNC = 'MDS Store Sync';

    /**
     * @description It queries all Integration Request Objects whose sfdc status is pending/failed and integration type is MDS Store Sync
     * @JIRA# LEM-11258
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return IntegrationRequestsSelector.newInstance().selectFailedIntegrationRequestsForMdsStoreSync();
    }

    /**
     * @description It process the Integration request object record payload
     * @JIRA# LEM-11258
     * @param batchableContext
     * @param integrationRequests
     */
    public void execute(Database.BatchableContext batchableContext, List<Integration_Request__c> integrationRequests) {
        try {
            MDSSyncEventsService.processMDSUpdates(new Set<Id>{integrationRequests[0].Id});
        } catch (Exception ex) {
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(LOG_SERVICE_MDS_STORE_SYNC,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.MEDIUM).logException(ex).logSFRecordId(new Set<String>{integrationRequests[0].Id}));
        }
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-11258
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description Execute method to schedule this batch.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new MDSSyncEventsReProcessingBatch(), 1);
    }
}