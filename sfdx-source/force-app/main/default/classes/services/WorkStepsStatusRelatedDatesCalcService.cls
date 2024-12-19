/**
 * @author Deloitte
 * @date 23/05/2022
 * @description Service class to calculate and update the value of date fields used for tracking WorkStep Status changes.
 */
public inherited sharing class WorkStepsStatusRelatedDatesCalcService {
    /**
     * @description It is used to calculate and update the value of date fields used for tracking WorkStep Status changes.
     * @JIRA# LEM-1489
     * @param newWorkSteps
     * @param oldWorkSteps
     */
    public static void updateAssociatedDateTrackingFieldsOnStatusChange(
        List<WorkStep> newWorkSteps,
        Map<Id, WorkStep> oldWorkSteps
    ) {
        service().updateAssociatedDateTrackingFieldsOnStatusChange(newWorkSteps, oldWorkSteps);
    }

    /**
     * @description It creates instance of WorkStepsStatusRelatedDatesCalcSrvcImpl class.
     * @return IWorkStepsStatusRelatedDatesCalcService -
     * return instance of WorkStepsStatusRelatedDatesCalcSrvcImpl
     */
    private static IWorkStepsStatusRelatedDatesCalcService service() {
        return (IWorkStepsStatusRelatedDatesCalcService) Application.Service.newInstance(
            IWorkStepsStatusRelatedDatesCalcService.class
        );
    }
}