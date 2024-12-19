/**
 * @author Deloitte
 * @date 03/16/2023
 * @description Interface for WorkOrderHistory selector class methods.
 */
public interface IWorkOrderHistorySelector extends fflib_ISObjectSelector {
    /**
     * @description It queries Work Order History records having Status field’s history
     * using the passed Work Order Ids.
     * @param workOrderIds
     * @return List<WorkOrderHistory>
     */
    List<WorkOrderHistory> selectStatusHistoryByWorkOrderIds(Set<Id> workOrderIds);
}