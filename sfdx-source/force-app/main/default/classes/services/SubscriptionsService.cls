/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service class for Subscription related logic.
 */
public inherited sharing class SubscriptionsService {
    /**
     * @description It is used get Subscription records and
     * related Account, Opportunity and Contract.
     * @JIRA# LEM-15362
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public static List<SBQQ__Subscription__c> getSubscriptionsAndRelatedInformation(
        Set<Id> subscriptionIds
    ) {
        return service().getSubscriptionsAndRelatedInformation(subscriptionIds);
    }

    /**
     * @description It is used to relate the subscriptions to the passed ContractId.
     * @JIRA# LEM-15321
     * @param contractIds
     * @return Map<Id, Set<String>>
     */
    public static Map<Id, Set<String>> getExistingSubscriptionsForContracts(Set<Id> contractIds) {
        return service().getExistingSubscriptionsForContracts(contractIds);
    }

    /**
     * @description It creates instance of SubscriptionsServiceImpl class.
     * @return ISubscriptionsService
     */
    private static ISubscriptionsService service() {
        return (ISubscriptionsService) Application.SERVICE.newInstance(ISubscriptionsService.class);
    }
}