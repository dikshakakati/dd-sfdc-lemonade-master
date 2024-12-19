/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Selector interface to query activation checklist validation metadata.
 */
public interface IActivationChecklistValidationSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting all active Activation_Checklist_Validation__mdt records
     * having service class and method name fields populated.
     * @return List<Activation_Checklist_Validation__mdt>
     */
    List<Activation_Checklist_Validation__mdt> getAllActiveValidations();
}