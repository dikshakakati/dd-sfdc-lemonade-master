/**
 * @author Deloitte
 * @date   14/03/2022
 * @description This is the service interface for Account roll up related logic
 */
public interface IAccountRollUpService {
    /**
     * @description Roll up accounts method
     * @param accountsToRollup
     */
    void publishStoreRollUpEvents(Set<Id> accountsToRollup);

    /**
     * @description Roll up accounts method for Vertical
     * @param accountsToRollup
     */
    void publishVerticalRollUpEvents(Set<Id> accountsToRollup);

    /**
     * @description Roll up Store Account verticals to direct Parent Accounts.
     * @param accountsToRollup
     */
    void publishStoreVerticalRollUpEvents(Set<Id> accountsToRollup);

    /**
     * @description It is used to publish Roll Up events for Primary Vertical Roll up to Franchise Accounts from Store
     * Accounts.
     * @param accountsToRollup
     */
    void publishStoreVerticalRollUpToFranchiseEvents(Set<Id> accountsToRollup);

    /**
     * @description It is used to populate Additional Vertical field on the direct parent Account.
     * @param franchiseAccountIds
     */
    void aggregateVerticalOnFranchiseParents(Set<Id> franchiseAccountIds);
    /**
     * @description Publish event for partnership status calculation
     * @param accountsToRollup
     */
    void publishPartnershipStatusRollUpEvents(Set<Id> accountsToRollup);

    /**
     * @description Generic method to redirect to appropraite roll up calculation
     * @param accountIdsByType
     */
    void calculateRollupsByType(Map<String, Set<Id>> accountIdsByType);
    
    /**
     * @description Publish event for Medal Rank calculation.
     * @param accountsToRollup
     */
    void publishMedalRankRollUpEvents(Set<Id> accountsToRollup);

}