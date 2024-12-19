/**
 * @author DoorDash
 * @date 11/29/2022
 * @description Batch class that updates the Provisioning status on COO Work Orders to Ready for Provisioning the day before the PDOA date.
 */
public with sharing class WorkOrdersProvisioningStatusCOOBatch implements Database.Batchable<SObject>, Schedulable {
    @testvisible
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    /**
     * @description It queries all WorkOrders where PDOA date is in future
     * @JIRA# LEM-3648
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return WorkOrdersSelector.newInstance().selectCOOWorkOrdersBasedOnPDOADate();
    }

    /**
     * @description It updates WorkOrder provisioning status according to PDOA dates.
     * @JIRA# LEM-3648
     * @param batchableContext
     * @param workOrders
     */
    public void execute(Database.BatchableContext batchableContext, List<WorkOrder> workOrders) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkOrder eachWorkOrder : workOrders) {
            eachWorkOrder.Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING;
            eachWorkOrder.HasWorkPlansGenerated__c = true;
            uow.registerDirty(eachWorkOrder);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-3648
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
        Database.executeBatch(new WorkOrdersProvisioningStatusCOOBatch());
    }
}
