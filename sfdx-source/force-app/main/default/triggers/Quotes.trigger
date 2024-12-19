/**
 * @author ATG
 * @date 2022-04-05
 * @description Trigger on SBQQ__Quote__c Object
 */

trigger Quotes on SBQQ__Quote__c (
    before insert,
    before update,
    after insert,
    after update,
    before delete,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
}