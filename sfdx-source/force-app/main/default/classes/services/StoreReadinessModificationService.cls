/**
 * @author            : Aethereus
 * @group             :
 * @last modified on  : 05-09-2024
 * @description Service class for readiness Message related logic.
**/
public inherited sharing class StoreReadinessModificationService {

    private static final String LOG_SERVICE_READINESS_CHECK = 'Readiness Check';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    /**
     * @description It is used to collect store readiness validation rules
     * and child Work Orders to perform readiness check on stores associated with
     * the passed Work Order Ids.
     * @jira LEM-13963
     * @param existingReadinessCheckFailures
     * @param newReadinessCheckFailures
     * @param sObjectName
     * @param className
     */
    public static void processReadinessCheckFailures(List<Readiness_Check_Failure__c> existingReadinessCheckFailures,List<Readiness_Check_Failure__c> newReadinessCheckFailures,String sObjectName, String className) {
        service().processReadinessCheckFailures(existingReadinessCheckFailures,newReadinessCheckFailures,sObjectName,className);
    }

    /**
     * @description It creates instance of StoreReadinessModificationServiceImpl class.
     * @return IStoreReadinessModificationService - instance of StoreReadinessModificationServiceImpl
     */
    private static IStoreReadinessModificationService service() {
        return (IStoreReadinessModificationService) Application.Service.newInstance(
            IStoreReadinessModificationService.class
        );
    }
}