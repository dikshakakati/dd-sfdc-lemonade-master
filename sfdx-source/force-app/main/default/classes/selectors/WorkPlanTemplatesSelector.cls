/**
 * @author Deloitte
 * @date 13/04/2022
 * @description Selector class for WorkPlanTemplate object.
 */
public inherited sharing class WorkPlanTemplatesSelector extends fflib_SObjectSelector implements IWorkPlanTemplatesSelector {
    /**
     * @description default constructor for the class
     * @return IWorkPlanTemplatesSelector - interface of WorkPlanTemplatesSelector
     */
    public static IWorkPlanTemplatesSelector newInstance() {
        return (IWorkPlanTemplatesSelector) Application.Selector.newInstance(
            WorkPlanTemplate.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return WorkPlanTemplate.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Plan Template object
     * @return List<Schema.SObjectField>- Work Plan Template fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkPlanTemplate.Id,
            WorkPlanTemplate.Name,
            WorkPlanTemplate.IsActive,
            WorkPlanTemplate.Type__c,
            WorkPlanTemplate.RelativeExecutionOrder,
            WorkPlanTemplate.Work_Plan_Default_Status__c
        };
    }

    /**
     * @description It is used for getting WorkPlanTemplates based on passed set of Ids.
     * @param setIds Set of WorkPlanTemplate Ids
     * @return List<WorkPlanTemplate> - list of WorkPlanTemplate records
     */
    public List<WorkPlanTemplate> selectById(Set<Id> setIds) {
        return (List<WorkPlanTemplate>) selectSObjectsById(setIds);
    }

    /**
     * @description It is used for getting active WorkPlanTemplate records
     * based on passed WorkPlan types.
     * @JIRA# LEM-1113, LEM-1874
     * @param workPlanTypes
     * @return List<WorkPlanTemplate>
     */
    public List<WorkPlanTemplate> selectByType(Set<String> workPlanTypes) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Type__c != null AND Type__c IN :workPlanTypes AND IsActive = true');
        return (List<WorkPlanTemplate>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries WorkPlanTemplates with related WorkPlanTemplateEntries.
     * @JIRA# LEM-732
     * @param workPlanTemplateIds
     * @return List<WorkPlanTemplate>
     */
    public List<WorkPlanTemplate> selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
        Set<Id> workPlanTemplateIds
    ) {
        fflib_QueryFactory workPlanTemplateQuery = newQueryFactory(false)
            .selectField('Id')
            .setCondition('Id IN :workPlanTemplateIds');
        WorkPlanTemplateEntriesSelector workPlanTemplateEntriesSelector = new WorkPlanTemplateEntriesSelector();
        // LEM-1061: Added to ignore CRUD check while querying WorkPlanTemplateEntry object.
        workPlanTemplateEntriesSelector.ignoreCRUD();
        workPlanTemplateEntriesSelector.addQueryFactorySubselect(
                workPlanTemplateQuery,
                'WorkStepTemplates'
            )
            .selectField('WorkStepTemplate.Name')
            .selectField('WorkStepTemplate.IsActive')
            .setCondition('WorkStepTemplate.IsActive = true AND Active__c = true')
            .setOrdering('ExecutionOrder', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkPlanTemplate>) Database.query(workPlanTemplateQuery.toSOQL());
    }
}