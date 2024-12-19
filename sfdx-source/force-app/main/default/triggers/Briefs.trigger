/**
 * @author ATG
 * @date 10/04/23
 * @description trigger on Brief
 */
trigger Briefs on Brief__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(BriefHandler.class);
}