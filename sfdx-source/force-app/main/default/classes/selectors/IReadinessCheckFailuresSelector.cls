/**
 * @author Deloitte
 * @date 19/07/2022
 * @description Interface for ReadinessCheckFailuresSelector class methods.
 */
public interface IReadinessCheckFailuresSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting count of Readiness Check Failures filtered by passed
     * WorkOrder Ids and grouped by passed WorkOrder Ids.
     * @param workOrderIds
     * @return Aggregate[]
     */
    Aggregate[] getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It queries Readiness Check Failures by the passed child WorkOrder Ids.
     * @param workOrderIds
     * @return List<Readiness_Check_Failure__c>
     */
    List<Readiness_Check_Failure__c> selectByChildWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It queries Readiness Check Failures by the passed parent WorkOrder Ids.
     * @param parentWorkOrderIds
     * @return List<Readiness_Check_Failure__c>
     */
    List<Readiness_Check_Failure__c> selectByParentWorkOrderIds(Set<Id> parentWorkOrderIds);

    /**
     * @description It is used to get the Readiness Check Failure Record.
     * Status is equal to Resolved and createddate less than week.
     * @JIRA# LEM-13963
     * @return List<Readiness_Check_Failure__c>
     */
    List<Readiness_Check_Failure__c> selectByReadinessCheckFailureId();
}