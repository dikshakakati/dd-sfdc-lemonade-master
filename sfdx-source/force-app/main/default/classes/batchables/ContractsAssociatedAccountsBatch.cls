/**
 * @author DoorDash
 * @date 05/02/2023
 * @description Batch class to process store agreements
 */
public with sharing class ContractsAssociatedAccountsBatch implements Database.Batchable<SObject>, Schedulable, Database.stateful {
    public List<Contract_Associated_Accounts__c> contratAssociatedAccountToProcess = new List<Contract_Associated_Accounts__c>();
    public Set<Id> conAssociatedAccountIds = new Set<Id>();

    /**
     * @description Contructor to accept the inputs from the invoking batch class from trigger
     * @JIRA# LEM-6159
     * @param conAssociatedAccountIds
     */
    public ContractsAssociatedAccountsBatch(Set<Id> conAssociatedAccountIds) {
        this.conAssociatedAccountIds = conAssociatedAccountIds;
    }

    /**
     * @description Empty Contructor to accept the inputs from the invoking batch class from Scheduler
     * @JIRA# LEM-6159
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public ContractsAssociatedAccountsBatch() {
    }

    /**
     * @description It queries all Contract associated Accounts records where batch process is enabled and the status is in Not Started / Failed
     * if called from trigger context (conAssociatedAccountIds,size()>0) invoke the ContractAssociatedAccountsSelector.selectByBatchProcessEnabledAndStatusIds
     * if called from scheduler, invoke the ContractAssociatedAccountsSelector.selectByBatchProcessEnabledAndStatus
     * @JIRA# LEM-6159
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        if (this.conAssociatedAccountIds.size() > 0) {
            return ContractAssociatedAccountsSelector.newInstance()
                .selectByBatchProcessEnabledAndStatusIds(conAssociatedAccountIds);
        } else {
            return ContractAssociatedAccountsSelector.newInstance()
                .selectByBatchProcessEnabledAndStatus();
        }
    }

    /**
     * @description It process the accounts added in this records text area feild Associated_Account_Ids__c field
     * @JIRA# LEM-6159
     * @param batchableContext
     * @param contratAssociatedAccounts
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Contract_Associated_Accounts__c> contratAssociatedAccounts
    ) {
        contratAssociatedAccountToProcess.addAll(contratAssociatedAccounts);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-6159
     * @param batchableContext
     */
    @SuppressWarnings('PMD.operationwithlimitsinloop')
    public void finish(Database.BatchableContext batchableContext) {
        if (!contratAssociatedAccountToProcess.isEmpty()) {
            for (Contract_Associated_Accounts__c ca : contratAssociatedAccountToProcess) {
                if (ca.IsProcessingExistingStores__c == false) {
                    Database.executeBatch(new AgreementsCreationBatch(ca));
                } else {
                    Database.executeBatch(new AgreementsUpdateBatch(ca));
                }
            }
        }
    }

    /**
     * @description Execute method to schedule this batch.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new ContractsAssociatedAccountsBatch(), 1);
    }
}