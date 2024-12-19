/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Implementation for Store Association Service.
 */
public inherited sharing class StoreAssociationServiceImpl implements IStoreAssociationService {
    private static final String EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT = 'PHOTOSHOOT_STORE_ASSOCIATION';
    private static final String GUIDED_FLOW = 'Guided Flow';
    private static final String GUIDED_FLOW_BUSINESS_ACCOUNT = 'Guided Flow - Business Account';
    private static final String GUIDED_FLOW_WORK_PLAN = 'Guided Flow - Work Plan';
    private static final String LOG_SERVICE_STORE_ASSOCIATION_SERVICE = 'StoreAssociationService';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String MANUAL_CREATION = 'Manual';
    private static final String WORK_ORDER_PHOTOSHOOT_TYPE = 'Photoshoot';
    private static final String WORK_ORDER_STATUS_CONFIRMED = 'Confirmed';
    private static final String WORK_ORDER_STATUS_NOT_STARTED = 'Not Started';
    private List<WorkOrder> guidedFlowWorkOrders;
    private List<WorkOrder> manualWorkOrders;
    private List<WorkOrder> childPhotoshootWorkOrder;
    private Set<Id> businessAccountIds;
    private fflib_ISObjectUnitOfWork uow;
    private Map<Id, String> storeAccountIdsToActiveMDSExternalId;
    Set<Id> storeAccountIds;

    private enum EventTopics {
        EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT_HANDLER
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT => EventTopics.EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT_HANDLER
    };

    private enum CreationSource {
        BUSINESS_ACCOUNT_GUIDED_FLOW_SOURCE,
        MANUAL_CREATION_SOURCE,
        WORK_PLAN_GUIDED_FLOW_SOURCE
    }
    private static final Map<String, CreationSource> CREATION_SOURCE_MAPPINGS = new Map<String, CreationSource>{
        GUIDED_FLOW_BUSINESS_ACCOUNT => CreationSource.BUSINESS_ACCOUNT_GUIDED_FLOW_SOURCE,
        MANUAL_CREATION => CreationSource.MANUAL_CREATION_SOURCE,
        GUIDED_FLOW_WORK_PLAN => CreationSource.WORK_PLAN_GUIDED_FLOW_SOURCE
    };

    /**
     * @description Default constructor for Store Association Service Impl
     */
    public StoreAssociationServiceImpl() {
        guidedFlowWorkOrders = new List<WorkOrder>();
        manualWorkOrders = new List<WorkOrder>();
        businessAccountIds = new Set<Id>();
        childPhotoshootWorkOrder = new List<WorkOrder>();
        uow = Application.UnitOfWork.newInstance();
        this.storeAccountIdsToActiveMDSExternalId = new Map<Id, String>();
        this.storeAccountIds = new Set<Id>();
    }

    /**
     * @description It is used to handle and route the published Onboarding Activations Events.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    public void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    ) {
        Set<Id> photoshootStoreAssociationWorkOrderIds;
        Set<Id> recordIdsByPayload;

        for (Onboarding_Activation__e eachEvent : onboardingActivationsEvents) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT_HANDLER {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    if (recordIdsByPayload == null) {
                        continue;
                    }
                    photoshootStoreAssociationWorkOrderIds = new Set<Id>();
                    photoshootStoreAssociationWorkOrderIds.addAll(recordIdsByPayload);
                }
            }
        }
        initiatePhotoshootStoreAssociation(photoshootStoreAssociationWorkOrderIds);
    }

    /**
     * @description It is used to initiate the Store Association process based on Photoshoot Work
     * Order Creation Source.
     * @param photoshootStoreAssociationWorkOrderIds
     */
    public void initiatePhotoshootStoreAssociation(Set<Id> photoshootStoreAssociationWorkOrderIds) {
        Map<String, List<WorkOrder>> creationSourceToWorkOrders = groupByCreationSource(
            getWorkOrders(photoshootStoreAssociationWorkOrderIds)
        );
        for (String eachCreationSource : creationSourceToWorkOrders.keySet()) {
            switch on CREATION_SOURCE_MAPPINGS.get(eachCreationSource) {
                when BUSINESS_ACCOUNT_GUIDED_FLOW_SOURCE {
                    guidedFlowWorkOrders.addAll(creationSourceToWorkOrders.get(eachCreationSource));
                }
                when MANUAL_CREATION_SOURCE {
                    manualWorkOrders.addAll(creationSourceToWorkOrders.get(eachCreationSource));
                }
                when WORK_PLAN_GUIDED_FLOW_SOURCE {
                    manualWorkOrders.addAll(creationSourceToWorkOrders.get(eachCreationSource));
                }
            }
        }
        associateStoreForGuidedFlow(guidedFlowWorkOrders);
        associateStoreForManualWorkOrder(manualWorkOrders);
    }

    /**
     * @description It is used to retrieve all Work Orders for Store Association.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    private List<WorkOrder> getWorkOrders(Set<Id> workOrderIds) {
        return WorkOrdersSelector.newInstance().selectById(workOrderIds);
    }

    /**
     * @description It is used to map the Work Orders to the associated creation source.
     * @param workOrdersForMapping
     * @return Map<String, List<WorkOrder>>
     */
    private Map<String, List<WorkOrder>> groupByCreationSource(
        List<WorkOrder> workOrdersForMapping
    ) {
        Map<String, List<WorkOrder>> creationSourceToWorkOrders = new Map<String, List<WorkOrder>>();
        creationSourceToWorkOrders.put(MANUAL_CREATION, new List<WorkOrder>());
        creationSourceToWorkOrders.put(GUIDED_FLOW_BUSINESS_ACCOUNT, new List<WorkOrder>());
        creationSourceToWorkOrders.put(GUIDED_FLOW_WORK_PLAN, new List<WorkOrder>());
        for (WorkOrder eachWorkOrder : workOrdersForMapping) {
            if (eachWorkOrder.Creation_Source__c == MANUAL_CREATION) {
                creationSourceToWorkOrders.get(eachWorkOrder.Creation_Source__c).add(eachWorkOrder);
            } else if (eachWorkOrder.Creation_Source__c == GUIDED_FLOW) {
                if (eachWorkOrder.Originating_Work_Order__c == null) {
                    creationSourceToWorkOrders.get(GUIDED_FLOW_BUSINESS_ACCOUNT).add(eachWorkOrder);
                } else {
                    creationSourceToWorkOrders.get(GUIDED_FLOW_WORK_PLAN).add(eachWorkOrder);
                }
            }
        }
        return creationSourceToWorkOrders;
    }

    /**
     * @description It is used to associate Stores to Work Orders created from Guided Flow.
     * @param workOrders
     */
    private void associateStoreForGuidedFlow(List<WorkOrder> workOrders) {
        if (workOrders.isEmpty()) {
            return;
        }
        Map<Id, List<WorkOrder>> businessAccountIdToPhotoshootWorkOrder = new Map<Id, List<WorkOrder>>();
        for (WorkOrder eachWorkOrder : workOrders) {
            businessAccountIds.add(eachWorkOrder.AccountId);
            if (!businessAccountIdToPhotoshootWorkOrder.containsKey(eachWorkOrder.AccountId)) {
                businessAccountIdToPhotoshootWorkOrder.put(
                    eachWorkOrder.AccountId,
                    new List<WorkOrder>()
                );
            }
            businessAccountIdToPhotoshootWorkOrder.get(eachWorkOrder.AccountId).add(eachWorkOrder);
        }
        List<Account> storeAccountsForAssociation = AccountsSelector.newInstance()
            .selectStoreAccountsByParentIdsAndExternalSource(businessAccountIds);
        for (Account eachAccount : storeAccountsForAssociation) {
            storeAccountIds.add(eachAccount.Id);
        }
        getActiveMDSXrefsByStoreAccountIds(storeAccountIds);
        if (storeAccountsForAssociation.isEmpty()) {
            return;
        }
        for (Account eachStoreAccount : storeAccountsForAssociation) {
            for (
                WorkOrder eachWorkOrder : businessAccountIdToPhotoshootWorkOrder.get(
                    eachStoreAccount?.ParentId
                )
            ) {
                registerPhotoshootWorkOrderForStoreAccounts(eachStoreAccount, eachWorkOrder);
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to associate Stores to Work Orders created from Pre-Sales or Manual.
     * @param workOrders
     */
    private void associateStoreForManualWorkOrder(List<WorkOrder> workOrders) {
        if (workOrders.isEmpty()) {
            return;
        }
        Set<Id> marketplaceWorkOrderIds = new Set<Id>();
        Map<Id, Set<Id>> marketplaceWorkOrderIdToPhotoshootWorkOrder = new Map<Id, Set<Id>>();
        for (WorkOrder eachWorkOrder : workOrders) {
            marketplaceWorkOrderIds.add(eachWorkOrder.Originating_Work_Order__c);
            if (
                !marketplaceWorkOrderIdToPhotoshootWorkOrder.containsKey(
                    eachWorkOrder.Originating_Work_Order__r.AccountId
                )
            ) {
                marketplaceWorkOrderIdToPhotoshootWorkOrder.put(
                    eachWorkOrder.Originating_Work_Order__r.AccountId,
                    new Set<Id>()
                );
            }
            marketplaceWorkOrderIdToPhotoshootWorkOrder.get(
                    eachWorkOrder.Originating_Work_Order__r.AccountId
                )
                .add(eachWorkOrder.Id);
        }
        List<Account> storeAccountsForAssociation = AccountsSelector.newInstance()
            .selectRelatedStoreAccountsQuery(marketplaceWorkOrderIds);
        for (Account eachAccount : storeAccountsForAssociation) {
            storeAccountIds.add(eachAccount.Id);
        }
        getActiveMDSXrefsByStoreAccountIds(storeAccountIds);
        for (WorkOrder eachPhotoshootWorkOrder : workOrders) {
            for (Account eachStoreAccount : storeAccountsForAssociation) {
                if (
                    marketplaceWorkOrderIdToPhotoshootWorkOrder.containsKey(
                        eachStoreAccount.ParentId
                    ) &&
                    marketplaceWorkOrderIdToPhotoshootWorkOrder.get(eachStoreAccount.ParentId)
                        .contains(eachPhotoshootWorkOrder.Id)
                ) {
                    registerPhotoshootWorkOrderForStoreAccounts(
                        eachStoreAccount,
                        eachPhotoshootWorkOrder
                    );
                }
            }
        }
        commitWork(uow);
    }

    /**
     * @description It is used to register new Photoshoot Work Order
     * @param storeAccount
     * @param photoshootWorkOrder
     */
    private void registerPhotoshootWorkOrderForStoreAccounts(
        Account storeAccount,
        WorkOrder photoshootWorkOrder
    ) {
        if (storeAccount == null || photoshootWorkOrder == null) {
            return;
        }
        uow.registerNew(
            new WorkOrder(
                Type__c = WORK_ORDER_PHOTOSHOOT_TYPE,
                AccountId = storeAccount.Id,
                Photoshoot_Date__c = photoshootWorkOrder?.Photoshoot_Date__c,
                Photoshoot_Time__c = photoshootWorkOrder?.Photoshoot_Time__c,
                Store_Location_for_Photoshoot__c = photoshootWorkOrder
                    ?.Store_Location_for_Photoshoot__c,
                Store_Id__c = getStoreId(storeAccount.Id),
                Status = WORK_ORDER_STATUS_CONFIRMED,
                Mx_Requested_Photoshoot__c = photoshootWorkOrder?.Mx_Requested_Photoshoot__c,
                ParentWorkOrderId = photoshootWorkOrder.Id,
                Provisioning_Status__c = WORK_ORDER_STATUS_NOT_STARTED
            )
        );
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     */
    private static void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_STORE_ASSOCIATION_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description It is used to collect active 'MDS' Xrefs related to Store Account Ids.
     * @JIRA# LEM-20937
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
     * @description It returns "External Id" corresponding to the passed Store Account Id.
     * @JIRA# LEM-20937
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