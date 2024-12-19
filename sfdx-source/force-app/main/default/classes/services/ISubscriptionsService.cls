/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service Interface for Subscription related logic.
 */
public interface ISubscriptionsService {
    /**
     * @description It is used get Subscription records and
     * related Account, Opportunity and Contract.
     * @JIRA# LEM-15362
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> getSubscriptionsAndRelatedInformation(Set<Id> subscriptionIds);

    /**
     * @description It is used to relate the subscriptions to the passed ContractId.
     * @JIRA# LEM-15321
     * @param contractIds
     * @return Map<Id, Set<String>>
     */
    Map<Id, Set<String>> getExistingSubscriptionsForContracts(Set<Id> contractIds);
}