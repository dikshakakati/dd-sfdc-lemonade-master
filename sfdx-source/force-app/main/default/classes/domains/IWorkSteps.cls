/**
 * @author Deloitte
 * @date 30/03/2022
 * @description WorkSteps interface to add domain class methods.
 */
public interface IWorkSteps extends fflib_ISObjects {
    /**
     * @description It update Work Steps related records on After Insert trigger event.
     */
    void onAfterInsertHandleRelatedRecords();

    /**
     * @description It update Work Step related records on After Update trigger event.
     * @param oldWorkSteps - The map of old Work Steps
     */
    void onAfterUpdateHandleRelatedRecords(Map<Id, WorkStep> oldWorkSteps);

    /**
     * @description It validate and update Work Step fields on Before Insert trigger event.
     */
    void onBeforeInsertValidateAndUpdateWorkStepFields();

    /**
     * @description It validate and update Work Step fields on Before Update trigger event.
     * @param oldWorkSteps - The map of old Work Steps
     */
    void onBeforeUpdateValidateAndUpdateWorkStepFields(Map<Id, WorkStep> oldWorkSteps);
}