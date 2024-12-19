/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Interface of service class for WorkOrder related logic.
 */
public interface IWorkOrdersService {
    /**
     * @description It associates Contracts to parent Work Orders based on the
     * passed Account and Contract Id mappings.
     * @param parentAccountIdtoContractId
     */
    void associateContractsOnParentWorkOrders(Map<Id, Id> parentAccountIdtoContractId);

    /**
     * @description It filters Opportunities without any associated parent Work Order.
     * @param opportunities
     * @return List<Opportunity>
     */
    List<Opportunity> collectOpportunitiesWithoutWorkOrder(List<Opportunity> opportunities);

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for COO work orders
     * @JIRA# LEM-3373
     * @param workOrderIds
     */
    void generateProvisioningEventForCOOWorkOrders(Set<Id> workOrderIds);

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for Drive
     *                  work orders
     * @JIRA# LEM-2703
     * @param workOrderIds
     */
    void generateProvisioningEventForDriveWorkOrders(Set<Id> workOrderIds);

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for each Parent
     * Work Order with child Store Account Work Orders
     * @JIRA# LEM-2304
     * @param workOrderIds
     */
    void generateProvisioningEventForWorkOrders(Set<Id> workOrderIds);

    /**
     * @description It is used for getting updated Work Order Status
     * on basis of PDOA/PDOM/PDOT date criteria.
     * @param workOrderRecord
     * @return String
     */
    String getWorkStatusUpdatedValue(WorkOrder workOrderRecord);

    /**
     * @description It is for getting parent Work Order Ids from the payload received
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It initiates Work Plans creation on the passed Work Orders Ids.
     * @param workOrderIds
     * @param changeType
     */
    void initiateWorkPlansCreation(Set<Id> workOrderIds, String changeType);

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It triggers actual number of stores and account owner email updates
     * on basis of the passed Work Orders.
     * @param workOrders
     */
    void processMergedAccountsRelatedRecords(List<WorkOrder> workOrders);

    /**
     * @description It clean-up the existing business Account readiness check failures and trigger
     * readiness check on the passed child Work Order Ids.
     * @param workOrderIds
     */
    void runReadinessCheckOnChildWorkOrders(Set<Id> workOrderIds);

    /**
     * @description It cleans up the existing business Account readiness check failures and trigger
     * readiness check on the passed parent Work Order Ids.
     * @param workOrderIds
     * @param triggerSource
     * @return Boolean
     */
    Boolean runReadinessCheckOnParentWorkOrders(Set<Id> workOrderIds, String triggerSource);

    /**
     * @description It toggles banner indicator on the passed parent Work Orders.
     * @param parentWorkOrderIds
     */
    void toggleBannerOnParentWorkOrders(Set<Id> parentWorkOrderIds);

    /**
     * @description It collects parent Work Order Ids and Updates the Child Work Orders to
     * Provisioning complete LEM-3170.
     * @param workOrderIds
     */
    void updateChildWorkOrdersStatusToProvisioningComplete(Set<Id> workOrderIds);

    /**
     * @description updates store id on the work orders associated to child accounts
     * @param storeAccountIds
     */
    void updateStoreIdsOnChildWorkOrders(Set<Id> storeAccountIds);

    /**
     * @description It is used for updating Work Order status to 'Past Due' and 'At Risk'
     * on basis of matching criteria.
     * @param workOrderRecords
     */
    void updateWorkOrderStatus(List<WorkOrder> workOrderRecords);

    /**
     * @description It is used for reverting Work Order Status to previous status value
     * (other than ‘Past Due’/‘At Risk’) based on Work Order History.
     * @param workOrders
     */
    void updateWorkOrderStatusByWorkOrderHistory(Map<Id, WorkOrder> workOrders);

    /**
     * @description It collects the Dead parent Work Order Ids and Updates the Child Work Steps to Dead
     * @param parentWorkOrderIds
     */
    void updateChildWorkStepsStatusToDead(Set<Id> parentWorkOrderIds);

    /**
     * @description updates associated accounts Id on workorder
     * @param woIdToAssociatedAccounts
     */
    void setAssociatedAccounts(Map<Id, String> woIdToAssociatedAccounts);

    /**
     * @description initiates child workorder creation on parent work order
     * @param workOrderIds
     */
    void initiateChildWorkOrderAutoCreation(Set<Id> workOrderIds);

    /**
     * @description updates last updated by mint to now
     * @param workOrderIds
     */
    void setLastUpdatedByMintToNow(Set<Id> workOrderIds);

    /**
     * @description It is used to initiate Work Plan creation for Tablet Work Order.
     * @param workOrders
     */
    void initiateTabletWorkPlanCreation(List<WorkOrder> workOrders);

    /**
     * @description It is used to initiate Store Association by publishing Photoshoot Store
     * Association Event.
     * @param workOrders
     */
    void initiateStoreAssociation(List<WorkOrder> workOrders);

    /**
     * @description It is used to update child Work Orders Provisioining Status by Marketplace
     * Work Order's Provisioning Status.
     * @JIRA# LEM-19828
     * @param workOrders
     */
    void updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
        Set<WorkOrder> workOrders
    );

    /**
     * @description It is used to set "Proposed Date of Implementation" field value on 'Storefront'
     * work orders of 'SMB' segment.
     * @JIRA# LEM-25334
     * @param workOrders
     */
    void setProposedDateofImplementationOnSMBStorefrontWorkOrders(List<WorkOrder> workOrders);

    /**
     * @description It is used to update the work order status to "Dead" by the passed business
     * account ids.
     * @param uow
     * @param businessAccountIds
     * @return fflib_ISObjectUnitOfWork
     */
    fflib_ISObjectUnitOfWork updateChurnedMxWorkOrderToDead(
        fflib_ISObjectUnitOfWork uow,
        Set<Id> businessAccountIds
    );
}