/**
 * @author Deloitte
 * @date 07/04/2022
 * @description Service implementation class for WorkPlansMapper related logic.
 */
public inherited sharing class WorkPlansMapperServiceImpl implements IWorkPlansMapperService {
    /**
     * @description It is used to call WorkPlanMapper method for collecting
     * WorkPlan types matching criteria for WorkOrders.
     * @param workOrderIds
     * @return Map<Id, Set<String>>
     */
    public Map<Id, Set<String>> collectMatchingWorkPlanTypes(List<String> workOrderIds) {
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        workOrderIdToWorkPlanTypes = WorkPlanMapper.getMappedWorkPlanTypes(workOrderIds);
        return workOrderIdToWorkPlanTypes;
    }
}