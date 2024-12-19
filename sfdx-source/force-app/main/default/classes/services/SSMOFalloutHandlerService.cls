/**
 * @author Deloitte
 * @date 05/11/2024
 * @description SSMOFallout trigger handler class to insert/update lead and contact.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class SSMOFalloutHandlerService implements IHandleNonInstantIngestionEvents {
    private static final String LEAD_STATUS_UNTOUCHED = 'Untouched';
    private static final String LEAD_SOURCE = 'get.doordash.com';
    private static final String LEAD_BUSINESS_ERROR_MESSAGE = 'Fallout SSMO Lead/Contact creation or update failed';
    private static final String LOG_SALES_DOMAIN = 'Sales';
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String NON_DUPLICATE_LEAD_STATUS = 'Non-Duplicate';
    private static final String FAILED = 'Failed';
    private List<Contact> upsertContactList = new List<Contact>();
    private List<Lead> upsertLeadList = new List<Lead>();
    private static final String BUSINESS = 'Business';
    private static final String STORE = 'Store';
    private static final String INACTIVE_STATUS = 'Inactive';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String SSMO_HOLDING_QUEUE = 'SSMO Holding Queue';
    private Id queueId;
    private Map<Id, Contact> matchedContact = new Map<Id, Contact>();
    private static final String STATUS_VERIFIED = 'Verified';
    private Map<Id, Id> inboundIngestionLogIdToSubmarketIds = new Map<Id, Id>();
    private static final String SUBMARKET_FAILED_BUSINESS_ERROR_MESSAGE = 'SubMarket creation failed';
    private Map<Id, Id> logIdToUuidMatchedLeadId = new Map<Id, Id>();
    private static final String UPDATE_CONTEXT ='Update';
    private static final String INSERT_CONTEXT ='Insert';
    private static final String BUSINESS_ERROR_MESSAGE = 'Fallout SSMO processing failed';
    private static final String INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST = 'INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST';
    private static final String INVALID_STATE_ERROR_MESSAGE = 'Please select a state from the list of valid states';
    private static final String COUNTRY = 'Country';
    private Map<Id, Lead> matchedLeads = new Map<Id, Lead>();

    /**
     * @description service execute method.
     * @param events
     */
    public void execute(List<Non_Instant_Ingestor__e> events) {
        Map<Id, SSMOFalloutWrapper> logIdToSSMOFalloutWrapper = new Map<Id, SSMOFalloutWrapper>();
        Set<Id> matchedContactIds = new Set<Id>();
        Set<Id> matchedLeadIds = new Set<Id>();
        Set<Id> setLogIds = new Set<Id>();
        Set<Id> matchedAccountIds = new Set<Id>();
        Set<String> submarketIds = new Set<String>();
        Map<Id, Id> accountIdToinboubdIngestionLog = new Map<Id, Id>();
        Map<Id, Id> inboundIngestionLogIdToMatchedContactId = new Map<Id, Id>();
        Map<Id, Id> inboundIngestionLogIdToMatchedLeadId = new Map<Id, Id>();
        Map<Id, String> logIdsToSubmarketIdValues = new Map<Id, String>();
        Map<String, Id> sourceUniqueIdTologIds = new Map<String, Id>();
        Inbound_Ingestion_Log__c logRecord = new Inbound_Ingestion_Log__c();
        for (Non_Instant_Ingestor__e eachEvent : events) {
            setLogIds = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
        }
        if (!setLogIds.isEmpty()) {
            List<Inbound_ingestion_Log__c> inboundIngestionLogRecords = InboundIngestionLogsSelector.newInstance()
                .selectById(setLogIds);
            List<Group> queues = GroupsSelector.newInstance().selectQueueByName(SSMO_HOLDING_QUEUE);
            queueId = queues[0]?.Id;
            try{
                for (Inbound_ingestion_Log__c eachInboundIngestionLog : inboundIngestionLogRecords) {
                    SSMOFalloutWrapper falloutWrapper = (SSMOFalloutWrapper) System.JSON.deserialize(
                        eachInboundIngestionLog.Payload__c,
                        SSMOFalloutWrapper.class
                    );
                    logIdToSSMOFalloutWrapper.put(eachInboundIngestionLog.Id, falloutWrapper);
                    sourceUniqueIdTologIds.put(
                        falloutWrapper.sourceUniqueId,
                        eachInboundIngestionLog.Id
                    );
                    Id matchedLeadId = getExistingLeadIds(falloutWrapper);
                    Id matchedAccountId = getExistingAccountIds(falloutWrapper);
                    Id matchedContactId = getExistingContactIds(falloutWrapper);
                    if (String.isNotBlank(matchedAccountId)) {
                        matchedAccountIds.add(matchedAccountId);
                        accountIdToinboubdIngestionLog.put(
                            matchedAccountId,
                            eachInboundIngestionLog.Id
                        );
                    }
                    if (String.isNotBlank(matchedContactId)) {
                        matchedContactIds.add(matchedContactId);
                        inboundIngestionLogIdToMatchedContactId.put(
                            eachInboundIngestionLog.Id,
                            matchedContactId
                        );
                    }
                    if (String.isNotBlank(matchedLeadId)) {
                        matchedLeadIds.add(matchedLeadId);
                        inboundIngestionLogIdToMatchedLeadId.put(
                            eachInboundIngestionLog.Id,
                            matchedLeadId
                        );
                    }
                    if (String.isNotBlank(falloutWrapper.addressVerificationInfo?.submarket?.id)) {
                        submarketIds.add(falloutWrapper.addressVerificationInfo?.submarket?.id);
                        logIdsToSubmarketIdValues.put(
                            eachInboundIngestionLog.Id,
                            falloutWrapper.addressVerificationInfo?.submarket?.id
                        );
                        logRecord = eachInboundIngestionLog;
                    }
                }
                Map<Id, Id> inboundIngestionLogIdToBusinessAccountId = getBusinessAccountIdsForMatchedAccounts(
                    matchedAccountIds,
                    accountIdToinboubdIngestionLog
                );
                inboundIngestionLogIdToSubmarketIds = getSubmarketRecordIds(
                    logIdToSSMOFalloutWrapper,
                    submarketIds,
                    logIdsToSubmarketIdValues,
                    logRecord
                );
                logIdToUuidMatchedLeadId = getLeadsByUniqueIdentifiers(sourceUniqueIdTologIds);
                getMatchedContactsByIds(matchedContactIds);
                getMatchedLeadsByIds(matchedLeadIds);
                processInboundIngestionLogs(
                    inboundIngestionLogRecords,
                    logIdToSSMOFalloutWrapper,
                    inboundIngestionLogIdToBusinessAccountId,
                    inboundIngestionLogIdToMatchedContactId,
                    inboundIngestionLogIdToMatchedLeadId
                );
            }
            catch (Exception e) {
                logError(inboundIngestionLogRecords, e, new Set<String>{},BUSINESS_ERROR_MESSAGE);
            }
        }
    }

    /**
     * @description It is used to process inbound ingestion logs for creation/updation of Lead or Contact.
     * @param inboundIngestionLogRecords
     * @param logIdToSSMOFalloutWrapper
     * @param inboundIngestionLogIdToBusinessAccountId
     * @param inboundIngestionLogIdToMatchedContactId
     * @param inboundIngestionLogIdToMatchedLeadId
     */
    private void processInboundIngestionLogs(
        List<Inbound_ingestion_Log__c> inboundIngestionLogRecords,
        Map<Id, SSMOFalloutWrapper> logIdToSSMOFalloutWrapper,
        Map<Id, Id> inboundIngestionLogIdToBusinessAccountId,
        Map<Id, Id> inboundIngestionLogIdToMatchedContactId,
        Map<Id, Id> inboundIngestionLogIdToMatchedLeadId
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Inbound_ingestion_Log__c> logs = new List<Inbound_ingestion_Log__c>();
        for (Inbound_ingestion_Log__c eachInboundIngestionLog : inboundIngestionLogRecords) {
            String existingleadId;
            String existingAccId;
            String existingconId;
            logs.add(eachInboundIngestionLog);
            SSMOFalloutWrapper falloutWrapper = logIdToSSMOFalloutWrapper.get(
                eachInboundIngestionLog.Id
            );
            existingleadId = inboundIngestionLogIdToMatchedLeadId.containsKey(
                    eachInboundIngestionLog.Id
                )
                ? inboundIngestionLogIdToMatchedLeadId.get(eachInboundIngestionLog.Id)
                : null;
            existingAccId = inboundIngestionLogIdToBusinessAccountId.containsKey(
                    eachInboundIngestionLog.Id
                )
                ? inboundIngestionLogIdToBusinessAccountId.get(eachInboundIngestionLog.Id)
                : null;
            existingconId = inboundIngestionLogIdToMatchedContactId.containsKey(
                    eachInboundIngestionLog.Id
                )
                ? inboundIngestionLogIdToMatchedContactId.get(eachInboundIngestionLog.Id)
                : null;
            upsertLead(
                existingleadId,
                existingAccId,
                existingconId,
                falloutWrapper,
                eachInboundIngestionLog
            );
            upsertContact(
                existingleadId,
                existingAccId,
                existingconId,
                falloutWrapper,
                eachInboundIngestionLog
            );
        }
        if(!upsertLeadList.isEmpty()){
            uow.registerUpsert(upsertLeadList);
        }
        if(!upsertContactList.isEmpty()){
            uow.registerUpsert(upsertContactList);
        }
        commitWork(uow, logs, upsertLeadList, upsertContactList);
    }

    /**
     * @description A common method to commit unit of work.
     * @param falloutWrapper
     * @return Id
     */
    private Id getExistingLeadIds(SSMOFalloutWrapper falloutWrapper) {
        String existingLeadId;
        if (
            !falloutWrapper?.matchedRecords?.lead.isEmpty() &&
            String.isNotEmpty(falloutWrapper?.matchedRecords?.lead[0]?.Id)
        ) {
            existingleadId = falloutWrapper.matchedRecords.lead[0].Id;
        }
        return existingLeadId;
    }

    /**
     * @description A common method to commit unit of work.
     * @param falloutWrapper
     * @return Id
     */
    private Id getExistingAccountIds(SSMOFalloutWrapper falloutWrapper) {
        String existingAccId;
        if (
            !falloutWrapper?.matchedRecords?.account.isEmpty() &&
            String.isNotEmpty(falloutWrapper?.matchedRecords?.account[0]?.Id)
        ) {
            existingAccId = falloutWrapper.matchedRecords.account[0].Id;
        }
        return existingAccId;
    }

    /**
     * @description A common method to commit unit of work.
     * @param falloutWrapper
     * @return Id
     */
    private Id getExistingContactIds(SSMOFalloutWrapper falloutWrapper) {
        String existingConId;
        if (
            !falloutWrapper?.matchedRecords?.contact.isEmpty() &&
            String.isNotEmpty(falloutWrapper?.matchedRecords?.contact[0]?.Id)
        ) {
            existingconId = falloutWrapper.matchedRecords.contact[0].Id;
        }
        return existingConId;
    }

    /**
     * @description A common method to commit unit of work.
     * @param existingleadId
     * @param existingAccId
     * @param existingconId
     * @param falloutWrapper
     * @param inboundLog
     */
    private void upsertContact(
        String existingleadId,
        String existingAccId,
        String existingconId,
        SSMOFalloutWrapper falloutWrapper,
        Inbound_ingestion_Log__c inboundLog
    ) {
        Id submarketId = getMapValueFromKey(inboundIngestionLogIdToSubmarketIds, inboundLog.Id);
        if (
            String.isNotEmpty(existingconId) &&
            !matchedContact.isEmpty() &&
            matchedContact.containsKey(existingconId)
        ) {
            Contact objContact = matchedContact.get(existingconId);
            objContact.Inbound_Ingestion_Log__c = inboundLog.Id;
            objContact.SSMO_Business_Account_Id__c = String.isNotEmpty(existingaccId)
                ? existingaccId
                : '';
            objContact.Submarket__c = (submarketId != null) ? submarketId : objContact.Submarket__c;
            objContact = SSMOContactCreationService.updateContactSSMO(falloutWrapper, objContact);
            upsertContactList.add(objContact);
        }
        if (String.isNotEmpty(existingaccId) && String.isEmpty(existingconId)) {
            Contact objContact = new Contact(Inbound_Ingestion_Log__c = inboundLog.Id);
            objContact.SSMO_Business_Account_Id__c = existingaccId;
            objContact.Submarket__c = submarketId;
            objContact = SSMOContactCreationService.insertContactSSMO(falloutWrapper, objContact);
            objContact = SSMOContactCreationService.updateContactSSMO(falloutWrapper, objContact);
            upsertContactList.add(objContact);
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param existingleadId
     * @param existingAccId
     * @param existingconId
     * @param falloutWrapper
     * @param inboundLog
     */
    private void upsertLead(
        String existingleadId,
        String existingAccId,
        String existingconId,
        SSMOFalloutWrapper falloutWrapper,
        Inbound_ingestion_Log__c inboundLog
    ) {
        Id submarketId = getMapValueFromKey(inboundIngestionLogIdToSubmarketIds, inboundLog.Id);
        Id uuidMatchedLeadId = getMapValueFromKey(logIdToUuidMatchedLeadId, inboundLog.Id);
        if (
            insertLeadOrUpdateLeadCheck(existingaccId,existingconId,existingleadId,uuidMatchedLeadId,UPDATE_CONTEXT)
        ) {
            Lead objLead = new Lead();
            if(matchedLeads.containsKey(existingleadId)){
                objLead = matchedLeads.get(existingleadId);
            }
            else{
                objLead.Id = uuidMatchedLeadId;
            }
            objLead.Inbound_Ingestion_Log__c = inboundLog.Id;
            objLead.Submarket__c = (submarketId != null) ? submarketId : objLead.Submarket__c;
            objLead = SSMOLeadCreationService.updateLead(falloutWrapper, objLead);
            upsertLeadList.add(objLead);
        }
        if (
            insertLeadOrUpdateLeadCheck(existingaccId,existingconId,existingleadId,uuidMatchedLeadId,INSERT_CONTEXT)
        ) {
            Lead objLead = new Lead(
                Status = LEAD_STATUS_UNTOUCHED,
                LeadSource = LEAD_SOURCE,
                Inbound_Ingestion_Log__c = inboundLog.Id,
                Duplicate_Status__c = NON_DUPLICATE_LEAD_STATUS,
                Submarket__c = submarketId
            );
            objLead = SSMOLeadCreationService.insertLead(falloutWrapper, objLead, queueId);
            objLead = SSMOLeadCreationService.updateLead(falloutWrapper, objLead);
            upsertLeadList.add(objLead);
        }
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     * @param inboundIngestionLogRecords
     * @param upsertLeads
     * @param upsertContacts
     */
    private static void commitWork(
        fflib_ISObjectUnitOfWork unitOfWork,
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords,
        List<Lead> upsertLeads,
        List<Contact> upsertContacts
    ) {
        Set<String> recordIds = new Set<String>();

        try {
            unitOfWork.commitWork();
            if (upsertLeads != null && !upsertLeads.isEmpty()) {
                recordIds.addAll(
                    (List<String>) new List<Id>(new Map<Id, Lead>(upsertLeads).keySet())
                );
            }
            if (upsertContacts != null && !upsertContacts.isEmpty()) {
                recordIds.addAll(
                    (List<String>) new List<Id>(new Map<Id, Contact>(upsertContacts).keySet())
                );
            }
        } catch (Exception e) {
            isCountryStateExceptionValidation(upsertContacts,
            upsertLeads,
            e,
            inboundIngestionLogRecords,
            recordIds);

        }
    }

    /**
     * @description It is used to get the Business Account Ids from Matched Account ids.
     * @param matchedAccountIds
     * @param accountIdToinboubdIngestionLog
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getBusinessAccountIdsForMatchedAccounts(
        Set<Id> matchedAccountIds,
        Map<Id, Id> accountIdToinboubdIngestionLog
    ) {
        Map<Id, Id> inboundIngestionLogIdToBusinessAccountId = new Map<Id, Id>();
        if (!matchedAccountIds.isEmpty()) {
            inboundIngestionLogIdToBusinessAccountId = getBusinessAccountIdsForMatchedStoreAccounts(
                matchedAccountIds,
                accountIdToinboubdIngestionLog
            );
        }
        return inboundIngestionLogIdToBusinessAccountId;
    }
    /**
     * @description It is used to get the Business Account Ids for matched Store Account Ids.
     * @param matchedAccountIds
     * @param accountIdToinboubdIngestionLog
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getBusinessAccountIdsForMatchedStoreAccounts(
        Set<Id> matchedAccountIds,
        Map<Id, Id> accountIdToinboubdIngestionLog
    ) {
        Map<Id, Id> inboundIngestionLogIdToBusinessAccountId = new Map<Id, Id>();
        Set<Id> storeAccountIds = new Set<Id>();

        for (Account eachAccount : AccountsSelector.newInstance().selectById(matchedAccountIds)) {
            if (eachAccount.Record_Type_Name__c == BUSINESS) {
                inboundIngestionLogIdToBusinessAccountId.put(
                    accountIdToinboubdIngestionLog.get(eachAccount.Id),
                    eachAccount.Id
                );
            } else if (
                eachAccount.Record_Type_Name__c == STORE &&
                eachAccount.Activation_Status__c == ACTIVE_STATUS
            ) {
                storeAccountIds.add(eachAccount.Id);
            } else if (
                eachAccount.Record_Type_Name__c == STORE &&
                eachAccount.Activation_Status__c == INACTIVE_STATUS
            ) {
                inboundIngestionLogIdToBusinessAccountId.put(
                    accountIdToinboubdIngestionLog.get(eachAccount.Id),
                    eachAccount.ParentId
                );
            }
        }
        if (!storeAccountIds.isEmpty()) {
            for (
                Agreement__c eachAggrement : AgreementsSelector.newInstance()
                    .selectAgreementsByAccountsIds(storeAccountIds)
            ) {
                inboundIngestionLogIdToBusinessAccountId.put(
                    accountIdToinboubdIngestionLog.get(eachAggrement.Account__c),
                    eachAggrement.Contract__r.AccountId
                );
            }
        }
        return inboundIngestionLogIdToBusinessAccountId;
    }
    /**
     * @description It is used to get the existing contact records by matched Contact Ids.
     * @param matchedContactIds
     */
    private void getMatchedContactsByIds(Set<Id> matchedContactIds) {
        if (!matchedContactIds.isEmpty()) {
            matchedContact = new Map<Id, Contact>(
                ContactsSelector.newInstance().selectById(matchedContactIds)
            );
        }
    }
    /**
     * @description It is used to get the existing Lead records by matched lead Ids.
     * @param matchedLeadIds
     */
    private void getMatchedLeadsByIds(Set<Id> matchedLeadIds) {
        if (!matchedLeadIds.isEmpty()) {
            matchedLeads = new Map<Id, Lead>(
                LeadsSelector.newInstance().selectById(matchedLeadIds)
            );
        }
    }
    /**
     * @description It is used to get existing submarket records and insert new submarkets based on submarket Id values.
     * @param logIdToSSMOFalloutWrapper
     * @param submarketIds
     * @param logIdsToSubmarketIdValues
     * @param logRecord
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getSubmarketRecordIds(
        Map<Id, SSMOFalloutWrapper> logIdToSSMOFalloutWrapper,
        Set<String> submarketIds,
        Map<Id, String> logIdsToSubmarketIdValues,
        Inbound_Ingestion_Log__c logRecord
    ) {
        Map<Id, Id> logIdToSubmarketIdMap = new Map<Id, Id>();
        if (!submarketIds.isEmpty()) {
            Map<String, Id> submarketIdValueToId = new Map<String, Id>();
            for (
                Submarket__c eachSubmarket : SubmarketsSelector.newInstance()
                    .getSubmarketsByIds(submarketIds)
            ) {
                if (!submarketIdValueToId.containsKey(eachSubmarket.Submarket_ID__c)) {
                    submarketIdValueToId.put(eachSubmarket.Submarket_ID__c, eachSubmarket.Id);
                }
            }
            logIdToSubmarketIdMap = getSubmarketIdsForEachInboundLog(
                logIdToSSMOFalloutWrapper,
                submarketIdValueToId,
                logIdsToSubmarketIdValues,
                logRecord
            );
        }
        return logIdToSubmarketIdMap;
    }
    /**
     * @description It is used to get existing submarket records and insert new submarkets based on submarket Id values.
     * @param logIdToSSMOFalloutWrapper
     * @param submarketIdValueToId
     * @param logIdsToSubmarketIdValues
     * @param logRecord
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getSubmarketIdsForEachInboundLog(
        Map<Id, SSMOFalloutWrapper> logIdToSSMOFalloutWrapper,
        Map<String, Id> submarketIdValueToId,
        Map<Id, String> logIdsToSubmarketIdValues,
        Inbound_Ingestion_Log__c logRecord
    ) {
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        List<Submarket__c> submarketRecordsToBeCreated = new List<Submarket__c>();
        Map<String, Id> submarketIdValueToLogId = new Map<String, Id>();
        Map<Id, Id> logIdToSubmarketIdMap = new Map<Id, Id>();
        for (Id eachLogId : logIdToSSMOFalloutWrapper.keySet()) {
            if (
                logIdsToSubmarketIdValues.containsKey(eachLogId) &&
                submarketIdValueToId.containsKey(logIdsToSubmarketIdValues.get(eachLogId))
            ) {
                logIdToSubmarketIdMap.put(
                    eachLogId,
                    submarketIdValueToId.get(logIdsToSubmarketIdValues.get(eachLogId))
                );
            } else if (
                logIdsToSubmarketIdValues.containsKey(eachLogId) &&
                !submarketIdValueToId.containsKey(logIdsToSubmarketIdValues.get(eachLogId))
            ) {
                SubMarket__c newSubMarket = createNewSubmarket(logIdToSSMOFalloutWrapper,eachLogId);
                submarketRecordsToBeCreated.add(newSubMarket);
                submarketIdValueToLogId.put(newSubMarket.Submarket_ID__c, eachLogId);
            }
        }
        if (!submarketRecordsToBeCreated.isEmpty()) {
            unitOfWork.registerNew(submarketRecordsToBeCreated);
            try {
                unitOfWork.commitWork();
                for (SubMarket__c eachSubmarket : submarketRecordsToBeCreated) {
                    logIdToSubmarketIdMap.put(
                        submarketIdValueToLogId.get(eachSubmarket.Submarket_ID__c),
                        eachSubmarket.Id
                    );
                }
            } catch (Exception ex) {
                IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                    LOG_SELF_SERVING_FALLOUT_SERVICE,
                    LOG_SALES_DOMAIN,
                    logRecord?.Id,
                    logRecord?.UUID__c,
                    logRecord?.Unique_Id__c
                );
                InboundIngestionLoggerService.logException(
                    loggerEntry,
                    ex,
                    SUBMARKET_FAILED_BUSINESS_ERROR_MESSAGE,
                    '',
                    new Set<String>{},
                    ex.getTypeName()
                );
            }
        }
        return logIdToSubmarketIdMap;
    }

    /**
     * @description It is used to get the existing Lead records by UUIDs.
     * @param sourceUniqueIdTologIds
     * @return Map<Id,Id>
     */
    private Map<Id, Id> getLeadsByUniqueIdentifiers(Map<String, Id> sourceUniqueIdTologIds) {
        Map<Id, Id> logIdToUuidMatchedLeadId = new Map<Id, Id>();
        if (!sourceUniqueIdTologIds.isEmpty()) {
            for (Lead eachLead : LeadsSelector.newInstance().selectByUniqueIdentifiers(sourceUniqueIdTologIds.keySet())) {
                logIdToUuidMatchedLeadId.put(
                    sourceUniqueIdTologIds.get(eachLead.SSMO_UUID__c),
                    eachLead.Id
                );
            }
        }
        return logIdToUuidMatchedLeadId;
    }

    /**
     * @description It is used to check if the map contains the key and get its value.
     * @param mapToFindKeyValue
     * @param key
     * @return Id
     */
    private Id getMapValueFromKey(Map<Id, Id> mapToFindKeyValue, Id key) {
        Id value = mapToFindKeyValue.containsKey(key) ? mapToFindKeyValue.get(key) : null;
        return value;
    }

    /**
     * @description It is used to check for insert or update criteria for lead.
     * @param existingaccId
     * @param existingconId
     * @param existingleadId
     * @param uuidMatchedLeadId
     * @param context
     * @return Boolean
     */
    private Boolean insertLeadOrUpdateLeadCheck(String existingaccId,
        String existingconId,
        String existingleadId,
        Id uuidMatchedLeadId,
        String context
        ) {
        Boolean result = false;
        if(context == UPDATE_CONTEXT){
            result =  (String.isEmpty(existingaccId) &&
            ((String.isNotEmpty(existingleadId) &&
            !matchedLeads.isEmpty() &&
            matchedLeads.containsKey(existingleadId))
            || uuidMatchedLeadId != null));
        }
        else if(context == INSERT_CONTEXT){
            result = (String.isEmpty(existingaccId)
            && String.isEmpty(existingleadId) &&
            uuidMatchedLeadId == null);
        }
        return result;
    }
    /**
     * @description It is used to create new submarket.
     * @param logIdToSSMOFalloutWrapper
     * @param eachLogId
     * @return SubMarket__c
     */
    private SubMarket__c createNewSubmarket(Map<Id, SSMOFalloutWrapper> logIdToSSMOFalloutWrapper,Id eachLogId) {
        SSMOFalloutWrapper eachSSMOFalloutWrapper = logIdToSSMOFalloutWrapper.get(
            eachLogId
        );
        SubMarket__c newSubMarket = new SubMarket__c();
        newSubMarket.Name = eachSSMOFalloutWrapper.addressVerificationInfo?.submarket?.name;
        newSubMarket.Submarket_ID__c = eachSSMOFalloutWrapper.addressVerificationInfo
            ?.submarket
            ?.id;
        newSubMarket.Status__c = STATUS_VERIFIED;
        return newSubMarket;
    }
    /**
     * @description It is used to Update logs and log Error.
     * @param inboundIngestionLogRecords
     * @param ex
     * @param recordIds
     * @param errorMessage
     */
    private static void logError(
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords,
        Exception ex,
        Set<String> recordIds,
        String errorMessage
    ) {
        Set<Id> setLogIds = (new Map<Id, Inbound_Ingestion_Log__c>(inboundIngestionLogRecords))
            .keySet();
        InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
            setLogIds,
            FAILED,
            ex.getMessage(),
            ex.getStackTraceString(),
            errorMessage
        );
        IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
            LOG_SELF_SERVING_FALLOUT_SERVICE,
            LOG_SALES_DOMAIN,
            inboundIngestionLogRecords[0].Id,
            inboundIngestionLogRecords[0].UUID__c,
            inboundIngestionLogRecords[0].Unique_Id__c
        );
        InboundIngestionLoggerService.logException(
            loggerEntry,
            ex,
            errorMessage,
            '',
            recordIds,
            ex.getTypeName()
        );
    }

    /**
     * @description It is used to check for country or state error message.
     * @param upsertLeads
     * @param errorMessage
     * @return Boolean
     */
    private static Boolean isCountryStateExceptionForLeadCheck(
        List<lead> upsertLeads,
        String errorMessage
    ) {
        Boolean isCountryStateExceptionForLead = false;
        if (
            !upsertLeads.isEmpty() &&
            ((errorMessage.contains(INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST) &&
            errorMessage.contains(COUNTRY)) ||
            errorMessage.contains(INVALID_STATE_ERROR_MESSAGE))
        ) {
            isCountryStateExceptionForLead = true;
        }
        return isCountryStateExceptionForLead;
    }
    /**
     * @description It is used to validate Country State exception for Leads.
     * @param upsertContacts
     * @param leadRecords
     * @param e
     * @param inboundIngestionLogRecords
     * @param recordIds
     */
    private static void isCountryStateExceptionValidation(
        List<Contact> upsertContacts,
        List<Lead> leadRecords,
        Exception e,
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords,
        Set<String> recordIds) {
        try {
            if (isCountryStateExceptionForLeadCheck(leadRecords, e.getMessage())) {
                fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                for (Lead eachLead : leadRecords) {
                    eachLead.Street = null;
                    eachLead.City = null;
                    eachLead.State = null;
                    eachLead.StateCode = null;
                    eachLead.Country = null;
                    eachLead.CountryCode = null;
                    eachLead.PostalCode = null;
                    uow.registerUpsert(eachLead);
                }
                uow.registerUpsert(upsertContacts);
                uow.commitWork();
            } else {
                logError(inboundIngestionLogRecords, e, recordIds, LEAD_BUSINESS_ERROR_MESSAGE);
            }
        } catch (Exception ex) {
            logError(inboundIngestionLogRecords, ex, recordIds, LEAD_BUSINESS_ERROR_MESSAGE);
        }
    }
}