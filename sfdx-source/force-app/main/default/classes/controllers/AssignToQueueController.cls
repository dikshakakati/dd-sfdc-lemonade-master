/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Controller class for AssignToQueue flow.
 */
public with sharing class AssignToQueueController {
    /**
     * @description To get WorkPlan queues for AssignToQueue flow.
     * @JIRA# LEM-1970
     * @return List<List<Group>>
     */
    @InvocableMethod(
        label='Get Work Plan Queues'
        description='It gets Group records filtered by QueuesSobject records for WorkPlan object'
    )
    public static List<List<Group>> getWorkPlanQueues() {
        return WorkPlansService.getWorkPlanQueues();
    }
}