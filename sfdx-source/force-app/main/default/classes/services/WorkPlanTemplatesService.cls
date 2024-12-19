/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Service class for WorkPlanTemplate related logic.
 */
public inherited sharing class WorkPlanTemplatesService {
    /**
     * @description Create WorkPlans for the passed list of WorkOrders using
     * the matching WorkPlanTemplate types.
     * @param workOrdersToCreateWorkPlans
     */
    public static void createWorkPlansOnWorkOrdersByMatchingCriteria(
        List<WorkOrder> workOrdersToCreateWorkPlans
    ) {
        service().createWorkPlansOnWorkOrdersByMatchingCriteria(workOrdersToCreateWorkPlans);
    }

    /**
     * @description Create Work Plans on the passed Work Order by
     * re-evaluating criteria using the passed Work Plan types.
     * @JIRA# LEM-1956
     * @param workOrderToReevaluateWorkPlans
     * @param workOrderIdToWorkPlanTypes
     */
    public static void createWorkPlansOnWorkOrdersByReevaluatingCriteria(
        List<WorkOrder> workOrderToReevaluateWorkPlans,
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes
    ) {
        service()
            .createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                workOrderToReevaluateWorkPlans,
                workOrderIdToWorkPlanTypes
            );
    }

    /**
     * @description It creates instance of WorkPlanTemplatesServiceImpl class.
     * @return IWorkPlanTemplatesService - instance of WorkPlanTemplatesServiceImpl
     */
    private static IWorkPlanTemplatesService service() {
        return (IWorkPlanTemplatesService) Application.Service.newInstance(
            IWorkPlanTemplatesService.class
        );
    }
}