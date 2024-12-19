/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Service class for WorkSteps creation logic.
 */
public inherited sharing class WorkStepsCreationService {
    /**
     * @description It triggers creation of WorkSteps from WorkPlanTemplates
     * and associated WorkPlanTemplateEntries after creation of WorkPlans.
     * @JIRA# LEM-732 & LEM-1061
     * @param workPlans
     * @param workPlanTemplateIds
     */
    public static void createWorkStepsOnWorkPlans(
        List<WorkPlan> workPlans,
        Set<Id> workPlanTemplateIds
    ) {
        service().createWorkStepsOnWorkPlans(workPlans, workPlanTemplateIds);
    }

    /**
     * @description It creates instance of WorkStepsCreationServiceImpl class.
     * @return IWorkStepsCreationService
     */
    private static IWorkStepsCreationService service() {
        return (IWorkStepsCreationService) Application.Service.newInstance(
            IWorkStepsCreationService.class
        );
    }
}