/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Trigger on Brand Object
 */

trigger Brands on Brand__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(BrandsHandler.class);

}