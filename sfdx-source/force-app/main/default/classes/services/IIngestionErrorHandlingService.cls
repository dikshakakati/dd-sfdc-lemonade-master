/**
 * @author Deloitte
 * @date 09/16/2024
 * @description Interface class for IngestionErrorHandlingService.
 */
public interface IIngestionErrorHandlingService {
    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the Onboarding Event.
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     * @param className
     */
    void catchExceptionsOnGovernerLimits(
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String className
    );
    /**
     * @description It is used to update the success status on inbound ingestion log record..
     * @param inboundIngestionLog
     * @param successMessage
     */
    void updateInboundIngestionLogForSuccess(
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String successMessage
    );
    /**
     * @description It is used to update the save result exception on Inbound Ingestion log record.
     * @param savedIngestionResult
     * @param inboundIngestionLog
     * @param methodName
     * @param payloadMethodsToStepMap
     */
    void logSaveResultIngestionExceptionToInboundIngestionRecord(
        Database.SaveResult savedIngestionResult,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String methodName,
        Map<String, String> payloadMethodsToStepMap
    );
    /**
     * @description It is used to update the uncaught exception on Inbound Ingestion log record.
     * @param recordsProcessingExceptions
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     */
    void logUncaughtIngestionExceptionToInboundIngestionRecord(
        Exception recordsProcessingExceptions,
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog
    );
}