/**
 * @author DoorDash
 * @date 25/03/2024
 * @description Batch class to process future Rate Change Requests.
 */
public with sharing class ActiveRatesProvisioningBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    public List<Rate_Change_Request__c> rateChangeToProcess = new List<Rate_Change_Request__c>();
    public Set<Id> rateChangeIds = new Set<Id>();
    public List<Rate_Change_Request__c> rateChanges = new List<Rate_Change_Request__c>();
    public String batchSize = System.Label.Update_Subscription_Active_Rates_Batch_Size;

    /**
     * @description It queries all Subscription Rate Changes where effective date is today
     * @JIRA# LEM-13931
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return RateChangeRequestSelector.newInstance().selectByEffectiveDateToday();
    }

    /**
     * @description It process the subscriptionRateChanges
     * @JIRA# LEM-6159
     * @param batchableContext
     * @param rateChanges
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Rate_Change_Request__c> rateChanges
    ) {
        for (Rate_Change_Request__c eachRCR : rateChanges) {
            rateChangeIds.add(eachRCR.Id);
        }
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-13931
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {
        if (!rateChangeIds.isEmpty()) {
            Database.executeBatch(
                new UpdateSubscriptionActiveRatesBatch(rateChangeIds),
                Integer.valueOf(batchSize)
            );
        }
    }

    /**
     * @description Execute method to schedule this batch.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new ActiveRatesProvisioningBatch());
    }
}