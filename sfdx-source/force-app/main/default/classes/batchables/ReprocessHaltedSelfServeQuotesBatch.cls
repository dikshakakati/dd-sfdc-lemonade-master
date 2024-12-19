/**
 * @author Deloitte
 * @date 12/03/2024
 * @description This batchable class is used to perform the updates on the self-serve
 * quotes that got stuck in Approved due to managed package row lock error due to
 * multiple cpq queueable calculator jobs running in parallel. It updates such quotes to primary and
 * contract signed.
 */
public with sharing class ReprocessHaltedSelfServeQuotesBatch implements Database.Batchable<sObject>, Schedulable {
    private static final String PROCESS_SELF_SERVE_HALTED_QUOTE_RECORDS_SCOPE_METADATA = 'ProcessSelfServeHaltedQuotesScope';

    /**
     * @description It is used to query the non-primary quotes that are stuck in Approved status.
     * @JIRA #LEM-23462
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return QuotesSelector.newInstance().selectSelfServeHaltedQuotes();
    }

    /**
     * @description It is used to initiate the updates on the self-serve stuck quotes.
     * @JIRA #LEM-23462
     * @param batchableContext
     * @param selfServeStuckQuotes
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<SBQQ__Quote__c> selfServeStuckQuotes
    ) {
        if (selfServeStuckQuotes.isEmpty()) {
            return;
        }
        HaltedSelfServeQuotesReprocessorService.initiateHaltedSelfServeQuotesReprocessing(
            selfServeStuckQuotes
        );
    }

    /**
     * @description It is used to schedule this batch class.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Integer scopeSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_SELF_SERVE_HALTED_QUOTE_RECORDS_SCOPE_METADATA)
                .Configuration_Value__c
        );
        Database.executeBatch(new ReprocessHaltedSelfServeQuotesBatch(), scopeSize);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}