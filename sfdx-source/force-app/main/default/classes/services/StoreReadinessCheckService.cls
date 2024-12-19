/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Service class for store readiness validations related logic.
 */
public inherited sharing class StoreReadinessCheckService {
    /**
     * @description It is used to collect store readiness validation rules
     * and child Work Orders to perform readiness check on stores associated with
     * the passed Work Order Ids.
     * @jira LEM-13963
     * @param workOrderIds
     * @param existingReadinessCheckFailures
     */
    public static void runReadinessCheckOnWorkOrders(Set<Id> workOrderIds,List<Readiness_Check_Failure__c> existingReadinessCheckFailures) {
        service().runReadinessCheckOnWorkOrders(workOrderIds,existingReadinessCheckFailures);
    }

    /**
     * @description It creates instance of StoreReadinessCheckServiceImpl class.
     * @return IStoreReadinessCheckService - instance of StoreReadinessCheckServiceImpl
     */
    private static IStoreReadinessCheckService service() {
        return (IStoreReadinessCheckService) Application.Service.newInstance(
            IStoreReadinessCheckService.class
        );
    }
}