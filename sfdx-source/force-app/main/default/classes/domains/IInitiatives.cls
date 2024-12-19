/**
 * @author Deloitte
 * @date 28/04/2022
 * @description Interface to add Initiative Domain Class methods
 */
public interface IInitiatives extends fflib_ISObjects {
    /**
     * @description It restricts status update on Mx Touchpoint records if there are no
     * Stakeholder contacts associated.
     */
    void addErrorOnCompleteMxTouchpointsWithoutStakeholders();

    /**
     * @description Fetches the Ultimate Parent on the Parent Account of
     *              each Initiative and updates the lookup on the current
     *              Initiative Record
     */
    void populateUltimateParentAccount();

    /**
     * @description It creates the Tasks for the 'Complete' Mx Touchpoint records.
     */
    void createTaskOnCompleteMxTouchpoints();
}