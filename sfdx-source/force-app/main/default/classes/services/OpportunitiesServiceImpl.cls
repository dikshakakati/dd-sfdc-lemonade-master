/**
 * @author Deloitte
 * @date 16/06/2022
 * @description Service implementation class for Opportunities related logic.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength')
public inherited sharing class OpportunitiesServiceImpl implements IOpportunitiesService {
    private static final String LOG_SERVICE_MX_TAG_ASSOCIATION = 'MxTagAssociationsBatch';
    private static final String LOG_DOMAIN_SALES = 'Sales';
    private static final String SEPARATOR_SEMI_COLON = '; ';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = System.Label.BusinessAccountRecordTypeName;
    private static final String AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS = 'opportunityId';
    private static final String AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS = 'productFamily';
    private static final String BATCH_JOB_MESSAGE = 'Child Work Orders creation is initiated through Rate Change Nintex use case.';
    private static final String CONTRACTING_STAGE = 'Contracting';
    private static final Set<String> CONTRACT_CORRECTION = new Set<String>{
        'Contract Correction - Amendment',
        'Contract Correction'
    };
    private static final Set<String> CONTRACTING_STAGE_VALIDATION_BYPASSED_PRODUCT_FAMILIES = new Set<String>{
        'Advertisement',
        'Drive Promotion',
        'Marketplace Promotion'
    };
    private static final String LOG_SERVICE = 'Quote Changes';
    private static final String LOG_DOMAIN = 'CPQ';
    private static final String NEGOTIATING_STAGE = 'Negotiating';
    private static final String PITCHING_STAGE = 'Pitching';
    private static final String UPGRADE_SUB_TYPE = 'Upgrade';
    private static final String EXISTING_TYPE_VALUE = 'Existing';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String RATE_CHANGE_USE_CASE = 'Rate Change';
    private static final String STANDARD = 'Standard';
    private static final String RESCUE = 'Rescue';
    private static final String OPT_IN = 'Opt-In';
    private static final String OPT_OUT = 'Opt-Out';
    private static final String FSA = 'FSA';
    private static final String MERCHANT = 'Merchant';
    private static final String DOORDASH = 'DoorDash';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String CLOSED_LOST = 'Closed Lost';
    private static final String LACK_OF_ACTIVITY = 'Lack of Activity';
    private static final String FRANCHISE_AMENDMENT_PROCESS = 'FranchiseAmendmentProcess__c';
    private static final String NINTEX_WORK_ORDERS_PROCESSOR_BATCH_SIZE_STATIC_CONFIG = 'Nintex_Work_Orders_Processor_Batch_Size';
    private static final String OPPORTUNITY_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Opportunity_Creation_Payload_Chunk_Size';
    private static final String OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE = 'Rate Change';
    private static final String OPT_IN_OPT_OUT_RESPONSE_TIME = 'Opt_In_Opt_Out_Response_Time__c';
    private static final String RESPONSIBLE_PARTY = 'Responsible_Party__c';
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    static final String UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY = 'UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY';
    static final String CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES = 'CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES';
    private static Boolean enableCopyQuoteValuesOnOpportunities;
    private Map<Id, Opportunity> closedWonRateChangeOpportunities;
    private Integer nintexWorkOrdersProcessorBatchSize;
    private Integer franchiseAccountIdsChunkSize;
    private static final String DRIVE_AMENDMENT_USE_CASE = 'Drive - Amendment';
    private static final String PARTNERSHIP_LEVEL_EXCLUSIVE = 'Exclusive';
    private static final String PARTNERSHIP_LEVEL_PREFERRED = 'Preferred';
    private static final String EXCLUSIVITY_RENEWAL_OPPORTUNITY_NAME = 'Exclusivity Renewal';
    private static final String PREFERRED_RENEWAL_OPPORTUNITY_NAME = 'Preferred partnership Renewal';
    private static final String SMB = 'SMB';
    private static final String PROSPECTING_STAGE = 'Prospecting';
    private enum EventTopics {
        EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION,
        UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY,
        CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION => EventTopics.EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION,
        UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY => EventTopics.UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY,
        CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES => EventTopics.CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES
    };

    static {
        enableCopyQuoteValuesOnOpportunities = false;
    }

    /**
     * @description Default constructor to instantiate variables.
     */
    public OpportunitiesServiceImpl() {
        this.closedWonRateChangeOpportunities = new Map<Id, Opportunity>();
        collectStaticConfigurations();
    }

    /**
     * @description It is used to activate banner message indicator on parent Work Order when
     * Rate Change Opportunity is Closed Won.
     * @JIRA# LEM-3711
     * @param opportunityIds
     */
    public void activateBannerOnClosedWonRateChangeOpportunities(Set<Id> opportunityIds) {
        Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>();
        collectClosedWonRateChangeOpportunities(opportunityIds);
        if (!closedWonRateChangeOpportunities.isEmpty()) {
            workOrders = new Map<Id, WorkOrder>(
                WorkOrdersSelector.newInstance()
                    .selectParentWorkOrdersByOpportunityIds(
                        closedWonRateChangeOpportunities.keySet()
                    )
            );
            WorkOrdersService.toggleBannerOnParentWorkOrders(workOrders.keySet());
        }
    }

    /**
     * @description This method is used to perform update on Opportunity currency when update currency notifier event is fired.
     * @param notifierEvents
     */
    public void handleNotifierEvents(List<Notifier__e> notifierEvents) {
        Set<Id> accountRecordIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> recordIdsFromPayload;
        List<String> franchiseAccountIds;
        String contractId;
        String useCase;
        String daysToAdd;
        NintexOpportunityCreationWrapper payloads = new NintexOpportunityCreationWrapper(
            franchiseAccountIds,
            contractId,
            useCase,
            daysToAdd
        );
        for (Notifier__e eventRec : notifierEvents) {
            if (eventRec.Topic__c == CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES) {
                payloads = (NintexOpportunityCreationWrapper) JSON.deserialize(
                    eventRec.Payload__c,
                    NintexOpportunityCreationWrapper.class
                );
                if (payloads == null) {
                    continue;
                }
                createOpportunitiesOnFranchiseAccounts(
                    payloads.franchiseAccountIds,
                    payloads.contractId,
                    payloads.useCase,
                    payloads.daysToAdd
                );
            } else {
                recordIdsFromPayload = (Set<Id>) JSON.deserialize(
                    eventRec.Payload__c,
                    Set<Id>.class
                );
            }
            if (recordIdsFromPayload == null) {
                continue;
            }
            switch on EVENT_TOPIC_MAPPINGS.get(eventRec.Topic__c) {
                when EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION {
                    opportunityIds.addAll(recordIdsFromPayload);
                }
                when UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY {
                    accountRecordIds.addAll(recordIdsFromPayload);
                }
            }
        }
        updateCurrencyOnOpenOpportunitiesWithNoLinkedQuotes(accountRecordIds);
        initiateOpportunityTeamMemberCreation(opportunityIds);
    }

    /**
     * @description This method is used to delete Opportunity Account Relationship records filtered
     * by OpportunityIds
     * @param reparentedOpportunityIds
     */
    public static void deleteOpportunityAccountRelationships(Set<String> reparentedOpportunityIds) {
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();
        for (
            Opportunity_Account_Relationship__c eachOpportunityAccountRelationship : OpportunityAccountRelationshipsSelector.newInstance()
                .fetchRelationshipsByParentOpportunities(reparentedOpportunityIds)
        ) {
            relationshipUnitOfWork.registerDeleted(eachOpportunityAccountRelationship);
        }
        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description This method is used to create Opportunities on the passed Franchise Accounts.
     * @param franchiseAccountIds
     * @param contractId
     * @param useCase
     * @param daysToAdd
     */
    public void createOpportunitiesOnFranchiseAccounts(
        List<String> franchiseAccountIds,
        String contractId,
        String useCase,
        String daysToAdd
    ) {
        Integer closeDateInFuture = Integer.valueOf(daysToAdd.trim());
        Map<String, String> idToLegalBusinessName = mapAccountIdToLegalBusinessName(
            new Set<String>(franchiseAccountIds)
        );
        if (franchiseAccountIds.size() > franchiseAccountIdsChunkSize) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES => payloadGenerationNintex(
                        franchiseAccountIds,
                        contractId,
                        useCase,
                        daysToAdd
                    )
                }
            );
            return;
        }
        Id opportunityOwnerId = UserInfo.getUserId();
        if (useCase == DRIVE_AMENDMENT_USE_CASE) {
            Contract contractWithCorporateAccount = ContractsSelector.newInstance()
                .selectById(new Set<Id>{ contractId })[0];
            List<AccountTeamMember> accountTeamMemberWithFranchiseRepRole = AccountTeamMembersSelector.newInstance()
                .selectFranchiseRepRoleAccountTeamMembersByAccountId(
                    contractWithCorporateAccount.AccountId
                );
            opportunityOwnerId = !accountTeamMemberWithFranchiseRepRole.isEmpty()
                ? accountTeamMemberWithFranchiseRepRole[0].UserId
                : contractWithCorporateAccount.account.OwnerId;
        }
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();
        Set<Id> fxAccountIds = new Set<Id>();
        for (String eachAccountId : franchiseAccountIds) {
            fxAccountIds.add(eachAccountId);
        }
        for (Account eachAccount : AccountsSelector.newInstance().selectById(fxAccountIds)) {
            relationshipUnitOfWork.registerNew(
                new Opportunity(
                    AccountId = eachAccount.Id,
                    Name = idToLegalBusinessName.get(eachAccount.Id),
                    CloseDate = Date.today().addDays(closeDateInFuture),
                    Opportunity_Sub_Type__c = UPGRADE_SUB_TYPE,
                    StageName = NEGOTIATING_STAGE,
                    Estimated_Number_of_Stores__c = eachAccount.Segment__c == SMB
                        ? (eachAccount.Total_Number_Of_Stores__c == 0
                              ? 1
                              : eachAccount.Total_Number_Of_Stores__c)
                        : null,
                    Type = EXISTING_TYPE_VALUE,
                    Source__c = SOURCE_NINTEX,
                    Nintex_Use_Case__c = useCase,
                    Deal_Type__c = STANDARD,
                    ContractId = contractId,
                    OwnerId = opportunityOwnerId,
                    LeadSource = ''
                )
            );
        }
        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description It creates the payload for creation of notifier event using franchise account Ids
     * contract Id and Nintex Use Case
     * @JIRA# LEM-6570
     * @param franchiseAccountIds
     * @param contractId
     * @param useCase
     * @param daysToAdd
     * @return List<String>
     */
    private List<String> payloadGenerationNintex(
        List<String> franchiseAccountIds,
        String contractId,
        String useCase,
        String daysToAdd
    ) {
        List<String> payloads = new List<String>();
        Set<Id> franchiseAccIds = new Set<Id>((List<Id>) franchiseAccountIds);
        List<String> payloadsFromNotifierEvent = NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
            franchiseAccIds,
            franchiseAccountIdsChunkSize
        );
        NintexOpportunityCreationWrapper wrapper;
        for (String eachPayload : payloadsFromNotifierEvent) {
            wrapper = new NintexOpportunityCreationWrapper(
                (List<String>) JSON.deserialize(eachPayload, List<String>.class),
                contractId,
                useCase,
                daysToAdd
            );
            payloads.add(JSON.serialize(wrapper));
        }
        return payloads;
    }

    /**
     * @description It initiates child Work Orders creation using the Opportunities collected
     * on creation/update through Nintex.
     * @JIRA# LEM-3658
     * @param opportunityIds
     */
    public void initiateChildWorkOrdersCreationByNintexUseCase(Set<Id> opportunityIds) {
        Map<Id, Id> franchiseAccountIdToOpportunityId = new Map<Id, Id>();
        collectClosedWonRateChangeOpportunities(opportunityIds);
        for (Opportunity eachOpportunity : closedWonRateChangeOpportunities.values()) {
            franchiseAccountIdToOpportunityId.put(eachOpportunity.AccountId, eachOpportunity.Id);
        }
        if (!franchiseAccountIdToOpportunityId.isEmpty()) {
            String jobId = Database.executeBatch(
                new NintexWorkOrdersProcessorBatch(franchiseAccountIdToOpportunityId),
                nintexWorkOrdersProcessorBatchSize
            );
            createBatchJobLogEntry(jobId, franchiseAccountIdToOpportunityId);
        }
    }

    /**
     * @description It is used to collect valid Opportunities (having Nintex Id) to initiate
     * parent Work Order creation.
     * @param opportunityIds
     */
    public void initiateParentWorkOrdersCreation(Set<Id> opportunityIds) {
        if (opportunityIds.isEmpty()) {
            return;
        }
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            OpportunitiesSelector.newInstance().selectOpportunitiesWithNintexIdById(opportunityIds)
        );
    }

    /**
     * @description This method is used to get the legal business name of Accounts and map them to Account Ids
     * @param franchiseAccountIds
     * @return Map<String, String>
     */
    private static Map<String, String> mapAccountIdToLegalBusinessName(
        Set<String> franchiseAccountIds
    ) {
        Map<String, String> idToLegalBusinessName = new Map<String, String>();
        for (Account eachAccount : AccountsSelector.newInstance().selectById(franchiseAccountIds)) {
            idToLegalBusinessName.put(
                String.valueOf(eachAccount.Id),
                eachAccount.Legal_Business_Name__c
            );
        }
        return idToLegalBusinessName;
    }

    /**
     * @description This method is used to update currency on Open Opportunities
     * if parent Account Currency is updated and the Opportunities are not linked to a Quote
     * @param accountRecordIds
     */
    private static void updateCurrencyOnOpenOpportunitiesWithNoLinkedQuotes(
        Set<Id> accountRecordIds
    ) {
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();
        Set<Id> opportunityIdsWithQuotes = new Set<Id>();

        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectOpenOpportunitiesByAccountIds(accountRecordIds)
        ) {
            if (!opportunityIdsWithQuotes.contains(eachOpportunity.Id)) {
                eachOpportunity.CurrencyIsoCode = eachOpportunity.Account.CurrencyIsoCode;
                relationshipUnitOfWork.registerDirty(eachOpportunity);
            }
        }
        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description This method is used to update currency on Open Opportunities
     * if parent Account Currency is updated and the Opportunities are not linked to a Quote
     * @param opportunityIds
     */
    private static void initiateOpportunityTeamMemberCreation(Set<Id> opportunityIds) {
        List<Opportunity> opportunities = OpportunitiesSelector.newInstance()
            .selectById(opportunityIds);
        if (opportunities != null && !opportunities.isEmpty()) {
            OpportunityTeamMembersService.createOpportunityTeamMembersForManagers(opportunities);
        }
    }

    /**
     * @description This method is called from Batch class to update the Opportunity Stage to
     * Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     * @param opportunities
     */
    public static void updateStageToClosedByFranchiseAmendmentProcessByBatch(
        List<Opportunity> opportunities
    ) {
        if (opportunities == null) {
            return;
        }
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UNITOFWORK.newInstance();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity eachOpportunity : opportunities) {
            if (
                enableCopyQuoteValuesOnOpportunities &&
                eachOpportunity.Nintex_Use_Case__c == RATE_CHANGE_USE_CASE
            ) {
                eachOpportunity.FranchiseAmendmentProcess__c = eachOpportunity.Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Opt_Out_Decision__c;
                eachOpportunity.Opt_In_Opt_Out_Response_Time__c = eachOpportunity.Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Opt_Out_Response_Time_in_Days__c;
                eachOpportunity.Opt_Out_Save_Period__c = eachOpportunity.Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_Out_Save_Period_days__c;
                eachOpportunity.Responsible_Party__c = eachOpportunity.Contract.SBQQ__Order__r.SBQQ__Quote__r.Opt_In_Out_Responsible_Party__c;
            }
            opportunitiesToUpdate.add(isOpportunityEligibleForCloseWon(eachOpportunity));
        }
        relationshipUnitOfWork.registerDirty(opportunitiesToUpdate);
        commitUnitOfWork(relationshipUnitOfWork);
    }

    /**
     * @description This method is called from Change Event class to update the Opportunity Stage
     * to Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     * @param opportunityIds
     * @param isCreateEvent
     */
    public static void updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
        Set<Id> opportunityIds,
        Boolean isCreateEvent
    ) {
        enableCopyQuoteValuesOnOpportunities = isCreateEvent;
        updateStageToClosedByFranchiseAmendmentProcessByBatch(
            OpportunitiesSelector.newInstance().selectOpportunitiesWithNintexUseCase(opportunityIds)
        );
    }

    /**
     * @description It collects Opportunities where 'Stage' field value is 'Closed Won' when
     * 'Nintex Use Case' field value is 'Rate Change'.
     * @param opportunityIds
     */
    private void collectClosedWonRateChangeOpportunities(Set<Id> opportunityIds) {
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(opportunityIds)
        ) {
            if (!isEligibleOpportunity(eachOpportunity)) {
                continue;
            }
            closedWonRateChangeOpportunities.put(eachOpportunity.Id, eachOpportunity);
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.nintexWorkOrdersProcessorBatchSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(NINTEX_WORK_ORDERS_PROCESSOR_BATCH_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.franchiseAccountIdsChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(OPPORTUNITY_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It is used to create log entry for 'NintexWorkOrdersProcessorBatch' batch job Id.
     * @param jobId
     * @param franchiseAccountIdToOpportunityId
     */
    private void createBatchJobLogEntry(
        String jobId,
        Map<Id, Id> franchiseAccountIdToOpportunityId
    ) {
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        if (jobId != null) {
            logEntryInstance = LogEntry.newBatchLog(
                BATCH_JOB_MESSAGE,
                jobId,
                LogEntry.SeverityLevel.LOW
            );
            logEntryInstance.recordId = franchiseAccountIdToOpportunityId.toString();
            loggerInstance = Logger.add(logEntryInstance);
        }
        if (loggerInstance == null) {
            return;
        }
        loggerInstance.publish();
    }

    /**
     * @description It checks whether 'Stage' field value is 'Closed Won' when
     * 'Nintex Use Case' field value is 'Rate Change' and Nintex Id is populated
     * on the passed Opportunity.
     * @param opportunityToValidate
     * @return Boolean
     */
    private Boolean isEligibleOpportunity(Opportunity opportunityToValidate) {
        return (opportunityToValidate.Drive_Nintex_Id__c != null ||
            opportunityToValidate.Marketplace_Nintex_Id__c != null) &&
            opportunityToValidate.Nintex_Use_Case__c == OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE &&
            opportunityToValidate.StageName == CLOSED_WON;
    }

    /**
     * @description It checks whether the passed field value is null on the passed Account.
     * @param opportunity
     * @param fieldName
     * @return Boolean
     */
    private static Boolean isFieldValueNull(Opportunity opportunity, String fieldName) {
        return opportunity.get(fieldName) == null;
    }

    /**
     * @description This method is to check the conditions for updating the Opportunity as Closed Won.
     * @param opportunity
     * @return Opportunity
     */
    private static Opportunity isOpportunityEligibleForCloseWon(Opportunity opportunity) {
        Boolean conditionForClosedWon = ((!isFieldValueNull(
            opportunity,
            FRANCHISE_AMENDMENT_PROCESS
        ) &&
        opportunity.FranchiseAmendmentProcess__c == FSA &&
        opportunity.Nintex_Signed_Date__c != null) ||
        (!isFieldValueNull(opportunity, FRANCHISE_AMENDMENT_PROCESS) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_IN &&
        opportunity.Nintex_Signed_Date__c != null) ||
        (!isFieldValueNull(opportunity, FRANCHISE_AMENDMENT_PROCESS) &&
        !isFieldValueNull(opportunity, OPT_IN_OPT_OUT_RESPONSE_TIME) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_OUT &&
        (opportunity.Nintex_Signed_Date__c == null &&
        System.today() >
        (opportunity.CreatedDate.addDays(
                Integer.valueOf(opportunity.Opt_In_Opt_Out_Response_Time__c) + 3
            ))
            .date())));

        if (conditionForClosedWon) {
            return setOpportunityClosedWonDetails(opportunity);
        } else {
            return isOpportunityEligibleForCloseLost(opportunity);
        }
    }

    /**
     * @description This method is to check the conditions for updating the Opportunity as Closed Lost.
     * @param opportunity
     * @return Opportunity
     */
    private static Opportunity isOpportunityEligibleForCloseLost(Opportunity opportunity) {
        Boolean conditionForClosedLost = (((!isFieldValueNull(
            opportunity,
            FRANCHISE_AMENDMENT_PROCESS
        ) &&
        !isFieldValueNull(opportunity, OPT_IN_OPT_OUT_RESPONSE_TIME) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_IN &&
        (opportunity.Nintex_Signed_Date__c == null &&
        System.today() >
        (opportunity.CreatedDate.addDays(
                Integer.valueOf(opportunity.Opt_In_Opt_Out_Response_Time__c) + 368
            ))
            .date())) ||
        (!isFieldValueNull(opportunity, OPT_IN_OPT_OUT_RESPONSE_TIME) &&
        !isFieldValueNull(opportunity, FRANCHISE_AMENDMENT_PROCESS) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_OUT &&
        opportunity.Nintex_Signed_Date__c != null &&
        opportunity.Nintex_Signed_Date__c <=
        (opportunity.CreatedDate.addDays(
                Integer.valueOf(opportunity.Opt_In_Opt_Out_Response_Time__c) + 3
            ))
            .date())) &&
        !isFieldValueNull(opportunity, RESPONSIBLE_PARTY) &&
        opportunity.Responsible_Party__c == MERCHANT);
        if (conditionForClosedLost) {
            return setOpportunityClosedLostDetails(
                opportunity,
                opportunity.FranchiseAmendmentProcess__c
            );
        } else {
            return isOpportunityEligibleForRescueType(opportunity);
        }
    }

    /**
     * @description This method is to check the conditions for updating the Opportunity Type as Rescue.
     * @param opportunity
     * @return Opportunity
     */
    private static Opportunity isOpportunityEligibleForRescueType(Opportunity opportunity) {
        Boolean conditionForTypeRescue = ((!isFieldValueNull(
            opportunity,
            FRANCHISE_AMENDMENT_PROCESS
        ) &&
        !isFieldValueNull(opportunity, OPT_IN_OPT_OUT_RESPONSE_TIME) &&
        !isFieldValueNull(opportunity, RESPONSIBLE_PARTY) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_IN &&
        opportunity.Nintex_Signed_Date__c == null &&
        System.today() >
        (opportunity.CreatedDate.addDays(
                Integer.valueOf(opportunity.Opt_In_Opt_Out_Response_Time__c) + 3
            ))
            .date()) ||
        (!isFieldValueNull(opportunity, FRANCHISE_AMENDMENT_PROCESS) &&
        !isFieldValueNull(opportunity, OPT_IN_OPT_OUT_RESPONSE_TIME) &&
        !isFieldValueNull(opportunity, RESPONSIBLE_PARTY) &&
        opportunity.FranchiseAmendmentProcess__c == OPT_OUT &&
        opportunity.Nintex_Signed_Date__c != null &&
        opportunity.Nintex_Signed_Date__c <=
        (opportunity.CreatedDate.addDays(
                Integer.valueOf(opportunity.Opt_In_Opt_Out_Response_Time__c) + 3
            ))
            .date() &&
        opportunity.Responsible_Party__c == DOORDASH));
        if (conditionForTypeRescue) {
            return setOpportunityRescueDetails(opportunity);
        } else {
            return opportunity;
        }
    }

    /**
     * @description This method is to set the Opportunity stage as Closed Won.
     * @param opportunity
     * @return Opportunity
     */
    private static Opportunity setOpportunityClosedWonDetails(Opportunity opportunity) {
        opportunity.StageName = CLOSED_WON;
        opportunity.CloseDate = System.today();
        opportunity.Is_Updated_By_System__c = true;
        return opportunity;
    }

    /**
     * @description This method is to set the Opportunity stage as Closed Lost.
     * @param opportunity
     * @param franchiseAmendmentProcess
     * @return Opportunity
     */
    private static Opportunity setOpportunityClosedLostDetails(
        Opportunity opportunity,
        String franchiseAmendmentProcess
    ) {
        opportunity.StageName = CLOSED_LOST;
        opportunity.Lost_Reason__c = LACK_OF_ACTIVITY;
        if (franchiseAmendmentProcess == OPT_IN) {
            opportunity.Lost_Reason_Additional_Notes__c = System.Label.ADDITIONAL_NOTES_ON_CLOSED_LOST_OPT_IN_OPPORTUNITY;
        } else {
            opportunity.Lost_Reason_Additional_Notes__c = System.Label.ADDITIONAL_NOTES_ON_CLOSED_LOST_OPT_OUT_OPPORTUNITY;
        }

        return opportunity;
    }

    /**
     * @description This method is to set the Opportunity Type as Rescue.
     * @param opportunity
     * @return Opportunity
     */
    private static Opportunity setOpportunityRescueDetails(Opportunity opportunity) {
        opportunity.Type = RESCUE;
        opportunity.Opportunity_Sub_Type__c = RESCUE;
        opportunity.OwnerId = opportunity.Account.OwnerId;
        opportunity.CloseDate = System.today()
            .addDays(Integer.valueOf(opportunity.Opt_Out_Save_Period__c));
        return opportunity;
    }

    /**
     * @description This method is used to retrieve Opportunity Brand Relationships for all
     * opportunities and extract the set of parent Opportunities.
     * @param opportunities
     * @return Set<Id>
     */
    public Set<Id> getOpportunitiesWithOpportunityBrandRelationships(
        List<Opportunity> opportunities
    ) {
        List<Opportunity_Brand_Relationship__c> opportunityBrandRelationships = OpportunityBrandRelationshipsSelector.newInstance()
            .selectByOpportunity(new Map<Id, Opportunity>(opportunities).keySet());
        Set<Id> opportunitiesWithBrandRelationships = new Set<Id>();

        if (opportunityBrandRelationships == null) {
            return opportunitiesWithBrandRelationships;
        }
        for (
            Opportunity_Brand_Relationship__c eachOpportunityBrandRelationship : opportunityBrandRelationships
        ) {
            if (eachOpportunityBrandRelationship.Opportunity__c != null) {
                opportunitiesWithBrandRelationships.add(
                    eachOpportunityBrandRelationship.Opportunity__c
                );
            }
        }
        return opportunitiesWithBrandRelationships;
    }

    /**
     * @description It collects corporate Opportunities in contracting stage
     * without associated Work Order.
     * @JIRA# LEM-2132
     * @param opportunitiesWithChangedStage
     * @return List<Opportunity>
     */
    public List<Opportunity> collectOpportunitiesWithoutWorkOrderInContractingStage(
        List<Opportunity> opportunitiesWithChangedStage
    ) {
        Map<Id, Set<String>> opportunityIdToProductFamilies = getOpportunityProductFamilies(
            new Map<Id, Opportunity>(opportunitiesWithChangedStage)
        );
        List<Opportunity> corporateOpportunitiesInContractingStage = new List<Opportunity>();
        for (Opportunity eachOpportunity : opportunitiesWithChangedStage) {
            if (
                isEligibleOpportunityInOrBeyondContractingStage(
                    eachOpportunity,
                    opportunityIdToProductFamilies
                )
            ) {
                corporateOpportunitiesInContractingStage.add(eachOpportunity);
            }
        }
        if (corporateOpportunitiesInContractingStage.isEmpty()) {
            return corporateOpportunitiesInContractingStage;
        }
        return WorkOrdersService.collectOpportunitiesWithoutWorkOrder(
            corporateOpportunitiesInContractingStage
        );
    }

    /**
     * @description It is used to update the Estimated Total Investment on the Opportunities.
     * @param opportunityToTotalInvestment
     */
    public void updateEstimatedTotalInvestmentOnOpportunity(
        Map<Id, Decimal> opportunityToTotalInvestment
    ) {
        fflib_ISObjectUnitOfWork investmentUnitOfWork = Application.UNITOFWORK.newInstance();
        Map<Id, Opportunity> opportunitiesToBeUpdated = new Map<Id, Opportunity>(
            OpportunitiesSelector.newInstance().selectById(opportunityToTotalInvestment.keySet())
        );
        Opportunity opportunityToBeUpdated = new Opportunity();
        for (Id eachOpportunityId : opportunityToTotalInvestment.keySet()) {
            opportunityToBeUpdated = opportunitiesToBeUpdated.get(eachOpportunityId);
            opportunityToBeUpdated.Estimated_Total_Investment__c = opportunityToTotalInvestment.get(
                eachOpportunityId
            );
            investmentUnitOfWork.registerDirty(opportunityToBeUpdated);
        }
        commitUnitOfWork(investmentUnitOfWork);
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception relationshipUnitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    relationshipUnitOfWorkException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed opportunities which triggers the further processing on AccountId change on opportunities.
     * @param opportunities
     */
    public void processMergedAccountsRelatedRecords(List<Opportunity> opportunities) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Opportunity eachOpportunity : opportunities) {
            eachOpportunity.Is_Parent_Account_Merged__c = true;
            uow.registerDirty(eachOpportunity);
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description It collects a map of Opportunity Id with associated product families for
     * each Opportunity.
     * @JIRA# LEM-4258
     * @param opportunities
     * @return Map<Id, Set<String>>
     */
    private Map<Id, Set<String>> getOpportunityProductFamilies(Map<Id, Opportunity> opportunities) {
        Map<Id, Set<String>> opportunityIdToProductFamilies = new Map<Id, Set<String>>();
        Id opportunityId;
        String opportunityProductFamily;
        for (
            Aggregate eachAggregate : OpportunityLineItemsSelector.newInstance()
                .getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                    opportunities.keySet()
                )
        ) {
            opportunityId = (Id) eachAggregate.get(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS);
            opportunityProductFamily = (String) eachAggregate.get(
                AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS
            );
            if (!opportunityIdToProductFamilies.containsKey(opportunityId)) {
                opportunityIdToProductFamilies.put(opportunityId, new Set<String>());
            }
            opportunityIdToProductFamilies.get(opportunityId).add(opportunityProductFamily);
        }
        return opportunityIdToProductFamilies;
    }

    /**
     * @description It checks whether Opportunity is in contracting stage and
     * Nintex Id is not populated and associated Opportunity Products have family
     * other than bypassed product families:
     * ('Advertisement', 'Drive Promotion', 'Marketplace Promotion').
     * @JIRA# LEM-2132 & LEM-4258
     * @param opportunity
     * @param opportunityIdToProductFamilies
     * @return Boolean
     */
    private Boolean isEligibleOpportunityInOrBeyondContractingStage(
        Opportunity opportunity,
        Map<Id, Set<String>> opportunityIdToProductFamilies
    ) {
        Boolean isEligibleOpportunity =
            (opportunity.StageName == CONTRACTING_STAGE ||
            opportunity.StageName == CLOSED_WON) &&
            opportunity.Source__c != SOURCE_NINTEX &&
            !CONTRACT_CORRECTION.contains(opportunity.Opportunity_Sub_Type__c);
        Integer productFamilyTypeCount = 0;
        if (opportunityIdToProductFamilies.containsKey(opportunity.Id)) {
            for (String productFamily : opportunityIdToProductFamilies.get(opportunity.Id)) {
                if (
                    CONTRACTING_STAGE_VALIDATION_BYPASSED_PRODUCT_FAMILIES.contains(productFamily)
                ) {
                    continue;
                }
                ++productFamilyTypeCount;
            }
        }
        return isEligibleOpportunity && productFamilyTypeCount > 0;
    }
    /**
     * @description maps the Opportunity Id to the brief
     * @param briefs
     * @return Map<Id,List<Brief__c>>
     */
    public Map<Id, List<Brief__c>> mapOpportunityIdToListOfBrief(List<Brief__c> briefs) {
        Map<Id, List<Brief__c>> mapOIdToBrief = new Map<Id, List<Brief__c>>();
        Map<Id, List<Brief__c>> mapOfOppIdToBriefs = (Map<Id, List<Brief__c>>) groupById(
            briefs,
            Brief__c.Opportunity_Name__c
        );
        Map<Id, List<Brief__c>> mapOfAgencyOppIdToBriefs = (Map<Id, List<Brief__c>>) groupById(
            briefs,
            Brief__c.Agency_Opportunity_Name__c
        );
        if (!mapOfAgencyOppIdToBriefs.isEmpty()) {
            mapOIdToBrief.putAll(mapOfAgencyOppIdToBriefs);
        }
        if (!mapOfOppIdToBriefs.isEmpty()) {
            mapOIdToBrief.putAll(mapOfOppIdToBriefs);
        }
        return mapOIdToBrief;
    }
    /**
     * @description updates the briefs with synched fields from the Opportunity
     * @param opportunities
     * @param briefMap
     */
    public void updateBriefsFromOpportunity(
        List<Opportunity> opportunities,
        Map<Id, List<Brief__c>> briefMap
    ) {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opportunities);
        list<Brief__c> allBriefs = new List<Brief__c>();
        for (List<Brief__c> briefList : briefMap.values()) {
            allBriefs.addall(briefList);
        }
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Opportunity_To_Brief_Item_Mapping__mdt> opportunityToBriefMapping = OpportunityToBriefMappingSelector.newInstance()
            .getAllValues();
        for (Opportunity_To_Brief_Item_Mapping__mdt mapping : opportunityToBriefMapping) {
            if (
                mapping.BriefFieldAPIName__c != null &&
                mapping.OpportunityFieldAPIName__c != null
            ) {
                for (Brief__c oppBrief : allBriefs) {
                    if (oppMap.containsKey(oppBrief.Opportunity_Name__c)) {
                        oppBrief.put(
                            mapping.BriefFieldAPIName__c,
                            oppMap.get(oppBrief.Opportunity_Name__c)
                                .get(mapping.OpportunityFieldAPIName__c)
                        );
                        uow.registerDirty(oppBrief);
                    } else if (oppMap.containsKey(oppBrief.Agency_Opportunity_Name__c)) {
                        oppBrief.put(
                            mapping.BriefFieldAPIName__c,
                            oppMap.get(oppBrief.Agency_Opportunity_Name__c)
                                .get(mapping.OpportunityFieldAPIName__c)
                        );
                        uow.registerDirty(oppBrief);
                    }
                }
            }
        }
        commitUnitOfWork(uow);
    }
    /**
     * @description updates owner id on brief item
     * @param opps
     */
    public void updateBriefItemsFromOpportunity(List<Opportunity> opps) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
            oppMap.put(opp.Id, opp);
        }
        List<Brief_Item__c> brItems = BriefItemsSelector.newInstance()
            .selectByOpportunities(oppIds);
        for (Brief_Item__c briefItem : brItems) {
            if (oppMap.containsKey(briefItem.Opportunity_ID__c)) {
                briefItem.Opportunity_Owner__c = oppMap.get(briefItem.Opportunity_ID__c).OwnerId;
                uow.registerDirty(briefItem);
            }
        }
        commitUnitOfWork(uow);
    }
    /**
     * @description Group a list of SOBjects by any field on the SObject
     * This version of the method supports Passing in a refgerence field and returning aMap using an Id as the key
     * @param listOfRecords list of Sobject
     * @param filterField Property to get a map by (Lookup, Master-Detail Field, text field which holds a SFID)
     * @return [description]
     */
    public static Map<Id, List<SObject>> groupById(
        List<SObject> listOfRecords,
        Schema.SObjectField filterField
    ) {
        Map<Id, List<SObject>> mapListSobjectById = new Map<Id, List<SObject>>();
        for (SObject record : listOfRecords) {
            Id key = (Id) record.get(filterField);
            List<SObject> tempList;
            if ((tempList = mapListSobjectById.get(key)) == null) {
                mapListSobjectById.put(key, tempList = new List<SObject>());
            }
            tempList.add(record);
        }
        return mapListSobjectById;
    }

    /**
     * @description It updates Estimated # of Stores on opportunity with the value on Quote's 'Number of Stores' field.
     * @JIRA# LEM-14946
     * @param opportunityIdToNumberOfStores
     */
    public void updateOpportunityNoOfStoresByQuoteNoOfStores(
        Map<Id, Decimal> opportunityIdToNumberOfStores
    ) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        for (Id eachOpportunityId : opportunityIdToNumberOfStores.keySet()) {
            unitOfWork.registerDirty(
                new Opportunity(
                    Id = eachOpportunityId,
                    Estimated_Number_of_Stores__c = opportunityIdToNumberOfStores.get(
                        eachOpportunityId
                    )
                )
            );
        }
        try {
            commitUnitOfWork(unitOfWork);
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively.
     * @JIRA# LEM-14174
     * @param opportunityIdToChangedStatus
     */
    public void updateOpportunityStageByQuoteStatus(Map<Id, String> opportunityIdToChangedStatus) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        for (Id eachOpportunityId : opportunityIdToChangedStatus.keySet()) {
            Opportunity opp = new Opportunity();
            opp.Id = eachOpportunityId;
            opp.StageName = opportunityIdToChangedStatus.get(eachOpportunityId);
            if (opportunityIdToChangedStatus.get(eachOpportunityId) == CLOSED_WON) {
                opp.CloseDate = System.today();
            }
            unitOfWork.registerDirty(opp);
        }
        try {
            commitUnitOfWork(unitOfWork);
        } catch (Exception unitOfWorkException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It is used to update the Primary Contact on Opportunity.
     * @JIRA# LEM-14152
     * @param opportunityIdToPrimaryOCRContactId
     */
    public void updatePrimaryOCRContactOnOpportunity(
        Map<Id, Id> opportunityIdToPrimaryOCRContactId
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachOpportunityId : opportunityIdToPrimaryOCRContactId.keySet()) {
            OpportunitiesHandler.isUpdateRestricted = true;
            uow.registerDirty(
                new opportunity(
                    Id = eachOpportunityId,
                    Primary_Contact__c = opportunityIdToPrimaryOCRContactId.get(eachOpportunityId)
                )
            );
        }
        commitUnitOfWork(uow);
    }
    /**
     * @description It creates renewal Opportunity on Accounts having partnership expiration date
     * in next 90 days from today.
     * @param accountsToStartBatch
     */
    public void createRenewalOpportunityFromBatch(List<Account> accountsToStartBatch) {
        if (accountsToStartBatch.isEmpty()) {
            return;
        }
        InsertUnitOfWorkHelper insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        List<Database.SaveResult> renewalOpportunityInsertSaveResults;
        String opportunityName;
        Set<Id> accountIdsWithActiveAccountPlan = (new Map<Id, Account>(accountsToStartBatch))
            .keySet();
        Map<Id, Id> accountIdToAccountPlanId = new Map<Id, Id>();
        for (
            Account_Plan__c eachAccountPlan : AccountPlansSelector.newInstance()
                .selectActiveAccountPlanByAccounts(accountIdsWithActiveAccountPlan)
        ) {
            accountIdToAccountPlanId.put(eachAccountPlan.Account__c, eachAccountPlan.Id);
        }
        Map<Id, Opportunity> accountIdToOppMap = new Map<Id, Opportunity>();
        for (Account eachAccount : accountsToStartBatch) {
            Opportunity renewalOpportunity = new Opportunity();
            if (eachAccount.Partnership_Level__c == PARTNERSHIP_LEVEL_EXCLUSIVE) {
                opportunityName = EXCLUSIVITY_RENEWAL_OPPORTUNITY_NAME;
            } else if (eachAccount.Partnership_Level__c == PARTNERSHIP_LEVEL_PREFERRED) {
                opportunityName = PREFERRED_RENEWAL_OPPORTUNITY_NAME;
            }
            renewalOpportunity.Name = opportunityName;
            renewalOpportunity.StageName = PROSPECTING_STAGE;
            renewalOpportunity.OwnerId = eachAccount.OwnerId;
            renewalOpportunity.CloseDate = eachAccount.Partnership_Expiration_Date__c;
            renewalOpportunity.Deal_Type__c = STANDARD;
            renewalOpportunity.Type = EXISTING_TYPE_VALUE;
            renewalOpportunity.Opportunity_Sub_Type__c = UPGRADE_SUB_TYPE;
            renewalOpportunity.CurrencyIsoCode = eachAccount.CurrencyIsoCode;
            renewalOpportunity.Estimated_Number_of_Stores__c = eachAccount.Total_Number_Of_Active_Stores_Calculate__c;
            renewalOpportunity.AccountId = eachAccount.Id;
            if (
                !(accountIdToAccountPlanId.isEmpty()) &&
                accountIdToAccountPlanId.containsKey(eachAccount.Id)
            ) {
                renewalOpportunity.Account_Plan__c = accountIdToAccountPlanId.get(eachAccount.Id);
            }
            unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
            insertUnitOfWorkHelper.registerInsert(renewalOpportunity);
            accountIdToOppMap.put(eachAccount.Id, renewalOpportunity);
        }
        try {
            unitOfWorkInstance.commitWork();
            renewalOpportunityInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        } catch (Exception unitOfWorkException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.HIGH
                )
            );
        }
        //Calling Accounts Service to update the renewal Opportunity Lookup on Account.
        AccountsService.updateRenewalOpportunityCreatedFromBatchLookupOnAccount(accountIdToOppMap);
    }

    /**
     * @description It is used to concatenate 'Active' Mx Tag Associations on
     * Opportunities and Accounts.
     * @JIRA# LEM-18923, LEM-25211
     * @param mxTagAssociations
     */
    public void concatenateMxTagsOnSObjects(List<Mx_Tag_Association__c> mxTagAssociations) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> businessAccountIds = new Set<Id>();
        Map<Id, String> accountIdToConcatenatedMxTags = new Map<Id, String>();
        Map<Id, Set<String>> accountIdToMxTags = new Map<Id, Set<String>>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        UpdateUnitOfWorkHelper updateUnitOfWorkHelper = new UpdateUnitOfWorkHelper();
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        List<Database.SaveResult> updateSaveResults;
        if (mxTagAssociations.isEmpty()) {
            return;
        }
        for (Mx_Tag_Association__c eachMxTagAssociation : mxTagAssociations) {
            if (eachMxTagAssociation.Account__c != null) {
                accountIds.add(eachMxTagAssociation.Account__c);
                if (
                    eachMxTagAssociation.Account__r.RecordType.Name == ACCOUNT_RECORD_TYPE_BUSINESS
                ) {
                    businessAccountIds.add(eachMxTagAssociation.Account__c);
                }
            } else if (eachMxTagAssociation.Opportunity__c != null) {
                accountIds.add(eachMxTagAssociation.Opportunity_Account__c);
                businessAccountIds.add(eachMxTagAssociation.Opportunity_Account__c);
            }
        }
        if (businessAccountIds.isEmpty() && accountIds.isEmpty()) {
            return;
        }
        for (
            Mx_Tag_Association__c eachMxTagAssociation : MxTagAssociationsSelector.newInstance()
                .selectByBusinessAccountIds(accountIds)
        ) {
            if (eachMxTagAssociation.MxTagName__c != null) {
                if (!accountIdToMxTags.containsKey(eachMxTagAssociation.Account__c)) {
                    accountIdToMxTags.put(eachMxTagAssociation.Account__c, new Set<String>{});
                }
                accountIdToMxTags.get(eachMxTagAssociation.Account__c)
                    .add(eachMxTagAssociation.MxTagName__c);
            }
        }
        accountIdToConcatenatedMxTags = concatenateMxTags(accountIdToMxTags, businessAccountIds);
        accountsToUpdate = collectAccountsToUpdate(accountIdToConcatenatedMxTags);
        opportunitiesToUpdate = collectOpportunitiesToUpdate(
            accountIdToConcatenatedMxTags,
            businessAccountIds
        );
        if (opportunitiesToUpdate.size() > 0 || accountsToUpdate.size() > 0) {
            unitOfWorkInstance.registerWork(updateUnitOfWorkHelper);
            updateUnitOfWorkHelper.registerUpdate(accountsToUpdate);
            updateUnitOfWorkHelper.registerUpdate(opportunitiesToUpdate);
        }
        try {
            if (opportunitiesToUpdate.size() > 0 || accountsToUpdate.size() > 0) {
                unitOfWorkInstance.commitWork();
                updateSaveResults = updateUnitOfWorkHelper.saveResults;
            }
        } catch (Exception opportunityUpdateException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_MX_TAG_ASSOCIATION,
                        LOG_DOMAIN_SALES,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(opportunityUpdateException)
            );
        }
    }

    /**
     * @description It collects the Accounts to be updated with concatenated Mx Tag names.
     * @JIRA# LEM-25211
     * @param accountIdToConcatenatedMxTags
     * @return List<Account>
     **/
    private List<Account> collectAccountsToUpdate(Map<Id, String> accountIdToConcatenatedMxTags) {
        List<Account> accountsToUpdate = new List<Account>();
        for (Id eachAccountId : accountIdToConcatenatedMxTags.keySet()) {
            accountsToUpdate.add(
                new Account(
                    Id = eachAccountId,
                    Mx_Tag_Associations_Concatenated__c = accountIdToConcatenatedMxTags.get(
                        eachAccountId
                    )
                )
            );
        }
        return accountsToUpdate;
    }

    /**
     * @description It collects the Opportunities to be updated with concatenated Mx Tag names.
     * @JIRA# LEM-18923, LEM-25211
     * @param accountIdToConcatenatedMxTags
     * @param businessAccountIds
     * @return List<Opportunity>
     **/
    private List<Opportunity> collectOpportunitiesToUpdate(
        Map<Id, String> accountIdToConcatenatedMxTags,
        Set<Id> businessAccountIds
    ) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectAllOpenOpportunitiesByAccountIds(businessAccountIds)
        ) {
            eachOpportunity.Mx_Tag_Associations_Concatenated__c = accountIdToConcatenatedMxTags.get(
                eachOpportunity.AccountId
            );
            opportunitiesToUpdate.add(eachOpportunity);
        }
        return opportunitiesToUpdate;
    }

    /**
     * @description Method to concatenate MxTag Names
     * @JIRA# LEM-18923, LEM-25211
     * @param accountIdToMxTags
     * @param businessAccountIds
     * @return Map<Id, String>
     **/
    private Map<Id, String> concatenateMxTags(
        Map<Id, Set<String>> accountIdToMxTags,
        Set<Id> businessAccountIds
    ) {
        Map<Id, String> accountIdToConcatenatedMxTags = new Map<Id, String>();
        for (Id eachAccountId : accountIdToMxTags.keySet()) {
            if (accountIdToMxTags.containsKey(eachAccountId)) {
                accountIdToConcatenatedMxTags.put(
                    eachAccountId,
                    String.join(
                        (Iterable<String>) accountIdToMxTags.get(eachAccountId),
                        SEPARATOR_SEMI_COLON
                    )
                );
            }
        }
        return accountIdToConcatenatedMxTags;
    }
}