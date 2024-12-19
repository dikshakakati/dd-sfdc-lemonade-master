/**
 * @author Deloitte
 * @date 09/17/2024
 * @description Service Implementation class for IngestionErrorHandlingService
 */
public inherited sharing class IngestionErrorHandlingServiceImpl implements IIngestionErrorHandlingService {
    private static final String STATUS_FAILED = 'Failed';
    private static final String BUSINESS_ERROR_MESSAGE = ' event has been Failed';
    private static final String COMMITWORK_MESSAGE = 'Error occured during commit work';
    List<Database.SaveResult> saveResultsDetails = new List<Database.SaveResult>();
    List<String> errorsList = new List<String>();
    String methodName = '';
    private static final String SELF_SERVING_ONBOARDING_SERVICE = 'selfServiceOnboardingService';
    private static final String CPQ_WS = 'CPQ';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF = 'payloadDistributorForAccountsAndXrefsBizRefs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR = 'payloadDistributorForContactsAndACRs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES = 'payloadDistributorForOpportunities';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES = 'payloadDistributorForQuotesAndQuoteLines';
    private static final String SUCESS_STATUS = 'Success';
    private static final String ONBOARDING = ' onboarding';
    private static final String AMENDMENT = ' amendment';
    private static final String SSMO = 'SSMO';
    private static final String SSOB = 'SSOB';

    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the Onboarding Event.
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     * @param className
     */
    public void catchExceptionsOnGovernerLimits(
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String className
    ) {
        String govLimitsException = InboundIngestionLoggerService.errorOnGovtLimitsExceeded();
        if (String.isNotBlank(govLimitsException) || Test.isRunningTest()) {
            IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                SELF_SERVING_ONBOARDING_SERVICE,
                CPQ_WS,
                inboundIngestionLog.Id,
                inboundIngestionLog.UUID__c,
                ''
            );
            InboundIngestionLoggerService.logGovLimitsException(
                loggerEntry,
                govLimitsException,
                payloadMethodsToStepMap.get(methodName),
                className,
                methodName
            );
        }
    }
    /**
     * @description It is used to update the save result exception on Inbound Ingestion log record.
     * @param savedIngestionResult
     * @param inboundIngestionLog
     * @param methodName
     * @param payloadMethodsToStepMap
     */
    public void logSaveResultIngestionExceptionToInboundIngestionRecord(
        Database.SaveResult savedIngestionResult,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String methodName,
        Map<String, String> payloadMethodsToStepMap
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        String traceString = '';
        String exceptionMessage = '';
        String message =
            inboundIngestionLog.Source__c +
            ((inboundIngestionLog.Source__c == SSMO ||
                inboundIngestionLog.Source__c == SSOB)
                ? ONBOARDING
                : AMENDMENT) +
            BUSINESS_ERROR_MESSAGE;
        if (savedIngestionResult.isSuccess()) {
            return;
        }
        for (Database.Error err : savedIngestionResult.getErrors()) {
            traceString = new DmlException().getStackTraceString().substringAfter('\n');
            exceptionMessage += err.getMessage();
        }
        Inbound_ingestion_Log__c ingestionRecord = new Inbound_ingestion_Log__c(
            Id = inboundIngestionLog.Id,
            Status__c = STATUS_FAILED,
            Business_Error_Message__c = message,
            Failure_Step__c = methodName == ''
                ? 1
                : Decimal.valueof(payloadMethodsToStepMap.get(methodName)),
            Stack_Trace__c = traceString,
            Exception_Message__c = exceptionMessage
        );
        uowUpdateHelper.registerUpdate(ingestionRecord);

        uow.commitWork();

        logIngestionExceptionToScaler(
            null,
            inboundIngestionLog,
            methodName,
            payloadMethodsToStepMap,
            message
        );
    }

    /**
     * @description It is used to update the uncaught exception on Inbound Ingestion log record.
     * @param recordsProcessingExceptions
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param inboundIngestionLog
     */
    public void logUncaughtIngestionExceptionToInboundIngestionRecord(
        Exception recordsProcessingExceptions,
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        Inbound_Ingestion_Log__c inboundIngestionLog
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        String message =
            inboundIngestionLog.Source__c +
            '' +
            ((inboundIngestionLog.Source__c == SSMO ||
                inboundIngestionLog.Source__c == SSOB)
                ? ONBOARDING
                : AMENDMENT) +
            BUSINESS_ERROR_MESSAGE;
        Inbound_ingestion_Log__c ingestionRecord = new Inbound_ingestion_Log__c(
            Id = inboundIngestionLog.Id,
            Status__c = STATUS_FAILED,
            Business_Error_Message__c = message,
            Failure_Step__c = methodName == ''
                ? 1
                : Decimal.valueof(payloadMethodsToStepMap.get(methodName)),
            Stack_Trace__c = recordsProcessingExceptions.getStackTraceString(),
            Exception_Message__c = recordsProcessingExceptions.getMessage()
        );
        uowUpdateHelper.registerUpdate(ingestionRecord);
        uow.commitWork();
        logIngestionExceptionToScaler(
            recordsProcessingExceptions,
            inboundIngestionLog,
            methodName,
            payloadMethodsToStepMap,
            message
        );
    }
    /**
     * @description It is used to update the success status on inbound ingestion log record..
     * @param inboundIngestionLog
     * @param successMessage
     */
    public void updateInboundIngestionLogForSuccess(
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String successMessage
    ) {
        String message =
            inboundIngestionLog.Source__c +
            ((inboundIngestionLog.Source__c == SSMO ||
                inboundIngestionLog.Source__c == SSOB)
                ? ONBOARDING
                : AMENDMENT) +
            successMessage;
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        Inbound_ingestion_Log__c ingestionRecord = new Inbound_ingestion_Log__c(
            Id = inboundIngestionLog.Id,
            Status__c = SUCESS_STATUS,
            Business_Error_Message__c = null,
            Failure_Step__c = null,
            Stack_Trace__c = null,
            Exception_Message__c = null,
            Success_Message__c = message
        );

        uowUpdateHelper.registerUpdate(ingestionRecord);
        uow.commitWork();

        IinboundIngestionLoggerEntry le = InboundIngestionLoggerService.createInboundIngestionLog(
            SELF_SERVING_ONBOARDING_SERVICE,
            CPQ_WS,
            inboundIngestionLog.Id,
            inboundIngestionLog.UUID__c,
            ''
        );
        InboundIngestionLoggerService.logSuccess(le, message);
    }
    /**
     * @description It is used to log the ingestion exceptions to scaler
     * @param recordsProcessingExceptions
     * @param inboundIngestionLog
     * @param methodName
     * @param payloadMethodsToStepMap
     * @param businessErrorMessage
     */
    private void logIngestionExceptionToScaler(
        Exception recordsProcessingExceptions,
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String methodName,
        Map<String, String> payloadMethodsToStepMap,
        String businessErrorMessage
    ) {
        IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
            SELF_SERVING_ONBOARDING_SERVICE,
            CPQ_WS,
            inboundIngestionLog.Id,
            inboundIngestionLog.UUID__c,
            ''
        );
        InboundIngestionLoggerService.logException(
            loggerEntry,
            recordsProcessingExceptions != null
                ? recordsProcessingExceptions
                : new dmlexception(COMMITWORK_MESSAGE),
            businessErrorMessage,
            methodName != '' ? payloadMethodsToStepMap.get(methodName) : '',
            new Set<String>{ inboundIngestionLog.Id },
            recordsProcessingExceptions != null ? recordsProcessingExceptions.getTypeName() : ''
        );
    }
}