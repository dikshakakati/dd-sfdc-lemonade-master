/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Domain class for WorkOrder object.
 */

@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class WorkOrders extends fflib_SObjects implements IWorkOrders {
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String PRODUCT_BANNERS = 'Banners';
    private static final String PRODUCT_CRM = 'CRM';
    private static final String PRODUCT_DASHPASS_EXCLUSIVE_ITEMS = 'DashPass Exclusive Items';
    private static final String PRODUCT_SPONSORED_LISTINGS = 'Sponsored Listings';
    private static final String PRODUCT_BUY_ITEM = 'Buy Item, Get $X or Y% Off';
    private static final String PRODUCT_DOORDASH_DEALS = 'DoorDash Deals';
    private static final String PRODUCT_SPEND_X_GET_Y = 'Spend X, Get Y';
    private static final String PRODUCT_TRY_ME_FREE = 'Try Me Free';
    private static final String PRODUCT_BUY_ONE_GET_ONE = 'Buy One, Get One';
    private static final String PRODUCT_CUSTOM_MARKETING_PROMOTION = 'Custom Marketing Promotion';
    private static final String PRODUCT_FREE_ITEM_OVER_X = 'Free Item Over $X';
    private static final String PRODUCT_FIRST_ORDER_PERCENTAGE_OFF = 'First Order, Percentage Off';
    private static final String PRODUCT_ORDER_AGAIN = 'Order Again';
    private static final String PRODUCT_FIRST_ORDER_OFF = 'First Order, $ Off';
    private static final String PRODUCT_MARKETPLACE_LOYALITY = 'Marketplace Loyalty'; //not present
    private static final String PRODUCT_STORE_REWARDS_DD_LOYALTY = 'Store Rewards (DD Loyalty)';
    private static final String PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Parent_WorkOrders_Payload_Chunk_Size';
    private static final String CHILD_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Order_Ids_Payload_Chunk_Size';
    private static final String READINESS_CHECK_PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Readiness_Check_Parent_WO_Ids_Chunk_Size';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_POS = 'POS';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
    private static final Id ACCOUNT_BUSINESS_RECORD_TYPE_ID;
    private static final Id ACCOUNT_STORE_RECORD_TYPE_ID;
    private static final String ACCOUNT_FRANCHISE_REP_ROLE = 'Franchise Representative';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEPARATOR_COMMA = ',';
    static {
        ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
    }

    private static final Set<String> WORK_ORDER_PRIORITY_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final Set<String> WORK_ORDER_TYPES_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION = new Set<String>{
        TYPE_DRIVE,
        TYPE_POS,
        TYPE_STOREFRONT,
        TYPE_PHOTOSHOOT,
        TYPE_TABLET,
        TYPE_MARKETING_KIT
    };
    private static final Set<String> WORK_ORDER_TYPES_SUBTYPE_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION_FOR_SMB = new Set<String>{
        TYPE_ADS_AND_PROMOS + null,
        TYPE_POST_SALES + SUB_TYPE_RATE_CHANGE
    };
    private static final String WORK_ORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_PLAN_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private enum AdsAndPromosProducts {
        ADS,
        PROMOS
    }
    //To do.
    private static final Map<String, AdsAndPromosProducts> ELIGIBLE_ADS_AND_PROMOS_PRODUCTS = new Map<String, AdsAndPromosProducts>{
        PRODUCT_BANNERS => AdsAndPromosProducts.ADS,
        PRODUCT_CRM => AdsAndPromosProducts.ADS,
        PRODUCT_DASHPASS_EXCLUSIVE_ITEMS => AdsAndPromosProducts.ADS,
        PRODUCT_SPONSORED_LISTINGS => AdsAndPromosProducts.ADS,
        PRODUCT_BUY_ITEM => AdsAndPromosProducts.PROMOS,
        PRODUCT_DOORDASH_DEALS => AdsAndPromosProducts.PROMOS,
        PRODUCT_SPEND_X_GET_Y => AdsAndPromosProducts.PROMOS,
        PRODUCT_TRY_ME_FREE => AdsAndPromosProducts.PROMOS,
        PRODUCT_BUY_ONE_GET_ONE => AdsAndPromosProducts.PROMOS,
        PRODUCT_CUSTOM_MARKETING_PROMOTION => AdsAndPromosProducts.PROMOS,
        PRODUCT_FREE_ITEM_OVER_X => AdsAndPromosProducts.PROMOS,
        PRODUCT_FIRST_ORDER_PERCENTAGE_OFF => AdsAndPromosProducts.PROMOS,
        PRODUCT_ORDER_AGAIN => AdsAndPromosProducts.PROMOS,
        PRODUCT_FIRST_ORDER_OFF => AdsAndPromosProducts.PROMOS,
        PRODUCT_MARKETPLACE_LOYALITY => AdsAndPromosProducts.PROMOS,
        PRODUCT_STORE_REWARDS_DD_LOYALTY => AdsAndPromosProducts.PROMOS
    };

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description This method is used to return the IWorkOrders interface.
     * @param workOrderRecords
     * @return IWorkOrders - Returns IWorkOrders Interface
     */
    public static IWorkOrders newInstance(List<WorkOrder> workOrderRecords) {
        return (IWorkOrders) Application.Domain.newInstance(workOrderRecords);
    }

    /**
     * @description Default constructor to instantiate the variables.
     * @param sObjectList
     */
    public WorkOrders(List<WorkOrder> sObjectList) {
        super(sObjectList, Schema.WorkOrder.SObjectType);
    }

    /**
     * @description It collects child Work Order record with updated parent Work Order Id.
     * @JIRA# LEM-6198
     * @param parentWorkOrders
     */
    public void collectParentWorkOrdersWithUpdatedInformation(List<WorkOrder> parentWorkOrders) {
        Set<Id> parentWorkOrderIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : parentWorkOrders) {
            if (eachWorkOrder.ParentWorkOrderId != null) {
                continue;
            }
            parentWorkOrderIds.add(eachWorkOrder.Id);
        }
        if (parentWorkOrderIds.isEmpty()) {
            return;
        }

        getChildWorkOrdersWithParentWorkOrderDetailsByParentWorkOrderIds(
            parentWorkOrderIds,
            EVENT_TOPIC_WORK_OBJECTS_SYNC
        );
    }

    /**
     * @description It collects child Work Order Ids from changed parent Work Order for the
     * given topic and share bulk Notifier Events.
     * @JIRA# LEM-6198
     * @param parentWorkOrderIds
     * @param eventTopic
     */
    public void getChildWorkOrdersWithParentWorkOrderDetailsByParentWorkOrderIds(
        Set<Id> parentWorkOrderIds,
        String eventTopic
    ) {
        Map<Id, WorkOrder> childWorkOrders = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance().selectByParentWorkOrderIds(parentWorkOrderIds)
        );
        if (childWorkOrders.isEmpty()) {
            return;
        }
        Integer childWorkOrderIdPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CHILD_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventTopic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    childWorkOrders.keySet(),
                    childWorkOrderIdPayloadChunkSize
                )
            }
        );
    }

    /**
     * @description It collects child Work Order record with updated parent Work Order Id.
     * @JIRA# LEM-955
     * @param oldWorkOrders
     */
    public void collectChildWorkOrdersWithUpdatedParentWorkOrderId(
        Map<Id, WorkOrder> oldWorkOrders
    ) {
        List<WorkOrder> childWorkOrders = new List<WorkOrder>();
        WorkOrder oldWorkOrder;
        for (WorkOrder eachWorkOrder : (List<WorkOrder>) getRecords()) {
            oldWorkOrder = oldWorkOrders.get(eachWorkOrder.Id);
            childWorkOrders.add(eachWorkOrder);
            childWorkOrders.add(oldWorkOrder);
        }
        collectParentWorkOrderIds(childWorkOrders, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description It collects parent Work Order Ids from child Work Order for the given topic.
     * @JIRA# LEM-955, LEM-2083
     * @param childWorkOrders
     * @param eventTopic
     */
    public void collectParentWorkOrderIds(List<WorkOrder> childWorkOrders, String eventTopic) {
        Set<Id> parentWorkOrderIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (eachWorkOrder.ParentWorkOrderId == null) {
                continue;
            }
            parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
        }
        if (parentWorkOrderIds.isEmpty()) {
            return;
        }
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{ eventTopic => generatePayload(parentWorkOrderIds) }
        );
    }

    /**
     * @description Method to update Work Order status on PDOA, PDOT or PDOM update with future date
     * @param existingRecords
     * @JIRA LEM-985, LEM-1011, LEM-1226, LEM-5159
     */
    public void updateStatusOnPDOAOrPDOTChange(Map<Id, SObject> existingRecords) {
        Set<Id> workOrderIdsToProcessByWorkSteps = new Set<Id>();
        Map<Id, WorkOrder> workOrdersToProcessByWorkOrderHistory = new Map<Id, WorkOrder>();
        for (WorkOrder currentWorkOrder : (List<WorkOrder>) getRecords()) {
            WorkOrder existingWorkOrder = (WorkOrder) existingRecords.get(currentWorkOrder.Id);
            if (addWorkRecordForStatusChange(existingWorkOrder, currentWorkOrder)) {
                if (currentWorkOrder.HasWorkPlansGenerated__c) {
                    workOrderIdsToProcessByWorkSteps.add(currentWorkOrder.Id);
                } else {
                    workOrdersToProcessByWorkOrderHistory.put(
                        currentWorkOrder.Id,
                        currentWorkOrder
                    );
                }
            }
        }
        if (!isEmptyOrNull(workOrderIdsToProcessByWorkSteps)) {
            WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
                workOrderIdsToProcessByWorkSteps
            );
        }
        if (!isEmptyOrNull(workOrdersToProcessByWorkOrderHistory)) {
            WorkOrdersService.updateWorkOrderStatusByWorkOrderHistory(
                workOrdersToProcessByWorkOrderHistory
            );
        }
    }

    /**
     * @description It validate and update Work Order fields on Before Insert trigger event.
     */
    public void onBeforeInsertValidateAndUpdateWorkOrderFields() {
        List<WorkOrder> childWorkOrders = new List<WorkOrder>();
        List<WorkOrder> childWorkOrdersWithNonDriveAndNonPOS = new List<WorkOrder>();
        List<WorkOrder> driveAutoActivationsWorkOrder = new List<WorkOrder>();
        Set<Id> accountIdsWithDriveAutoActivationsWorkOrder = new Set<Id>();
        Set<Id> storeAccountIds = new Set<Id>();
        Map<Id, WorkOrder> contractIdToAdsAndPromosWorkOrder = new Map<Id, WorkOrder>();
        Set<Id> businessAccountIdsToAssociateActiveMxTags = new Set<Id>();
        List<WorkOrder> smbParentWorkOrders = new List<WorkOrder>();
        for (WorkOrder eachWorkOrder : (List<WorkOrder>) getRecords()) {
            //JIRA#: LEM-23063
            eachWorkOrder.Sales_Rep_Name__c = String.isBlank(eachWorkOrder.Sales_Rep_Name__c)
                ? UserInfo.getUserId()
                : eachWorkOrder.Sales_Rep_Name__c;
            //JIRA#: LEM-746
            copyAccountOwnerEmail(eachWorkOrder);
            //JIRA#: LEM-1048
            copyWorkOrderDateFieldsToOriginalDateFields(eachWorkOrder);
            /* JIRA#: LEM-4195
             * checking child Work Orders eligibility for 'Decision Maker'
             * and skipping decision maker logic for parent Work Orders
             */
            if (
                isChildWorkOrder(eachWorkOrder) &&
                WorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(eachWorkOrder)
            ) {
                childWorkOrders.add(eachWorkOrder);
            }
            /* JIRA#: LEM-7912
             * checking child Work Orders type not equal to Drive and POS
             */
            if (
                isChildWorkOrder(eachWorkOrder) &&
                !WORK_ORDER_TYPES_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION.contains(
                    (eachWorkOrder.Type__c)
                ) &&
                isEligibleWorkOrderTypeSubTypeToSkipOpenMarketplaceWorkOrderValidation(
                    eachWorkOrder
                )
            ) {
                childWorkOrdersWithNonDriveAndNonPOS.add(eachWorkOrder);
                storeAccountIds.add(eachWorkOrder.AccountId);
            }
            /* JIRA#: LEM-11612
             * Check for Work Orders created manually with type as 'Drive'
             * and sub-type as 'Auto-Activations'.
             */
            if (isDriveAutoActivationsCreatedManually(eachWorkOrder)) {
                accountIdsWithDriveAutoActivationsWorkOrder.add(eachWorkOrder.AccountId);
                driveAutoActivationsWorkOrder.add(eachWorkOrder);
            }
            /**
             * @description It is used to evaluate and populate if SMB Ads and Promos WorkOrder is eligible for
             * WorkPlan and WorkStep creation.
             * @JIRA# LEM-13559
             */
            if (isWorkOrderEligibleForAdsAndPromosWorkPlanCreation(eachWorkOrder)) {
                contractIdToAdsAndPromosWorkOrder.put(eachWorkOrder.Contract__c, eachWorkOrder);
            }

            /* JIRA#: LEM-14041
             * Check for Work Orders as segment 'SMB' and parent Work Order
             */
            if (
                eachWorkOrder.Segment__c == SEGMENT_SMB &&
                eachWorkOrder.ParentWorkOrderId == null
            ) {
                businessAccountIdsToAssociateActiveMxTags.add(eachWorkOrder.AccountId);
                smbParentWorkOrders.add(eachWorkOrder);
            }
        }
        //JIRA#: LEM-4195
        populateDecisionMaker(childWorkOrders);
        //JIRA#: LEM-7912
        validateAccountHavingInProgressMarketPlaceWO(
            childWorkOrdersWithNonDriveAndNonPOS,
            storeAccountIds
        );
        //JIRA#: LEM-11612
        preventDuplicateNonDeadDriveAutoActivationsWorkOrder(
            driveAutoActivationsWorkOrder,
            accountIdsWithDriveAutoActivationsWorkOrder
        );
        //JIRA#: LEM-14041
        populateActiveMxTags(businessAccountIdsToAssociateActiveMxTags, smbParentWorkOrders);
        if (!contractIdToAdsAndPromosWorkOrder.isEmpty()) {
            setAdsAndPromosWorkPlanCreationOnEligibleWorkOrders(contractIdToAdsAndPromosWorkOrder);
        }
        WorkOrdersService.setProposedDateofImplementationOnSMBStorefrontWorkOrders(
            smbParentWorkOrders
        );
    }

    /**
     * @description It validate and update Work Order fields on Before Update trigger event.
     * @param oldWorkOrders - The map of old Work Orders
     */
    public void onBeforeUpdateValidateAndUpdateWorkOrderFields(Map<Id, WorkOrder> oldWorkOrders) {
        WorkOrder oldWorkOrder;
        for (WorkOrder eachWorkOrder : (List<WorkOrder>) getRecords()) {
            oldWorkOrder = oldWorkOrders.get(eachWorkOrder.Id);
            //JIRA#: LEM-1048
            if (hasWorkOrderPDOTChanged(eachWorkOrder, oldWorkOrder)) {
                updateWorkOrderPDOTOriginalFromPDOT(eachWorkOrder);
            }
            //JIRA#: LEM-746
            if (hasWorkOrderAccountChanged(eachWorkOrder, oldWorkOrder)) {
                copyAccountOwnerEmail(eachWorkOrder);
            }
            if (hasWorkOrderPDOAChanged(eachWorkOrder, oldWorkOrder)) {
                restrictPDOAUpdateOnChildWorkOrder(eachWorkOrder);
            }
            if (
                hasWorkOrderStatusChanged(eachWorkOrder, oldWorkOrder) ||
                hasWorkOrderPDOAChanged(eachWorkOrder, oldWorkOrder)
            ) {
                //JIRA#: LEM-1010 & LEM-4205
                // Reverting indicator for system updates
                eachWorkOrder.Is_Updated_By_System__c = false;
            }
        }
    }

    /**
     * @description It restricts update of PDOA on Child Work Order
     * @JIRA# LEM-21971
     * @param workOrder
     */
    private void restrictPDOAUpdateOnChildWorkOrder(WorkOrder workOrder) {
        if (workOrder.Is_Updated_By_System__c) {
            return;
        }
        if (workOrder.ParentWorkOrderId != null) {
            workOrder.addError(System.Label.PDOA_Error_Message);
        }
    }

    /**
     * @description It checks whether WorkOrder PDOA has changed.
     * @JIRA# LEM-21971
     * @param newWorkOrder
     * @param oldWorkOrder
     * @return Boolean
     */
    private Boolean hasWorkOrderPDOAChanged(WorkOrder newWorkOrder, WorkOrder oldWorkOrder) {
        return (newWorkOrder.Proposed_Date_of_Activation__c !=
        oldWorkOrder.Proposed_Date_of_Activation__c &&
        workOrder.ParentWorkOrderId != null);
    }
    /**
     * @description It collects the Dead parent Work Order Ids and update the Child WorkSteps To Dead
     * @JIRA# LEM-5460
     * @param workOrders
     */
    public void updateChildWorkStepsStatusToDead(List<WorkOrder> workOrders) {
        if (workOrders.isEmpty()) {
            return;
        }
        WorkOrdersService.updateChildWorkStepsStatusToDead(
            new Map<Id, WOrkOrder>(workOrders).keySet()
        );
    }

    /**
     * @description It validates the passed Work Order segment is SMB and Type is either "Ads & Promos" or Sub-Type is "Rate Change".
     * @param workOrderToEvaluate
     * @return Boolean
     */
    private Boolean isEligibleWorkOrderTypeSubTypeToSkipOpenMarketplaceWorkOrderValidation(
        WorkOrder workOrderToEvaluate
    ) {
        Boolean isWorkOrderEligible = true;
        if (
            workOrderToEvaluate.Segment__c == SEGMENT_SMB &&
            WORK_ORDER_TYPES_SUBTYPE_TO_SKIP_IN_PROGRESS_MARKETPLACE_WORK_ORDER_VALIDATION_FOR_SMB.contains(
                workOrderToEvaluate.Type__c + workOrderToEvaluate.Sub_Type__c
            )
        ) {
            isWorkOrderEligible = false;
        }
        return isWorkOrderEligible;
    }

    /**
     * @description Method to check whether Work Order record add in the list or not.
     * @param existingWorkOrder
     * @param currentWorkOrder
     * @return Boolean
     * @JIRA LEM-985,LEM-1011
     */
    private Boolean addWorkRecordForStatusChange(
        WorkOrder existingWorkOrder,
        WorkOrder currentWorkOrder
    ) {
        return WORK_ORDER_PRIORITY_STATUSES.contains(currentWorkOrder.Status) &&
            currentWorkOrder.Status == existingWorkOrder.Status &&
            ((currentWorkOrder.Proposed_Date_of_Activation__c !=
            existingWorkOrder.Proposed_Date_of_Activation__c &&
            currentWorkOrder.Proposed_Date_of_Activation__c >= System.today()) ||
            (currentWorkOrder.Proposed_Date_of_Menu__c !=
            existingWorkOrder.Proposed_Date_of_Menu__c &&
            currentWorkOrder.Proposed_Date_of_Menu__c >= System.today()) ||
            (currentWorkOrder.Proposed_Date_of_Tablet__c !=
            existingWorkOrder.Proposed_Date_of_Tablet__c &&
            currentWorkOrder.Proposed_Date_of_Tablet__c >= System.today()));
    }

    /**
     * @description It copies "Account Owner Email Calculated" (formula field)
     * to "Account Owner Email Id" (email field).
     * @JIRA# LEM-746
     * @param workOrder
     */
    private void copyAccountOwnerEmail(WorkOrder workOrder) {
        workOrder.Account_Owner_Email_Id__c = workOrder.Account_Owner_Email_Calculated__c;
    }

    /**
     * @description It copy Work Order Date field values To Work Order original date field values.
     * Fields covered: Proposed_Date_of_Activation__c, Proposed_Date_of_Menu__c,
     * Proposed_Date_of_Tablet__c
     * @JIRA# LEM-1048
     * @param workOrder
     */
    private void copyWorkOrderDateFieldsToOriginalDateFields(WorkOrder workOrder) {
        workOrder.Proposed_Date_of_Activation_Original__c = workOrder.Proposed_Date_of_Activation__c;
        if (workOrder.Proposed_Date_of_Tablet__c != null) {
            workOrder.Proposed_Date_of_Tablet_Original__c = workOrder.Proposed_Date_of_Tablet__c;
        }
        if (workOrder.Proposed_Date_of_Menu__c != null) {
            workOrder.Proposed_Date_of_Menu_Original__c = workOrder.Proposed_Date_of_Menu__c;
        }
    }

    /**
     * @description It fetches unique Decision Makers from OpportunityContactRole and AccountContactRelation.
     * @JIRA# LEM-1652
     * @param workOrders
     * @return Map<Id, List<Id>>
     */
    private Map<Id, List<Id>> fetchDecisionMaker(List<WorkOrder> workOrders) {
        Map<Id, List<Id>> decisionMakers = DecisionMakerCalculationService.getDecisionMakers(
            workOrders
        );
        return decisionMakers;
    }

    /**
     * @description It checks whether the passed Work Order is a child Work Order.
     * @JIRA# LEM-4195
     * @param workOrder
     * @return Boolean
     */
    private Boolean isChildWorkOrder(WorkOrder workOrder) {
        return workOrder.ParentWorkOrderId != null &&
            workOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE;
    }

    /**
     * @description It checks whether the passed Work Order is created manually with type as 'Drive'
     * and sub-type as 'Auto-Activations'.
     * @JIRA# LEM-11612
     * @param workOrder
     * @return Boolean
     */
    private Boolean isDriveAutoActivationsCreatedManually(WorkOrder workOrder) {
        return workOrder.Type__c == TYPE_DRIVE &&
            workOrder.Sub_Type__c == SUB_TYPE_AUTO_ACTIVATIONS &&
            workOrder.Work_Order_Source__c == WORK_ORDER_SOURCE_SALES;
    }

    /**
     * @description It is used to get 'Active' Mx Tag Associations
     * and populate the "Mx Tags" field on 'SMB' parent Work Order.
     * @JIRA# LEM-14041
     * @param businessAccountIds
     * @param smbParentWorkOrders
     */
    private void populateActiveMxTags(
        Set<Id> businessAccountIds,
        List<WorkOrder> smbParentWorkOrders
    ) {
        if (businessAccountIds.isEmpty()) {
            return;
        }
        Map<Id, Set<String>> accountIdToMxTagAssociations = MxTagAssociations.newInstance(
                new List<Mx_Tag_Association__c>()
            )
            .getActiveMxTagAssociationsByBusinessAccountIds(businessAccountIds);
        for (WorkOrder eachWorkOrder : smbParentWorkOrders) {
            if (accountIdToMxTagAssociations.containsKey(eachWorkOrder.AccountId)) {
                eachWorkOrder.Mx_Tags__c = String.join(
                    (Iterable<String>) accountIdToMxTagAssociations.get(eachWorkOrder.AccountId),
                    SEPARATOR_COMMA
                );
            }
        }
    }

    /**
     * @description It populates Decision Maker field on the passed Work Orders.
     * @JIRA# LEM-1652 & LEM-4195
     * @param workOrders
     */
    private void populateDecisionMaker(List<WorkOrder> workOrders) {
        if (workOrders.isEmpty()) {
            return;
        }
        Map<Id, List<Id>> decisionMakers = fetchDecisionMaker(workOrders);
        if (decisionMakers == null || decisionMakers.isEmpty()) {
            return;
        }
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.AccountId != null &&
                decisionMakers.containsKey(eachWorkOrder.AccountId)
            ) {
                eachWorkOrder.Decision_Maker__c = decisionMakers.get(eachWorkOrder.AccountId)[0];
            }
        }
    }

    /**
     * @description It throws error if there is Marketplace Work Order for Store Account when trying
     * to create new Work order other than Drive and POS.
     * @JIRA# LEM-7912
     * @param workOrders
     * @param accountIds
     */
    private void validateAccountHavingInProgressMarketPlaceWO(
        List<WorkOrder> workOrders,
        Set<Id> accountIds
    ) {
        Map<Id, WorkOrder> accountIdsWithMarketplaceWO = new Map<Id, WorkOrder>();
        if (workOrders.isEmpty()) {
            return;
        }
        List<WorkOrder> childWorkOrders = WorkOrdersSelector.newInstance()
            .selectOpenMarketPlaceWorkOrdersByAccountIds(accountIds);
        if (childWorkOrders != null && !childWorkOrders.isEmpty()) {
            for (WorkOrder eachWorkOrder : childWorkOrders) {
                if (accountIdsWithMarketplaceWO.containsKey(eachWorkOrder.AccountId)) {
                    continue;
                }
                accountIdsWithMarketplaceWO.put(eachWorkOrder.AccountId, eachWorkOrder);
            }
        }
        if (!accountIdsWithMarketplaceWO.isEmpty()) {
            for (WorkOrder eachWorkOrder : workOrders) {
                if (accountIdsWithMarketplaceWO.containsKey(eachWorkOrder.AccountId)) {
                    eachWorkOrder.addError(
                        String.format(
                            Label.InProgress_Child_Marketplace_Work_Order_Validation_Message,
                            new List<Object>{
                                accountIdsWithMarketplaceWO.get(eachWorkOrder.AccountId)
                                    .ParentWorkOrder.Work_Order_Name__c
                            }
                        )
                    );
                }
            }
        }
    }

    /**
     * @description It prevents creation of new Drive Auto-Activations Work Order if there is
     * already an existing Non-Dead Drive Auto-activation Work Order on the Account
     * @JIRA LEM-11612
     * @param workOrders
     * @param accountIds
     */
    private void preventDuplicateNonDeadDriveAutoActivationsWorkOrder(
        List<WorkOrder> workOrders,
        Set<Id> accountIds
    ) {
        if (workOrders.isEmpty()) {
            return;
        }
        Set<Id> accountIdsWithExistingDriveAutoActivationsWorkOrder = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(accountIds)
        ) {
            accountIdsWithExistingDriveAutoActivationsWorkOrder.add(eachWorkOrder.AccountId);
        }
        if (accountIdsWithExistingDriveAutoActivationsWorkOrder.isEmpty()) {
            return;
        }
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                accountIdsWithExistingDriveAutoActivationsWorkOrder.contains(
                    eachWorkOrder.AccountId
                )
            ) {
                eachWorkOrder.addError(
                    error(
                        System.Label.Duplicate_Drive_Auto_Activations_WorkOrder_Validation_Message,
                        eachWorkOrder
                    )
                );
            }
        }
    }

    /**
     * @description It checks whether the provisioning status is changed for the WorkOrder.
     * @JIRA# LEM-1684
     * @param newWorkOrder
     * @param oldWorkOrder
     * @return Boolean
     */
    private Boolean hasProvisioningStatusChanged(WorkOrder newWorkOrder, WorkOrder oldWorkOrder) {
        return newWorkOrder.Provisioning_Status__c != oldWorkOrder.Provisioning_Status__c;
    }

    /**
     * @description It checks whether WorkOrder Account has changed.
     * @JIRA# LEM-746
     * @param newWorkOrder
     * @param oldWorkOrder
     * @return Boolean
     */
    private Boolean hasWorkOrderAccountChanged(WorkOrder newWorkOrder, WorkOrder oldWorkOrder) {
        return newWorkOrder.AccountId != oldWorkOrder.AccountId;
    }

    /**
     * @description It checks whether WorkOrder Status has changed.
     * @JIRA# LEM-1010
     * @param newWorkOrder - new WorkOrder Record
     * @param oldWorkOrder - old WorkOrder Record
     * @return Boolean
     */
    private Boolean hasWorkOrderStatusChanged(WorkOrder newWorkOrder, WorkOrder oldWorkOrder) {
        return newWorkOrder.Status != oldWorkOrder.Status;
    }

    /**
     * @description It checks whether WorkOrder PDOT Date has changed.
     * @JIRA# LEM-1048
     * @param newWorkOrder
     * @param oldWorkOrder
     * @return Boolean
     */
    private Boolean hasWorkOrderPDOTChanged(WorkOrder newWorkOrder, WorkOrder oldWorkOrder) {
        return newWorkOrder.Proposed_Date_of_Tablet__c != null &&
            oldWorkOrder.Proposed_Date_of_Tablet__c == null;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @JIRA# LEM-5159
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It updates WorkOrder PDOT Date to PDOT Date Original when PDOT Date is populated.
     * @JIRA# LEM-1048
     * @param workOrder - WorkOrder Record
     */
    private void updateWorkOrderPDOTOriginalFromPDOT(WorkOrder workOrder) {
        workOrder.Proposed_Date_of_Tablet_Original__c = workOrder.Proposed_Date_of_Tablet__c;
    }

    /**
     * @description Creates payload with parent Work Order Ids according to the chunk size.
     * @JIRA# LEM-2083
     * @param parentWorkOrderIds
     * @return List<String>
     */
    private List<String> generatePayload(Set<Id> parentWorkOrderIds) {
        Integer parentWorkOrderIdPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        List<String> payloads = new List<String>();
        Integer iterator = 0;
        Integer endIndex = parentWorkOrderIdPayloadChunkSize;
        List<Id> workOrderIdsToProcess = new List<Id>(parentWorkOrderIds);
        while (iterator < workOrderIdsToProcess.size()) {
            payloads.add(
                JSON.serialize(
                    filterParentWorkOrderIdsByChunkSize(endIndex, iterator, workOrderIdsToProcess)
                )
            );
            iterator += parentWorkOrderIdPayloadChunkSize;
            endIndex += parentWorkOrderIdPayloadChunkSize;
        }
        return payloads;
    }

    /**
     * @description method to populate Franchise Rep As Owner On Mxp And Drive Franchise Work Orders
     * @author rishab.goyal | 03-19-2024
     **/
    public void populateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders() {
        List<WorkOrder> mxpAndDrivWorkOrders = new List<WorkOrder>();
        Set<Id> accountIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : (List<WorkOrder>) getRecords()) {
            if (isMxpOrDriveWorkOrder(eachWorkOrder)) {
                mxpAndDrivWorkOrders.add(eachWorkOrder);
                accountIds.add(eachWorkOrder.AccountId);
            }
        }

        Map<Id, Account> accounts = new Map<Id, Account>(
            AccountsSelector.newInstance().selectById(accountIds)
        );
        Map<Id, Id> franchiseAccountToParentAccountIdMap = getFranchiseAccountToParentAccountIdMap(
            accounts
        );

        Map<Id, Account> parentCorporateAccounts = new Map<Id, Account>(
            AccountsSelector.newInstance()
                .selectAccountWithAccTeamMembers(
                    new Set<Id>(franchiseAccountToParentAccountIdMap.values())
                )
        );
        for (WorkOrder workOrder : mxpAndDrivWorkOrders) {
            // Your logic here
            if (!franchiseAccountToParentAccountIdMap.containsKey(workOrder.AccountId)) {
                continue;
            }

            workOrder.OwnerId = getFranchiseWorkOrderOwnerId(
                workOrder,
                parentCorporateAccounts,
                franchiseAccountToParentAccountIdMap
            );
        }
    }

    /**
     * @description It is used to trigger Readiness Check on parent Work Orders.
     * @JIRA LEM-19805
     * @param existingRecords
     */
    public void runReadinessCheckOnParentWorkOrders(Map<Id, SObject> existingRecords) {
        Set<Id> parentWorkOrderIdsToRunReadinessCheck = new Set<Id>();
        WorkOrder existingWorkOrder;
        for (WorkOrder eachWorkOrder : (List<WorkOrder>) getRecords()) {
            existingWorkOrder = (WorkOrder) existingRecords.get(eachWorkOrder.Id);
            if (
                isParentWorkOrderExecuteReadinessCheckFlagChanged(existingWorkOrder, eachWorkOrder)
            ) {
                parentWorkOrderIdsToRunReadinessCheck.add(eachWorkOrder.Id);
            }
        }
        if (!isEmptyOrNull(parentWorkOrderIdsToRunReadinessCheck)) {
            Integer readinessCheckParentWorkOrderIdsPayloadChunkSize = Integer.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(READINESS_CHECK_PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                    .Configuration_Value__c
            );
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        parentWorkOrderIdsToRunReadinessCheck,
                        readinessCheckParentWorkOrderIdsPayloadChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description It is used to evaluate if SMB Ads and Promos WorkOrder is eligible for
     * WorkPlan and WorkStep creation.
     * @JIRA# LEM-13559
     * @param workOrder
     * @return Boolean
     */
    private Boolean isWorkOrderEligibleForAdsAndPromosWorkPlanCreation(WorkOrder workOrder) {
        return (workOrder.Type__c == TYPE_ADS_AND_PROMOS &&
        workOrder.Contract__c != null &&
        workOrder.ParentWorkOrderId == null &&
        workOrder.Segment__c == SEGMENT_SMB);
    }

    private Boolean isMxpOrDriveWorkOrder(WorkOrder workOrder) {
        return workOrder.Type__c == TYPE_MARKETPLACE || workOrder.Type__c == TYPE_DRIVE;
    }

    private Map<Id, Id> getFranchiseAccountToParentAccountIdMap(Map<Id, Account> accounts) {
        Map<Id, Id> franchiseAccountToParentAccountIdMap = new Map<Id, Id>();
        for (Account acc : accounts.values()) {
            if (
                (acc.RecordTypeId == ACCOUNT_STORE_RECORD_TYPE_ID &&
                acc.Franchise_Parent__c != null) ||
                (acc.RecordTypeId == ACCOUNT_BUSINESS_RECORD_TYPE_ID &&
                acc.Type == ACCOUNT_TYPE_FRANCHISEE)
            ) {
                if (acc.parentId == null) {
                    continue;
                }
                franchiseAccountToParentAccountIdMap.put(acc.Id, acc.ParentId);
            }
        }
        return franchiseAccountToParentAccountIdMap;
    }

    /**
     * @description main logic for determining the owner of Franchise Work Order
     * @author rishab.goyal | 03-19-2024
     * @param workOrder
     * @param parentCorporateAccounts
     * @param franchiseAccountToParentAccountIdMap
     * @return Id
     **/
    private Id getFranchiseWorkOrderOwnerId(
        WorkOrder workOrder,
        Map<Id, Account> parentCorporateAccounts,
        Map<Id, Id> franchiseAccountToParentAccountIdMap
    ) {
        Account parentAccount = parentCorporateAccounts.get(
            franchiseAccountToParentAccountIdMap.get(workOrder.AccountId)
        );

        if (
            parentAccount != null &&
            parentAccount.AccountTeamMembers != null &&
            !parentAccount.AccountTeamMembers.isEmpty()
        ) {
            Boolean isFranchiseOwnerAssigned = false;
            for (AccountTeamMember teamMember : parentAccount.AccountTeamMembers) {
                if (teamMember.TeamMemberRole == ACCOUNT_FRANCHISE_REP_ROLE) {
                    return teamMember.UserId;
                }
            }
            if (!isFranchiseOwnerAssigned) {
                return parentAccount.OwnerId;
            }
        }
        return workOrder.OwnerId;
    }

    /**
     * @description It is used to filter parent work order Ids according to the chunk size.
     * @JIRA# LEM-2083
     * @param endIndex
     * @param startIndex
     * @param workOrderIdsToProcess
     * @return List<Id>
     */
    private List<Id> filterParentWorkOrderIdsByChunkSize(
        Integer endIndex,
        Integer startIndex,
        List<Id> workOrderIdsToProcess
    ) {
        List<Id> filteredIds = new List<Id>();
        for (Integer index = startIndex; index < endIndex; index++) {
            if (index >= workOrderIdsToProcess.size()) {
                continue;
            }
            filteredIds.add(workOrderIdsToProcess[index]);
        }
        return filteredIds;
    }

    /**
     * @description It is used to check whether 'Execute_Readiness_Check__c' flag is updated
     * on parent Work Order.
     * @param existingWorkOrder
     * @param currentWorkOrder
     * @return Boolean
     * @JIRA LEM-190805
     */
    private Boolean isParentWorkOrderExecuteReadinessCheckFlagChanged(
        WorkOrder existingWorkOrder,
        WorkOrder currentWorkOrder
    ) {
        return currentWorkOrder.ParentWorkOrderId == null &&
            (existingWorkOrder.Execute_Readiness_Check__c == false &&
            currentWorkOrder.Execute_Readiness_Check__c == true);
    }

    /**
     * @description It is used to populate Ads and Promos Work Plan creation indicator.
     * @JIRA# LEM-13559
     * @param contractIdToWorkOrder
     */
    private void setAdsAndPromosWorkPlanCreationOnEligibleWorkOrders(
        Map<Id, WorkOrder> contractIdToWorkOrder
    ) {
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectActiveSubscriptionsList(new Set<Id>(contractIdToWorkOrder.keySet()), false)
        ) {
            switch on ELIGIBLE_ADS_AND_PROMOS_PRODUCTS.get(eachSubscription.SBQQ__Product__r.Name) {
                when ADS {
                    contractIdToWorkOrder.get(eachSubscription.SBQQ__Contract__c)
                        .Is_Eligible_for_Ads_Work_Plan__c = true;
                }
                when PROMOS {
                    contractIdToWorkOrder.get(eachSubscription.SBQQ__Contract__c)
                        .Is_Eligible_for_Promos_Work_Plan__c = true;
                }
            }
        }
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return WorkOrders - List of WorkOrders
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (WorkOrders.constructorMock != null) {
                return (fflib_SObjects) WorkOrders.constructorMock.construct(objectList);
            }
            return new WorkOrders((List<SObject>) objectList);
        }
    }
}