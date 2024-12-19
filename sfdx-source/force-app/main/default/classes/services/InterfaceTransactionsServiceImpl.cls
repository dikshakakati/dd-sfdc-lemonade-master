/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service implementation class for Interface Transactions related logic.
 */
public inherited sharing class InterfaceTransactionsServiceImpl implements IInterfaceTransactionsService {
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String EVENT_TOPIC_MX_FRAUD_OUTBOUND = 'MX_FRAUD_DOCUMENT_INTEGRATION';
    private static final String EVENT_TOPIC_PHOTOSHOOT_OUTBOUND = 'PHOTOSHOOT_OUTBOUND_INTEGRATION';
    private static final String EVENT_TOPIC_TABLET_OUTBOUND = 'TABLET_OUTBOUND_INTEGRATION';
    private static final String FAILED_STATUS = 'Failure';
    private static final String INTEGRATION_USECASE_EMAIL = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String INTERFACE_TRANSACTION_CONFIG_NAME_OIDATASERVICE = 'OIDataService';
    private static final String LOG_SERVICE_INTERFACE_TRANSACTION = 'Interface Transactions Service';
    private static final String LOG_DOMAIN_TABLET_INTEGRATION = 'Tablet Outbound Integration';
    private static final String MX_FRAUD_OUTBOUND_CONFIG_NAME = 'Mx_Fraud_Document_Integration';
    private static final String NEW_STATUS = 'New';
    private static final String PHOTOSHOOT_OUTBOUND_CONFIG_NAME = 'Photoshoot_Outbound_Integration';
    private static final String SUBMITTED_STATUS = 'Submitted';
    private static final String SUCCESS_STATUS = 'Success';
    private static final String TABLET_OUTBOUND_CONFIG_NAME = 'Tablet_Outbound_Integration';

    private enum EventTopics {
        EVENTTOPIC_MX_FRAUD_OUTBOUND,
        EVENTTOPIC_PHOTOSHOOT_OUTBOUND,
        EVENTTOPIC_TABLET_OUTBOUND
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_MX_FRAUD_OUTBOUND => EventTopics.EVENTTOPIC_MX_FRAUD_OUTBOUND,
        EVENT_TOPIC_PHOTOSHOOT_OUTBOUND => EventTopics.EVENTTOPIC_PHOTOSHOOT_OUTBOUND,
        EVENT_TOPIC_TABLET_OUTBOUND => EventTopics.EVENTTOPIC_TABLET_OUTBOUND
    };

    private enum IntegrationUseCase {
        EMAIL_OUTBOUND,
        MX_FRAUD_OUTBOUND,
        PHOTOSHOOT_OUTBOUND,
        TABLET_OUTBOUND
    }
    private static final Map<String, IntegrationUseCase> INTEGRATION_USECASE_MAPPING = new Map<String, IntegrationUseCase>{
        EMAIL_OUTBOUND_CONFIG_NAME => IntegrationUseCase.EMAIL_OUTBOUND,
        MX_FRAUD_OUTBOUND_CONFIG_NAME => IntegrationUseCase.MX_FRAUD_OUTBOUND,
        PHOTOSHOOT_OUTBOUND_CONFIG_NAME => IntegrationUseCase.PHOTOSHOOT_OUTBOUND,
        TABLET_OUTBOUND_CONFIG_NAME => IntegrationUseCase.TABLET_OUTBOUND
    };

    /**
     * @description This method is used to handle the published onboardingActivationsEvents.
     * @JIRA# LEM-13506
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        List<String> mxOrderOutboundPayloads = new List<String>();
        String integrationUseCase;
        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_TABLET_OUTBOUND {
                    mxOrderOutboundPayloads.add(eachEvent.Payload__c);
                    integrationUseCase = EVENT_TOPIC_TABLET_OUTBOUND;
                }
                when EVENTTOPIC_PHOTOSHOOT_OUTBOUND {
                    mxOrderOutboundPayloads.add(eachEvent.Payload__c);
                    integrationUseCase = EVENT_TOPIC_PHOTOSHOOT_OUTBOUND;
                }
                when EVENTTOPIC_MX_FRAUD_OUTBOUND {
                    mxOrderOutboundPayloads.add(eachEvent.Payload__c);
                    integrationUseCase = EVENT_TOPIC_MX_FRAUD_OUTBOUND;
                }
            }
        }
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            integrationUseCase,
            mxOrderOutboundPayloads
        );
    }

    /**
     * @description It initiates the tablet integration process based on the passed orders.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     */
    public void initiateOutboundIntegrationForinterfaceTransactions(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        List<Interface_Transaction__c> emailInterfaceTransactions = new List<Interface_Transaction__c>();
        Set<Id> emailIntegrationTemplateIds = new Set<Id>();
        List<Interface_Transaction__c> mxFraudInterfaceTransactions = new List<Interface_Transaction__c>();
        List<Interface_Transaction__c> photoshootInterfaceTransactions = new List<Interface_Transaction__c>();
        List<Interface_Transaction__c> tabletInterfaceTransactions = new List<Interface_Transaction__c>();
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            if (eachInterfaceTransaction.Status__c != NEW_STATUS) {
                continue;
            }
            switch on
                INTEGRATION_USECASE_MAPPING.get(
                    eachInterfaceTransaction.Interface_Transaction_Configuration_Name__c
                ) {
                when EMAIL_OUTBOUND {
                    emailInterfaceTransactions.add(eachInterfaceTransaction);
                    emailIntegrationTemplateIds.add(
                        eachInterfaceTransaction.Integration_Template__c
                    );
                }
                when MX_FRAUD_OUTBOUND {
                    mxFraudInterfaceTransactions.add(eachInterfaceTransaction);
                }
                when PHOTOSHOOT_OUTBOUND {
                    photoshootInterfaceTransactions.add(eachInterfaceTransaction);
                }
                when TABLET_OUTBOUND {
                    tabletInterfaceTransactions.add(eachInterfaceTransaction);
                }
            }
        }
        List<String> photoshootChunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
            photoshootInterfaceTransactions
        );
        List<String> interfaceTransactionsChunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderIntegration(
            tabletInterfaceTransactions
        );
        List<String> mxFraudDocumentsChunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxFraudDocumentsIntegration(
            mxFraudInterfaceTransactions
        );
        if (!interfaceTransactionsChunkedPayloads.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_TABLET_OUTBOUND => interfaceTransactionsChunkedPayloads
                }
            );
        }
        if (!photoshootChunkedPayloads.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PHOTOSHOOT_OUTBOUND => photoshootChunkedPayloads
                }
            );
        }
        if (!mxFraudDocumentsChunkedPayloads.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_MX_FRAUD_OUTBOUND => mxFraudDocumentsChunkedPayloads
                }
            );
        }
        if (!emailInterfaceTransactions.isEmpty()) {
            processEmailPayloadsForOutboundIntegration(
                emailIntegrationTemplateIds,
                emailInterfaceTransactions
            );
        }
    }

    /**
     * @description It updates Interface Transaction status based on outbound REST API callout response.
     * @JIRA# LEM-13778, LEM-15836
     * @param failedInterfaceTransactionIds
     * @param passedInterfaceTransactionIds
     */
    public void updateInterfaceTransactionStatusByOutboundCalloutResponse(
        Set<String> failedInterfaceTransactionIds,
        Set<String> passedInterfaceTransactionIds
    ) {
        List<Interface_Transaction__c> interfaceTransactionsToUpdate = new List<Interface_Transaction__c>();
        Set<String> idsForStatusUpdate = new Set<String>();
        idsForStatusUpdate.addAll(failedInterfaceTransactionIds);
        idsForStatusUpdate.addAll(passedInterfaceTransactionIds);
        String statusToUpdate;
        Integer retryAttempts;
        for (
            Interface_Transaction__c eachInterfaceTransaction : InterfaceTransactionSelector.newInstance()
                .selectById(new Set<Id>((List<Id>) new List<String>(idsForStatusUpdate)))
        ) {
            if (eachInterfaceTransaction.Status__c == SUCCESS_STATUS) {
                continue;
            }
            retryAttempts = (Integer) (eachInterfaceTransaction.Status__c == FAILED_STATUS &&
                !InterfaceTransactionsService.isManualRetry
                ? Integer.valueOf(eachInterfaceTransaction.Remaining_Retry_Attempts__c - 1)
                : eachInterfaceTransaction.Remaining_Retry_Attempts__c);
            statusToUpdate = passedInterfaceTransactionIds.contains(eachInterfaceTransaction.Id)
                ? SUBMITTED_STATUS
                : FAILED_STATUS;
            interfaceTransactionsToUpdate.add(
                new Interface_Transaction__c(
                    Id = eachInterfaceTransaction.Id,
                    Status__c = statusToUpdate,
                    Remaining_Retry_Attempts__c = retryAttempts
                )
            );
        }
        if (!interfaceTransactionsToUpdate.isEmpty()) {
            fireUpdateOnInterfaceTransactions(interfaceTransactionsToUpdate);
        }
    }

    /**
     * @description It updates Interface Transaction status based on REST API callout response.
     * @JIRA# LEM-13506
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    public void updateInterfaceTransactionStatusByResponse(
        Set<String> failedMxOrderIds,
        Set<String> passedMxOrderIds
    ) {
        List<Interface_Transaction__c> interfaceTransactionsToUpdate = new List<Interface_Transaction__c>();
        Set<String> mxOrderIdsForStatusUpdate = new Set<String>();
        mxOrderIdsForStatusUpdate.addAll(failedMxOrderIds);
        mxOrderIdsForStatusUpdate.addAll(passedMxOrderIds);
        String statusToUpdate;
        Integer retryAttempts;
        for (
            Interface_Transaction__c eachInterfaceTransaction : InterfaceTransactionSelector.newInstance()
                .selectByOriginRecordIds(mxOrderIdsForStatusUpdate)
        ) {
            if (eachInterfaceTransaction.Status__c == SUCCESS_STATUS) {
                continue;
            }
            retryAttempts = (Integer) (eachInterfaceTransaction.Status__c == FAILED_STATUS &&
                !InterfaceTransactionsService.isManualRetry
                ? Integer.valueOf(eachInterfaceTransaction.Remaining_Retry_Attempts__c - 1)
                : eachInterfaceTransaction.Remaining_Retry_Attempts__c);
            statusToUpdate = passedMxOrderIds.contains(eachInterfaceTransaction.Record_Id__c)
                ? (eachInterfaceTransaction.Interface_Transaction_Configuration_Name__c ==
                      INTERFACE_TRANSACTION_CONFIG_NAME_OIDATASERVICE
                      ? SUCCESS_STATUS
                      : SUBMITTED_STATUS)
                : FAILED_STATUS;
            interfaceTransactionsToUpdate.add(
                new Interface_Transaction__c(
                    Id = eachInterfaceTransaction.Id,
                    Status__c = statusToUpdate,
                    Remaining_Retry_Attempts__c = retryAttempts
                )
            );
        }
        if (!interfaceTransactionsToUpdate.isEmpty()) {
            fireUpdateOnInterfaceTransactions(interfaceTransactionsToUpdate);
        }
    }

    /**
     * @description It updates Interface Transaction status based on REST API callout response.
     * @JIRA# LEM-13506
     * @param interfaceTransactionsToUpdate
     */
    private void fireUpdateOnInterfaceTransactions(
        List<Interface_Transaction__c> interfaceTransactionsToUpdate
    ) {
        if (interfaceTransactionsToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsUpdate = Application.UnitOfWork.newInstance();
        uowRecordsUpdate.registerDirty(interfaceTransactionsToUpdate);
        try {
            uowRecordsUpdate.commitWork();
        } catch (Exception recordsUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(recordsUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_INTERFACE_TRANSACTION,
                        LOG_DOMAIN_TABLET_INTEGRATION,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(recordsUpdateException)
            );
        }
    }

    /**
     * @description It generates chunked payload for Email interface transactions.
     * @JIRA# LEM-13506
     * @param emailIntegrationTemplateIds
     * @param emailInterfaceTransactions
     */
    private void processEmailPayloadsForOutboundIntegration(
        Set<Id> emailIntegrationTemplateIds,
        List<Interface_Transaction__c> emailInterfaceTransactions
    ) {
        Map<Id, Integration_Template__c> emailIntegrationTemplates = new Map<Id, Integration_Template__c>(
            IntegrationTemplatesSelector.newInstance().selectByIds(emailIntegrationTemplateIds)
        );
        List<Interface_Transaction__c> emailPayloadsToProcess = new List<Interface_Transaction__c>();
        for (Interface_Transaction__c eachInterfaceTransaction : emailInterfaceTransactions) {
            if (
                !emailIntegrationTemplates.containsKey(
                    eachInterfaceTransaction.Integration_Template__c
                )
            ) {
                continue;
            }
            if (
                emailIntegrationTemplates.get(eachInterfaceTransaction.Integration_Template__c)
                    .Immediate_Communication__c
            ) {
                emailPayloadsToProcess.add(eachInterfaceTransaction);
            }
        }
        List<String> interfaceTransactionsChunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForEmailIntegration(
            emailPayloadsToProcess
        );
        if (!interfaceTransactionsChunkedPayloads.isEmpty()) {
            IntegrationOutboundService.sendAPICalloutWithRequestPayload(
                INTEGRATION_USECASE_EMAIL,
                interfaceTransactionsChunkedPayloads
            );
        }
    }
}