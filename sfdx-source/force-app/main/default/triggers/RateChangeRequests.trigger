/**
 * @author Deloitte
 * @date 20/08/2023
 * @description Trigger on Rate_Change_Request__c Object
 */

trigger RateChangeRequests on Rate_Change_Request__c(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(RateChangeRequestsHandler.class);
}