/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service implementation class for Parent Work Orders creation related logic.
 */
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity,PMD.ExcessiveClassLength,PMD.NcssTypeCount'
)
public inherited sharing class WorkOrdersGeneratorServiceImpl implements IWorkOrdersGeneratorService {
    private static final String ADDRESS_COVERAGE_IN_COVERAGE = 'In Coverage';
    private static final String ADS_PROMOS_ORDER = 'A&P';
    private static final String ADS_PROMOS = 'Ads & Promos';
    private static final String ADDRESS_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String AMENDMENT_WORK_ORDER_CREATION = 'AMENDMENT_WORK_ORDER_GENERATION';
    private static final String AUTOMATIC_PROVISIONING_PROCESS = 'Automatic';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String EMAIL_ORDER_PROTOCOL = 'Email';
    private static final String EVENT_TOPIC_WORK_ORDER_GENERATION = 'WORK_ORDER_GENERATION';
    private static final String COMMA = ',';
    private static final String CONFIRMED_STATUS = 'Confirmed';
    private static final String CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String CORE_ORDER = 'Core';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DRIVE_PLATFORM = 'Drive';
    private static final String DRIVE_AUTO_ACTIVATION_SUPPORTED = 'Yes';
    private static final String DOORDASH_PLATFORM = 'DoorDash';
    private static final String DAY_SATURDAY = 'Sat';
    private static final String DAY_SUNDAY = 'Sun';
    private static final Boolean FALSE_VALUE = false;
    private static final String FIELD_MENU_TO_BE_COMPLETED_BY = 'Menu_to_be_Completed_By__c';
    private static final String FIELD_MENU_SET_UP_METHOD = 'Menu_Setup_Method__c';
    private static final String FIELD_SALES_NOTE_FOR_MENU_TEAM = 'Sales_Notes_for_Menu_Team__c';
    private static final String FIELD_PROPOSED_DATE_OF_ACTIVATION = 'Proposed_Date_of_Activation__c';
    private static final String FIELD_PROPOSED_DATE_OF_IMPLEMENTATION = 'Storefront_Proposed_Date_of_Impl__c';
    private static final String FIELD_ORDER_PROTOCOL = 'Order_Protocol__c';
    private static final String FIELD_ACTIVATED_CENTRALLY = 'Activated_Centrally_AC__c';
    private static final String FIELD_BUSINESS_ID = 'Business_ID__c';
    private static final String FIELD_MX_REQUESTED_PHOTOSHOOT = 'Mx_Requested_Photoshoot__c';
    private static final String FIELD_PHOTOSHOOT_DATE = 'Photoshoot_Date__c';
    private static final String FIELD_PHOTOSHOOT_TIME = 'Photoshoot_Time__c';
    private static final String FIELD_POS_INTEGRATION_TYPE = 'POS_Integration_Type__c';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION = 'WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION';
    private static final String INTERFACE_TRANSACTION_STATUS_SUCCESS = 'Success';
    private static final String INTERFACE_TRANSACTION_STATUS_FAILURE = 'Failure';
    private static final String LOG_SERVICE_WORK_ORDER_GENERATOR_SERVICE = 'WorkOrdersGeneratorService';
    private static final String LOG_DOMAIN_WORK_ORDER_CREATION = 'Work Order Creation';
    private static final String MANUAL_PROVISIONING_PROCESS = 'Manual';
    private static final String MARKETPLACE_PLATFORM = 'Marketplace';
    private static final String MARKETING_KIT = 'Marketing Kit';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NEW_STORE_EXPANSION = 'NSE';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String OPPORTUNTIY_TYPE_EXISTING = 'Existing';
    private static final Integer PDOI_OFFSET_FOR_STOREFRONT_AMENDMENT = 10;
    private static final String PRODUCT_FAMILY_ADVERTISEMENT = 'Advertisement';
    private static final String PRODUCT_FAMILY_DRIVE = 'Drive';
    private static final String PRODUCT_FAMILY_MARKETPLACE_PROMOTION = 'Marketplace Promotion';
    private static final String PROVISIONING_COMPLETE_STATUS = 'Provisioning Complete';
    private static final String PROVISIONING_NOT_STARTED_STATUS = 'Not Started';
    private static final String PHOTOSHOOT_REQUESTED_YES = 'Yes';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String POST_SALES = 'Post-Sales';
    private static final String PRODUCT_FAMILY_HARDWARE = 'Hardware';
    private static final String RX_PRIMARY_VERTICAL = 'Rx';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SMB_SEGMENT = 'SMB';
    private static final String SSMO_CREATION_SOURCE = 'SSMO';
    private static final String RESSMO_CREATION_SOURCE = 'RESSMO';
    private static final String SSOB_CREATION_SOURCE = 'SSOB';
    private static final String STOREFRONT_PLATFORM = 'Storefront';
    private static final String SUB_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String SUB_TYPE_AUTO_ACTIVATION = 'Auto-Activations';
    private static final String SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String SUB_TYPE_DOWNGRADE = 'Downgrade';
    private static final String SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String SUB_TYPE_PARTNERSHIP = 'Partnership creation/update';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String TYPE_AMENDMENT = 'Amendment';
    private static final Id STORE_ACCOUNT_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final Boolean TRUE_VALUE = true;
    private static final String WORK_ORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_ORDER_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String YES_ACTIVATED_CENTRALLY = 'Yes';
    private static final String MENU_SETUP_METHOD = 'Create New Menu(s) using Menu Source';
    private static final String MENU_TO_BE_COMPLETED_BY = 'DoorDash Onboarding Team';
    private enum EventTopics {
        EVENT_TOPIC_WORK_ORDER_GENERATION_HANDLER,
        EVENT_TOPIC_AMENDMENT_WORK_ORDER_GENERATION_HANDLER
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_WORK_ORDER_GENERATION => EventTopics.EVENT_TOPIC_WORK_ORDER_GENERATION_HANDLER,
        AMENDMENT_WORK_ORDER_CREATION => EventTopics.EVENT_TOPIC_AMENDMENT_WORK_ORDER_GENERATION_HANDLER
    };
    private enum ObjectTypes {
        OPPORTUNITY,
        ORDER,
        SUBSCRIPTION,
        WORK_PLAN,
        MX_ONBOARDING_LINK,
        INTERFACE_TRANSACTION
    }
    private static final Map<Schema.SobjectType, ObjectTypes> SOBJECTTYPETOOBJECTTYPES = new Map<Schema.SobjectType, ObjectTypes>{
        Order.SObjectType => ObjectTypes.ORDER,
        Opportunity.SObjectType => ObjectTypes.OPPORTUNITY,
        SBQQ__Subscription__c.SObjectType => ObjectTypes.SUBSCRIPTION,
        WorkPlan.SObjectType => ObjectTypes.WORK_PLAN,
        Mx_Onboarding_Link__c.SObjectType => ObjectTypes.MX_ONBOARDING_LINK,
        Interface_Transaction__c.SObjectType => ObjectTypes.INTERFACE_TRANSACTION
    };
    private enum WorkOrderTypes {
        ADVERTISEMENT,
        DRIVE,
        MARKETPLACE,
        MARKETPLACE_PROMOTION,
        STOREFRONT,
        ADS_AND_PROMOS
    }
    private static final Map<String, WorkOrderTypes> WORKORDERTYPESMAPPING = new Map<String, WorkOrderTypes>{
        PRODUCT_FAMILY_ADVERTISEMENT => WorkOrderTypes.ADVERTISEMENT,
        PRODUCT_FAMILY_MARKETPLACE_PROMOTION => WorkOrderTypes.MARKETPLACE_PROMOTION,
        PRODUCT_FAMILY_DRIVE => WorkOrderTypes.DRIVE,
        PRODUCT_FAMILY_HARDWARE => WorkOrderTypes.MARKETPLACE,
        MARKETPLACE_PLATFORM => WorkOrderTypes.MARKETPLACE,
        STOREFRONT_PLATFORM => WorkOrderTypes.STOREFRONT,
        SUB_TYPE_ADS_AND_PROMOS => WorkOrderTypes.ADS_AND_PROMOS
    };
    private enum DaysOfWeek {
        SATURDAY,
        SUNDAY
    }
    private static final Map<String, DaysOfWeek> DAYS_OF_WEEK = new Map<String, DaysOfWeek>{
        DAY_SATURDAY => DaysOfWeek.SATURDAY,
        DAY_SUNDAY => DaysOfWeek.SUNDAY
    };
    private enum IntegrationSources {
        RESSMO,
        SSMO,
        SSOB,
        MX_PORTAL
    }
    private static final Map<String, IntegrationSources> INTEGRATIONSOURCESMAPPING = new Map<String, IntegrationSources>{
        RESSMO_CREATION_SOURCE => IntegrationSources.RESSMO,
        SSMO_CREATION_SOURCE => IntegrationSources.SSMO,
        SSOB_CREATION_SOURCE => IntegrationSources.SSOB,
        WORK_ORDER_SOURCE_MX_PORTAL => IntegrationSources.MX_PORTAL
    };
    private enum BooleanValues {
        BOOLEAN_TRUE,
        BOOLEAN_FALSE
    }
    private static final Map<Boolean, BooleanValues> BOOLEANVALUESMAPPING = new Map<Boolean, BooleanValues>{
        TRUE_VALUE => BooleanValues.BOOLEAN_TRUE,
        FALSE_VALUE => BooleanValues.BOOLEAN_FALSE
    };
    private static final Set<String> ELIGIBLE_PRODUCT_FAMILIES = new Set<String>{
        MARKETPLACE_PLATFORM,
        STOREFRONT_PLATFORM,
        PRODUCT_FAMILY_DRIVE
    };
    private static final Set<String> ELIGIBLE_ADS_AND_PROMO = new Set<String>{
        PRODUCT_FAMILY_ADVERTISEMENT,
        PRODUCT_FAMILY_MARKETPLACE_PROMOTION
    };
    private static final Set<String> ELIGIBLE_ADS_AND_PROMO_OPPORTUNTIY_SUB_TYPE = new Set<String>{
        SUB_TYPE_ADS_AND_PROMOS,
        SUB_TYPE_UPGRADE
    };
    private enum ProductFamilies {
        NON_ADS_AND_PROMOS,
        ADS_AND_PROMOS
    }
    private static final Map<String, ProductFamilies> PRODUCTFAMILIESMAPPINGS = new Map<String, ProductFamilies>{
        PRODUCT_FAMILY_ADVERTISEMENT => ProductFamilies.ADS_AND_PROMOS,
        PRODUCT_FAMILY_MARKETPLACE_PROMOTION => ProductFamilies.ADS_AND_PROMOS,
        MARKETPLACE_PLATFORM => ProductFamilies.NON_ADS_AND_PROMOS,
        PRODUCT_FAMILY_DRIVE => ProductFamilies.NON_ADS_AND_PROMOS,
        STOREFRONT_PLATFORM => ProductFamilies.NON_ADS_AND_PROMOS,
        PRODUCT_FAMILY_HARDWARE => ProductFamilies.NON_ADS_AND_PROMOS
    };
    private enum OnboardingScenarios {
        NET_NEW_MX_ONBOARDING,
        NEW_STORE_EXPANSION,
        PRODUCT_ADDITION
    }
    private static final Map<String, OnboardingScenarios> ONBOARDINGSCENARIOSMAPPINGS = new Map<String, OnboardingScenarios>{
        ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING => OnboardingScenarios.NET_NEW_MX_ONBOARDING,
        ONBOARDING_SCENARIO_NEW_STORE_EXPANSION => OnboardingScenarios.NEW_STORE_EXPANSION,
        ONBOARDING_SCENARIO_PRODUCT_ADDITION => OnboardingScenarios.PRODUCT_ADDITION
    };
    private static final Set<String> NON_ELIGIBLE_INTEGRATION_SOURCE_FOR_ADS_PROMOS = new Set<String>{
        CREATION_SOURCE_MX_PORTAL,
        SSMO_CREATION_SOURCE
    };
    Set<String> contractIdToWorkOrderToBeCreated;
    Map<Id, Set<String>> contractIdToSubscriptionsPresent;
    Map<Id, Id> contractIdToOpportunityId;
    Map<Id, Double> adsAndPromoContractIdToEstimatedNoOfStores;
    Map<Id, Id> coreContractIdToAdsAndPromosContractId;
    Map<String, String> uniqueIdentifierToOrderProtocol;
    Map<String, String> uniqueIdentifierToMenuToBeCompletedBy;
    Map<Id, List<OrderItem>> orderToOrderItems = new Map<Id, List<OrderItem>>();
    Map<String, String> uniqueIdentiferToStoreAccountIds;
    Set<Id> interfaceTransactionIds;
    Set<Id> mxOnboardingLinkIds;
    Set<Id> opportunityIds;
    Set<Id> subscriptionIds;
    Set<Id> workPlanIds;
    Set<Id> storefrontContractIds;

    /**
     * @description default constructor
     */
    public WorkOrdersGeneratorServiceImpl() {
        contractIdToWorkOrderToBeCreated = new Set<String>();
        contractIdToSubscriptionsPresent = new Map<Id, Set<String>>();
        contractIdToOpportunityId = new Map<Id, Id>();
        adsAndPromoContractIdToEstimatedNoOfStores = new Map<Id, Double>();
        coreContractIdToAdsAndPromosContractId = new Map<Id, Id>();
        uniqueIdentifierToOrderProtocol = new Map<String, String>();
        uniqueIdentifierToMenuToBeCompletedBy = new Map<String, String>();
        uniqueIdentiferToStoreAccountIds = new Map<String, String>();
        interfaceTransactionIds = new Set<Id>();
        mxOnboardingLinkIds = new Set<Id>();
        opportunityIds = new Set<Id>();
        subscriptionIds = new Set<Id>();
        workPlanIds = new Set<Id>();
        storefrontContractIds = new Set<Id>();
    }

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @JIRA# LEM-15362
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> sobjectIds = new Set<Id>();
        Set<Id> amendedSubscriptionIds = new Set<Id>();
        Set<Id> recordIdsByPayload;

        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_WORK_ORDER_GENERATION_HANDLER {
                    recordIdsByPayload = getRecordIdsFromPlatformEvent(eachEvent);
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    sobjectIds.addAll(recordIdsByPayload);
                }
                when EVENT_TOPIC_AMENDMENT_WORK_ORDER_GENERATION_HANDLER {
                    recordIdsByPayload = getRecordIdsFromPlatformEvent(eachEvent);
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    amendedSubscriptionIds.addAll(recordIdsByPayload);
                }
            }
        }
        try {
            if (!sobjectIds.isEmpty()) {
                groupSobjectIdsBySObjectTypes(sobjectIds);
                initiateWorkOrderGeneration();
            }
            if (!amendedSubscriptionIds.isEmpty()) {
                groupSobjectIdsBySObjectTypes(amendedSubscriptionIds);
                initializeAmendmentWorkWrapper(subscriptionIds);
            }
        } catch (Exception workOrderCreationException) {
            updateInterfaceTransactionStatusToFailure();
            createLogEntries(workOrderCreationException);
        }
    }

    /**
     * @description It is used to collect Product Families to prevent duplicate parent Work Order creation.
     * @JIRA# LEM-24313
     * @param contractId
     * @param productFamilies
     * @param productFamiliesProcessedForContract
     */
    private void setProcessedProductFamilies(
        Id contractId,
        Set<String> productFamilies,
        Set<String> productFamiliesProcessedForContract
    ) {
        for (String eachProductFamily : productFamilies) {
            productFamiliesProcessedForContract.add(contractId + eachProductFamily);
        }
    }

    /**
     * @description It Converts the given date to nearest business day.
     * @param dateToConvert
     * @return Date
     */
    private Date convertToNearestBusinessDay(Date dateToConvert) {
        DateTime requiredDateTime = (DateTime) dateToConvert;
        String dayOfWeek = requiredDateTime.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL);
        switch on DAYS_OF_WEEK.get(dayOfWeek) {
            when SATURDAY {
                return dateToConvert.addDays(2);
            }
            when SUNDAY {
                return dateToConvert.addDays(1);
            }
        }
        return dateToConvert;
    }

    /**
     * @description It returns the calculated date excluding weekends based on the passed start date
     * and offset to add.
     * @param startDate
     * @param offsetToAdd
     * @return Date
     */
    public Date calculateDateExcludingWeekends(Datetime startDate, Integer offsetToAdd) {
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
     * @description It is used to create Interface Transaction for Work Order Creation.
     * @JIRA# LEM-15363
     * @param workOrderGenerator
     */
    private void createInterfaceTransactionForWorkOrderCreation(
        List<WorkOrderGenerationWrapper> workOrderGenerator
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkOrderGenerationWrapper eachGenerator : workOrderGenerator) {
            uow.registerNew(
                new Interface_Transaction__c(
                    Payload__c = JSON.serialize(eachGenerator),
                    Remaining_Retry_Attempts__c = 3,
                    Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION
                )
            );
        }
        uow.commitWork();
    }

    /**
     * @description It is used to create Log Entries.
     * @param workOrderCreationException
     */
    public void createLogEntries(Exception workOrderCreationException) {
        Set<String> recordIdsToLog = getRecordIdsToLog();
        Logger.publish(
            LogEntry.newExceptionLog(workOrderCreationException, LogEntry.SeverityLevel.HIGH)
        );
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_WORK_ORDER_GENERATOR_SERVICE,
                    LOG_DOMAIN_WORK_ORDER_CREATION,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logException(workOrderCreationException)
                .logSFRecordId(recordIdsToLog)
        );
    }

    /**
     * @description It is used to create WorkOrderGenerationWrapper for Onboarding Inputs.
     * @JIRA# LEM-15321, LEM-15783
     * @param contractIdToMxOnboardingLink
     * @return List<WorkOrderGenerationWrapper>
     */
    private List<WorkOrderGenerationWrapper> createWorkOrderGenerationWrapperForOnboardingInputs(
        Map<Id, Mx_Onboarding_Link__c> contractIdToMxOnboardingLink
    ) {
        Id eachContractId;
        List<String> splittedString;
        String workOrderType;
        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();
        for (String workOrderToBeCreated : contractIdToWorkOrderToBeCreated) {
            splittedString = workOrderToBeCreated.split(SEPARATOR);
            workOrderType = splittedString[1];
            eachContractId = Id.valueOf(splittedString[0]);
            WorkOrderGenerationWrapper workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
            workOrderGenerationWrapper.setType(workOrderType);
            workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
            workOrderGenerationWrapper.setAccountId(
                contractIdToMxOnboardingLink.get(eachContractId).Contract__r.AccountId
            );
            workOrderGenerationWrapper.setOpportunityId(
                contractIdToOpportunityId.get(eachContractId)
            );
            workOrderGenerationWrapper.setMxOnboardingLinkId(
                contractIdToMxOnboardingLink.get(eachContractId).Id
            );
            workOrderGenerationWrapper.setContractId(eachContractId);
            workOrderGenerationWrapper.setPrimaryVertical(RX_PRIMARY_VERTICAL);
            workOrderGenerationWrapper.setSegment(SMB_SEGMENT);
            workOrderGenerationWrapper.setUniqueIdentifier(
                contractIdToMxOnboardingLink.get(eachContractId).UUID__c
            );
            workOrderGenerationWrapper.setSalesRepName(
                contractIdToMxOnboardingLink.get(eachContractId).CreatedById
            );
            workOrderGenerationWrapper.setProvisioningProcess(AUTOMATIC_PROVISIONING_PROCESS);
            workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_NOT_STARTED_STATUS);
            if (
                contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r != null &&
                !contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r.isEmpty()
            ) {
                workOrderGenerationWrapper.setMenuToBeCompletedBy(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r,
                        FIELD_MENU_TO_BE_COMPLETED_BY
                    )
                );
                workOrderGenerationWrapper.setMenuSetUpMethod(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r,
                        FIELD_MENU_SET_UP_METHOD
                    )
                );
                workOrderGenerationWrapper.setSalesNotesForMenuTeam(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r,
                        FIELD_SALES_NOTE_FOR_MENU_TEAM
                    )
                );
                workOrderGenerationWrapper.setProposedDateOfImplementation(
                    (Date) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId).Store_Details__r,
                        FIELD_PROPOSED_DATE_OF_IMPLEMENTATION
                    )
                );
            }
            if (workOrderType != STOREFRONT_PLATFORM) {
                workOrderGenerationWrapper.setProposedDateOfImplementation(null);
            }
            workOrderGenerationWrapper.setCreationSource(WORK_ORDER_SOURCE_ONBOARDING_INPUTS);
            workOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_SALES);
            if (
                contractIdToMxOnboardingLink.get(eachContractId).Business_Onboarding_Details__r !=
                null &&
                !contractIdToMxOnboardingLink.get(eachContractId)
                    .Business_Onboarding_Details__r.isEmpty()
            ) {
                workOrderGenerationWrapper.setProposedDateOfActivation(
                    (Date) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId)
                            .Business_Onboarding_Details__r,
                        FIELD_PROPOSED_DATE_OF_ACTIVATION
                    )
                );
                workOrderGenerationWrapper.setOrderProtocol(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId)
                            .Business_Onboarding_Details__r,
                        FIELD_ORDER_PROTOCOL
                    )
                );
                workOrderGenerationWrapper.setActivatedCentrally(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId)
                            .Business_Onboarding_Details__r,
                        FIELD_ACTIVATED_CENTRALLY
                    )
                );
                workOrderGenerationWrapper.setBusinessId(
                    (String) getCombinedFieldValueByMultipleSobjectInstances(
                        contractIdToMxOnboardingLink.get(eachContractId)
                            .Business_Onboarding_Details__r,
                        FIELD_BUSINESS_ID
                    )
                );
            }
            setFieldsForMxOnbardingLinkRESSMO(
                workOrderGenerationWrapper,
                contractIdToMxOnboardingLink.get(eachContractId)
            );
            setAssociatedAccountIdsForProductAdditionScenarioContainingOnlyStorefrontProduct(
                workOrderGenerationWrapper,
                contractIdToMxOnboardingLink.get(eachContractId)
            );
            switch on WORKORDERTYPESMAPPING.get(workOrderType) {
                when MARKETPLACE {
                    setOnboardingInputsWrapperForMarketplace(
                        workOrderGenerationWrapper,
                        contractIdToMxOnboardingLink.get(eachContractId)
                    );
                }
                when STOREFRONT {
                    setOnboardingInputsWrapperForStorefront(
                        workOrderGenerationWrapper,
                        contractIdToMxOnboardingLink.get(eachContractId)
                    );
                }
                when DRIVE {
                    setOnboardingInputsWrapperForDrive(
                        workOrderGenerationWrapper,
                        contractIdToMxOnboardingLink.get(eachContractId)
                    );
                }
                when ADS_AND_PROMOS {
                    setOnboardingInputsWrapperForAdsAndPromos(
                        workOrderGenerationWrapper,
                        eachContractId
                    );
                }
            }

            workOrderGenerationWrappers.add(workOrderGenerationWrapper);
        }
        return workOrderGenerationWrappers;
    }

    /**
     * @description It initializes fields common to MxOnbardingLink for RESSMO.
     * @JIRA# LEM-16359
     * @param workOrderGenerationWrapper
     * @param mxOnbardingLink
     */
    private void setFieldsForMxOnbardingLinkRESSMO(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Mx_Onboarding_Link__c mxOnbardingLink
    ) {
        if (mxOnbardingLink.Source__c != RESSMO_CREATION_SOURCE) {
            return;
        }
        Map<String, Object> mxOnboadingPayloadObjectMap = (Map<String, Object>) JSON.deserializeUntyped(
            mxOnbardingLink.Payload__c
        );
        Map<String, Object> workOrderInformationObj = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serializePretty(mxOnboadingPayloadObjectMap.get('workOrderInformation'))
        );
        workOrderGenerationWrapper.setProposedDateOfActivation(
            convertToNearestBusinessDay(
                getProposedDateOfActivation(workOrderGenerationWrapper.getUniqueIdentifier())
            )
        );
        workOrderGenerationWrapper.setOrderProtocol(
            (String) workOrderInformationObj.get(FIELD_ORDER_PROTOCOL)
        );
        workOrderGenerationWrapper.setActivatedCentrally(
            (String) workOrderInformationObj.get(FIELD_ACTIVATED_CENTRALLY)
        );
        workOrderGenerationWrapper.setBusinessId(
            (String) workOrderInformationObj.get(FIELD_BUSINESS_ID)
        );
        if (
            workOrderGenerationWrapper.getOrderProtocol() == null ||
            workOrderGenerationWrapper.getOrderProtocol() != POS_ORDER_PROTOCOL
        ) {
            workOrderGenerationWrapper.setMenuSetUpMethod(MENU_SETUP_METHOD);
            workOrderGenerationWrapper.setMenuToBeCompletedBy(MENU_TO_BE_COMPLETED_BY);
            workOrderGenerationWrapper.setSalesNotesForMenuTeam(
                (String) workOrderInformationObj.get(FIELD_SALES_NOTE_FOR_MENU_TEAM)
            );
        }
        if (mxOnbardingLink.Contract__r.RESSMO_Sales_Rep_Name__c != null) {
            workOrderGenerationWrapper.setSalesRepName(
                mxOnbardingLink.Contract__r.RESSMO_Sales_Rep_Name__c
            );
        } else if (mxOnbardingLink.Contract__r.SBQQ__Quote__r.SBQQ__SalesRep__c != null) {
            workOrderGenerationWrapper.setSalesRepName(
                mxOnbardingLink.Contract__r.SBQQ__Quote__r.SBQQ__SalesRep__c
            );
        }
        workOrderGenerationWrapper.setPosIntegrationType(
            (String) workOrderInformationObj.get(FIELD_POS_INTEGRATION_TYPE)
        );
        workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_COMPLETE_STATUS);
        workOrderGenerationWrapper.setCreationSource(RESSMO_CREATION_SOURCE);
        workOrderGenerationWrapper.setWorkOrderSource(RESSMO_CREATION_SOURCE);
        workOrderGenerationWrapper.setHasWorkPlansGenerated(TRUE_VALUE);
        workOrderGenerationWrapper.setStoreAccountIds(
            (String) workOrderInformationObj.get('storeAccountIds')
        );

        String payload = mxOnbardingLink.Payload__c;
        if (payload != null && payload != '') {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
            Map<String, Object> genericInputMap = (Map<String, Object>) jsonMap.get('genericInput');
            Map<String, Object> photoshootMap = genericInputMap != null
                ? (Map<String, Object>) genericInputMap.get('Photoshoot')
                : null;
            setPhotoShootFieldsFromPayload(workOrderGenerationWrapper, photoshootMap);
        }
    }

    /**
     * @description It is used to get Store Accounts associated to Onboarding Inputs.
     * @param uniqueIdentifiers
     */
    private void getAssociatedAccountIdsForOnboardingInputs(Set<String> uniqueIdentifiers) {
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectAccountsByMxOnboardingLinkIds(uniqueIdentifiers)
        ) {
            if (!isAccountEligibleForStoreAssociation(eachAccount)) {
                continue;
            }
            if (
                !uniqueIdentiferToStoreAccountIds.containsKey(eachAccount.Mx_Onboarding_Link_Id__c)
            ) {
                uniqueIdentiferToStoreAccountIds.put(eachAccount.Mx_Onboarding_Link_Id__c, '');
            }
            uniqueIdentiferToStoreAccountIds.put(
                eachAccount.Mx_Onboarding_Link_Id__c,
                uniqueIdentiferToStoreAccountIds.get(eachAccount.Mx_Onboarding_Link_Id__c) +
                    eachAccount.Id +
                    COMMA
            );
        }
    }

    /**
     * @description It is used to associate stores from Payload to workorder
     * when Account Id is passed.
     * @JIRA# LEM-15362
     * @param accountIds
     * @param uniqueIdentifiers
     * @return Map<String,String>
     */
    private Map<String, String> getAssociatedStoresFromAccount(
        Set<Id> accountIds,
        Set<String> uniqueIdentifiers
    ) {
        Map<String, String> accountIdentifierToStoreAccounts = new Map<String, String>();
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectByUniqueIdentifiers(accountIds, uniqueIdentifiers)
        ) {
            String key = eachAccount.ParentId + eachAccount.Unique_Identifier__c;
            if (!accountIdentifierToStoreAccounts.containsKey(key)) {
                accountIdentifierToStoreAccounts.put(key, '');
            }
            accountIdentifierToStoreAccounts.put(
                key,
                accountIdentifierToStoreAccounts.get(key) + eachAccount.Id + COMMA
            );
            uniqueIdentifierToOrderProtocol.put(
                eachAccount.Unique_Identifier__c,
                eachAccount.Order_Protocol__c
            );
            uniqueIdentifierToMenuToBeCompletedBy.put(
                eachAccount.Unique_Identifier__c,
                eachAccount.Menu_to_be_Completed_By__c
            );
        }
        return accountIdentifierToStoreAccounts;
    }

    /**
     * @description It is used to get the value of Bundled With Marketplace for Storefront.
     * @JIRA# LEM-15783
     * @param onboardingScenario
     * @param contractId
     * @return Boolean
     */
    private Boolean getBundledWithMarketplaceValue(String onboardingScenario, Id contractId) {
        Boolean bundledWithMarketplace;
        switch on ONBOARDINGSCENARIOSMAPPINGS.get(onboardingScenario) {
            when NET_NEW_MX_ONBOARDING, NEW_STORE_EXPANSION {
                bundledWithMarketPlace = true;
            }
            when PRODUCT_ADDITION {
                bundledWithMarketplace = contractIdToWorkOrderToBeCreated.contains(
                    contractId + SEPARATOR + MARKETPLACE_PLATFORM
                );
            }
        }
        return bundledWithMarketplace;
    }

    /**
     * @description It is used to get the contracts eligible for Ads & Promos Work Order Creation.
     * @JIRA# LEM-15784
     * @param contractIdToMxOnboardingLink
     */
    private void getContractsForAdsAndPromosWorkOrderCreation(
        Map<Id, Mx_Onboarding_Link__c> contractIdToMxOnboardingLink
    ) {
        Map<Id, Id> accountIdToCoreContractId = new Map<Id, Id>();
        for (Id eachContractId : contractIdToMxOnboardingLink.keySet()) {
            switch on
                ONBOARDINGSCENARIOSMAPPINGS.get(
                    contractIdToMxOnboardingLink.get(eachContractId).Onboarding_Scenario__c
                ) {
                when NET_NEW_MX_ONBOARDING, NEW_STORE_EXPANSION {
                    accountIdToCoreContractId.put(
                        contractIdToMxOnboardingLink.get(eachContractId).Contract__r.AccountId,
                        eachContractId
                    );
                }
            }
        }
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>(accountIdToCoreContractId.keySet())
                )
        ) {
            if (
                contractIdToMxOnboardingLink.get(
                        accountIdToCoreContractId.get(eachContract.AccountId)
                    )
                    .Contract__r.SBQQ__Quote__c != eachContract.SBQQ__Quote__c
            ) {
                continue;
            }
            coreContractIdToAdsAndPromosContractId.put(
                accountIdToCoreContractId.get(eachContract.AccountId),
                eachContract.Id
            );
        }
        for (Id eachContractId : coreContractIdToAdsAndPromosContractId.keySet()) {
            contractIdToWorkOrderToBeCreated.add(
                eachContractId + SEPARATOR + SUB_TYPE_ADS_AND_PROMOS
            );
            adsAndPromoContractIdToEstimatedNoOfStores.put(
                eachContractId,
                contractIdToMxOnboardingLink.get(eachContractId).Contract__r.Number_of_Stores__c
            );
        }
    }

    /**
     * @description It is used to get all the existing Subscriptions on the passed Contract.
     * @param contractIds
     * @param productNames
     * @param subscriptionIds
     * @return Set<String>
     */
    private Set<String> getExistingSubscriptions(
        Set<Id> contractIds,
        Set<String> productNames,
        Set<Id> subscriptionIds
    ) {
        Set<String> existingSubscriptions = new Set<String>();
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectAmendedSubscriptions(contractIds, productNames, subscriptionIds)
        ) {
            existingSubscriptions.add(
                eachSubscription.SBQQ__Contract__c + eachSubscription.SBQQ__Product__r.Name
            );
            existingSubscriptions.add(
                eachSubscription.SBQQ__Contract__c + getSubscriptionProductFamily(eachSubscription)
            );
        }
        return existingSubscriptions;
    }

    /**
     * @description It is used to get the proposed Date of Activation.
     * @param uniqueIdentifier
     * @return Date
     */
    private Date getProposedDateOfActivation(String uniqueIdentifier) {
        Date proposedDateOfActivation = System.today().addDays(10);
        if (uniqueIdentifierToOrderProtocol.get(uniqueIdentifier) == POS_ORDER_PROTOCOL) {
            proposedDateOfActivation = System.today().addDays(21);
        }
        return proposedDateOfActivation;
    }

    /**
     * @description It is used to get record Ids from platform event.
     * @param eventName
     * @return Set<Id>
     */
    private Set<Id> getRecordIdsFromPlatformEvent(Onboarding_Activation__e eventName) {
        Set<Id> recordIdsByPayload;
        recordIdsByPayload = (Set<Id>) JSON.deserialize(eventName.Payload__c, Set<Id>.class);
        return recordIdsByPayload;
    }

    /**
     * @description It is used to get Product Family of the passed Subscription.
     * @param subscriptionRecord
     * @return String
     */
    private String getSubscriptionProductFamily(SBQQ__Subscription__c subscriptionRecord) {
        String currentProductFamily = subscriptionRecord.Package__c == null
            ? subscriptionRecord.SBQQ__Product__r.Family
            : subscriptionRecord.SBQQ__RequiredByProduct__r.Family;
        String currentPackage = subscriptionRecord.Package__c != null &&
            (subscriptionRecord.Package__c).containsIgnoreCase(STOREFRONT_PLATFORM)
            ? STOREFRONT_PLATFORM
            : '';
        return String.isNotBlank(currentPackage) ? currentPackage : currentProductFamily;
    }

    /**
     * @description It is used to get field value for Work Order creation from Multiple Business/Store Onboarding
     * Details related to a Mx Onboarding Link.
     * @param sobjects
     * @param fieldName
     * @return Object
     */
    private Object getCombinedFieldValueByMultipleSobjectInstances(
        List<Sobject> sobjects,
        String fieldName
    ) {
        Object valueToReturn = null;
        for (SObject eachSobject : (List<Sobject>) sobjects) {
            if (
                String.isNotBlank(String.valueOf(eachSobject.get(fieldName))) &&
                String.valueOf(eachSobject.get(fieldName)) != null
            ) {
                valueToReturn = eachSobject.get(fieldName);
                break;
            }
        }
        return valueToReturn;
    }

    /**
     * @description It is used to get the record Ids that needs to be logged.
     * @return  Set<String>
     */
    private Set<String> getRecordIdsToLog() {
        Set<String> recordIdsToLog = new Set<String>();
        recordIdsToLog.add(JSON.serialize(interfaceTransactionIds));
        if (!mxOnboardingLinkIds.isEmpty()) {
            recordIdsToLog.add(JSON.serialize(mxOnboardingLinkIds));
        }
        if (!opportunityIds.isEmpty()) {
            recordIdsToLog.add(JSON.serialize(opportunityIds));
        }
        if (!subscriptionIds.isEmpty()) {
            recordIdsToLog.add(JSON.serialize(subscriptionIds));
        }
        if (!workPlanIds.isEmpty()) {
            recordIdsToLog.add(JSON.serialize(workPlanIds));
        }
        return recordIdsToLog;
    }

    /**
     * @description It is used to initiate creation of Interface Transaction for
     * Work Order Generation.
     * @JIRA# LEM-15362,LEM-13484
     */
    public void initiateWorkOrderGeneration() {
        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();

        workOrderGenerationWrappers.addAll(
            initializeSSMOAndSSOBWrappers(
                SubscriptionsService.getSubscriptionsAndRelatedInformation(subscriptionIds)
            )
        );
        workOrderGenerationWrappers.addAll(
            initializeMarketingKitWrapper(
                WorkPlansSelector.newInstance().selectWorkPlansWithWorkOrderDetails(workPlanIds)
            )
        );
        workOrderGenerationWrappers.addAll(initializeOnboardingInputsWrapper(mxOnboardingLinkIds));
        workOrderGenerationWrappers.addAll(initializeMxPortalWrapper(opportunityIds));
        if (!workOrderGenerationWrappers.isEmpty()) {
            createInterfaceTransactionForWorkOrderCreation(workOrderGenerationWrappers);
        }
    }

    /**
     * @description It is used to create Work Order for Mx Portal Store Addition.
     * @JIRA# LEM-14753
     * @param opportunityIds
     * @return List<WorkOrderGenerationWrapper>
     */
    private List<WorkOrderGenerationWrapper> initializeMxPortalWrapper(Set<Id> opportunityIds) {
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<String> uniqueIdentifiers = new Set<String>();
        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();
        if (opportunityIds.isEmpty()) {
            return workOrderGenerationWrappers;
        }
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(opportunityIds)
        ) {
            accountIds.add(eachOpportunity.AccountId);
            uniqueIdentifiers.add(eachOpportunity.Unique_Identifier__c);
            opportunities.add(eachOpportunity);
            contractIds.add(eachOpportunity.ContractId);
        }
        contractIdToSubscriptionsPresent = SubscriptionsService.getExistingSubscriptionsForContracts(
            contractIds
        );
        Map<String, String> accountIdentifierToStoreAccounts = getAssociatedStoresFromAccount(
            accountIds,
            uniqueIdentifiers
        );
        for (Opportunity eachOpportunity : opportunities) {
            if (
                contractIdToSubscriptionsPresent.get(eachOpportunity.ContractId)
                    .contains(MARKETPLACE_PLATFORM)
            ) {
                workOrderGenerationWrappers.add(
                    setMxPortalWrapper(
                        eachOpportunity,
                        MARKETPLACE_PLATFORM,
                        accountIdentifierToStoreAccounts
                    )
                );
            }
            if (
                contractIdToSubscriptionsPresent.get(eachOpportunity.ContractId)
                    .contains(STOREFRONT_PLATFORM)
            ) {
                workOrderGenerationWrappers.add(
                    setMxPortalWrapper(
                        eachOpportunity,
                        STOREFRONT_PLATFORM,
                        accountIdentifierToStoreAccounts
                    )
                );
            }
        }
        return workOrderGenerationWrappers;
    }

    /**
     * @description It initializes wrapper for Amendment Work Order creation.
     * @JIRA# LEM-15364,LEM-17449
     * @param subscriptionIds
     */
    private void initializeAmendmentWorkWrapper(Set<Id> subscriptionIds) {
        Boolean alreadyProcessed;
        Set<String> productNames = new Set<String>();
        Set<Id> contractIds = new Set<Id>();
        Set<String> existingSubscriptions = new Set<String>();
        Set<String> productFamiliesProcessedForContract = new Set<String>();
        List<SBQQ__Subscription__c> retrievedSubscriptions = new List<SBQQ__Subscription__c>();
        String subscriptionProductFamily;
        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();

        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectBySubscriptionIds(subscriptionIds)
        ) {
            subscriptionProductFamily = getSubscriptionProductFamily(eachSubscription);
            productNames.add(eachSubscription.SBQQ__Product__r.Name);
            productNames.add(subscriptionProductFamily);
            contractIds.add(eachSubscription.SBQQ__Contract__c);
            retrievedSubscriptions.add(eachSubscription);
            if (subscriptionProductFamily == STOREFRONT_PLATFORM) {
                storefrontContractIds.add(eachSubscription.SBQQ__Contract__c);
            }
        }
        existingSubscriptions = getExistingSubscriptions(
            contractIds,
            productNames,
            subscriptionIds
        );
        for (SBQQ__Subscription__c eachSubscription : retrievedSubscriptions) {
            alreadyProcessed = isProductFamilyAlreadyProcessed(
                productFamiliesProcessedForContract,
                eachSubscription
            );
            if (alreadyProcessed) {
                continue;
            }
            subscriptionProductFamily = getSubscriptionProductFamily(eachSubscription);
            switch on WORKORDERTYPESMAPPING.get(subscriptionProductFamily) {
                when MARKETPLACE {
                    setProcessedProductFamilies(
                        eachSubscription.SBQQ__Contract__c,
                        new Set<String>{
                            STOREFRONT_PLATFORM,
                            PRODUCT_FAMILY_HARDWARE,
                            MARKETPLACE_PLATFORM,
                            eachSubscription.SBQQ__Product__r.Name
                        },
                        productFamiliesProcessedForContract
                    );
                }
                when STOREFRONT {
                    setProcessedProductFamilies(
                        eachSubscription.SBQQ__Contract__c,
                        new Set<String>{
                            MARKETPLACE_PLATFORM,
                            PRODUCT_FAMILY_HARDWARE,
                            STOREFRONT_PLATFORM,
                            eachSubscription.SBQQ__Product__r.Name
                        },
                        productFamiliesProcessedForContract
                    );
                }
                when ADVERTISEMENT {
                    setProcessedProductFamilies(
                        eachSubscription.SBQQ__Contract__c,
                        new Set<String>{
                            PRODUCT_FAMILY_MARKETPLACE_PROMOTION,
                            PRODUCT_FAMILY_ADVERTISEMENT,
                            eachSubscription.SBQQ__Product__r.Name
                        },
                        productFamiliesProcessedForContract
                    );
                }
                when MARKETPLACE_PROMOTION {
                    setProcessedProductFamilies(
                        eachSubscription.SBQQ__Contract__c,
                        new Set<String>{
                            PRODUCT_FAMILY_ADVERTISEMENT,
                            PRODUCT_FAMILY_MARKETPLACE_PROMOTION,
                            eachSubscription.SBQQ__Product__r.Name
                        },
                        productFamiliesProcessedForContract
                    );
                }
            }
            if (isEligibleForAmendment(eachSubscription, existingSubscriptions)) {
                switch on PRODUCTFAMILIESMAPPINGS.get(subscriptionProductFamily) {
                    when NON_ADS_AND_PROMOS {
                        workOrderGenerationWrappers.add(
                            setWorkOrderGenerationWrapperForAmendments(eachSubscription)
                        );
                    }
                    when ADS_AND_PROMOS {
                        if (
                            ELIGIBLE_ADS_AND_PROMO_OPPORTUNTIY_SUB_TYPE.contains(
                                eachSubscription.SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Sub_Type__c
                            ) &&
                            !NON_ELIGIBLE_INTEGRATION_SOURCE_FOR_ADS_PROMOS.contains(
                                eachSubscription.Integration_Source__c
                            )
                        ) {
                            workOrderGenerationWrappers.add(
                                setWorkOrderGenerationWrapperForAmendments(eachSubscription)
                            );
                        }
                    }
                }
            } else if (
                ELIGIBLE_ADS_AND_PROMO.contains(eachSubscription.SBQQ__Product__r.Family) &&
                eachSubscription.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type ==
                OPPORTUNTIY_TYPE_EXISTING &&
                ELIGIBLE_ADS_AND_PROMO_OPPORTUNTIY_SUB_TYPE.contains(
                    eachSubscription.SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Sub_Type__c
                ) &&
                !NON_ELIGIBLE_INTEGRATION_SOURCE_FOR_ADS_PROMOS.contains(
                    eachSubscription.Integration_Source__c
                )
            ) {
                workOrderGenerationWrappers.add(
                    setWorkOrderGenerationWrapperForAmendments(eachSubscription)
                );
            }
        }
        if (!workOrderGenerationWrappers.isEmpty()) {
            createInterfaceTransactionForWorkOrderCreation(workOrderGenerationWrappers);
        }
    }
    /**
     * @description It initializes wrapper for Marketing Kit Work Order creation.
     * @JIRA# LEM-13484
     * @param workPlans
     * @return List<WorkOrderGenerationWrapper>
     */
    private List<WorkOrderGenerationWrapper> initializeMarketingKitWrapper(
        List<WorkPlan> workPlans
    ) {
        WorkOrderGenerationWrapper workOrderGenerationWrapper;
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> originatingMarketplaceWorkOrderIds = new Set<Id>();
        for (WorkPlan eachWorkPlan : workPlans) {
            workOrderIds.add(eachWorkPlan.WorkOrderId);
        }
        for (
            WorkOrder eachMarketingKitWorkOrder : WorkOrdersSelector.newInstance()
                .selectMarketingKitWorkOrdersByOriginatingWorkOrder(workOrderIds)
        ) {
            originatingMarketplaceWorkOrderIds.add(
                eachMarketingKitWorkOrder.Originating_Work_Order__c
            );
        }

        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();
        for (WorkPlan eachWorkPlan : workPlans) {
            if (
                !isWorkPlanEligibleForMarketingKitWorkOrderCreation(
                    eachWorkPlan,
                    originatingMarketplaceWorkOrderIds
                )
            ) {
                continue;
            }
            workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
            workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
            workOrderGenerationWrapper.setType(MARKETING_KIT);
            workOrderGenerationWrapper.setAccountId(eachWorkPlan.WorkOrder.AccountId);
            workOrderGenerationWrapper.setOpportunityId(eachWorkPlan.WorkOrder.Opportunity__c);
            workOrderGenerationWrapper.setContractId(eachWorkPlan.WorkOrder.Contract__c);
            workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_NOT_STARTED_STATUS);
            workOrderGenerationWrapper.setOriginatingWorkOrderId(eachWorkPlan.WorkOrderId);
            workOrderGenerationWrappers.add(workOrderGenerationWrapper);
        }
        return workOrderGenerationWrappers;
    }

    /**
     * @description It is used to initailize wrapper for SSMO and SSOB Work Order Creation.
     * @JIRA# LEM-15363
     * @param newSubcriptions
     * @return List<WorkOrderGenerationWrapper>
     */
    private List<WorkOrderGenerationWrapper> initializeSSMOAndSSOBWrappers(
        List<SBQQ__Subscription__c> newSubcriptions
    ) {
        WorkOrderGenerationWrapper workOrderGenerationWrapper;
        Set<Id> parentAccountIds = new Set<Id>();
        Set<String> uniqueIdentifiers = new Set<String>();
        Set<String> uniqueIdentifierToProductWorkOrderType = new Set<String>();
        Set<Id> orderIds = new Set<Id>();

        for (SBQQ__Subscription__c eachSubscription : newSubcriptions) {
            parentAccountIds.add(eachSubscription.SBQQ__Account__c);
            uniqueIdentifiers.add(
                eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
            );
            orderIds.add(eachSubscription.SBQQ__Contract__r.SBQQ__Order__c);
        }
        Map<String, String> accountIdentifierToStoreAccounts = getAssociatedStoresFromAccount(
            parentAccountIds,
            uniqueIdentifiers
        );
        getOrderToOrderItems(orderIds);
        List<WorkOrderGenerationWrapper> workOrderGenerationWrappers = new List<WorkOrderGenerationWrapper>();
        for (SBQQ__Subscription__c eachSubscription : newSubcriptions) {
            if (
                !isSubscriptionEligibleForWrapperCreation(
                    eachSubscription,
                    uniqueIdentifierToProductWorkOrderType
                )
            ) {
                continue;
            }
            uniqueIdentifierToProductWorkOrderType.add(
                eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c +
                    SEPARATOR +
                    eachSubscription.SBQQ__Product__r.Work_Order_Type__c
            );
            workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
            //common for SSOB and SSMO
            setCommonFieldsForSSMOAndSSOB(workOrderGenerationWrapper, eachSubscription);
            workOrderGenerationWrapper.setStoreAccountIds(
                accountIdentifierToStoreAccounts.get(
                    eachSubscription.SBQQ__Account__c +
                    eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
                )
            );
            //not common for SSOB and SSMO
            switch on INTEGRATIONSOURCESMAPPING.get(eachSubscription.Integration_Source__c) {
                when SSMO, MX_PORTAL, RESSMO {
                    setFieldsForSSMO(workOrderGenerationWrapper, eachSubscription);
                    setFieldsForRESSMO(workOrderGenerationWrapper, eachSubscription);
                }
                when SSOB {
                    workOrderGenerationWrapper.setType(STOREFRONT_PLATFORM);
                    workOrderGenerationWrapper.setProposedDateOfActivation(
                        System.today().addDays(7)
                    );
                    workOrderGenerationWrapper.setUniqueIdentifier(
                        eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
                    );
                }
            }
            workOrderGenerationWrappers.add(workOrderGenerationWrapper);
        }
        return workOrderGenerationWrappers;
    }

    /**
     * @description It is used to create a map of orderId to OrderItems.
     * @param orderIds
     */
    private void getOrderToOrderItems(Set<Id> orderIds) {
        for (
            OrderItem eachOrderItem : OrderItemsSelector.newInstance()
                .selectOrderItemsByOrderIds(orderIds)
        ) {
            if (!orderToOrderItems.containsKey(eachOrderItem.OrderId)) {
                orderToOrderItems.put(eachOrderItem.OrderId, new List<OrderItem>());
            }
            orderToOrderItems.get(eachOrderItem.OrderId).add(eachOrderItem);
        }
    }

    /**
     * @description It is used to initailize wrapper for Onboarding Inputs Work Order Creation.
     * @JIRA# LEM-15321,LEM-15781
     * @param mxOnboardingLinkIds
     * @return WorkOrderGenerationWrapper
     */
    private List<WorkOrderGenerationWrapper> initializeOnboardingInputsWrapper(
        Set<Id> mxOnboardingLinkIds
    ) {
        if (mxOnboardingLinkIds.isEmpty()) {
            return new List<WorkOrderGenerationWrapper>();
        }
        Map<Id, Mx_Onboarding_Link__c> contractIdToMxOnboardingLink = new Map<Id, Mx_Onboarding_Link__c>();
        Set<String> uniqueIdentifiers = new Set<String>();
        for (
            Mx_Onboarding_Link__c eachMxOnboardingLink : MxOnboardingLinksSelector.newInstance()
                .selectByMxOnboardingLinkIds(mxOnboardingLinkIds)
        ) {
            contractIdToMxOnboardingLink.put(
                eachMxOnboardingLink.Contract__c,
                eachMxOnboardingLink
            );
            uniqueIdentifiers.add(eachMxOnboardingLink.UUID__c);
            contractIdToOpportunityId.put(
                eachMxOnboardingLink.Contract__c,
                eachMxOnboardingLink.Opportunity__c
            );
        }
        contractIdToSubscriptionsPresent = SubscriptionsService.getExistingSubscriptionsForContracts(
            contractIdToMxOnboardingLink.keySet()
        );
        contractIdToSubscriptionsPresent.remove(null);
        contractIdToWorkOrderToBeCreated = ContractsService.getEligibleContractsForOnboardingInputsWorkOrderCreation(
            contractIdToMxOnboardingLink.values(),
            contractIdToSubscriptionsPresent
        );
        getAssociatedAccountIdsForOnboardingInputs(uniqueIdentifiers);
        getContractsForAdsAndPromosWorkOrderCreation(contractIdToMxOnboardingLink);
        return createWorkOrderGenerationWrapperForOnboardingInputs(contractIdToMxOnboardingLink);
    }

    /**
     * @description It is used to check if WorkPlan is eligible for Marketing Kit Work Order
     * Creation.
     * @JIRA# LEM-18140
     * @param workPlanInstance
     * @param originatingMarketplaceWorkOrderIds
     * @return Boolean
     */
    private Boolean isWorkPlanEligibleForMarketingKitWorkOrderCreation(
        WorkPlan workPlanInstance,
        Set<Id> originatingMarketplaceWorkOrderIds
    ) {
        return !originatingMarketplaceWorkOrderIds.contains(workPlanInstance.WorkOrderId) &&
            (workPlanInstance.WorkOrder.Order_Protocol__c == EMAIL_ORDER_PROTOCOL ||
            workPlanInstance.WorkOrder.Order_Protocol__c == POS_ORDER_PROTOCOL);
    }

    /**
     * @description It checks if Product Family is already Processed.
     * @param productFamiliesProcessedForContract
     * @param subscriptionRecord
     * @return Boolean
     */
    private Boolean isProductFamilyAlreadyProcessed(
        Set<String> productFamiliesProcessedForContract,
        SBQQ__Subscription__c subscriptionRecord
    ) {
        Boolean alreadyProcessedProductFamily = productFamiliesProcessedForContract.contains(
            subscriptionRecord.SBQQ__Contract__c + subscriptionRecord.SBQQ__Product__r.Family
        );
        Boolean alreadyProcessedProductName = productFamiliesProcessedForContract.contains(
            subscriptionRecord.SBQQ__Contract__c + subscriptionRecord.SBQQ__Product__r.Name
        );
        Boolean alreadyProcessedRequiredFamily = productFamiliesProcessedForContract.contains(
            subscriptionRecord.SBQQ__Contract__c +
            subscriptionRecord.SBQQ__RequiredByProduct__r.Family
        );
        if (
            subscriptionRecord.Is_It_A_New_Product__c &&
            (subscriptionRecord.SBQQ__Product__r.Name.contains(STOREFRONT_PLATFORM) ||
            getSubscriptionProductFamily(subscriptionRecord).contains(STOREFRONT_PLATFORM))
        ) {
            return true;
        }
        switch on BOOLEANVALUESMAPPING.get(alreadyProcessedProductFamily) {
            when BOOLEAN_TRUE {
                return true;
            }
        }
        switch on BOOLEANVALUESMAPPING.get(alreadyProcessedProductName) {
            when BOOLEAN_TRUE {
                return true;
            }
        }
        switch on BOOLEANVALUESMAPPING.get(alreadyProcessedRequiredFamily) {
            when BOOLEAN_TRUE {
                return true;
            }
        }
        return false;
    }

    /**
     * @description It is used to check whether Account satisfies the following criteria for store
     * association with parent Work Order:
     * 1. Record Type should be 'Store'
     * 2. Address Verification Status should be 'Verified'
     * 3. Coverage should be 'In Coverage'
     * @param accountInstance
     * @return Boolean
     */
    private Boolean isAccountEligibleForStoreAssociation(Account accountInstance) {
        return accountInstance.RecordTypeId == STORE_ACCOUNT_RECORD_TYPE &&
            accountInstance.Address_Verification_Status__c ==
            ADDRESS_VERIFICATION_STATUS_VERIFIED &&
            accountInstance.Coverage__c == ADDRESS_COVERAGE_IN_COVERAGE;
    }

    /**
     * @description To check if wrapper should be initialized for the passed
     * Subscription.
     * @JIRA# LEM-15363
     * @param subscriptionToEvaluate
     * @param uniqueIdentifierToProductWorkOrderType
     * @return Boolean
     */
    private Boolean isSubscriptionEligibleForWrapperCreation(
        SBQQ__Subscription__c subscriptionToEvaluate,
        Set<String> uniqueIdentifierToProductWorkOrderType
    ) {
        Boolean isEligible;
        switch on INTEGRATIONSOURCESMAPPING.get(subscriptionToEvaluate.Integration_Source__c) {
            when SSOB {
                isEligible =
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    STOREFRONT_PLATFORM;
            }
            when SSMO {
                isEligible =
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    STOREFRONT_PLATFORM ||
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    MARKETPLACE_PLATFORM;
            }
            when RESSMO {
                isEligible =
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    STOREFRONT_PLATFORM ||
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    MARKETPLACE_PLATFORM ||
                    subscriptionToEvaluate.SBQQ__Product__r.Family ==
                    PRODUCT_FAMILY_ADVERTISEMENT ||
                    subscriptionToEvaluate.SBQQ__Product__r.Family ==
                    PRODUCT_FAMILY_MARKETPLACE_PROMOTION;
            }
            when MX_PORTAL {
                isEligible =
                    (subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    STOREFRONT_PLATFORM ||
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c ==
                    MARKETPLACE_PLATFORM) &&
                    (String.isNotBlank(subscriptionToEvaluate.Unique_Identifier__c) &&
                    (subscriptionToEvaluate.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c ==
                    subscriptionToEvaluate.Unique_Identifier__c ||
                    subscriptionToEvaluate.SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.Unique_Identifier__c ==
                    subscriptionToEvaluate.Unique_Identifier__c));
            }
        }
        return isEligible &&
            !uniqueIdentifierToProductWorkOrderType.contains(
                subscriptionToEvaluate.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c +
                    SEPARATOR +
                    subscriptionToEvaluate.SBQQ__Product__r.Work_Order_Type__c
            );
    }

    /**
     * @description It checks whether the passed datetime is on Saturday or Sunday.
     * @param dateTimeToValidate
     * @return Boolean
     */
    private Boolean isWeekend(Datetime dateTimeToValidate) {
        return dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_SATURDAY ||
            dateTimeToValidate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_SUNDAY;
    }

    /**
     * @description It is used to set Associated Account Ids field for Onboarding Inputs 'I' scenario.
     * 'I' Scenario - Product to be added on the Contract contains only Storefront.
     * @param workOrderGenerationWrapper
     * @param mxOnboardingLinkRecord
     */
    private void setAssociatedAccountIdsForProductAdditionScenarioContainingOnlyStorefrontProduct(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Mx_Onboarding_Link__c mxOnboardingLinkRecord
    ) {
        String associatedAccountIds;
        if (
            mxOnboardingLinkRecord.Onboarding_Scenario__c != ONBOARDING_SCENARIO_PRODUCT_ADDITION ||
            mxOnboardingLinkRecord.Product_on_Contract__c != STOREFRONT_PLATFORM
        ) {
            return;
        }
        associatedAccountIds = uniqueIdentiferToStoreAccountIds.containsKey(
                mxOnboardingLinkRecord.UUID__c
            )
            ? uniqueIdentiferToStoreAccountIds.get(mxOnboardingLinkRecord.UUID__c)
            : '';
        workOrderGenerationWrapper.setStoreAccountIds(associatedAccountIds);
    }

    /**
     * @description It is used to set values of fields for Mx Portal Store Addition.
     * @JIRA# LEM-14753
     * @param opportunityRecord
     * @param workOrderType
     * @param accountIdentifierToStoreAccounts
     * @return WorkOrderGenerationWrapper
     */
    private WorkOrderGenerationWrapper setMxPortalWrapper(
        Opportunity opportunityRecord,
        String workOrderType,
        Map<String, String> accountIdentifierToStoreAccounts
    ) {
        WorkOrderGenerationWrapper workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
        workOrderGenerationWrapper.setType(workOrderType);
        workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
        workOrderGenerationWrapper.setAccountId(opportunityRecord.AccountId);
        workOrderGenerationWrapper.setOpportunityId(opportunityRecord.Id);
        workOrderGenerationWrapper.setContractId(opportunityRecord.ContractId);
        workOrderGenerationWrapper.setPrimaryVertical(RX_PRIMARY_VERTICAL);
        workOrderGenerationWrapper.setSegment(SMB_SEGMENT);
        workOrderGenerationWrapper.setProvisioningProcess(AUTOMATIC_PROVISIONING_PROCESS);
        workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_COMPLETE_STATUS);
        workOrderGenerationWrapper.setProposedDateOfActivation(
            getProposedDateOfActivation(opportunityRecord.Unique_Identifier__c)
        );
        workOrderGenerationWrapper.setCreationSource(WORK_ORDER_SOURCE_MX_PORTAL);
        workOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_MX_PORTAL);
        workOrderGenerationWrapper.setUniqueIdentifier(opportunityRecord.Unique_Identifier__c);
        workOrderGenerationWrapper.setStoreAccountIds(
            accountIdentifierToStoreAccounts.get(
                opportunityRecord.AccountId + opportunityRecord.Unique_Identifier__c
            )
        );
        switch on WORKORDERTYPESMAPPING.get(workOrderType) {
            when MARKETPLACE {
                workOrderGenerationWrapper.setOrderProtocol(
                    uniqueIdentifierToOrderProtocol.get(opportunityRecord.Unique_Identifier__c)
                );
                workOrderGenerationWrapper.setActivatedCentrally(YES_ACTIVATED_CENTRALLY);
                workOrderGenerationWrapper.setMenuToBeCompletedBy(
                    uniqueIdentifierToMenuToBeCompletedBy.get(
                        opportunityRecord.Unique_Identifier__c
                    )
                );
            }
            when STOREFRONT {
                workOrderGenerationWrapper.setProposedDateOfActivation(
                    calculateDateExcludingWeekends(
                        workOrderGenerationWrapper.getProposedDateOfActivation(),
                        5
                    )
                );
                workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_YES);
            }
        }
        return workOrderGenerationWrapper;
    }

    /**
     * @description It is used to set the values of fields specific to Drive Work Order.
     * @JIRA# LEM-15783
     * @param workOrderGenerationWrapper
     * @param contractId
     */
    private void setOnboardingInputsWrapperForAdsAndPromos(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Id contractId
    ) {
        workOrderGenerationWrapper.setContractId(
            coreContractIdToAdsAndPromosContractId.get(contractId)
        );
        workOrderGenerationWrapper.setEstimatedNumberofStores(
            adsAndPromoContractIdToEstimatedNoOfStores.get(contractId)
        );
        workOrderGenerationWrapper.setProvisioningProcess(MANUAL_PROVISIONING_PROCESS);
        workOrderGenerationWrapper.setHasWorkPlansGenerated(true);
    }

    /**
     * @description It is used to set the values of fields specific to Drive Work Order.
     * @JIRA# LEM-15783
     * @param workOrderGenerationWrapper
     * @param mxOnboardingLinkRecord
     */
    private void setOnboardingInputsWrapperForDrive(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Mx_Onboarding_Link__c mxOnboardingLinkRecord
    ) {
        workOrderGenerationWrapper.setSubType(SUB_TYPE_NET_NEW_BUSINESS);
        workOrderGenerationWrapper.setStatus(STATUS_PLANNING);
        workOrderGenerationWrapper.setProposedDateOfActivation(
            calculateDateExcludingWeekends(System.today(), 7)
        );
        workOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_SYSTEM);
        if (
            mxOnboardingLinkRecord.Contract__r.Drive_Auto_Activation_Supported__c ==
            DRIVE_AUTO_ACTIVATION_SUPPORTED
        ) {
            workOrderGenerationWrapper.setSubType(SUB_TYPE_AUTO_ACTIVATION);
        }
    }

    /**
     * @description It is used to set the values of fields specific to Marketplace Work Order.
     * @JIRA# LEM-15783
     * @param workOrderGenerationWrapper
     * @param mxOnboardingLinkRecord
     */
    private void setOnboardingInputsWrapperForMarketplace(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Mx_Onboarding_Link__c mxOnboardingLinkRecord
    ) {
        if (
            mxOnboardingLinkRecord.Business_Onboarding_Details__r == null ||
            mxOnboardingLinkRecord.Business_Onboarding_Details__r.isEmpty()
        ) {
            return;
        }
        workOrderGenerationWrapper.setPhotoShootRequest(
            (String) getCombinedFieldValueByMultipleSobjectInstances(
                mxOnboardingLinkRecord.Business_Onboarding_Details__r,
                FIELD_MX_REQUESTED_PHOTOSHOOT
            )
        );
        workOrderGenerationWrapper.setPhotoShootDate(
            (Date) getCombinedFieldValueByMultipleSobjectInstances(
                mxOnboardingLinkRecord.Business_Onboarding_Details__r,
                FIELD_PHOTOSHOOT_DATE
            )
        );
        workOrderGenerationWrapper.setPhotoShootTime(
            (Time) getCombinedFieldValueByMultipleSobjectInstances(
                mxOnboardingLinkRecord.Business_Onboarding_Details__r,
                FIELD_PHOTOSHOOT_TIME
            )
        );
    }

    /**
     * @description It is used to set the values of fields specific to Storefront Work Order.
     * @JIRA# LEM-15783
     * @param workOrderGenerationWrapper
     * @param mxOnboardingLinkRecord
     */
    private void setOnboardingInputsWrapperForStorefront(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Mx_Onboarding_Link__c mxOnboardingLinkRecord
    ) {
        Boolean bundledWithMarketplace = getBundledWithMarketplaceValue(
            mxOnboardingLinkRecord.Onboarding_Scenario__c,
            mxOnboardingLinkRecord.Contract__c
        );
        switch on BOOLEANVALUESMAPPING.get(bundledWithMarketplace) {
            when BOOLEAN_TRUE {
                if (workOrderGenerationWrapper.getProposedDateOfActivation() != null) {
                    workOrderGenerationWrapper.setProposedDateOfActivation(
                        calculateDateExcludingWeekends(
                            workOrderGenerationWrapper.getProposedDateOfActivation(),
                            3
                        )
                    );
                }
                workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_YES);
            }
            when BOOLEAN_FALSE {
                workOrderGenerationWrapper.setProposedDateOfActivation(
                    calculateDateExcludingWeekends(System.today(), 3)
                );
                workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_NO);
            }
        }
    }

    /**
     * @description It is used to check whether the passed Subscription is eligible for
     * Amendement Work Order.
     * @param subscriptionRecord
     * @param existingSubscriptions
     * @return String
     */

    private Boolean isEligibleForAmendment(
        SBQQ__Subscription__c subscriptionRecord,
        Set<String> existingSubscriptions
    ) {
        String contractId = subscriptionRecord.SBQQ__Contract__c;
        return existingSubscriptions.contains(
                contractId + getSubscriptionProductFamily(subscriptionRecord)
            ) ||
            existingSubscriptions.contains(contractId + subscriptionRecord.SBQQ__Product__r.Name) ||
            (subscriptionRecord.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c == TYPE_AMENDMENT &&
            (getSubscriptionProductFamily(subscriptionRecord) == PRODUCT_FAMILY_HARDWARE ||
            subscriptionRecord.SBQQ__Product__r.Name == PRODUCT_FAMILY_HARDWARE));
    }

    /**
     * @description It is used to set the value of Type and Sub Type for Amendment Work Orders.
     * @JIRA# LEM-15364
     * @param workOrderGenerationWrapper
     * @param subscriptions
     */
    private void setTypeAndSubType(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        SBQQ__Subscription__c subscriptions
    ) {
        switch on WORKORDERTYPESMAPPING.get(getSubscriptionProductFamily(subscriptions)) {
            when MARKETPLACE, STOREFRONT {
                workOrderGenerationWrapper.setType(POST_SALES);
                workOrderGenerationWrapper.setSubType(SUB_TYPE_RATE_CHANGE);
                workOrderGenerationWrapper.setProvisioningProcess(AUTOMATIC_PROVISIONING_PROCESS);
            }
            when DRIVE {
                workOrderGenerationWrapper.setType(PRODUCT_FAMILY_DRIVE);
                workOrderGenerationWrapper.setSubType(SUB_TYPE_PARTNERSHIP);
            }
            when ADVERTISEMENT {
                workOrderGenerationWrapper.setType(ADS_PROMOS);
                workOrderGenerationWrapper.setHasWorkPlansGenerated(true);
            }
            when MARKETPLACE_PROMOTION {
                workOrderGenerationWrapper.setType(ADS_PROMOS);
                workOrderGenerationWrapper.setHasWorkPlansGenerated(true);
            }
        }
    }

    /**
     * @description It initializes fields common to SSOB and SSMO.
     * @JIRA# LEM-15363
     * @param workOrderGenerationWrapper
     * @param eachSubscription
     */
    private void setCommonFieldsForSSMOAndSSOB(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        SBQQ__Subscription__c eachSubscription
    ) {
        workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
        workOrderGenerationWrapper.setAccountId(eachSubscription.SBQQ__Account__c);
        workOrderGenerationWrapper.setOpportunityId(
            eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
        );
        workOrderGenerationWrapper.setContractId(eachSubscription.SBQQ__Contract__c);
        workOrderGenerationWrapper.setPrimaryVertical(RX_PRIMARY_VERTICAL);
        workOrderGenerationWrapper.setSegment(SMB_SEGMENT);
        workOrderGenerationWrapper.setCreationSource(eachSubscription.Integration_Source__c);
        workOrderGenerationWrapper.setWorkOrderSource(eachSubscription.Integration_Source__c);
    }

    /**
     * @description It initailizes fields for SSMO.
     * @JIRA# LEM-15363
     * @param workOrderGenerationWrapper
     * @param eachSubscription
     */
    private void setFieldsForSSMO(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        SBQQ__Subscription__c eachSubscription
    ) {
        workOrderGenerationWrapper.setProposedDateOfActivation(
            getProposedDateOfActivation(
                eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
            )
        );
        workOrderGenerationWrapper.setHasWorkPlansGenerated(true);
        workOrderGenerationWrapper.setProvisioningProcess(AUTOMATIC_PROVISIONING_PROCESS);
        workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_COMPLETE_STATUS);
        workOrderGenerationWrapper.setUniqueIdentifier(
            eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
        );
        workOrderGenerationWrapper.setPhotoShootRequest(PHOTOSHOOT_REQUESTED_YES);
        switch on WORKORDERTYPESMAPPING.get(eachSubscription.SBQQ__Product__r.Work_Order_Type__c) {
            when MARKETPLACE {
                if (eachSubscription.SBQQ__Contract__r.Account.Marketplace_Nintex_Id__c != null) {
                    setPhotoShootForNintexSSMOSubmission(
                        workOrderGenerationWrapper,
                        eachSubscription.SBQQ__Contract__r.Account.Nintex_Photoshoot_Text_Value__c
                    );
                    workOrderGenerationWrapper.setPhotoShootRequest(
                        eachSubscription.SBQQ__Contract__r.Account.Nintex_Mx_Requested_Photoshoot__c
                    );
                }
                workOrderGenerationWrapper.setType(MARKETPLACE_PLATFORM);
                workOrderGenerationWrapper.setOrderProtocol(
                    uniqueIdentifierToOrderProtocol.get(
                        eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
                    )
                );
                workOrderGenerationWrapper.setActivatedCentrally(YES_ACTIVATED_CENTRALLY);
                workOrderGenerationWrapper.setMenuToBeCompletedBy(
                    uniqueIdentifierToMenuToBeCompletedBy.get(
                        eachSubscription.SBQQ__Contract__r.SBQQ__Order__r.Unique_Identifier__c
                    )
                );
            }
            when STOREFRONT {
                workOrderGenerationWrapper.setProposedDateOfActivation(
                    calculateDateExcludingWeekends(
                        workOrderGenerationWrapper.getProposedDateOfActivation(),
                        5
                    )
                );
                workOrderGenerationWrapper.setType(STOREFRONT_PLATFORM);
                populateBundledWithMarketplace(eachSubscription, workOrderGenerationWrapper);
            }
        }
    }

    /**
     * @description It populates bundledWithMarketplace value.
     * @param subscription
     * @param workOrderGenerationWrapper
     */
    private void populateBundledWithMarketplace(
        SBQQ__Subscription__c subscription,
        WorkOrderGenerationWrapper workOrderGenerationWrapper
    ) {
        if (subscription.Integration_Source__c == CREATION_SOURCE_MX_PORTAL) {
            Boolean isBundledWithMarketplace = getBundledWithMarketplaceValueForMxPortal(
                subscription.SBQQ__Contract__r.SBQQ__Order__c
            );
            switch on BOOLEANVALUESMAPPING.get(isBundledWithMarketplace) {
                when BOOLEAN_TRUE {
                    workOrderGenerationWrapper.setBundledWithMarketplace(
                        BUNDLED_WITH_MARKETPLACE_YES
                    );
                }
                when BOOLEAN_FALSE {
                    workOrderGenerationWrapper.setBundledWithMarketplace(
                        BUNDLED_WITH_MARKETPLACE_NO
                    );
                }
            }
        } else {
            workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_YES);
        }
    }

    /**
     * @description It is used to group SObject Ids from Platform Event by SObject Types.
     * @param sobjectIds
     */
    private void groupSobjectIdsBySObjectTypes(Set<Id> sobjectIds) {
        for (Id eachId : sobjectIds) {
            switch on SOBJECTTYPETOOBJECTTYPES.get(eachId.getSObjectType()) {
                when SUBSCRIPTION {
                    subscriptionIds.add(eachId);
                }
                when WORK_PLAN {
                    workPlanIds.add(eachId);
                }
                when OPPORTUNITY {
                    opportunityIds.add(eachId);
                }
                when MX_ONBOARDING_LINK {
                    mxOnboardingLinkIds.add(eachId);
                }
                when INTERFACE_TRANSACTION {
                    interfaceTransactionIds.add(eachId);
                }
            }
        }
    }

    /**
     * @description It populates bundledWithMarketplace value for Mx Portal Work Order.
     * @param orderId
     * @return Boolean
     */
    private Boolean getBundledWithMarketplaceValueForMxPortal(Id orderId) {
        Boolean isBundledWithMarketplace = false;
        if (!orderToOrderItems.containsKey(orderId)) {
            return isBundledWithMarketplace;
        }
        for (OrderItem eachOrderItem : orderToOrderItems.get(orderId)) {
            if (
                String.isNotBlank(eachOrderItem.Package__c) &&
                eachOrderItem.Package__c != STOREFRONT_PLATFORM
            ) {
                isBundledWithMarketplace = true;
                break;
            }
        }
        return isBundledWithMarketplace;
    }

    /**
     * @description
     * @author rishab.goyal | 08-14-2024
     * @param workOrderGenerationWrapper
     * @param eachSubscription
     **/
    private void setFieldsForRESSMO(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        SBQQ__Subscription__c eachSubscription
    ) {
        if (eachSubscription.Integration_Source__c != RESSMO_CREATION_SOURCE) {
            return;
        }
        workOrderGenerationWrapper.setSalesRepName(getSalesRepfromSubscription(eachSubscription));

        if (
            eachSubscription.SBQQ__Product__r.Family == PRODUCT_FAMILY_ADVERTISEMENT ||
            eachSubscription.SBQQ__Product__r.Family == PRODUCT_FAMILY_MARKETPLACE_PROMOTION
        ) {
            workOrderGenerationWrapper.setProposedDateOfActivation(
                convertToNearestBusinessDay(
                    workOrderGenerationWrapper.getProposedDateOfActivation().addDays(5)
                )
            );
            workOrderGenerationWrapper.setType(ADS_PROMOS);
        }
        if (
            eachSubscription?.SBQQ__Contract__r?.SBQQ__Quote__r?.RESSMO_Payload__c != null &&
            eachSubscription?.SBQQ__Contract__r?.SBQQ__Quote__r?.RESSMO_Payload__c != ''
        ) {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
                eachSubscription.SBQQ__Contract__r.SBQQ__Quote__r.RESSMO_Payload__c
            );
            workOrderGenerationWrapper.setPosIntegrationType(
                (String) jsonMap.get(FIELD_POS_INTEGRATION_TYPE)
            );
            Map<String, Object> photoshootMap = (Map<String, Object>) jsonMap.get('Photoshoot');
            setPhotoShootFieldsFromPayload(workOrderGenerationWrapper, photoshootMap);
            if (
                workOrderGenerationWrapper.getOrderProtocol() == null ||
                workOrderGenerationWrapper.getOrderProtocol() != POS_ORDER_PROTOCOL
            ) {
                workOrderGenerationWrapper.setSalesNotesForMenuTeam(
                    (String) jsonMap.get(FIELD_SALES_NOTE_FOR_MENU_TEAM)
                );
            }
        }
        if (
            workOrderGenerationWrapper.getOrderProtocol() == null ||
            workOrderGenerationWrapper.getOrderProtocol() != POS_ORDER_PROTOCOL
        ) {
            workOrderGenerationWrapper.setMenuSetupMethod(MENU_SETUP_METHOD);
            workOrderGenerationWrapper.setmenuToBeCompletedBy(MENU_TO_BE_COMPLETED_BY);
        }
    }

    /**
     * @description - get SalesRep from subscription's quote.
     * @author Soumya Dash | 11-08-2024
     * @param subscription
     * @return Id
     **/
    private Id getSalesRepfromSubscription(SBQQ__Subscription__c subscription) {
        if (subscription?.SBQQ__Contract__r?.SBQQ__Quote__r?.SBQQ__SalesRep__c != null) {
            return subscription.SBQQ__Contract__r.SBQQ__Quote__r.SBQQ__SalesRep__c;
        }
        return subscription.SBQQ__Contract__r.CreatedById;
    }

    /**
     * @description method to update the PhotoShootFields from the Payload
     * @author VenkateshDD | 08-21-2024
     * @param workOrderGenerationWrapper
     * @param photoshootMap
     **/
    private void setPhotoShootFieldsFromPayload(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        Map<String, Object> photoshootMap
    ) {
        if (photoShootMap != null) {
            String photoShootRequest = photoshootMap.get('PhotoshootMxRequested') != null
                ? (String) photoshootMap.get('PhotoshootMxRequested')
                : '';
            workOrderGenerationWrapper.setPhotoShootRequest(photoShootRequest);

            Date photoShootDate = photoshootMap.get('PhotoshootDate') != null &&
                (String) photoshootMap.get('PhotoshootDate') != ''
                ? Date.valueOf((String) photoshootMap.get('PhotoshootDate'))
                : null;
            workOrderGenerationWrapper.setPhotoShootDate(photoShootDate);

            Time photoShootTime = photoshootMap.get('PhotoshootTime') != null &&
                (String) photoshootMap.get('PhotoshootTime') != ''
                ? Time.newInstance(
                      Integer.valueOf(((String) photoshootMap.get('PhotoshootTime')).split(':')[0]),
                      Integer.valueOf(((String) photoshootMap.get('PhotoshootTime')).split(':')[1]),
                      0,
                      0
                  )
                : null;
            workOrderGenerationWrapper.setPhotoShootTime(photoShootTime);
        }
    }

    /**
     * @description It sets the Photoshoot Date and Time for SSMO Nintex Subsmission.
     * @param workOrderGenerationWrapper
     * @param photoshootDateTimeTextValue
     */
    private void setPhotoShootForNintexSSMOSubmission(
        WorkOrderGenerationWrapper workOrderGenerationWrapper,
        String photoshootDateTimeTextValue
    ) {
        Date photoshootDate;
        Time photoshootTime;
        if (photoshootDateTimeTextValue != null) {
            List<String> dateTimeParts = photoshootDateTimeTextValue.split(' ');
            photoshootDate = Date.valueOf(dateTimeParts[0]);
            List<String> photoshootTimeComp = dateTimeParts[1].split(':');
            photoshootTime = Time.newInstance(
                Integer.valueOf(photoshootTimeComp[0]),
                Integer.valueOf(photoshootTimeComp[1]),
                Integer.valueOf(photoshootTimeComp[2]),
                0
            );
        }
        workOrderGenerationWrapper.setPhotoShootDate(photoshootDate);
        workOrderGenerationWrapper.setPhotoShootTime(photoshootTime);
    }

    /**
     * @description It creates the wrapper for Work Order Creation for Amendments.
     * @param subscription
     * @return WorkOrderGenerationWrapper
     */
    private WorkOrderGenerationWrapper setWorkOrderGenerationWrapperForAmendments(
        SBQQ__Subscription__c subscription
    ) {
        WorkOrderGenerationWrapper workOrderGenerationWrapper;
        workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
        workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
        workOrderGenerationWrapper.setAccountId(subscription.SBQQ__Account__c);
        workOrderGenerationWrapper.setOpportunityId(
            subscription.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c
        );
        workOrderGenerationWrapper.setContractId(subscription.SBQQ__Contract__c);
        workOrderGenerationWrapper.setPrimaryVertical(RX_PRIMARY_VERTICAL);
        workOrderGenerationWrapper.setSegment(SMB_SEGMENT);
        workOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_SYSTEM);
        workOrderGenerationWrapper.setProvisioningProcess(MANUAL_PROVISIONING_PROCESS);
        workOrderGenerationWrapper.setProvisioningStatus(PROVISIONING_NOT_STARTED_STATUS);
        if (storefrontContractIds.contains(subscription.SBQQ__Contract__c)) {
            workOrderGenerationWrapper.setProposedDateOfImplementation(
                calculateDateExcludingWeekends(System.today(), PDOI_OFFSET_FOR_STOREFRONT_AMENDMENT)
            );
        }
        setTypeAndSubType(workOrderGenerationWrapper, subscription);
        return workOrderGenerationWrapper;
    }

    /**
     * @description It is used to update Interface Transaction Status to Failure.
     */
    private void updateInterfaceTransactionStatusToFailure() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Id eachId : interfaceTransactionIds) {
            uow.registerDirty(
                new Interface_Transaction__c(
                    Id = eachId,
                    Status__c = INTERFACE_TRANSACTION_STATUS_FAILURE
                )
            );
        }
        uow.commitWork();
    }
}