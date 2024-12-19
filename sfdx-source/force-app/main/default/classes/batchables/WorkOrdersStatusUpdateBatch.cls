/**
 * @author Deloitte
 * @date 04/11/2022
 * @description Batch class to process past dated WorkOrders i.e. PDOA/PDOM/PDOT date is in past.
 * It updates WorkOrder status to Past Due for past dated PDOA and
 * "At Risk" for past dated PDOM/PDOT.
 */
public with sharing class WorkOrdersStatusUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    /**
     * @description It queries all WorkOrders where PDOA/PDOM/PDOT date is in past
     * and Status is not "Onboarding Complete".
     * @JIRA# LEM-985 & LEM-1011
     * @param batchableContext
     * @return Database.QueryLocator
     * @JIRA# LEM-985
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return WorkOrdersService.getWorkOrderRecordsForUpdateStatusFromBatch();
    }

    /**
     * @description It updates WorkOrder status according to PDOA/PDOM/PDOT dates.
     * @JIRA# LEM-985 & LEM-1011
     * @param batchableContext
     * @param workOrders
     */
    public void execute(Database.BatchableContext batchableContext, List<WorkOrder> workOrders) {
        WorkOrdersService.updateWorkOrderStatus(workOrders);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-985 & LEM-1011
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
        Database.executeBatch(new WorkOrdersStatusUpdateBatch(), 200);
    }
}