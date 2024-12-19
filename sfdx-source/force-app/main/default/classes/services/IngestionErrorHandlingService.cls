/**
 * @author Deloitte
 * @date 09/17/2024
 * @description Service class for IngestionErrorHandlingServiceImpl.
 */
public inherited sharing class IngestionErrorHandlingService {
    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the Onboarding Event.
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     * @param className
     */
    public static void catchExceptionsOnGovernerLimits(
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String className
    ) {
        service()
            .catchExceptionsOnGovernerLimits(
                methodName,
                payloadMethodsToStepMap,
                inboundIngestionLog,
                className
            );
    }
    /**
     * @description It is used to update the success status on inbound ingestion log record..
     * @param inboundIngestionLog
     * @param successMessage
     */
    public static void updateInboundIngestionLogForSuccess(
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String successMessage
    ) {
        service().updateInboundIngestionLogForSuccess(inboundIngestionLog, successMessage);
    }
    /**
     * @description It is used to update the save result exception on Inbound Ingestion log record.
     * @param savedIngestionResult
     * @param inboundIngestionLog
     * @param methodName
     * @param payloadMethodsToStepMap
     */
    public static void logSaveResultIngestionExceptionToInboundIngestionRecord(
        Database.SaveResult savedIngestionResult,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String methodName,
        Map<String, String> payloadMethodsToStepMap
    ) {
        service()
            .logSaveResultIngestionExceptionToInboundIngestionRecord(
                savedIngestionResult,
                inboundIngestionLog,
                methodName,
                payloadMethodsToStepMap
            );
    }
    /**
     * @description It is used to update the uncaught exception on Inbound Ingestion log record.
     * @param recordsProcessingExceptions
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     */
    public static void logUncaughtIngestionExceptionToInboundIngestionRecord(
        Exception recordsProcessingExceptions,
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog
    ) {
        service()
            .logUncaughtIngestionExceptionToInboundIngestionRecord(
                recordsProcessingExceptions,
                methodName,
                payloadMethodsToStepMap,
                inboundIngestionLog
            );
    }
    /**
     * @description It is used to create an instance of IngestionErrorHandlingService class.
     * @return IIngestionErrorHandlingService - return instance of IngestionErrorHandlingServiceImpl
     */
    private static IIngestionErrorHandlingService service() {
        return (IIngestionErrorHandlingService) Application.Service.newInstance(
            IIngestionErrorHandlingService.class
        );
    }
}