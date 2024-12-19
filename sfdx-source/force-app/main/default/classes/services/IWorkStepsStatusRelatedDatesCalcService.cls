/**
 * @author Deloitte
 * @date 23/05/2022
 * @description Interface for service class to calculate and update the value of date fields
 * used for tracking WorkStep Status changes.
 */
public interface IWorkStepsStatusRelatedDatesCalcService {
    /**
     * @description It is used to calculate and update the value of date fields
     * used for tracking WorkStep Status changes.
     * @param newWorkSteps
     * @param oldWorkSteps
     */
    void updateAssociatedDateTrackingFieldsOnStatusChange(
        List<WorkStep> newWorkSteps,
        Map<Id, WorkStep> oldWorkSteps
    );
}