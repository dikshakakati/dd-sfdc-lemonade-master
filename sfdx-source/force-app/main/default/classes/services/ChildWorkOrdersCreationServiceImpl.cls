/**
 * @author Deloitte
 * @date 16/04/2024
 * @description Service Implementation class for child Work Orders creation related logic.
 */
public inherited sharing class ChildWorkOrdersCreationServiceImpl implements IChildWorkOrdersCreationService {
    private static final String LOG_SERVICE_STORE_ASSOCIATION_SERVICE = 'StoreAssociationService';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String PROVISIONING_STATUS_READINESS_CHECK = 'Readiness Check';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WO_SUBTYPE_COO = 'COO Same Store';
    private static final String WORK_ORDER_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private InsertUnitOfWorkHelper insertUnitOfWorkHelper;
    private List<Account> storeAccountsToCopyPDOX;
    private fflib_ISObjectUnitOfWork unitOfWorkInstance;
    private List<Database.SaveResult> workOrderInsertSaveResults;
    private List<WorkOrder> workOrdersToInsert;
    private Map<Id, String> storeAccountIdsToActiveMDSExternalId;
    Set<Id> storeAccountIds;

    /**
     * @description Default constructor to instantiate variables.
     */
    public ChildWorkOrdersCreationServiceImpl() {
        this.insertUnitOfWorkHelper = new InsertUnitOfWorkHelper();
        this.storeAccountsToCopyPDOX = new List<Account>();
        this.unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        this.storeAccountIdsToActiveMDSExternalId = new Map<Id, String>();
        this.storeAccountIds = new Set<Id>();
        // Register custom insert unit of work to allow partial success
        unitOfWorkInstance.registerWork(insertUnitOfWorkHelper);
        workOrdersToInsert = new List<WorkOrder>();
    }

    /**
     * @description It initiates association of Stores to the parent Marketing Kit WorkOrder.
     * @JIRA# LEM-15317
     * @param originatingWorkOrderIdToMarketingKitWorkOrder
     */
    public void initiateStoreAssociationOnMarketingKitWorkOrder(
        Map<Id, WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder
    ) {
        Map<Id, List<Account>> originatingWorkOrderIdToStoreAccounts = new Map<Id, List<Account>>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(originatingWorkOrderIdToMarketingKitWorkOrder.keySet())
        ) {
            if (
                !originatingWorkOrderIdToStoreAccounts.containsKey(eachWorkOrder.ParentWorkOrderId)
            ) {
                originatingWorkOrderIdToStoreAccounts.put(
                    eachWorkOrder.ParentWorkOrderId,
                    new List<Account>()
                );
            }
            originatingWorkOrderIdToStoreAccounts.get(eachWorkOrder.ParentWorkOrderId)
                .add(eachWorkOrder.Account);
            storeAccountIds.add(eachWorkOrder.Account.Id);
        }
        getActiveMDSXrefsByStoreAccountIds(storeAccountIds);
        if (originatingWorkOrderIdToStoreAccounts.isEmpty()) {
            return;
        }
        for (WorkOrder eachWorkOrder : originatingWorkOrderIdToMarketingKitWorkOrder.values()) {
            for (
                Account eachStoreAccount : originatingWorkOrderIdToStoreAccounts.get(
                    eachWorkOrder.Originating_Work_Order__c
                )
            ) {
                createChildWorkOrderByStoreAccount(eachWorkOrder, eachStoreAccount, '');
            }
        }
        try {
            unitOfWorkInstance.commitWork();
            workOrderInsertSaveResults = insertUnitOfWorkHelper.saveResults;
        } catch (Exception exp) {
            Logger.publish(LogEntry.newExceptionLog(exp, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_STORE_ASSOCIATION_SERVICE,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(exp)
            );
        }
    }

    /**
     * @description It is used to create child Work Order using the details from
     * the passed store Account and the passed parent Work Order.
     * @JIRA# LEM-15317
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
            Creation_Source__c = creationSource,
            Menu_Setup_Method__c = storeAccount.Menu_Setup_Method__c,
            Menu_to_be_Completed_By__c = storeAccount.Menu_to_be_Completed_By__c,
            Opportunity__c = parentWorkOrder.Opportunity__c,
            Order_Protocol__c = storeAccount.Order_Protocol__c,
            OwnerId = parentWorkOrder.OwnerId,
            ParentWorkOrderId = parentWorkOrder.Id,
            Sales_Notes_for_Menu_Team__c = storeAccount.Sales_Notes_for_Menu_Team__c,
            Status = parentWorkOrder.Status,
            Store_Id__c = getStoreId(storeAccount.Id),
            Sub_Type__c = parentWorkOrder.Sub_Type__c,
            Type__c = parentWorkOrder.Type__c,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        workOrdersToInsert.add(workOrderInstance);
        // Leveraging custom registerNew() method for partial success insertion.
        insertUnitOfWorkHelper.registerInsert(workOrderInstance);
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