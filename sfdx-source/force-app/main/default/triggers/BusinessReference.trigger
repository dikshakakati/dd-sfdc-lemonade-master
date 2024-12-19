/**
 * @author ATG
 * @date 2022-06-30
 * @description LEM-2081 Trigger on Business_Reference__c Object
 */

trigger BusinessReference on Business_Reference__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(BusinessReferenceHandler.class);
}