/**
 * @author            : Aetherues
 * @group             :
 * @last modified on  : 05-09-2024
 * @description Interface for service class for readiness Message related logic.
**/
public interface IStoreReadinessModificationService {
    /**
     * @description It is used to collect store readiness validation rules
     * and child Work Orders to perform readiness check on stores associated with
     * the passed Work Order Ids and existingReadinessCheckfailures.
     * @jira LEM-13963
     * @param existingReadinessCheckFailures
     * @param newReadinessCheckFailures
     * @param sObjectName
     * @param className
     */
    void processReadinessCheckFailures(List<Readiness_Check_Failure__c> existingReadinessCheckFailures,List<Readiness_Check_Failure__c> newReadinessCheckFailures,String sObjectName, String className);
}