/**
 * @author Deloitte
 * @date 08/25/2022
 * @description Service implementation class for Parent Work Orders creation related logic.
 * Supressing Warning since NCSS method count is high.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.NcssMethodCount')
public inherited sharing class ParentWorkOrdersCreationServiceImpl implements IParentWorkOrdersCreationService {
    private static final List<String> COUNTRIES_TO_BYPASS_PDOA_CALCULATION = new List<String>{
        'US',
        'CA'
    };
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String CREATION_SOURCE_NINTEX = 'Nintex';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DAY_OF_WEEK_SAT = 'Sat';
    private static final String DAY_OF_WEEK_SUN = 'Sun';
    private static final String DRIVE_AUTO_ACTIVATION_SUPPORTED = 'Yes';
    private static final String DRIVE_NINTEX_ID_FIELD = 'Drive_Nintex_Id__c';
    private static final String INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION = 'WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION';
    private static final String DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String INTEGRATED_FRANCHISE_USE_CASE = 'Integrated Franchise';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String LOG_SERVICE_WORK_ORDER = 'Work Order Service';
    private static final String MARKETPLACE_NINTEX_ID_FIELD = 'Marketplace_Nintex_Id__c';
    private static final String NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP = 'Change of Ownership';
    private static final String NINTEX_USE_CASE_NEW_ADDITIONAL_STORES = 'New additional stores';
    private static final String NINTEX_USE_CASE_NEW_FRANCHISE_UNKNOWN = 'New Franchise - Unknown';
    private static final String NINTEX_USE_CASE_SSMO = 'SSMO';
    private static final List<String> NINTEX_USE_CASE_TO_BYPASS_PDOA_CALCULATION = new List<String>{
        'Change of Ownership',
        'New additional stores',
        'New Franchise - Unknown'
    };
    private static final String OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_OUT = 'Opt-Out';
    private static final String OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE = 'Rate Change';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String PROVISIONING_PROCESS_AUTOMATIC = 'Automatic';
    private static final String PROVISIONING_PROCESS_FIELD = 'Business_to_Store_Assignment__c';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String TODAY = 'Today';
    private static final String VALUE_TO_APPLY_TYPE_SELF = 'Self';
    private static final String WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String YESTERDAY = 'Yesterday';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String RECORD_CREATION_STATUS_WO_CREATION_SUCCESS = 'WO Creation Success';
    private static final String WORK_ORDER_CREATION_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String WORKORDER_TYPE_POSTSALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORKORDER_SUB_TYPE_POSTSALES = 'Rate Change';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String CREATION_SOURCE_MANAGE_PRICING = 'Manage Pricing';
    private static final String WORKORDER_PROVISIONING_PROCESS = 'Automatic';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String RESSMO_CREATION_SOURCE = 'RESSMO';
    private static final String USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION = 'PHOTOSHOOT_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION = 'MX_FRAUD_DOCUMENT_INTEGRATION';
    private static final String USECASE_NAME_TABLET_OUTBOUND_INTEGRATION = 'TABLET_OUTBOUND_INTEGRATION';
    private Set<Id> contractIds;
    private Map<Id, Set<String>> contractIdToWorkOrderTypesToCreate;
    private InsertUnitOfWorkHelper insertUnitOfWorkHelper;
    private List<Opportunity> filteredOpportunities;
    Map<String, Account> nintexIdToStoreAccount;
    private Map<String, Nintex_Work_Order_Mapping__mdt> nintexUseCaseToMapping;
    private Map<String, List<Opportunity_Status_PDOA_Mapping__mdt>> nintexUseCaseToPDOAMappings;
    private List<Opportunity> opportunitiesByWorkOrder;
    private fflib_ISObjectUnitOfWork unitOfWorkInstance;
    private List<Database.SaveResult> workOrderInsertSaveResults;
    private List<WorkOrder> workOrdersToInsert;
    private String workOrderSubType;
    private enum ObjectNames {
        ACCOUNT,
        OPPORTUNITY
    }
    private static final Map<String, ObjectNames> OBJECTNAMETOOBJECTNAMEENUMVALUES = new Map<String, ObjectNames>{
        'Account' => ObjectNames.ACCOUNT,
        'Opportunity' => ObjectNames.OPPORTUNITY
    };
    private enum NintexUseCases {
        NEW_ADDITIONAL_STORES,
        NEW_FRANCHISE_UNKNOWN,
        SSMO,
        CHANGE_OF_OWNERSHIP
    }
    private static final Map<String, NintexUseCases> NINTEXUSECASEMAPPINGS = new Map<String, NintexUseCases>{
        NINTEX_USE_CASE_NEW_ADDITIONAL_STORES => NintexUseCases.NEW_ADDITIONAL_STORES,
        NINTEX_USE_CASE_NEW_FRANCHISE_UNKNOWN => NintexUseCases.NEW_FRANCHISE_UNKNOWN,
        NINTEX_USE_CASE_SSMO => NintexUseCases.SSMO,
        NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP => NintexUseCases.CHANGE_OF_OWNERSHIP
    };

    /**
     * @description Default constructor to instantiate variables.
     */
    public ParentWorkOrdersCreationServiceImpl() {
        this.contractIds = new Set<Id>();
        this.contractIdToWorkOrderTypesToCreate = new Map<Id, Set<String>>();
        this.filteredOpportunities = new List<Opportunity>();
        this.nintexIdToStoreAccount = new Map<String, Account>();
        this.nintexUseCaseToMapping = new Map<String, Nintex_Work_Order_Mapping__mdt>();
        this.nintexUseCaseToPDOAMappings = new Map<String, List<Opportunity_Status_PDOA_Mapping__mdt>>();
        this.opportunitiesByWorkOrder = new List<Opportunity>();
        this.unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        this.insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        // Register custom insert unit of work to allow partial success
        unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
        workOrdersToInsert = new List<WorkOrder>();
        workOrderSubType = null;
    }

    /**
     * @description It is used to create parent Work Orders based on Nintex use case
     * from the passed Opportunities.
     * @JIRA# LEM-2348
     * @param opportunities
     */
    public void createParentWorkOrdersByNintexUseCases(List<Opportunity> opportunities) {
        collectNintexUseCaseMappings();
        filteredOpportunities = filterOpportunities(opportunities);
        getStoreAccountsByNintexId(filteredOpportunities);
        contractIdToWorkOrderTypesToCreate = SubscriptionsService.getExistingSubscriptionsForContracts(
            contractIds
        );
        for (Opportunity eachOpportunity : filteredOpportunities) {
            if (isNintexUseCaseOnOpportunityRateChangeWithOptOut(eachOpportunity)) {
                continue;
            }
            if (eachOpportunity.Account.Segment__c == ACCOUNT_SEGMENT_SMB) {
                createParentWorkOrderBySMBOpportunity(eachOpportunity);
            } else {
                createParentWorkOrderByOpportunity(
                    eachOpportunity,
                    nintexIdToStoreAccount.get(getNintexId(eachOpportunity))
                );
            }
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        createLogEntries(opportunitiesByWorkOrder);
    }

    /**
     * @description It is used to create parent Work Orders when Interface Transactions are passed.
     * @JIRA# LEM-15362
     * @param interfaceTransactions
     */
    @SuppressWarnings('PMD.NCSSMethodCount')
    public void createParentWorkOrder(List<Interface_Transaction__c> interfaceTransactions) {
        Set<String> uniqueIdentifiers = new Set<String>();
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            if (
                !INTERFACE_TRANSACTION_CONFIG_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION.equalsIgnoreCase(
                    eachInterfaceTransaction.Interface_Transaction_Configuration_Name__c.toUpperCase()
                )
            ) {
                continue;
            }
            WorkOrderGenerationWrapper workOrderGenerationWrapper = (WorkOrderGenerationWrapper) JSON.deserialize(
                eachInterfaceTransaction.Payload__c,
                WorkOrderGenerationWrapper.class
            );
            WorkOrder workOrderInstance = new WorkOrder(
                Type__c = workOrderGenerationWrapper.getType(),
                Sub_Type__c = workOrderGenerationWrapper.getSubType(),
                Status = workOrderGenerationWrapper.getStatus(),
                Proposed_Date_of_Activation__c = workOrderGenerationWrapper.getProposedDateOfActivation(),
                Creation_Source__c = workOrderGenerationWrapper.getCreationSource(),
                Unique_Identifier__c = workOrderGenerationWrapper.getUniqueIdentifier(),
                Business_to_Store_Assignment__c = workOrderGenerationWrapper.getProvisioningProcess(),
                Provisioning_Status__c = workOrderGenerationWrapper.getProvisioningStatus(),
                Order_Protocol__c = workOrderGenerationWrapper.getOrderProtocol(),
                Associated_Account_Ids__c = workOrderGenerationWrapper.getStoreAccountIds(),
                Activated_Centrally_AC__c = workOrderGenerationWrapper.getActivatedCentrally(),
                Menu_to_be_Completed_By__c = workOrderGenerationWrapper.getMenuToBeCompletedBy(),
                Work_Order_Source__c = workOrderGenerationWrapper.getWorkOrderSource(),
                Mx_Requested_Photoshoot__c = workOrderGenerationWrapper.getPhotoShootRequest(),
                Bundled_with_Marketplace__c = workOrderGenerationWrapper.getBundledWithMarketplace(),
                Menu_Setup_Method__c = workOrderGenerationWrapper.getMenuSetUpMethod(),
                Photoshoot_Date__c = workOrderGenerationWrapper.getPhotoShootDate(),
                Photoshoot_Time__c = workOrderGenerationWrapper.getPhotoShootTime(),
                Sales_Notes_for_Menu_Team__c = workOrderGenerationWrapper.getSalesNotesForMenuTeam(),
                Proposed_Date_of_Implementation__c = workOrderGenerationWrapper.getProposedDateofImplementation(),
                Integration_Request_Id__c = workOrderGenerationWrapper.getIntegrationRequestId(),
                HasWorkPlansGenerated__c = workOrderGenerationWrapper.getHasWorkPlansGenerated(),
                Business_Id__c = workOrderGenerationWrapper.getBusinessId(),
                POS_Integration_Type__c = workOrderGenerationWrapper.getPosIntegrationType(),
                Sales_Rep_Name__c = workOrderGenerationWrapper.getSalesRepName()
            );
            if (!String.isBlank(workOrderGenerationWrapper.getOriginatingWorkOrderId())) {
                workOrderInstance.Originating_Work_Order__c = workOrderGenerationWrapper.getOriginatingWorkOrderId();
            }
            if (!String.isBlank(workOrderGenerationWrapper.getAccountId())) {
                workOrderInstance.AccountId = workOrderGenerationWrapper.getAccountId();
            }
            if (!String.isBlank(workOrderGenerationWrapper.getOpportunityId())) {
                workOrderInstance.Opportunity__c = workOrderGenerationWrapper.getOpportunityId();
            }
            if (!String.isBlank(workOrderGenerationWrapper.getContractId())) {
                workOrderInstance.Contract__c = workOrderGenerationWrapper.getContractId();
            }
            if (workOrderGenerationWrapper.getType() == WORK_ORDER_TYPE_ADS_AND_PROMOS) {
                workOrderInstance.Estimated_Number_Of_Stores__c = workOrderGenerationWrapper.getEstimatedNumberofStores();
            }
            workOrderInstance.Mx_Onboarding_Link__c = getMxOnboardingLinkId(
                workOrderGenerationWrapper
            );
            if (
                workOrderGenerationWrapper.getCreationSource() ==
                WORK_ORDER_CREATION_SOURCE_ONBOARDING_INPUTS ||
                workOrderGenerationWrapper.getCreationSource() == RESSMO_CREATION_SOURCE
            ) {
                uniqueIdentifiers.add(workOrderGenerationWrapper.getUniqueIdentifier());
            }
            unitOfWorkInstance.registerNew(workOrderInstance);
        }
        unitOfWorkInstance.commitWork();
        updateRecordCreationStatusOnMxOnboardingLinks(uniqueIdentifiers);
    }

    /**
     * @description It is used to map the Mx_Onboarding_Link__c field value for creating Work Order.
     * @param workOrderGenerationWrapper
     * @return String
     */
    private String getMxOnboardingLinkId(WorkOrderGenerationWrapper workOrderGenerationWrapper) {
        String mxOnboardingLinkId = String.isNotBlank(
                workOrderGenerationWrapper.getMxOnboardingLinkId()
            )
            ? workOrderGenerationWrapper.getMxOnboardingLinkId()
            : null;
        return mxOnboardingLinkId;
    }

    /**
     * @description It is used to convert the passed value to date and
     * return the calculated date value by adding the passed offset.
     * @param valueToConvert
     * @param offsetToAdd
     * @return Date
     */
    private Date calculateDate(Object valueToConvert, Integer offsetToAdd) {
        Date calculatedDate;
        if (valueToConvert == null) {
            return calculatedDate;
        }
        if (offsetToAdd == null) {
            offsetToAdd = 0;
        }
        if (String.valueOf(valueToConvert) == TODAY) {
            calculatedDate = calculateDateExcludingWeekends(System.today(), offsetToAdd);
        } else if (String.valueOf(valueToConvert) == YESTERDAY) {
            calculatedDate = calculateDateExcludingWeekends(System.today(), offsetToAdd - 1);
        } else {
            Date dateValue = Date.valueOf(valueToConvert);
            calculatedDate = calculateDateExcludingWeekends(
                DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day()),
                offsetToAdd
            );
        }
        return calculatedDate;
    }

    /**
     * @description It returns the calculated date excluding weekends based on the passed start date
     * and offset to add.
     * @JIRA# LEM-4162
     * @param startDate
     * @param offsetToAdd
     * @return Date
     */
    private Date calculateDateExcludingWeekends(Datetime startDate, Integer offsetToAdd) {
        Date startDateGMT = startDate.dateGMT();
        while (offsetToAdd > 0) {
            startDateGMT = startDateGMT.addDays(1);
            if (!isWeekend(startDateGMT)) {
                offsetToAdd = offsetToAdd - 1;
            }
        }
        return startDateGMT;
    }

    /**
     * @description It checks whether the passed datetime is on Saturday or Sunday.
     * @JIRA# LEM-4162
     * @param dateTimeToValidate
     * @return Boolean
     */
    private Boolean isWeekend(Datetime dateTimeToValidate) {
        return dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SAT ||
            dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUN;
    }

    /**
     * @description It is used to calculate offset value for PDOA population
     * by comparing the following conditions:
     * 1. Sub-Type = Auto-Activations
     * @param opportunityPDOAMapping
     * @param offset
     * @return Integer
     */
    private Integer calculateOffsetToAdd(
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping,
        Integer offset
    ) {
        Integer calculatedOffset = offset;
        if (
            workOrderSubType != null &&
            opportunityPDOAMapping.Sub_Type_To_Override__c == workOrderSubType
        ) {
            calculatedOffset = (Integer) opportunityPDOAMapping.Override_Offset_To_Apply__c;
        }
        return calculatedOffset;
    }

    /**
     * @description It is used to compare conditions to populate PDOA on Work Order.
     * @param opportunityPDOAMapping
     * @param opportunity
     * @param storeAccount
     * @return Date
     */
    private Date calcuatePDOAByMappings(
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping,
        Opportunity opportunity,
        Account storeAccount
    ) {
        Date proposedDateOfActivation;
        SObject sObjectToRefer = getSObjectToRefer(
            opportunityPDOAMapping,
            opportunity,
            storeAccount
        );
        if (!opportunityPDOAMapping.Compare_Values__c) {
            proposedDateOfActivation = getPDOABySelfMapping(sObjectToRefer, opportunityPDOAMapping);
        }
        if (hasComparatorConditionSatisfied(sObjectToRefer, opportunityPDOAMapping)) {
            proposedDateOfActivation = getPDOAByComparingValues(
                opportunityPDOAMapping,
                sObjectToRefer
            );
        }
        return proposedDateOfActivation;
    }

    /**
     * @description It is used to get mappings of Nintex use case to Work Order
     * type, sub-type and PDOA.
     */
    private void collectNintexUseCaseMappings() {
        Set<String> nintexUseCaseMappingDeveloperNames = new Set<String>();
        for (
            Nintex_Work_Order_Mapping__mdt eachMapping : NintexWorkOrderMappingsSelector.newInstance()
                .getAllMappings()
        ) {
            nintexUseCaseToMapping.put(eachMapping.Nintex_Use_Case__c, eachMapping);
            nintexUseCaseMappingDeveloperNames.add(eachMapping.DeveloperName);
        }
        collectStatusPDOAMappings(nintexUseCaseMappingDeveloperNames);
    }

    /**
     * @description It is used to get mappings of Nintex use case to
     * Opportunity status to PDOA mappings.
     * @param nintexUseCaseMappingDeveloperNames
     */
    private void collectStatusPDOAMappings(Set<String> nintexUseCaseMappingDeveloperNames) {
        for (
            Opportunity_Status_PDOA_Mapping__mdt eachPDOAMapping : OpportunityStatusPDOAMappingsSelector.newInstance()
                .selectByNintexUseCaseMappings(nintexUseCaseMappingDeveloperNames)
        ) {
            if (
                !nintexUseCaseToPDOAMappings.containsKey(
                    eachPDOAMapping.Nintex_Mapping__r.Nintex_Use_Case__c
                )
            ) {
                nintexUseCaseToPDOAMappings.put(
                    eachPDOAMapping.Nintex_Mapping__r.Nintex_Use_Case__c,
                    new List<Opportunity_Status_PDOA_Mapping__mdt>()
                );
            }
            nintexUseCaseToPDOAMappings.get(eachPDOAMapping.Nintex_Mapping__r.Nintex_Use_Case__c)
                .add(eachPDOAMapping);
        }
    }

    /**
     * @description It is used to create log records for the issues recorded
     * while generating child Work Orders.
     * @param dmlRecords
     */
    private void createLogEntries(List<SObject> dmlRecords) {
        ILogger loggerInstance;
        if (!dmlRecords.isEmpty()) {
            loggerInstance = Logger.add(
                LogEntry.newDmlLog(
                    workOrderInsertSaveResults,
                    dmlRecords,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
        if (loggerInstance == null) {
            return;
        }
        loggerInstance.publish();
    }

    /**
     * @description Utility method to check if "Storefront" is specified in Packages_with_Products__c.
     * @param opportunity
     * @return Boolean indicating if "Storefront" is present.
     */
    private Boolean checkHasStorefront(Opportunity opportunity) {
        return String.isNotBlank(opportunity.Packages_with_Products__c) &&
            opportunity.Packages_with_Products__c.contains(WORKORDER_TYPE_STOREFRONT);
    }

    /**
     * @description It is used to create parent Work Order using the details from
     * the passed Opportunity and store Account.
     * @JIRA# LEM-2348
     * @param opportunity
     * @param storeAccount
     */
    private void createParentWorkOrderByOpportunity(Opportunity opportunity, Account storeAccount) {
        Nintex_Work_Order_Mapping__mdt nintexUseCaseMapping = nintexUseCaseToMapping.get(
            opportunity.Nintex_Use_Case__c
        );
        String workOrderType = nintexUseCaseMapping?.Work_Order_Type__c;
        String workOrderProvisioningProcess = nintexUseCaseMapping
            ?.Work_Order_Provisioning_Process__c;
        workOrderSubType = getWorkOrderSubType(
            opportunity.Contract,
            opportunity.Nintex_Use_Case__c,
            workOrderType,
            nintexUseCaseMapping?.Work_Order_Sub_Type__c,
            workOrderProvisioningProcess
        );

        Date proposedDateOfActivation = populatePDOAOnWorkOrders(opportunity, storeAccount);

        // Create the main work order
        WorkOrder workOrderInstance = new WorkOrder(
            AccountId = opportunity.AccountId,
            Activated_Centrally_AC__c = storeAccount?.Activated_Centrally_AC__c,
            Contract__c = opportunity.ContractId,
            Creation_Source__c = CREATION_SOURCE_NINTEX,
            Menu_Setup_Method__c = storeAccount?.Menu_Setup_Method__c,
            Menu_to_be_Completed_By__c = storeAccount?.Menu_to_be_Completed_By__c,
            Opportunity__c = opportunity.Id,
            Order_Protocol__c = storeAccount?.Order_Protocol__c,
            OwnerId = opportunity.OwnerId,
            Proposed_Date_of_Activation__c = proposedDateOfActivation,
            Status = STATUS_CONFIRMED,
            Sub_Type__c = workOrderSubType,
            Type__c = workOrderType,
            Withholding_with_Auto_Activations__c = isWithholdingWithAutoActivations(opportunity),
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        workOrderInstance.put(PROVISIONING_PROCESS_FIELD, workOrderProvisioningProcess);
        workOrdersToInsert.add(workOrderInstance);

        // JIRA# LEM-22496 Use the new method to check for Storefront
        if (checkHasStorefront(opportunity)) {
            createStorefrontParentWorkOrderByNintexUsesCases(opportunity, workOrderInstance);
        }

        opportunitiesByWorkOrder.add(opportunity);
        // leveraging custom registerNew() method for partial success insertion.
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
    }

    /**
     * @description It is used to create parent Work Order for “SMB” Opportunity.
     * TODO: Fix PMD.NCSSMethodCount SCA issue.
     * @JIRA# LEM-15361
     * @param opportunity
     */
    private void createParentWorkOrderBySMBOpportunity(Opportunity opportunity) {
        Nintex_Work_Order_Mapping__mdt nintexUseCaseMapping = nintexUseCaseToMapping.get(
            opportunity.Nintex_Use_Case__c
        );
        if (nintexUseCaseMapping == null) {
            return;
        }
        String workOrderType = nintexUseCaseMapping?.Work_Order_Type__c;
        String workOrderProvisioningProcess = nintexUseCaseMapping
            ?.Work_Order_Provisioning_Process__c;
        workOrderSubType = getWorkOrderSubType(
            opportunity.Contract,
            opportunity.Nintex_Use_Case__c,
            workOrderType,
            nintexUseCaseMapping?.Work_Order_Sub_Type__c,
            workOrderProvisioningProcess
        );

        WorkOrder workOrderInstance = new WorkOrder(
            AccountId = opportunity.AccountId,
            Business_Id__c = opportunity.Business_ID__c,
            Contract__c = opportunity.ContractId,
            Creation_Source__c = CREATION_SOURCE_NINTEX,
            Opportunity__c = opportunity.Id,
            OwnerId = opportunity.OwnerId,
            Status = STATUS_PLANNING,
            Sub_Type__c = workOrderSubType,
            Type__c = workOrderType,
            Business_to_Store_Assignment__c = workOrderProvisioningProcess,
            Provisioning_Status__c = PROVISIONING_STATUS_NOT_STARTED,
            Withholding_with_Auto_Activations__c = isWithholdingWithAutoActivations(opportunity),
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );

        setFieldsValuesForNintexUseCases(opportunity, workOrderInstance);
        workOrdersToInsert.add(workOrderInstance);

        // JIRA# LEM-22496 Use the new method to check for Storefront
        if (checkHasStorefront(opportunity)) {
            createStorefrontParentWorkOrderByNintexUsesCases(opportunity, workOrderInstance);
        }

        opportunitiesByWorkOrder.add(opportunity);
        // leveraging custom registerNew() method for partial success insertion.
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
    }

    /**
     * @description It is used to create Storefront Work Order if the Contract contains
     * Storefront Products as well.
     * @JIRA# LEM-21419
     * @param opportunity
     * @param workOrderInstance
     */
    private void createStorefrontParentWorkOrderByNintexUsesCases(
        Opportunity opportunity,
        WorkOrder workOrderInstance
    ) {
        if (
            workOrderInstance.Type__c != WORKORDER_TYPE_MARKETPLACE ||
            !contractIdToWorkOrderTypesToCreate.get(opportunity.ContractId)
                .contains(WORKORDER_TYPE_STOREFRONT)
        ) {
            return;
        }
        WorkOrder storefrontWorkOrderInstance = workOrderInstance.clone(false, false, false, false);
        storefrontWorkOrderInstance.Type__c = WORKORDER_TYPE_STOREFRONT;
        storefrontWorkOrderInstance.Bundled_with_Marketplace__c = BUNDLED_WITH_MARKETPLACE_YES;
        workOrdersToInsert.add(storefrontWorkOrderInstance);
        opportunitiesByWorkOrder.add(opportunity);
        insertUnitOfWorkHelper.registerInsert(storefrontWorkOrderInstance);
    }

    /**
     * @description It is used to get mappings of Nintex use case to Work Order type and sub-type.
     * @param opportunities
     * @return List<Opportunity>
     */
    private List<Opportunity> filterOpportunities(List<Opportunity> opportunities) {
        Map<Id, Opportunity> opportunitiesToProcess = new Map<Id, Opportunity>(opportunities);
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentWorkOrdersByOpportunityIds(opportunitiesToProcess.keySet())
        ) {
            if (hasExistingParentWorkOrder(eachWorkOrder)) {
                opportunitiesToProcess.remove(eachWorkOrder.Opportunity__c);
            }
        }
        return opportunitiesToProcess.values();
    }

    /**
     * @description It is used to get Drive or Marketplace Nintex Id from the passed Opportunity.
     * @param sObjectInstance
     * @return String
     */
    private String getNintexId(Sobject sObjectInstance) {
        return String.isNotBlank(String.valueOf(sObjectInstance.get(MARKETPLACE_NINTEX_ID_FIELD)))
            ? String.valueOf(sObjectInstance.get(MARKETPLACE_NINTEX_ID_FIELD))
            : String.valueOf(sObjectInstance.get(DRIVE_NINTEX_ID_FIELD));
    }

    /**
     * @description It is used to get the proposed date of activation by comparing
     * values from the custom metadata.
     * @param opportunityPDOAMapping
     * @param sObjectToRefer
     * @return Date
     */
    private Date getPDOAByComparingValues(
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping,
        SObject sObjectToRefer
    ) {
        Date proposedDateOfActivation;
        if (
            String.isBlank(opportunityPDOAMapping.Value_To_Apply__c) ||
            opportunityPDOAMapping.Value_To_Apply_Type__c == VALUE_TO_APPLY_TYPE_SELF
        ) {
            proposedDateOfActivation = getPDOABySelfMapping(sObjectToRefer, opportunityPDOAMapping);
        } else {
            proposedDateOfActivation = calculateDate(
                opportunityPDOAMapping.Value_To_Apply__c,
                calculateOffsetToAdd(
                    opportunityPDOAMapping,
                    (Integer) opportunityPDOAMapping.Offset_To_Apply__c
                )
            );
        }
        return proposedDateOfActivation;
    }

    /**
     * @description It is used to return Proposed Date of Activation using field on
     * object to refer from the custom metdata.
     * @param sObjectToRefer
     * @param opportunityPDOAMapping
     * @return Date
     */
    private Date getPDOABySelfMapping(
        SObject sObjectToRefer,
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping
    ) {
        return calculateDate(
            sObjectToRefer.get(opportunityPDOAMapping.Field_To_Refer__c),
            calculateOffsetToAdd(
                opportunityPDOAMapping,
                (Integer) opportunityPDOAMapping.Offset_To_Apply__c
            )
        );
    }

    /**
     * @description It is used to get the object to be referred from the custom metadata.
     * @param opportunityPDOAMapping
     * @param opportunity
     * @param storeAccount
     * @return SObject
     */
    private SObject getSObjectToRefer(
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping,
        Opportunity opportunity,
        Account storeAccount
    ) {
        SObject sObjectToRefer;
        switch on OBJECTNAMETOOBJECTNAMEENUMVALUES.get(opportunityPDOAMapping.Object_To_Refer__c) {
            when ACCOUNT {
                sObjectToRefer = storeAccount;
            }
            when OPPORTUNITY {
                sObjectToRefer = opportunity;
            }
        }
        return sObjectToRefer;
    }

    /**
     * @description It is used to get store Account details using Nintex Id
     * from the passed Opportunities.
     * @param opportunities
     */
    private void getStoreAccountsByNintexId(List<Opportunity> opportunities) {
        Set<String> nintexIds = new Set<String>();
        for (Opportunity eachOpportunity : opportunities) {
            nintexIds.add(getNintexId(eachOpportunity));
            contractIds.add(eachOpportunity.ContractId);
        }
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectStoreAccountsByMarketplaceOrDriveNintexIds(nintexIds)
        ) {
            if (String.isNotBlank(eachStoreAccount.Marketplace_Nintex_Id__c)) {
                nintexIdToStoreAccount.put(
                    eachStoreAccount.Marketplace_Nintex_Id__c,
                    eachStoreAccount
                );
            }
            if (String.isNotBlank(eachStoreAccount.Drive_Nintex_Id__c)) {
                nintexIdToStoreAccount.put(eachStoreAccount.Drive_Nintex_Id__c, eachStoreAccount);
            }
        }
    }

    /**
     * @description It is used to get Work Order sub-type value according to the criteria.
     * @JIRA# LEM-2659, LEM-10519
     * @param contractInstance
     * @param nintexUseCase
     * @param workOrderType
     * @param workOrderSubType
     * @param workOrderProvisioningProcess
     * @return String
     */
    private String getWorkOrderSubType(
        Contract contractInstance,
        String nintexUseCase,
        String workOrderType,
        String workOrderSubType,
        String workOrderProvisioningProcess
    ) {
        String driveAutoProvisioningIndicatorValue = (String) contractInstance
            ?.get(System.Label.DriveAutoProvisioningIndicator);
        if (
            workOrderType == WORK_ORDER_TYPE_DRIVE &&
            workOrderProvisioningProcess == PROVISIONING_PROCESS_AUTOMATIC
        ) {
            if (
                String.isNotBlank(driveAutoProvisioningIndicatorValue) &&
                driveAutoProvisioningIndicatorValue == DRIVE_AUTO_ACTIVATION_SUPPORTED
            ) {
                // Returns Auto-Activations when "Drive Auto Activation Supported" is 'Yes' on the passed Contract.
                workOrderSubType = DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS;
            } else if (
                nintexUseCase == INTEGRATED_FRANCHISE_USE_CASE &&
                contractInstance.Payment_Method__c == WITHHOLDING
            ) {
                /*
                 * Returns Withholding when "Nintex Use Case" is 'Integrated Franchise' and
                 * "Payment Method" is 'Withholding' on the passed Contract.
                 */
                workOrderSubType = WITHHOLDING;
            }
        }
        return workOrderSubType;
    }

    /**
     * @description It is used to check whether comparison condition is satisfied
     * for the passed SObject.
     * @param sObjectToRefer
     * @param opportunityPDOAMapping
     * @return Boolean
     */
    private Boolean hasComparatorConditionSatisfied(
        SObject sObjectToRefer,
        Opportunity_Status_PDOA_Mapping__mdt opportunityPDOAMapping
    ) {
        return LogicalComparatorFactory.getComparator(opportunityPDOAMapping.Operator__c)
            .compare(
                calculateDate(sObjectToRefer?.get(opportunityPDOAMapping.Field_To_Refer__c), null),
                calculateDate(
                    opportunityPDOAMapping.Value_To_Compare__c,
                    calculateOffsetToAdd(
                        opportunityPDOAMapping,
                        (Integer) opportunityPDOAMapping.Offset_To_Compare__c
                    )
                )
            );
    }

    /**
     * @description It is used to identify the existing parent Work Order
     * associated with Opportunity matching Nintex use case mapping.
     * @param workOrder
     * @return Boolean
     */
    private Boolean hasExistingParentWorkOrder(WorkOrder workOrder) {
        if (!nintexUseCaseToMapping.containsKey(workOrder.Opportunity__r.Nintex_Use_Case__c)) {
            return false;
        }
        Nintex_Work_Order_Mapping__mdt nintexUseCaseMapping = nintexUseCaseToMapping.get(
            workOrder.Opportunity__r.Nintex_Use_Case__c
        );
        return nintexUseCaseMapping.Work_Order_Type__c == workOrder.Type__c &&
            ((String.isBlank(workOrder.Sub_Type__c) ||
            ((String.isNotBlank(workOrder.Sub_Type__c) &&
            nintexUseCaseMapping.Work_Order_Sub_Type__c == workOrder.Sub_Type__c))));
    }

    /**
     * @description It checks whether "Franchise Amendment Process" field value is "Opt-Out" when
     * "Nintex Use Case" field value is "Rate Change" on the passed Opportunity.
     * @param opportunity
     * @return Boolean
     */
    private Boolean isNintexUseCaseOnOpportunityRateChangeWithOptOut(Opportunity opportunity) {
        return opportunity.Nintex_Use_Case__c == OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE &&
            String.isNotBlank(opportunity.FranchiseAmendmentProcess__c) &&
            opportunity.FranchiseAmendmentProcess__c ==
            OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_OUT;
    }

    /**
     * @description It is used to evaluate Auto-Activations with Withholding according to the criteria.
     * @JIRA# LEM-10519, LEM-10769
     * @param opportunityInstance
     * @return Boolean
     */
    private Boolean isWithholdingWithAutoActivations(Opportunity opportunityInstance) {
        return opportunityInstance?.Nintex_Use_Case__c == INTEGRATED_FRANCHISE_USE_CASE &&
            opportunityInstance.Contract?.Payment_Method__c == WITHHOLDING &&
            opportunityInstance.Contract?.Drive_Auto_Activation_Supported__c ==
            DRIVE_AUTO_ACTIVATION_SUPPORTED;
    }

    /**
     * @description It is used to get Proposed Date of Activation by comparing conditions
     * and calculating PDOA using the custom metadata.
     * @JIRA# LEM-2796
     * @param opportunity
     * @param storeAccount
     * @return Date
     */
    private Date populatePDOAOnWorkOrders(Opportunity opportunity, Account storeAccount) {
        Date proposedDateOfActivation;
        if (
            !nintexUseCaseToPDOAMappings.containsKey(opportunity.Nintex_Use_Case__c) ||
            (opportunity.StageName == OPPORTUNITY_STAGE_CLOSED_WON) &&
            NINTEX_USE_CASE_TO_BYPASS_PDOA_CALCULATION.contains(opportunity.Nintex_Use_Case__c) &&
            (COUNTRIES_TO_BYPASS_PDOA_CALCULATION.contains(storeAccount?.BillingCountryCode))
        ) {
            return storeAccount?.Proposed_Date_of_Activation__c;
        }
        for (
            Opportunity_Status_PDOA_Mapping__mdt eachPDOAMapping : nintexUseCaseToPDOAMappings.get(
                opportunity.Nintex_Use_Case__c
            )
        ) {
            if (eachPDOAMapping.Opportunity_Status__c != opportunity.StageName) {
                continue;
            }
            proposedDateOfActivation = calcuatePDOAByMappings(
                eachPDOAMapping,
                opportunity,
                storeAccount
            );
            if (proposedDateOfActivation != null) {
                break;
            }
        }
        if (proposedDateOfActivation == null) {
            proposedDateOfActivation = storeAccount?.Proposed_Date_of_Activation__c;
        }
        return proposedDateOfActivation;
    }

    /**
     * @description It is used to create parent Work Orders for Rate change request flow.
     * @JIRA# LEM-12932
     * @param rcrList
     */
    public void createParentWorkOrdersByRateChangeRequest(List<Rate_Change_Request__c> rcrList) {
        if (rcrList.isEmpty()) {
            return;
        }

        Set<Id> parentAccountIdWithWO = new Set<Id>();
        Map<Id, Rate_Change_Request__c> parentAccountIdToRcr = new Map<Id, Rate_Change_Request__c>();
        for (Rate_Change_Request__c rcr : rcrList) {
            if (!(parentAccountIdToRcr.keySet().contains(rcr.Contract__r.AccountId))) {
                parentAccountIdToRcr.put(rcr.Contract__r.AccountId, rcr);
            }
        }

        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(parentAccountIdToRcr.keySet())
        ) {
            if (
                eachWorkOrder.Status == STATUS_CONFIRMED &&
                eachWorkOrder.Proposed_Date_of_Activation__c == System.today()
            ) {
                parentAccountIdWithWO.add(eachWorkOrder.AccountId);
            }
        }

        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        for (Id eachParentAccountId : parentAccountIdToRcr.keySet()) {
            if (!parentAccountIdWithWO.contains(eachParentAccountId)) {
                createWorkOrderForParentAccount(
                    eachParentAccountId,
                    parentAccountIdToRcr.get(eachParentAccountId),
                    workOrdersToInsert
                );
            }
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
    }

    private void createWorkOrderForParentAccount(
        Id parentAccountId,
        Rate_Change_Request__c rcrRelatedToAccount,
        List<WorkOrder> workOrdersToInsert
    ) {
        WorkOrder workOrderInstance = new WorkOrder(
            AccountId = parentAccountId,
            Activated_Centrally_AC__c = rcrRelatedToAccount
                ?.Contract__r
                ?.Account
                ?.Activated_Centrally_AC__c,
            Contract__c = rcrRelatedToAccount?.Contract__c,
            Creation_Source__c = CREATION_SOURCE_MANAGE_PRICING,
            Menu_Setup_Method__c = rcrRelatedToAccount?.Contract__r?.Account?.Menu_Setup_Method__c,
            Menu_to_be_Completed_By__c = rcrRelatedToAccount
                ?.Contract__r
                ?.Account
                ?.Menu_to_be_Completed_By__c,
            Order_Protocol__c = rcrRelatedToAccount?.Contract__r?.Account?.Order_Protocol__c,
            OwnerId = rcrRelatedToAccount?.S_O_Support_Request_Link__r?.CreatedById,
            Proposed_Date_of_Activation__c = rcrRelatedToAccount?.Effective_Date__c,
            Status = STATUS_CONFIRMED,
            Sub_Type__c = WORKORDER_SUB_TYPE_POSTSALES,
            Type__c = WORKORDER_TYPE_POSTSALES,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        workOrderInstance.put(PROVISIONING_PROCESS_FIELD, WORKORDER_PROVISIONING_PROCESS);
        workOrdersToInsert.add(workOrderInstance);
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
    }

    /**
     * @description It updates the passed Work Order instance's field values,
     * if Nintex Use Case is SSMO, New Franchise - Unknown, New additional stores.
     * @JIRA# LEM-18213
     * @param opportunityInstance
     * @param workOrderInstance
     */
    private void setFieldsValuesForNintexUseCases(
        Opportunity opportunityInstance,
        WorkOrder workOrderInstance
    ) {
        if (!NINTEXUSECASEMAPPINGS.containsKey(opportunityInstance.Nintex_Use_Case__c)) {
            return;
        }
        Account storeAccount = nintexIdToStoreAccount.get(getNintexId(opportunityInstance));
        workOrderInstance.Activated_Centrally_AC__c = storeAccount?.Activated_Centrally_AC__c;
        workOrderInstance.Menu_to_be_Completed_By__c = storeAccount?.Menu_to_be_Completed_By__c;
        workOrderInstance.Order_Protocol__c = storeAccount?.Order_Protocol__c;
        workOrderInstance.Proposed_Date_of_Activation__c = storeAccount?.Order_Protocol__c ==
            ORDER_PROTOCOL_POS
            ? System.today().addDays(21)
            : System.today().addDays(10);
        switch on NINTEXUSECASEMAPPINGS.get(opportunityInstance.Nintex_Use_Case__c) {
            when SSMO {
                setFieldsValuesForNintexUseCaseSSMO(storeAccount, workOrderInstance);
            }
            when else {
                workOrderInstance.Proposed_Date_of_Activation__c = populatePDOAOnWorkOrders(
                    opportunityInstance,
                    storeAccount
                );
            }
        }
    }

    /**
     * @description It updates the passed Work Order instance's field values,
     * if Nintex Use Case is SSMO.
     * @JIRA# LEM-15362
     * @param storeAccountInstance
     * @param workOrderInstance
     */
    private void setFieldsValuesForNintexUseCaseSSMO(
        Account storeAccountInstance,
        WorkOrder workOrderInstance
    ) {
        workOrderInstance.Photoshoot_Date__c = storeAccountInstance?.Nintex_Photoshoot_Date__c;
        workOrderInstance.Photoshoot_Time__c = storeAccountInstance?.Nintex_Photoshoot_Time__c;
        workOrderInstance.Mx_Requested_Photoshoot__c = storeAccountInstance
            ?.Nintex_Mx_Requested_Photoshoot__c;
        workOrderInstance.Status = STATUS_CONFIRMED;
        // On Nintex SSMO form submission, order of "Merchant Services" creation is not guaranteed
        // to happen after parent work order creation hence,
        // to ensure that stores association is initiated on parent work order creation.
        workOrderInstance.Associated_Account_Ids__c = storeAccountInstance?.Id;
        workOrderInstance.Proposed_Date_of_Activation__c = storeAccountInstance
                ?.Order_Protocol__c == ORDER_PROTOCOL_POS
            ? System.today().addDays(21)
            : System.today().addDays(10);
    }

    private void updateRecordCreationStatusOnMxOnboardingLinks(Set<String> uniqueIdentifiers) {
        unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        if (uniqueIdentifiers.isEmpty()) {
            return;
        }
        for (
            Mx_Onboarding_Link__c eachMxOnboardingLink : MxOnboardingLinksSelector.newInstance()
                .selectByUUID(uniqueIdentifiers)
        ) {
            eachMxOnboardingLink.Record_Creation_Status__c = RECORD_CREATION_STATUS_WO_CREATION_SUCCESS;
            unitOfWorkInstance.registerDirty(eachMxOnboardingLink);
        }
        unitOfWorkInstance.commitWork();
    }
}