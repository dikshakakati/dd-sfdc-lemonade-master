/**
 * @author Deloitte
 * @date 28/11/2022
 * @description This batch class performs child record update for merged parent accounts.
 */
public class ProcessMergedAccountChildRecords implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    @TestVisible
    private Set<Id> parentAccountIds = new Set<Id>();
    private static final String PROCESS_MERGED_ACCOUNT_CHILD_RECORDS_SCOPE_METADATA = 'ProcessMergedAccountChildRecordsScope';
    private Id scheduledJobId;
    private static final String STORE_RECORD_TYPE = 'Store';

    /**
     * @description constructor to instantiate variables.
     * @param scheduledJobId
     */
    public ProcessMergedAccountChildRecords(Id scheduledJobId) {
        this.scheduledJobId = scheduledJobId;
    }
    /**
     * @description Default constructor.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public ProcessMergedAccountChildRecords() {
        //Default constructor which called from AccountServiceImpl Class.
    }
    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Integer scopeSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_MERGED_ACCOUNT_CHILD_RECORDS_SCOPE_METADATA)
                .Configuration_Value__c
        );
        Database.executeBatch(
            new ProcessMergedAccountChildRecords(schedulableContext.getTriggerId()),
            scopeSize
        );
    }

    /**
     * @description Called to query all account records where Is Merged flag is checked
     * @param batchableContext Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return AccountsSelector.newInstance()
            .selectRelatedChildRecordsByAccountsWithIsMergedEnabled();
    }

    /**
     * @description To perform update logic on related child records.
     * @param batchableContext Database.BatchableContext
     * @param parentAccounts List<SObject>
     */
    public void execute(Database.BatchableContext batchableContext, List<Account> parentAccounts) {
        List<Account> childAccounts = new List<Account>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Initiative__c> initiatives = new List<Initiative__c>();
        List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>();
        List<WorkOrder> workOrders = new List<WorkOrder>();

        for (Account eachParentAccount : parentAccounts) {
            //LEM-24741: To collect all child accounts
            if (eachParentAccount.Record_Type_Name__c == STORE_RECORD_TYPE) {
                childAccounts.add(eachParentAccount);
            }
            for (Account eachChildAccount : eachParentAccount.ChildAccounts) {
                childAccounts.add(eachChildAccount);
            }

            for (Opportunity eachOpportunity : eachParentAccount.Opportunities) {
                opportunities.add(eachOpportunity);
            }

            for (Initiative__c eachInitiative : eachParentAccount.Initiatives__r) {
                initiatives.add(eachInitiative);
            }

            for (Payment_Account__c eachPaymentAccount : eachParentAccount.Payment_Accounts__r) {
                paymentAccounts.add(eachPaymentAccount);
            }
            // Collect work orders for further processing
            for (WorkOrder eachWorkOrder : eachParentAccount.WorkOrders) {
                workOrders.add(eachWorkOrder);
            }
            parentAccountIds.add(eachParentAccount.Id);
        }
        AccountsService.processMergedAccountsRelatedRecords(childAccounts);
        OpportunitiesService.processMergedAccountsRelatedRecords(opportunities);
        InitiativesService.processMergedAccountsRelatedRecords(initiatives);
        PaymentAccountsService.processMergedAccountsRelatedRecords(paymentAccounts);
        // LEM-3643 - Initiate Work Orders processes
        ParentWorkOrderSyncService.processMergedAccountsRelatedRecords(workOrders);
        WorkOrdersService.processMergedAccountsRelatedRecords(workOrders);
    }

    /**
     * @description To perform update logic on all parent records and to set IsMerged flag as false
     * @param batchableContext Database.BatchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {
        AccountsService.processMergedParentAccounts(parentAccountIds);
        // Query the AsyncApexJob object to retrieve the current job's information.
        if (!Test.isRunningTest()) {
            //Abort the current scheduled job, this stops the job from running more than once.
            system.abortJob(scheduledJobId);
        }
    }
}