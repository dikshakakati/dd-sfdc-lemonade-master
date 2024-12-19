/**
 * @author Deloitte
 * @date 06/05/2022
 * @description Interface for WorkStepDependency selector class methods.
 */
public interface IWorkStepDependenciesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting count of WorkStepDependencies filtered by
     * passed sObjectIds and grouped by passed field.
     * @param sObjectIds - Set of sObject Ids (WorkPlan/WorkStep)
     * @param fieldToFilter - Field used for filtering and grouping
     * @return Aggregate[]
     */
    Aggregate[] getWorkStepDependencyCountFilteredAndGroupedBySobjectIds(
        Set<Id> sObjectIds,
        SObjectField fieldToFilter
    );

    /**
     * @description It fetches WorkStepDependencies where Dependent_Work_Step__c is
     * in the passed set of WorkStep Ids.
     * @param sObjectIds - Set of WorkStep/WorkPlan Ids
     * @param fieldToFilter
     * @return List<WorkStepDependency__c>
     */
    List<WorkStepDependency__c> selectDependeeWorkStepsByDependentSobjectIds(
        Set<Id> sObjectIds,
        SObjectField fieldToFilter
    );

    /**
     * @description It fetches WorkStepDependencies where Dependee_WorkStep__c is
     * in passed set of WorkStep Ids.
     * @param dependeeWorkStepIds - Set of WorkStep Ids
     * @return List<WorkStepDependency__c>
     */
    List<WorkStepDependency__c> selectDependenciesByDependeeWorkStepsIds(
        Set<Id> dependeeWorkStepIds
    );

    /**
     * @description It fetches WorkStepDependencies where Dependent_WorkStep__c is
     * in passed set of WorkStep Ids.
     * @param dependentWorkStepIds - Set of WorkStep Ids
     * @return List<WorkStepDependency__c>
     */
    List<WorkStepDependency__c> selectDependenciesByDependentWorkStepsIds(
        Set<Id> dependentWorkStepIds
    );

    /**
     * @description It fetches WorkStepDependencies where Dependee_WorkStep__c's WorkOrder
     * or Dependent_Work_Step__r's WorkOrder is in the passed set of WorkOrder Ids.
     * @param workOrderIds
     * @return List<WorkStepDependency__c>
     */
    List<WorkStepDependency__c> selectDependenciesByWorkOrderIds(Set<Id> workOrderIds);
}