/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Trigger Handler for Task.
 */
public class TasksHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - Task Record List
     */
    public TasksHandler(List<Task> sObjectList) {
        super(sObjectList);
        setContextBypass(Task.SObjectType, TasksHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return TasksHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new TasksHandler(sObjectList);
        }
    }

    /**
     * @description It is used to perform operation after a Call
     */
    public override void onAfterInsert() {
        Tasks.newInstance(this.records).updateCallCountWhenAnyCallIsHappened();
        Tasks.newInstance(this.records).updateActivityDatesOnOpportunity();
        Tasks.newInstance(this.records).updateFirstAndLastActivityOnLead();
    }

    /**
     * @description It is used to process after update of Tasks.
     * @JIRA LEM-13561, LEM-18009
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, Task> oldTaskRecords = (Map<Id, Task>) existingRecords;
        //JIRA#: LEM-18009
        Tasks.newInstance(getTasksEligibleForCloning(oldTaskRecords))
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
    }

    /**
     * @description It is used to get the list of Tasks eligible for cloning.
     * @JIRA LEM-18009
     * @param oldTaskRecords
     * @return List<Task>
     */
    private List<Task> getTasksEligibleForCloning(Map<Id, Task> oldTaskRecords) {
        List<Task> eligibleTasks = new List<Task>();
        List<Task> tasksWithChangedWhatId = new List<Task>(
            (List<Task>) getChangedRecords(new Set<SObjectField>{ Task.WhatId })
        );
        eligibleTasks.addAll(tasksWithChangedWhatId);
        for (
            Task eachTask : new List<Task>(
                (List<Task>) getChangedRecords(
                    new Set<SObjectField>{ Task.AC_Contact_Trace_Record__c }
                )
            )
        ) {
            if (
                (String.isBlank(oldTaskRecords.get(eachTask.Id).AC_Contact_Trace_Record__c) &&
                String.isNotBlank(eachTask.AC_Contact_Trace_Record__c))
            ) {
                eligibleTasks.add(eachTask);
            }
        }
        return eligibleTasks;
    }
}