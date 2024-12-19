/**
 * @author Deloitte
 * @date 10/26/2023
 * @description Trigger on Account Payment Account Relation object.
 */
trigger AccountPaymentAccountRelations on Account_Payment_Account_Relation__c(before insert) {
    fflib_SObjectDomain.triggerHandler(AccountPaymentAccountRelationsHandler.class);
}