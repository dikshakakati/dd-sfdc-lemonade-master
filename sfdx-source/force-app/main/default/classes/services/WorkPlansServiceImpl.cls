/**
 * @author Deloitte
 * @date 01/06/2022
 * @description Service implementation class for WorkPlan related logic.
 */
public inherited sharing class WorkPlansServiceImpl implements IWorkPlansService {
    private static final String LOG_SERVICE_WORK_PLAN = 'Work Plans Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String ESCALATED_ACTIVATION_STATUS = 'Escalated';
    /**
     * @description It is used to get parent and child WorkPlans for Assign To Queue flow.
     * @JIRA# LEM-1536
     * @param workPlanIds
     * @return List<List<WorkPlan>>
     */
    public List<List<WorkPlan>> getParentAndChildWorkPlanDetails(List<List<String>> workPlanIds) {
        List<List<WorkPlan>> workPlans = new List<List<WorkPlan>>();
        Set<String> recordIds = new Set<String>();
        if (workPlanIds == null && workPlanIds.isEmpty()) {
            return workPlans;
        }
        for (List<String> eachWorkPlanId : workPlanIds) {
            recordIds.addAll(eachWorkPlanId);
        }
        workPlans.add(
            WorkPlansSelector.newInstance().selectWorkPlansWithChildWorkPlanDetails(recordIds)
        );
        return workPlans;
    }

    /**
     * @description It gets WorkPlan queues filtered by QueuesSobject records for AssignToQueue flow.
     * @JIRA# LEM-1970
     * @return List<List<Group>>
     */
    public List<List<Group>> getWorkPlanQueues() {
        return new List<List<Group>>{ GroupsSelector.newInstance().selectByWorkPlanQueueIds() };
    }

    /**
     * @description Update parent Activation Checklist validation status on Work Plans based on
     * passed Status value.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkPlans
     * @param validationStatus
     */
    public void updateActivationChecklistValidationStatusOnWorkPlans(
        Set<Id> activationChecklistWorkPlans,
        String validationStatus
    ) {
        if (activationChecklistWorkPlans.isEmpty()) {
            return;
        }
        List<WorkPlan> updatedWorkPlans = new List<WorkPlan>();
        for (Id eachWorkPlanId : activationChecklistWorkPlans) {
            updatedWorkPlans.add(
                new WorkPlan(
                    Id = eachWorkPlanId,
                    Activation_Checklist_Validation__c = validationStatus
                )
            );
        }
        fireUpdateOnParent(updatedWorkPlans);
    }

    /**
     * @description Update parent Activation Checklist validation status on Work Plans to Escalated.
     * @JIRA# LEM-14272
     * @param workSteps
     */
    public void escalateActivationChecklistValidationOnWorkPlan(List<WorkStep> workSteps) {
        Set<Id> newWorkPlanIds = new Set<Id>();
        for (WorkStep eachWorkStep : workSteps) {
            newWorkPlanIds.add(eachWorkStep.WorkPlanId);
        }
        updateActivationChecklistValidationStatusOnWorkPlans(
            newWorkPlanIds,
            ESCALATED_ACTIVATION_STATUS
        );
    }

    /**
     * @description It fires UPDATE DML statement on Parent records.
     * @param sObjectsToUpdate
     */
    private void fireUpdateOnParent(List<sObject> sObjectsToUpdate) {
        if (sObjectsToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowParentObjectUpdate = Application.UNITOFWORK.newInstance();
        uowParentObjectUpdate.registerDirty(sObjectsToUpdate);
        try {
            uowParentObjectUpdate.commitWork();
        } catch (Exception parentObjectUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(parentObjectUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_PLAN,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(parentObjectUpdateException)
            );
        }
    }

    /**
     * @description It gets WorkOrders related to passed WorkPlan Ids.
     * @JIRA# LEM-13484
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> getWorkOrdersFromWorkPlan(Set<Id> workPlanIds) {
        return WorkPlansSelector.newInstance().selectWorkPlansWithWorkOrderDetails(workPlanIds);
    }
}