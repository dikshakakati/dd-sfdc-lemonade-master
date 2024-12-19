/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Trigger on sbaa__Approval__c object.
 */
trigger Approvals on sbaa__Approval__c(before update, after update, before insert) {
    fflib_SObjectDomain.triggerHandler(ApprovalsHandler.class);
}