/**
 * @description This batchable class calculates Ultimate Parent for Account with Hierarchy of parent Accounts to 5 levels up.
 * @author Deloitte
 * @date 04/03/2022
 */
public class UltimateParentUpdateBatchable implements Database.Batchable<SObject>, Database.Stateful {
    @TestVisible
    private Set<Id> accountIds = new Set<Id>();

    /**
     * @description Constructor to perform before update processing\
     * @param accountIds Set<Id>
     */
    public UltimateParentUpdateBatchable(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    /**
     * @description Called to perform before update processing\
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AccountsSelector.newInstance().selectAllParents(accountIds);
    }

    /**
     * @description Called to perform before update processing\
     * @param batchableContextRef Database.BatchableContext
     * @param modifiedAccounts List<SObject>
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<SObject> modifiedAccounts
    ) {
        List<Account> accountReferences = new List<Account>((List<Account>) modifiedAccounts);
        AccountsService.updateUltimateParent(accountReferences);
    }

    /**
     * @description Called to perform before update processing\
     * @param batchableContextRef Database.BatchableContext
     */
    public void finish(Database.BatchableContext batchableContextRef) {
        System.debug(LoggingLevel.INFO, 'Need to add Error Logging');
    }
}