/**
 * @description Handler to perform all trigger based actions on Subscription
 * @author Deloitte
 * @date 2023-06-24
 */
public class SubscriptionHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor to instantiate a List of Subscription
     * @param sObjectList
     */
    public SubscriptionHandler(List<SBQQ__Subscription__c> sObjectList) {
        super(sObjectList);
        setContextBypass(SBQQ__Subscription__c.SObjectType, SubscriptionHandler.class);
    }
    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return SubscriptionHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new SubscriptionHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after Update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        OrderItemsService.populateActiveRatesOnPrimaryOrderItems(recordsWithUpdatedActiveRates());
        Subscriptions.newInstance(this.records).updateContractWithSubscritionProductFamily();
    }

    /**
     * @description Common method to return subscription records when Subscription Rate Change and Active rates are updated
     * @return List<SBQQ__Subscription__c>
     */
    private List<SBQQ__Subscription__c> recordsWithUpdatedActiveRates() {
        return new List<SBQQ__Subscription__c>(
            (List<SBQQ__Subscription__c>) getChangedRecords(
                new Set<SObjectField>{
                    SBQQ__Subscription__c.Subscription_Rate_Change__c,
                    SBQQ__Subscription__c.Active_fee__c,
                    SBQQ__Subscription__c.Active_commission__c
                }
            )
        );
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        //Set<Id> subscriptionIds = new Set<Id>(
        //  new Map<Id, SBQQ__Subscription__c>((List<SBQQ__Subscription__c>) this.records).keySet()
        //);
        Subscriptions.newInstance(this.records).callContractServiceToUpdateContractName();
        Subscriptions.newInstance(this.records).evaluateAndInitalizeForWorkOrderCreation();
        Subscriptions.newInstance(this.records).updateContractWithSubscritionProductFamily();
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Subscriptions.newInstance(subscriptionsWithQuoteLines()).populateQuoteLineGroup();
    }

    /**
     * @description Common method to return subscription records if quote lines are not null
     * @return List<SBQQ__Subscription__c>
     */
    private List<SBQQ__Subscription__c> subscriptionsWithQuoteLines() {
        return new List<SBQQ__Subscription__c>(
            (List<SBQQ__Subscription__c>) getRecordsWithNotBlankFieldValues(
                SBQQ__Subscription__c.SBQQ__QuoteLine__c
            )
        );
    }
}