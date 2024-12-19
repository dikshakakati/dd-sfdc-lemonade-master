/**
 * @author Deloitte
 * @date 06/17/2022
 * @description Service implementation class for Work Orders creation related logic.
 * TODO: Fix cyclomatic complexity for this class.
 */
@SuppressWarnings(
    'PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.TooManyFields, PMD.ExcessiveClassLength, PMD.ExcessiveParameterList'
)
public inherited sharing class WorkOrdersCreationServiceImpl implements IWorkOrdersCreationService {
    private static final String ACCOUNT_IN_COVERAGE = 'In Coverage';
    private static final String ACCOUNT_ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String COMMA_SEPARATOR = ',';
    private static final String CREATION_SOURCE_ADD_STORES = 'Add Stores';
    private static final String CREATION_SOURCE_MANAGE_STORES = 'Manage Stores';
    private static final String CREATION_SOURCE_MANUAL = 'Manual';
    private static final String CREATION_SOURCE_NINTEX = 'Nintex';
    private static final String CREATION_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final String CREATION_SOURCE_SSMO = 'SSMO';
    private static final String CREATION_SOURCE_SSOB = 'SSOB';
    private static final String DISALLOW_PDOX_OVERRIDE_YES = 'Yes';
    private static final String DRIVE_NINTEX_ID_FIELD = 'Drive_Nintex_Id__c';
    private static final String DRIVE_WORK_ORDER_TYPE = 'Drive';
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION = 'PHOTOSHOOT_WORK_ORDER_CREATION';
    private static final String LOG_ERROR_MESSAGE_FOR_ACCOUNT_PARENTID_NULL = 'This store account has Parent Id as null';
    private static final String LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND = 'There is no parent Work Order in Planning or Confirmed status or within PDOA date range. Product not found for type: ';
    private static final String LOG_ERROR_MESSAGE_FOR_NO_ACTIVE_STORE_ID_ON_STORES = 'The store(s) did not have an Active Store ID associated to it therefore it cannot be associated to a Storefront or Post-Sales Rate Change work order.';
    private static final String LOG_ERROR_MESSAGE_FOR_STORE_CRITERIA_MISMATCH = 'Associated Store Account does not have address verified or is not in coverage';
    private static final String LOG_RECORD_METHOD_NAME = 'createWorkOrders';
    private static final String MARKETPLACE_NINTEX_ID_FIELD = 'Marketplace_Nintex_Id__c';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String PROVISIONING_STATUS_READINESS_CHECK = 'Readiness Check';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORK_ORDER_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_PHOTOHOOT = 'Photshoot';
    private static final String WORK_ORDER_TYPE_POS = 'POS';
    private static final String WO_SUBTYPE_COO = 'COO Same Store';
    private static final String WORK_ORDER_CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_CREATION_SOURCE_SSMO = 'SSMO';
    private static final String WORK_ORDER_CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final String WORK_ORDER_PROVISIONING_NOT_STARTED = 'Not Started';
    private static final String WORK_ORDER_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final Set<String> WORK_ORDER_MATCH_BY_CONTRACT_TYPE_SUB_TYPES = new Set<String>{
        'COO' +
        SEPARATOR +
        null,
        'Post-Sales' +
        SEPARATOR +
        'Rate Change',
        'Ads & Promos' +
        SEPARATOR +
        null
    };
    private static final Set<String> WORK_ORDER_TYPES_FOR_PROVISIONING_STATUS_NOT_STARTED = new Set<String>{
        WORK_ORDER_MARKETING_KIT,
        WORK_ORDER_TYPE_PHOTOHOOT
    };

    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        WORK_ORDER_TYPE_MARKETPLACE,
        STOREFRONT
    };
    private enum EventTopics {
        EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION_HANDLER
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION => EventTopics.EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION_HANDLER
    };
    private static final Set<String> CREATION_SOURCES_TO_BYPASS_READINESS_CHECK = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL,
        WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME,
        WORK_ORDER_CREATION_SOURCE_SSMO,
        WORK_ORDER_CREATION_SOURCE_RESSMO
    };
    private static final Set<String> CREATION_SOURCES_APPLICABLE_FOR_SYNCING_DATA_WITH_STORE = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_SSMO,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL
    };
    private static final Set<String> CREATION_SOURCES_APPLICABLE_FOR_SYNCING_PDOI_WITH_STORE = new Set<String>{
        CREATION_SOURCE_MANUAL,
        CREATION_SOURCE_NINTEX,
        CREATION_SOURCE_ONBOARDING_INPUTS
    };
    private static final Set<String> WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_CREATION_SOURCE = new Set<String>{
        CREATION_SOURCE_RESSMO,
        CREATION_SOURCE_SSMO,
        CREATION_SOURCE_SSOB,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL
    };
    private static final Set<String> WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_PROVISIONING_STATUS = new Set<String>{
        CREATION_SOURCE_RESSMO,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL
    };
    private static final Set<String> WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_BUNDLED_WITH_MARKETPLACE = new Set<String>{
        CREATION_SOURCE_ONBOARDING_INPUTS
    };
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private Map<Id, AccountDetails> accountIdToAccountDetails;
    private Map<Id, List<LogMessageEntry>> accountIdToLogMessageEntries;
    public Set<Id> businessAccountIds;
    private Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders;
    private Set<Id> contractIds;
    private Map<Id, List<WorkOrder>> contractIdToParentWorkOrders;
    private InsertUnitOfWorkHelper insertUnitOfWorkHelper;
    private Set<String> nintexIds;
    private Map<String, List<WorkOrder>> nintexIdToParentWorkOrders;
    private Map<String, WorkOrder> orderItemIdentifierToWorkOrder;
    private Map<Id, Set<Id>> parentWorkOrderIdToStoreAccountIds;
    private Set<Id> parentWorkOrderIds;
    private Set<String> recipientIdsToNotify;
    public Set<Id> storeAccountIds;
    private Map<Id, String> storeAccountIdsToActiveMDSExternalId;
    private Map<Id, Boolean> storeAccountIdToHasBundledProducts;
    private Map<Id, Set<String>> storeAccountIdToTypes;
    private List<Account> storeAccountsToCopyPDOX;
    private fflib_ISObjectUnitOfWork unitOfWorkInstance;
    private List<Database.SaveResult> workOrderInsertSaveResults;
    private List<WorkOrder> workOrdersToInsert;
    private Set<String> accountUniqueIdentifiers;
    private Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders;

    /**
     * @description Default constructor to instantiate variables.
     */
    public WorkOrdersCreationServiceImpl() {
        this.accountIdToAccountDetails = new Map<Id, AccountDetails>();
        this.accountIdToLogMessageEntries = new Map<Id, List<LogMessageEntry>>();
        this.accountUniqueIdentifiers = new Set<String>();
        this.businessAccountIds = new Set<Id>();
        this.businessAccountIdToParentWorkOrders = new Map<Id, List<WorkOrder>>();
        this.contractIds = new Set<Id>();
        this.contractIdToParentWorkOrders = new Map<Id, List<WorkOrder>>();
        this.nintexIds = new Set<String>();
        this.nintexIdToParentWorkOrders = new Map<String, List<WorkOrder>>();
        this.orderItemIdentifierToWorkOrder = new Map<String, WorkOrder>();
        this.parentWorkOrderIds = new Set<Id>();
        this.parentWorkOrderIdToStoreAccountIds = new Map<Id, Set<Id>>();
        this.storeAccountIds = new Set<Id>();
        this.storeAccountIdsToActiveMDSExternalId = new Map<Id, String>();
        this.storeAccountIdToHasBundledProducts = new Map<Id, Boolean>();
        this.storeAccountIdToTypes = new Map<Id, Set<String>>();
        this.storeAccountsToCopyPDOX = new List<Account>();
        this.uniqueIdentifierToParentWorkOrders = new Map<String, List<WorkOrder>>();
        this.unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        this.insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        // Register custom insert unit of work to allow partial success
        unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
        workOrdersToInsert = new List<WorkOrder>();
    }

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> marketplaceWorkOrdersIds;
        Set<Id> recordIdsByPayload;

        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION_HANDLER {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    marketplaceWorkOrdersIds = new Set<Id>();
                    marketplaceWorkOrdersIds.addAll(recordIdsByPayload);
                }
            }
        }
        createPhotoshootWorkOrder(marketplaceWorkOrdersIds);
    }

    /**
     * @description It is used to create child Work Orders on the passed parent Work Order
     * using the passed store Accounts.
     * @JIRA# LEM-2013
     * @param parentWorkOrder
     * @param storeAccounts
     */
    public void createChildWorkOrdersOnStoreAccounts(
        WorkOrder parentWorkOrder,
        List<Account> storeAccounts
    ) {
        for (Account eachStoreAccount : storeAccounts) {
            storeAccountIds.add(eachStoreAccount.Id);
        }
        getActiveMDSXrefsByStoreAccountIds(storeAccountIds);
        for (Account eachStoreAccount : storeAccounts) {
            createChildWorkOrderByStoreAccount(
                parentWorkOrder,
                eachStoreAccount,
                CREATION_SOURCE_ADD_STORES
            );
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        AccountsService.populatePDOXOnStoreAccounts(storeAccountsToCopyPDOX);
        createLogEntries();
    }

    /**
     * @description create child workorder for the given store Id
     * to be related to the given parent work order id
     * @param storeAccountIdToParentWOIds
     */
    public void createChildWorkOrdersOnStoreAccounts(Map<Id, Set<Id>> storeAccountIdToParentWOIds) {
        Set<Id> workOrderIds = new Set<Id>();
        Map<Id, Account> storeAccountIdToAccount = new Map<Id, Account>(
            AccountsSelector.newInstance()
                .selectById(
                    (Set<String>) JSON.deserialize(
                        JSON.serialize(storeAccountIdToParentWOIds.keySet()),
                        Set<String>.class
                    )
                )
        );
        for (Id storeAccountId : storeAccountIdToParentWOIds.keySet()) {
            workOrderIds.addAll(storeAccountIdToParentWOIds.get(storeAccountId));
        }
        Map<Id, WorkOrder> parentWorkOrderIdToWorkOrder = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance().selectById(workOrderIds)
        );
        //LEM-18861: Collect 'Active' MDS Xrefs related to Store Account Ids.
        getActiveMDSXrefsByStoreAccountIds(storeAccountIdToParentWOIds.keySet());
        for (Account eachStoreAccount : storeAccountIdToAccount.values()) {
            for (Id eachParentWOId : storeAccountIdToParentWOIds.get(eachStoreAccount.Id)) {
                createChildWorkOrderByStoreAccount(
                    parentWorkOrderIdToWorkOrder.get(eachParentWOId),
                    eachStoreAccount,
                    null
                );
            }
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        AccountsService.populatePDOXOnStoreAccounts(storeAccountsToCopyPDOX);
        createLogEntries();
    }

    /**
     * @description It is used to create child Work Orders by franchise parent associated with
     * the passed store Accounts.
     * @JIRA# LEM-3658
     * @param franchiseParentToParentWorkOrder
     * @param storeAccounts
     */
    public void createChildWorkOrdersByFranchiseParents(
        Map<Id, WorkOrder> franchiseParentToParentWorkOrder,
        List<Account> storeAccounts
    ) {
        AccountDetails accountDetailsInstance;
        LogMessageEntry logMessageEntry;
        WorkOrder parentWorkOrder;
        Map<Id, Account> storeAccountsToEvaluate = new Map<Id, Account>(storeAccounts);
        recipientIdsToNotify = new Set<String>();
        if (storeAccounts.isEmpty()) {
            return;
        }
        String logMessage;
        // Collect 'Active' MDS Xrefs related to Store Account Ids.
        getActiveMDSXrefsByStoreAccountIds(storeAccountsToEvaluate.keySet());
        for (Account eachStoreAccount : storeAccounts) {
            logMessage = null;
            accountDetailsInstance = new AccountDetails(
                eachStoreAccount.ParentId,
                eachStoreAccount.Id,
                eachStoreAccount.Name
            );
            accountDetailsInstance.businessAccountOwnerId = eachStoreAccount.Parent.OwnerId;
            accountDetailsInstance.franchiseParentOwnerId = eachStoreAccount.Franchise_Parent__r.OwnerId;
            accountIdToAccountDetails.put(eachStoreAccount.Id, accountDetailsInstance);
            parentWorkOrder = franchiseParentToParentWorkOrder
                ?.get(eachStoreAccount.Franchise_Parent__c);
            if (isEmptyOrNull(parentWorkOrder)) {
                continue;
            }
            if (doesStoreAccountMatchesCriteria(eachStoreAccount)) {
                // LEM-12608: Added the check for 'Active' MDS Xref on the store account.
                if (
                    isActiveMDSXrefRequired(parentWorkOrder, null) &&
                    !storeAccountIdsToActiveMDSExternalId.containsKey(eachStoreAccount.Id)
                ) {
                    logMessage = LOG_ERROR_MESSAGE_FOR_NO_ACTIVE_STORE_ID_ON_STORES;
                }
            } else {
                logMessage = LOG_ERROR_MESSAGE_FOR_STORE_CRITERIA_MISMATCH;
            }
            if (String.isBlank(logMessage)) {
                createChildWorkOrderByStoreAccount(
                    parentWorkOrder,
                    eachStoreAccount,
                    CREATION_SOURCE_NINTEX
                );
                continue;
            }
            if (!accountIdToLogMessageEntries.containsKey(eachStoreAccount.Id)) {
                accountIdToLogMessageEntries.put(eachStoreAccount.Id, new List<LogMessageEntry>());
            }
            logMessageEntry = new LogMessageEntry(
                eachStoreAccount.ParentId,
                logMessage,
                userInfo.getUserId(),
                parentWorkOrder.Id,
                eachStoreAccount.Id
            );
            collectRecipientIdsForLogCreation(eachStoreAccount);
            logMessageEntry.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
            logMessageEntry.franchiseAccountId = eachStoreAccount.Franchise_Parent__c;
            logMessageEntry.recipientIdsToNotify = String.join(
                new List<String>(recipientIdsToNotify),
                COMMA_SEPARATOR
            );
            logMessageEntry.sendNotification = true;
            logMessageEntry.severityLevel = LogEntry.SeverityLevel.CRITICAL.name();
            logMessageEntry.storeAccountName = eachStoreAccount.Name;
            accountIdToLogMessageEntries.get(eachStoreAccount.Id).add(logMessageEntry);
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        AccountsService.populatePDOXOnStoreAccounts(storeAccountsToCopyPDOX);
        createLogEntries();
    }

    /**
     * @description It is an entry point to create Work Orders according to matching criteria.
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    public void createWorkOrders(Set<Id> orderItemIds, Boolean isManagePricingProcess) {
        List<OrderItem> orderItemsMatchingCriteria = new List<OrderItem>();
        orderItemsMatchingCriteria = getActivatedOrderItemsWithStoreDetails(
            orderItemIds,
            isManagePricingProcess
        );
        getParentWorkOrderDetailsByAccountIds();
        getParentWorkOrderDetailsByContractIds();
        getParentWorkOrderDetailsByNintexIds();
        getParentWorkOrderDetailsByMxOnboardingLinks();
        getChildWorkOrdersByParentWorkIdsAndStoreAccountIds(parentWorkOrderIds);
        storeAccountIdToHasBundledProducts = OrderItemsService.getStoresWithBundledOrderProducts(
            OrderItemsSelector.newInstance()
                .selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    storeAccountIds,
                    WORK_ORDER_TYPES
                )
        );
        getActiveMDSXrefsByStoreAccountIds(storeAccountIds);
        createChildWorkOrdersOnStoreAccountsByOrderItems(orderItemsMatchingCriteria);
        OrderItemsService.populateWorkOrderOnOrderItems(
            orderItemIdentifierToWorkOrder,
            orderItemsMatchingCriteria
        );
    }

    /**
     * @description It collects Owner Ids to send notification based on passed
     * Account details for store association failures Logs creation.
     * @param account
     */
    private void collectRecipientIdsForLogCreation(Account account) {
        if (account != null) {
            if (getNintexId(account) != null) {
                recipientIdsToNotify.add(account.Parent.OwnerId);
                recipientIdsToNotify.add(account.Franchise_Parent__r.OwnerId);
            } else {
                recipientIdsToNotify.add(account.Parent.OwnerId);
            }
        }
    }

    /**
     * @description It is used to collect mapping of Order Id to
     * Product's Work Order Type & Sub-Type to parent Work Order Id for populating Work Order
     * lookup on the Order Item associated with the store level Work Order.
     * @JIRA# LEM-2445, LEM-3200
     * @param orderProduct
     * @param workOrderInstance
     */
    private void collectOrderProductToWorkOrderMapping(
        OrderItem orderProduct,
        WorkOrder workOrderInstance
    ) {
        String orderItemIdentifier =
            orderProduct.Order.Id +
            SEPARATOR +
            workOrderInstance.Type__c +
            SEPARATOR +
            workOrderInstance.Sub_Type__c;
        if (!orderItemIdentifierToWorkOrder.containsKey(orderItemIdentifier)) {
            orderItemIdentifierToWorkOrder.put(orderItemIdentifier, null);
        }
        orderItemIdentifierToWorkOrder.put(orderItemIdentifier, workOrderInstance);
    }

    /**
     * @description It is used to copy "Proposed Date of Activation", "Proposed Date of Menu"
     * and "Proposed Date of Tablet" from parent Work Order to child Work Order when associated
     * store Account does not has "User Sets PDOX Value?" as 'Yes'.
     * @JIRA# LEM-2854, LEM-3402 & LEM-3442
     * @param childWorkOrder
     * @param parentWorkOrder
     * @param storeAccount
     */
    private void copyPDOXOnChildWorkOrderByParentWorkOrder(
        WorkOrder childWorkOrder,
        WorkOrder parentWorkOrder,
        Account storeAccount
    ) {
        Boolean isPDOXCopiedOnStoreAccount = false;
        // 'Disallow_PDOA_Override__c' represents "User Sets PDOA Value?" field value.
        if (
            evaluateANDLogicalOperator(
                storeAccount.Disallow_PDOA_Override__c != DISALLOW_PDOX_OVERRIDE_YES,
                !isEmptyOrNull(parentWorkOrder.Proposed_Date_of_Activation__c)
            )
        ) {
            childWorkOrder.Proposed_Date_of_Activation__c = parentWorkOrder.Proposed_Date_of_Activation__c;
            if (
                !CREATION_SOURCES_APPLICABLE_FOR_SYNCING_DATA_WITH_STORE.contains(
                    parentWorkOrder.Creation_Source__c
                ) ||
                evaluateANDLogicalOperator(
                    CREATION_SOURCES_APPLICABLE_FOR_SYNCING_DATA_WITH_STORE.contains(
                        parentWorkOrder.Creation_Source__c
                    ),
                    parentWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETPLACE
                )
            ) {
                storeAccount.Proposed_Date_of_Activation__c = parentWorkOrder.Proposed_Date_of_Activation__c;
            }
            isPDOXCopiedOnStoreAccount = true;
        }
        if (
            evaluateANDLogicalOperator(
                storeAccount.User_Sets_PDOT_Value__c != DISALLOW_PDOX_OVERRIDE_YES,
                !isEmptyOrNull(parentWorkOrder.Proposed_Date_of_Tablet__c)
            )
        ) {
            childWorkOrder.Proposed_Date_of_Tablet__c = parentWorkOrder.Proposed_Date_of_Tablet__c;
            storeAccount.Proposed_Date_of_Tablet__c = parentWorkOrder.Proposed_Date_of_Tablet__c;
            isPDOXCopiedOnStoreAccount = true;
        }
        if (
            evaluateANDLogicalOperator(
                storeAccount.User_Sets_PDOM_Value__c != DISALLOW_PDOX_OVERRIDE_YES,
                !isEmptyOrNull(parentWorkOrder.Proposed_Date_of_Menu__c)
            )
        ) {
            storeAccount.Proposed_Date_of_Menu__c = parentWorkOrder.Proposed_Date_of_Menu__c;
            isPDOXCopiedOnStoreAccount = true;
        }
        if (
            evaluateANDLogicalOperator(
                !isEmptyOrNull(parentWorkOrder.Activated_Centrally_AC__c),
                evaluateANDLogicalOperator(
                    CREATION_SOURCES_APPLICABLE_FOR_SYNCING_DATA_WITH_STORE.contains(
                        parentWorkOrder.Creation_Source__c
                    ),
                    evaluateANDLogicalOperator(
                        parentWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETPLACE,
                        parentWorkOrder.Activated_Centrally_AC__c !=
                        storeAccount.Activated_Centrally_AC__c
                    )
                )
            )
        ) {
            storeAccount.Activated_Centrally_AC__c = parentWorkOrder.Activated_Centrally_AC__c;
            isPDOXCopiedOnStoreAccount = true;
        }
        if (isEligibleForPDOIupdateOnStore(parentWorkOrder)) {
            storeAccount.Proposed_Date_of_Implementation__c = parentWorkOrder.Proposed_Date_of_Implementation__c;
            isPDOXCopiedOnStoreAccount = true;
        }
        if (
            isPDOXCopiedOnStoreAccount &&
            !(new Map<Id, Account>(storeAccountsToCopyPDOX).containsKey(storeAccount.Id))
        ) {
            storeAccountsToCopyPDOX.add(storeAccount);
        }
    }

    /**
     * @description It is used to create child Work Orders using passed OrderItems.
     * @param orderItemsMatchingCriteria
     */
    private void createChildWorkOrdersOnStoreAccountsByOrderItems(
        List<OrderItem> orderItemsMatchingCriteria
    ) {
        for (OrderItem eachOrderItem : orderItemsMatchingCriteria) {
            createChildWorkOrderByOrderItem(eachOrderItem);
        }
        unitOfWorkInstance.commitWork();
        workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        AccountsService.populatePDOXOnStoreAccounts(storeAccountsToCopyPDOX);
        createLogEntries();
    }

    /**
     * @description It is used to create child Work Order for a particular OrderItem.
     * @param matchingOrderItem
     */
    private void createChildWorkOrderByOrderItem(OrderItem matchingOrderItem) {
        String bundledWithMarketplace = BUNDLED_WITH_MARKETPLACE_NO;
        Account storeAccount = matchingOrderItem.Order.Account;
        WorkOrder parentWorkOrder = getMatchingParentWorkOrder(matchingOrderItem);
        String parentWorkOrderTypeSubTypeKey;
        if (isEmptyOrNull(parentWorkOrder)) {
            logErrors(
                LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND +
                getWorkOrderTypeByOrderItem(matchingOrderItem),
                matchingOrderItem,
                LogEntry.LogCategory.BUSINESS_ERROR.name(),
                true,
                LogEntry.SeverityLevel.HIGH.name()
            );
            return;
        }
        //preventing duplicate store Association if Associated Account Ids field is
        //already populated on Work Order.
        if (
            parentWorkOrder.Segment__c == SEGMENT_SMB &&
            String.isNotBlank(parentWorkOrder.Associated_Account_Ids__c) &&
            parentWorkOrder.Associated_Account_Ids__c.contains(storeAccount.Id)
        ) {
            return;
        }
        parentWorkOrderTypeSubTypeKey =
            parentWorkOrder.Type__c +
            SEPARATOR +
            parentWorkOrder.Sub_Type__c;
        bundledWithMarketplace = convertToBundledWithMarketplaceValue(
            storeAccountIdToHasBundledProducts?.containsKey(storeAccount.Id)
                ? storeAccountIdToHasBundledProducts.get(storeAccount.Id)
                : checkBundledWithMarketplaceOnSMBParentWorkOrder(parentWorkOrder),
            matchingOrderItem
        );
        if (
            parentWorkOrderIdToStoreAccountIds.containsKey(parentWorkOrder.Id) &&
            parentWorkOrderIdToStoreAccountIds.get(parentWorkOrder.Id).contains(storeAccount.Id)
        ) {
            return;
        }
        if (
            storeAccountIdToTypes.containsKey(storeAccount.Id) &&
            storeAccountIdToTypes.get(storeAccount.Id).contains(parentWorkOrderTypeSubTypeKey)
        ) {
            return;
        }
        if (
            isActiveMDSXrefRequired(parentWorkOrder, bundledWithMarketplace) &&
            !storeAccountIdsToActiveMDSExternalId.containsKey(storeAccount.Id)
        ) {
            logErrors(
                LOG_ERROR_MESSAGE_FOR_NO_ACTIVE_STORE_ID_ON_STORES,
                matchingOrderItem,
                LogEntry.LogCategory.BUSINESS_ERROR.name(),
                true,
                LogEntry.SeverityLevel.HIGH.name()
            );
            return;
        }
        if (!storeAccountIdToTypes.containsKey(storeAccount.Id)) {
            storeAccountIdToTypes.put(storeAccount.Id, new Set<String>());
        }
        storeAccountIdToTypes.get(storeAccount.Id).add(parentWorkOrderTypeSubTypeKey);
        if (!parentWorkOrderIdToStoreAccountIds.containsKey(parentWorkOrder.Id)) {
            parentWorkOrderIdToStoreAccountIds.put(parentWorkOrder.Id, new Set<Id>());
        }
        parentWorkOrderIdToStoreAccountIds.get(parentWorkOrder.Id).add(storeAccount.Id);
        WorkOrder workOrderInstance = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = storeAccount.Activated_Centrally_AC__c,
            Bundled_with_Marketplace__c = setBundledWithMarketplace(
                parentWorkOrder,
                bundledWithMarketplace
            ),
            Business_to_Store_Assignment__c = parentWorkOrder.Business_to_Store_Assignment__c,
            Contract__c = getContractIdByOrderProduct(matchingOrderItem),
            Creation_Source__c = setCreationSource(CREATION_SOURCE_MANAGE_STORES, parentWorkOrder),
            HasWorkPlansGenerated__c = parentWorkOrder?.HasWorkPlansGenerated__c,
            Matched_By__c = parentWorkOrder.Matched_By__c,
            Menu_Setup_Method__c = storeAccount.Menu_Setup_Method__c,
            Menu_to_be_Completed_By__c = storeAccount.Menu_to_be_Completed_By__c,
            Opportunity__c = parentWorkOrder.Opportunity__c,
            Mx_Onboarding_Link__c = parentWorkOrder.Mx_Onboarding_Link__c,
            Order_Protocol__c = storeAccount.Order_Protocol__c,
            OwnerId = parentWorkOrder.OwnerId,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = storeAccount.Proposed_Date_of_Activation__c,
            Proposed_Date_of_Implementation__c = parentWorkOrder.Proposed_Date_of_Implementation__c,
            Proposed_Date_of_Tablet__c = storeAccount.Proposed_Date_of_Tablet__c,
            Provisioning_Status__c = getProvisioningStatusByParentWorkOrderForChildWorkOrderByOrderItem(
                parentWorkOrder
            ),
            Sales_Notes_for_Menu_Team__c = storeAccount.Sales_Notes_for_Menu_Team__c,
            Status = parentWorkOrder.Status,
            Store_Id__c = getStoreId(storeAccount.Id),
            Sub_Type__c = parentWorkOrder.Sub_Type__c,
            Type__c = parentWorkOrder.Type__c,
            Work_Order_Source__c = setSource(WORK_ORDER_SOURCE_SYSTEM, parentWorkOrder),
            Sales_Rep_Name__c = parentWorkOrder.Sales_Rep_Name__c
        );
        workOrdersToInsert.add(workOrderInstance);
        copyPDOXOnChildWorkOrderByParentWorkOrder(workOrderInstance, parentWorkOrder, storeAccount);
        // Leveraging custom registerNew() method for partial success insertion.
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
        collectOrderProductToWorkOrderMapping(matchingOrderItem, workOrderInstance);
    }

    /**
     * @description It is used to set Bundled With Marketplace for the child Work Order
     * @param parentWorkOrder
     * @param bundledWithMarketplace
     * @return String
     */
    private String setBundledWithMarketplace(
        WorkOrder parentWorkOrder,
        String bundledWithMarketplace
    ) {
        return WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_BUNDLED_WITH_MARKETPLACE.contains(
                parentWorkOrder.Creation_Source__c
            )
            ? parentWorkOrder.Bundled_with_Marketplace__c
            : bundledWithMarketplace;
    }

    /**
     * @description It is used to check if Bundled with Marketplace is set for SMB Parent
     * Work Order.
     * @JIRA# LEM-18004
     * @param parentWorkOrder
     * @return Boolean
     */
    private Boolean checkBundledWithMarketplaceOnSMBParentWorkOrder(WorkOrder parentWorkOrder) {
        return parentWorkOrder.Segment__c == SEGMENT_SMB &&
            parentWorkOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES;
    }

    /**
     * @description It is used to convert Bundled With Marketplace boolean value
     * to the picklist values 'Yes' or 'No'.
     * @JIRA# LEM-2132
     * @param hasBundledMarketplace
     * @param activatedOrderItem
     * @return String
     */
    private String convertToBundledWithMarketplaceValue(
        Boolean hasBundledMarketplace,
        OrderItem activatedOrderItem
    ) {
        String bundledWithMarketplace = BUNDLED_WITH_MARKETPLACE_NO;
        if (
            evaluateANDLogicalOperator(
                evaluateANDLogicalOperator(
                    getWorkOrderTypeByOrderItem(activatedOrderItem) == STOREFRONT,
                    hasBundledMarketplace
                ),
                !activatedOrderItem.Existing_Store_Processed__c
            )
        ) {
            bundledWithMarketplace = BUNDLED_WITH_MARKETPLACE_YES;
        }
        return bundledWithMarketplace;
    }

    /**
     * @description It is used to create child Work Order using the details from
     * the passed store Account and the passed parent Work Order.
     * @JIRA# LEM-2013
     * @param parentWorkOrder
     * @param storeAccount
     * @param creationSource
     */
    private void createChildWorkOrderByStoreAccount(
        WorkOrder parentWorkOrder,
        Account storeAccount,
        String creationSource
    ) {
        WorkOrder workOrderInstance = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = storeAccount.Activated_Centrally_AC__c,
            Bundled_with_Marketplace__c = parentWorkOrder.Bundled_with_Marketplace__c,
            Business_to_Store_Assignment__c = parentWorkOrder.Business_to_Store_Assignment__c,
            Contract__c = parentWorkOrder?.Contract__c,
            Creation_Source__c = setCreationSource(creationSource, parentWorkOrder),
            HasWorkPlansGenerated__c = parentWorkOrder?.HasWorkPlansGenerated__c,
            Menu_Setup_Method__c = storeAccount.Menu_Setup_Method__c,
            Menu_to_be_Completed_By__c = storeAccount.Menu_to_be_Completed_By__c,
            Opportunity__c = parentWorkOrder.Opportunity__c,
            Mx_Onboarding_Link__c = parentWorkOrder.Mx_Onboarding_Link__c,
            Order_Protocol__c = storeAccount.Order_Protocol__c,
            POS_Integration_Type__c = parentWorkOrder.POS_Integration_Type__c,
            OwnerId = parentWorkOrder.OwnerId,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = evaluateANDLogicalOperator(
                    !String.isBlank(parentWorkOrder.Sub_Type__c),
                    WO_SUBTYPE_COO.Equals(parentWorkOrder.Sub_Type__c)
                )
                ? storeAccount.Change_of_Ownership_Effective_Date__c
                : storeAccount.Proposed_Date_of_Activation__c,
            Proposed_Date_of_Implementation__c = parentWorkOrder.Proposed_Date_of_Implementation__c,
            Provisioning_Status__c = getProvisioningStatusByParentWorkOrder(parentWorkOrder),
            Sales_Notes_for_Menu_Team__c = storeAccount.Sales_Notes_for_Menu_Team__c,
            Status = parentWorkOrder.Status,
            Sub_Type__c = parentWorkOrder.Sub_Type__c,
            Type__c = parentWorkOrder.Type__c,
            Work_Order_Source__c = setSource(WORK_ORDER_SOURCE_SYSTEM, parentWorkOrder),
            Store_Id__c = getStoreId(storeAccount.Id),
            Sales_Rep_Name__c = parentWorkOrder.Sales_Rep_Name__c
        );
        workOrdersToInsert.add(workOrderInstance);
        copyPDOXOnChildWorkOrderByParentWorkOrder(workOrderInstance, parentWorkOrder, storeAccount);
        // Leveraging custom registerNew() method for partial success insertion.
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
    }

    /**
     * @description It is used to create log records for the issues recorded
     * while generating child Work Orders.
     */
    private void createLogEntries() {
        List<LogMessageEntry> logMessageEntries = new List<LogMessageEntry>();
        createLogEntriesByDMLResults();
        if (isEmptyOrNull(accountIdToLogMessageEntries.values())) {
            return;
        }
        for (List<LogMessageEntry> eachLogMessageEntries : accountIdToLogMessageEntries.values()) {
            logMessageEntries.addAll(eachLogMessageEntries);
        }
        // Create payload for asynchronous creation of business error logs.
        LogCreationEntry logCreationEntryInstance = new LogCreationEntry(
            WorkOrdersCreationServiceImpl.class.getName(),
            LOG_RECORD_METHOD_NAME,
            logMessageEntries
        );
        NotifierEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => JSON.serialize(
                    new List<LogCreationEntry>{ logCreationEntryInstance }
                )
            }
        );
    }

    /**
     * @description It determines the Creation Source value for child WorkOrder
     * based on parentWork Order.
     * @param creationSource
     * @param parentWorkOrder
     * @return String
     */
    private String setCreationSource(String creationSource, WorkOrder parentWorkOrder) {
        return (creationSource == null && parentWorkOrder.Type__c != WORK_ORDER_TYPE_POS) ||
            WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_CREATION_SOURCE.contains(
                parentWorkOrder?.Creation_Source__c
            )
            ? parentWorkOrder?.Creation_Source__c
            : creationSource;
    }

    /**
     * @description It determines the Source value for child WorkOrder
     * based on parentWork Order.
     * @param source
     * @param parentWorkOrder
     * @return String
     */
    private String setSource(String source, WorkOrder parentWorkOrder) {
        return parentWorkOrder?.Work_Order_Source__c == CREATION_SOURCE_RESSMO ||
            parentWorkOrder?.Work_Order_Source__c == CREATION_SOURCE_SSMO ||
            parentWorkOrder?.Creation_Source__c == CREATION_SOURCE_SSOB
            ? parentWorkOrder?.Work_Order_Source__c
            : source;
    }

    /**
     * @description It is used to create log records using DML save results.
     */
    private void createLogEntriesByDMLResults() {
        LogMessageEntry logMessageEntry;
        Database.SaveResult saveResult;
        recipientIdsToNotify = new Set<String>();
        if (isEmptyOrNull(workOrderInsertSaveResults)) {
            return;
        }
        AccountDetails accountDetailsInstance;
        for (Integer iterator = 0; iterator < workOrderInsertSaveResults.size(); iterator++) {
            saveResult = workOrderInsertSaveResults[iterator];
            for (Database.Error eachError : saveResult.getErrors()) {
                if (
                    !accountIdToLogMessageEntries.containsKey(
                        workOrdersToInsert[iterator].AccountId
                    )
                ) {
                    accountIdToLogMessageEntries.put(
                        workOrdersToInsert[iterator].AccountId,
                        new List<LogMessageEntry>()
                    );
                }
                accountDetailsInstance = accountIdToAccountDetails.get(
                    workOrdersToInsert[iterator].AccountId
                );
                logMessageEntry = new LogMessageEntry(
                    accountDetailsInstance.businessAccountId,
                    eachError.getMessage(),
                    userInfo.getUserId(),
                    workOrdersToInsert[iterator].ParentWorkOrderId,
                    workOrdersToInsert[iterator].AccountId
                );
                recipientIdsToNotify.add(accountDetailsInstance.businessAccountOwnerId);
                recipientIdsToNotify.add(accountDetailsInstance.franchiseParentOwnerId);
                logMessageEntry.franchiseAccountId = accountDetailsInstance.franchiseParentId;
                logMessageEntry.logType = LogEntry.LogCategory.DML_EXCEPTION.name();
                logMessageEntry.recipientIdsToNotify = String.join(
                    new List<String>(recipientIdsToNotify),
                    COMMA_SEPARATOR
                );
                logMessageEntry.sendNotification = true;
                logMessageEntry.severityLevel = LogEntry.SeverityLevel.HIGH.name();
                logMessageEntry.storeAccountName = accountDetailsInstance.storeAccountName;
                accountIdToLogMessageEntries.get(workOrdersToInsert[iterator].AccountId)
                    .add(logMessageEntry);
            }
        }
    }

    /**
     * @description It is used to check whether Store Account has address verified and in coverage.
     * @param storeAccount
     * @return Boolean
     */
    private Boolean doesStoreAccountMatchesCriteria(Account storeAccount) {
        return (evaluateANDLogicalOperator(
            storeAccount.Address_Verification_Status__c == ACCOUNT_ADDRESS_VERIFICATION_STATUS,
            storeAccount.Coverage__c == ACCOUNT_IN_COVERAGE
        ));
    }

    /**
     * @description It compares the received boolean values with AND(&&) logical operator
     * and returns the result.
     * It is added to reduce the Cyclomatic Complexity of the class.
     * @param leftOperand
     * @param rightOperand
     * @return Boolean
     */
    private Boolean evaluateANDLogicalOperator(Boolean leftOperand, Boolean rightOperand) {
        return leftOperand && rightOperand;
    }

    /**
     * @description It is used to collect active 'MDS' Xrefs related to Store Account Ids.
     * @JIRA# LEM-11610
     * @param storeAccountIds
     */
    private void getActiveMDSXrefsByStoreAccountIds(Set<Id> storeAccountIds) {
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveMDSXrefsByStoreIds(storeAccountIds)
        ) {
            if (
                storeAccountIdsToActiveMDSExternalId.containsKey(
                    eachXref.Salesforce_Account_Name__c
                )
            ) {
                continue;
            }
            storeAccountIdsToActiveMDSExternalId.put(
                eachXref.Salesforce_Account_Name__c,
                eachXref.External_Id__c
            );
        }
    }

    /**
     * @description It is used to get activated Order Item and
     * related Store and Business Account details.
     * @param orderItemIds
     * @param isManagePricingProcess
     * @return List<OrderItem>
     */
    private List<OrderItem> getActivatedOrderItemsWithStoreDetails(
        Set<Id> orderItemIds,
        Boolean isManagePricingProcess
    ) {
        Map<Id, OrderItem> orderItemsMatchingCriteria = new Map<Id, OrderItem>();
        AccountDetails accountDetailsInstance;
        for (
            OrderItem eachActivatedOrderItem : OrderItemsSelector.newInstance()
                .selectActivatedOrderItemsById(orderItemIds, isManagePricingProcess)
        ) {
            if (doesStoreAccountMatchesCriteria(eachActivatedOrderItem.Order.Account)) {
                //LEM-10895: Skipping Drive products in the corporate store association flow.
                if (
                    evaluateANDLogicalOperator(
                        isEmptyOrNull(eachActivatedOrderItem.Order.Account.Franchise_Parent__c),
                        (getWorkOrderTypeByOrderItem(eachActivatedOrderItem) ==
                        DRIVE_WORK_ORDER_TYPE)
                    )
                ) {
                    continue;
                }
                orderItemsMatchingCriteria.put(eachActivatedOrderItem.Id, eachActivatedOrderItem);
                accountDetailsInstance = new AccountDetails(
                    eachActivatedOrderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId,
                    eachActivatedOrderItem.Order.AccountId,
                    eachActivatedOrderItem.Order.Account.Name
                );
                accountDetailsInstance.businessAccountOwnerId = eachActivatedOrderItem.Order.Account.Parent.OwnerId;
                accountDetailsInstance.franchiseParentId = eachActivatedOrderItem.Order.Account.Franchise_Parent__c;
                accountDetailsInstance.franchiseParentOwnerId = eachActivatedOrderItem.Order.Account.Franchise_Parent__r.OwnerId;
                accountIdToAccountDetails.put(
                    eachActivatedOrderItem.Order.AccountId,
                    accountDetailsInstance
                );
                businessAccountIds.add(
                    eachActivatedOrderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
                );
                contractIds.add(getContractIdByOrderProduct(eachActivatedOrderItem));
                nintexIds.add(eachActivatedOrderItem.Order.Account.Marketplace_Nintex_Id__c);
                nintexIds.add(eachActivatedOrderItem.Order.Account.Drive_Nintex_Id__c);
                accountUniqueIdentifiers.add(
                    eachActivatedOrderItem.Order.Account.Mx_Onboarding_Link_Id__c
                );
                storeAccountIds.add(eachActivatedOrderItem.Order.AccountId);
                continue;
            }
            logErrors(
                LOG_ERROR_MESSAGE_FOR_STORE_CRITERIA_MISMATCH,
                eachActivatedOrderItem,
                LogEntry.LogCategory.BUSINESS_ERROR.name(),
                true,
                LogEntry.SeverityLevel.CRITICAL.name()
            );
        }
        return orderItemsMatchingCriteria.values();
    }

    /**
     * @description It is used to get child Work Order details related Store Account Ids.
     * @param parentWorkOrderIds
     */
    private void getChildWorkOrdersByParentWorkIdsAndStoreAccountIds(Set<Id> parentWorkOrderIds) {
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectChildWorkOrdersByStoreAccountIds(parentWorkOrderIds, storeAccountIds)
        ) {
            if (!parentWorkOrderIdToStoreAccountIds.containsKey(eachWorkOrder.ParentWorkOrderId)) {
                parentWorkOrderIdToStoreAccountIds.put(
                    eachWorkOrder.ParentWorkOrderId,
                    new Set<Id>()
                );
            }
            parentWorkOrderIdToStoreAccountIds.get(eachWorkOrder.ParentWorkOrderId)
                .add(eachWorkOrder.AccountId);
        }
    }

    /**
     * @description It returns the Contract Id by comparing Activation Order Product
     * and Primary Order Product.
     * @param activatedOrderItem
     * @return String
     */
    private String getContractIdByOrderProduct(OrderItem activatedOrderItem) {
        return isEmptyOrNull(activatedOrderItem.SBQQ__Contract__c)
            ? activatedOrderItem.Primary_Order_Product__r.SBQQ__Contract__c
            : activatedOrderItem.SBQQ__Contract__c;
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching criteria against Order Product:
     * 1. Contract Id for COO
     * 2. Nintex Id (Marketplace/Drive)
     * 3. Contract Id for Rate Change
     * 4. PDOA
     * 5. Storefront Type.
     * TODO: Fix cyclomatic complexity for this method.
     * @param currentOrderItem
     * @return WorkOrder
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private WorkOrder getMatchingParentWorkOrder(OrderItem currentOrderItem) {
        WorkOrder parentWorkOrder;
        Date accountPDOA = currentOrderItem.Order.Account.Proposed_Date_of_Activation__c;
        if (isEmptyOrNull(currentOrderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId)) {
            logErrors(
                LOG_ERROR_MESSAGE_FOR_ACCOUNT_PARENTID_NULL,
                currentOrderItem,
                LogEntry.LogCategory.GENERIC_LOG.name(),
                false,
                LogEntry.SeverityLevel.LOW.name()
            );
            return parentWorkOrder;
        }
        //checks for UUID match criteria for Onboarding Inputs.
        if (isEmptyOrNull(parentWorkOrder)) {
            parentWorkOrder = ParentWorkOrderMatcherService.matchByMxOnboardingLink(
                currentOrderItem,
                uniqueIdentifierToParentWorkOrders
            );
        }
        // checks for Nintex Id match criteria when Contract match criteria returns null
        if (isEmptyOrNull(parentWorkOrder)) {
            parentWorkOrder = ParentWorkOrderMatcherService.matchByNintexId(
                currentOrderItem,
                nintexIdToParentWorkOrders
            );
        }
        // checks for Contract match criteria for Rate Change scenario
        if (isEmptyOrNull(parentWorkOrder)) {
            parentWorkOrder = ParentWorkOrderMatcherService.matchByContractOnRateChange(
                currentOrderItem,
                contractIdToParentWorkOrders
            );
        }

        // checks for type post sales and rate change match criteria when PDOA match criteria returns null
        //@JIRA# LEM-12932
        if (isEmptyOrNull(parentWorkOrder)) {
            parentWorkOrder = ParentWorkOrderMatcherService.matchByRateChangeTypeFromRateChangeRequest(
                currentOrderItem,
                businessAccountIdToParentWorkOrders
            );
        }

        // checks for PDOA match criteria when Nintex Id match criteria returns null
        if (isEmptyOrNull(parentWorkOrder)) {
            if (
                evaluateANDLogicalOperator(
                    !isEmptyOrNull(accountPDOA),
                    WorkOrderSettingsService.isPDOAMatchingEnabled(
                        getWorkOrderTypeByOrderItem(currentOrderItem) +
                            SEPARATOR +
                            getWorkOrderSubTypeByOrderItem(currentOrderItem)
                    )
                ) &&
                businessAccountIdToParentWorkOrders.containsKey(
                    currentOrderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId
                )
            ) {
                parentWorkOrder = ParentWorkOrderMatcherService.matchByPDOA(
                    currentOrderItem,
                    businessAccountIdToParentWorkOrders
                );
            }
        }

        // checks for type match criteria when PDOA match criteria returns null
        if (isEmptyOrNull(parentWorkOrder)) {
            parentWorkOrder = ParentWorkOrderMatcherService.matchByType(
                currentOrderItem,
                businessAccountIdToParentWorkOrders
            );
        }
        return parentWorkOrder;
    }

    /**
     * @description It is used to get Drive or Marketplace Nintex Id from the passed Opportunity.
     * @param sObjectInstance
     * @return String
     */
    private String getNintexId(Sobject sObjectInstance) {
        return String.isNotBlank(String.valueOf(sObjectInstance?.get(MARKETPLACE_NINTEX_ID_FIELD)))
            ? String.valueOf(sObjectInstance?.get(MARKETPLACE_NINTEX_ID_FIELD))
            : String.valueOf(sObjectInstance?.get(DRIVE_NINTEX_ID_FIELD));
    }

    /**
     * @description It is used to get parent Work Order details related to Business Account Ids.
     */
    private void getParentWorkOrderDetailsByAccountIds() {
        businessAccountIds.remove(null);
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByBusinessAccountIds(businessAccountIds)
        ) {
            if (!businessAccountIdToParentWorkOrders.containsKey(eachWorkOrder.AccountId)) {
                businessAccountIdToParentWorkOrders.put(
                    eachWorkOrder.AccountId,
                    new List<WorkOrder>()
                );
            }
            businessAccountIdToParentWorkOrders.get(eachWorkOrder.AccountId).add(eachWorkOrder);
            parentWorkOrderIds.add(eachWorkOrder.Id);
        }
    }

    /**
     * @description It is used to get parent Work Order details related to Contract Ids
     * for COO type of Work Order.
     */
    private void getParentWorkOrderDetailsByContractIds() {
        contractIds.remove(null);
        String workOrderTypeSubTypeKey;
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentWorkOrdersByContractIds(contractIds)
        ) {
            workOrderTypeSubTypeKey = eachWorkOrder.Type__c + SEPARATOR + eachWorkOrder.Sub_Type__c;
            if (!WORK_ORDER_MATCH_BY_CONTRACT_TYPE_SUB_TYPES.contains(workOrderTypeSubTypeKey)) {
                continue;
            }
            if (!contractIdToParentWorkOrders.containsKey(eachWorkOrder.Contract__c)) {
                contractIdToParentWorkOrders.put(eachWorkOrder.Contract__c, new List<WorkOrder>());
            }
            contractIdToParentWorkOrders.get(eachWorkOrder.Contract__c).add(eachWorkOrder);
            parentWorkOrderIds.add(eachWorkOrder.Id);
        }
    }

    /**
     * @description It is used to get parent Work Order details by Nintex Ids
     * from associated Opportunity.
     */
    private void getParentWorkOrderDetailsByNintexIds() {
        nintexIds.remove(null);
        if (isEmptyOrNull(nintexIds)) {
            return;
        }
        String nintexId;
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance().selectByNintexIds(nintexIds)
        ) {
            nintexId = getNintexId(eachWorkOrder.Opportunity__r);
            if (!nintexIdToParentWorkOrders.containsKey(nintexId)) {
                nintexIdToParentWorkOrders.put(nintexId, new List<WorkOrder>());
            }
            nintexIdToParentWorkOrders.get(nintexId).add(eachWorkOrder);
            parentWorkOrderIds.add(eachWorkOrder.Id);
        }
    }

    /**
     * @description It is used to get parent Work Order details related to Mx Onboarding Links.
     * @JIRA# LEM-15782
     */
    private void getParentWorkOrderDetailsByMxOnboardingLinks() {
        accountUniqueIdentifiers.remove(null);
        if (accountUniqueIdentifiers.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentWorkOrdersByUniqueIdentifiers(accountUniqueIdentifiers)
        ) {
            if (
                !uniqueIdentifierToParentWorkOrders.containsKey(eachWorkOrder.Unique_Identifier__c)
            ) {
                uniqueIdentifierToParentWorkOrders.put(
                    eachWorkOrder.Unique_Identifier__c,
                    new List<WorkOrder>()
                );
            }
            uniqueIdentifierToParentWorkOrders.get(eachWorkOrder.Unique_Identifier__c)
                .add(eachWorkOrder);
            parentWorkOrderIds.add(eachWorkOrder.Id);
        }
    }

    /**
     * @description It evaluates and return Provisioning Status by the passed Parent Work Order.
     * @JIRA# LEM-15317
     * @param parentWorkOrder
     * @return String
     */
    private String getProvisioningStatusByParentWorkOrder(WorkOrder parentWorkOrder) {
        String provisioningStatus = PROVISIONING_STATUS_READINESS_CHECK;
        if (
            evaluateANDLogicalOperator(
                !String.isBlank(parentWorkOrder.Sub_Type__c),
                WO_SUBTYPE_COO.Equals(parentWorkOrder.Sub_Type__c)
            )
        ) {
            provisioningStatus = WORK_ORDER_PROVISIONING_COMPLETE;
        } else if (
            WORK_ORDER_TYPES_FOR_PROVISIONING_STATUS_NOT_STARTED.contains(parentWorkOrder.Type__c)
        ) {
            provisioningStatus = WORK_ORDER_PROVISIONING_NOT_STARTED;
        } else if (
            CREATION_SOURCES_TO_BYPASS_READINESS_CHECK.contains(parentWorkOrder.Creation_Source__c)
        ) {
            provisioningStatus = parentWorkOrder.Provisioning_Status__c;
        }
        return provisioningStatus;
    }

    /**
     * @description It evaluates and return Provisioning Status by the passed Parent Work Order.
     * @JIRA# LEM-19446
     * @param parentWorkOrder
     * @return String
     */
    private String getProvisioningStatusByParentWorkOrderForChildWorkOrderByOrderItem(
        WorkOrder parentWorkOrder
    ) {
        String provisioningStatus = PROVISIONING_STATUS_READINESS_CHECK;
        if (
            WORK_ORDER_CREATION_SOURCE_ELIGIBLE_TO_STAMP_PARENT_PROVISIONING_STATUS.contains(
                parentWorkOrder.Creation_Source__c
            )
        ) {
            provisioningStatus = parentWorkOrder.Provisioning_Status__c;
        } else if (
            parentWorkOrder.Segment__c == SEGMENT_SMB &&
            parentWorkOrder.Type__c == WORK_ORDER_TYPE_ADS_AND_PROMOS
        ) {
            provisioningStatus = PROVISIONING_STATUS_NOT_STARTED;
        }
        return provisioningStatus;
    }

    /**
     * @description It returns the Work Order Sub Type based on passed Order Item.
     * @param orderItem
     * @return String
     */
    private String getWorkOrderSubTypeByOrderItem(OrderItem orderItem) {
        return orderItem?.Product2?.Work_Order_Sub_Type__c == null
            ? orderItem
                  ?.SBQQ__QuoteLine__r
                  ?.SBQQ__RequiredBy__r
                  ?.SBQQ__Product__r
                  ?.Work_Order_Sub_Type__c
            : orderItem?.Product2?.Work_Order_Sub_Type__c;
    }

    /**
     * @description It returns the Work Order Type based on passed Order Item.
     * @param orderItem
     * @return String
     */
    private String getWorkOrderTypeByOrderItem(OrderItem orderItem) {
        return orderItem?.Product2?.Work_Order_Type__c == null
            ? orderItem
                  ?.SBQQ__QuoteLine__r
                  ?.SBQQ__RequiredBy__r
                  ?.SBQQ__Product__r
                  ?.Work_Order_Type__c
            : orderItem?.Product2?.Work_Order_Type__c;
    }

    /**
     * @description To check whether the passed work order is eligible for updating
     * 'Proposed Date of Implementation' on the store account.
     * @JIRA# LEM-25334
     * @param workOrderInstance
     * @return Boolean
     */
    private Boolean isEligibleForPDOIupdateOnStore(WorkOrder workOrderInstance) {
        return evaluateANDLogicalOperator(
                CREATION_SOURCES_APPLICABLE_FOR_SYNCING_PDOI_WITH_STORE.contains(
                    workOrderInstance.Creation_Source__c
                ),
                workOrderInstance.Type__c == STOREFRONT
            ) ||
            evaluateANDLogicalOperator(
                evaluateANDLogicalOperator(
                    workOrderInstance.Segment__c == SEGMENT_SMB,
                    workOrderInstance.Type__c == WORK_ORDER_TYPE_POST_SALES
                ),
                String.isNotBlank(
                    String.valueOf(workOrderInstance.Proposed_Date_of_Implementation__c)
                )
            );
    }

    /**
     * @description To check whether the passed parent work order (Type & Sub-type)
     * requires an active ‘MDS’ Xref. It is currently applicable to work order of type ‘Storefront’
     * (non-bundled) and ‘Post-Sales’.
     * @JIRA# LEM-11610
     * @param parentWorkOrder
     * @param bundledWithMarketplace
     * @return Boolean
     */
    private Boolean isActiveMDSXrefRequired(
        WorkOrder parentWorkOrder,
        String bundledWithMarketplace
    ) {
        return ((parentWorkOrder.Type__c == STOREFRONT &&
        bundledWithMarketplace != BUNDLED_WITH_MARKETPLACE_YES) ||
        (parentWorkOrder.Type__c == WORK_ORDER_TYPE_POST_SALES &&
        parentWorkOrder.Sub_Type__c == WORK_ORDER_SUB_TYPE_RATE_CHANGE));
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @JIRA# LEM-2013
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It is used to capture the log details for initializing
     * creation of Logs.
     * @param detailedMessage
     * @param orderItem
     * @param logErrorType
     * @param notifyAccountOwner
     * @param severityLevel
     */
    private void logErrors(
        String detailedMessage,
        OrderItem orderItem,
        String logErrorType,
        Boolean notifyAccountOwner,
        String severityLevel
    ) {
        recipientIdsToNotify = new Set<String>();
        if (!accountIdToLogMessageEntries.containsKey(orderItem.Order.AccountId)) {
            accountIdToLogMessageEntries.put(
                orderItem.Order.AccountId,
                new List<LogMessageEntry>()
            );
        }
        for (
            LogMessageEntry eachLogMessageEntry : accountIdToLogMessageEntries.get(
                orderItem.Order.AccountId
            )
        ) {
            if (eachLogMessageEntry.detailedMessage == detailedMessage) {
                return;
            }
        }
        LogMessageEntry logMessageEntry = new LogMessageEntry(
            orderItem.Primary_Order_Product__r.SBQQ__Contract__r.AccountId,
            detailedMessage,
            userInfo.getUserId(),
            orderItem.Id,
            orderItem.Order.AccountId
        );
        collectRecipientIdsForLogCreation(orderItem.Order.Account);
        logMessageEntry.franchiseAccountId = orderItem.Order.Account.Franchise_Parent__c;
        logMessageEntry.logType = logErrorType;
        logMessageEntry.recipientIdsToNotify = String.join(
            new List<String>(recipientIdsToNotify),
            COMMA_SEPARATOR
        );
        logMessageEntry.sendNotification = notifyAccountOwner;
        logMessageEntry.severityLevel = severityLevel;
        logMessageEntry.storeAccountName = orderItem.Order.Account.Name;
        accountIdToLogMessageEntries.get(orderItem.Order.AccountId).add(logMessageEntry);
    }

    /**
     * @description It is used to create photoshoot work order.
     * @param workOrders
     */
    public void createPhotoshootWorkOrder(Set<Id> workOrders) {
        List<WorkOrder> newWorkOrders = new List<WorkOrder>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrderForPhotoshoot(workOrders)
        ) {
            newWorkOrders.add(
                new WorkOrder(
                    Type__c = 'Photoshoot',
                    AccountId = eachWorkOrder.AccountId,
                    Photoshoot_Date__c = eachWorkOrder.Photoshoot_Date__c,
                    Photoshoot_Time__c = eachWorkOrder.Photoshoot_Time__c,
                    Store_Location_for_Photoshoot__c = eachWorkOrder.Store_Location_for_Photoshoot__c,
                    Status = 'Confirmed',
                    Mx_Requested_Photoshoot__c = eachWorkOrder.Mx_Requested_Photoshoot__c,
                    Opportunity__c = eachWorkOrder.Opportunity__c,
                    Contract__c = eachWorkOrder.Contract__c,
                    Originating_Work_Order__c = eachWorkOrder.Id,
                    Provisioning_Status__c = 'Not Started',
                    Creation_Source__c = 'Manual'
                )
            );
        }
        unitOfWorkInstance.registerNew(newWorkOrders);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception workStepsStatusUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    workStepsStatusUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria((newWorkOrders));
    }

    /**
     * @author Deloitte
     * @date 10/27/2023
     * @description Wrapper class to store account details.
     */
    private class AccountDetails {
        Id businessAccountId;
        Id businessAccountOwnerId;
        Id franchiseParentId;
        Id franchiseParentOwnerId;
        Id storeAccountId;
        String storeAccountName;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param businessAccountId
         * @param storeAccountId
         * @param storeAccountName
         */
        public AccountDetails(Id businessAccountId, Id storeAccountId, String storeAccountName) {
            this.businessAccountId = businessAccountId;
            this.storeAccountId = storeAccountId;
            this.storeAccountName = storeAccountName;
        }
    }

    /**
     * @description It returns "External Id" corresponding to the passed Store Account Id.
     * @JIRA# LEM-18861
     * @param storeAccountId
     * @return String
     */
    private String getStoreId(Id storeAccountId) {
        String storeId;
        if (storeAccountIdsToActiveMDSExternalId.containsKey(storeAccountId)) {
            storeId = storeAccountIdsToActiveMDSExternalId.get(storeAccountId);
        }
        return storeId;
    }
}