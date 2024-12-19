/**
 * @author Deloitte
 * @date 2023-04-25
 * @description Trigger on SBQQ__QuoteLine__c Object
 */
trigger QuoteLineItems on SBQQ__QuoteLine__c (after update, before insert, before delete) {
    fflib_SObjectDomain.triggerHandler(QuoteLineItemsHandler.class);

}