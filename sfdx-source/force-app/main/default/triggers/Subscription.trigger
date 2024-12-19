/**
 * @author Deloitte
 * @date 2023-06-23
 * @description Trigger on SBQQ__Subscription__c Object
 */

trigger Subscription on SBQQ__Subscription__c(before insert, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
}