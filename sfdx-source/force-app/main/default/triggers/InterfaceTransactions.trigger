/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Trigger on Interface Transaction object.
 */
trigger InterfaceTransactions on Interface_Transaction__c(after insert) {
    fflib_SObjectDomain.triggerHandler(InterfaceTransactionsHandler.class);
}