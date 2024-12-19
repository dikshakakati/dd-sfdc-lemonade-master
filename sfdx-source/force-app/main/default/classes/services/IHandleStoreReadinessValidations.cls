/**
 * @author Deloitte
 * @date 07/11/2022
 * @description Interface used for dynamically calling service class related to a validation.
 * It needs to be implemented by every service class that requires to validate the object related to
 * store readiness validations.
 */
public interface IHandleStoreReadinessValidations {
    /**
     * @description It allows to pass validation rules to the service class
     * corresponding to the object.
     *  @jira LEM-13963
     * @param childWorkOrders
     * @param parentWorkOrders
     * @param storeReadinessValidationRules
     * @param existingReadinessCheckFailures //* @jira LEM-13963
     * @param objectName //* @jira LEM-13963
     */
    void validate(
        List<WorkOrder> childWorkOrders,
        List<WorkOrder> parentWorkOrders,
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules,
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures,
        String objectName
    );
}