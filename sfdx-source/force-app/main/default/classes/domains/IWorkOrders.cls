/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Interface to add domain class methods
 */
public interface IWorkOrders extends fflib_ISObjects {
    /**
     * @description It validate and update Work Order fields on Before Insert trigger event.
     */
    void onBeforeInsertValidateAndUpdateWorkOrderFields();

    /**
     * @description It validate and update Work Order fields on Before Update trigger event.
     * @param oldWorkOrders - The map of old Work Orders
     */
    void onBeforeUpdateValidateAndUpdateWorkOrderFields(Map<Id, WorkOrder> oldWorkOrders);

    /**
     * @description It validate and update Work Order fields on after Update trigger event.
     * @param existingRecords - The map of old Work Orders
     */
    void updateStatusOnPDOAOrPDOTChange(Map<Id, SObject> existingRecords);

    /**
     * @description It collects child Work Order records with updated parent Work Order Id.
     * @param oldWorkOrders
     */
    void collectChildWorkOrdersWithUpdatedParentWorkOrderId(Map<Id, WorkOrder> oldWorkOrders);

    /**
     * @description It collects parent Work Order Ids from child Work Order for the given topic.
     * @param childWorkOrders
     * @param eventTopic
     */
    void collectParentWorkOrderIds(List<WorkOrder> childWorkOrders, String eventTopic);

    /**
     * @description It collects Dead parent Work Order Ids and update the Child WorkSteps To Dead
     * @param workOrders
     */
    void updateChildWorkStepsStatusToDead(List<WorkOrder> workOrders);

    /**
     * @description It collects child Work Order Ids from parent Work Order for the given topic.
     * @param parentWorkOrders
     */
    void collectParentWorkOrdersWithUpdatedInformation(List<WorkOrder> parentWorkOrders);

    /**
     * @description It populates Franchise Work Order Owner as Franchise Rep of the Corporate account
     */
    void populateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders();

    /**
     * @description It is used to trigger Readiness Check on parent Work Orders.
     * @param existingRecords
     */
    void runReadinessCheckOnParentWorkOrders(Map<Id, SObject> existingRecords);
}