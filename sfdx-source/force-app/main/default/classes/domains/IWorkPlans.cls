/**
 * @author Deloitte
 * @date 18/04/2022
 * @description WorkPlans interface to add domain class methods.
 */
public interface IWorkPlans extends fflib_ISObjects {
    /**
     * @description It update Work Plan related records on After Insert trigger event.
     */
    void onAfterInsertHandleRelatedRecords();

    /**
     * @description It updates Work Plan related records on After Update trigger event.
     * @param oldWorkPlans - The map of old Work Plans
     */
    void onAfterUpdateHandleRelatedRecords(Map<Id, WorkPlan> oldWorkPlans);

    /**
     * @description It validates and update Work Plan fields on Before Update trigger event.
     * @param oldWorkPlans - The map of old Work Plans
     */
    void onBeforeUpdateValidateAndUpdateWorkPlanFields(Map<Id, WorkPlan> oldWorkPlans);

    /**
     * @description It collects child Work Plan Ids from parent Work Plan for the given topic.
     * @param parentWorkPlans
     */
    void collectParentWorkPlansWithUpdatedInformation(List<WorkPlan> parentWorkPlans);

    /**
     * @description It validates Work Plan fields on After Update trigger event for Marketing
     * Kit WorkOrder creation.
     * @JIRA# LEM-13484
     */
    void evaluateAndInitiateMarketingKitWorkOrderCreation();
}