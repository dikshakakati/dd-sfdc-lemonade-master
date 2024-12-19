/**
 * @author Deloitte
 * @date 08/07/2024
 * @description Trigger on Store_Detail__c Object
 */
trigger StoreDetails on Store_Detail__c(
    before insert,
    before update,
    after insert,
    after update,
    before delete,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(StoreDetailsHandler.class);
}