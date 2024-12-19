/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Interface for store readiness validations related logic.
 */
public interface IStoreReadinessCheckService {
    /**
     * @description It is used to collect store readiness validation rules
     * and child Work Orders to perform readiness check on stores associated with
     * the passed Work Order Ids and existingReadinessCheckfailures .
     * @jira LEM-13963
     * @param workOrderIds
     * @param existingReadinessCheckFailures
     */
    void runReadinessCheckOnWorkOrders(Set<Id> workOrderIds,List<Readiness_Check_Failure__c> existingReadinessCheckFailures);
}