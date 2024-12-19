/**
 * @description This batch class will reconcile data for account attributes to handle top down automation.
 * @author Deloitte
 * @date 05/18/2022
 */
public class UpdateAccFieldsTopDownAutomationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    /**
     * @description Called to perform the query processing
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AccountsSelector.newInstance().selectAccountAttributesForTopDownAutomationBatch();
    }

    /**
     * @description Called to perform the execution of batch
     * @param batchableContextRef Database.BatchableContext
     * @param accountRecords
     */
    public void execute(
        Database.BatchableContext batchableContextRef,List<Account> accountRecords
    ) {
        AccountsService.updateAccountAttributesTopDownAutomation(accountRecords);
    }

    /**
     * @description Called to perform any left over processing if anything is needed
     * @param batchableContextRef Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextRef) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateAccFieldsTopDownAutomationBatch(), 200);
    }
}