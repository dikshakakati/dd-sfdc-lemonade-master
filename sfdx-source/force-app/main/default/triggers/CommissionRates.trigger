/**
 * @author Deloitte
 * @date 24/04/2024
 * @description Trigger on Commission_Rate__c Object
 */
trigger CommissionRates on Commission_Rate__c (before update, before insert) {
	fflib_SObjectDomain.triggerHandler(CommissionRatesHandler.class);
}