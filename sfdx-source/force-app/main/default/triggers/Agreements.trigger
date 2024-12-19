/**
 * @author ATG
 * @date 2022-05-20
 * @description Trigger on Agreement__c Object
 */
trigger Agreements on Agreement__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(AgreementsHandler.class);
}