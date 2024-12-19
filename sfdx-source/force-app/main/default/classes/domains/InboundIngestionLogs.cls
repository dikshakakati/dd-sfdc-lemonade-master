/**
 * @description Domain Class for Inbound Ingestion Logs.
 * @author Deloitte
 * @date 05/11/2024
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public inherited sharing class InboundIngestionLogs extends SObjects implements IInboundIngestionLogs {
    private static final String MX_PORTAL_NSE_EVENT = 'Mx Portal New Store Expansion';
    private static final String MX_PORTAL_ADD_STOREFRONT_EVENT = 'Mx Portal Add Storefront';
    private static final String MX_PORTAL_PACKAGE_SWITCH_EVENT = 'Mx Portal Package Switch';
    private static final String MX_PORTAL_ADD_ADS_PROMOS = 'Mx Portal Ads And Promos';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String SSOB_ONBOARDING_EVENT = 'SSOB Onboarding Event';
    private static final String FALLOUT_EVENT = 'Fallout event';
    private static final String INGESTION_LOG_FAILED_BUSINESS_ERROR_MESSAGE = 'Fallout Inbound Ingestion Log records update failed';
    private static final String LOG_SALES_DOMAIN = 'Sales';
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String LOG_CREATE_CHILD_INBOUND_INGESTION = 'Error in creating child Inbound Ingestion Log';
    private static final String LOG_UPDATE_PARENT_INBOUND_INGESTION = 'Error in updating Parent Inbound Ingestion';
    private static final String LOG_UPDATE_STATUS_ON_INBOUND_INGESTION = 'Update status on Inbound Ingestion Log records failed';
    private static final String STATUS_SKIPPED = 'Skipped';
    private static final String COMPLETED = 'Completed';
    private static final String PENDING = 'Pending';
    private static final String SUCCESS_MESSAGE = 'Fallout event has been completed successfully';
    private static final String SUCCESS = 'Success';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String REJECTED = 'Rejected';
    private static final String FAILED = 'Failed';
    private static final String DUPLICATE = 'Duplicate';

    private static final List<String> INTEGRATION_TYPES = new List<String>{
        FALLOUT_EVENT,
        ONBOARDING_EVENT,
        SSOB_ONBOARDING_EVENT,
        MX_PORTAL_ADD_ADS_PROMOS,
        MX_PORTAL_NSE_EVENT,
        MX_PORTAL_ADD_STOREFRONT_EVENT,
        MX_PORTAL_PACKAGE_SWITCH_EVENT
    };
    private static final String EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY = 'EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY';
    private static final String EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE';
    private static final Set<String> AMENDMENT_EVENT_TOPICS = new Set<String>{
        EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY,
        EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE
    };
    private Map<String, Set<Object>> failedInboundIngestionAmendmentRetryPayloadByEventTopic = new Map<String, Set<Object>>();

    /**
     * @description This method is used to return the IInboundIngestionLogs interface.
     * @param recordList
     * @return IInboundIngestionLogs
     */
    public static IInboundIngestionLogs newInstance(List<Inbound_Ingestion_Log__c> recordList) {
        return (IInboundIngestionLogs) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class InboundIngestionLogs.
     * @param sObjects
     */
    public InboundIngestionLogs(List<Inbound_Ingestion_Log__c> sObjects) {
        super(sObjects, Schema.Inbound_Ingestion_Log__c.SObjectType);
    }

    /**
     * @description To create instance of InboundIngestionLogs domain class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objects
         * @return InboundIngestionLogs
         */
        public SObjects construct(List<Object> objects) {
            if (InboundIngestionLogs.constructorMock != null) {
                return (SObjects) InboundIngestionLogs.constructorMock.construct(objects);
            }
            return new InboundIngestionLogs((List<SObject>) objects);
        }
    }
    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description It is used to initiate the SSMO records creation in Salesforce by publishing platform events.
     * @JIRA# LEM-14648
     * @param eventName
     */
    public void initiateSSMOOnboardingRecordsCreation(String eventName) {
        Map<Id, Inbound_Ingestion_Log__c> onboardingEventIdToInboundIngestionLogs = new Map<Id, Inbound_Ingestion_Log__c>(
            new List<Inbound_Ingestion_Log__c>(
                (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
                    Inbound_Ingestion_Log__c.Integration_Type__c,
                    ONBOARDING_EVENT
                )
            )
        );
        if (onboardingEventIdToInboundIngestionLogs.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Inbound_Ingestion_Log__c>(onboardingEventIdToInboundIngestionLogs)
                        .keySet(),
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            },
            PreSalesTransaction__e.SObjectType
        );
    }

    /**
     * @description It is used to initiate the SSOB records creation in Salesforce by publishing platform events.
     * @JIRA# LEM-14648
     * @param eventName
     */
    public void initiateSSOBOnboardingRecordsCreation(String eventName) {
        List<Inbound_Ingestion_Log__c> ssobOnboardingEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                SSOB_ONBOARDING_EVENT
            )
        );
        if (ssobOnboardingEventInboundIngestionLogs.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Inbound_Ingestion_Log__c>(ssobOnboardingEventInboundIngestionLogs)
                        .keySet(),
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            },
            PostSalesTransaction__e.SObjectType
        );
    }

    /**
     * @description RESSMO Onboarding Instant Ingestor Initiation
     * @author VenkateshDD | 07-23-2024
     * @param eventName
     **/
    public void initiateRESSMOOnboardingRecordsCreation(String eventName) {
        Map<Id, Inbound_Ingestion_Log__c> onboardingEventIdToInboundIngestionLogs = new Map<Id, Inbound_Ingestion_Log__c>(
            new List<Inbound_Ingestion_Log__c>(
                (List<Inbound_Ingestion_Log__c>) getRecordsByMultipleFieldValue(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Source__c => SOURCE_RESSMO,
                        Inbound_Ingestion_Log__c.Status__c => PENDING
                    }
                )
            )
        );
        if (onboardingEventIdToInboundIngestionLogs.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                eventName => JSON.serialize(onboardingEventIdToInboundIngestionLogs.keySet())
            },
            PreSalesTransaction__e.SObjectType
        );
    }

    /**
     * @description It is used to initiate the Mx Portal records creation in
     * Salesforce by publishing platform events for new store expansion.
     * @JIRA #16260
     * @param eventName
     */
    public void initiateMxPortalNSERecordsCreation(String eventName) {
        List<Inbound_Ingestion_Log__c> mxPortalAmendmentEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                MX_PORTAL_NSE_EVENT
            )
        );
        if (mxPortalAmendmentEventInboundIngestionLogs.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Inbound_Ingestion_Log__c>(
                            mxPortalAmendmentEventInboundIngestionLogs
                        )
                        .keySet(),
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            },
            PostSalesTransaction__e.SObjectType
        );
    }

    /**
     * @description It is used to initiate the Mx Portal amendment records creation in
     * Salesforce by publishing platform events for storefront addition, package switch and A&Ps.
     * @JIRA #16260
     * @param eventName
     */
    public void initiateMxPortalAmendments(String eventName) {
        List<Inbound_Ingestion_Log__c> mxPortalAmendmentEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValues(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                new Set<Object>{ MX_PORTAL_ADD_STOREFRONT_EVENT, MX_PORTAL_PACKAGE_SWITCH_EVENT }
            )
        );
        if (mxPortalAmendmentEventInboundIngestionLogs.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.eventType = InstantIngestorEventsService.PlatformEventType.POSTSALES;
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Inbound_Ingestion_Log__c>(
                            mxPortalAmendmentEventInboundIngestionLogs
                        )
                        .keySet(),
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            },
            PostSalesTransaction__e.SObjectType
        );
    }

    /**
     * @description It is used to initiate the Mx Portal amendment records creation in
     * Salesforce by publishing platform events for ads and promos.
     * @param eventName
     */
    public void initiateAdsPromosAmendment(String eventName) {
        List<Inbound_Ingestion_Log__c> mxPortalAmendmentEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValues(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                new Set<Object>{ MX_PORTAL_ADD_ADS_PROMOS }
            )
        );
        if (mxPortalAmendmentEventInboundIngestionLogs.isEmpty()) {
            return;
        }
        // Set the event type to be used
        InstantIngestorEventsService.eventType = InstantIngestorEventsService.PlatformEventType.ADS_PROMOS;
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Map<Id, Inbound_Ingestion_Log__c>(
                            mxPortalAmendmentEventInboundIngestionLogs
                        )
                        .keySet(),
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            },
            Instant_Ingestor__e.SObjectType
        );
    }

    /**
     * @description It is used to create opportunity team members for new opportunities
     * and Opportunities when owner is changed.
     * @JIRA# LEM-14590
     * @param eventName
     */
    public void initiateSSMOFalloutRecordsCreation(String eventName) {
        List<Inbound_Ingestion_Log__c> falloutEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>();
        Map<Id, Inbound_Ingestion_Log__c> falloutEventToInboundIngestionLog = new Map<Id, Inbound_Ingestion_Log__c>();
        falloutEventInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                FALLOUT_EVENT
            )
        );
        falloutEventToInboundIngestionLog = new Map<Id, Inbound_Ingestion_Log__c>(
            falloutEventInboundIngestionLogs
        );
        for (Inbound_Ingestion_Log__c eachInboundIngestionLog : falloutEventInboundIngestionLogs) {
            if (
                eachInboundIngestionLog.Status__c == STATUS_SKIPPED ||
                eachInboundIngestionLog.Parent_Log__c == null
            ) {
                falloutEventToInboundIngestionLog.remove(eachInboundIngestionLog.Id);
            }
        }
        if (falloutEventInboundIngestionLogs.isEmpty()) {
            return;
        }
        NonInstantIngestionEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventName => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    falloutEventToInboundIngestionLog.keySet(),
                    1
                )
            }
        );
    }

    /**
     * @description It checks for existing inbound ingestion record
     * with the same uuid and relate it with the inserted record.
     * @JIRA# LEM-14590
     */
    public void onBeforeInsertHandleFalloutIngestionLogs() {
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs = new Map<String, List<Inbound_Ingestion_Log__c>>();
        uuidToInboundIngestionLogs = collectUUIDtoInboundIngestionLogs(
            (List<Inbound_Ingestion_Log__c>) getRecords()
        );
        if (uuidToInboundIngestionLogs.isEmpty()) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_UPDATE_PARENT_INBOUND_INGESTION,
                    LOG_SALES_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
            );
        }
        List<Inbound_Ingestion_Log__c> falloutInboundIngestionLogs = collectFalloutIngestionLogsToUpdate(
            uuidToInboundIngestionLogs
        );
        updateIngestionLogsBasedOnConditions(
            falloutInboundIngestionLogs,
            uuidToInboundIngestionLogs
        );
        updateParentLogOnChildIngestionLog(
            uuidToInboundIngestionLogs,
            collectParentIngestionLogs(uuidToInboundIngestionLogs)
        );
    }

    /**
     * @description Update Business Id for RESSSMO Onboarding Event
     * @author VenkateshDD | 10-03-2024
     **/
    public void onBeforeInsertHandleRESSMOIngestionLogs() {
        List<String> uuids = getStringFieldValues(Inbound_Ingestion_Log__c.UUID__c);
        List<Inbound_Ingestion_Log__c> existingLogs = InboundIngestionLogsSelector.newInstance()
            .selectByUUIDStatusSource(
                new Set<String>(uuids),
                new Set<String>{ PENDING, COMPLETED, SUCCESS, FAILED },
                SOURCE_RESSMO
            );
        Set<String> existingUuids = new Set<String>();
        for (Inbound_Ingestion_Log__c log : existingLogs) {
            existingUuids.add(log.UUID__c);
        }
        for (
            Inbound_Ingestion_Log__c ressmoLog : (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
                Inbound_Ingestion_Log__c.Source__c,
                SOURCE_RESSMO
            )
        ) {
            InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) JSON.deserialize(
                ressmoLog.Payload__c,
                InstantIngestionPayloadParser.class
            );
            ressmoLog.Business_Id__c = payload?.business?.businessId;
            ressmoLog.Status__c = payload
                    ?.store
                    ?.addressVerificationInfo
                    ?.addressVerificationStatus == REJECTED
                ? REJECTED
                : (existingUuids.contains(ressmoLog.UUID__c) ? DUPLICATE : ressmoLog.Status__c);
        }
    }

    /**
     * @description It rolls up the Status and Error message values from child
     * to parent ingestion log records.
     * @JIRA# LEM-14590
     */
    public void rollupStatusAndErrorMessage() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = new List<Inbound_Ingestion_Log__c>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestion : (List<Inbound_Ingestion_Log__c>) getRecords()
        ) {
            if (
                eachInboundIngestion.Parent_Log__c != null &&
                eachInboundIngestion.Status__c != STATUS_SKIPPED
            ) {
                inboundIngestionLogs.add(
                    new Inbound_Ingestion_Log__c(
                        Id = eachInboundIngestion.Parent_Log__c,
                        Business_Error_Message__c = eachInboundIngestion.Business_Error_Message__c,
                        Error_Message__c = eachInboundIngestion.Error_Message__c,
                        Exception_Message__c = eachInboundIngestion.Exception_Message__c,
                        Stack_Trace__c = eachInboundIngestion.Stack_Trace__c,
                        Status__c = eachInboundIngestion.Status__c,
                        Success_Message__c = eachInboundIngestion.Success_Message__c
                    )
                );
            }
        }
        if (inboundIngestionLogs.isEmpty() || Test.isRunningTest()) {
            return;
        }
        uow.registerDirty(inboundIngestionLogs);
        commitWork(uow, inboundIngestionLogs);
    }

    /**
     * @description It creates a child record if the inserted parent record's UUID does not match
     * with any existing UUID
     */
    public void createParentAndChildRecordsWhenNoMatchingUUIDFound() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Inbound_Ingestion_Log__c> ingestionLogs = new List<Inbound_Ingestion_Log__c>();
        Set<Inbound_Ingestion_Log__c> parentLogs = new Set<Inbound_Ingestion_Log__c>();
        List<Inbound_Ingestion_Log__c> skippedLogs = new List<Inbound_Ingestion_Log__c>();
        for (Inbound_ingestion_Log__c eachLog : (List<Inbound_Ingestion_Log__c>) getRecords()) {
            if (
                eachLog.Parent_Log__c == null &&
                eachLog.Integration_Type__c == FALLOUT_EVENT &&
                eachLog.Status__c != STATUS_SKIPPED
            ) {
                parentLogs.add(eachLog);
            } else if (eachLog.Status__c == STATUS_SKIPPED) {
                skippedLogs.add(eachLog);
            }
        }
        if (parentLogs.isEmpty()) {
            return;
        }
        ingestionLogs.addAll(parentLogs);
        for (Inbound_ingestion_Log__c eachLog : parentLogs) {
            uow.registerNew(
                new Inbound_Ingestion_Log__c(
                    Integration_Type__c = FALLOUT_EVENT,
                    UUID__c = eachLog.UUID__c,
                    Payload__c = eachLog.Payload__c,
                    Parent_Log__c = eachLog.Id,
                    Created_Date_Time__c = eachLog.Created_Date_Time__c,
                    Unique_Id__c = eachLog.Unique_Id__c,
                    Source__c = eachLog.Source__c
                )
            );
            for (Inbound_ingestion_Log__c eachSkippedLog : skippedLogs) {
                if (eachSkippedLog.UUID__c == eachLog.UUID__c) {
                    uow.registerDirty(
                        new Inbound_Ingestion_Log__c(
                            Id = eachSkippedLog.Id,
                            Parent_Log__c = eachLog.Id
                        )
                    );
                }
            }
        }
        ingestionLogs.addAll(skippedLogs);
        commitWork(uow, ingestionLogs);
    }

    /**
     * @description It collects parent Inbound Ingestion Logs by matching UUID.
     * @JIRA# LEM-15613
     * @param uuidToInboundIngestionLogs
     * @return Map<String, Id>
     */
    private List<Inbound_Ingestion_Log__c> collectFalloutIngestionLogsToUpdate(
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs
    ) {
        List<Inbound_Ingestion_Log__c> falloutIngestionLogsToUpdate = new List<Inbound_Ingestion_Log__c>();
        List<Inbound_Ingestion_Log__c> currentFalloutIngestionLogs = new List<Inbound_Ingestion_Log__c>();
        Inbound_Ingestion_Log__c latestFalloutIngestionLog = new Inbound_Ingestion_Log__c();
        Integer latestFalloutIngestionLogIndex;
        List<Inbound_Ingestion_Log__c> falloutIngestionLogsToSkip;
        for (String eachUUID : uuidToInboundIngestionLogs.keySet()) {
            falloutIngestionLogsToSkip = new List<Inbound_Ingestion_Log__c>();
            currentFalloutIngestionLogs = getFalloutLogs(uuidToInboundIngestionLogs.get(eachUUID));
            if (!currentFalloutIngestionLogs.isEmpty()) {
                latestFalloutIngestionLog = currentFalloutIngestionLogs[0];
                latestFalloutIngestionLogIndex = 0;
                falloutIngestionLogsToSkip.addAll(currentFalloutIngestionLogs);
                for (
                    Integer iterator = 0;
                    iterator < currentFalloutIngestionLogs.size() - 1;
                    iterator++
                ) {
                    latestFalloutIngestionLog = (latestFalloutIngestionLog.Created_Date_Time__c >=
                        currentFalloutIngestionLogs[iterator + 1].Created_Date_Time__c)
                        ? latestFalloutIngestionLog
                        : currentFalloutIngestionLogs[iterator + 1];
                    latestFalloutIngestionLogIndex = falloutIngestionLogsToSkip.indexOf(
                        latestFalloutIngestionLog
                    );
                }
                falloutIngestionLogsToSkip.remove(latestFalloutIngestionLogIndex);
            }
            if (!falloutIngestionLogsToSkip.isEmpty()) {
                falloutIngestionLogsToUpdate.addAll(falloutIngestionLogsToSkip);
            }
        }
        return falloutIngestionLogsToUpdate;
    }

    /**
     * @description It collects parent Inbound Ingestion Logs by matching UUID.
     * @JIRA# LEM-16006
     * @param uuidToInboundIngestionLogs
     * @return Map<String, Id>
     */
    private Map<String, List<Id>> collectParentIngestionLogs(
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs
    ) {
        Map<String, List<Id>> uuidToParentInboundIngestionLogIds = new Map<String, List<Id>>();
        List<Inbound_Ingestion_Log__c> parentIngestionLogs = new List<Inbound_Ingestion_Log__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Inbound_ingestion_Log__c eachParentInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectParentInboundIngestionLogsByUUIDs(uuidToInboundIngestionLogs.keySet())
        ) {
            if (
                !uuidToParentInboundIngestionLogIds.containsKey(
                    eachParentInboundIngestionLog.UUID__c
                )
            ) {
                List<Id> associatedParentLogs = new List<Id>{ eachParentInboundIngestionLog.Id };
                uuidToParentInboundIngestionLogIds.put(
                    eachParentInboundIngestionLog.UUID__c,
                    associatedParentLogs
                );
            } else {
                uuidToParentInboundIngestionLogIds.get(eachParentInboundIngestionLog.UUID__c)
                    .add(eachParentInboundIngestionLog.Id);
                if (eachParentInboundIngestionLog.Integration_Type__c == FALLOUT_EVENT) {
                    Id ultimateParentId = uuidToParentInboundIngestionLogIds.get(
                        eachParentInboundIngestionLog.UUID__c
                    )[0];
                    parentIngestionLogs.add(eachParentInboundIngestionLog);
                    uow.registerDirty(
                        new Inbound_Ingestion_Log__c(
                            Id = eachParentInboundIngestionLog.Id,
                            Parent_Log__c = ultimateParentId
                        )
                    );
                }
            }
        }
        commitWork(uow, parentIngestionLogs);
        return uuidToParentInboundIngestionLogIds;
    }

    /**
     * @description It collects UUID to Inbound Ingestion Logs.
     * @JIRA# LEM-15616
     * @param inboundIngestionLogs
     * @return Map<String, List<Inbound_Ingestion_Log__c>>
     */
    private Map<String, List<Inbound_Ingestion_Log__c>> collectUUIDtoInboundIngestionLogs(
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs
    ) {
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs = new Map<String, List<Inbound_Ingestion_Log__c>>();
        for (Inbound_Ingestion_Log__c eachInboundIngestionLog : inboundIngestionLogs) {
            if (
                eachInboundIngestionLog.UUID__c != null &&
                eachInboundIngestionLog.Integration_Type__c == FALLOUT_EVENT &&
                eachInboundIngestionLog.Parent_Log__c == null
            ) {
                uuidToInboundIngestionLogs = getUUIdToInboundIngestionLogs(
                    eachInboundIngestionLog,
                    eachInboundIngestionLog.UUID__c,
                    uuidToInboundIngestionLogs
                );
            } else if (
                eachInboundIngestionLog.UUID__c != null &&
                (eachInboundIngestionLog.Integration_Type__c == ONBOARDING_EVENT ||
                eachInboundIngestionLog.Integration_Type__c == MX_PORTAL_NSE_EVENT)
            ) {
                uuidToInboundIngestionLogs = getUUIdToInboundIngestionLogs(
                    eachInboundIngestionLog,
                    eachInboundIngestionLog.UUID__c,
                    uuidToInboundIngestionLogs
                );
            }
        }
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                    new Set<String>{ FALLOUT_EVENT, ONBOARDING_EVENT, MX_PORTAL_NSE_EVENT },
                    uuidToInboundIngestionLogs.keySet()
                )
        ) {
            uuidToInboundIngestionLogs = getUUIdToInboundIngestionLogs(
                eachInboundIngestionLog,
                eachInboundIngestionLog.UUID__c,
                uuidToInboundIngestionLogs
            );
        }
        return uuidToInboundIngestionLogs;
    }

    /**
     * @description It returns map of Uuid to list of Inbound Ingestion Logs.
     * @JIRA# LEM-15616
     * @param inboundIngestionLog
     * @param uuid
     * @param uuidToInboundIngestionLogs
     * @return Map<String, List<Inbound_Ingestion_Log__c>>
     */
    private Map<String, List<Inbound_Ingestion_Log__c>> getUUIdToInboundIngestionLogs(
        Inbound_Ingestion_Log__c inboundIngestionLog,
        String uuid,
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs
    ) {
        if (!uuidToInboundIngestionLogs.containsKey(uuid)) {
            uuidToInboundIngestionLogs.put(uuid, new List<Inbound_Ingestion_Log__c>());
        }
        uuidToInboundIngestionLogs.get(uuid).add(inboundIngestionLog);
        return uuidToInboundIngestionLogs;
    }

    /** @description It is used to mark the fallout event Inbound Ingestion Log status
     * to 'Skipped'.
     * @param inboundIngestionLog
     * @JIRA# LEM-15613
     */
    private void markStatusAsSkipped(Inbound_Ingestion_Log__c inboundIngestionLog) {
        inboundIngestionLog.Status__c = STATUS_SKIPPED;
    }

    /**
     * @description It updates 'Parent Log' value on child record if matching
     * Inbound Ingestion Log found.
     * @param uuidToInboundIngestionLogs
     * @param uuidToParentInboundIngestionLogIds
     * @JIRA# LEM-16006
     */
    private void updateParentLogOnChildIngestionLog(
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs,
        Map<String, List<Id>> uuidToParentInboundIngestionLogIds
    ) {
        for (String eachUUID : uuidToInboundIngestionLogs.keySet()) {
            for (
                Inbound_Ingestion_Log__c eachInboundIngestionLog : getFalloutLogs(
                    uuidToInboundIngestionLogs.get(eachUUID)
                )
            ) {
                if (
                    uuidToParentInboundIngestionLogIds.containsKey(eachInboundIngestionLog.UUID__c)
                ) {
                    eachInboundIngestionLog.Parent_Log__c = uuidToParentInboundIngestionLogIds.get(
                        eachInboundIngestionLog.UUID__c
                    )[0];
                }
            }
        }
    }

    /** @description It is used to update the fallout event Inbound Ingestion Log status
     * to 'Skipped'.
     * @param uuidToInboundIngestionLogs
     * @JIRA# LEM-15616
     */
    private void updateStatusToSkipped(
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs
    ) {
        Boolean isOnboardingIngestionLogPresent;
        for (String eachUUID : uuidToInboundIngestionLogs.keySet()) {
            List<Inbound_Ingestion_Log__c> falloutIngestionLogs = new List<Inbound_Ingestion_Log__c>();
            isOnboardingIngestionLogPresent = false;
            for (
                Inbound_Ingestion_Log__c eachInboundIngestionLog : uuidToInboundIngestionLogs.get(
                    eachUUID
                )
            ) {
                if (
                    eachInboundIngestionLog.Integration_Type__c == ONBOARDING_EVENT ||
                    eachInboundIngestionLog.Integration_Type__c == MX_PORTAL_NSE_EVENT
                ) {
                    isOnboardingIngestionLogPresent = true;
                } else if (
                    eachInboundIngestionLog.Integration_Type__c == FALLOUT_EVENT &&
                    eachInboundIngestionLog.Status__c != STATUS_SKIPPED &&
                    eachInboundIngestionLog.Status__c != COMPLETED &&
                    eachInboundIngestionLog.Status__c != SUCCESS
                ) {
                    falloutIngestionLogs.add(eachInboundIngestionLog);
                }
            }
            if (isOnboardingIngestionLogPresent) {
                for (Inbound_Ingestion_Log__c eachInboundIngestionLog : falloutIngestionLogs) {
                    markStatusAsSkipped(eachInboundIngestionLog);
                }
            }
        }
    }

    /** @description It is used to update the Inbound Ingestion Logs based
     * on certain empty checks.
     * @param falloutInboundIngestionLogs
     * @param uuidToInboundIngestionLogs
     * @JIRA# LEM-15616
     */
    private void updateIngestionLogsBasedOnConditions(
        List<Inbound_Ingestion_Log__c> falloutInboundIngestionLogs,
        Map<String, List<Inbound_Ingestion_Log__c>> uuidToInboundIngestionLogs
    ) {
        if (!uuidToInboundIngestionLogs.isEmpty()) {
            updateStatusToSkipped(uuidToInboundIngestionLogs);
        }
        if (!falloutInboundIngestionLogs.isEmpty()) {
            for (Inbound_Ingestion_Log__c eachFalloutIngestionLog : falloutInboundIngestionLogs) {
                if (
                    eachFalloutIngestionLog.Status__c != STATUS_SKIPPED &&
                    eachFalloutIngestionLog.Status__c != COMPLETED &&
                    eachFalloutIngestionLog.Status__c != SUCCESS
                ) {
                    markStatusAsSkipped(eachFalloutIngestionLog);
                }
            }
        }
    }

    /**
     * @description It is used to update the Inbound Ingestion Log records with Success or Failure status.
     * @param ingestionLogsIdSet
     * @param status
     * @param errorMessage
     * @param stackTrace
     * @param businessErrorMessage
     * TODO: Move this method to a service.  Domain classes should not have static methods like this.
     */
    public static void updateIngestionLogsWithSucessOrFailureStatus(
        Set<Id> ingestionLogsIdSet,
        String status,
        String errorMessage,
        String stackTrace,
        String businessErrorMessage
    ) {
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogsToUpdate = new List<Inbound_Ingestion_Log__c>();
        if (!ingestionLogsIdSet.isEmpty()) {
            for (
                Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                    .selectById(ingestionLogsIdSet)
            ) {
                eachInboundIngestionLog.Status__c = status;
                eachInboundIngestionLog.Error_Message__c = errorMessage;
                eachInboundIngestionLog.Business_Error_Message__c = businessErrorMessage;
                eachInboundIngestionLog.Exception_Message__c = errorMessage;
                if (status == COMPLETED) {
                    eachInboundIngestionLog.Success_Message__c = SUCCESS_MESSAGE;
                }
                eachInboundIngestionLog.Stack_Trace__c = stackTrace;
                inboundIngestionLogsToUpdate.add(eachInboundIngestionLog);
            }
        }
        if (!inboundIngestionLogsToUpdate.isEmpty()) {
            unitOfWork.registerDirty(inboundIngestionLogsToUpdate);
            commitWork(unitOfWork, inboundIngestionLogsToUpdate);
            sendSuccessNotificationToScalyr(inboundIngestionLogsToUpdate, status);
        }
    }

    /**
     * @description It is a common method to commit unit of work.
     * @JIRA# LEM-15227
     * @param uow
     * @param inboundIngestionLogs
     */
    private static void commitWork(
        fflib_ISObjectUnitOfWork uow,
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs
    ) {
        Set<String> updatedRecordIds = new Set<String>();
        try {
            uow.commitWork();
        } catch (Exception e) {
            for (Inbound_Ingestion_Log__c eachInboundIngestionLog : inboundIngestionLogs) {
                updatedRecordIds.add(eachInboundIngestionLog.Id);
            }
            IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                LOG_SALES_DOMAIN,
                inboundIngestionLogs[0].Id,
                inboundIngestionLogs[0].UUID__c,
                inboundIngestionLogs[0].Unique_Id__c
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                e,
                INGESTION_LOG_FAILED_BUSINESS_ERROR_MESSAGE,
                '',
                updatedRecordIds,
                e.getTypeName()
            );
        }
    }

    /**
     * @description It is used to update the Inbound Ingestion Log records with pending status
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public void updateFailedLogsWithPendingStatus() {
        Set<id> parentIngestionLogIds = new Set<Id>();
        for (Inbound_ingestion_Log__c iLog : (List<Inbound_Ingestion_Log__c>) getRecords()) {
            parentIngestionLogIds.add(iLog.Id);
        }

        if (parentIngestionLogIds.isEmpty()) {
            return;
        }
        List<Inbound_Ingestion_Log__c> parentChildLogList = [
            SELECT
                id,
                Integration_Type__c,
                status__c,
                Retry_Count__c,
                (
                    SELECT id, Integration_Type__c, status__c, Retry_Count__c
                    FROM Inbound_ingestion_Logs__r
                    ORDER BY createddate DESC
                )
            FROM Inbound_Ingestion_log__c
            WHERE id IN :parentIngestionLogIds
        ];
        List<Inbound_Ingestion_Log__c> logsToBeUpdatedPending = new List<Inbound_Ingestion_Log__c>();
        for (Inbound_Ingestion_Log__c iLog : parentChildLogList) {
            if (INTEGRATION_TYPES.contains(ilog.Integration_Type__c)) {
                iLog.Status__c = 'Pending';
                iLog.Retry_Count__c++;
                logsToBeUpdatedPending.add(iLog);
                continue;
            }
            for (Inbound_ingestion_Log__c childLog : iLog.Inbound_ingestion_Logs__r) {
                if (
                    (childLog.Integration_Type__c == ONBOARDING_EVENT ||
                    childLog.Integration_Type__c == FALLOUT_EVENT) && childLog.status__c == 'Failed'
                ) {
                    childLog.status__c = 'Pending';
                    childLog.Retry_Count__c = childLog.Retry_Count__c + 1;
                    logsToBeUpdatedPending.add(childLog);
                    break;
                } else if (
                    childLog.Integration_Type__c == ONBOARDING_EVENT &&
                    childLog.status__c != 'Failed'
                ) {
                    break;
                }
            }
        }

        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        unitOfWork.registerDirty(logsToBeUpdatedPending);
        unitOfWork.commitWork();
    }

    /**
     * @description It is used to initiate retry SSMO process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @JIRA #18394
     */
    public void initiateRetrySSMORecordsCreation() {
        initiateRetryRecordsCreationByFieldValueAndSource(
            Inbound_Ingestion_Log__c.Integration_Type__c,
            (Object) ONBOARDING_EVENT,
            SOURCE_SSMO
        );
    }

    /**
     * @description It is used to initiate retry RESSMO process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @JIRA #LEM-21402
     */
    public void initiateRetryRESSMORecordsCreation() {
        initiateRetryRecordsCreationByFieldValueAndSource(
            Inbound_Ingestion_Log__c.Source__c,
            (Object) SOURCE_RESSMO,
            SOURCE_RESSMO
        );
    }

    /**
     * @description It is used to initiate retry SSOB process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @JIRA #18394
     */
    public void initiateRetrySSOBRecordsCreation() {
        initiateRetryRecordsCreationByFieldValueAndSource(
            Inbound_Ingestion_Log__c.Source__c,
            (Object) SOURCE_SSOB,
            SOURCE_SSOB
        );
    }

    /**
     * @description It is used to initiate retry Mx Portal process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @JIRA #18394
     */
    public void initiateRetryMxPortalRecordsCreation() {
        initiateRetryRecordsCreationByFieldValueAndSource(
            Inbound_Ingestion_Log__c.Source__c,
            (Object) SOURCE_MX_PORTAL,
            SOURCE_MX_PORTAL
        );
    }

    /**
     * @description It is used to initiate retry By Source process in Salesforce by publishing
     * platform events for the corrosponding failed step.
     * @param field
     * @param value
     * @param source
     * @author VenkateshDD | 09-30-2024
     **/
    private void initiateRetryRecordsCreationByFieldValueAndSource(
        Schema.SObjectField field,
        Object value,
        String source
    ) {
        Map<String, String> failedStepToEvent = new Map<String, String>();
        Map<String, Set<Id>> failedInboundIngestionLogIdsByEventTopic = new Map<String, Set<Id>>();
        List<Inbound_Ingestion_Log__c> retryInboundIngestionLogs = (List<Inbound_Ingestion_Log__c>) getRecordsByFieldValue(
            field,
            value
        );
        if (retryInboundIngestionLogs.isEmpty()) {
            return;
        }
        failedStepToEvent = getFailedStepToEvent(source);
        assignFailedStepToEvent(
            failedStepToEvent,
            failedInboundIngestionLogIdsByEventTopic,
            retryInboundIngestionLogs
        );
        if (failedInboundIngestionLogIdsByEventTopic.isEmpty() || Test.isRunningTest()) {
            return;
        }
        publishFailedRecordsByEventTopic(failedInboundIngestionLogIdsByEventTopic, source);
    }

    /**
     * @description It is used to get the failed step with corrosponding event topic from custom metadata.
     * @param integrationType
     * @return Map<String, String>
     */
    private Map<String, String> getFailedStepToEvent(String integrationType) {
        Map<String, String> failedStepToEvent = new Map<String, String>();
        for (
            Inbound_Ingestion_Failed_Step_Mapping__mdt eachmdt : Inbound_Ingestion_Failed_Step_Mapping__mdt.getAll()
                .values()
        ) {
            if (eachmdt.Integration_Source__c == integrationType) {
                failedStepToEvent.put(eachmdt.Falied_Step__c, eachmdt.Event_Topic__c);
            }
        }
        return failedStepToEvent;
    }

    /**
     * @description It is used to populate the ingestion record Ids with event topic.
     * @param failedStepToEvent
     * @param failedInboundIngestionLogIdsByEventTopic
     * @param retryInboundIngestionLogs
     */
    private void assignFailedStepToEvent(
        Map<String, String> failedStepToEvent,
        Map<String, Set<Id>> failedInboundIngestionLogIdsByEventTopic,
        List<Inbound_Ingestion_Log__c> retryInboundIngestionLogs
    ) {
        for (Inbound_Ingestion_Log__c retryInboundIngestionLog : retryInboundIngestionLogs) {
            if (retryInboundIngestionLog.Status__c != PENDING) {
                continue;
            }
            if (
                AMENDMENT_EVENT_TOPICS.contains(
                    failedStepToEvent.get(
                        String.valueof(Integer.valueof(retryInboundIngestionLog.Failure_Step__c))
                    )
                )
            ) {
                if (
                    !failedInboundIngestionAmendmentRetryPayloadByEventTopic.containsKey(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        )
                    ) && retryInboundIngestionLog.Internal_Payload_For_Retry__c != null
                ) {
                    failedInboundIngestionAmendmentRetryPayloadByEventTopic.put(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        ),
                        new Set<Object>{}
                    );
                }
                MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper wrap = (MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper) JSON.deserialize(
                    retryInboundIngestionLog.Internal_Payload_For_Retry__c,
                    MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper.class
                );
                failedInboundIngestionAmendmentRetryPayloadByEventTopic.get(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        )
                    )
                    .add(wrap);
            } else {
                if (
                    !failedInboundIngestionLogIdsByEventTopic.containsKey(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        )
                    )
                ) {
                    failedInboundIngestionLogIdsByEventTopic.put(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        ),
                        new Set<Id>{}
                    );
                }
                failedInboundIngestionLogIdsByEventTopic.get(
                        failedStepToEvent.get(
                            String.valueof(
                                Integer.valueof(retryInboundIngestionLog.Failure_Step__c)
                            )
                        )
                    )
                    .add(retryInboundIngestionLog.Id);
            }
        }
    }

    /**
     * @description It is used to publish failed records in Salesforce by publishing platform events.
     * @param failedInboundIngestionLogIdsByEventTopic
     * @param integrationType
     */
    private void publishFailedRecordsByEventTopic(
        Map<String, Set<Id>> failedInboundIngestionLogIdsByEventTopic,
        String integrationType
    ) {
        if (!failedInboundIngestionAmendmentRetryPayloadByEventTopic.isEmpty()) {
            for (
                String eventTopic : failedInboundIngestionAmendmentRetryPayloadByEventTopic.keySet()
            ) {
                InstantIngestorEventsService.publishBulkEvents(
                    new Map<String, List<String>>{
                        eventTopic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                            failedInboundIngestionAmendmentRetryPayloadByEventTopic.get(eventTopic),
                            Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                        )
                    }
                );
            }
        } else if (!failedInboundIngestionLogIdsByEventTopic.isEmpty()) {
            for (String eventTopic : failedInboundIngestionLogIdsByEventTopic.keySet()) {
                InstantIngestorEventsService.publishBulkEvents(
                    new Map<String, List<String>>{
                        eventTopic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                            failedInboundIngestionLogIdsByEventTopic.get(eventTopic),
                            Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                        )
                    }
                );
            }
        }
    }

    /**
     * @description It is used to get only fallouts logs from a list of logs.
     * @param inboundIngestionLogRecords
     * @return List<Inbound_Ingestion_Log__c>
     */
    private List<Inbound_Ingestion_Log__c> getFalloutLogs(
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords
    ) {
        List<Inbound_Ingestion_Log__c> falloutLogs = new List<Inbound_Ingestion_Log__c>();
        for (Inbound_Ingestion_Log__c eachInboundIngestionLog : inboundIngestionLogRecords) {
            if (eachInboundIngestionLog.Integration_Type__c == FALLOUT_EVENT) {
                falloutLogs.add(eachInboundIngestionLog);
            }
        }
        return falloutLogs;
    }

    /**
     * @description It is used to send success notification to scalyr when the inbound ingestion log
     * is marked as completed.
     * @param inboundIngestionLogsToUpdate
     * @param status
     */
    private static void sendSuccessNotificationToScalyr(
        List<Inbound_Ingestion_Log__c> inboundIngestionLogsToUpdate,
        String status
    ) {
        if (status == COMPLETED) {
            IinboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                LOG_SALES_DOMAIN,
                inboundIngestionLogsToUpdate[0].Id,
                inboundIngestionLogsToUpdate[0].UUID__c,
                inboundIngestionLogsToUpdate[0].Unique_Id__c
            );
            InboundIngestionLoggerService.logSuccess(loggerEntry, SUCCESS_MESSAGE);
        }
    }
}