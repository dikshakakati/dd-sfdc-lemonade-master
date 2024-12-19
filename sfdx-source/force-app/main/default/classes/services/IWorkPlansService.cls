/**
 * @author Deloitte
 * @date 01/06/2022
 * @description Interface of service class for WorkPlan related logic.
 */
public interface IWorkPlansService {
    /**
     * @description It is used to get parent and child WorkPlans for Assign To Queue flow.
     * @param workPlanIds
     * @return List<List<WorkPlan>>
     */
    List<List<WorkPlan>> getParentAndChildWorkPlanDetails(List<List<String>> workPlanIds);

    /**
     * @description It gets WorkPlan queues filtered by QueuesSobject records for AssignToQueue flow.
     * @return List<List<Group>>
     */
    List<List<Group>> getWorkPlanQueues();

    /**
     * @description Update parent Activation Checklist validation status on Work Plans based on
     * passed Status value.
     * @param activationChecklistWorkPlans
     * @param validationStatus
     */
    void updateActivationChecklistValidationStatusOnWorkPlans(
        Set<Id> activationChecklistWorkPlans,
        String validationStatus
    );

    /**
     * @description Update parent Activation Checklist validation status on Work Plans to Escalated.
     * @param workSteps
     */
    void escalateActivationChecklistValidationOnWorkPlan(List<WorkStep> workSteps);

    /**
     * @description It gets WorkOrders related to passed WorkPlan Ids.
     * @JIRA# LEM-13484
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> getWorkOrdersFromWorkPlan(Set<Id> workPlanIds);
}