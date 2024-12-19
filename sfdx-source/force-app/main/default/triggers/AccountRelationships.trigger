/**
 * @author Deloitte
 * @date 27/04/2022
 * @description Trigger on Account Relationships
 */
trigger AccountRelationships on Account_Relationship__c(
    before insert,
    after insert,
    after undelete,
    after delete,
    before update,
    after update
) {
    fflib_SObjectDomain.triggerHandler(AccountRelationshipsHandler.class);
}