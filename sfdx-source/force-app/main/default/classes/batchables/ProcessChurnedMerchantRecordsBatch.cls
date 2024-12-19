/**
 * @author Deloitte
 * @date 11/07/2024
 * @description This batchable class to perform the Churned Merchant Operation to delete Agreement
 * and Merchant Service Records, to update Xref Records status to inactive, and to update WorkOrder
 * Records status to Dead related to Contracts of Type Churned Merchant.
 */
public with sharing class ProcessChurnedMerchantRecordsBatch implements Database.Batchable<sObject>, Schedulable {
    private static final String LOG_SERVICE_NAME = 'Churned Mx Records Cleanup';
    private static final String LOG_DOMAIN_NAME = 'Churned Mx Processing';
    private static final String PROCESS_CHURNED_MX_CONTRACTS_RECORDS_SCOPE_METADATA = 'ProcessChurnedMxContractRecordsScope';

    /**
     * @description It is used to query the Contract Records of Type Churned Merchant.
     * @JIRA #LEM-23780
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return ContractsSelector.newInstance().selectChurnedMxContracts();
    }

    /**
     * @description It is used to initiate the cleanup of records associated with
     * the Churned Mx Contract.
     * @JIRA #LEM-23780
     * @param batchableContext
     * @param churnedMxContracts
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Contract> churnedMxContracts
    ) {
        Set<Id> businessAccountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        fflib_ISObjectUnitOfWork uowforRecordsCleanup = Application.UnitOfWork.newInstance();
        try {
            for (Contract eachChurnedMxContract : churnedMxContracts) {
                businessAccountIds.add(eachChurnedMxContract.AccountId);
                contractIds.add(eachChurnedMxContract.Id);
            }
            uowforRecordsCleanup = AgreementsService.deleteChurnedMxAgreements(contractIds);
            uowforRecordsCleanup = MerchantServicesService.deleteChurnedMxServices(
                contractIds,
                uowforRecordsCleanup
            );
            uowforRecordsCleanup = WorkOrdersService.updateChurnedMxWorkOrderToDead(
                uowforRecordsCleanup,
                businessAccountIds
            );
            uowforRecordsCleanup.commitwork();
            updateContractChurnedMerchantProcessedFlagToTrue(churnedMxContracts);
        } catch (Exception processingExceptions) {
            publishExceptionToGenericLog(processingExceptions);
        }
    }

    /**
     * @description It is used to schedule this batch class.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Integer scopeSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PROCESS_CHURNED_MX_CONTRACTS_RECORDS_SCOPE_METADATA)
                .Configuration_Value__c
        );
        Database.executeBatch(new ProcessChurnedMerchantRecordsBatch(), scopeSize);
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

    /**
     * @description It is used to update the contract's churned merchant processed flag status to true
     * @param churnedMxContracts
     */
    private void updateContractChurnedMerchantProcessedFlagToTrue(
        List<Contract> churnedMxContracts
    ) {
        fflib_ISObjectUnitOfWork uowForContractUpdate = Application.UnitOfWork.newInstance();
        for (Contract eachChurnedMxContract : churnedMxContracts) {
            eachChurnedMxContract.Is_Churned_Mx_Contract_Processed__c = true;
            uowForContractUpdate.registerDirty(eachChurnedMxContract);
        }
        uowForContractUpdate.commitwork();
    }

    /**
     * @description It is used to publish error details in case of any exception/failure
     * @param processingExceptions
     */
    private void publishExceptionToGenericLog(Exception processingExceptions) {
        Logger.publish(processingExceptions, LogEntry.SeverityLevel.HIGH);
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_NAME,
                    LOG_DOMAIN_NAME,
                    GenericLogEntry.SeverityLevel.MEDIUM
                )
                .logException(processingExceptions)
        );
    }
}