/**
 * @author BizApps
 * @date 05/23
 * @description Trigger on Contract_Associated_Accounts__c Object
 */

 trigger ContractAssociatedAccounts on Contract_Associated_Accounts__c (before insert, before update, before delete, after insert,after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(ContractAssociatedAccountsHandler.class);
}