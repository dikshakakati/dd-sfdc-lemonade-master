/**
 * @author Deloitte
 * @date 18/04/2022
 * @description Trigger on WorkPlan object.
 */
trigger WorkPlans on WorkPlan(after insert, after update, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(WorkPlansHandler.class);
}