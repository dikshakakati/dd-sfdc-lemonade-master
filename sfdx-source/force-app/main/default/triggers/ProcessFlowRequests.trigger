/**
 * @description       :
 * @author            : rishab.goyal
 * @group             :
 * @last modified on  : 03-17-2024
 * @last modified by  : rishab.goyal
**/
trigger ProcessFlowRequests on Process_Flow_Request__c (after update) {
    fflib_SObjectDomain.triggerHandler(ProcessFlowRequestsHandler.class);
}