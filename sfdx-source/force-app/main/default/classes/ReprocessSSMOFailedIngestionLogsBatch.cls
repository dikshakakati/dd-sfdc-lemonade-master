/**
* @author Shiva Pochamalla
* @date 09/09/2024
* @description Batch class for ssmo errored logs reprocessing
*/
public class ReprocessSSMOFailedIngestionLogsBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    /**
     * @description Called to query all account records which picks up parent logs in failed status
     * @param batchableContext Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        IInboundIngestionLogsSelector iils = InboundIngestionLogsSelector.newInstance();
        Database.QueryLocator ql = iils.selectFailedIngestionLogs();
        return ql;
    }

    /**
     * @description To perform update logic on related child records.
     * @param batchableContext Database.BatchableContext
     * @param failedParentLogs List<SObject>
     */
    public void execute(Database.BatchableContext batchableContext, List<Inbound_ingestion_Log__c> failedParentLogs) {
        IInboundIngestionLogs iil = InboundIngestionLogs.newInstance(failedParentLogs);
        iil.updateFailedLogsWithPendingStatus();

    }

    /**
     * @description To perform update logic on all parent records and to set IsMerged flag as false
     * @param batchableContext Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {}


    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new ReprocessSSMOFailedIngestionLogsBatch());
    }


}