/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Trigger on Mx Fraud Document object.
 */
trigger MxFraudDocuments on Mx_Fraud_Document__c(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(MxFraudDocumentsHandler.class);
}