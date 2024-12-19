/**
 * @author Deloitte
 * @date 05/16/2024
 * @description Service implementation class for SSMO Lead conversion related logic.
 */
public inherited sharing class SSMOLeadConversionServiceImpl implements ISSMOLeadConversionService {
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String CONTACT_OBJECT = 'Contact';
    private static final String CONVERTED_LEAD_STATUS = 'Converted';
    private static final String LEAD_BUSINESS_ERROR_MESSAGE = 'Lead conversion failed for Onboarding SSMO event';
    private static final String LEAD_CONVERSION_TYPE_AUTO = 'Auto';
    private static final String LEAD_OBJECT = 'Lead';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_ERROR_CATEGORY_DML = 'Data Validation';
    private static final String LOG_ERROR_CATEGORY_OTHER = 'Other Salesforce Exception';
    private static final String LOG_SALES_DOMAIN = 'Sales';
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private Map<String, Id> matchingIdentifiersToAccountIds;
    private Map<String, Id> matchingIdentifiersToContactIds;
    private Map<Lead, String> matchingLeadsToIdentifiers;

    /**
     * @description Default constructor to instantiate variables.
     */
    public SSMOLeadConversionServiceImpl() {
        this.matchingIdentifiersToAccountIds = new Map<String, Id>();
        this.matchingIdentifiersToContactIds = new Map<String, Id>();
        this.matchingLeadsToIdentifiers = new Map<Lead, String>();
    }

    /**
     * @description It is used to auto convert Leads received from
     * onboarding SSMO scenario by passed Inbound Ingestion Log Ids.
     * @param ingestionLogIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    public void autoConvertLeads(
        Set<Id> ingestionLogIds,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        Set<String> uniqueIdentifierIds = new Set<String>();
        if (ingestionLogIds == null || ingestionLogIds.isEmpty()) {
            return;
        }
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(ingestionLogIds)
        ) {
            uniqueIdentifierIds.add(eachInboundIngestionLog.UUID__c);
        }
        collectSObjectsByUniqueIdentifiers(
            uniqueIdentifierIds,
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
        autoConvertMatchingLeads();
    }

    /**
     * @description It is used to auto convert Leads matching unique identifiers from SSMO.
     */
    private void autoConvertMatchingLeads() {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        Set<String> leadIds = new Set<String>();
        List<Lead> leads = new List<Lead>();
        if (matchingLeadsToIdentifiers.isEmpty() || matchingLeadsToIdentifiers == null) {
            return;
        }
        for (Lead eachMatchingLead : matchingLeadsToIdentifiers.keySet()) {
            unitOfWork.registerDirty(
                new Lead(
                    Id = eachMatchingLead.Id,
                    Lead_Conversion_Type__c = LEAD_CONVERSION_TYPE_AUTO
                )
            );
            leadIds.add(eachMatchingLead.Id);
            Database.LeadConvert currentLeadConvert = new Database.LeadConvert();
            currentLeadConvert.setLeadId(eachMatchingLead.Id);
            currentLeadConvert.setAccountId(
                matchingIdentifiersToAccountIds.get(
                    matchingLeadsToIdentifiers.get(eachMatchingLead)
                )
            );
            currentLeadConvert.setContactId(
                matchingIdentifiersToContactIds.get(
                    matchingLeadsToIdentifiers.get(eachMatchingLead)
                )
            );
            currentLeadConvert.setConvertedStatus(CONVERTED_LEAD_STATUS);
            currentLeadConvert.setDoNotCreateOpportunity(true);
            currentLeadConvert.setSendNotificationEmail(false);
            currentLeadConvert.setOwnerId(UserInfo.getUserId());
            leadConverts.add(currentLeadConvert);
        }
        leads.addAll(matchingLeadsToIdentifiers.keySet());
        commitWork(unitOfWork, leads, leadIds);
        if (!leadConverts.isEmpty() && !Test.isRunningTest()) {
            try {
                Database.convertLead(leadConverts);
            } catch (Exception ex) {
                IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                    LOG_SELF_SERVING_FALLOUT_SERVICE,
                    LOG_SALES_DOMAIN,
                    leads[0].Inbound_Ingestion_Log__c,
                    leads[0].SSMO_UUID__c,
                    leads[0].Unique_Id__c
                );
                InboundIngestionLoggerService.logException(
                    loggerEntry,
                    ex,
                    LEAD_BUSINESS_ERROR_MESSAGE,
                    '',
                    leadIds,
                    LOG_ERROR_CATEGORY_OTHER
                );
            }
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     * @param leads
     * @param leadIds
     */
    private static void commitWork(
        fflib_ISObjectUnitOfWork unitOfWork,
        List<Lead> leads,
        Set<String> leadIds
    ) {
        try {
            unitOfWork.commitWork();
        } catch (Exception e) {
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                LOG_SALES_DOMAIN,
                leads[0].Inbound_Ingestion_Log__c,
                leads[0].SSMO_UUID__c,
                leads[0].Unique_Id__c
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                e,
                LEAD_BUSINESS_ERROR_MESSAGE,
                '',
                leadIds,
                LOG_ERROR_CATEGORY_DML
            );
        }
    }

    /**
     * @description It is used to collect Leads using matching unique identifiers.
     * @param uniqueIdentifierIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    private void collectSObjectsByUniqueIdentifiers(
        Set<String> uniqueIdentifierIds,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        if (uniqueIdentifierIds == null || uniqueIdentifierIds.isEmpty()) {
            return;
        }
        collectLeadRecords(uniqueIdentifierIds, payLoadWrapperByIngestionLogUUIDForContactAndACR);
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectAccountsByUniqueIdentifiersAndRecordType(
                    uniqueIdentifierIds,
                    BUSINESS_RECORD_TYPE_ID
                )
        ) {
            matchingIdentifiersToAccountIds.put(eachAccount.Unique_Identifier__c, eachAccount.Id);
        }
        collectContactRecords(
            uniqueIdentifierIds,
            payLoadWrapperByIngestionLogUUIDForContactAndACR
        );
    }

    /**
     * @description It is used to collect Contacts using matched record Contact Ids or
     * matching passed unique identifiers.
     * @param uniqueIdentifierIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    private void collectContactRecords(
        Set<String> uniqueIdentifierIds,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        Map<Id, String> matchedContactIdToUniqueId = new Map<Id, String>();
        matchedContactIdToUniqueId = InstantIngestionCheckRecordsService.getExistingSObjectsByMatchedRecordId(
            payLoadWrapperByIngestionLogUUIDForContactAndACR,
            CONTACT_OBJECT
        );
        if (matchedContactIdToUniqueId != null || !matchedContactIdToUniqueId.isEmpty()) {
            for (
                Contact eachContact : ContactsSelector.newInstance()
                    .selectById(matchedContactIdToUniqueId.keySet())
            ) {
                matchingIdentifiersToContactIds.put(
                    matchedContactIdToUniqueId.get(eachContact.Id),
                    eachContact.Id
                );
            }
        }
        for (
            Contact eachContact : ContactsSelector.newInstance()
                .selectContactsByUniqueIdentifier(uniqueIdentifierIds)
        ) {
            matchingIdentifiersToContactIds.put(eachContact.Unique_Identifier__c, eachContact.Id);
        }
    }

    /**
     * @description It is used to collect Leads using matched record Lead Ids or
     * matching passed unique identifiers.
     * @param uniqueIdentifierIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    private void collectLeadRecords(
        Set<String> uniqueIdentifierIds,
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR
    ) {
        Map<Id, String> matchedRecordLeadIdToUniqueId = new Map<Id, String>();
        matchedRecordLeadIdToUniqueId = InstantIngestionCheckRecordsService.getExistingSObjectsByMatchedRecordId(
            payLoadWrapperByIngestionLogUUIDForContactAndACR,
            LEAD_OBJECT
        );
        if (matchedRecordLeadIdToUniqueId != null || !matchedRecordLeadIdToUniqueId.isEmpty()) {
            for (
                Lead eachLead : LeadsSelector.newInstance()
                    .selectById(matchedRecordLeadIdToUniqueId.keySet())
            ) {
                if (!eachLead.isConverted) {
                    matchingLeadsToIdentifiers.put(
                        eachLead,
                        matchedRecordLeadIdToUniqueId.get(eachLead.Id)
                    );
                }
            }
        }
        for (
            Lead eachLead : LeadsSelector.newInstance()
                .selectByUniqueIdentifiers(uniqueIdentifierIds)
        ) {
            if (!eachLead.isConverted) {
                matchingLeadsToIdentifiers.put(eachLead, eachLead.SSMO_UUID__c);
            }
        }
    }
}