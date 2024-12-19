/**
 * @author Deloitte
 * @date 05/11/2024
 * @description InboundIngestionLogs Trigger Handler.
 */
public inherited sharing class InboundIngestionLogsHandler extends ApplicationDomainHandler {
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION = 'EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION';
    private static final String EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT = 'EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String SSMO_FALLOUT = 'SSMO_FALLOUT';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String PENDING = 'Pending';
    /**
     * @description Constructor to instantiate list of inbound ingestion logs
     * @param sObjects
     */
    public InboundIngestionLogsHandler(List<Inbound_Ingestion_Log__c> sObjects) {
        super(sObjects);
        setContextBypass(Inbound_Ingestion_Log__c.SobjectType, InboundIngestionLogsHandler.class);
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjects
         * @return InboundIngestionLogsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new InboundIngestionLogsHandler(sObjects);
        }
    }
    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        InboundIngestionLogs.newInstance(this.records).onBeforeInsertHandleFalloutIngestionLogs();
        InboundIngestionLogs.newInstance(this.records).onBeforeInsertHandleRESSMOIngestionLogs();
    }

    /**
     * @description It is used to perform Before Insert operations on the Inbound Ingestion Logs.
     * @JIRA# LEM-14648
     */
    public override void onAfterInsert() {
        if (
            this.records[0].get('Source__c') != null &&
            this.records[0].get('Source__c').equals(SOURCE_RESSMO)
        ) {
            InboundIngestionLogs.newInstance(this.records)
                .initiateRESSMOOnboardingRecordsCreation(
                    EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
                );
        } else {
            InboundIngestionLogs.newInstance(this.records)
                .initiateSSMOOnboardingRecordsCreation(
                    EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
                );
            InboundIngestionLogs.newInstance(this.records)
                .initiateSSOBOnboardingRecordsCreation(
                    EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
                );
            InboundIngestionLogs.newInstance(this.records)
                .initiateMxPortalNSERecordsCreation(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION);

            InboundIngestionLogs.newInstance(this.records)
                .initiateMxPortalAmendments(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);

            InboundIngestionLogs.newInstance(this.records)
                .initiateAdsPromosAmendment(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT);

            InboundIngestionLogs.newInstance(this.records)
                .initiateSSMOFalloutRecordsCreation(SSMO_FALLOUT);
            InboundIngestionLogs.newInstance(this.records)
                .createParentAndChildRecordsWhenNoMatchingUUIDFound();
        }
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Inbound_Ingestion_Log__c> changedRecordsForRollup = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getChangedRecords(
                new Set<SObjectField>{
                    Inbound_Ingestion_Log__c.Error_Message__c,
                    Inbound_Ingestion_Log__c.Status__c,
                    Inbound_ingestion_Log__c.Success_Message__c,
                    Inbound_ingestion_Log__c.Exception_Message__c,
                    Inbound_ingestion_Log__c.Business_Error_Message__c,
                    Inbound_ingestion_Log__c.Stack_Trace__c
                }
            )
        );
        if (changedRecordsForRollup.size() > 0) {
            InboundIngestionLogs.newInstance(changedRecordsForRollup).rollupStatusAndErrorMessage();
        }

        List<Inbound_Ingestion_Log__c> changedInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>(
            (List<Inbound_Ingestion_Log__c>) getChangedRecords(
                new Set<SObjectField>{ Inbound_Ingestion_Log__c.Status__c }
            )
        );
        if (changedInboundIngestionLogs.size() > 0) {
            InboundIngestionLogs.newInstance(changedInboundIngestionLogs)
                .initiateRetryRESSMORecordsCreation();
            InboundIngestionLogs.newInstance(changedInboundIngestionLogs)
                .initiateRetrySSMORecordsCreation();
            InboundIngestionLogs.newInstance(changedInboundIngestionLogs)
                .initiateRetrySSOBRecordsCreation();
            InboundIngestionLogs.newInstance(changedInboundIngestionLogs)
                .initiateRetryMxPortalRecordsCreation();
        }
        List<Inbound_Ingestion_Log__c> changedPendingLogs = getPendingInboundIngestionLogs(
            existing
        );
        InboundIngestionLogs.newInstance(changedPendingLogs)
            .initiateSSMOFalloutRecordsCreation(SSMO_FALLOUT);
    }
    /**
     * @description It is used to get logs with updated status as pending.
     * @param existing
     * @return List<Inbound_Ingestion_Log__c>
     */
    private List<Inbound_Ingestion_Log__c> getPendingInboundIngestionLogs(
        Map<Id, SObject> existing
    ) {
        List<Inbound_Ingestion_Log__c> changedPendingLogs = new List<Inbound_Ingestion_Log__c>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : new List<Inbound_Ingestion_Log__c>(
                (List<Inbound_Ingestion_Log__c>) getChangedRecords(
                    new Set<SObjectField>{ Inbound_Ingestion_Log__c.Status__c }
                )
            )
        ) {
            if (eachInboundIngestionLog.Status__c == PENDING) {
                changedPendingLogs.add(eachInboundIngestionLog);
            }
        }
        return changedPendingLogs;
    }
}