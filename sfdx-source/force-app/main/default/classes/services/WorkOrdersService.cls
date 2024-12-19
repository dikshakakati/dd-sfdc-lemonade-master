/**
 * @author Deloitte
 * @date 15/04/2022
 * @description Service class for WorkOrder related logic.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class WorkOrdersService implements IHandleNotifierEvents {
    /**
     * @description - Calling Selector Framework
     * @JIRA# LEM-985
     * @param sObjectType
     * @return IWorkOrdersSelector
     */
    private static IWorkOrdersSelector selector(SObjectType sObjectType) {
        return (IWorkOrdersSelector) Application.SELECTOR.newInstance(sObjectType);
    }

    /**
     * @description - Calling Unit Of Work Framework
     * @JIRA# LEM-985
     * @return IWorkOrdersService
     */
    private static IWorkOrdersService service() {
        return (IWorkOrdersService) Application.SERVICE.newInstance(IWorkOrdersService.class);
    }

    /**
     * @description It is used to initiate Store Association by publishing Photoshoot Store
     * Association Event.
     * @param photoshootWorkOrders
     */
    public static void initiateStoreAssociation(List<WorkOrder> photoshootWorkOrders) {
        service().initiateStoreAssociation(photoshootWorkOrders);
    }

    /**
     * @description It is used to initiate Work Plan creation for Tablet Work Order.
     * @param workOrders
     */
    public static void initiateTabletWorkPlanCreation(List<WorkOrder> workOrders) {
        service().initiateTabletWorkPlanCreation(workOrders);
    }

    /**
     * @description It associates Contracts to parent Work Orders based on the
     * passed Account and Contract Id mappings.
     * @JIRA# LEM-4005
     * @param parentAccountIdtoContractId
     */
    public static void associateContractsOnParentWorkOrders(
        Map<Id, Id> parentAccountIdtoContractId
    ) {
        service().associateContractsOnParentWorkOrders(parentAccountIdtoContractId);
    }

    /**
     * @description It filters Opportunities without any associated parent Work Order.
     * @JIRA# LEM-2132
     * @param opportunities
     * @return List<Opportunity>
     */
    public static List<Opportunity> collectOpportunitiesWithoutWorkOrder(
        List<Opportunity> opportunities
    ) {
        return service().collectOpportunitiesWithoutWorkOrder(opportunities);
    }

    /**
     * @description It is used for getting parent Work Order Ids from the payload received via Platform Event.
     * @JIRA# LEM-955
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for each Parent
     * Work Order with child Store Account Work Orders
     * @JIRA# LEM-2304
     * @param workOrderIds
     */
    public static void generateProvisioningEventForWorkOrders(Set<Id> workOrderIds) {
        service().generateProvisioningEventForWorkOrders(workOrderIds);
    }
    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for
     * Drive WorkOrder Types
     * @JIRA# LEM-2703
     * @param workOrderIds
     */
    public static void generateProvisioningEventForDriveWorkOrders(Set<Id> workOrderIds) {
        service().generateProvisioningEventForDriveWorkOrders(workOrderIds);
    }

    /**
     * @description - generates Provisioning Platform Events (Provisioning_Event__e) for COO work orders
     * @JIRA# LEM-3373
     * @param workOrderIds
     */
    public static void generateProvisioningEventForCOOWorkOrders(Set<Id> workOrderIds) {
        service().generateProvisioningEventForCOOWorkOrders(workOrderIds);
    }

    /**
     * @description - Method is being used to get WorkOrder records(Applicablefor Trigger events)
     * @JIRA# LEM-985
     * @return List<WorkOrder>
     */
    public static List<WorkOrder> getWorkOrderRecordsForUpdateStatus() {
        return selector(WorkOrder.SObjectType).getWorkOrderRecordsForUpdateStatus();
    }

    /**
     * @description - Method is being used to get WorkOrder records(Applicable only for Batch job)
     * @JIRA# LEM-985
     * @return Database.QueryLocator
     */
    public static Database.QueryLocator getWorkOrderRecordsForUpdateStatusFromBatch() {
        return selector(WorkOrder.SObjectType).getWorkOrderRecordsForUpdateStatusFromBatch();
    }

    /**
     * @description It is used for getting updated Work Order Status
     * on basis of PDOA/PDOM/PDOT date criteria.
     * @JIRA# LEM-985 & LEM-1011
     * @param workOrderRecord
     * @return String
     */
    public static String getWorkStatusUpdatedValue(WorkOrder workOrderRecord) {
        return service().getWorkStatusUpdatedValue(workOrderRecord);
    }

    /**
     * @description It initiates Work Plans creation on the passed Work Orders Ids.
     * @param workOrderIds
     * @param changeType
     */
    public static void initiateWorkPlansCreation(Set<Id> workOrderIds, String changeType) {
        service().initiateWorkPlansCreation(workOrderIds, changeType);
    }

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It triggers actual number of stores and account owner email updates
     * on basis of the passed Work Orders.
     * @JIRA# LEM-3643
     * @param workOrders
     */
    public static void processMergedAccountsRelatedRecords(List<WorkOrder> workOrders) {
        service().processMergedAccountsRelatedRecords(workOrders);
    }

    /**
     * @description It cleans up the existing business Account readiness check failures and trigger
     * readiness check on the passed child Work Order Ids.
     * @JIRA LEM-2455
     * @param workOrderIds
     */
    public static void runReadinessCheckOnChildWorkOrders(Set<Id> workOrderIds) {
        service().runReadinessCheckOnChildWorkOrders(workOrderIds);
    }

    /**
     * @description It cleans up the existing business Account readiness check failures and trigger
     * readiness check on the passed parent Work Order Ids.
     * @JIRA LEM-2455
     * @param workOrderIds
     * @param triggerSource
     * @return Boolean
     */
    public static Boolean runReadinessCheckOnParentWorkOrders(
        Set<Id> workOrderIds,
        String triggerSource
    ) {
        return service().runReadinessCheckOnParentWorkOrders(workOrderIds, triggerSource);
    }

    /**
     * @description It toggles banner indicator on the passed parent Work Orders.
     * @param parentWorkOrderIds
     */
    public static void toggleBannerOnParentWorkOrders(Set<Id> parentWorkOrderIds) {
        service().toggleBannerOnParentWorkOrders(parentWorkOrderIds);
    }

    /**
     * @description Get the Child work orders from Parent WorkOrder and Update the status to
     * Provisioning complete
     * @JIRA# LEM-3170
     * @param workOrderIds
     */
    public static void updateChildWorkOrdersStatusToProvisioningComplete(Set<Id> workOrderIds) {
        service().updateChildWorkOrdersStatusToProvisioningComplete(workOrderIds);
    }

    /**
     * @description updates store id on the work orders associated to child accounts
     * @param storeAccountIds
     */
    public static void updateStoreIdsOnChildWorkOrders(Set<Id> storeAccountIds) {
        service().updateStoreIdsOnChildWorkOrders(storeAccountIds);
    }

    /**
     * @description It is used for updating Work Order status to 'Past Due' and 'At Risk'
     * on basis of matching criteria.
     * @JIRA# LEM-985
     * @param workOrders
     */
    public static void updateWorkOrderStatus(List<WorkOrder> workOrders) {
        service().updateWorkOrderStatus(workOrders);
    }

    /**
     * @description It is used for reverting Work Order Status to previous status value
     * (other than ‘Past Due’/‘At Risk’) based on Work Order History.
     * @JIRA# LEM-5159
     * @param workOrders
     */
    public static void updateWorkOrderStatusByWorkOrderHistory(Map<Id, WorkOrder> workOrders) {
        service().updateWorkOrderStatusByWorkOrderHistory(workOrders);
    }

    /**
     * @description @description It collects the Dead parent Work Order Ids and Updates the Child Work Steps to Dead
     * @JIRA# LEM-5460
     * @param parentWorkOrderIds
     */
    public static void updateChildWorkStepsStatusToDead(Set<Id> parentWorkOrderIds) {
        service().updateChildWorkStepsStatusToDead(parentWorkOrderIds);
    }

    /**
     * @description updates associated accounts Id on workorder
     * @param woIdToAssociatedAccounts
     */
    public static void setAssociatedAccounts(Map<Id, String> woIdToAssociatedAccounts) {
        service().setAssociatedAccounts(woIdToAssociatedAccounts);
    }

    /**
     * @description initiates child workorder creation on parent work order
     * @param workOrderIds
     */
    public static void initiateChildWorkOrderAutoCreation(Set<Id> workOrderIds) {
        service().initiateChildWorkOrderAutoCreation(workOrderIds);
    }

    /**
     * @description update the workorder Last_Updated_By_MINT__c to now
     * @param workOrderIds
     */
    public static void setLastUpdatedByMintToNow(Set<Id> workOrderIds) {
        service().setLastUpdatedByMintToNow(workOrderIds);
    }

    /**
     * @description It is used to update child Work Orders Provisioining Status by Marketplace
     * Work Order's Provisioning Status.
     * @JIRA# LEM-19828
     * @param workOrders
     */
    public static void updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
        Set<WorkOrder> workOrders
    ) {
        service().updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(workOrders);
    }

    /**
     * @description It is used to set "Proposed Date of Implementation" field value on 'Storefront'
     * work orders of 'SMB' segment.
     * @JIRA# LEM-25334
     * @param workOrders
     */
    public static void setProposedDateofImplementationOnSMBStorefrontWorkOrders(
        List<WorkOrder> workOrders
    ) {
        service().setProposedDateofImplementationOnSMBStorefrontWorkOrders(workOrders);
    }

    /**
     * @description It is used to update the work order status to "Dead" by the passed business
     * account ids.
     * @JIRA# LEM-23780
     * @param uow
     * @param businessAccountIds
     * @return fflib_ISObjectUnitOfWork
     */
    public static fflib_ISObjectUnitOfWork updateChurnedMxWorkOrderToDead(
        fflib_ISObjectUnitOfWork uow,
        Set<Id> businessAccountIds
    ) {
        return service().updateChurnedMxWorkOrderToDead(uow, businessAccountIds);
    }
}