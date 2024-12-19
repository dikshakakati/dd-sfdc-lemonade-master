/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Service implementation class for WorkOrder related logic.
 * Cyclomatic Complexity warning suppressed by QTC team in
 * PR# https://github.com/doordash/dd-sfdc-lemonade/pull/5096/
 */
@SuppressWarnings(
    'PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.ExcessivePublicCount, PMD.NcssTypeCount'
)
public inherited sharing class WorkOrdersServiceImpl implements IWorkOrdersService {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_UNIQUE_STORE_COUNT_ALIAS = 'uniqueStoreCount';
    private static final String AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS = 'provisioningStatus';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String CHURNED_MERCHANT_CONTRACT_SPLIT_CATEGORY = 'Churned Merchant';
    private static final String CHILD_WORK_ORDER_TYPES_ELIGIBLE_FOR_BUSINESS_ID_UPDATE = 'BusinessIdUpdateEligibleWorkOrderTypes';
    private static final String CHILD_WORK_ORDER_TYPES_ELIGIBLE_FOR_STORE_ID_UPDATE = 'StoreIdUpdateEligibleWorkOrderTypes';
    private static final String CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Order_Ids_Payload_Chunk_Size';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DAY_SATURDAY = 'Sat';
    private static final String DAY_SUNDAY = 'Sun';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS = 'READINESS_CHECK_ON_CHILD_WORK_ORDERS';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT = 'PHOTOSHOOT_STORE_ASSOCIATION';
    private static final String EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE = 'WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS = 'CREATE_WORK_PLANS_ON_WORK_ORDERS';
    private static final String EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION = 'INITIATE_POS_CHILD_WORK_ORDERS_CREATION';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER = 'UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER';
    private static final String UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final Integer PDOI_OFFSET_FOR_CREATION_SOURCE_MANUAL = 10;
    private static final Integer PDOI_OFFSET_FOR_CREATION_SOURCE_NINTEX = 3;
    private static final Integer PROVISIONING_EVENT_SCOPE_SIZE = 50;
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String PROVISIONING_STATUS_READINESS_CHECK = 'Readiness Check';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_FAILED = 'Readiness Check Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String READINESS_CHECK_TRIGGER_SOURCE_AUTOMATIC = 'Automatic';
    private static final String READINESS_CHECK_TRIGGER_SOURCE_CHANGE_EVENT = 'Change_Event';
    private static final String DELIMITER = ',';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STORE_ASSOCIATION_PAYLOAD_SIZE = 'Store_Association_Payload_Size';
    private static final String TABLET_WORK_ORDER_TYPE = 'Tablet';
    private static final String REASON_OTHER = 'Other';
    private Map<Id, WorkOrder> workOrders;
    private static final Set<String> WORK_ORDER_PDOX_RELATED_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Work_Plans_Creation_Payload_Chunk_Size';
    private static final String LOG_SERVICE_WORK_ORDER = 'Work Order Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private Integer childWorkOrderIdsChunkSize;
    private final Map<Id, WorkOrder> driveWorkOrders;
    private final Map<Id, Set<String>> parentWorkOrderIdToProvisioningStatus;
    private final Set<Id> unprocessedParentWorkOrderIds;
    private Integer workOrderIdsChunkSizeToCreateWorkPlans;
    private Integer storeAssociationPayloadSize;
    private static final String EXISTING_READINESS_ROWS_COUNT_CHECK = 'Existing_Readiness_Rows_Count_Check';
    private Integer existingReadinessMessageProcessingLimit;
    private enum EventTopics {
        EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS,
        EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS,
        EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE,
        EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE,
        EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
        EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS,
        EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER,
        EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS => EventTopics.EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS,
        EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS => EventTopics.EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS,
        EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE => EventTopics.EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE,
        EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE => EventTopics.EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE,
        EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION => EventTopics.EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
        EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS => EventTopics.EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS,
        EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER => EventTopics.EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER,
        EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION => EventTopics.EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION
    };
    private static final String GENERIC_LOG_SERVICE_WORKORDER_PROVISIONING_EVENT = 'WORKORDER_PROVISIONING_EVENT';
    private static final String CREATION_SOURCE_MANUAL = 'Manual';
    private static final String CREATION_SOURCE_NINTEX = 'Nintex';
    private static final String CREATION_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private enum CreationSources {
        CREATION_SOURCE_MANUAL,
        CREATION_SOURCE_NINTEX,
        CREATION_SOURCE_ONBOARDING_INPUTS
    }
    private static final Map<String, CreationSources> CREATION_SOURCE_MAPPINGS = new Map<String, CreationSources>{
        CREATION_SOURCE_MANUAL => CreationSources.CREATION_SOURCE_MANUAL,
        CREATION_SOURCE_NINTEX => CreationSources.CREATION_SOURCE_NINTEX,
        CREATION_SOURCE_ONBOARDING_INPUTS => CreationSources.CREATION_SOURCE_ONBOARDING_INPUTS
    };

    /**
     * @description Default Constructor to initialize class variables.
     */
    public WorkOrdersServiceImpl() {
        driveWorkOrders = new Map<Id, WorkOrder>();
        parentWorkOrderIdToProvisioningStatus = new Map<Id, Set<String>>();
        unprocessedParentWorkOrderIds = new Set<Id>();
        workOrders = new Map<Id, WorkOrder>();
        collectStaticConfigurations();
    }

    /**
     * @description It is used to set "Proposed Date of Implementation" field value on 'Storefront'
     * work orders of 'SMB' segment.
     * @JIRA# LEM-25334
     * @param workOrders
     */
    public void setProposedDateofImplementationOnSMBStorefrontWorkOrders(
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.Type__c != WORK_ORDER_TYPE_STOREFRONT) {
                continue;
            }
            switch on CREATION_SOURCE_MAPPINGS.get(eachWorkOrder.Creation_Source__c) {
                when CREATION_SOURCE_MANUAL {
                    eachWorkOrder.Proposed_Date_of_Implementation__c = WorkOrdersGeneratorService.calculateDateExcludingWeekends(
                        System.today(),
                        PDOI_OFFSET_FOR_CREATION_SOURCE_MANUAL
                    );
                }
                when CREATION_SOURCE_NINTEX, CREATION_SOURCE_ONBOARDING_INPUTS {
                    if (eachWorkOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES) {
                        eachWorkOrder.Proposed_Date_of_Implementation__c = WorkOrdersGeneratorService.calculateDateExcludingWeekends(
                            eachWorkOrder.Proposed_Date_of_Activation__c,
                            PDOI_OFFSET_FOR_CREATION_SOURCE_NINTEX
                        );
                    }
                }
            }
        }
    }

    /**
     * @description It associates Contracts to parent Work Orders based on the
     * passed Account and Contract Id mappings.
     * @JIRA# LEM-4005
     * @param parentAccountIdtoContractId
     */
    public void associateContractsOnParentWorkOrders(Map<Id, Id> parentAccountIdtoContractId) {
        fflib_ISObjectUnitOfWork uowToUpdateParentWorkOrder = Application.UNITOFWORK.newInstance();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByAccountIds(parentAccountIdtoContractId.keySet())
        ) {
            if (eachWorkOrder.Contract__c != null) {
                continue;
            }
            uowToUpdateParentWorkOrder.registerDirty(
                new WorkOrder(
                    Id = eachWorkOrder.Id,
                    Contract__c = parentAccountIdtoContractId.get(eachWorkOrder.AccountId)
                )
            );
        }
        commitWork(uowToUpdateParentWorkOrder);
    }

    /**
     * @description It is used to trigger stores association event for Photoshoot and Marketing Kit Work Order.
     * @param workOrders
     */
    public void initiateStoreAssociation(List<WorkOrder> workOrders) {
        List<WorkOrder> photoshootWorkOrders = new List<WorkOrder>();
        Map<Id, WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder = new Map<Id, WorkOrder>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.Type__c == WORK_ORDER_TYPE_PHOTOSHOOT &&
                eachWorkOrder.ParentWorkOrderId == null
            ) {
                photoshootWorkOrders.add(eachWorkOrder);
            }
            if (
                eachWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETING_KIT &&
                String.isBlank(eachWorkOrder.ParentWorkOrderId) &&
                !String.isBlank(eachWorkOrder.Originating_Work_Order__c)
            ) {
                OriginatingWorkOrderIdToMarketingKitWorkOrder.put(
                    eachWorkOrder.Originating_Work_Order__c,
                    eachWorkOrder
                );
            }
        }
        if (!photoshootWorkOrders.isEmpty()) {
            OnboardingActivationsEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        new Map<Id, WorkOrder>(photoshootWorkOrders).keySet(),
                        storeAssociationPayloadSize
                    )
                }
            );
        }
        if (!originatingWorkOrderIdToMarketingKitWorkOrder.isEmpty()) {
            ChildWorkOrdersCreationService.initiateStoreAssociationOnMarketingKitWorkOrder(
                originatingWorkOrderIdToMarketingKitWorkOrder
            );
        }
    }

    /**
     * @description It filters Opportunities without any associated parent Work Order.
     * @JIRA# LEM-2132
     * @param opportunities
     * @return List<Opportunity>
     */
    public List<Opportunity> collectOpportunitiesWithoutWorkOrder(List<Opportunity> opportunities) {
        Map<Id, Opportunity> opportunitiesToProcess = new Map<Id, Opportunity>(opportunities);
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentWorkOrdersByOpportunityIds(opportunitiesToProcess.keySet())
        ) {
            if (opportunitiesToProcess.containsKey(eachWorkOrder.Opportunity__c)) {
                opportunitiesToProcess.remove(eachWorkOrder.Opportunity__c);
            }
        }
        return opportunitiesToProcess.values();
    }

    /**
     * @description It generates Provisioning Platform Events (Provisioning_Event__e)
     * for each parent Work Order with child Store Account Work Orders.
     * @JIRA# LEM-2304
     * @param workOrderIds
     */
    public void generateProvisioningEventForWorkOrders(Set<Id> workOrderIds) {
        List<Provisioning_Event__e> eventsToPublish = new List<Provisioning_Event__e>();
        if (workOrderIds.isEmpty()) {
            return;
        }
        //LEM-4516 publish the provisioning events even if this is an amendment.
        //The amendment might add a new Backend_System__c
        eventsToPublish = generateProvisioningEvents(
            getChildWorkOrderAccountIdsByParentWorkOrderIds(workOrderIds),
            getCreationMethodsByParentWorkOrderIds(workOrderIds),
            getWorkOrderTypeByParentWorkOrderIds(workOrderIds)
        );
        if (eventsToPublish.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerPublishAfterSuccessTransaction(eventsToPublish);
        commitWork(uow);
    }

    /**
     * @description It generates Provisioning Platform Events (Provisioning_Event__e)
     * for each parent Work Order with child Store Account Work Orders.
     * @JIRA# LEM-2304
     * @param workOrderIds
     */
    public void generateProvisioningEventForDriveWorkOrders(Set<Id> workOrderIds) {
        if (workOrderIds.isEmpty()) {
            return;
        }

        Set<Id> accountIdSet = new Set<Id>();
        List<Provisioning_Event__e> eventsToPublish = new List<Provisioning_Event__e>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectDriveAmendedOpportunityWorkOrdersByWorkOrderIds(workOrderIds)
        ) {
            //Collect all the store AccountId.
            accountIdSet.add(eachWorkOrder.AccountId);
        }

        if (!accountIdSet.isEmpty()) {
            XrefIntegrationService.updateExistingXrefsForAmendaments(accountIdSet);
        }

        //LEM-4516 publish the provisioning events even if this is an amendment.
        //The amendment might add a new Backend_System__c
        eventsToPublish = generateProvisioningEventsForDrive(workOrderIds);

        if (eventsToPublish.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerPublishAfterSuccessTransaction(eventsToPublish);
        commitWork(uow);
    }

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for COO work orders
     * @JIRA# LEM-3373
     * @param workOrderIds
     */
    public void generateProvisioningEventForCOOWorkOrders(Set<Id> workOrderIds) {
        Map<Id, List<Id>> parentWOIdToChildAccountIdListMap = getChildWorkOrderAccountIdsByParentWorkOrderIds(
            workOrderIds
        );
        List<Provisioning_Event__e> eventsToPublish = generateProvisioningEventsForCOO(
            parentWOIdToChildAccountIdListMap
        );

        if (eventsToPublish.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerPublishAfterSuccessTransaction(eventsToPublish);
        commitWork(uow);
    }
    /**
     * @description It is used for getting updated Work Order Status
     * on basis of PDOA/PDOM/PDOT date criteria.
     * @JIRA# LEM-985, LEM-1011
     * @param workOrderRecord
     * @return String
     */
    public String getWorkStatusUpdatedValue(WorkOrder workOrderRecord) {
        String workOrderStatusToUpdate = '';
        Boolean isEligibleForAtRiskStatusUpdate = false;
        Boolean isPDOAInPast = false;
        isEligibleForAtRiskStatusUpdate =
            (workOrderRecord.Proposed_Date_of_Menu__c != null &&
            workOrderRecord.Proposed_Date_of_Menu__c < System.today()) ||
            (workOrderRecord.Proposed_Date_of_Tablet__c != null &&
            workOrderRecord.Proposed_Date_of_Tablet__c < System.today());
        isPDOAInPast = workOrderRecord.Proposed_Date_of_Activation__c < System.today();
        if (!isPDOAInPast && isEligibleForAtRiskStatusUpdate) {
            workOrderStatusToUpdate = STATUS_AT_RISK;
        } else if (isPDOAInPast) {
            workOrderStatusToUpdate = STATUS_PAST_DUE;
        }
        return workOrderStatusToUpdate;
    }

    /**
     * @description It is being called through NotifierEvent class for getting parent Work Order Ids from the payload received via Platform Event.
     * @JIRA# LEM-955
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> childWorkOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIdsToTriggerReadinessCheck = new Set<Id>();
        Set<Id> workOrdersReadyForProvisioning = new Set<Id>();
        Set<Id> workOrderIdsToCreateWorkPlans = new Set<Id>();
        Set<Id> workOrderIdsToRollUpProvisioningStatus = new Set<Id>();
        Map<Id, Set<Id>> storeAccountIdToParentWOIds = new Map<Id, Set<Id>>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> recordIdsFromPayload;
        List<String> payloadForFranchiseUpdate = new List<String>();
        for (Notifier__e eachEvent : events) {
            if (
                EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) ==
                EventTopics.EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION
            ) {
                Set<AsyncPayloadWrapper> payloads = (Set<AsyncPayloadWrapper>) JSON.deserialize(
                    eachEvent.Payload__c,
                    Set<AsyncPayloadWrapper>.class
                );
                for (AsyncPayloadWrapper payload : payloads) {
                    if (!storeAccountIdToParentWOIds.containsKey(payload.key)) {
                        storeAccountIdToParentWOIds.put(payload.key, new Set<Id>());
                    }
                    storeAccountIdToParentWOIds.get(payload.key).add(payload.value);
                }
                continue;
            }
            if (eachEvent.Topic__c == UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER) {
                payloadForFranchiseUpdate.add(eachEvent.Payload__c);
                continue;
            }
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsFromPayload == null) {
                continue;
            }
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION {
                    parentWorkOrderIds.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER {
                    accountIds.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE {
                    workOrderIdsToRollUpProvisioningStatus.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE {
                    workOrdersReadyForProvisioning.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS {
                    childWorkOrderIds.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS {
                    parentWorkOrderIdsToTriggerReadinessCheck.addAll(recordIdsFromPayload);
                }
                when EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS {
                    workOrderIdsToCreateWorkPlans.addAll(recordIdsFromPayload);
                }
            }
        }
        if (payloadForFranchiseUpdate.size() > 0) {
            updateFranchiseBusinessAndStoreWorkOrder(payloadForFranchiseUpdate);
        }
        // JIRA: LEM-955
        updateActualNumberOfStoresOnParentWorkOrder(parentWorkOrderIds);
        // JIRA: LEM-746
        updateAccountOwnerEmailOnWorkOrder(accountIds);
        // JIRA: LEM-2083
        collectChildWorkOrdersDetailsToRollUpProvisioningStatusOnParentWorkOrders(
            workOrderIdsToRollUpProvisioningStatus
        );
        // JIRA: LEM-1684
        updateWorkOrderProvisioningStatusToReadyForProvisioning(workOrdersReadyForProvisioning);
        // JIRA: LEM-4054
        runReadinessCheckOnChildWorkOrders(childWorkOrderIds);
        // JIRA: LEM-11106
        runReadinessCheckOnParentWorkOrders(
            parentWorkOrderIdsToTriggerReadinessCheck,
            READINESS_CHECK_TRIGGER_SOURCE_AUTOMATIC
        );
        // JIRA: LEM-5836
        initiateWorkPlansCreationById(workOrderIdsToCreateWorkPlans);
        // support child workOrder creation for non-contract bound workorder types e.g. POS
        initiateChildWorkOrderAutoCreation(storeAccountIdToParentWOIds);
    }

    /**
     * @description It is used to initiate Work Plan creation for Tablet Work Order.
     * @param workOrders
     */
    public void initiateTabletWorkPlanCreation(List<WorkOrder> workOrders) {
        Set<Id> newTabletWorkOrderIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.Type__c == TABLET_WORK_ORDER_TYPE &&
                eachWorkOrder.HasWorkPlansGenerated__c == false
            ) {
                newTabletWorkOrderIds.add(eachWorkOrder.Id);
            }
        }
        initiateWorkPlansCreationById(newTabletWorkOrderIds);
    }

    /**
     * @description
     * @author rishab.goyal | 03-20-2024
     * @param payload
     **/
    private void updateFranchiseBusinessAndStoreWorkOrder(List<String> payload) {
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            List<WorkOrder> workOrdersToBeUpdated = new List<WorkOrder>();
            for (String workOrderIdWithOwnerId : payload) {
                String workOrderId = workOrderIdWithOwnerId.split(':')[0];
                String ownerId = workOrderIdWithOwnerId.split(':')[1];
                workOrdersToBeUpdated.add(new WorkOrder(Id = workOrderId, OwnerId = ownerId));
            }
            uow.registerDirty(workOrdersToBeUpdated);
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_ORDER,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It initiates Work Plans creation on the passed Work Order Ids
     * by changeType.
     * @JIRA# LEM-1113, LEM-658, LEM-1684, LEM-3474
     * @param workOrderIds
     * @param changeType
     */
    public void initiateWorkPlansCreation(Set<Id> workOrderIds, String changeType) {
        if (workOrderIds.isEmpty()) {
            return;
        }
        Map<Id, WorkOrder> eligibleWorkOrders = new Map<Id, WorkOrder>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentAndChildrenByIds(workOrderIds)
        ) {
            if (
                changeType == CHANGE_TYPE_CREATE &&
                isEligibleToCreateWorkPlansOnCreateChangeType(eachWorkOrder)
            ) {
                eligibleWorkOrders.put(eachWorkOrder.Id, eachWorkOrder);
            } else if (
                changeType == CHANGE_TYPE_UPDATE &&
                isEligibleToCreateWorkPlansOnUpdateChangeType(eachWorkOrder)
            ) {
                eligibleWorkOrders.put(eachWorkOrder.Id, eachWorkOrder);
            }
        }
        if (eligibleWorkOrders.isEmpty()) {
            return;
        }
        /* Switched to async process for avoiding 'UNABLE_TO_LOCK_ROW' and
         'Apex CPU time limit exceeded' exceptions on Work Plans creation. */
        if (eligibleWorkOrders.size() > workOrderIdsChunkSizeToCreateWorkPlans) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        eligibleWorkOrders.keySet(),
                        workOrderIdsChunkSizeToCreateWorkPlans
                    )
                }
            );
            return;
        }
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(
            eligibleWorkOrders.values()
        );
        PosIntegrationRequestsService.makePosWorkPlansCurrent(eligibleWorkOrders.values());
    }

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It triggers actual number of stores and account owner email updates
     * on basis of the passed Work Orders.
     * @JIRA# LEM-3643
     * @param workOrders
     */
    public void processMergedAccountsRelatedRecords(List<WorkOrder> workOrders) {
        if (isEmptyOrNull(workOrders)) {
            return;
        }
        Set<Id> parentWorkOrderIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.ParentWorkOrderId != null &&
                eachWorkOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE
            ) {
                parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
            }
            accountIds.add(eachWorkOrder.AccountId);
        }
        updateActualNumberOfStoresOnParentWorkOrder(parentWorkOrderIds);
        updateAccountOwnerEmailOnWorkOrder(accountIds);
    }

    /**
     * @description It cleans up the existing business Account readiness check failures and trigger
     * readiness check on the passed child Work Order Ids.
     * @JIRA LEM-2455
     * @param workOrderIds
     */
    public void runReadinessCheckOnChildWorkOrders(Set<Id> workOrderIds) {
        if (workOrderIds.isEmpty()) {
            return;
        }
        Set<Id> childWorkOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIds = new Set<Id>();
        Set<Id> workOrderIdsToDeleteReadinessCheckFailures = new Set<Id>();
        for (WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)) {
            if (
                WorkOrderSettingsService.isReadinessCheckEligibilityByParentBypassed(
                    eachWorkOrder
                ) ||
                eachWorkOrder.Provisioning_Status__c == PROVISIONING_STATUS_PROVISIONING_COMPLETE
            ) {
                continue;
            }
            if (
                WorkOrderSettingsService.isReadinessCheckEligibleOnParentWorkOrderCreation(
                    eachWorkOrder
                )
            ) {
                parentWorkOrderIds.add(eachWorkOrder.Id);
            }
            if (eachWorkOrder.ParentWorkOrderId != null) {
                parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
                childWorkOrderIds.add(eachWorkOrder.Id);
            }
        }
        if (parentWorkOrderIds.isEmpty() && childWorkOrderIds.isEmpty()) {
            return;
        }
        workOrderIdsToDeleteReadinessCheckFailures.addAll(childWorkOrderIds);
        workOrderIdsToDeleteReadinessCheckFailures.addAll(parentWorkOrderIds);
        // Query readiness check failures where parent Work Order is populated as child Work Order
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        existingReadinessCheckFailures = ReadinessCheckFailuresSelector.newInstance()
            .selectByChildWorkOrderIds(workOrderIdsToDeleteReadinessCheckFailures);
        // @jira LEM-13963  passing the exiting readiness check failures to processing;
        if (!parentWorkOrderIds.isEmpty() && childWorkOrderIds.isEmpty()) {
            StoreReadinessCheckService.runReadinessCheckOnWorkOrders(
                parentWorkOrderIds,
                existingReadinessCheckFailures
            );
        } else {
            StoreReadinessCheckService.runReadinessCheckOnWorkOrders(
                childWorkOrderIds,
                existingReadinessCheckFailures
            );
        }
    }

    /**
     * @description It cleans up the existing business Account readiness check failures and trigger
     * readiness check on the passed parent Work Order Ids.
     * @JIRA LEM-2455
     * @param workOrderIds
     * @param triggerSource
     * @return Boolean
     */
    public Boolean runReadinessCheckOnParentWorkOrders(Set<Id> workOrderIds, String triggerSource) {
        Set<Id> childWorkOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIds = new Set<Id>();
        Set<Id> parentWorkOrderIdsToRunReadinessCheckOnChildWorkOrders = new Set<Id>();
        Set<Id> workOrderIdsToProcess = new Set<Id>();
        Boolean isAsyncCall = false;
        for (WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)) {
            /* Added condition to skip triggering of the Readiness Check when
             'Execute_Readiness_Check__c' value is false. */
            if (
                String.isNotBlank(eachWorkOrder.ParentWorkOrderId) ||
                eachWorkOrder.Type__c == 'POS' ||
                eachWorkOrder.Sub_Type__c == 'COO Same Store' ||
                (triggerSource == READINESS_CHECK_TRIGGER_SOURCE_CHANGE_EVENT &&
                !eachWorkOrder.Execute_Readiness_Check__c)
            ) {
                continue;
            }
            parentWorkOrderIds.add(eachWorkOrder.Id);
            if (
                WorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(eachWorkOrder)
            ) {
                workOrderIdsToProcess.add(eachWorkOrder.Id);
            } else {
                parentWorkOrderIdsToRunReadinessCheckOnChildWorkOrders.add(eachWorkOrder.Id);
            }
        }
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();
        // Query readiness check failures where parent Work Order is populated as child Work Order
        existingReadinessCheckFailures.addAll(
            ReadinessCheckFailuresSelector.newInstance()
                .selectByParentWorkOrderIds(parentWorkOrderIds)
        );
        if (!parentWorkOrderIdsToRunReadinessCheckOnChildWorkOrders.isEmpty()) {
            childWorkOrderIds = new Map<Id, Workorder>(
                    WorkOrdersSelector.newInstance()
                        .selectByParentWorkOrderIds(
                            parentWorkOrderIdsToRunReadinessCheckOnChildWorkOrders
                        )
                )
                .keySet();
        }
        if (
            (childWorkOrderIds.isEmpty() ||
            childWorkOrderIds.size() <= childWorkOrderIdsChunkSize) &&
            existingReadinessCheckFailures.size() <= existingReadinessMessageProcessingLimit
        ) {
            workOrderIdsToProcess.addAll(childWorkOrderIds);
            // @jira LEM-13963 // passing the exiting readiness check failures to processing;
            StoreReadinessCheckService.runReadinessCheckOnWorkOrders(
                workOrderIdsToProcess,
                existingReadinessCheckFailures
            );
        } else {
            isAsyncCall = true;
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        childWorkOrderIds,
                        childWorkOrderIdsChunkSize
                    )
                }
            );
        }
        return isAsyncCall;
    }

    /**
     * @description It toggles banner indicator on the passed parent Work Orders.
     * @JIRA LEM-3711
     * @param parentWorkOrderIds
     */
    public void toggleBannerOnParentWorkOrders(Set<Id> parentWorkOrderIds) {
        fflib_ISObjectUnitOfWork uowToUpdateParentWorkOrder = Application.UNITOFWORK.newInstance();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectById(parentWorkOrderIds)
        ) {
            // toggles banner indicator on Work Order
            uowToUpdateParentWorkOrder.registerDirty(
                new WorkOrder(
                    Id = eachWorkOrder.Id,
                    IsStoresAssociationInProgress__c = !eachWorkOrder.IsStoresAssociationInProgress__c
                )
            );
        }
        commitWork(uowToUpdateParentWorkOrder);
    }

    /**
     * @description It used for updating work order records by given set of Ids
     * @JIRA# LEM-985, LEM-1011
     * @param workOrderRecords
     */
    public void updateWorkOrderStatus(List<WorkOrder> workOrderRecords) {
        String workOrderStatusToUpdate = '';
        List<WorkOrder> updateWorkOrderList = new List<WorkOrder>();
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        for (WorkOrder workOrderRecord : workOrderRecords) {
            workOrderStatusToUpdate = getWorkStatusUpdatedValue(workOrderRecord);
            if (String.isNotBlank(workOrderStatusToUpdate)) {
                updateWorkOrderList.add(
                    new WorkOrder(Id = workOrderRecord.Id, Status = workOrderStatusToUpdate)
                );
            }
        }
        if (!updateWorkOrderList.isEmpty()) {
            unitOfWork.registerDirty(updateWorkOrderList);
            commitWork(unitOfWork);
        }
    }

    /**
     * @description It is used for reverting Work Order Status to previous status value
     * (other than ‘Past Due’/‘At Risk’) based on Work Order History.
     * @JIRA# LEM-5159
     * @param workOrders
     */
    public void updateWorkOrderStatusByWorkOrderHistory(Map<Id, WorkOrder> workOrders) {
        String statusValueByHistory;
        String statusValueByPDOx;
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        Map<Id, WorkOrder> workOrdersToUpdate = new Map<Id, WorkOrder>();
        for (
            WorkOrderHistory eachWorkOrderHistory : WorkOrderHistorySelector.newInstance()
                .selectStatusHistoryByWorkOrderIds(workOrders.keySet())
        ) {
            statusValueByHistory = (String) eachWorkOrderHistory.OldValue;
            if (
                workOrdersToUpdate.containsKey(eachWorkOrderHistory.WorkOrderId) ||
                WORK_ORDER_PDOX_RELATED_STATUSES.contains(statusValueByHistory)
            ) {
                continue;
            }
            statusValueByPDOx = getWorkStatusUpdatedValue(
                workOrders.get(eachWorkOrderHistory.WorkOrderId)
            );
            workOrdersToUpdate.put(
                eachWorkOrderHistory.WorkOrderId,
                new WorkOrder(
                    Id = (Id) eachWorkOrderHistory.WorkOrderId,
                    Status = String.isBlank(statusValueByPDOx)
                        ? statusValueByHistory
                        : statusValueByPDOx
                )
            );
            workOrders.remove(eachWorkOrderHistory.WorkOrderId);
        }
        /* This handles scenario where ‘Past Due’/‘At Risk’ work order exists
         without work order history.*/
        for (Id eachWorkOrderId : workOrders.keySet()) {
            workOrdersToUpdate.put(
                eachWorkOrderId,
                new WorkOrder(Id = (Id) eachWorkOrderId, Status = STATUS_PLANNING)
            );
        }
        if (!workOrdersToUpdate.isEmpty()) {
            unitOfWork.registerDirty(workOrdersToUpdate.values());
            commitWork(unitOfWork);
        }
    }

    /**
     * @description It collects the provisioning status values for each parent Work Order Id
     * using the aggregate query on child Work Orders.
     * @JIRA# LEM-2083
     * @param parentWorkOrderIds
     */
    private void collectChildWorkOrdersDetailsToRollUpProvisioningStatusOnParentWorkOrders(
        Set<Id> parentWorkOrderIds
    ) {
        if (parentWorkOrderIds.isEmpty()) {
            return;
        }
        Id parentWorkOrderId;
        String workOrderProvisioningStatus;
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    parentWorkOrderIds
                )
        ) {
            parentWorkOrderId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS);
            unprocessedParentWorkOrderIds.remove(parentWorkOrderId);
            workOrderProvisioningStatus = (String) eachAggregate.get(
                AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS
            );
            if (!parentWorkOrderIdToProvisioningStatus.containsKey(parentWorkOrderId)) {
                parentWorkOrderIdToProvisioningStatus.put(parentWorkOrderId, new Set<String>());
            }
            if (
                !parentWorkOrderIdToProvisioningStatus.get(parentWorkOrderId)
                    .contains(workOrderProvisioningStatus)
            ) {
                parentWorkOrderIdToProvisioningStatus.get(parentWorkOrderId)
                    .add(workOrderProvisioningStatus);
            }
        }
        updateProvisioningStatusOnParentWorkOrder();
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.childWorkOrderIdsChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.workOrderIdsChunkSizeToCreateWorkPlans = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.existingReadinessMessageProcessingLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EXISTING_READINESS_ROWS_COUNT_CHECK)
                .Configuration_Value__c
        );
        this.storeAssociationPayloadSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(STORE_ASSOCIATION_PAYLOAD_SIZE)
                .Configuration_Value__c
        );
        this.existingReadinessMessageProcessingLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EXISTING_READINESS_ROWS_COUNT_CHECK)
                .Configuration_Value__c
        );
    }

    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-746
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_ORDER,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description It calculates provisioning status to roll-up on parent Work Order
     * on basis of child Work Orders' provisioning status.
     * @JIRA# LEM-2083
     * @param provisioningStatuses
     * @return String
     */
    private String getProvisioningStatus(Set<String> provisioningStatuses) {
        String calculatedProvisioningStatus;
        if (provisioningStatuses.contains(PROVISIONING_STATUS_READINESS_CHECK)) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_READINESS_CHECK;
        } else if (provisioningStatuses.contains(PROVISIONING_STATUS_READINESS_CHECK_FAILED)) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_READINESS_CHECK_FAILED;
        } else if (provisioningStatuses.contains(PROVISIONING_STATUS_READINESS_CHECK_COMPLETE)) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_READINESS_CHECK_COMPLETE;
        } else if (provisioningStatuses.contains(PROVISIONING_STATUS_READY_FOR_PROVISIONING)) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_READY_FOR_PROVISIONING;
        } else if (provisioningStatuses.contains(PROVISIONING_STATUS_PROVISIONING_FAILED)) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_PROVISIONING_FAILED;
        } else if (
            provisioningStatuses
                .equals(new Set<String>{ PROVISIONING_STATUS_PROVISIONING_COMPLETE })
        ) {
            calculatedProvisioningStatus = PROVISIONING_STATUS_PROVISIONING_COMPLETE;
        } else {
            calculatedProvisioningStatus = PROVISIONING_STATUS_NOT_STARTED;
        }
        return calculatedProvisioningStatus;
    }

    /**
     * @description It initiates Work Plans creation based on the passed Work Order Ids
     * received from Notifier Event's payload.
     * @JIRA# LEM-5836
     * @param workOrderIds
     */
    private void initiateWorkPlansCreationById(Set<Id> workOrderIds) {
        if (workOrderIds.isEmpty()) {
            return;
        }
        Map<Id, WorkOrder> workOrdersToProcess = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance().selectById(workOrderIds)
        );
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(
            workOrdersToProcess.values()
        );
    }

    /**
     * @description It checks whether Work Orders are eligible to create Work Plans on creation.
     * The conditions checked are as follows:
     * 1. Work Order is a parent Work Order i.e. ParentWorkOrderId as null and
     *  Account Record Type as 'Business'.
     * 2. Work Plans auto creation is enabled for the Work Order.
     * 3. Work Order has Provisioning Status as 'Readiness Check Complete'
     * Filter logic: 1 AND (2 OR 3)
     * @JIRA# LEM-5890
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleToCreateWorkPlansOnCreateChangeType(WorkOrder workOrder) {
        return (workOrder.ParentWorkOrderId == null &&
            workOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_BUSINESS &&
            (WorkOrderSettingsService.isWorkPlansAutoCreationEnabled(workOrder) ||
            //Added provisioning status check for Integrated Franchise scenario where Provisioning
            //Status is 'Readiness Check Complete' in 'CREATE' changeType.
            workOrder.Provisioning_Status__c == PROVISIONING_STATUS_READINESS_CHECK_COMPLETE)) ||
            (workOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE &&
            (WorkOrderSettingsService.isReadinessCheckEligibilityByParentBypassed(workOrder) ||
            isStorefrontWorkOrderCreationSourcePlaceItForMe(workOrder)));
    }

    /**
     * @description It enables auto creation of Work Plans for Storefront Work Orders
     * created for Place It For Me process.
     * @JIRA# LEM-15585
     * @param workOrder
     * @return Boolean
     */
    private Boolean isStorefrontWorkOrderCreationSourcePlaceItForMe(WorkOrder workOrder) {
        return workOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
            workOrder.Creation_Source__c == WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME;
    }

    /**
     * @description It checks whether Work Orders are eligible to create Work Plans on updation.
     * The conditions checked are as follows:
     * 1. Work Order is a child Work Order having Parent Work Order's Provisioning Status as
     * 'Readiness Check Complete'.
     * 2. Work Order is a parent Work Order having Provisioning Status as 'Readiness Check Complete'
     * and Work Plans creation is allowed without stores association.
     * Filter logic: 1 OR 2
     * @JIRA# LEM-1684, LEM-2132, LEM-3094, LEM-5273
     * @param workOrder
     * @return Boolean
     */
    private Boolean isEligibleToCreateWorkPlansOnUpdateChangeType(WorkOrder workOrder) {
        Boolean isEligible = false;
        if (
            workOrder.ParentWorkOrderId != null &&
            workOrder.ParentWorkOrder.Provisioning_Status__c ==
            PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
        ) {
            isEligible = true;
        } else if (
            workOrder.ParentWorkOrderId == null &&
            workOrder.Provisioning_Status__c == PROVISIONING_STATUS_READINESS_CHECK_COMPLETE &&
            WorkOrderSettingsService.isWorkPlansEligibilityByStoreBypassed(workOrder)
        ) {
            isEligible = true;
        } else if (
            workOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE &&
            (workOrder.Type__c == 'POS' ||
            workOrder.Sub_Type__c == 'COO Same Store')
        ) {
            isEligible = true;
        }
        return isEligible;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It is used for populating "Account Owner Email Id" on Account's Owner change.
     * @JIRA# LEM-746
     * @param accountIds
     */
    private void updateAccountOwnerEmailOnWorkOrder(Set<Id> accountIds) {
        if (isEmptyOrNull(accountIds)) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(accountIds)
        ) {
            eachWorkOrder.Account_Owner_Email_Id__c = eachWorkOrder.Account_Owner_Email_Calculated__c;
            workOrdersToUpdate.add(eachWorkOrder);
            for (WorkStep eachWorkStep : eachWorkOrder.WorkSteps) {
                workStepsToUpdate.add(
                    new WorkStep(
                        Id = eachWorkStep.Id,
                        Account_Owner_Email_Id__c = eachWorkOrder.Account_Owner_Email_Calculated__c
                    )
                );
            }
        }
        List<sObject> sObjectsToUpdate = new List<sObject>();
        sObjectsToUpdate.addAll(workOrdersToUpdate);
        sObjectsToUpdate.addAll(workStepsToUpdate);
        unitOfWorkInstance.registerDirty(sObjectsToUpdate);
        commitWork(unitOfWorkInstance);
    }

    /**
     * @description It is used to calculate unique number of Stores from child Work Orders
     * using given set of parent Work Order Ids.
     * @JIRA# LEM-955
     * @param parentWorkOrderIds
     */
    private void updateActualNumberOfStoresOnParentWorkOrder(Set<Id> parentWorkOrderIds) {
        if (isEmptyOrNull(parentWorkOrderIds)) {
            return;
        }
        unprocessedParentWorkOrderIds.addAll(parentWorkOrderIds);
        Id workOrderId;
        WorkOrder currentWorkOrder;
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    parentWorkOrderIds
                )
        ) {
            workOrderId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS);
            unprocessedParentWorkOrderIds.remove(workOrderId);
            if (workOrders.containsKey(workOrderId)) {
                currentWorkOrder = workOrders.get(workOrderId);
                currentWorkOrder.Actual_Number_Of_Stores__c += Integer.valueOf(
                    eachAggregate.get(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS)
                );
            } else {
                workOrders.put(
                    workOrderId,
                    new WorkOrder(
                        Id = workOrderId,
                        Actual_Number_Of_Stores__c = Integer.valueOf(
                            eachAggregate.get(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS)
                        )
                    )
                );
            }
        }
        if (!isEmptyOrNull(unprocessedParentWorkOrderIds)) {
            handleUnprocessedParentWorkOrderIds();
        }
        collectChildWorkOrdersDetailsToRollUpProvisioningStatusOnParentWorkOrders(
            parentWorkOrderIds
        );
    }

    /**
     * @description It is used for updating Provisioning Status on parent Work Orders
     * based on grouping of Provisioning Status on child Work Orders.
     * @JIRA# LEM-2083
     */
    private void updateProvisioningStatusOnParentWorkOrder() {
        fflib_ISObjectUnitOfWork uowToUpdateParentWorkOrder = Application.UNITOFWORK.newInstance();
        String provisioningStatusToUpdate;
        WorkOrder workOrderToUpdate;
        Boolean isAddStores = false;
        Set<String> provisioningStatuses = new Set<String>();
        for (Id eachWorkOrderId : parentWorkOrderIdToProvisioningStatus.keySet()) {
            isAddStores = false;
            provisioningStatuses = parentWorkOrderIdToProvisioningStatus.get(eachWorkOrderId);
            provisioningStatusToUpdate = getProvisioningStatus(provisioningStatuses);
            if (workOrders.containsKey(eachWorkOrderId)) {
                isAddStores = true;
                workOrderToUpdate = workOrders.get(eachWorkOrderId);
            } else {
                workOrderToUpdate = new WorkOrder(Id = eachWorkOrderId);
            }
            workOrderToUpdate.Provisioning_Status__c = provisioningStatusToUpdate;
            // LEM-1684 - Added field update to trigger readiness check email on every re-run
            if (
                provisioningStatusToUpdate == PROVISIONING_STATUS_READINESS_CHECK_FAILED &&
                !isAddStores
            ) {
                workOrderToUpdate.Send_Readiness_Check_Email__c = String.valueOf(
                    Math.abs(Crypto.getRandomInteger())
                );
            }
            // LEM-2413 - Added field update to enable visibility of "Re-evaludate Work Plans".
            if (
                provisioningStatuses.equals(
                    new Set<String>{ PROVISIONING_STATUS_READY_FOR_PROVISIONING }
                )
            ) {
                workOrderToUpdate.HasWorkPlansGenerated__c = true;
            }
            //Reset the flag value to false once the Readiness Check process is completed
            workOrderToUpdate.Execute_Readiness_Check__c = false;
            uowToUpdateParentWorkOrder.registerDirty(workOrderToUpdate);
        }
        commitWork(uowToUpdateParentWorkOrder);
    }

    /**
     * @description - creates a map of creation methods by parent work order id
     * @JIRA# LEM-2304
     * @param workOrderIds
     * @return list of store ids by workorder parent id
     */
    private Map<Id, String> getCreationMethodsByParentWorkOrderIds(Set<Id> workOrderIds) {
        Map<Id, String> creationMethodsByParentWorkOrderIds = new Map<Id, String>();

        for (
            WorkOrder parentWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)
        ) {
            creationMethodsByParentWorkOrderIds.put(
                parentWorkOrder.Id,
                parentWorkOrder.Business_to_Store_Assignment__c
            );
        }

        return creationMethodsByParentWorkOrderIds;
    }

    /**
     * @description - creates a map of work Order Types by parent work order id
     * @JIRA# LEM-2304
     * @param workOrderIds
     * @return list of store ids by workorder parent id
     */
    private Map<Id, String> getWorkOrderTypeByParentWorkOrderIds(Set<Id> workOrderIds) {
        Map<Id, String> workOrderTypeByParentWorkOrderIds = new Map<Id, String>();

        for (
            WorkOrder parentWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)
        ) {
            workOrderTypeByParentWorkOrderIds.put(parentWorkOrder.Id, parentWorkOrder.Type__c);
        }

        return workOrderTypeByParentWorkOrderIds;
    }

    /**
     * @description - creates a map of list of store accounts by parent work order id
     * @JIRA# LEM-2304
     * @param workOrderIds
     * @return list of store ids by workorder parent id
     */
    private Map<Id, List<Id>> getChildWorkOrderAccountIdsByParentWorkOrderIds(
        Set<Id> workOrderIds
    ) {
        Map<Id, List<Id>> childAccountIdsByParentWorkOrderIds = new Map<Id, List<Id>>();
        if (workOrderIds.isEmpty()) {
            return childAccountIdsByParentWorkOrderIds;
        }
        for (
            WorkOrder childWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(workOrderIds)
        ) {
            if (
                !childAccountIdsByParentWorkOrderIds.containsKey(childWorkOrder.ParentWorkOrderId)
            ) {
                childAccountIdsByParentWorkOrderIds.put(
                    childWorkOrder.ParentWorkOrderId,
                    new List<Id>()
                );
            }

            childAccountIdsByParentWorkOrderIds.get(childWorkOrder.ParentWorkOrderId)
                .add(childWorkOrder.AccountId);
        }
        return childAccountIdsByParentWorkOrderIds;
    }

    /**
     * @description - creates a list of provisioning events.
     * @JIRA# LEM-2304
     * @param childAccountIdsByParentWorkOrderIds
     * @param creationMethodsByParentWorkOrderIds
     * @param workOrderTypeByParentWorkOrderIds
     * @return list of provisioning events to publish
     */
    private List<Provisioning_Event__e> generateProvisioningEvents(
        Map<Id, List<Id>> childAccountIdsByParentWorkOrderIds,
        Map<Id, String> creationMethodsByParentWorkOrderIds,
        Map<Id, String> workOrderTypeByParentWorkOrderIds
    ) {
        List<Provisioning_Event__e> events = new List<Provisioning_Event__e>();
        String creationMethod;

        for (Id parentWorkOrderId : childAccountIdsByParentWorkOrderIds.keySet()) {
            creationMethod = creationMethodsByParentWorkOrderIds.get(parentWorkOrderId);
            events.addAll(
                createProvisioningEvent(
                    creationMethod,
                    childAccountIdsByParentWorkOrderIds.get(parentWorkOrderId),
                    workOrderTypeByParentWorkOrderIds.get(parentWorkOrderId)
                )
            );
        }

        return events;
    }

    /**
     * @description It is used to update "Actual Number of Stores" to '0' and "Provisioning Status"
     * to 'Not Started' on parent Work orders without child Work orders.
     * @JIRA# LEM-5837
     */
    private void handleUnprocessedParentWorkOrderIds() {
        for (Id eachWorkOrderId : unprocessedParentWorkOrderIds) {
            workOrders.put(
                eachWorkOrderId,
                new WorkOrder(Id = eachWorkOrderId, Actual_Number_Of_Stores__c = 0)
            );
            parentWorkOrderIdToProvisioningStatus.put(
                eachWorkOrderId,
                new Set<String>{ PROVISIONING_STATUS_NOT_STARTED }
            );
        }
    }

    /**
     * @description creates a new provisioning platform event
     *
     * @JIRA# LEM-2304
     * @param creationMethod
     * @param childAccountIds
     * @param woType
     * @return list of events
     */
    private List<Provisioning_Event__e> createProvisioningEvent(
        String creationMethod,
        List<Id> childAccountIds,
        String woType
    ) {
        List<Provisioning_Event__e> events = new List<Provisioning_Event__e>();
        Integer scopeSize = PROVISIONING_EVENT_SCOPE_SIZE;
        Integer currentGroupSize = 0;
        List<Id> groupChildAccountIds = new List<Id>();
        String messageDetails = '';

        for (Id childAccountId : childAccountIds) {
            groupChildAccountIds.add(childAccountId);
            currentGroupSize++;

            if (currentGroupSize >= scopeSize) {
                events.add(
                    new Provisioning_Event__e(
                        WO_Type__c = woType,
                        Creation_Method__c = creationMethod,
                        Accounts__c = JSON.serialize(groupChildAccountIds)
                    )
                );
                // Append the message for logging
                messageDetails =
                    messageDetails +
                    ' Provisioning Event Created: WO_Type=' +
                    woType +
                    ', Creation_Method=' +
                    creationMethod +
                    ', Accounts=' +
                    JSON.serialize(groupChildAccountIds);

                //reset for next group
                currentGroupSize = 0;
                groupChildAccountIds = new List<Id>();
            }
        }

        if (!groupChildAccountIds.isEmpty()) {
            events.add(
                new Provisioning_Event__e(
                    WO_Type__c = woType,
                    Creation_Method__c = creationMethod,
                    Accounts__c = JSON.serialize(groupChildAccountIds)
                )
            );
            // Append the message for logging
            MessageDetails =
                MessageDetails +
                ' Provisioning Event BEFORE Creation: WO_Type=' +
                woType +
                ', Creation_Method=' +
                creationMethod +
                ', Accounts=' +
                JSON.serialize(groupChildAccountIds);
        }

        // Log the event details
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    GENERIC_LOG_SERVICE_WORKORDER_PROVISIONING_EVENT,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logMessage(MessageDetails)
        );
        return events;
    }

    /**
     * @description - creates a list of provisioning events for Drive DB
     * @JIRA# LEM-2703
     * @param workOrderIds
     * @return list of provisioning events to publish
     * TODO: Replace multiple selectById method calls with one method to collect data related to
     * the required maps.
     */
    private List<Provisioning_Event__e> generateProvisioningEventsForDrive(Set<Id> workOrderIds) {
        Map<Id, List<Id>> childAccountIdsByParentWorkOrderIds = getChildWorkOrderAccountIdsByParentWorkOrderIds(
            workOrderIds
        );
        // Create provisioning events for child work orders
        List<Provisioning_Event__e> provisioningEventList = generateProvisioningEvents(
            childAccountIdsByParentWorkOrderIds,
            getCreationMethodsByParentWorkOrderIds(workOrderIds),
            getWorkOrderTypeByParentWorkOrderIds(workOrderIds)
        );

        for (
            WorkOrder eachDriveWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)
        ) {
            if (
                eachDriveWorkOrder.Type__c == WORK_ORDER_TYPE_DRIVE &&
                !childAccountIdsByParentWorkOrderIds.containsKey(eachDriveWorkOrder.Id)
            ) {
                driveWorkOrders.put(eachDriveWorkOrder.Id, eachDriveWorkOrder);
                provisioningEventList.add(
                    new Provisioning_Event__e(
                        WO_Type__c = eachDriveWorkOrder.Type__c,
                        Creation_Method__c = eachDriveWorkOrder.Business_to_Store_Assignment__c,
                        Accounts__c = JSON.serialize(new Set<Id>{ eachDriveWorkOrder.AccountId })
                    )
                );
            }
        }
        return provisioningEventList;
    }

    /**
     * @description - creates a list of provisioning events for COO
     * @JIRA# LEM-3373
     * @param parentWOIdToChildAccountIdListMap
     * @return list of provisioning events to publish
     */
    private List<Provisioning_Event__e> generateProvisioningEventsForCOO(
        Map<Id, List<Id>> parentWOIdToChildAccountIdListMap
    ) {
        List<Provisioning_Event__e> provisioningEventList = new List<Provisioning_Event__e>();

        for (
            WorkOrder eachCOOWorkOrder : WorkOrdersSelector.newInstance()
                .selectById(parentWOIdToChildAccountIdListMap.keySet())
        ) {
            if (eachCOOWorkOrder.Type__c == WORK_ORDER_TYPE_COO) {
                List<Id> childWOAccountIdList = parentWOIdToChildAccountIdListMap.get(
                    eachCOOWorkOrder.Id
                );
                provisioningEventList.add(
                    new Provisioning_Event__e(
                        COO_Graveyard_Id__c = String.IsBlank(
                                eachCOOWorkOrder.COO_Graveyard_Business_Id__c
                            )
                            ? ''
                            : eachCOOWorkOrder.COO_Graveyard_Business_Id__c,
                        WO_Type__c = eachCOOWorkOrder.Type__c,
                        Creation_Method__c = eachCOOWorkOrder.Business_to_Store_Assignment__c,
                        Accounts__c = JSON.serialize(childWOAccountIdList)
                    )
                );
            }
        }
        return provisioningEventList;
    }

    /**
     * @description It updates child Work Orders' provisioning status to
     * 'Ready for Provisioning' on Work Plans and Work Steps generation.
     * @JIRA# LEM-1684
     * @param workOrderIds
     */
    private void updateWorkOrderProvisioningStatusToReadyForProvisioning(Set<Id> workOrderIds) {
        fflib_ISObjectUnitOfWork uowWorkOrdersUpdation = Application.UNITOFWORK.newInstance();
        if (workOrderIds.isEmpty()) {
            return;
        }
        for (WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)) {
            if (eachWorkOrder.HasWorkPlansGenerated__c) {
                continue;
            }
            uowWorkOrdersUpdation.registerDirty(
                new WorkOrder(
                    Id = eachWorkOrder.Id,
                    Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
                    HasWorkPlansGenerated__c = true
                )
            );
        }
        commitWork(uowWorkOrdersUpdation);
    }

    /**
     * @description Get the Child work orders from Parent WorkOrder and Update the status to
     * Provisioning complete
     * @JIRA# LEM-3170
     * @param workOrderIds
     */
    public void updateChildWorkOrdersStatusToProvisioningComplete(Set<Id> workOrderIds) {
        Set<Id> storeAccountIds = new Set<Id>();
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<WorkOrder> updateWorkOrderList = new List<WorkOrder>();
        if (workOrderIds.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(workOrderIds)
        ) {
            storeAccountIds.add(eachWorkOrder.AccountId);
        }
        if (storeAccountIds.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(storeAccountIds)
        ) {
            if (
                eachWorkOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
                eachWorkOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES &&
                eachWorkOrder.Provisioning_Status__c == PROVISIONING_STATUS_READY_FOR_PROVISIONING
            ) {
                updateWorkOrderList.add(
                    new WorkOrder(
                        Id = eachWorkOrder.Id,
                        Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_COMPLETE
                    )
                );
            }
            if (!updateWorkOrderList.isEmpty()) {
                unitOfWork.registerDirty(updateWorkOrderList);
                commitWork(unitOfWork);
            }
        }
    }

    /**
     * @description It is used to update child Work Orders Provisioining Status by Marketplace
     * Work Order's Provisioning Status.
     * @JIRA# LEM-19828
     * @param workOrders
     */
    public void updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
        Set<WorkOrder> workOrders
    ) {
        Set<Id> businessAccountIds = new Set<Id>();
        Map<Id, WorkOrder> storefrontWorkOrderIdToWorkOrder = new Map<Id, WorkOrder>();
        Map<Id, WorkOrder> quoteIdToMarketplaceWorkOrder = new Map<Id, WorkOrder>();
        Set<Id> matchingStorefrontWorkOrderIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            businessAccountIds.add(eachWorkOrder.AccountId);
            storefrontWorkOrderIdToWorkOrder.put(eachWorkOrder.Id, eachWorkOrder);
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(businessAccountIds)
        ) {
            if (eachWorkOrder.status == STATUS_DEAD) {
                continue;
            }
            if (storefrontWorkOrderIdToWorkOrder.containsKey(eachWorkOrder.Id)) {
                storefrontWorkOrderIdToWorkOrder.put(eachWorkOrder.Id, eachWorkOrder);
            }
            if (eachWorkOrder.Type__c == WORK_ORDER_TYPE_MARKETPLACE) {
                quoteIdToMarketplaceWorkOrder.put(
                    eachWorkOrder.Contract__r.SBQQ__Order__r.SBQQ__Quote__c,
                    eachWorkOrder
                );
            }
        }
        matchingStorefrontWorkOrderIds = getMatchingStorefrontParentWorkOrders(
            storefrontWorkOrderIdToWorkOrder,
            quoteIdToMarketplaceWorkOrder
        );
        updateStorefrontBundledChildWorkOrderProvisioningStatus(
            matchingStorefrontWorkOrderIds,
            quoteIdToMarketplaceWorkOrder
        );
    }

    /**
     * @description It is used to update Storefront bundled Work Orders Provisioning Status by Marketplace
     * Work Orders Provisioning Status.
     * @JIRA# LEM-19828
     * @param matchingStorefrontWorkOrderIds
     * @param quoteIdToMarketplaceWorkOrder
     */
    private void updateStorefrontBundledChildWorkOrderProvisioningStatus(
        Set<Id> matchingStorefrontWorkOrderIds,
        Map<Id, WorkOrder> quoteIdToMarketplaceWorkOrder
    ) {
        WorkOrder marketplaceWorkOrder;
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(matchingStorefrontWorkOrderIds)
        ) {
            marketplaceWorkOrder = quoteIdToMarketplaceWorkOrder.get(
                eachWorkOrder.ParentWorkOrder.Contract__r.SBQQ__Order__r.SBQQ__Quote__c
            );
            if (
                marketplaceWorkOrder.Provisioning_Status__c ==
                PROVISIONING_STATUS_PROVISIONING_COMPLETE
            ) {
                unitOfWork.registerDirty(
                    new WorkOrder(
                        Id = eachWorkOrder.Id,
                        Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_COMPLETE
                    )
                );
            }
        }
        commitWork(unitOfWork);
    }

    /**
     * @description It is used to get Storefront parent Work Orders that matches Markeplace Work Orders
     * Quote.
     * @JIRA# LEM-19828
     * @param storefrontWorkOrderIdToWorkOrder
     * @param quoteIdToMarketplaceWorkOrder
     * @return Set<Id>
     */
    private Set<Id> getMatchingStorefrontParentWorkOrders(
        Map<Id, WorkOrder> storefrontWorkOrderIdToWorkOrder,
        Map<Id, WorkOrder> quoteIdToMarketplaceWorkOrder
    ) {
        Set<Id> matchingStorefrontWorkOrderIds = new Set<Id>();
        Id quoteId;
        for (WorkOrder eachWorkOrder : storefrontWorkOrderIdToWorkOrder.values()) {
            quoteId = eachWorkOrder.Contract__r.SBQQ__Order__r.SBQQ__Quote__c;
            if (quoteIdToMarketplaceWorkOrder.containsKey(quoteId)) {
                matchingStorefrontWorkOrderIds.add(eachWorkOrder.Id);
            }
        }
        return matchingStorefrontWorkOrderIds;
    }

    /**
     * @description It updates "Store Id" and "Business Id" on selective work orders
     * associated to the passed store accounts.
     * @JIRA# LEM-18577
     * @param storeAccountIds
     */
    public void updateStoreIdsOnChildWorkOrders(Set<Id> storeAccountIds) {
        List<String> businessIdUpdateEligibleWorkOrderTypes = getEligibleChildWorkOrderTypesForBusinessIdUpdate();
        List<String> storeIdUpdateEligibleWorkOrderTypes = getEligibleChildWorkOrderTypesForStoreIdUpdate();
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        Map<Id, WorkOrder> storeAccountIdToWorkOrder = new Map<Id, WorkOrder>();
        WorkOrder workOrderInstance;
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersByAccountIds(storeAccountIds)
        ) {
            if (eachWorkOrder.AccountId != null) {
                storeAccountIdToWorkOrder.put(eachWorkOrder.AccountId, eachWorkOrder);
            }
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectBySalesforceAccountName(storeAccountIds)
        ) {
            if (
                storeAccountIdToWorkOrder.containsKey(eachXref.Salesforce_Account_Name__c) &&
                String.isNotBlank(eachXref.External_ID__c)
            ) {
                workOrderInstance = storeAccountIdToWorkOrder.get(
                    eachXref.Salesforce_Account_Name__c
                );
                workOrderInstance.Store_Id__c = (!storeIdUpdateEligibleWorkOrderTypes.isEmpty() &&
                    storeIdUpdateEligibleWorkOrderTypes.contains(workOrderInstance.Type__c))
                    ? eachXref?.External_ID__c
                    : workOrderInstance.Store_Id__c;
                getBusinessId(workOrderInstance, eachXref, businessIdUpdateEligibleWorkOrderTypes);
                unitOfWorkInstance.registerDirty(workOrderInstance);
            }
        }
        commitWork(unitOfWorkInstance);
    }

    /**
     * @description It assigns Business Id to the applicable Work Order.
     * @JIRA# LEM-18577
     * @param workOrder
     * @param xref
     * @param businessIdUpdateEligibleWorkOrderTypes
     */
    private void getBusinessId(
        WorkOrder workOrder,
        Xref__c xref,
        List<String> businessIdUpdateEligibleWorkOrderTypes
    ) {
        workOrder.Business_Id__c = (!businessIdUpdateEligibleWorkOrderTypes.isEmpty() &&
            businessIdUpdateEligibleWorkOrderTypes.contains(workOrder.Type__c))
            ? xref?.Business_Reference__r?.External_Id__c
            : null;
    }

    /**
     * @description It fetches the Work Order types eligible for Business Id update.
     * @JIRA# LEM-18577
     * @return List<String>
     */
    private List<String> getEligibleChildWorkOrderTypesForBusinessIdUpdate() {
        return StaticConfigurationsSelector.newInstance()
            .getInstanceValue(CHILD_WORK_ORDER_TYPES_ELIGIBLE_FOR_BUSINESS_ID_UPDATE)
            .Configuration_Value__c.split(DELIMITER);
    }

    /**
     * @description It fetches the Work Order types eligible for Store Id update.
     * @JIRA# LEM-18577
     * @return List<String>
     */
    private List<String> getEligibleChildWorkOrderTypesForStoreIdUpdate() {
        return StaticConfigurationsSelector.newInstance()
            .getInstanceValue(CHILD_WORK_ORDER_TYPES_ELIGIBLE_FOR_STORE_ID_UPDATE)
            .Configuration_Value__c.split(DELIMITER);
    }

    /**
     * @description Get the child work orders from Parent WorkOrder and Update the status to
     * Dead
     * @JIRA# LEM-5460
     * @param parentWorkOrderIds
     */
    public void updateChildWorkStepsStatusToDead(Set<Id> parentWorkOrderIds) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        if (parentWorkOrderIds == null || parentWorkOrderIds.isEmpty()) {
            return;
        }
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersAndWorkStepsUsingWorkOrderIds(parentWorkOrderIds)
        ) {
            for (WorkStep eachWorkStep : eachWorkOrder.WorkSteps) {
                if (!STATUS_DEAD.equals(eachWorkStep.Status)) {
                    workStepsToUpdate.add(
                        new WorkStep(
                            Id = eachWorkStep.Id,
                            Status__c = STATUS_DEAD,
                            Is_Updated_By_System__c = true,
                            Status_Reason__c = REASON_OTHER,
                            Status_Reason_Details__c = System.Label.WorkStep_Dead_Status_Status_Reason_Details
                        )
                    );
                }
            }
        }
        if (!workStepsToUpdate.isEmpty()) {
            unitOfWork.registerDirty(workStepsToUpdate);
            commitWork(unitOfWork);
        }
    }

    /**
     * @description update work workOrder with newly associated account Ids
     * @param woIdToAssociatedAccounts - map WorkOrder Id to comma separated account Ids
     */
    public void setAssociatedAccounts(Map<Id, String> woIdToAssociatedAccounts) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id woId : woIdToAssociatedAccounts.keySet()) {
            uow.registerDirty(
                new WorkOrder(
                    Id = woId,
                    Associated_Account_Ids__c = woIdToAssociatedAccounts.get(woId)
                )
            );
        }
        uow.commitWork();
    }

    /**
     * @description update the workorder Last_Updated_By_MINT__c to now
     * @param workOrderIds
     */
    public void setLastUpdatedByMintToNow(Set<Id> workOrderIds) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Id woId : workOrderIds) {
            uow.registerDirty(new WorkOrder(Id = woId, Last_Updated_By_MINT__c = System.now()));
        }
        uow.commitWork();
    }

    @testVisible
    void initiateChildWorkOrderAutoCreation(Map<Id, Set<Id>> storeAccountIdToParentWOIds) {
        if (storeAccountIdToParentWOIds.isEmpty()) {
            return;
        }
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(storeAccountIdToParentWOIds);
    }

    /**
     * @description created child work orders
     * @param workOrderIds -- set of work order ids
     */
    public void initiateChildWorkOrderAutoCreation(Set<Id> workOrderIds) {
        if (workOrderIds.isEmpty()) {
            return;
        }

        // workOrderIds may contain any parent and child workOrder type during create event
        // wokOrderIds may contain any parent and child workOrder type that have either
        // Provisioning_Status__c or Associated_Account_Ids__c fields updated
        // we only need to handle parent POS WorkOrder

        // filter POS parent workOrders
        Map<Id, WorkOrder> wos = filterWOs(
            WorkOrdersSelector.newInstance().selectById(workOrderIds)
        );
        if (wos.isEmpty()) {
            return;
        }

        // filter for stores that need WorkOrder created
        Map<Id, Set<Id>> storeAccountIdToParentWOIds = getStoresToCreateChildWorkOrder(wos);

        // process chunks
        if (storeAccountIdToParentWOIds.size() > childWorkOrderIdsChunkSize) {
            Set<Object> payLoads = new Set<Object>();
            for (Id storeAccountId : storeAccountIdToParentWOIds.keySet()) {
                for (Id eachParentWOId : storeAccountIdToParentWOIds.get(storeAccountId)) {
                    payLoads.add(new AsyncPayloadWrapper(storeAccountId, eachParentWOId));
                }
            }
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                        payLoads,
                        childWorkOrderIdsChunkSize
                    )
                }
            );
            return;
        }
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(storeAccountIdToParentWOIds);
    }

    /**
     * @description It is used to update the work order status to "Dead" by the passed business
     * account ids.
     * @JIRA# LEM-23780
     * @param uow
     * @param businessAccountIds
     * @return fflib_ISObjectUnitOfWork
     */
    public fflib_ISObjectUnitOfWork updateChurnedMxWorkOrderToDead(
        fflib_ISObjectUnitOfWork uow,
        Set<Id> businessAccountIds
    ) {
        String contractSplitCategory;
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentAndChildWorkOrdersWithWorkPlansByBusinessAccountIds(businessAccountIds)
        ) {
            contractSplitCategory = eachWorkOrder.ParentWorkOrderId == null
                ? eachWorkOrder.Contract__r.Contract_Split_Category__c
                : eachWorkOrder.ParentWorkOrder.Contract__r.Contract_Split_Category__c;
            if (
                contractSplitCategory != CHURNED_MERCHANT_CONTRACT_SPLIT_CATEGORY ||
                (eachWorkOrder.ParentWOrkOrderId != null &&
                eachWorkOrder.WorkPlans.size() > 0)
            ) {
                continue;
            }
            eachWorkOrder.Status = STATUS_DEAD;
            uow.registerDirty(eachWorkOrder);
        }
        return uow;
    }

    @testVisible
    Map<Id, Set<Id>> getStoresToCreateChildWorkOrder(Map<Id, WorkOrder> idToWO) {
        Map<Id, Set<Id>> storeAccountIdToParentWOIds = new Map<Id, Set<Id>>();
        Set<Id> allAssociatedAccounts = new Set<Id>();
        Map<Id, Set<Id>> woIdToAssociatedAccount = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> woIdToAssociatedAccountWithExistingChildWO = new Map<Id, Set<Id>>();

        for (WorkOrder wo : idToWO.values()) {
            //initialize woIdToAssociatedAccountWithExistingChildWO
            woIdToAssociatedAccountWithExistingChildWO.put(wo.Id, new Set<Id>());

            // populate woIdToAssociatedAccount
            woIdToAssociatedAccount.put(
                wo.Id,
                new Set<Id>(
                    (String.isBlank(wo.Associated_Account_Ids__c)
                        ? new List<Id>()
                        : (List<Id>) wo.Associated_Account_Ids__c.deleteWhitespace().split(','))
                )
            );

            // populate allAssociatedAccounts
            allAssociatedAccounts.addAll(woIdToAssociatedAccount.get(wo.Id));
        }

        for (
            WorkOrder childWO : WorkOrdersSelector.newInstance()
                .selectChildWorkOrdersByStoreAccountIds(idToWO.keySet(), allAssociatedAccounts)
        ) {
            woIdToAssociatedAccountWithExistingChildWO.get(childWO.ParentWorkOrderId)
                .add(childWO.AccountId);
        }

        // populate storeAccountIdToParentWOIds
        for (Id parentWOId : woIdToAssociatedAccount.keySet()) {
            for (Id storeAccountId : woIdToAssociatedAccount.get(parentWOId)) {
                if (
                    !woIdToAssociatedAccountWithExistingChildWO.get(parentWOId)
                        .contains(storeAccountId)
                ) {
                    if (!storeAccountIdToParentWOIds.containsKey(storeAccountId)) {
                        storeAccountIdToParentWOIds.put(storeAccountId, new Set<Id>());
                    }
                    storeAccountIdToParentWOIds.get(storeAccountId).add(parentWOId);
                }
            }
        }
        return storeAccountIdToParentWOIds;
    }

    @testVisible
    Map<Id, WorkOrder> filterWOs(List<WorkOrder> wos) {
        // filter for parent POS WorkOrders
        Map<Id, WorkOrder> woIdToWorkOrder = new Map<Id, WorkOrder>();
        for (WorkOrder wo : wos) {
            if (wo.ParentWorkOrderId == null) {
                woIdToWorkOrder.put(wo.Id, wo);
            }
        }
        return woIdToWorkOrder;
    }

    /**
     * @description payload wrapper
     */
    public class AsyncPayloadWrapper {
        public Id key;
        public Id value;

        /**
         * @description payload wrapper constructor
         * @param key
         * @param value
         */
        public AsyncPayloadWrapper(Id key, Id value) {
            this.key = key;
            this.value = value;
        }
    }
}