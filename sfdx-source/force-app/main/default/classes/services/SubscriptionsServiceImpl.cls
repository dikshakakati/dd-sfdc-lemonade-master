/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service Implementation class for Subscription related logic.
 */
public inherited sharing class SubscriptionsServiceImpl implements ISubscriptionsService {
    private static final String STOREFRONT_PLATFORM = 'Storefront';
    /**
     * @description It is used get Subscription records and
     * related Account, Opportunity and Contract.
     * @JIRA# LEM-15362
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    public List<SBQQ__Subscription__c> getSubscriptionsAndRelatedInformation(
        Set<Id> subscriptionIds
    ) {
        List<SBQQ__Subscription__c> subscriptions = SubscriptionSelector.newInstance()
            .getSubscriptionsForWorkOrderCreation(subscriptionIds);
        return subscriptions;
    }

    /**
     * @description It is used to relate the subscriptions to the passed ContractId.
     * @JIRA# LEM-15321
     * @param contractIds
     * @return Map<Id, Set<String>>
     */
    public Map<Id, Set<String>> getExistingSubscriptionsForContracts(Set<Id> contractIds) {
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>();
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectActiveSubscriptionsList(contractIds, false)
        ) {
            if (String.isBlank(eachSubscription.SBQQ__Product__r.Work_Order_Type__c)) {
                continue;
            }
            if (!contractIdToSubscriptionsPresent.containsKey(eachSubscription.SBQQ__Contract__c)) {
                contractIdToSubscriptionsPresent.put(
                    eachSubscription.SBQQ__Contract__c,
                    new Set<String>()
                );
            }
            contractIdToSubscriptionsPresent.get(eachSubscription.SBQQ__Contract__c)
                .add(eachSubscription.SBQQ__Product__r.Work_Order_Type__c);
        }
        return contractIdToSubscriptionsPresent;
    }
}