/**
 * @author ATG
 * @date 2022-06-29
 * @description LEM-1911 Trigger on Xref__c Object
 */

trigger Xrefs on Xref__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(XrefsHandler.class);
}