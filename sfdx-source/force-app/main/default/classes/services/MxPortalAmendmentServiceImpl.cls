/**
 * @author Deloitte
 * @date 07/02/2024
 * @description Service implementation class for MxPortalAmendmentService.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength,PMD.StdCyclomaticComplexity')
public inherited sharing class MxPortalAmendmentServiceImpl implements IMxPortalAmendmentService {
    private static final String PRODUCT_NAME_DASHPASS = 'Dashpass';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION = 'EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION';
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT = 'EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT';
    private static final String EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT = 'EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT';
    private static final String EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY = 'EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY';
    private static final String EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS = 'EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS';
    private static final String EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE';
    private static final String LOG_DOMAIN = 'Mx Portal Amendment';
    private static final String LOG_INBOUND_INGESTION_RECORDS_INSERT_FAILED = 'Creation on inbound ingestion records failed';
    private static final String STANDARD_STOREFRONT_PACKAGE = 'Standard Storefront Package';
    private static final String STOREFRONT_PACKAGE = 'Storefront';
    private static final String STATUS_FAILED = 'Failed';
    private static final Set<String> CORE_PACKAGES_CODE = new Set<String>{
        '10088',
        '10087',
        '10086',
        '10017',
        '10027',
        '10047'
    };
    private static final Set<String> CORE_PACKAGES_WITHOUT_SERVICE_RATE = new Set<String>{
        'Basic Package',
        'Plus Package',
        'Premier Package',
        'Self-Delivery'
    };
    private static final String SERVICE_RATE = 'Service Rate';
    private static final String SUCCESS_MESSAGE = 'Mx Portal Amendment event has been completed successfully';
    private static final String MX_PORTAL_BUSINESS_ERROR_MESSAGE = 'Mx portal amendment has been failed';
    Business_Vertical__c businessVerticalRx = new Business_Vertical__c();
    private enum EVENT_TOPICS {
        EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION,
        EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT,
        EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT,
        EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY,
        EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE,
        EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS,
        EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE
    }
    private static final String COMMITWORK_MESSAGE = 'Error occured during commit work';
    private static Map<String, EVENT_TOPICS> eventTopicMap = new Map<String, EVENT_TOPICS>{
        'EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION' => EVENT_TOPICS.EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION,
        'EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT' => EVENT_TOPICS.EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT,
        'EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT' => EVENT_TOPICS.EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT,
        'EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY' => EVENT_TOPICS.EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY,
        'EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE' => EVENT_TOPICS.EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE,
        'EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS' => EVENT_TOPICS.EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS,
        'EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE' => EVENT_TOPICS.EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE
    };
    private static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String MXP_EVENT_TYPE_NEW_STORE_EXPANSION = 'Mx Portal New Store Expansion';
    private static final String MXP_EVENT_TYPE_STOREFRONT = 'Mx Portal Add Storefront';
    private static final String MXP_EVENT_TYPE_PACKAGE_SWITCH = 'Mx Portal Package Switch';
    private static final String MXP_EVENT_TYPE_ADS_AND_PROMOS = 'Mx Portal Ads And Promos';
    Set<Id> recordIdsByPayload;
    private static Map<String, String> sourceByUUID = new Map<String, String>();
    private static Map<String, String> integrationTypeByUUID = new Map<String, String>();
    private static Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByBusinessId = new Map<String, Inbound_Ingestion_Log__c>();
    private static Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID = new Map<String, Inbound_Ingestion_Log__c>();
    Set<Id> inboundIngestionLogIds = new Set<Id>();
    private static final String COLON_SEPARATOR = ': ';
    private static final String CUSTOM_AMENDMENT_SUCCESSFUL_RESPONSE_ATTRIBUTE = 'isSuccessful';
    private static final String CUSTOM_AMENDMENT_QUOTE_ID_RESPONSE_ATTRIBUTE = 'quoteId';
    private static final String CUSTOM_AMENDMENT_MESSAGE_RESPONSE_ATTRIBUTE = 'message';
    private static final String CUSTOM_AMENDMENT_FAILED = 'Quote Amendment failed: ';
    private static final Boolean STORE_EXPANSION_ELIGIBILITY = false;
    List<SBQQ__Quote__c> amendmentQuote = new List<SBQQ__Quote__c>();
    List<Database.SaveResult> saveResultsDetails = new List<Database.SaveResult>();
    List<String> errorsList = new List<String>();
    String methodName = '';
    private static final String CLASS_NAME = 'MxPortalAmendmentServiceImpl';

    private static final String PAYLOAD_DISTRIBUTOR_FOR_NEW_STORE_EXPANSION_AND_CONTRACTS_CREATION = 'payloadDistributorForNewStoreExpansionAndContractsCreation';
    private static final String NSE_ON_EXISTING_CONTRACT = 'newStoreExpansionOnExistingContract';
    private static final String INITIATE_MXPORTAL_AMENDMENT_PROCESSING = 'initiateMxPortalAmendmentProcessing';
    private static final String CREATE_AMENDMENT_QUOTES_AND_QUOTELINES = 'createAmendmentQuoteAndQuoteLineItems';
    private static final String PAYLOAD_DISTRIBUTER_QUOTELINES_CREATION = 'payloadDistributorForQuoteLinesCreationFromPayload';
    private static final String INTIATE_NEW_QUOTE_AND_QUOTELINE_CREATION_FOR_AP = 'initiateNewQuoteAndQuoteLineCreationForAdsAndPromos';
    private static final String UPDATE_QUOTE_MAPPING_ON_AMENDMENT_QUOTE = 'updateQuoteMappingOnAmendmentQuote';
    private static Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c();
    private static Map<String, String> payloadMethodsToStepMap = new Map<String, String>{
        PAYLOAD_DISTRIBUTOR_FOR_NEW_STORE_EXPANSION_AND_CONTRACTS_CREATION => '1',
        NSE_ON_EXISTING_CONTRACT => '2',
        INITIATE_MXPORTAL_AMENDMENT_PROCESSING => '3',
        CREATE_AMENDMENT_QUOTES_AND_QUOTELINES => '4',
        PAYLOAD_DISTRIBUTER_QUOTELINES_CREATION => '5',
        INTIATE_NEW_QUOTE_AND_QUOTELINE_CREATION_FOR_AP => '6',
        UPDATE_QUOTE_MAPPING_ON_AMENDMENT_QUOTE => '7'
    };
    /**
     * @description It is used to subscribe to the instant ingestor platform event for mx portal.
     * @JIRA# LEM-16260
     * @param events
     */
    public void handleMxPortalEvents(List<Instant_Ingestor__e> events) {
        try {
            Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, InstantIngestionPayloadParser>();
            Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID = new Map<String, MxPortalPayloadParser>();
            for (Instant_Ingestor__e eachEvent : events) {
                if (String.isBlank(eachEvent.Payload__c)) {
                    continue;
                }
                switch on eventTopicMap.get(eachEvent.Topic__c) {
                    when EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION {
                        methodName = PAYLOAD_DISTRIBUTOR_FOR_NEW_STORE_EXPANSION_AND_CONTRACTS_CREATION;
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadForNewStoreExpansion(
                            this.recordIdsByPayload
                        );
                        payloadDistributorForNewStoreExpansionAndContractsCreation(
                            payLoadWrapperByIngestionLogUUID
                        );
                    }
                    when EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT {
                        methodName = NSE_ON_EXISTING_CONTRACT;
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadForNewStoreExpansion(
                            this.recordIdsByPayload
                        );
                        newStoreExpansionOnExistingContract(payLoadWrapperByIngestionLogUUID);
                    }
                    when EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT {
                        methodName = INITIATE_MXPORTAL_AMENDMENT_PROCESSING;
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        mxPortalPayloadWrapperByUUID = getParsedPayloadForMxPortalAmendments(
                            this.recordIdsByPayload
                        );
                        initiateMxPortalAmendmentProcessing(mxPortalPayloadWrapperByUUID);
                    }
                    when EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY {
                        methodName = CREATE_AMENDMENT_QUOTES_AND_QUOTELINES;
                        Set<MxPortalAmendmentPayloadWrapper> payloads = (Set<MxPortalAmendmentPayloadWrapper>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<MxPortalAmendmentPayloadWrapper>.class
                        );
                        //The events were published in bulk with chunk size of 1 to process the quote amendments that accepts
                        //a single opportunity and contract id in the custom amendment functionality.
                        //As a result, payloads in the set are fetched by the 0th index.
                        MxPortalAmendmentPayloadWrapper payloadInstance = new List<MxPortalAmendmentPayloadWrapper>(
                            payloads
                        )[0];
                        createAmendmentQuoteAndQuoteLineItems(
                            payloadInstance.opportunityId,
                            payloadInstance.contractId,
                            payloadInstance.inboundIngestionLogId,
                            payloadInstance.eventType
                        );
                    }
                    when EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE {
                        methodName = PAYLOAD_DISTRIBUTER_QUOTELINES_CREATION;
                        Set<MxPortalAmendmentPayloadWrapper> payloads = (Set<MxPortalAmendmentPayloadWrapper>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<MxPortalAmendmentPayloadWrapper>.class
                        );
                        MxPortalAmendmentPayloadWrapper payloadInstance = new List<MxPortalAmendmentPayloadWrapper>(
                            payloads
                        )[0];
                        mxPortalPayloadWrapperByUUID = getParsedPayloadForMxPortalAmendments(
                            new Set<Id>{ payloadInstance.inboundIngestionLogId }
                        );
                        payloadDistributorForQuoteLinesCreationFromPayload(
                            payloadInstance.amendmentQuoteId,
                            mxPortalPayloadWrapperByUUID,
                            payloadInstance.eventType
                        );
                    }
                    when EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS {
                        methodName = INTIATE_NEW_QUOTE_AND_QUOTELINE_CREATION_FOR_AP;
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        mxPortalPayloadWrapperByUUID = getParsedPayloadForMxPortalAmendments(
                            this.recordIdsByPayload
                        );
                        initiateNewQuoteAndQuoteLineCreationForAdsAndPromos(
                            mxPortalPayloadWrapperByUUID
                        );
                    }
                    when EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE {
                        methodName = UPDATE_QUOTE_MAPPING_ON_AMENDMENT_QUOTE;
                        Set<MxPortalAmendmentPayloadWrapper> payloads = (Set<MxPortalAmendmentPayloadWrapper>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<MxPortalAmendmentPayloadWrapper>.class
                        );
                        MxPortalAmendmentPayloadWrapper payloadInstance = new List<MxPortalAmendmentPayloadWrapper>(
                            payloads
                        )[0];
                        mxPortalPayloadWrapperByUUID = getParsedPayloadForMxPortalAmendments(
                            new Set<Id>{ payloadInstance.inboundIngestionLogId }
                        );
                        InstantIngestionQuoteAndQLIService.updateQuoteFieldsMappingOnAmendmentQuote(
                            payloadInstance.amendmentQuoteId,
                            mxPortalPayloadWrapperByUUID,
                            payloadInstance.eventType
                        );
                    }
                }
            }
        } catch (Exception recordsProcessingExceptions) {
            Logger.publish(recordsProcessingExceptions, LogEntry.SeverityLevel.HIGH);
            if (errorsList.isEmpty()) {
                IngestionErrorHandlingService.logUncaughtIngestionExceptionToInboundIngestionRecord(
                    recordsProcessingExceptions,
                    methodName,
                    payloadMethodsToStepMap,
                    inboundIngestionLog
                );
            } else {
                IngestionErrorHandlingService.logSaveResultIngestionExceptionToInboundIngestionRecord(
                    saveResultsDetails[0],
                    inboundIngestionLog,
                    methodName,
                    payloadMethodsToStepMap
                );
            }
        }
    }

    /**
     * @description It is used to check the eligibility for new store expansion, whether a new contract
     * needs to be created or a new agreement on the existing contract.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void payloadDistributorForNewStoreExpansionAndContractsCreation(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        methodName = PAYLOAD_DISTRIBUTOR_FOR_NEW_STORE_EXPANSION_AND_CONTRACTS_CREATION;

        Map<String, Id> existingContractsByBusinessId = checkEligibleContractsForNewStoreExpansion(
            payLoadWrapperByIngestionLogUUID
        );
        Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogsForNewStoresAndContractsCreation = inboundIngestionLogByBusinessId.clone();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogsForStoreAndAgreementCreation = new List<Inbound_Ingestion_Log__c>();
        for (String eachBusinessId : existingContractsByBusinessId.keySet()) {
            if (existingContractsByBusinessId.get(eachBusinessId) != null) {
                inboundIngestionLogsForStoreAndAgreementCreation.add(
                    inboundIngestionLogsForNewStoresAndContractsCreation.get(eachBusinessId)
                );
                inboundIngestionLogsForNewStoresAndContractsCreation.remove(eachBusinessId);
            }
        }
        //It is used to create new store account, opportunity, quote,quote lines, contracts and agreements.
        //This event is subscribed in the InstantIngestionOnboardingServiceImpl to re-use the same functionality.
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD,
            JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        inboundIngestionLogsForNewStoresAndContractsCreation.values()
                    )
                    .keySet()
            )
        );
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
        //It is used to initiate creation of new store account, opportunity and agreements on existing Contract.
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT,
            JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        inboundIngestionLogsForStoreAndAgreementCreation
                    )
                    .keySet()
            )
        );
    }

    /**
     * @description It is used to create a new store account, xref and agreement on an existing contract.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void newStoreExpansionOnExistingContract(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        methodName = NSE_ON_EXISTING_CONTRACT;

        InstantIngestionOnboardingService.payloadDistributorForAccountsAndXrefsBizRefs(
            payLoadWrapperByIngestionLogUUID,
            sourceByUUID
        );
        InstantIngestionOnboardingService.payloadDistributorForContactsAndACRs(
            payLoadWrapperByIngestionLogUUID,
            sourceByUUID
        );
        InstantIngestionOnboardingService.payloadDistributorForOpportunities(
            payLoadWrapperByIngestionLogUUID,
            integrationTypeByUUID,
            inboundIngestionLogByUUID
        );
        Map<Id, Set<String>> storeAccountIdsByParentId = new Map<Id, Set<String>>();
        Map<String, Account> storeAccountsByUUID = InstantIngestionRecordsGetterService.getStoreAccountByUUID(
            payLoadWrapperByIngestionLogUUID
        );
        Map<Id, Set<String>> contractIdWithAccountIds = new Map<Id, Set<String>>();
        for (Account eachStoreAccount : storeAccountsByUUID.values()) {
            if (storeAccountIdsByParentId.containsKey(eachStoreAccount.ParentId)) {
                storeAccountIdsByParentId.get(eachStoreAccount.ParentId).add(eachStoreAccount.Id);
            } else {
                storeAccountIdsByParentId.put(
                    eachStoreAccount.ParentId,
                    new Set<String>{ eachStoreAccount.Id }
                );
            }
        }
        List<Contract> existingContracts;
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectByParentAccountId(storeAccountIdsByParentId.keySet())
        ) {
            contractIdWithAccountIds = new Map<Id, Set<String>>{
                eachContract.Id => storeAccountIdsByParentId.get(eachContract.AccountId)
            };
            existingContracts = new List<Contract>{ eachContract };
        }
        IngestionErrorHandlingService.updateInboundIngestionLogForSuccess(
            inboundIngestionLog,
            SUCCESS_MESSAGE
        );
        AgreementsService.createAgreementsfromContractsWithGroup(
            existingContracts,
            contractIdWithAccountIds,
            new Map<Id, Map<Id, String>>{}
        );
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
    }

    /**
     * @description It is used to initiate the amendment process for opportunity, quote and quote lines creation.
     * This method checks the eligibility based on the event type and invokes the events with different topics.
     * For ads and promos, the event is invoked for new quote and contract while for non ads and promos,
     * it invokes the custom amendment process with events in chunks to create the amendment quotes and quote lines.
     * @param mxPortalPayloadWrapperByUUID
     */
    private void initiateMxPortalAmendmentProcessing(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        methodName = INITIATE_MXPORTAL_AMENDMENT_PROCESSING;

        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        fflib_ISObjectUnitOfWork uowForUpdatingInternalPayloadOnIngestionLog = Application.UNITOFWORK.newInstance();
        Set<Object> payLoads = new Set<Object>();
        Map<String, Account> storeAccountByStoreId = InstantIngestionCheckRecordsService.checkAndFetchExistingStoreAccountsByStoreId(
            mxPortalPayloadWrapperByUUID
        );
        Map<Id, Contract> existingContractByBusinessAccountId = InstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
            new Map<Id, Account>(storeAccountByStoreId.values()).keySet()
        );
        if (storeAccountByStoreId.isEmpty()) {
            throw new DmlException(
                System.Label.Instant_Ingestion_Invalid_Store_Id_Exception_Message
            );
        }
        for (
            MxPortalPayloadParser eachParsedMxPortalPayload : mxPortalPayloadWrapperByUUID.values()
        ) {
            Account accountforAssociation = storeAccountByStoreId.get(
                        eachParsedMxPortalPayload.store.storeId
                    )
                    .Franchise_Parent__c != null
                ? storeAccountByStoreId.get(eachParsedMxPortalPayload.store.storeId)
                      .Franchise_Parent__r
                : storeAccountByStoreId.get(eachParsedMxPortalPayload.store.storeId).Parent;
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionOpportunityService.createAmendmentOpportunityForMxPortal(
                    eachParsedMxPortalPayload,
                    accountforAssociation,
                    integrationTypeByUUID.get(eachParsedMxPortalPayload.Uuid),
                    inboundIngestionLogByUUID.get(eachParsedMxPortalPayload.uuid).Id
                )
            );
            uow.registerDirty(
                new Account(
                    Id = storeAccountByStoreId.get(eachParsedMxPortalPayload.store.storeId).Id,
                    Unique_Identifier__c = eachParsedMxPortalPayload.uuid
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
        Map<String, Opportunity> opportunitiesByPassedUUID = InstantIngestionRecordsGetterService.getOpportunitiesByUUID(
            mxPortalPayloadWrapperByUUID,
            null
        );
        MxPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new MxPortalAmendmentPayloadWrapper();
        Set<Id> adsAndPromosIngestionLogIds = new Set<Id>();
        for (
            MxPortalPayloadParser eachParsedMxPortalPayload : mxPortalPayloadWrapperByUUID.values()
        ) {
            if (
                inboundIngestionLogByUUID.containsKey(eachParsedMxPortalPayload.uuid) &&
                integrationTypeByUUID.get(eachParsedMxPortalPayload.uuid) !=
                MXP_EVENT_TYPE_ADS_AND_PROMOS &&
                (existingContractByBusinessAccountId.isEmpty() ||
                !existingContractByBusinessAccountId.containsKey(
                    opportunitiesByPassedUUID.get(eachParsedMxPortalPayload.uuid).AccountId
                ))
            ) {
                uowForUpdatingInternalPayloadOnIngestionLog.registerDirty(
                    new Inbound_ingestion_Log__c(
                        Id = inboundIngestionLogByUUID.get(eachParsedMxPortalPayload.uuid).Id,
                        Status__c = STATUS_FAILED,
                        Business_Error_Message__c = MX_PORTAL_BUSINESS_ERROR_MESSAGE,
                        Failure_Step__c = methodName == ''
                            ? 1
                            : Decimal.valueof(payloadMethodsToStepMap.get(methodName)),
                        Stack_Trace__c = new DmlException()
                            .getStackTraceString()
                            .substringAfter('\n'),
                        Exception_Message__c = System.Label.Instant_Ingestion_Blank_Contract_Exception_Message
                    )
                );
                continue;
            }
            amendmentPayloadWrapper.opportunityId = opportunitiesByPassedUUID.get(
                    eachParsedMxPortalPayload.uuid
                )
                .Id;
            amendmentPayloadWrapper.contractId = existingContractByBusinessAccountId.containsKey(
                    opportunitiesByPassedUUID.get(eachParsedMxPortalPayload.uuid).AccountId
                )
                ? existingContractByBusinessAccountId.get(
                          opportunitiesByPassedUUID.get(eachParsedMxPortalPayload.uuid).AccountId
                      )
                      .Id
                : null;
            amendmentPayloadWrapper.inboundIngestionLogId = inboundIngestionLogByUUID.get(
                    eachParsedMxPortalPayload.uuid
                )
                .Id;
            amendmentPayloadWrapper.eventType = integrationTypeByUUID.get(
                eachParsedMxPortalPayload.uuid
            );
            uowForUpdatingInternalPayloadOnIngestionLog.registerDirty(
                new Inbound_Ingestion_Log__c(
                    Id = inboundIngestionLogByUUID.get(eachParsedMxPortalPayload.uuid).Id,
                    Internal_Payload_For_Retry__c = JSON.serialize(amendmentPayloadWrapper)
                )
            );
            payLoads.add(amendmentPayloadWrapper);

            if (
                (inboundIngestionLogByUUID.containsKey(eachParsedMxPortalPayload.uuid) &&
                (integrationTypeByUUID.get(eachParsedMxPortalPayload.uuid) ==
                MXP_EVENT_TYPE_ADS_AND_PROMOS) ||
                (integrationTypeByUUID.get(eachParsedMxPortalPayload.uuid) ==
                MXP_EVENT_TYPE_PACKAGE_SWITCH &&
                existingContractByBusinessAccountId.get(
                        storeAccountByStoreId.get(eachParsedMxPortalPayload.store.storeId).ParentId
                    )
                    .Account.Total_Number_Of_Stores__c > 1))
            ) {
                adsAndPromosIngestionLogIds.add(
                    inboundIngestionLogByUUID.get(eachParsedMxPortalPayload.uuid).Id
                );
            }
        }
        uowForUpdatingInternalPayloadOnIngestionLog.commitWork();
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
        if (!adsAndPromosIngestionLogIds.isEmpty()) {
            InstantIngestorEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        adsAndPromosIngestionLogIds,
                        Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                    )
                }
            );
        } else {
            InstantIngestorEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                        payLoads,
                        1
                    )
                }
            );
        }
    }

    /**
     * @description It is used to initiate the process after the amendment creation is complete.
     * For package switch, it cancels the existing lines by updating quantity to 0 and then adds new
     * package and option lines on the quotes.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     * @param mxPortalEventType
     */
    private void payloadDistributorForQuoteLinesCreationFromPayload(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        String mxPortalEventType
    ) {
        methodName = PAYLOAD_DISTRIBUTER_QUOTELINES_CREATION;

        this.amendmentQuote = QuotesSelector.newInstance().selectById(new Set<Id>{ quoteId });
        if (mxPortalEventType == MXP_EVENT_TYPE_PACKAGE_SWITCH  || mxPortalEventType == MXP_EVENT_TYPE_STOREFRONT ) {
            cancelExistingPackageLines(quoteId,mxPortalEventType);
        }
        addParentQuoteLineItemsOnAmendmentQuote(quoteId, mxPortalPayloadWrapperByUUID);
        addOptionQuoteLineItemsOnAmendmentQuote(quoteId, mxPortalPayloadWrapperByUUID);
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY,
            JSON.serialize(new Set<Id>{ quoteId })
        );
    }

    /**
     * @description It is used to add bundle and standalone quote lines on the amendment quote.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     */
    private void addParentQuoteLineItemsOnAmendmentQuote(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroup = QuoteLineGroupSelector.newInstance()
            .selectQuoteLineGroupsByQuoteIds(new Set<Id>{ quoteId });
        for (
            MxPortalPayloadParser eachMxPortalParsedPayload : mxPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForMxPortalPayload(
                    eachMxPortalParsedPayload,
                    this.amendmentQuote[0],
                    pricebook,
                    quoteLineGroup[0].Id,
                    sourceByUUID.get(eachMxPortalParsedPayload.uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to add option quote lines on the amendment quote.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     */
    private void addOptionQuoteLineItemsOnAmendmentQuote(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        Map<String, SBQQ__QuoteLine__c> quoteLinesWithProductNameByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByMxPortalUUID(
            mxPortalPayloadWrapperByUUID
        );
        for (
            MxPortalPayloadParser eachMxPortalParsedPayload : mxPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForMxPortalPayload(
                    eachMxPortalParsedPayload,
                    quoteLinesWithProductNameByUUID,
                    this.amendmentQuote[0],
                    pricebook
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to zero out the quantity for the amended quote lines.
     * @param quoteId
     * @param eventType
     */
    private void cancelExistingPackageLines(Id quoteId,String eventType) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        Decimal quantity = 0;
        for (
            SBQQ__QuoteLine__c eachExistingQuoteLineForCancellation : QuoteLineItemsSelector.newInstance()
                .selectQuoteLineItemsFromQuoteIds(new Set<Id>{ quoteId })
        ) {
            if (
                CORE_PACKAGES_CODE.contains(
                    eachExistingQuoteLineForCancellation.SBQQ__ProductCode__c
                ) ||
                CORE_PACKAGES_CODE.contains(eachExistingQuoteLineForCancellation.Package_Code__c)
            ) {
                quantity = (eventType == MXP_EVENT_TYPE_PACKAGE_SWITCH )? 0:
                ( eachExistingQuoteLineForCancellation.Package__c == STOREFRONT_PACKAGE ||
                eachExistingQuoteLineForCancellation.SBQQ__Product__r.Name == STOREFRONT_PACKAGE ) ?0:eachExistingQuoteLineForCancellation.SBQQ__Quantity__c;
                uow.registerDirty(
                    new SBQQ__QuoteLine__c(
                        Id = eachExistingQuoteLineForCancellation.Id,
                        SBQQ__Quantity__c = quantity
                    )
                );
            }
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to commit the changes to database.
     * @param uow
     * @param insertUnitOfWorkHelper
     */
    private void commitUnitOfWork(
        fflib_ISObjectUnitOfWork uow,
        InsertUnitOfWorkHelper insertUnitOfWorkHelper
    ) {
        uow.registerWork(insertUnitOfWorkHelper);
        SBQQ.TriggerControl.disable();
        uow.commitWork();
        SBQQ.TriggerControl.enable();
        saveResultsDetails = insertUnitOfWorkHelper.saveResults != null
            ? insertUnitOfWorkHelper.saveResults
            : new List<Database.SaveResult>();
        for (Database.SaveResult eachSaveResultsDetail : saveResultsDetails) {
            for (Database.Error eachSaveResultError : eachSaveResultsDetail.getErrors()) {
                errorsList.add(
                    eachSaveResultError.getStatusCode() +
                        COLON_SEPARATOR +
                        eachSaveResultError.getMessage() +
                        COLON_SEPARATOR +
                        eachSaveResultError.getFields()
                );
            }
        }

        if (!errorsList.isEmpty()) {
            throw new DmlException(COMMITWORK_MESSAGE);
        }
    }

    /**
     * @description It is used to create the amendment quote and quote lines by the passed opportunity Id.
     * @param opportunityId
     * @param contractId
     * @param inboundIngestionLogId
     * @param mxPortalEventType
     */
    private void createAmendmentQuoteAndQuoteLineItems(
        Id opportunityId,
        Id contractId,
        Id inboundIngestionLogId,
        String mxPortalEventType
    ) {
        methodName = CREATE_AMENDMENT_QUOTES_AND_QUOTELINES;
        inboundIngestionLog = new Inbound_Ingestion_Log__c(Id = inboundIngestionLogId);
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Object> amendmentQuoteIdWithIngestionLogId = new Set<Object>();
        String response;
        MxPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new MxPortalAmendmentPayloadWrapper();
        //this calls the custom amendment process to create an amendment quote with quote lines.
        SBQQ.TriggerControl.disable();
        response = AmendmentService.createAmendmentFromOpportunity(
            String.valueOf(opportunityId),
            String.valueOf(contractId)
        );
        SBQQ.TriggerControl.enable();
        Map<String, Object> amendmentResponse = (Map<String, Object>) JSON.deserializeUntyped(
            response
        );
        if ((Boolean) amendmentResponse?.get(CUSTOM_AMENDMENT_SUCCESSFUL_RESPONSE_ATTRIBUTE)) {
            amendmentPayloadWrapper.amendmentQuoteId = Id.valueOf(
                (String) amendmentResponse.get(CUSTOM_AMENDMENT_QUOTE_ID_RESPONSE_ATTRIBUTE)
            );
            amendmentPayloadWrapper.inboundIngestionLogId = inboundIngestionLogId;
            amendmentPayloadWrapper.eventType = mxPortalEventType;
            amendmentQuoteIdWithIngestionLogId.add(amendmentPayloadWrapper);
        } else {
            throw new DmlException(
                CUSTOM_AMENDMENT_FAILED +
                (String) amendmentResponse.get(CUSTOM_AMENDMENT_MESSAGE_RESPONSE_ATTRIBUTE)
            );
        }
        if (amendmentQuoteIdWithIngestionLogId.isEmpty()) {
            return;
        }
        uow.registerDirty(
            new Inbound_Ingestion_Log__c(
                Id = inboundIngestionLogId,
                Internal_Payload_For_Retry__c = JSON.serialize(amendmentPayloadWrapper)
            )
        );

        commitUnitOfWork(uow, insertUnitOfWorkHelper);
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_QUOTE_FIELD_MAPPING_ON_AMENDMENT_QUOTE,
            JSON.serialize(amendmentQuoteIdWithIngestionLogId)
        );
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE,
            JSON.serialize(amendmentQuoteIdWithIngestionLogId)
        );
    }

    /**
     * @description It is used to initiate the creation of new quote and quote lines for ads and promos event type.
     * @param mxPortalPayloadWrapperByUUID
     */
    private void initiateNewQuoteAndQuoteLineCreationForAdsAndPromos(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        methodName = INTIATE_NEW_QUOTE_AND_QUOTELINE_CREATION_FOR_AP;

        Map<String, Opportunity> adsAndPromosOpportunitiesByUUID = InstantIngestionRecordsGetterService.getOpportunitiesByUUID(
            mxPortalPayloadWrapperByUUID,
            null
        );
        PriceBook2 standardPricebook = PricebookSelector.newInstance().selectStandardPricebook();
        initiateQuoteCreationForAdsPromos(
            mxPortalPayloadWrapperByUUID,
            adsAndPromosOpportunitiesByUUID,
            standardPricebook
        );
        Map<String, SBQQ__Quote__c> adsAndPromosQuotesByUUID = InstantIngestionRecordsGetterService.getQuotesByMxPortalUUID(
            mxPortalPayloadWrapperByUUID
        );
        initiateQuoteLineGroupCreationForAdsPromos(
            mxPortalPayloadWrapperByUUID,
            adsAndPromosOpportunitiesByUUID,
            adsAndPromosQuotesByUUID
        );
        Map<Id, SBQQ__QuoteLineGroup__c> adsAndPromosQuoteLineGroupByUUID = InstantIngestionCheckRecordsService.getQuoteLineGroupsByAccountIds(
            new Map<Id, SBQQ__Quote__c>(adsAndPromosQuotesByUUID.values()).keySet()
        );
        initiateQuoteLinesCreationForAdsPromos(
            mxPortalPayloadWrapperByUUID,
            adsAndPromosQuotesByUUID,
            standardPricebook,
            adsAndPromosQuoteLineGroupByUUID
        );
        initiateQuoteLineOptions(
            mxPortalPayloadWrapperByUUID,
            adsAndPromosQuotesByUUID,
            standardPricebook
        );
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            methodName,
            payloadMethodsToStepMap,
            inboundIngestionLog,
            CLASS_NAME
        );
        publishMxPortalBulkEventsByEventTopic(
            EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY,
            JSON.serialize(new Map<Id, SBQQ__Quote__c>(adsAndPromosQuotesByUUID.values()).keySet())
        );
    }

    /**
     * @description It is used to create the new quotes for ads and promos event type.
     * @param mxPortalPayloadWrapperByUUID
     * @param adsAndPromosOpportunitiesByUUID
     * @param standardPricebook
     */
    private void initiateQuoteCreationForAdsPromos(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        Map<String, Opportunity> adsAndPromosOpportunitiesByUUID,
        PriceBook2 standardPricebook
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            MxPortalPayloadParser eachMxPortalPayloadParser : mxPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createAdsAndPromosQuoteForMxPortal(
                    eachMxPortalPayloadParser,
                    adsAndPromosOpportunitiesByUUID.get(eachMxPortalPayloadParser.uuid),
                    standardPricebook.Id,
                    sourceByUUID.get(eachMxPortalPayloadParser.uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create the new quote line group for ads and promos event type.
     * @param mxPortalPayloadWrapperByUUID
     * @param adsAndPromosOpportunitiesByUUID
     * @param adsAndPromosQuotesByUUID
     */
    private void initiateQuoteLineGroupCreationForAdsPromos(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        Map<String, Opportunity> adsAndPromosOpportunitiesByUUID,
        Map<String, SBQQ__Quote__c> adsAndPromosQuotesByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            MxPortalPayloadParser eachMxPortalPayloadParser : mxPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineGroup(
                    adsAndPromosOpportunitiesByUUID.get(eachMxPortalPayloadParser.uuid),
                    adsAndPromosQuotesByUUID.get(eachMxPortalPayloadParser.uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create quote line options in case of multi-location package upgrade
     * scenario.
     * @param mxPortalPayloadWrapperByUUID
     * @param adsAndPromosQuotesByUUID
     * @param standardPricebook
     */
    private void initiateQuoteLineOptions(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        Map<String, SBQQ__Quote__c> adsAndPromosQuotesByUUID,
        PriceBook2 standardPricebook
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, SBQQ__QuoteLine__c> quoteLinesWithProductNameByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByMxPortalUUID(
            mxPortalPayloadWrapperByUUID
        );
        for (
            MxPortalPayloadParser eachMxPortalParsedPayload : mxPortalPayloadWrapperByUUID.values()
        ) {
            if (
                integrationTypeByUUID.get(eachMxPortalParsedPayload.uuid) ==
                MXP_EVENT_TYPE_ADS_AND_PROMOS
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForMxPortalPayload(
                    eachMxPortalParsedPayload,
                    quoteLinesWithProductNameByUUID,
                    adsAndPromosQuotesByUUID.get(eachMxPortalParsedPayload.uuid),
                    standardPricebook
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create the new quote lines for ads and promos event type.
     * @param mxPortalPayloadWrapperByUUID
     * @param adsAndPromosQuotesByUUID
     * @param standardPricebook
     * @param adsAndPromosQuoteLineGroupByUUID
     */
    private void initiateQuoteLinesCreationForAdsPromos(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        Map<String, SBQQ__Quote__c> adsAndPromosQuotesByUUID,
        PriceBook2 standardPricebook,
        Map<Id, SBQQ__QuoteLineGroup__c> adsAndPromosQuoteLineGroupByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            MxPortalPayloadParser eachMxPortalPayloadParser : mxPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForMxPortalPayload(
                    eachMxPortalPayloadParser,
                    adsAndPromosQuotesByUUID.get(eachMxPortalPayloadParser.uuid),
                    standardPricebook,
                    adsAndPromosQuoteLineGroupByUUID.get(
                            adsAndPromosQuotesByUUID.get(eachMxPortalPayloadParser.uuid)
                                .SBQQ__Account__c
                        )
                        .Id,
                    sourceByUUID.get(eachMxPortalPayloadParser.uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to check the eligibility for new store expansion. It checks for existing
     * subscriptions and pricing in the system and compares with the pricing and package data received in the payload.
     * If there is a mismatch between the existing data and the payload data, then it invokes
     * new store account creation with a new xref, quote, quote lines and contract.
     * If there is a match between the data, then it invokes store account with xref and opportunity creation
     * with a new agreement on the existing Contract.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Id>
     */
    private Map<String, Id> checkEligibleContractsForNewStoreExpansion(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Boolean isMismatchInPayloadPackageAndPrice;
        Map<String, SBQQ__Subscription__c> existingSubscriptionsByAccountd = InstantIngestionCheckRecordsService.getExistingSubscriptionsByBusinessAccount(
            payLoadWrapperByIngestionLogUUID
        );
        Map<String, Id> businessAccountsToApplicableContractIds = new Map<String, Id>();
        Map<String, List<String>> applicableContractIdByBusinessId = new Map<String, List<String>>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            for (
                InstantIngestionPayloadParser.OrderProductsDetails eachProductPackage : eachPayload
                    .store.orderProducts
            ) {
                isMismatchInPayloadPackageAndPrice = false;
                for (
                    InstantIngestionPayloadParser.ProductOptionsDetails eachPayloadProductOption : eachProductPackage.productOptions
                ) {
                    if (
                        eachPayloadProductOption.name.contains(SERVICE_RATE) ||
                        isEligibleToSkipQuoteLineAndPricingComparison(eachPayloadProductOption)
                    ) {
                        continue;
                    }
                    String businessIdPackageNameAndProductOptionNameConcat =
                        eachPayload.business.businessId +
                        packageNameForProcessing(eachProductPackage) +
                        COLON_SEPARATOR +
                        eachPayloadProductOption.name;
                    if (
                        applicableContractIdByBusinessId.containsKey(
                            eachPayload.business.businessId
                        )
                    ) {
                        List<String> subscriptionRelatedContractIds = applicableContractIdByBusinessId.get(
                            eachPayload.business.businessId
                        );
                        subscriptionRelatedContractIds.add(
                            existingSubscriptionsByAccountd.containsKey(
                                    businessIdPackageNameAndProductOptionNameConcat
                                )
                                ? String.valueOf(
                                      existingSubscriptionsByAccountd.get(
                                              businessIdPackageNameAndProductOptionNameConcat
                                          )
                                          .SBQQ__Contract__c
                                  )
                                : 'null'
                        );
                        applicableContractIdByBusinessId.put(
                            eachPayload.business.businessId,
                            subscriptionRelatedContractIds
                        );
                    } else {
                        applicableContractIdByBusinessId.put(
                            eachPayload.business.businessId,
                            existingSubscriptionsByAccountd.containsKey(
                                    businessIdPackageNameAndProductOptionNameConcat
                                )
                                ? new List<String>{
                                      string.valueof(
                                          existingSubscriptionsByAccountd.get(
                                                  businessIdPackageNameAndProductOptionNameConcat
                                              )
                                              .SBQQ__Contract__c
                                      )
                                  }
                                : new List<String>{ 'null' }
                        );
                    }

                    if (
                        existingSubscriptionsByAccountd.containsKey(
                            businessIdPackageNameAndProductOptionNameConcat
                        ) &&
                        !isExistingSubscriptionsAndPriceMatching(
                            existingSubscriptionsByAccountd.get(
                                businessIdPackageNameAndProductOptionNameConcat
                            ),
                            eachProductPackage,
                            eachPayloadProductOption
                        )
                    ) {
                        isMismatchInPayloadPackageAndPrice = true;
                        applicableContractIdByBusinessId.put(
                            eachPayload.business.businessId,
                            new List<String>{ 'null' }
                        );
                        //break;
                    }
                }
            }
            businessAccountsToApplicableContractIds = getApplicableBusinessAccount(
                businessAccountsToApplicableContractIds,
                applicableContractIdByBusinessId,
                eachPayload
            );
        }

        return businessAccountsToApplicableContractIds;
    }

    /**
     * @description It is used to get the package name from the payload for processing.
     * @param eachProductPackage
     * @return String
     */
    private String packageNameForProcessing(
        InstantIngestionPayloadParser.OrderProductsDetails eachProductPackage
    ) {
        String packageName;
        if (eachProductPackage.name == STANDARD_STOREFRONT_PACKAGE) {
            packageName = STOREFRONT_PACKAGE;
        } else {
            packageName = eachProductPackage.name;
        }
        return packageName;
    }
    /**
     * @description It is used to applicable business account based on contract
     * @param businessAccountsToApplicableContractIds
     * @param applicableContractIdByBusinessId
     * @param eachPayload
     * @return Map<String, Id>
     */
    private Map<String, Id> getApplicableBusinessAccount(
        Map<String, Id> businessAccountsToApplicableContractIds,
        Map<String, List<String>> applicableContractIdByBusinessId,
        InstantIngestionPayloadParser eachPayload
    ) {
        List<String> applicableContractsList = applicableContractIdByBusinessId.get(
            eachPayload.business.businessId
        );
        Set<String> applicableContracts = new Set<String>(applicableContractsList);
        if (applicableContracts.contains('null') || applicableContracts.Size() != 1) {
            businessAccountsToApplicableContractIds.put(eachPayload.business.businessId, null);
        } else {
            businessAccountsToApplicableContractIds.put(
                eachPayload.business.businessId,
                applicableContractsList[0]
            );
        }
        return businessAccountsToApplicableContractIds;
    }

    /**
     * @description It is used to compare the existing packages, product subscriptions and prices with
     * the packages, products and pricing received from the payload for new store expansion.
     * @param eachSubscription
     * @param eachProductPackage
     * @param eachPayloadProductOption
     * @return Boolean
     */
    private Boolean isExistingSubscriptionsAndPriceMatching(
        SBQQ__Subscription__c eachSubscription,
        InstantIngestionPayloadParser.OrderProductsDetails eachProductPackage,
        InstantIngestionPayloadParser.ProductOptionsDetails eachPayloadProductOption
    ) {
        Decimal commission = eachPayloadProductOption.commission != null
            ? Decimal.valueOf(eachPayloadProductOption.commission).setScale(2)
            : null;
        Decimal fee = eachPayloadProductOption.fee != null
            ? Decimal.valueOf(eachPayloadProductOption.fee).setScale(2)
            : null;
        Decimal trialCommission = eachPayloadProductOption.trialCommission != null
            ? Decimal.valueOf(eachPayloadProductOption.trialCommission).setScale(2)
            : null;
        Decimal trialFee = eachPayloadProductOption.trialFee != null
            ? Decimal.valueOf(eachPayloadProductOption.trialFee).setScale(2)
            : null;
        return ((eachSubscription.Final_Fee__c == fee &&
        eachSubscription.Final_Commission__c == commission &&
        eachSubscription.Trial_Commission__c == trialCommission &&
        eachSubscription.Trial_Fee__c == trialFee));
    }

    /**
     * @description It is used to get the parsed payload by the passed inbound ingestion log ids.
     * @param inboundIngestionLogIds
     * @return Map<String, InstantIngestionPayloadParser>
     */
    private Map<String, InstantIngestionPayloadParser> getParsedPayloadForNewStoreExpansion(
        Set<Id> inboundIngestionLogIds
    ) {
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, InstantIngestionPayloadParser>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(inboundIngestionLogIds)
        ) {
            inboundIngestionLog = eachInboundIngestionLog;
            InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
                eachInboundIngestionLog.Payload__c,
                InstantIngestionPayloadParser.class
            );
            payLoadWrapperByIngestionLogUUID.put(eachInboundIngestionLog.UUID__c, parsedPayload);
            sourceByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog.Source__c);
            inboundIngestionLogByBusinessId.put(
                parsedPayload.business.businessId,
                eachInboundIngestionLog
            );
            inboundIngestionLogByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog);
            integrationTypeByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Integration_Type__c
            );
        }
        return payLoadWrapperByIngestionLogUUID;
    }

    /**
     * @description It is used to get the parsed payload by the passed inbound ingestion log ids for mx portal events.
     * @param inboundIngestionLogIds
     * @return Map<String, InstantIngestionPayloadParser>
     */
    private Map<String, MxPortalPayloadParser> getParsedPayloadForMxPortalAmendments(
        Set<Id> inboundIngestionLogIds
    ) {
        Map<String, MxPortalPayloadParser> mxPortalPayLoadWrapperByIngestionLogUUID = new Map<String, MxPortalPayloadParser>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(inboundIngestionLogIds)
        ) {
            inboundIngestionLog = eachInboundIngestionLog;

            MxPortalPayloadParser parsedPayload = (MxPortalPayloadParser) System.JSON.deserialize(
                eachInboundIngestionLog.Payload__c,
                MxPortalPayloadParser.class
            );
            mxPortalPayLoadWrapperByIngestionLogUUID.put(
                eachInboundIngestionLog.UUID__c,
                parsedPayload
            );
            sourceByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog.Source__c);
            inboundIngestionLogByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog);
            integrationTypeByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Integration_Type__c
            );
        }
        return mxPortalPayLoadWrapperByIngestionLogUUID;
    }

    /**
     * @description Payload wrapper for capturing the details and to publish in the events.
     */
    public class MxPortalAmendmentPayloadWrapper {
        public Id opportunityId;
        public Id contractId;
        public Id inboundIngestionLogId;
        public String eventType;
        public Id amendmentQuoteId;

        /**
         * @description Payload wrapper constructor
         */
        public MxPortalAmendmentPayloadWrapper() {
            this.opportunityId = opportunityId;
            this.contractId = contractId;
            this.inboundIngestionLogId = inboundIngestionLogId;
            this.eventType = eventType;
            this.amendmentQuoteId = amendmentQuoteId;
        }
    }

    /**
     * @description It is used to skip the comparison of quote lines if commission and fee both are
     * sent as null in payload.
     * @JIRA LEM-21655
     * @param eachPayloadProductOption
     * @return Boolean
     * TO DO: Currently it is applicable only for Dashpass quote line and will be made as
     *        generic post go-live to skip comparison of quote lines where commission and fee are received
     *        as null in the payload.
     */
    private Boolean isEligibleToSkipQuoteLineAndPricingComparison(
        InstantIngestionPayloadParser.ProductOptionsDetails eachPayloadProductOption
    ) {
        return (eachPayloadProductOption.name == PRODUCT_NAME_DASHPASS &&
        String.isBlank(eachPayloadProductOption.commission) &&
        String.isBlank(eachPayloadProductOption.fee));
    }

    /**
     * @description It is used to publish the mx portal events by the received event topic and data.
     * @param eventTopic
     * @param dataToProcess
     */
    private void publishMxPortalBulkEventsByEventTopic(String eventTopic, String dataToProcess) {
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{ eventTopic => dataToProcess }
        );
    }
}