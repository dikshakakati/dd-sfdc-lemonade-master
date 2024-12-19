/**
 * @author Deloitte
 * @date 07/24/2024
 * @description Service Implementation class for InstantIngestionOnboardingService.
 *
 */
@SuppressWarnings('PMD.ExcessiveClassLength,PMD.CyclomaticComplexity,PMD.ApexCRUDViolation')
public inherited sharing class SSOBOnboardingServiceImpl implements ISSOBOnboardingService {
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS = 'EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS';
    private static final String EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY = 'EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY';
    private static final String EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String CUSTOM_AMENDMENT_FAILED = 'Quote Amendment failed: ';
    private static final String LOG_DOMAIN = 'Instant Ingestion';
    private static final String LOG_INBOUND_INGESTION_RECORDS_INSERT_FAILED = 'Creation on inbound ingestion records failed';
    private enum EVENT_TOPICS {
        EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY,
        EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE
    }
    Business_Vertical__c businessVerticalRx = new Business_Vertical__c();
    private static Map<String, EVENT_TOPICS> eventTopicMap = new Map<String, EVENT_TOPICS>{
        'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD' => EVENT_TOPICS.EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD,
        'EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY' => EVENT_TOPICS.EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY,
        'EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE' => EVENT_TOPICS.EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE
    };
    Set<Id> recordIdsByPayload;
    Map<String, String> sourceByUUID = new Map<String, String>();
    List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>();
    Map<Id, Opportunity> existingOpportunityByAccountId = new Map<Id, Opportunity>();
    Map<Id, Opportunity> existingAmendOpportunityByAccountId = new Map<Id, Opportunity>();
    Map<String, Account> existingAccountByBusinessId = new Map<String, Account>();
    Map<Id, Contract> existingContractByBusinessAccountId = new Map<Id, Contract>();
    private static Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID = new Map<String, Inbound_Ingestion_Log__c>();
    Map<Id, SBQQ__Quote__c> quotesByOpportunityId = new Map<Id, SBQQ__Quote__c>();
    List<SBQQ__Quote__c> amendmentQuote = new List<SBQQ__Quote__c>();
    Boolean isNonMxPortalAmendmentEvent = false;
    Savepoint savePointForRollback;
    private static final String SELF_SERVING_ONBOARDING_SERVICE = 'selfServiceOnboardingService';
    private static final String CPQ_WS = 'CPQ';
    private static final String CLASS_NAME = 'InstantIngestionOnboardingServiceImpl';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF = 'payloadDistributorForAccountsAndXrefsBizRefs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR = 'payloadDistributorForContactsAndACRs';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES = 'payloadDistributorForOpportunities';
    private static final String PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES = 'payloadDistributorForQuotesAndQuoteLines';
    private static final String CREATE_AMENDMENT_QUOTES_AND_QUOTELINES = 'createAmendmentQuoteAndQuoteLineItems';
    private static final String STATUS_FAILED = 'Failed';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String SOURCE_SSOB = 'SSOB';
    private static Map<String, String> payloadMethodsToStepMap = new Map<String, String>{
        PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF => '1',
        PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR => '2',
        PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES => '3',
        PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES => '4',
        CREATE_AMENDMENT_QUOTES_AND_QUOTELINES => '5'
    };
    private static final String BUSINESS_ERROR_MESSAGE = 'SSOB onboarding event has been Failed';
    private static final String SUCCESS_MESSAGE = 'SSOB onboarding event has been completed successfully';
    List<Database.SaveResult> saveResultsDetails = new List<Database.SaveResult>();
    List<String> errorsList = new List<String>();
    private String methodName = '';
    private String ssobType = '';
    private String typeExisting = 'Existing ';
    private static final String COMMITWORK_MESSAGE = 'Error occured during commit work';

    /**
     * @description Constructor for InstantIngestionOnboardingServiceImpl.
     */
    public SSOBOnboardingServiceImpl() {
        this.businessVerticalRx = InstantIngestionRecordsGetterService.getRxBusinessVertical();
        this.recordIdsByPayload = recordIdsByPayload;
        this.existingOpportunityByAccountId = existingOpportunityByAccountId;
        this.existingAmendOpportunityByAccountId = existingAmendOpportunityByAccountId;
        this.existingAccountByBusinessId = existingAccountByBusinessId;
        this.quotesByOpportunityId = quotesByOpportunityId;
        this.sourceByUUID = sourceByUUID;
        this.methodName = methodName;
    }
    /**
     * @description It is used to subscribe to the instant ingestor platform event.
     * @JIRA# LEM-14648
     * @param events
     */
    public void handleSSOBEvents(List<Instant_Ingestor__e> events) {
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID = new Map<String, SSOBOnboardingPayloadParser>();
        try {
            for (Instant_Ingestor__e eachEvent : events) {
                if (String.isBlank(eachEvent.Payload__c)) {
                    continue;
                }

                switch on eventTopicMap.get(eachEvent.Topic__c) {
                    when EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD {
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                            this.recordIdsByPayload
                        );
                        payloadDistributorForAccountsAndXrefsBizRefs(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID
                        );
                    }
                    when EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD {
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                            this.recordIdsByPayload
                        );
                        payloadDistributorForContactsAndACRs(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID
                        );
                    }
                    when EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD {
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                            this.recordIdsByPayload
                        );
                        payloadDistributorForOpportunities(
                            payLoadWrapperByIngestionLogUUID,
                            sourceByUUID
                        );
                    }
                    when EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD {
                        this.recordIdsByPayload = (Set<Id>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<Id>.class
                        );
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                            this.recordIdsByPayload
                        );
                        payloadDistributorForQuotesAndQuoteLines(payLoadWrapperByIngestionLogUUID);
                    }
                    when EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY {
                        methodName = CREATE_AMENDMENT_QUOTES_AND_QUOTELINES;
                        Set<SSOBPortalAmendmentPayloadWrapper> payloads = (Set<SSOBPortalAmendmentPayloadWrapper>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<SSOBPortalAmendmentPayloadWrapper>.class
                        );
                        //The events were published in bulk with chunk size of 1 to process the quote amendments that accepts
                        //a single opportunity and contract id.
                        //As a result, payloads in the set are fetched by the 0th index.
                        SSOBPortalAmendmentPayloadWrapper payloadInstance = new List<SSOBPortalAmendmentPayloadWrapper>(
                            payloads
                        )[0];
                        createAmendmentQuoteAndQuoteLineItems(
                            payloadInstance.opportunityId,
                            payloadInstance.contractId,
                            payloadInstance.inboundIngestionLogId
                        );
                    }
                    when EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE {
                        Set<SSOBPortalAmendmentPayloadWrapper> payloads = (Set<SSOBPortalAmendmentPayloadWrapper>) JSON.deserialize(
                            eachEvent.Payload__c,
                            Set<SSOBPortalAmendmentPayloadWrapper>.class
                        );
                        SSOBPortalAmendmentPayloadWrapper payloadInstance = new List<SSOBPortalAmendmentPayloadWrapper>(
                            payloads
                        )[0];
                        payLoadWrapperByIngestionLogUUID = getParsedPayloadByUniqueInboundIngestionLogs(
                            new Set<Id>{ payloadInstance.inboundIngestionLogId }
                        );
                        payloadDistributorForQuoteLinesCreationFromPayload(
                            payloadInstance.amendmentQuoteId,
                            payLoadWrapperByIngestionLogUUID
                        );
                    }
                }
            }
        } catch (Exception recordsProcessingExceptions) {
            //Logger.publish(recordsProcessingExceptions, LogEntry.SeverityLevel.HIGH);
            if (errorsList.isEmpty()) {
                logUncaughtIngestionExceptionToInboundIngestionRecord(recordsProcessingExceptions);
            } else {
                logSaveResultIngestionExceptionToInboundIngestionRecord(saveResultsDetails);
            }
        }
    }

    /**
     * @description It is used to initiate account, xref and business reference creation.
     * @param payLoadWrapperByIngestionLogUUID
     * @param sourceByUUID
     */
    private void payloadDistributorForAccountsAndXrefsBizRefs(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, String> sourceByUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_ACCOUNTS_AND_XREF_BIZREF;
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            new Map<String, InstantIngestionPayloadParser>(),
            payLoadWrapperByIngestionLogUUID
        );
        this.sourceByUUID = sourceByUUID;
        initiateBusinessAccountsCreation(payLoadWrapperByIngestionLogUUID);
        initiateBrandsCreation(payLoadWrapperByIngestionLogUUID);
        initiateBusinessReferencesCreation(payLoadWrapperByIngestionLogUUID);
        initiateXrefsCreation(payLoadWrapperByIngestionLogUUID);
        publishEventsByEventTopic(
            EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
    }

    /**
     * @description It is used to initiate Contact and ACR creation.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @param sourceByUUID
     */
    private void payloadDistributorForContactsAndACRs(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR,
        Map<String, String> sourceByUUID
    ) {
        this.sourceByUUID = sourceByUUID;
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_CONTACT_AND_ACR;
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            new Map<String, InstantIngestionPayloadParser>(),
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        initiateContactCreation(payLoadWrapperByIngestionLogUUIDForContactAndACR);
        catchExceptionsOnGovernerLimits();
        publishEventsByEventTopic(
            EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
    }

    /**
     * @description It is used to initiate the creation of Opportunities by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     * @param sourceByUUID
     */
    private void payloadDistributorForOpportunities(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
        Map<String, String> sourceByUUID
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_OPPORTUNITIES;

        this.sourceByUUID = sourceByUUID;
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            new Map<String, InstantIngestionPayloadParser>(),
            payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
        );
        existingContractByBusinessAccountId = InstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        this.existingOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        this.existingAmendOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        if (!existingContractByBusinessAccountId.isEmpty()) {
            ssobType = typeExisting;
        }
        initiateOpportunityCreation(payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR);
        catchExceptionsOnGovernerLimits();
        publishEventsByEventTopic(
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
    }

    /**
     * @description It is used to initiate the creation of Quote and Quote Lines by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void payloadDistributorForQuotesAndQuoteLines(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        this.methodName = PAYLOAD_DISTRIBUTOR_FOR_QUOTES_AND_QUOTELINES;
        Set<Id> quoteIdsToUpdate = new Set<Id>();
        this.existingAccountByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessAccounts(
            new Map<String, InstantIngestionPayloadParser>(),
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        existingContractByBusinessAccountId = InstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        this.existingOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        this.existingAmendOpportunityByAccountId = InstantIngestionCheckRecordsService.fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );

        if (!existingContractByBusinessAccountId.isEmpty()) {
            initiateSSOBAmendment(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
        } else {
            initiateQuoteCreation(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
            initiateQuoteLineGroupCreation(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
            initiateDiscountTiersCreation(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
            initiateQuoteLineCreation(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
            initiateQuoteLineOptionsCreation(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines);
            catchExceptionsOnGovernerLimits();
            Map<String, SBQQ__Quote__c> quotesByUUID = InstantIngestionRecordsGetterService.getQuotesByUUID(
                null,
                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
            );
            for (SBQQ__Quote__c eachQuote : quotesByUUID.values()) {
                quoteIdsToUpdate.add(eachQuote.Id);
            }
            InstantIngestorEventsService.publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS => JSON.serialize(
                        getExistingPrimaryQuoteIds()
                    )
                }
            );

            if (quoteIdsToUpdate.isEmpty()) {
                return;
            }
            InstantIngestorEventsService.publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => JSON.serialize(quoteIdsToUpdate)
                }
            );
        }
    }

    /**
     * @description It is used to create business accounts.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void initiateBusinessAccountsCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createBusinessAccountSSOB(
                    inboundIngestionLogs[0].Payload__c,
                    eachInstantIngestionPayload
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create brands.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void initiateBrandsCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionAccountService.createBrand(
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUID
                    )
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create business references.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void initiateBusinessReferencesCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            if (isExistingAccountFound(eachInstantIngestionPayload)) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionXrefBizRefService.createBusinessReference(
                    new InstantIngestionPayloadParser(),
                    eachInstantIngestionPayload,
                    getExistingBrandForAssociation(
                            eachInstantIngestionPayload,
                            payLoadWrapperByIngestionLogUUID
                        )
                        .Id,
                    getExistingAccountForAssociation(
                            eachInstantIngestionPayload,
                            payLoadWrapperByIngestionLogUUID
                        )
                        .CurrencyIsoCode,
                    this.businessVerticalRx,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create xrefs.
     * @param payLoadWrapperByIngestionLogUUID
     */
    private void initiateXrefsCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Business_Reference__c existingBusinessReference = new Business_Reference__c();
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, Business_Reference__c> bizRefByBusinessId = InstantIngestionCheckRecordsService.getExistingBusinessReferences(
            this.existingAccountByBusinessId.keySet()
        );
        Map<String, Business_Reference__c> businessReferenceByUUID = InstantIngestionRecordsGetterService.getBizRefByUUID(
            null,
            payLoadWrapperByIngestionLogUUID
        );
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            existingBusinessReference = this.existingAccountByBusinessId.get(
                    eachInstantIngestionPayload.account.businessId
                ) == null
                ? businessReferenceByUUID.get(eachInstantIngestionPayload.Uuid)
                : bizRefByBusinessId.get(eachInstantIngestionPayload.account.businessId);
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionXrefBizRefService.createXref(
                    new InstantIngestionPayloadParser(),
                    eachInstantIngestionPayload,
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUID
                    ),
                    null,
                    existingBusinessReference,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to create contacts.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    private void initiateContactCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForContactAndACR.values()
        ) {
            if (!((eachInstantIngestionPayload.opportunity.MatchedRecords.contact).isEmpty())) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionContactACRService.createContactForSSOB(
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUIDForContactAndACR
                    ),
                    inboundIngestionLogs[0].Payload__c,
                    eachInstantIngestionPayload
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the opportunity creations.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     */
    private void initiateOpportunityCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, Contact> contactsByBusinessAccountId = InstantIngestionCheckRecordsService.getExistingContactsByBusinessAccount(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(
                    eachInstantIngestionPayload.account.businessId
                ) != new Opportunity() ||
                isAmendOpportunityWithPrimaryQuoteExist(
                    eachInstantIngestionPayload.account.businessId
                ) != new Opportunity()
            ) {
                uow.registerDirty(
                    new Opportunity(
                        Id = isOpportunityWithPrimaryQuoteExist(
                                eachInstantIngestionPayload.account.businessId
                            ) != new Opportunity()
                            ? isOpportunityWithPrimaryQuoteExist(
                                      eachInstantIngestionPayload.account.businessId
                                  )
                                  .Id
                            : isAmendOpportunityWithPrimaryQuoteExist(
                                      eachInstantIngestionPayload.account.businessId
                                  )
                                  .Id,
                        Source__c = SOURCE_SSOB,
                        Unique_Identifier__c = eachInstantIngestionPayload.uuid
                    )
                );
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionOpportunityService.createOpportunity(
                    null,
                    eachInstantIngestionPayload,
                    getExistingAccountForAssociation(
                        eachInstantIngestionPayload,
                        payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
                    ),
                    contactsByBusinessAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
                            )
                            .Id
                    ),
                    ssobType + this.sourceByUUID.get(eachInstantIngestionPayload.Uuid),
                    inboundIngestionLogByUUID.get(eachInstantIngestionPayload.Uuid).Id
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void initiateQuoteCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.account.businessId)
                    ?.SBQQ__PrimaryQuote__c != null ||
                isAmendOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.account.businessId
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createSSOBQuotes(
                    eachInstantIngestionPayload,
                    this.existingOpportunityByAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    pricebook.Id,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void initiateQuoteLineGroupCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        this.quotesByOpportunityId = InstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
            new Map<Id, Opportunity>(this.existingOpportunityByAccountId.values()).keySet()
        );
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.account.businessId)
                    ?.SBQQ__PrimaryQuote__c != null ||
                isAmendOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.account.businessId
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineGroup(
                    this.existingOpportunityByAccountId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    )
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote lines creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void initiateQuoteLineCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        Map<Id, SBQQ__QuoteLineGroup__c> quotesLineGroupsByQuoteId = new Map<Id, SBQQ__QuoteLineGroup__c>();
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        this.quotesByOpportunityId = InstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
            new Map<Id, Opportunity>(this.existingOpportunityByAccountId.values()).keySet()
        );
        quotesLineGroupsByQuoteId = InstantIngestionCheckRecordsService.getQuoteLineGroupsByAccountIds(
            new Map<Id, SBQQ__Quote__c>(this.quotesByOpportunityId.values()).keySet()
        );
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                (isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.account.businessId))
                    .SBQQ__PrimaryQuote__c != null ||
                isAmendOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.account.businessId
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForSSOBPayload(
                    eachInstantIngestionPayload,
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    pricebook,
                    quotesLineGroupsByQuoteId.get(
                            getExistingAccountForAssociation(
                                    eachInstantIngestionPayload,
                                    payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                                )
                                .Id
                        )
                        .Id,
                    this.sourceByUUID.get(eachInstantIngestionPayload.Uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote lines creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void initiateDiscountTiersCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                (isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.account.businessId))
                    ?.SBQQ__PrimaryQuote__c != null ||
                isAmendOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.account.businessId
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createDiscountTiers(eachInstantIngestionPayload)
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description It is used to initiate the quote line options creations.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    private void initiateQuoteLineOptionsCreation(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, SBQQ__QuoteLine__c> quoteLinesWithProductNameByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByUUID(
            null,
            payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
        );
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID = new Map<String, List<SBQQ__DiscountTier__c>>();
        for (
            SBQQ__DiscountTier__c eachDiscountTier : DiscountTiersSelector.newInstance()
                .selectByUUID(payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.keySet())
        ) {
            if (!discountTiersByUUID.containsKey(eachDiscountTier.Unique_Identifier__c)) {
                discountTiersByUUID.put(
                    eachDiscountTier.Unique_Identifier__c,
                    new List<SBQQ__DiscountTier__c>{ eachDiscountTier }
                );
            }
            discountTiersByUUID.get(eachDiscountTier.Unique_Identifier__c).add(eachDiscountTier);
        }

        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        for (
            SSOBOnboardingPayloadParser eachInstantIngestionPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                (isOpportunityWithPrimaryQuoteExist(eachInstantIngestionPayload.account.businessId))
                    ?.SBQQ__PrimaryQuote__c != null ||
                isAmendOpportunityWithPrimaryQuoteExist(
                        eachInstantIngestionPayload.account.businessId
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                continue;
            }
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForSsobPayload(
                    eachInstantIngestionPayload,
                    quoteLinesWithProductNameByUUID,
                    discountTiersByUUID,
                    this.quotesByOpportunityId.get(
                        getExistingAccountForAssociation(
                                eachInstantIngestionPayload,
                                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
                            )
                            .Id
                    ),
                    pricebook
                )
            );
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
        List<Database.SaveResult> saveResultData = new List<Database.SaveResult>();
        List<String> errorMessages = new List<String>();
        SBQQ.TriggerControl.disable();
        uow.registerWork(insertUnitOfWorkHelper);
        uow.commitWork();
        SBQQ.TriggerControl.enable();
        saveResultData = insertUnitOfWorkHelper.saveResults != null
            ? insertUnitOfWorkHelper.saveResults
            : new List<Database.SaveResult>();
        for (Database.SaveResult eachSaveResultsDetail : saveResultData) {
            for (Database.Error eachSaveResultError : eachSaveResultsDetail.getErrors()) {
                errorMessages.add(
                    eachSaveResultError.getStatusCode() +
                        ': ' +
                        eachSaveResultError.getMessage() +
                        ': ' +
                        eachSaveResultError.getFields()
                );
            }
        }
        if (!errorMessages.isEmpty()) {
            saveResultsDetails.addAll(saveResultData);
            errorsList.addAll(errorMessages);
            throw new DmlException('Errors occured during commitwork');
        }
    }
    /**
     * @description It is used to catch Governor Limit Exceptions when the payload inserted for the Onboarding Event.
     */
    private void catchExceptionsOnGovernerLimits() {
        String govLimitsException = InboundIngestionLoggerService.errorOnGovtLimitsExceeded();
        if (String.isNotBlank(govLimitsException)) {
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                SELF_SERVING_ONBOARDING_SERVICE,
                CPQ_WS,
                inboundIngestionLogs[0].Id,
                inboundIngestionLogs[0].UUID__c,
                ''
            );
            InboundIngestionLoggerService.logGovLimitsException(
                loggerEntry,
                govLimitsException,
                this.methodName != '' ? payloadMethodsToStepMap.get(this.methodName) : '',
                CLASS_NAME,
                this.methodName != '' ? this.methodName : ''
            );
        }
    }

    /**
     * @description It is used to update the save result exception on Inbound Ingestion log record.
     * @param savedIngestionResults
     */
    private void logSaveResultIngestionExceptionToInboundIngestionRecord(
        List<Database.SaveResult> savedIngestionResults
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        String traceString = '';
        String exceptionMessage = '';
        for (Integer i = 0; i < savedIngestionResults.size(); i++) {
            if (savedIngestionResults[i].isSuccess()) {
                continue;
            }
            for (Database.Error err : savedIngestionResults[i].getErrors()) {
                traceString = new DmlException().getStackTraceString().substringAfter('\n');
                exceptionMessage += err.getMessage();
            }
            Inbound_ingestion_Log__c ingestionRecord = new Inbound_ingestion_Log__c(
                Id = inboundIngestionLogs[i].Id,
                Status__c = STATUS_FAILED,
                Business_Error_Message__c = BUSINESS_ERROR_MESSAGE,
                Failure_Step__c = this.methodName == ''
                    ? 1
                    : Decimal.valueof(payloadMethodsToStepMap.get(this.methodName)),
                Stack_Trace__c = traceString,
                Exception_Message__c = exceptionMessage
            );
            uowUpdateHelper.registerUpdate(ingestionRecord);
        }
        uow.commitWork();

        logIngestionExceptionToScaler(null);
    }

    /**
     * @description It is used to update the uncaught exception on Inbound Ingestion log record.
     * @param recordsProcessingExceptions
     */
    private void logUncaughtIngestionExceptionToInboundIngestionRecord(
        Exception recordsProcessingExceptions
    ) {
        fflib_ISObjectUnitOfWork uowForFailureIngestionUpdate = Application.UNITOFWORK.newInstance();
        uowForFailureIngestionUpdate.registerDirty(
            new Inbound_ingestion_Log__c(
                Id = inboundIngestionLogs[0].Id,
                Status__c = STATUS_FAILED,
                Business_Error_Message__c = BUSINESS_ERROR_MESSAGE,
                Failure_Step__c = this.methodName == ''
                    ? 1
                    : Decimal.valueof(payloadMethodsToStepMap.get(this.methodName)),
                Stack_Trace__c = recordsProcessingExceptions.getStackTraceString(),
                Exception_Message__c = recordsProcessingExceptions.getMessage()
            )
        );
        uowForFailureIngestionUpdate.commitWork();
        logIngestionExceptionToScaler(recordsProcessingExceptions);
    }

    /**
     * @description It is used to log the ingestion exceptions to scaler
     * @param recordsProcessingExceptions
     */
    private void logIngestionExceptionToScaler(Exception recordsProcessingExceptions) {
        IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
            SELF_SERVING_ONBOARDING_SERVICE,
            CPQ_WS,
            inboundIngestionLogs[0].Id,
            inboundIngestionLogs[0].UUID__c,
            ''
        );
        InboundIngestionLoggerService.logException(
            loggerEntry,
            recordsProcessingExceptions != null
                ? recordsProcessingExceptions
                : new dmlexception(COMMITWORK_MESSAGE),
            BUSINESS_ERROR_MESSAGE,
            this.methodName != '' ? payloadMethodsToStepMap.get(this.methodName) : '',
            new Set<String>{ inboundIngestionLogs[0].Id },
            recordsProcessingExceptions != null ? recordsProcessingExceptions.getTypeName() : ''
        );
    }
    /**
     * @description It is used to check whether an existing Opportunity with a Primary Quote existing or not.
     * @param businessIdFromPayload
     * @return Opportunity
     */
    private Opportunity isOpportunityWithPrimaryQuoteExist(String businessIdFromPayload) {
        Opportunity existingOpportunity = new Opportunity();
        if (!this.existingOpportunityByAccountId.isEmpty()) {
            existingOpportunity = this.existingOpportunityByAccountId.get(
                this.existingAccountByBusinessId.get(businessIdFromPayload).Id
            );
        }
        return existingOpportunity;
    }

    /**
     * @description It is used to check whether an existing Amend Opportunity with a Primary Quote existing or not.
     * @param businessIdFromPayload
     * @return Opportunity
     */
    private Opportunity isAmendOpportunityWithPrimaryQuoteExist(String businessIdFromPayload) {
        Opportunity existingAmendOpportunity = new Opportunity();
        if (!this.existingAmendOpportunityByAccountId.isEmpty()) {
            existingAmendOpportunity = this.existingAmendOpportunityByAccountId.get(
                this.existingAccountByBusinessId.get(businessIdFromPayload).Id
            );
            ssobType = typeExisting;
        }
        return existingAmendOpportunity;
    }

    /**
     * @description It is used to check whether an existing account found or not.
     * @param eachInstantIngestionPayload
     * @return Boolean
     */
    private Boolean isExistingAccountFound(
        SSOBOnboardingPayloadParser eachInstantIngestionPayload
    ) {
        return (!this.existingAccountByBusinessId.isEmpty() &&
        this.existingAccountByBusinessId.containsKey(
            eachInstantIngestionPayload.account.businessId
        ));
    }

    /**
     * @description It is used to publish the instant ingestor events by the received event topic.
     * @param eventTopic
     */
    private void publishEventsByEventTopic(String eventTopic) {
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{ eventTopic => JSON.serialize(this.recordIdsByPayload) }
        );
    }

    /**
     * @description It is used to get the existing account Ids.
     * @return Set<Id>
     */
    private Set<Id> getExistingAccountIds() {
        Set<Id> existingAccountIds = new Set<Id>();
        for (Account eachExistingAccount : this.existingAccountByBusinessId.values()) {
            existingAccountIds.add(eachExistingAccount.Id);
        }
        return existingAccountIds;
    }

    /**
     * @description It is used to get the existing primary quote ids.
     * @return Set<Id>
     */
    private Set<Id> getExistingPrimaryQuoteIds() {
        Set<Id> existingPrimaryQuoteIds = new Set<Id>();
        List<Opportunity> newOrExistingOpportunities = new List<Opportunity>();
        if (!this.existingOpportunityByAccountId.isEmpty()) {
            newOrExistingOpportunities.addAll(this.existingOpportunityByAccountId.values());
        } else if (!this.existingAmendOpportunityByAccountId.isEmpty()) {
            newOrExistingOpportunities.addAll(this.existingAmendOpportunityByAccountId.values());
        }
        for (Opportunity eachExistingOpportunity : newOrExistingOpportunities) {
            existingPrimaryQuoteIds.add(eachExistingOpportunity.SBQQ__PrimaryQuote__c);
        }
        return existingPrimaryQuoteIds;
    }

    /**
     * @description It is used to get the existing accounts by business id or unique identifiers.
     * @param eachInstantIngestionPayload
     * @param payLoadWrapperByIngestionLogUUID
     * @return Account
     */
    private Account getExistingAccountForAssociation(
        SSOBOnboardingPayloadParser eachInstantIngestionPayload,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, Account> businessAccountByUUID = InstantIngestionRecordsGetterService.getBusinessAccountByUUID(
            null,
            payLoadWrapperByIngestionLogUUID
        );
        Account existingAccount = this.existingAccountByBusinessId.get(
                eachInstantIngestionPayload.account.businessId
            ) == null
            ? businessAccountByUUID.get(eachInstantIngestionPayload.Uuid)
            : this.existingAccountByBusinessId.get(eachInstantIngestionPayload.account.businessId);
        return existingAccount;
    }

    /**
     * @description It is used to get the existing brands by business id or unique identifiers.
     * @param eachInstantIngestionPayload
     * @param payLoadWrapperByIngestionLogUUID
     * @return Account
     */
    private Brand__c getExistingBrandForAssociation(
        SSOBOnboardingPayloadParser eachInstantIngestionPayload,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<Id, Brand__c> existingBrandByAccountId = InstantIngestionCheckRecordsService.getExistingBrands(
            new Map<Id, Account>(this.existingAccountByBusinessId.values()).keySet()
        );
        Map<String, Brand__c> brandsByUUID = InstantIngestionRecordsGetterService.getBrandByUUID(
            null,
            payLoadWrapperByIngestionLogUUID
        );
        Brand__c existingBrand = this.existingAccountByBusinessId.get(
                eachInstantIngestionPayload.account.businessId
            ) == null
            ? brandsByUUID.get(eachInstantIngestionPayload.Uuid)
            : existingBrandByAccountId.get(
                  getExistingAccountForAssociation(
                          eachInstantIngestionPayload,
                          payLoadWrapperByIngestionLogUUID
                      )
                      .Id
              );
        return existingBrand;
    }
    /**
     * @description It is used to get the parsed payload by the passed inbound ingestion log ids.
     * @param inboundIngestionLogIds
     * @return Map<String, SSOBOnboardingPayloadParser>
     */
    private Map<String, SSOBOnboardingPayloadParser> getParsedPayloadByUniqueInboundIngestionLogs(
        Set<Id> inboundIngestionLogIds
    ) {
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBIngestionLogUUID = new Map<String, SSOBOnboardingPayloadParser>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(inboundIngestionLogIds)
        ) {
            payLoadWrapperBySSOBIngestionLogUUID.put(
                eachInboundIngestionLog.UUID__c,
                (SSOBOnboardingPayloadParser) System.JSON.deserialize(
                    eachInboundIngestionLog.Payload__c,
                    SSOBOnboardingPayloadParser.class
                )
            );
            this.sourceByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Source__c
            );
            inboundIngestionLogByUUID.put(eachInboundIngestionLog.UUID__c, eachInboundIngestionLog);
            inboundIngestionLogs.add(eachInboundIngestionLog);
        }
        return payLoadWrapperBySSOBIngestionLogUUID;
    }

    private void initiateSSOBAmendment(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        //publish bulk events for contract amendment and pass opportunity by uuid and contract id
        //wrapper will be passed
        //event topic EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Object> payLoads = new Set<Object>();
        Set<Id> existingPrimaryQuoteIds = new Set<Id>();
        SSOBPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new SSOBPortalAmendmentPayloadWrapper();
        for (
            SSOBOnboardingPayloadParser eachParsedSSOBPortalPayload : payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines.values()
        ) {
            if (
                this.existingAmendOpportunityByAccountId.get(
                        this.existingAccountByBusinessId.get(
                                eachParsedSSOBPortalPayload.account.businessId
                            )
                            .Id
                    )
                    ?.SBQQ__PrimaryQuote__c != null
            ) {
                existingPrimaryQuoteIds.add(
                    this.existingAmendOpportunityByAccountId.get(
                            this.existingAccountByBusinessId.get(
                                    eachParsedSSOBPortalPayload.account.businessId
                                )
                                .Id
                        )
                        ?.SBQQ__PrimaryQuote__c
                );
                continue;
            }
            amendmentPayloadWrapper.opportunityId = this.existingAccountByBusinessId.containsKey(
                    eachParsedSSOBPortalPayload.account.businessId
                )
                ? existingAmendOpportunityByAccountId.get(
                          this.existingAccountByBusinessId.get(
                                  eachParsedSSOBPortalPayload.account.businessId
                              )
                              .Id
                      )
                      .Id
                : null;
            //
            amendmentPayloadWrapper.contractId = existingContractByBusinessAccountId.get(
                    this.existingAmendOpportunityByAccountId.get(
                            this.existingAccountByBusinessId.get(
                                    eachParsedSSOBPortalPayload.account.businessId
                                )
                                .Id
                        )
                        .AccountId
                )
                .Id;
            amendmentPayloadWrapper.inboundIngestionLogId = inboundIngestionLogByUUID.get(
                    eachParsedSSOBPortalPayload.uuid
                )
                .Id;
            payLoads.add(amendmentPayloadWrapper);
            uow.registerDirty(
                new Inbound_Ingestion_Log__c(
                    Id = inboundIngestionLogByUUID.get(eachParsedSSOBPortalPayload.uuid).Id,
                    Internal_Payload_For_Retry__c = JSON.serialize(amendmentPayloadWrapper)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);

        if (!existingPrimaryQuoteIds.isEmpty()) {
            InstantIngestorEventsService.publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS => JSON.serialize(
                        existingPrimaryQuoteIds
                    )
                }
            );
        }
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                    payLoads,
                    1
                )
            }
        );
    }

    private void createAmendmentQuoteAndQuoteLineItems(
        Id opportunityId,
        Id contractId,
        Id inboundIngestionLogId
    ) {
        inboundIngestionLogs.add(new Inbound_Ingestion_Log__c(Id = inboundIngestionLogId));
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Object> amendmentQuoteIdWithIngestionLogId = new Set<Object>();
        SBQQ.TriggerControl.disable();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(
            String.valueOf(opportunityId),
            String.valueOf(contractId)
        );
        SBQQ.TriggerControl.enable();
        Map<String, Object> amendmentResponse = (Map<String, Object>) JSON.deserializeUntyped(
            response
        );
        //String quoteId = (String) amendmentResponse.get('quoteId');
        SSOBPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new SSOBPortalAmendmentPayloadWrapper();

        if ((Boolean) amendmentResponse.get('isSuccessful')) {
            //fire event to append quote lines on amended quote.
            amendmentPayloadWrapper.amendmentQuoteId = Id.valueOf(
                (String) amendmentResponse.get('quoteId')
            );
            amendmentPayloadWrapper.inboundIngestionLogId = inboundIngestionLogId;
            amendmentQuoteIdWithIngestionLogId.add(amendmentPayloadWrapper);
        } else {
            throw new DmlException(
                CUSTOM_AMENDMENT_FAILED + (String) amendmentResponse.get('message')
            );
        }
        uow.registerDirty(
            new Inbound_Ingestion_Log__c(
                Id = inboundIngestionLogId,
                Internal_Payload_For_Retry__c = JSON.serialize(amendmentPayloadWrapper)
            )
        );

        commitUnitOfWork(uow, insertUnitOfWorkHelper);
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE => JSON.serialize(
                    amendmentQuoteIdWithIngestionLogId
                )
            }
        );
    }

    private void payloadDistributorForQuoteLinesCreationFromPayload(
        Id quoteId,
        Map<String, SSOBOnboardingPayloadParser> ssobPortalPayloadWrapperByUUID
    ) {
        this.amendmentQuote = QuotesSelector.newInstance().selectById(new Set<Id>{ quoteId });
        addDriveQuoteLineItemsOnAmendmentQuote(quoteId, ssobPortalPayloadWrapperByUUID);
        addOptionDriveQuoteLineItemsOnAmendmentQuote(quoteId, ssobPortalPayloadWrapperByUUID);
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => JSON.serialize(new Set<Id>{ quoteId })
            }
        );
    }

    private void addDriveQuoteLineItemsOnAmendmentQuote(
        Id quoteId,
        Map<String, SSOBOnboardingPayloadParser> ssobPortalPayloadWrapperByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroup = QuoteLineGroupSelector.newInstance()
            .selectQuoteLineGroupsByQuoteIds(new Set<Id>{ quoteId });

        for (
            SSOBOnboardingPayloadParser eachSSOBPortalParsedPayload : ssobPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForSSOBPayload(
                    eachSSOBPortalParsedPayload,
                    this.amendmentQuote[0],
                    pricebook,
                    quoteLineGroup[0].Id,
                    sourceByUUID.get(eachSSOBPortalParsedPayload.uuid)
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    private void addOptionDriveQuoteLineItemsOnAmendmentQuote(
        Id quoteId,
        Map<String, SSOBOnboardingPayloadParser> ssobPortalPayloadWrapperByUUID
    ) {
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        PriceBook2 pricebook = PricebookSelector.newInstance().selectStandardPricebook();
        Map<String, SBQQ__QuoteLine__c> quoteLinesWithProductNameByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByUUID(
            null,
            ssobPortalPayloadWrapperByUUID
        );
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID = new Map<String, List<SBQQ__DiscountTier__c>>();
        for (
            SBQQ__DiscountTier__c eachDiscountTier : DiscountTiersSelector.newInstance()
                .selectByUUID(ssobPortalPayloadWrapperByUUID.keySet())
        ) {
            if (!discountTiersByUUID.containsKey(eachDiscountTier.Unique_Identifier__c)) {
                discountTiersByUUID.put(
                    eachDiscountTier.Unique_Identifier__c,
                    new List<SBQQ__DiscountTier__c>{ eachDiscountTier }
                );
            }
            discountTiersByUUID.get(eachDiscountTier.Unique_Identifier__c).add(eachDiscountTier);
        }
        for (
            SSOBOnboardingPayloadParser eachSsobPortalParsedPayload : ssobPortalPayloadWrapperByUUID.values()
        ) {
            insertUnitOfWorkHelper.registerInsert(
                InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForSsobPayload(
                    eachSsobPortalParsedPayload,
                    quoteLinesWithProductNameByUUID,
                    discountTiersByUUID,
                    this.amendmentQuote[0],
                    pricebook
                )
            );
        }
        commitUnitOfWork(uow, insertUnitOfWorkHelper);
    }

    /**
     * @description Payload wrapper for capturing the details and to publish in the events.
     */
    public class SSOBPortalAmendmentPayloadWrapper {
        public Id opportunityId;
        public Id contractId;
        public Id amendmentQuoteId;
        public Id inboundIngestionLogId;
        /**
         * @description Payload wrapper constructor
         */
        public SSOBPortalAmendmentPayloadWrapper() {
            this.opportunityId = opportunityId;
            this.contractId = contractId;
            this.amendmentQuoteId = amendmentQuoteId;
            this.inboundIngestionLogId = inboundIngestionLogId;
        }
    }
}