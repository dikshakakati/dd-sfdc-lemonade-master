/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Selector class for WorkStepDependencyTemplate object.
 */
public inherited sharing class WorkStepDependencyTemplatesSelector extends fflib_SObjectSelector implements IWorkStepDependencyTemplatesSelector {
    /**
     * @description Default constructor for the WorkStepDependencyTemplates selector class.
     * @return IWorkStepDependencyTemplatesSelector
     */
    public static IWorkStepDependencyTemplatesSelector newInstance() {
        return (IWorkStepDependencyTemplatesSelector) Application.Selector.newInstance(
            WorkStepDependencyTemplate__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on WorkStepDependencyTemplate object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkStepDependencyTemplate__c.Id,
            WorkStepDependencyTemplate__c.Dependee_Work_Plan_Template_Entry__c,
            WorkStepDependencyTemplate__c.Dependent_Work_Plan_Template_Entry__c,
            WorkStepDependencyTemplate__c.Is_Active__c
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkStepDependencyTemplate__c.SObjectType;
    }

    /**
     * @description It is used to get WorkStepDependencyTemplate records
     * where passed Ids are dependent WorkPlanTemplateEntry.
     * @JIRA# LEM-1061
     * @param dependentWorkPlanTemplateEntryIds
     * @return List<WorkStepDependencyTemplate__c>
     */
    public List<WorkStepDependencyTemplate__c> selectDependeeWorkStepDependencyTemplates(
        Set<Id> dependentWorkPlanTemplateEntryIds
    ) {
        fflib_QueryFactory workStepDependencyTemplateQuery = newQueryFactory()
            .setCondition(
                'Is_Active__c = true' +
                ' AND Dependent_Work_Plan_Template_Entry__c IN :dependentWorkPlanTemplateEntryIds'
            );
        return (List<WorkStepDependencyTemplate__c>) Database.query(
            workStepDependencyTemplateQuery.toSOQL()
        );
    }
}