/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Selector class for Tasks object.
 */
public inherited sharing class TasksSelector extends fflib_SObjectSelector implements ITasksSelector {
    /**
     * @description Default constructor for the Tasks Selector class.
     * @return ITasksSelector - interface of ITasksSelector
     */
    public static ITasksSelector newInstance() {
        return (ITasksSelector) Application.Selector.newInstance(Task.SObjectType);
    }

    /**
     * @description It is used for getting the fields on Task object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Task.Id,
            Task.ActivityDate,
            Task.CompletedDateTime,
            Task.Description,
            Task.OwnerId,
            Task.Priority,
            Task.Status,
            Task.Subject,
            Task.WhatId,
            Task.WhoId,
            Task.Type
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }

    /**
     * @description It is used to query Tasks having WhatId by the passed Ids.
     * @JIRA# LEM-16013
     * @param taskIds
     * @return List<Task>
     */
    public List<Task> selectTasksWithWhatIdByIds(Set<Id> taskIds) {
        return (List<Task>) Database.query(
            newQueryFactory()
                .selectField('AC_Contact_Trace_Record__c')
                .selectField('Call_Duration_HH_MM__c')
                .selectField('Call_Purpose__c')
                .selectField('Call_Result__c')
                .selectField('Call_Type__c')
                .selectField('Recording_URL__c')
                .setCondition('Id IN :taskIds AND WhatId != null')
                .toSOQL()
        );
    }
}
