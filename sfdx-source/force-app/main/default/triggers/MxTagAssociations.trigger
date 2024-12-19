/**
 * @description Trigger on Mx Tag Association Object
 * @author Deloitte
 * @date 27/04/2024
 */
trigger MxTagAssociations on Mx_Tag_Association__c(
    before update,
    before insert,
    after insert,
    after update,
    after delete
) {
    fflib_SObjectDomain.triggerHandler(MxTagAssociationsHandler.class);
}