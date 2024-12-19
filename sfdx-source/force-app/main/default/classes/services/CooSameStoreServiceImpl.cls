/**
 * @author DoorDash
 * @date 05/03/2023
 * @description Service class for processing coo same store requests.
 * TDD: https://docs.google.com/document/d/1VERX0bkRg71SKOxPh6MLoqKiVLkyOhH06Qb79IIoS34/edit#
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class CooSameStoreServiceImpl implements ICooSameStoreService{
    private static final String EVENT_TOPIC_PROCESS_COO_SAME_STORE = 'PROCESS_COO_SAME_STORE';
    private static final String CREATED = 'created';
    private static final String COMPLETED = 'completed';
    private static final String CANCELLED = 'cancelled';
    private static final String PENDING = 'Pending';
    private static final String PROCESSED = 'Processed';
    private static final String READY = 'ready';
    private static final String STAGE_NAME_CLOSED_WON = 'Closed Won';
    private static final String STAGE_NAME_CLOSED_LOST = 'Closed Lost';
    private static final String SUB_TYPE_COO = 'COO';
    private static final String TYPE_FRANCHISE = 'Franchise';
    private static final String TYPE_CORPORATE = 'Corporate';
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';
    private static final Set<String> PAYMENT_ACCOUNT_RECORD_TYPES = new Set<String>{'Invoice', 'Payments'};
    private static final String INTEGRATION_TYPE_COO_SAME_STORE = 'COO Same Store';
    private List<Integration_Request__c> pendingNewReq = new List<Integration_Request__c>();
    private Map<String, Id> batchIdToOppId = new Map<String, Id>();
    private Set<String> providerTypes = IntegrationRequests.getPosProviderTypes();
    private static final String ORDER_PROTOCOL_EMAIL = 'EMAIL';
    private static final String ORDER_PROTOCOL_POS = 'POINT_OF_SALE';
    private static final String ACCOUNT_ORDER_PROTOCOL_EMAIL = 'Email';
    private static final Set<String> WO_OPEN_STATUS = new Set<String>{'Planning', 'Confirmed', 'In Progress', 'At Risk', 'Past Due', 'Not Started'};
    private static final Set<String> TYPE_COO = new Set<String>{'COO'};
    private static final Set<String> SUB_TYPE_COO_SAME_STORE = new Set<String>{'COO Same Store'};
    private static final String GENERIC_LOG_SERVICE_COO_SAME_STORE = 'COO Same Store Service';
    private static final String MATCHED_WITH_EXISTING_BUSINESS_ACCOUNT  = 'Matched with the existing business account';
    private static final String CREATED_A_NEW_BUSINESS_ACCOUNT = 'Created a new business account';
    //LEM-16130
    private static final String TYPE_FRANCHISEE = 'Franchisee';
    private static final String FUZZY_MATCHED_WITH_EXISTING_BUSINESS_ACCOUNT = 'Fuzzy Matched with existing business account';
    private static final String DUPLICATE_RULE_TO_BE_EXECUTED_FOR_FUZZY_MATCH = 'Account_Low_Complexity_Duplicate_Rule';
    private static final Decimal CONFIDENCE_THRESHOLD = 50.0;
    private static Map<Id, String> integrationReqIdToBusinessAccMatchReasonMap  = new Map <Id, String>();

    private enum EventTopics {
        EVENT_TOPIC_PROCESS_COO_SAME_STORE
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_PROCESS_COO_SAME_STORE => EventTopics.EVENT_TOPIC_PROCESS_COO_SAME_STORE
    };
    CooTransactionsDto dto;
    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
    /**
    * @description This method handles the events from the Notifier platform event.
    * Sends the grouped events to the appropriate handler for further processing.
    * @param events a list of Notifier__e objects representing the events to be processed.
    */
    public void handleNotifierEvents(List<Notifier__e> events){
        Set<String> batchIdsFromPayload = new Set<String>();
        Savepoint savePointBeforeProcessing = Database.setSavepoint();
        try {
            Set<String> batchIdsFromEachPayload = new Set<String>();
            for (Notifier__e eachEvent : events) {
                switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                    when EVENT_TOPIC_PROCESS_COO_SAME_STORE {
                        batchIdsFromEachPayload = (Set<String>)JSON.deserialize(eachEvent.Payload__c, Set<String>.class);
                        batchIdsFromPayload.addAll(batchIdsFromEachPayload);
                    }
                }
            }
            if(batchIdsFromPayload.size()>0){
                processCooSameStoreRequests(batchIdsFromPayload);
            }
        } catch (Exception ex) {
            Database.rollback(savePointBeforeProcessing);
            String message = 'Batch Ids '+batchIdsFromPayload + '  '+ex;
            ex.setMessage(message);
            Logger.publish( LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH) );
        }
    }
    /**
     * @description Processes the COO (Change of Ownership) requests based on the provided batch IDs.
     * @param cooBatchIds  A Set of batch IDs.
     */
    public void processCooSameStoreRequests(Set<String> cooBatchIds){
        List<Integration_Request__c> intReqByBatch = getIntegrationRequests(cooBatchIds);
        processNewCooRequests(intReqByBatch, cooBatchIds);
        processCancelledCooRequests(intReqByBatch);
        processReadyCooRequests(intReqByBatch);
        processCompletedCooRequests(intReqByBatch);
        createLog(cooBatchIds);
    }

    /**
     * @description Processes the new Integration_Request__c records by Batch
     * Create single opportunity for each batch Id.
     * @param intReqByBatch  A List of Integration_Request__c records.
     * @param batchIds  A Set of batch IDs.
     */
    @testVisible
    private void processNewCooRequests(List<Integration_Request__c> intReqByBatch, Set<String> batchIds){
         createOpportunity(intReqByBatch,batchIds);
         updateNewIntRequestsAndAccount(pendingNewReq);
         createUpdateWorkOrder( pendingNewReq, batchIdToOppId);
    }

    /**
     * @description Create single opportunity for each batch Id.
     * @param intReqByBatch  A List of Integration_Request__c records.
     * @param batchIds  A Set of batch IDs.
     */
    @testVisible
    private void createOpportunity(List<Integration_Request__c> intReqByBatch, Set<String> batchIds){
        //collect opportunities by batch id
        Set<Opportunity> newOpps = new Set<Opportunity>();
        for(Integration_Request__c eachIr: intReqByBatch){
            if(eachIr.Opportunity__c != null && eachIr.Opportunity__r.Batch_Id__c != null){
                batchIdToOppId.put(eachIr.Opportunity__r.Batch_Id__c, eachIr.Opportunity__c);
            }
        }
        // Filter new Integration_Request__c records with created product status and pending SFDC status
        pendingNewReq = IntegrationRequests.newInstance(intReqByBatch)
            .filterByProductStatus(CREATED).filterBySfdcStatus(PENDING).getRecords();
        getNewOpportunity(newOpps, pendingNewReq, batchIdToOppId);
        uow.registerNew(new List<Opportunity>(newOpps));
        uow.commitWork();
        for(opportunity eachOpp: newOpps){
            batchIdToOppId.put(eachOpp.Batch_Id__c, eachOpp.Id);
        }
    }

    /**
     * @description Update the new Integration request to Processed
     * update the store account with the Parent Integration request
     * @param pendingNewReq  A List of Integration_Request__c records.
     */
    @testVisible
    private void updateNewIntRequestsAndAccount(List<Integration_Request__c> pendingNewReq){
        uow = Application.UnitOfWork.newInstance();
        for(Integration_Request__c eachIr: pendingNewReq){
            eachIr.sfdc_status__c = PROCESSED;
            eachIr.Stage__c = eachIr.Product_Status__c;
            eachIr.Stage_Status__c =  PROCESSED;
            eachIr.opportunity__c = batchIdToOppId.get(eachIr.Batch_Id__c);
            uow.registerDirty(eachIr);
            if(eachIr.Parent_Integration_Request__c == null){
                Account acc = new Account(
                   Id = eachIr.Account__c,
                   Integration_Request__c  = eachIr.Id,
                   Change_of_Ownership_Effective_Date__c = eachIr.Activation_Date__c
               );
                uow.registerDirty(acc);
            }
        }
         uow.commitWork();
    }

    /**
     * @description create/update the parent workorder
     * @param pendingNewReq  A List of Integration_Request__c records.
     * @param batchIdToOppId  A Map pf batchIDToOpportunityID
     */
    @testVisible
    private void createUpdateWorkOrder(List<Integration_Request__c> pendingNewReq, Map<String, Id> batchIdToOppId){
        if(!pendingNewReq.isEmpty()){
            CooWorkOrderService.createUpdateParentWorkOrder(pendingNewReq, batchIdToOppId);
        }
    }

    private void getNewOpportunity(Set<Opportunity> newOpps, List<Integration_Request__c> pendingNewReq, Map<String, Id> batchIdToOppId){
        for(Integration_Request__c eachIr: pendingNewReq){
            Boolean oppExists = batchIdToOppId.containsKey(eachIr.Batch_Id__c) ? true :false;
             if(!oppExists){
                opportunity cooOpp = new opportunity(
                    AccountId = eachIr.Account__r.parentId,
                    StageName = 'Pitching',
                    Description__c = 'Coo Same Store',
                    Type = 'Existing',
                    Source__c = 'Product',
                    Batch_Id__c = eachIr.Batch_Id__c,
                    Opportunity_Sub_Type__c = SUB_TYPE_COO,
                    CloseDate = getActivationDate(eachIr.Activation_Date__c)
                );
                newOpps.add(cooOpp);
            }
        }
    }

    /**
     * @description Processes the cancelled Integration_Request__c records. If all the int req are cancelled
     * for that batch closed lost the opportunity.
     * @param intReqByBatch  A List of Integration_Request__c records.
     */
    @testVisible
    private void processCancelledCooRequests(List<Integration_Request__c> intReqByBatch){
        List<Integration_Request__c> pendingCancelledCooRequests = IntegrationRequests.newInstance(intReqByBatch).
            filterByProductStatus(CANCELLED).filterBySfdcStatus(PENDING).getRecords();
        // Filter batch Ids of Integration_Request__c records not in specified product status
        Set<String> batchIdsOppToNotCancel = IntegrationRequests.newInstance(intReqByBatch).
            filterBatchIdsIrNotInProductStatus(new set<String>{CANCELLED});

        Map<String,Id> batchIdToOpportunityId = new Map<String,Id>();
        List<Integration_Request__c> cancelledCooRequestForaSingleStore = new List<Integration_Request__c>();

        for(Integration_Request__c eachIr: pendingCancelledCooRequests){
            eachIr.sfdc_status__c = PROCESSED;
            String oppId = eachIr.Parent_Integration_Request__r.opportunity__c;
            if(!batchIdsOppToNotCancel.contains(eachIr.batch_Id__c) && string.isNotBlank(oppId)){
                Opportunity cancelOpp = new Opportunity(
                    Id = oppId,
                    StageName = STAGE_NAME_CLOSED_LOST
                );
                batchIdToOpportunityId.put(eachIr.batch_Id__c, eachIr.Parent_Integration_Request__r.opportunity__c);
                uow.registerDirty(cancelOpp);
            }else{
                cancelledCooRequestForaSingleStore.add(eachIr);
            }
            uow.registerDirty(eachIr);
        }
        uow.commitWork();

        if (!cancelledCooRequestForaSingleStore.isEmpty() || !batchIdToOpportunityId.isEmpty()){
            CooWorkOrderService.updateWorkOrderToDead(cancelledCooRequestForaSingleStore, batchIdToOpportunityId);
        }
    }

    /**
     * @description Processes the completed Integration_Request__c records within the batch.
     * @param intReqByBatch  A List of Integration_Request__c records.
     */
    @testVisible
    private void processCompletedCooRequests(List<Integration_Request__c> intReqByBatch){
        List<Integration_Request__c> pendingCompletedCooReq = new List<Integration_Request__c>();
        // process completed integration requests only if initial created request processed.
        for(Integration_Request__c eachIr: intReqByBatch){
            if(eachIr.Parent_Integration_Request__c != null
               && PROCESSED.equalsIgnoreCase(eachIr.Parent_Integration_Request__r.SFDC_status__c)
               && COMPLETED.equalsIgnoreCase(eachIr.product_status__c)
               && PENDING.equalsIgnoreCase(eachIr.SFDC_status__c)){
               pendingCompletedCooReq.add(eachIr);
            }
        }
        if(!pendingCompletedCooReq.isEmpty()){
            Map<Id, Id> intIdToBusinessActId = findOrCreateBusinessAccount(pendingCompletedCooReq);
            // create or update new contacts for store and business account and deactivate existing store accounts.
            handleContacts(pendingCompletedCooReq, intIdToBusinessActId);
            Map<Id, Id> intIdToBusinessRefId = findOrCreateBusinessReference(pendingCompletedCooReq, intIdToBusinessActId);
            updateXrefWithLatestBusinessRefId(pendingCompletedCooReq, intIdToBusinessRefId);
            updateOpportunityToClosedWon(intIdToBusinessActId, intReqByBatch);
            reparentTheStore(pendingCompletedCooReq, intIdToBusinessActId);
            deletePaymentAccountRelation(pendingCompletedCooReq);
        }
        if (!pendingCompletedCooReq.isEmpty()) {
             CooWorkOrderService.updateWorkOrderToComplete(pendingCompletedCooReq);
        }
    }

    /**
     * @description Finds or creates the Business Account records based on the completed Integration_Request__c records.
     * search for existing accounts based on Legal business Name and address and create if doesn't exists.
     * Only on business accounts will be created for int batch Id.
     * @param completedCooReq  A List of completed Integration_Request__c records.
     * @return  Map<Id, Id> A Map of Integration_Request__c record IDs to Business Account record IDs.
     */
    @testVisible
    private Map<Id, Id> findOrCreateBusinessAccount(List<Integration_Request__c> completedCooReq){
        Set<String> accountNames = new Set<String>();
        Map<Id, Id> intToAccountId = new Map<Id, Id>();
        Set<String> addressIds = new Set<String>();
        Map<String, Id> accountNameToAccountIdMap = new Map<String, Id>();
        Map<String, Id> addressIdToAccountIdMap = new Map<String, Id>();
        List<Account> acts = new List<Account>();
        //replace selector
        for(Integration_Request__c eachIr: completedCooReq){
            accountNames.add(dto.getLegalBusinessName(eachIr.Id));
            addressIds.add(dto.getBusinessAddressId(eachIr.Id));
        }
        acts = AccountsSelector.newInstance().selectBusinessAccountsWithNameAndAddressId(accountNames, addressIds);
        acts = acts == null ? new List<Account>() : acts;
        // Populate the accountNameToAccountIdMap and addressIdToAccountIdMap with the account
        // names and address IDs, and corresponding account IDs
        for(Account eachAccount: acts){
            accountNameToAccountIdMap.put(eachAccount.Name, eachAccount.Id);
            addressIdToAccountIdMap.put(eachAccount.Address_Id__c, eachAccount.Id);
        }
        // using set to avoid duplciates if there are multiple int request for same batch Id.
        Set<Account> newBusinessAccounts = new Set<Account>();
        //Iterate through completedCooReq to check if Business Account records need to be created
        for(Integration_Request__c eachIr: completedCooReq){
            if(!foundAccount(eachIr.Id, accountNameToAccountIdMap, addressIdToAccountIdMap, intToAccountId)){
                Account act = createBusinessAccount(eachIr);
                newBusinessAccounts.add(act);
            }
        }
        uow.registerNew(new List<Account>(newBusinessAccounts));
        uow.commitWork();
        acts.addAll(newBusinessAccounts);
        Map<String, Id> actNameToactIdMap = new Map<String, Id>();
        Map<String, Id> addressIdToactIdMap = new Map<String, Id>();
        // Populate the actNameToactIdMap and addressIdToactIdMap with the account names and address IDs,
        //and corresponding account IDs
        for(Account act: acts){
            actNameToactIdMap.put(act.Name, act.Id);
            addressIdToactIdMap.put(act.Address_ID__c, act.Id);
        }
        for(Integration_Request__c eachIr: completedCooReq){
            String accountId = getAccountId(eachIr.Id, actNameToactIdMap, addressIdToactIdMap);
            //LEM-16130
            if(String.isNotBlank(accountId)){
                intToAccountId.put(eachIr.Id, accountId);
            }
        }
        uow = Application.UnitOfWork.newInstance();
        return intToAccountId;
    }
    private String getAccountId(Id intId, Map<String, Id> actNameToactIdMap, Map<String, Id> addressIdToactIdMap){
        String legalBusinessName = dto.getLegalBusinessName(intId);
        String addressId = dto.getBusinessAddressId(intId);
        String accountId = actNameToactIdMap.containsKey(legalBusinessName) ?
            actNameToactIdMap.get(legalBusinessName) : addressIdToactIdMap.get(addressId);
        return accountId;
    }

    private Boolean foundAccount(Id intId, Map<String, Id> accountNameToAccountIdMap, Map<String, Id> addressIdToAccountIdMap, Map<Id, Id> intToAccountId){
        String legalBusinessName = dto.getLegalBusinessName(intId);
        Boolean accountFound = accountNameToAccountIdMap.containsKey(legalBusinessName) ? true : false;
        accountFound = addressIdToAccountIdMap.containsKey(dto.getBusinessAddressId(intId)) ? true : accountFound;
        //LEM-16130
        if(!accountFound){
            Account acct = dto.getAccountForFuzzyMatch(intId);
            acct.Type = getFranchiseeAccountType(intId);
            Id fuzzyAccountId = findFuzzyAccountMatch(acct);
            if(fuzzyAccountId != null){
                intToAccountId.put(intId, fuzzyAccountId);
                integrationReqIdToBusinessAccMatchReasonMap.put(intId, FUZZY_MATCHED_WITH_EXISTING_BUSINESS_ACCOUNT);
                return true;
            }
        }
        else{
            integrationReqIdToBusinessAccMatchReasonMap.put(intId, MATCHED_WITH_EXISTING_BUSINESS_ACCOUNT);
        }
        return accountFound;
    }
    /**
     * @description Utilises the Account_Low_Complexity_Duplicate_Rule and checks whether the account info present in IR's payload fuzzy matches (returned confidence > 50%) with an existing account in the database
     * @param acct  Account instance created with the IR's payload's legal_business_name, legal_business_address street & postal_code and isFranchise details
     * @return Id Record Id of the fuzzy matched account
     * @jira #LEM-16130
     */
    private Id findFuzzyAccountMatch(Account acct){
        Id matchedActId;
        Decimal mrRecConfidence = 0.0;
        for(Datacloud.FindDuplicatesResult dupRes : Datacloud.FindDuplicates.findDuplicates(new List<Account>{acct})){
            for(Datacloud.DuplicateResult dr : dupRes.duplicateresults){
                if(dr.getDuplicateRule() != DUPLICATE_RULE_TO_BE_EXECUTED_FOR_FUZZY_MATCH){
                    continue;
                }
                for(Datacloud.MatchResult mr : dr.getMatchResults()){
                    for(Datacloud.MatchRecord mrRec : mr.getMatchRecords()){
                        //Handled the possibility of multiple records returning more than 50% confidence
                        Boolean isMatched = (mrRec.getMatchConfidence() > CONFIDENCE_THRESHOLD && mrRec.getMatchConfidence() > mrRecConfidence);
                        if(!isMatched){
                            continue;
                        }
                        matchedActId = mrRec.getMatchConfidence() != mrRecConfidence ? mrRec.getRecord().Id : matchedActId;
                        mrRecConfidence = mrRec.getMatchConfidence();
                    }
                }
            }
        }
        return matchedActId;
    }

    private Account createBusinessAccount(Integration_Request__c eachIr){
        String accountType = getFranchiseeAccountType(eachIr.Id);
        String actName = dto.getLegalBusinessName(eachIr.Id);
        String addressId = dto.getBusinessAddressId(eachIr.Id);
        Account act = new Account(Type = accountType,
            Name = actName,
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            DoorDash_Legal_Entity__c = 'DoorDash, Inc.',
            Partnership_Status__c = 'Existing partner',
            Primary_Vertical__c = eachIr.Account__r.Primary_Vertical__c,
            Creation_Source__c = 'Integration',
            Address_ID__c = addressId,
            Segment__c = eachIr.Account__r.Segment__c,
            CurrencyIsoCode = eachIr.Account__r.CurrencyIsoCode,
            Legal_Business_Name__c = actName
        );
        // if address is not validated in mulesoft address will be blank so
        // do not populated address on account if address Id is blank.
        if(String.isNotBlank(addressId)){
          act = dto.getAddressDetails(act, eachIr.Id);
        }
        return act;
    }

    /**
     * @description Assigns Account type (FRANCHISEE / CORPORATE) based on Integration Request's payload
     * @param intId  Record Id of the relevant Integration Request
     * @return String Account Type
     * @jira #LEM-16130
     */
    private String getFranchiseeAccountType(Id intId){
        return dto.isFranchise(intId) ? TYPE_FRANCHISEE : TYPE_CORPORATE;
    }

    /**
     * @description Finds or creates the Contacts based on the completed Integration_Request__c records and the provided mapping
     * of Integration_Request__c record IDs to Business Account record IDs.
     * Contacts and Acrs will be created asynchrounosly in future handler because there will be call out to check existing contacts.
     * deactivate and remove the roles for existing store acrs.
     * @param completedCooReq  A List of completed Integration_Request__c records.
     * @param intIdToBusActId  A Map of Integration_Request__c record IDs to Business Account record IDs.
     */
    @testVisible
    private void handleContacts(List<Integration_Request__c> completedCooReq, Map<Id, Id> intIdToBusActId){
         List<String> contactsInfo = new List<String>();
        Set<Id> accountIds = new Set<Id>();
        for(Integration_Request__c eachIr: completedCooReq){
            contactsInfo.add(dto.serializeBusinessContact(eachIr.Id, intIdToBusActId.get(eachIr.Id)));
            contactsInfo.add(dto.serializeNewUserContact(eachIr.Id, eachIr.Account__c));
            accountIds.add(eachIr.Account__c);
        }
        // deactivate the existing ACR's and remove the roles for existing ACR
        AccountContactRelationsService.deactivateAccountAcrs(accountIds);
        // create or update ACR and contacts asynchronously using the ContactAndAcrCreateService class
        ContactAndAcrCreateService.processContactsPayloadAsyncly(contactsInfo);
    }
    /**
     * @description Finds or creates the Business Reference records based on the completed Integration_Request__c records
     * and the provided mapping of Integration_Request__c record Ids to Business Account record Ids.
     * @param completedCooReq       A List of completed Integration_Request__c records.
     * @param intIdToBusinessActId  A Map of Integration_Request__c record Ids to Business Account record Ids.
     * @return  Map<Id, Id> A Map of Integration_Request__c record Ids to Business Reference record Ids.
     */
    @testVisible
    private Map<Id, Id> findOrCreateBusinessReference(List<Integration_Request__c> completedCooReq, Map<Id, Id> intIdToBusinessActId){
        Map<String, Id> businessRefToMatchingKey = new Map<String, Id>();
        Set<String> businessIds = new Set<String>();
        for(Integration_Request__c eachIr: completedCooReq){
            businessIds.add(eachIr.business_Id__c);
        }
        List<Business_Reference__c> businessRef = BusinessReferencesSelector.newInstance().selectBusRefByExternalId(businessIds);
        businessRef = businessRef == null ? new List<Business_Reference__c>() : businessRef;
        for(Business_Reference__c eachBusinessRef: businessRef){
            String uniqueKey = getBusinessRefMatchingKey(eachBusinessRef);
            businessRefToMatchingKey.put(uniqueKey , eachBusinessRef.Id);
        }
        Set<Business_Reference__c> newBusinessRefs = new Set<Business_Reference__c>();
        // Iterate through completedCooReq to check if Business Reference records need to be created
        for(Integration_Request__c eachIr: completedCooReq){
            String uniqueKey = getIntReqMatchingKey(eachIr);
            Boolean businsessRefFound = businessRefToMatchingKey.containsKey(uniqueKey) ? true : false;
            if(!businsessRefFound){
                newBusinessRefs.add(createBusinessRefInstance(eachIr));
            }
        }
        uow.registerNew(new List<Business_Reference__c>(newBusinessRefs));
        uow.commitWork();
        uow = Application.UnitOfWork.newInstance();
        businessRef.addAll(newBusinessRefs);
        // Update the businessRefToMatchingKey map with the external IDs and record IDs of all Business Reference records
        return getintIdToBusinessRefIdMap(businessRef, completedCooReq);
    }
    /**
     * @description gets the intId To business ref map from newly created business ref and existing ref by matching
     * int req data for xref reparanting.
     * @param businessRef A List of completed businessRef records.
     * @param completedCooReq A List of completed Integration_Request__c records.
     * @return  Map<Id, Id> A Map of Integration_Request__c record Ids to Business Reference record Ids.
     */
    private Map<Id, Id> getintIdToBusinessRefIdMap(List<Business_Reference__c> businessRef, List<Integration_Request__c> completedCooReq){
        Map<Id, Id> intIdToBusinessRefId = new Map<Id, Id>();
        Map<String, Id> businessRefToMatchingKey = new Map<String, Id>();
        for(Business_Reference__c eachBusinessRef: businessRef){
            String uniqueKey = getBusinessRefMatchingKey(eachBusinessRef);
            businessRefToMatchingKey.put(uniqueKey, eachBusinessRef.Id);
        }
        for(Integration_Request__c eachIr: completedCooReq){
            String uniqueKey = getIntReqMatchingKey(eachIr);
            Id businessRefId = businessRefToMatchingKey.get(uniqueKey);
            intIdToBusinessRefId.put(eachIr.Id, businessRefId);
        }
        return intIdToBusinessRefId;
    }
    private String getBusinessRefMatchingKey(Business_Reference__c businessRef){
        return businessRef.External_Id__c + businessRef.CurrencyIsoCode +
            businessRef.External_Id_Source__c + businessRef.Default_Type__c;
    }
    private String getIntReqMatchingKey(Integration_Request__c ir){
        return ir.Business_Id__c + ir.Account__r.CurrencyIsoCode + EXTERNAL_DB_SOURCE_MDS + getFranchiseType(ir.Id);
    }
    private Business_Reference__c createBusinessRefInstance(Integration_Request__c eachIr){
        Business_Reference__c newBusinessRef = new Business_Reference__c(
            Business_Name__c = dto.getLegalBusinessName(eachIr.Id),
            Brand__c = eachIr.account__r.Brand__c,
            Default_Type__c = getFranchiseType(eachIr.Id),
            External_Id__c = eachIr.business_Id__c,
            External_Id_Source__c = EXTERNAL_DB_SOURCE_MDS,
            Integration_Status__c = 'Success',
            Business_Vertical__c = eachIr.account__r.Business_Vertical__c,
            Menu_UI_Type__c = eachIr.account__r.Menu_UI_Type__c,
            CurrencyIsoCode = eachIr.account__r.CurrencyIsoCode
        );
        return newBusinessRef;
    }
    /**
     * @description Updates the cross-reference (Xref) records with the latest Business Reference record IDs based
     * on the completed Integration_Request__c records and the provided mapping of Integration_Request__c record IDs to Business Reference record IDs.
     * @param completedCooReq       A List of completed Integration_Request__c records.
     * @param intIdToBusinessRefId  A Map of Integration_Request__c record IDs to Business Reference record IDs.
     */
    @testVisible
    private void updateXrefWithLatestBusinessRefId(List<Integration_Request__c> completedCooReq, Map<Id, Id> intIdToBusinessRefId){
        Map<String, Id> storeIdTobusinessId = new Map<String, Id>();
        for(Integration_Request__c eachir: completedCooReq){
            storeIdTobusinessId.put(eachir.store_Id__c, intIdToBusinessRefId.get(eachir.Id));
        }
        Set<String> storeIds = new Set<String>();
        for(Integration_Request__c eachIr: completedCooReq){
            storeIds.add(eachIr.store_Id__c);
        }
        // Update the Business Reference field of Xref records based on Store IDs
        for(Xref__c eachXref: XrefsSelector.newInstance().selectXrefByExternalId(new LIst<String>(storeIds))){
            eachXref.Business_Reference__c = storeIdTobusinessId.get(eachXref.External_Id__c);
            uow.registerDirty(eachXref);
        }
    }
    /**
    * @description Updates the Opportunity records to the Closed Won stage when int request is completed and all
    * opps related to the batch id are completed.
    * @param intIdToAccountId A Map of Integration_Request__c record Ids to Account record Ids.
    * @param intReqByBatch A List of Integration_Request__c records.
    */
    @testVisible
    private void updateOpportunityToClosedWon(Map<Id, Id> intIdToAccountId, List<Integration_Request__c> intReqByBatch){
        List<Integration_Request__c> completedCooReq = IntegrationRequests.newInstance(intReqByBatch).filterByProductStatus(COMPLETED).getRecords();
        Set<String> batchIdsOppNotCompleted = IntegrationRequests.newInstance(intReqByBatch).
            filterBatchIdsIrNotInProductStatus(new set<String>{COMPLETED,CANCELLED});
        Map<String, Id> onBoardingIdToOppId = new Map<String, Id>();
        for(Integration_Request__c eachIr: intReqByBatch){
            if(String.isNotEmpty(eachIr.opportunity__c)){
              onBoardingIdToOppId.put(eachIr.onBoarding_Id__c, eachIr.opportunity__c);
            }
        }
        for(Integration_Request__c eachIr: completedCooReq){
            if(!batchIdsOppNotCompleted.contains(eachIr.batch_Id__c)){
                String contractId = dto.getContractId(eachIr.Id);
                String contractUrl = System.Label.Contract_URL+contractId+'/record';
                Opportunity eachOpp = new Opportunity(Id = onBoardingIdToOppId.get(eachIr.onBoarding_Id__c),
                    StageName = STAGE_NAME_CLOSED_WON,
                    Is_Updated_By_System__c =true,
                    AccountId = intIdToAccountId.get(eachIr.Id),
                    Nintex_Id__c = contractId,
                    Nintex_Use_Case__c = INTEGRATION_TYPE_COO_SAME_STORE,
                    Nintex_URL__c = contractUrl
                );
                uow.registerDirty(eachOpp);
            }
        }
    }
    /**
     * @description Reparents the Store records based on the completed Integration_Request__c records.
     * This method is marked as @testVisible to allow for unit testing.
     * @param completedCooReq       A List of completed Integration_Request__c records.
     * @param intIdToBusinessActId  A Map of Integration_Request__c record Ids to Business Account record Ids.
     */
    @testVisible
    private void reparentTheStore(List<Integration_Request__c> completedCooReq, Map<Id, Id> intIdToBusinessActId){
        for(Integration_Request__c eachIr: completedCooReq){
            eachIr.sfdc_status__c = PROCESSED;
            String accountMatchReason = integrationReqIdToBusinessAccMatchReasonMap.containsKey(eachIr.Id) ? integrationReqIdToBusinessAccMatchReasonMap.get(eachIr.Id) : CREATED_A_NEW_BUSINESS_ACCOUNT;
            if(String.isNotBlank(accountMatchReason)){
                eachIr.COO_Parent_Account_Matching_Reason__c = accountMatchReason;
            }
            Id targetAccountId = intIdToBusinessActId.get(eachIr.Id);
            eachIr.COO_Reparented_Parent_Account__c = targetAccountId;
            Account store = new Account();
            store.Id = eachIr.Account__c;
            store.Change_of_Ownership_Effective_Date__c = getActivationDate(eachIr.Activation_Date__c);
            if(dto.isFranchise(eachIr.Id)){
               store.Franchise_Parent__c = targetAccountId;
            } else {
               store.Franchise_Parent__c = null;
               store.parentId = targetAccountId;
            }
            uow.registerDirty(eachIr);
            uow.registerDirty(store);
        }
    }
    /**
     * @description delete the existing Account To Payment Account Relation for the store.
     * @param completedCooReq  A List of completed Integration_Request__c records.
     */
    @testVisible
    private void deletePaymentAccountRelation(List<Integration_Request__c> completedCooReq){
        set<Id> accountIds = new Set<Id>();
        for(Integration_Request__c eachIr: completedCooReq){
            accountIds.add(eachIr.Account__c);
        }
        uow.registerDeleted(AccountPaymentAccountRelationsSelector.newInstance().selectByAccountIdsAndPaymentAccountRecordTypes(accountIds, PAYMENT_ACCOUNT_RECORD_TYPES));
        uow.commitWork();
    }
    /**
    * @description This method retrieves the Integration Requests associated with a given set of IDs.
    * @param batchIds A Set object containing the IDs of the Integration Requests to be retrieved.
    * @return List<Integration_Request__c>
    */
    @testVisible
    private List<Integration_Request__c> getIntegrationRequests(Set<String> batchIds){
        List<Integration_Request__c> intReq = IntegrationRequestsSelector.newInstance().selectByBatchId(batchIds);
        dto = new CooTransactionsDto(intReq);
        return intReq;
    }
    private Date getActivationDate(Date activationDate){
        return activationDate != null && activationDate >= Date.Today() ? activationDate : Date.today();
    }
    private String getFranchiseType(Id intId){
        return dto.isFranchise(intId) ? TYPE_FRANCHISE : TYPE_CORPORATE;
    }

    /**
     * @description Processes the ready Integration_Request__c records
     * @param intReqByBatch  A List of Integration_Request__c records.
     */
    @testVisible
    private void processReadyCooRequests(List<Integration_Request__c> intReqByBatch){
        List<Integration_Request__c> pendingReadyReq = IntegrationRequests.newInstance(intReqByBatch)
               .filterByProductStatus(READY).filterBySfdcStatus(PENDING).getRecords();
        if(pendingReadyReq.isEmpty()){
            return;
        }
        List<Integration_Request__c> integrationRequestsOnReadyEvent = new List<Integration_Request__c>();
        List<Integration_Request__c> posIntegrationRequestsOnReadyEvent = new List<Integration_Request__c>();
            for(Integration_Request__c eachIr: pendingReadyReq){
                if(eachIr.Parent_Integration_Request__c != null
                    && PROCESSED.equalsIgnoreCase(eachIr.Parent_Integration_Request__r.SFDC_status__c)
                    && READY.equalsIgnoreCase(eachIr.product_status__c)
                    && PENDING.equalsIgnoreCase(eachIr.SFDC_status__c) ){
                integrationRequestsOnReadyEvent.add(eachIr);
                        if (isPosIntegrationRequest(eachIr)){
                            posIntegrationRequestsOnReadyEvent.add(eachIr);
                        }
                 }
            }

        updateIntegrationRequestOnReadyEvent(integrationRequestsOnReadyEvent);
        updateAccountOnReadyEvent(integrationRequestsOnReadyEvent);
        updateWorkOrderPDOA(integrationRequestsOnReadyEvent);
        uow.commitWork();
        //reevaluate the workorders to create POS workplans
        CooWorkOrderService.processPosIntRequestOnReadyEvent(posIntegrationRequestsOnReadyEvent);
    }

     /**
     * @description Processes the WorkOrder on ready Integration_Request__c records
     * On ready event if the IntR.effective date changes update the Parent WO.Proposed_Date_of_Activation__c with the new effective date
     * @param integrationRequestsOnReadyEvent  A List of Integration_Request__c records.
     */
    private void updateWorkOrderPDOA(List<Integration_Request__c> integrationRequestsOnReadyEvent){
        Set<Id> oppIds = new Set<Id>();
        Set<String> batchIds = new Set<String>();
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();
        Map<String, Date> batchIDByActivationDate = new Map<String, Date>();
        for (Integration_Request__c eachIr : integrationRequestsOnReadyEvent){
            batchIds.add(eachIr.Batch_Id__c);
            oppIds.add(eachIr.Parent_Integration_Request__r.Opportunity__c);
            batchIDByActivationDate.put(eachIr.Batch_Id__c, eachIr.Activation_Date__c);
        }
        if (!batchIds.isEmpty() && !oppIds.isEmpty()){
            parentWorkOrders = WorkOrdersSelector.newInstance().selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(WO_OPEN_STATUS, TYPE_COO, SUB_TYPE_COO_SAME_STORE, oppIds, batchIds);
        }
        if (!parentWorkOrders.isEmpty()){
            for (WorkOrder eachWorkorder : parentWorkOrders){
                if (batchIDByActivationDate.get(eachWorkorder.Opportunity__r.Batch_Id__c) != eachWorkorder.Proposed_Date_of_Activation__c){
                    eachWorkorder.Proposed_Date_of_Activation__c = batchIDByActivationDate.get(eachWorkorder.Opportunity__r.Batch_Id__c);
                    uow.registerDirty(eachWorkorder);
                }
            }
        }
    }

    //copy the the POS Provider type on the raedy integration request on the parent Integration request, Provider type field
    @testVisible
    private void updateIntegrationRequestOnReadyEvent( List<Integration_Request__c> integrationRequestsOnReadyEvent){
        for (Integration_Request__c eachIr : integrationRequestsOnReadyEvent) {
            eachIr.sfdc_status__c = PROCESSED;
            uow.registerDirty(eachIr);
            if (isPosIntegrationRequest(eachIr)) {
                Integration_Request__c parentIntRequest = new Integration_Request__c(
                                                        Id = eachIr.Parent_Integration_Request__c,
                                                        Integration_Provider__c  = dto.getPOSProviderType(eachIr.id));
                uow.registerDirty(parentIntRequest);
            }
        }
    }

    //Update the Account POS Integration type with the POS Provider type on the raedy integration request
    @testVisible
    private void updateAccountOnReadyEvent(List<Integration_Request__c> integrationRequestsOnReadyEvent ){
        for(Integration_Request__c eachIr : integrationRequestsOnReadyEvent){
            Account eachAcc = new Account(Id = eachIr.Account__c);
            Boolean effectiveDateChanged =  eachIr.Activation_Date__c != eachIr.Account__r.Change_of_Ownership_Effective_Date__c;
            if( dto.getOrderProtocol(eachIr.Id).contains(ORDER_PROTOCOL_EMAIL) || isPosIntegrationRequest(eachIr) || effectiveDateChanged ){
                if (isPosIntegrationRequest(eachIr) && providerTypes.contains(dto.getPOSProviderType(eachIr.id))){
                    eachAcc.POS_Integration_Type__c = dto.getPOSProviderType(eachIr.id);
                    eachAcc.POS_Integration_ID__c = '';
                }
                if (dto.getOrderProtocol(eachIr.Id).contains(ORDER_PROTOCOL_EMAIL) && !String.isBlank(dto.getOrderProtocolEmail(eachIr.id))){
                    eachAcc.Order_Protocol_Email__c = dto.getOrderProtocolEmail(eachIr.id);
                    eachAcc.Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL_EMAIL;
                }
                if (dto.getOrderProtocol(eachIr.Id).contains(ORDER_PROTOCOL_EMAIL) && !String.isBlank(dto.getOrderprotocolPhoneNumber(eachIr.id))){
                    eachAcc.Phone = dto.getOrderprotocolPhoneNumber(eachIr.id);
                }
                if (effectiveDateChanged){
                    eachAcc.Change_of_Ownership_Effective_Date__c = eachIr.Activation_Date__c;
                }
                uow.registerDirty(eachAcc);
            }
        }
    }

    private boolean isPosIntegrationRequest(Integration_Request__c eachIr){
        boolean isPosIntegrationRequest = false;
        if (String.isNotBlank(dto.getPOSProviderType(eachIr.id)) && dto.getOrderProtocol(eachIr.Id).contains(ORDER_PROTOCOL_POS)) {
            isPosIntegrationRequest = true;
        }
      return  isPosIntegrationRequest;
    }

    /**
     * @description Create a Log__c record
     * @param cooBatchIds
     */
    private void createLog(Set<String> cooBatchIds) {
        List<String> batchList = new List<String>(cooBatchIds);
        String batchIdString = String.join(batchList, ',');

        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                GENERIC_LOG_SERVICE_COO_SAME_STORE,
                GenericLogEntry.GENERIC_LOG_DOMAIN_ONBOARDING,
                GenericLogEntry.SeverityLevel.LOW
            ).logException(
                new DmlException( 'Service was successful for batch Ids: ' + batchIdString )
            )
            .setCategory(GenericLogEntry.GENERIC_LOG_INFORMATION)
            .setLogLevel(GenericLogEntry.GENERIC_LOG_INFORMATION)
        );
    }
}