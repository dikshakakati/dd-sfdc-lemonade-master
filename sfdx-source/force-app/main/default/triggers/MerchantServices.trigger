/**
 * @author DoorDash QTC
 * @date 2022-09-15
 * @description Trigger on Merchant_Service__c Object
 */

trigger MerchantServices on Merchant_Service__c(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(MerchantServicesHandler.class);
}