/**
 * @author DoorDash
 * @date 03/28/2023
 * @description Trigger on Integration_request__c Object
 */
trigger IntegrationRequests on Integration_request__c (after insert, after update, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(IntegrationRequestsHandler.class);
}