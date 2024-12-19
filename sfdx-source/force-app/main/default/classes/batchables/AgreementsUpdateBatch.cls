/**
 * @author Deloitte
 * @date 12/08/2023
 * @description Batch class to process update on the store agreements
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AgreementsUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    Id contractId;
    Set<Id> accountIds;
    Id contractAssociateAccountsId;
    Contract_Associated_Accounts__c contractAssociatedAccountRec;
    boolean batchProcessed = false;

    /**
     * @description Contructor to accept the inputs from the invoking batch class
     * @param contractAssociatedAccount
     */

    global AgreementsUpdateBatch(Contract_Associated_Accounts__c contractAssociatedAccount) {
        this.contractAssociateAccountsId = contractAssociatedAccount.Id;
        this.contractAssociatedAccountRec = contractAssociatedAccount;
        this.contractId = contractAssociatedAccount.contract__c;
        this.accountIds = getAccountIds(contractAssociatedAccount.Associated_Account_Ids__c);
    }

    /**
     * @description It queries the Contract associated Account record where batch process is enabled and the status is in Not Started / Failed
     * @param batchableContext
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return AccountsSelector.newInstance().selectByIdsForBatchProcess(accountIds);
    }

    /**
     * @description It process the Contract Associated Accounts and updates the store agreements
     * by calling the updateAgreementsForExistingStores method of AgreementsServiceImpl
     * @param batchableContext
     * @param accounts
     */
    global void execute(Database.BatchableContext batchableContext, List<Account> accounts) {
        try {
            Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

            Set<String> accountIdStringSet = new Set<String>();

            for (Id accountId : accountMap.keyset()) {
                accountIdStringSet.add(String.valueOf(accountId));
            }
            Map<Id, Set<String>> contractIdAssociatedAccountIdsMapForExisting = new Map<Id, Set<String>>{
                contractId => accountIdStringSet
            };
            Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = ContractAssociatedAccounts.newInstance(
                    (new List<Contract_Associated_Accounts__c>{ contractAssociatedAccountRec })
                )
                .getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
                    contractIdAssociatedAccountIdsMapForExisting
                );
            AgreementsService.updateAgreementsForExistingStoresWithGroups(
                associatedAccountIdGroupIdMapWithEntitlements
            );
            batchProcessed = true;
        } catch (Exception ex) {
            batchProcessed = false;
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Finish method of this batch.
     * update the contract associated accounts record bat process status to complete and set the batch process enabled flag to false
     * @JIRA# LEM-6159
     * @param batchableContext
     */
    global void finish(Database.BatchableContext batchableContext) {
        String batchStatus = 'Failed';
        boolean batchProcessEnabled = true;
        if (batchProcessed) {
            batchStatus = 'Complete';
            batchProcessEnabled = false;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Contract_Associated_Accounts__c contractAssociatedAccount = new Contract_Associated_Accounts__c(
            Id = contractAssociateAccountsId,
            Batch_Process_Status__c = batchStatus,
            Batch_Process_Enabled__c = batchProcessEnabled
        );
        uow.registerDirty(contractAssociatedAccount);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    private Set<Id> getAccountIds(String accountsStr) {
        Set<Id> accountSet = new Set<Id>();
        for (String str : accountsStr.split(',')) {
            Id accountId = Id.valueOf(str);
            accountSet.add(accountId);
        }
        return accountSet;
    }
}