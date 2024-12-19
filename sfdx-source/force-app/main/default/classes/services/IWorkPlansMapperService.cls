/**
 * @author Deloitte
 * @date 07/04/2022
 * @description Interface of service implementation class for WorkPlansMapper related logic.
 */
public interface IWorkPlansMapperService {
    /**
     * @description It is used to call WorkPlanMapper method for collecting
     * WorkPlan types matching criteria for WorkOrders.
     * @param workOrderIds
     * @return Map<Id, Set<String>>
     */
    Map<Id, Set<String>> collectMatchingWorkPlanTypes(List<String> workOrderIds);
}