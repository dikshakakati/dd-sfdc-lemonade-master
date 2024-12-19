/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Service interface for WorkPlanTemplate related logic.
 */
public interface IWorkPlanTemplatesService {
    /**
     * @description Create WorkPlans for the passed list of WorkOrders using
     * the matching WorkPlanTemplate types.
     * @param workOrdersToCreateWorkPlans
     */
    void createWorkPlansOnWorkOrdersByMatchingCriteria(List<WorkOrder> workOrdersToCreateWorkPlans);

    /**
     * @description Create Work Plans on the passed Work Order by
     * re-evaluating criteria using the passed Work Plan types.
     * @param workOrderToReevaluateWorkPlans
     * @param workOrderIdToWorkPlanTypes
     */
    void createWorkPlansOnWorkOrdersByReevaluatingCriteria(
        List<WorkOrder> workOrderToReevaluateWorkPlans,
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes
    );
}