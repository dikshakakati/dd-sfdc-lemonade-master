/**
 * @author Deloitte
 * @date 09/10/2023
 * @description Batch class that updates the Subscription Active rate for future effective date on daily basis.
 */
public with sharing class UpdateSubscriptionActiveRatesBatch implements Database.Batchable<SObject> {
    public Set<Id> rateChangeIds = new Set<Id>();

    /**
     * @description Contructor to accept the inputs from the invoking batch class from trigger
     * @JIRA# LEM-6471
     * @param rateChangeIds
     */
    public UpdateSubscriptionActiveRatesBatch(Set<Id> rateChangeIds) {
        this.rateChangeIds = rateChangeIds;
    }

    /**
     * @description It queries all Approved Subscription Rate Changes where Effective Date is today
     * @JIRA# LEM-6471
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return SubscriptionRateChangeSelector.newInstance().selectByRateChangeIds(rateChangeIds);
    }

    /**
     * @description It updates Subscriptions with the active rates from the retrieved Subscription rate Changes.
     * @JIRA# LEM-6471
     * @param batchableContext
     * @param subscriptionRateChanges
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Subscription_Rate_Change__c> subscriptionRateChanges
    ) {
        SubscriptionService.updateSubscriptionActiveRatesFromSRC(subscriptionRateChanges);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-6471
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}