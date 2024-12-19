/**
 * @author Deloitte
 * @date 04/22/2024
 * @description Trigger on MerchantOrders Object
 */
trigger MerchantOrders on MX_Order__c(before insert, after insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
}