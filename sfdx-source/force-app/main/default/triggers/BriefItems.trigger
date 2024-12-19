/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Trigger on Brief Item Object
 */

trigger BriefItems on Brief_Item__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(BriefItemsHandler.class);
}