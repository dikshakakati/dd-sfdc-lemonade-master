/**
 * @author DoorDash
 * @date 31/08/2023
 * @description Batch class to process accounts and stamp Rate Change Request Id
 * for the uploaded list of storeIds
 */
public inherited sharing class AccountUpdateForActiveRatesBatch implements Database.Batchable<SObject> {
    public List<Account> accountsToProcess = new List<Account>();
    public Id rateChangeRequestId;
    public Set<Id> accountsToProcessIds = new Set<Id>();

    /**
     * @description Contructor to accept the inputs from the invoking batch class from Manage Pricing controller
     * @param accountsToProcessIds
     * @param rateChangeRequestId
     */
    public AccountUpdateForActiveRatesBatch(Set<Id> accountsToProcessIds, Id rateChangeRequestId) {
        this.accountsToProcessIds = accountsToProcessIds;
        this.rateChangeRequestId = rateChangeRequestId;
    }

    /**
     * @description It queries all store Accounts records where Rate Change Request is null
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        if (this.accountsToProcessIds.size() == 0) {
            return null;
        }
        return AccountsSelector.newInstance().getStoreAccountsById(accountsToProcessIds);
    }

    /**
     * @description It process the accounts added in this records text area feild Associated_Account_Ids__c field
     * @param batchableContext
     * @param storeAccounts
     */
    public void execute(Database.BatchableContext batchableContext, List<Account> storeAccounts) {
        AccountsService.updateRateChangeRequestOnAccount(storeAccounts, rateChangeRequestId);
    }

    /**
     * @description Finish method of this batch.
     * Calls the rateChangeRequestService method to update Rate Change Request Record
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {
        RateChangeRequestService.setRateChangeRequestStoreUpdatedFlagTrue(rateChangeRequestId);
    }
}