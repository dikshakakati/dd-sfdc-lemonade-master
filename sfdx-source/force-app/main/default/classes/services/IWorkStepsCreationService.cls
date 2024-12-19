/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Interface for service class of WorkSteps creation logic.
 */
public interface IWorkStepsCreationService {
    /**
     * @description It triggers creation of WorkSteps from WorkPlanTemplates
     * and associated WorkPlanTemplateEntries after creation of WorkPlans.
     * @param workPlans
     * @param workPlanTemplateIds
     */
    void createWorkStepsOnWorkPlans(List<WorkPlan> workPlans, Set<Id> workPlanTemplateIds);
}