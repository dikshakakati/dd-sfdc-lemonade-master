/**
 * @author DoorDash
 * @date 05/02/2023
 * @description Batch class to process store agreements
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AgreementsCreationBatch implements Database.Batchable<SObject>, Database.Stateful {
    Id contractId;
    Set<Id> accountIds;
    Id contractAssociateAccountsId;
    boolean batchProcessed = false;
    Contract_Associated_Accounts__c contractAssociatedAccountRec;

    /**
     * @description Contructor to accept the inputs from the invoking batch class
     * @JIRA# LEM-6159
     * @param contractAssociatedAccount
     */

    global AgreementsCreationBatch(Contract_Associated_Accounts__c contractAssociatedAccount) {
        this.contractId = contractAssociatedAccount.contract__c;
        this.contractAssociateAccountsId = contractAssociatedAccount.Id;
        this.accountIds = getAccountIds(contractAssociatedAccount.Associated_Account_Ids__c);
        this.contractAssociatedAccountRec = contractAssociatedAccount;
    }

    /**
     * @description It queries all Contract associated Accounts records where batch process is enabled and the status is in Not Started / Failed
     * @JIRA# LEM-6159
     * @param batchableContext
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return AccountsSelector.newInstance().selectByIdsForBatchProcess(accountIds);
    }

    /**
     * @description It process the accounts and creates the store agreements for the contract id and account id combination
     * @JIRA# LEM-6159
     * @param batchableContext
     * @param accounts
     */
    global void execute(Database.BatchableContext batchableContext, List<Account> accounts) {
        try {
            Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

            List<Agreement__c> agreements = AgreementsSelector.newInstance()
                .selectAgreementsByContractAndAccount(
                    new Set<Id>{ contractId },
                    accountMap.keyset()
                );

            Set<String> accountIdStringSet = new Set<String>();

            for (Id accountId : accountMap.keyset()) {
                accountIdStringSet.add(String.valueOf(accountId));
            }

            if (!agreements.isEmpty()) {
                for (Agreement__c agreement : agreements) {
                    if (accountMap.containskey(agreement.Account__c)) {
                        accountIdStringSet.remove(agreement.Account__c);
                    }
                }
            }

            Map<Id, Set<String>> contractIdAssociatedAccountIdsMap = new Map<Id, Set<String>>{
                contractId => accountIdStringSet
            };

            List<Contract> contractList = ContractsSelector.newInstance()
                .selectById(new Set<Id>{ contractId });
            Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = ContractAssociatedAccounts.newInstance(
                    (new List<Contract_Associated_Accounts__c>{ contractAssociatedAccountRec })
                )
                .getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
                    contractIdAssociatedAccountIdsMap
                );
            //Calling Agreements Service to create Agreement Records from Contract.
            AgreementsService.createAgreementsfromContractsWithGroup(
                contractList,
                contractIdAssociatedAccountIdsMap,
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
            Id accountId = str;
            accountSet.add(accountId);
        }
        return accountSet;
    }
}