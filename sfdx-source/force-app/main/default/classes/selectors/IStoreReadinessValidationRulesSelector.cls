/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Interface for Store_Readiness_Validation_Rule__mdt custom metadata selector.
 */
public interface IStoreReadinessValidationRulesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting all active Store_Readiness_Validation_Rule__mdt records
     * having service class and method name fields populated.
     * @return List<Store_Readiness_Validation_Rule__mdt>
     */
    List<Store_Readiness_Validation_Rule__mdt> selectAllValidReadinessValidationRules();
}