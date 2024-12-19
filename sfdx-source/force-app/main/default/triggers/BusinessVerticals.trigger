/**
 * @description Trigger on Business Vertical Object
 * @author Deloitte
 * @date 11/11/2023
 */
trigger BusinessVerticals on Business_Vertical__c (
    before insert,
    before update
) {
    fflib_SObjectDomain.triggerHandler(BusinessVerticalsHandler.class);
}