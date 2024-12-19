/**
 * @author Deloitte
 * @date 11/04/2022
 * @description Selector class for WorkPlanTemplateEntry object.
 */
public inherited sharing class WorkPlanTemplateEntriesSelector extends fflib_SObjectSelector implements IWorkPlanTemplateEntriesSelector {
    /**
     * @description Default constructor for the WorkPlanTemplateEntries selector class
     * @return IWorkPlanTemplateEntriesSelector - interface of IWorkPlanTemplateEntriesSelector
     */
    public static IWorkPlanTemplateEntriesSelector newInstance() {
        return (IWorkPlanTemplateEntriesSelector) Application.Selector.newInstance(
            WorkPlanTemplateEntry.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on WorkPlanTemplateEntry object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkPlanTemplateEntry.Id,
            WorkPlanTemplateEntry.Active__c,
            WorkPlanTemplateEntry.WorkPlanTemplateEntryNumber,
            WorkPlanTemplateEntry.ExecutionOrder,
            WorkPlanTemplateEntry.WorkPlanTemplateId,
            WorkPlanTemplateEntry.WorkStepTemplateId,
            WorkPlanTemplateEntry.Work_Step_Default_Status__c,
            WorkPlanTemplateEntry.Work_Step_Sequence__c
        };
    }

    /**
     * @description It is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkPlanTemplateEntry.SObjectType;
    }
}