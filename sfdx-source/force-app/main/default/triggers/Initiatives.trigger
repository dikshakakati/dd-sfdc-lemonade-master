/**
 * @description Trigger on Initiatives
 * @author Deloitte
 * @date 27/04/2022
 */
trigger Initiatives on Initiative__c(before insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(InitiativesHandler.class);
}