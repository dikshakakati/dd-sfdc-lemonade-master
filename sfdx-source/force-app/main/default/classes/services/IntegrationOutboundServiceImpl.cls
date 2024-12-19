/**
 * @author Deloitte
 * @date 04/02/2024
 * @description Service implementation class for outbound integrations with external systems.
 */
public inherited sharing class IntegrationOutboundServiceImpl implements IIntegrationOutboundService, IRetryableService {
    private static final String ACTIVATION_CHECKLIST_NAMED_CREDENTIAL = 'Mulesoft_Activation_Checklist_Named_Cred';
    private static final String CALLOUT_KEY_WORD = 'callout:';
    private static final String EMAIL_NAMED_CREDENTIAL = 'Mulesoft_Email_Named_Cred';
    private static final String ENTITY_NAME_INTERFACE_TRANSACTION = 'InterfaceTransaction';
    private static final String ENTITY_NAME_MX_ORDER = 'Merchant Order';
    private static final String ENTITY_NAME_STORE_ACCOUNT = 'StoreAccount';
    private static final String ENTITY_NAME_WORK_STEP = 'WorkStep';
    private static final String EVENT_TOPIC_ORDER_RETRY_CALLOUT = 'RETRY_CALLOUT';
    private static final String EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH = 'RETRY_CALLOUT_BATCH';
    private static final String GENERIC_LOG_ERROR_MESSAGE = 'Unable to send outbound integration request payload for the record Ids: ';
    private static final String HTTP_REQUEST_METHOD = 'POST';
    private static final String LOG_ERROR_MESSAGE = 'Unable to send outbound integration request payload.';
    private static final String LOG_METHOD_NAME = 'sendPayloadforOutboundIntegration';
    private static final String LOG_SERVICE_OUTBOUND_INTEGRATION = 'Integration Outbound Service';
    private static final String MX_FRAUD_NAMED_CREDENTIAL = 'Mulesoft_Mx_Fraud_Named_Cred';
    private static final String PHOTOSHOOT_NAMED_CREDENTIAL = 'Mulesoft_Photoshoot_Named_Cred';
    private static final String SEPARATOR = ' : ';
    private static final Integer SUCCESS_CODE = 200;
    private static final String TABLET_NAMED_CREDENTIAL = 'Mulesoft_Tablet_Named_Cred';
    private static final String USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION = 'ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION = 'MX_FRAUD_DOCUMENT_INTEGRATION';
    private static final String USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION = 'PHOTOSHOOT_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_TABLET_OUTBOUND_INTEGRATION = 'TABLET_OUTBOUND_INTEGRATION';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private enum EventTopics {
        EVENT_TOPIC_ORDER_RETRY_CALLOUT_TOPIC,
        EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH_TOPIC
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_ORDER_RETRY_CALLOUT => EventTopics.EVENT_TOPIC_ORDER_RETRY_CALLOUT_TOPIC,
        EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH => EventTopics.EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH_TOPIC
    };
    private enum IntegrationUseCase {
        USECASE_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
        USECASE_EMAIL_OUTBOUND_INTEGRATION,
        USECASE_MX_FRAUD_OUTBOUND_INTEGRATION,
        USECASE_PHOTOSHOOT_OUTBOUND_INTEGRATION,
        USECASE_TABLET_OUTBOUND_INTEGRATION
    }
    private static final Map<String, IntegrationUseCase> USECASE_MAPPINGS = new Map<String, IntegrationUseCase>{
        USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION => IntegrationUseCase.USECASE_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
        USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION => IntegrationUseCase.USECASE_EMAIL_OUTBOUND_INTEGRATION,
        USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION => IntegrationUseCase.USECASE_MX_FRAUD_OUTBOUND_INTEGRATION,
        USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION => IntegrationUseCase.USECASE_PHOTOSHOOT_OUTBOUND_INTEGRATION,
        USECASE_NAME_TABLET_OUTBOUND_INTEGRATION => IntegrationUseCase.USECASE_TABLET_OUTBOUND_INTEGRATION
    };
    private static List<String> failedPayloads;
    private static String outboundIntegrationUseCase;
    private static List<String> passedPayloads;
    private static String responseBody;
    private static String responseStatus;
    private Map<String, String> useCaseToEndPointName = new Map<String, String>();
    private Boolean isInvokedByPlatformEvent;

    static {
        failedPayloads = new List<String>();
        passedPayloads = new List<String>();
        responseBody = '';
        responseStatus = '';
    }

    /**
     * @description Default Constructor to initialize class variables.
     */
    public IntegrationOutboundServiceImpl() {
        isInvokedByPlatformEvent = false;
        collectStaticConfigurations();
    }

    /**
     * @description It is used to make a future callout for manual retry.
     * @param interfaceTransactionIds
     */
    @future(callout=true)
    public static void retryCallout(Set<Id> interfaceTransactionIds) {
        InterfaceTransactionsService.isManualRetry = true;
        IntegrationOutboundServiceImpl serviceImplInstance = new IntegrationOutboundServiceImpl();
        serviceImplInstance.isInvokedByPlatformEvent = true;
        serviceImplInstance.retry(
            InterfaceTransactionSelector.newInstance().selectById(interfaceTransactionIds)
        );
    }

    /**
     * @description It is used to make a future callout for manual retry.
     * @param interfaceTransactionIds
     */
    @future(callout=true)
    public static void retryCalloutByBatch(Set<Id> interfaceTransactionIds) {
        InterfaceTransactionsService.isManualRetry = false;
        IntegrationOutboundServiceImpl serviceImplInstance = new IntegrationOutboundServiceImpl();
        serviceImplInstance.isInvokedByPlatformEvent = true;
        serviceImplInstance.retry(
            InterfaceTransactionSelector.newInstance().selectById(interfaceTransactionIds)
        );
    }

    /**
     * @description It is used to handle and process the published Onboarding Activations Events payload.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> interfaceTransactionIds = new Set<Id>();
        Set<Id> interfaceTransactionIdsByBatch = new Set<Id>();
        Set<Id> recordIdsByPayload;

        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_ORDER_RETRY_CALLOUT_TOPIC {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    interfaceTransactionIds.addAll(recordIdsByPayload);
                }
                when EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH_TOPIC {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    interfaceTransactionIdsByBatch.addAll(recordIdsByPayload);
                }
            }
        }
        if (!interfaceTransactionIds.isEmpty()) {
            retryCallout(interfaceTransactionIds);
        }
        if (!interfaceTransactionIdsByBatch.isEmpty()) {
            retryCalloutByBatch(interfaceTransactionIdsByBatch);
        }
    }

    /**
     * @description It is used to retry failed Interface Transaction records.
     * @param interfaceTransactionId
     */
    public void retry(String interfaceTransactionId) {
        retry(
            InterfaceTransactionSelector.newInstance()
                .selectById(new Set<Id>{ interfaceTransactionId })
        );
    }

    /**
     * @description It is used to retry failed Interface Transaction records.
     * @param interfaceTransactionsForRetry
     */
    public void retry(List<Interface_Transaction__c> interfaceTransactionsForRetry) {
        if (interfaceTransactionsForRetry.isEmpty()) {
            return;
        }
        List<String> chunkedPayloads = new List<String>();
        Set<Id> interfaceTransactionIdsToRetryByOAEvent = new Set<Id>();
        outboundIntegrationUseCase = interfaceTransactionsForRetry[0]
            .Interface_Transaction_Configuration_Name__c;
        switch on USECASE_MAPPINGS.get(outboundIntegrationUseCase.toUpperCase()) {
            when USECASE_EMAIL_OUTBOUND_INTEGRATION {
                chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForEmailIntegration(
                    interfaceTransactionsForRetry
                );
            }
            when USECASE_MX_FRAUD_OUTBOUND_INTEGRATION {
                chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxFraudDocumentsIntegration(
                    interfaceTransactionsForRetry
                );
            }
            when USECASE_PHOTOSHOOT_OUTBOUND_INTEGRATION {
                if (isInvokedByPlatformEvent) {
                    chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
                        interfaceTransactionsForRetry
                    );
                } else {
                    interfaceTransactionIdsToRetryByOAEvent.addAll(
                        new Map<Id, Interface_Transaction__c>(interfaceTransactionsForRetry)
                            .keySet()
                    );
                }
            }
            when USECASE_TABLET_OUTBOUND_INTEGRATION {
                if (isInvokedByPlatformEvent) {
                    chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderIntegration(
                        interfaceTransactionsForRetry
                    );
                } else {
                    interfaceTransactionIdsToRetryByOAEvent.addAll(
                        new Map<Id, Interface_Transaction__c>(interfaceTransactionsForRetry)
                            .keySet()
                    );
                }
            }
        }
        if (!interfaceTransactionIdsToRetryByOAEvent.isEmpty()) {
            retryInterfaceTransactionsByBatch(
                (List<String>) JSON.deserialize(
                    JSON.serialize(interfaceTransactionIdsToRetryByOAEvent),
                    List<String>.class
                )
            );
        }
        if (!chunkedPayloads.isEmpty()) {
            generateHttpRequestAndProcessResponse(
                useCaseToEndPointName.get(outboundIntegrationUseCase.toUpperCase()),
                chunkedPayloads
            );
        }
    }

    /**
     * @description It enables manual retry of interface transactions.
     * @JIRA# LEM-13497
     * @param interfaceTransactionIds
     */
    public void retryInterfaceTransactions(List<String> interfaceTransactionIds) {
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_ORDER_RETRY_CALLOUT => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>((List<Id>) interfaceTransactionIds),
                    5
                )
            }
        );
    }

    /**
     * @description It sends REST API callout to Mulesoft using named credentials
     * to initiate Activations checklist validation.
     * @JIRA# LEM-13305
     * @param integrationUseCase
     * @param outboundPayloads
     */
    public void sendAPICalloutWithRequestPayload(
        String integrationUseCase,
        List<String> outboundPayloads
    ) {
        if (outboundPayloads.isEmpty()) {
            return;
        }
        sendAsyncAPICalloutWithRequestPayload(
            integrationUseCase,
            useCaseToEndPointName.get(integrationUseCase.toUpperCase()),
            outboundPayloads
        );
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.useCaseToEndPointName.put(
            USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
            String.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(ACTIVATION_CHECKLIST_NAMED_CREDENTIAL)
                    .Configuration_Value__c
            )
        );
        this.useCaseToEndPointName.put(
            USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION,
            String.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(EMAIL_NAMED_CREDENTIAL)
                    .Configuration_Value__c
            )
        );
        this.useCaseToEndPointName.put(
            USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION,
            String.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(MX_FRAUD_NAMED_CREDENTIAL)
                    .Configuration_Value__c
            )
        );
        this.useCaseToEndPointName.put(
            USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION,
            String.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL)
                    .Configuration_Value__c
            )
        );
        this.useCaseToEndPointName.put(
            USECASE_NAME_TABLET_OUTBOUND_INTEGRATION,
            String.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(TABLET_NAMED_CREDENTIAL)
                    .Configuration_Value__c
            )
        );
    }

    /**
     * @description It is used to generate Http Request, send over the request and receive back
     * response.
     * @param namedCredential
     * @param outboundPayloads
     */
    private static void generateHttpRequestAndProcessResponse(
        String namedCredential,
        List<String> outboundPayloads
    ) {
        for (String eachPayload : outboundPayloads) {
            HttpRequest httpRequestInstance = new HttpRequest();
            httpRequestInstance.setEndpoint(CALLOUT_KEY_WORD + namedCredential);
            httpRequestInstance.setMethod(HTTP_REQUEST_METHOD);
            httpRequestInstance.setBody(eachPayload);
            Http http = new Http();
            HTTPResponse response;
            try {
                response = http.send(httpRequestInstance);
                if (response.getStatusCode() == SUCCESS_CODE) {
                    passedPayloads.add(eachPayload);
                } else {
                    responseBody = response.getBody();
                    responseStatus = response.toString();
                    failedPayloads.add(eachPayload);
                }
            } catch (System.CalloutException httpCalloutException) {
                responseStatus = httpCalloutException.getMessage();
                responseBody = httpCalloutException.getStackTraceString();
                failedPayloads.add(eachPayload);
            }
        }
        processPayloadsBasedOnResponse();
    }

    /**
     * @description It is used to process related records for payloads based on response status.
     */
    private static void processPayloadsBasedOnResponse() {
        Set<String> failedStoreIds = new Set<String>();
        Map<String, Set<String>> failedRecordIdsFromPayload = new Map<String, Set<String>>();
        Map<String, Set<String>> passedRecordIdsFromPayload = new Map<String, Set<String>>();
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        switch on USECASE_MAPPINGS.get(outboundIntegrationUseCase.toUpperCase()) {
            when USECASE_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION {
                failedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromActivationChecklistPayload(
                    failedPayloads
                );
                passedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromActivationChecklistPayload(
                    passedPayloads
                );
                failedStoreIds.addAll(failedRecordIdsFromPayload.get(ENTITY_NAME_STORE_ACCOUNT));
                WorkPlansService.escalateActivationChecklistValidationOnWorkPlan(
                    WorkStepsSelector.newInstance()
                        .selectByIds(
                            new Set<Id>(
                                (List<Id>) new List<String>(
                                    failedRecordIdsFromPayload.get(ENTITY_NAME_WORK_STEP)
                                )
                            )
                        )
                );
                WorkStepsService.updateActivationChecklistWorkStepsStatus(
                    new Set<Id>(
                        (List<Id>) new List<String>(
                            passedRecordIdsFromPayload.get(ENTITY_NAME_WORK_STEP)
                        )
                    ),
                    false,
                    WORK_STEP_STATUS_IN_PROGRESS
                );
                WorkStepsService.updateActivationChecklistWorkStepsStatus(
                    new Set<Id>(
                        (List<Id>) new List<String>(
                            failedRecordIdsFromPayload.get(ENTITY_NAME_WORK_STEP)
                        )
                    ),
                    true,
                    WORK_STEP_STATUS_ESCALATED
                );
            }
            when USECASE_TABLET_OUTBOUND_INTEGRATION {
                failedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromMxOrderPayload(
                    failedPayloads
                );
                passedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromMxOrderPayload(
                    passedPayloads
                );
                failedStoreIds.addAll(failedRecordIdsFromPayload.get(ENTITY_NAME_STORE_ACCOUNT));
                InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_MX_ORDER),
                    passedRecordIdsFromPayload.get(ENTITY_NAME_MX_ORDER)
                );
            }
            when USECASE_PHOTOSHOOT_OUTBOUND_INTEGRATION {
                failedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromPhotoshootMxOrderPayload(
                    failedPayloads
                );
                passedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromPhotoshootMxOrderPayload(
                    passedPayloads
                );
                failedStoreIds.addAll(failedRecordIdsFromPayload.get(ENTITY_NAME_STORE_ACCOUNT));
                InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_MX_ORDER),
                    passedRecordIdsFromPayload.get(ENTITY_NAME_MX_ORDER)
                );
            }
            when USECASE_EMAIL_OUTBOUND_INTEGRATION {
                failedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromEmailPayload(
                    failedPayloads
                );
                passedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromEmailPayload(
                    passedPayloads
                );
                failedStoreIds.addAll(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                );
                InterfaceTransactionsService.updateInterfaceTransactionStatusByOutboundCalloutResponse(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION),
                    passedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                );
            }
            when USECASE_MX_FRAUD_OUTBOUND_INTEGRATION {
                failedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromMxFraudPayload(
                    failedPayloads
                );
                passedRecordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromMxFraudPayload(
                    passedPayloads
                );
                failedStoreIds.addAll(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                );
                InterfaceTransactionsService.updateInterfaceTransactionStatusByOutboundCalloutResponse(
                    failedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION),
                    passedRecordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)
                );
            }
        }
        if (failedStoreIds.isEmpty()) {
            return;
        }
        for (String eachFailedId : failedStoreIds) {
            logEntryInstance = LogEntry.newLog(
                IntegrationOutboundServiceImpl.class.getName(),
                LOG_METHOD_NAME,
                LOG_ERROR_MESSAGE +
                SEPARATOR +
                responseStatus
            );
            logEntryInstance.stackTrace = responseBody;
            logEntryInstance.recordId = eachFailedId;
            if (loggerInstance == null) {
                loggerInstance = Logger.add(logEntryInstance);
                continue;
            }
            loggerInstance.add(logEntryInstance);
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_OUTBOUND_INTEGRATION,
                        outboundIntegrationUseCase,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logMessage(GENERIC_LOG_ERROR_MESSAGE + failedStoreIds)
            );
        }
    }

    /**
     * @description It enables manual retry of interface transactions.
     * @JIRA# LEM-13497
     * @param interfaceTransactionIds
     */
    private void retryInterfaceTransactionsByBatch(List<String> interfaceTransactionIds) {
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>((List<Id>) interfaceTransactionIds),
                    5
                )
            }
        );
    }

    /**
     * @description It is used to call future method to make Rest API callout.
     * @param integrationUseCase
     * @param namedCredential
     * @param outboundPayloads
     */
    @future(callout=true)
    private static void sendAsyncAPICalloutWithRequestPayload(
        String integrationUseCase,
        String namedCredential,
        List<String> outboundPayloads
    ) {
        outboundIntegrationUseCase = integrationUseCase;
        generateHttpRequestAndProcessResponse(namedCredential, outboundPayloads);
    }
}