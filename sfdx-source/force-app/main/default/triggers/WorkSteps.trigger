/**
 * @author Deloitte
 * @date 11/04/2022
 * @description Trigger on WorkStep object.
 */
trigger WorkSteps on WorkStep(after insert, after update, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
}