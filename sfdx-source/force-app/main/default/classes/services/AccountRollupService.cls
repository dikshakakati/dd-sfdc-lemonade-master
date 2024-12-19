/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service class for Account roll up related logic
 */
public inherited sharing class AccountRollupService {
    /**
     * @description Roll up accounts method
     * @param accountsToRollup
     */
    public static void publishStoreRollUpEvents(Set<Id> accountsToRollup) {
        service().publishStoreRollUpEvents(accountsToRollup);
    }

    /**
     * @description Roll up accounts method for Vertical
     * @param accountsToRollup
     */
    public static void publishVerticalRollUpEvents(Set<Id> accountsToRollup) {
        service().publishVerticalRollUpEvents(accountsToRollup);
    }

    /**
     * @description It is used to publish Roll Up events for Primary Vertical roll up from Store
     * Accounts.
     * @param accountsToRollup
     */
    public static void publishStoreVerticalRollUpEvents(Set<Id> accountsToRollup) {
        service().publishStoreVerticalRollUpEvents(accountsToRollup);
    }

    /**
     * @description It is used to publish Roll Up events for Primary Vertical Roll up to Franchise Accounts from Store
     * Accounts.
     * @param accountsToRollup
     */
    public static void publishStoreVerticalRollUpToFranchiseEvents(Set<Id> accountsToRollup) {
        service().publishStoreVerticalRollUpToFranchiseEvents(accountsToRollup);
    }

    /**
     * @description It is used to populate Additional Vertical field on the direct parent Account.
     * @param franchiseAccountIds
     */
    public static void aggregateVerticalOnFranchiseParents(Set<Id> franchiseAccountIds) {
        service().aggregateVerticalOnFranchiseParents(franchiseAccountIds);
    }

    /**
     * @description Publish event for partnership status calculation
     * @param accountsToRollup
     */
    public static void publishPartnershipStatusRollUpEvents(Set<Id> accountsToRollup) {
        service().publishPartnershipStatusRollUpEvents(accountsToRollup);
    }

    /**
     * @description Generic method to redirect to appropraite roll up calculation
     * @param accountIdsByType
     */
    public static void calculateRollupsByType(Map<String, Set<Id>> accountIdsByType) {
        service().calculateRollupsByType(accountIdsByType);
    }

    private static IAccountRollupService service() {
        return (IAccountRollupService) Application.Service.newInstance(IAccountRollupService.class);
    }

    /**
     * @description Medal rank calculation by rollup on parent Accounts.
     * @param accountsToRollup
     */
    public static void publishMedalRankRollUpEvents(Set<Id> accountsToRollup) {
        service().publishMedalRankRollUpEvents(accountsToRollup);
    }
}