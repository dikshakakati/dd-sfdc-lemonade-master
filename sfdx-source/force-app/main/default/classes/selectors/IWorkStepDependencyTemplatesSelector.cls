/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Interface for WorkStepDependencyTemplates selector class methods.
 */
public interface IWorkStepDependencyTemplatesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get WorkStepDependencyTemplate records
     * where passed Ids are dependent WorkPlanTemplateEntry.
     * @param dependentWorkPlanTemplateEntryIds
     * @return List<WorkStepDependencyTemplate__c>
     */
    List<WorkStepDependencyTemplate__c> selectDependeeWorkStepDependencyTemplates(
        Set<Id> dependentWorkPlanTemplateEntryIds
    );
}