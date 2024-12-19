/**
 * @author            : Aethereus
 * @date 04/12/2024
 * @description It is used to cleanup readiness check failure records
 */
public with sharing class ReadinessCheckFailureCleanupBatch implements Database.Batchable<SObject>, Schedulable {
    /**
     * @description It queries Readiness Check Failure records
     * to start the batch processing.
     * @JIRA# LEM-13963
     * @param batchableContext
     * @return List<Readiness_Check_Failure__c>
     */

    public List<Readiness_Check_Failure__c> start(Database.BatchableContext batchableContext) {
        return ReadinessCheckFailuresSelector.newInstance().selectByReadinessCheckFailureId();
    }

    /**
     * @description It initiates deletion of the passed readiness check failure.
     * @JIRA# LEM-13963
     * @param batchableContext
     * @param readinessCheckFailureRecords
     */
    public void execute(Database.BatchableContext batchableContext, List<Readiness_Check_Failure__c> readinessCheckFailureRecords) {
        SobjectDeletionService.fireRecordsDeletion(readinessCheckFailureRecords);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-13963
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description Execute method to schedule this batch class.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new ReadinessCheckFailureCleanupBatch(), 200);
    }
}