/**
 * @author Deloitte
 * @date 30/05/2022
 * @description Service class for WorkPlan related logic.
 */
public inherited sharing class WorkPlansService {
    /**
     * @description It is used to get parent and child WorkPlans for Assign To Queue flow.
     * @JIRA# LEM-1536
     * @param workPlanIds
     * @return List<List<WorkPlan>>
     */
    @InvocableMethod(
        label='Get Work Plans'
        description='Get parent and child Work Plan for selected Work Plan Ids'
    )
    public static List<List<WorkPlan>> selectWorkPlansWithChildWorkPlanDetails(
        List<List<String>> workPlanIds
    ) {
        return service().getParentAndChildWorkPlanDetails(workPlanIds);
    }

    /**
     * @description It gets WorkPlan queues filtered by QueuesSobject records for AssignToQueue flow.
     * @JIRA# LEM-1970
     * @return List<List<Group>>
     */
    public static List<List<Group>> getWorkPlanQueues() {
        return service().getWorkPlanQueues();
    }

    /**
     * @description Update parent Activation Checklist validation status on Work Plans based on
     * passed Status value.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkPlans
     * @param validationStatus
     */
    public static void updateActivationChecklistValidationStatusOnWorkPlans(
        Set<Id> activationChecklistWorkPlans,
        String validationStatus
    ) {
        service()
            .updateActivationChecklistValidationStatusOnWorkPlans(
                activationChecklistWorkPlans,
                validationStatus
            );
    }

    /**
     * @description Update parent Activation Checklist validation status on Work Plans to Escalated.
     * @param workSteps
     */
    public static void escalateActivationChecklistValidationOnWorkPlan(List<WorkStep> workSteps) {
        service().escalateActivationChecklistValidationOnWorkPlan(workSteps);
    }

    /**
     * @description It gets WorkOrders related to passed WorkPlan Ids.
     * @JIRA# LEM-13484
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public static List<WorkPlan> getWorkOrdersFromWorkPlan(Set<Id> workPlanIds) {
        return service().getWorkOrdersFromWorkPlan(workPlanIds);
    }

    /**
     * @description It creates instance of WorkPlansServiceImpl class.
     * @return IWorkPlansService - return instance of WorkPlansServiceImpl
     */
    private static IWorkPlansService service() {
        return (IWorkPlansService) Application.SERVICE.newInstance(IWorkPlansService.class);
    }
}