/**
 * @description Trigger on Product Insights object
 * @author Deloitte
 * @date 04/04/2022
 */
trigger ProductInsights on Product_Insights__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(ProductInsightsHandler.class);
}