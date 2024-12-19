/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Batch class to process creation of Opportunities.
 */
public with sharing class CreateRenewalOpportunityBatch implements Database.Batchable<sObject>, Database.stateful, Schedulable {
    @TestVisible
    private static Boolean forceException = true;
    /**
     * @description Called to query all records with partnership expiration date in next 90 days
     * for which renewal opportunity is not created.
     * @param batchableContextRef Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContextRef) {
        return new AccountsSelector().getAccountsForRunningRenewalBatch();
    }

    /**
     * @description Called to create renewal Opportunities.
     * @param batchableContextRef Database.BatchableContext
     * @param accountsToStartBatch
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<Account> accountsToStartBatch
    ) {
        try {
            // We can force this exception by setting forceException to true
            // in our test method
            if ((Test.IsRunningTest() && forceException && accountsToStartBatch == null)) {
                throw new StringException('Exception forced from Test Class');
            }
            OpportunitiesService.createRenewalOpportunityFromBatch(accountsToStartBatch);
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description Operations to be performed after batch execution will be added here
     * @param batchableContextRef Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextRef) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new createRenewalOpportunityBatch());
    }
}