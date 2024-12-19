/**
 * @author Deloitte
 * @date 07/04/2022
 * @description Service class for WorkPlansMapper related logic.
 */
public inherited sharing class WorkPlansMapperService {
    /**
     * @description It is used to call WorkPlanMapper method for collecting
     * WorkPlan types matching criteria for WorkOrders.
     * @param workOrderIds
     * @return Map<Id, Set<String>>
     */
    public static Map<Id, Set<String>> collectMatchingWorkPlanTypes(List<String> workOrderIds) {
        return service().collectMatchingWorkPlanTypes(workOrderIds);
    }

    /**
     * @description It is used to create an instance of WorkPlansMapperService class.
     * @return IWorkPlansMapperService
     */
    private static IWorkPlansMapperService service() {
        return (IWorkPlansMapperService) Application.SERVICE.newInstance(
            IWorkPlansMapperService.class
        );
    }
}