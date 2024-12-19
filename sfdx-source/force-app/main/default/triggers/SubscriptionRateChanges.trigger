/**
 * @author Deloitte
 * @date 20/08/2023
 * @description Trigger on Subscription_Rate_Change__c Object
 */

trigger SubscriptionRateChanges on Subscription_Rate_Change__c(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(SubscriptionRateChangesHandler.class);
}