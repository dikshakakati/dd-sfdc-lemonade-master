/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Trigger on Inbound Ingestion Logs
 */
trigger InboundIngestionLogs on Inbound_Ingestion_Log__c (before insert, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(InboundIngestionLogsHandler.class);
}