/**
 * @author DoorDash
 * @date 04/18/2023
 * @description Batch class the process the xref's marked for batch Processing/failure.
 */
public with sharing class COOXrefsProcessingBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
    private static final Integer ASYNC_GET_STORE_LIMIT = 50;
    /**
     * @description It queries all WorkOrders where PDOA date is in future
     * @JIRA# LEM-5768
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return XrefsSelector.newInstance().selectXrefsByCooProcess();
    }

    /**
     * @description It updates WorkOrder provisioning status according to PDOA dates.
     * @JIRA# LEM-5768
     * @param batchableContext
     * @param xrefs
     */
    public void execute(Database.BatchableContext batchableContext, List<Xref__c> xrefs) {
        try {
            ChangeOfOwnershipService.getDriveStoreIdsForStores(xrefs);
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-5768
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
        Database.executeBatch(new COOXrefsProcessingBatch(), ASYNC_GET_STORE_LIMIT);
    }
}