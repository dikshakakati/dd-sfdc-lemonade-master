/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Domain Class for Task Object.
 */
public inherited sharing class Tasks extends fflib_SObjects implements ITasks {
    fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String BLANK_SPACE = ' ';
    private static final String INTERACTION_TYPE_PHONE_CALL = 'Phone Call';
    private static final String INTERACTION_TYPE_MEETING = 'Meeting';
    private static final String LOG_TASKS_FAILURE = 'commitWork() in Tasks failed.';
    private static final String LOG_UPDATE_SOBJECT_BASED_ON_TASKS = 'Updation of fields on sObjects based on Tasks';
    private static final String LOG_UPDATE_FIRST_AND_LAST_ACTIVITY = 'Update First and Last Activity failed';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String TASK_COMMENT = 'This task was created automatically from Mx Touchpoint';
    private static final String TASK_STATUS_COMPLETED = 'Completed';
    private static final String TASK_SUBJECT = 'Mx Touchpoint: ';
    private static final String TASK_SUBJECT_CALL = 'Call';
    private static final String TASK_CALL_RESULT = 'Completed Call';
    private static final String TASK_CALL_TYPE_OUTBOUND = 'Outbound';
    private static final String TASK_TYPE_CALL = 'Call';
    private static final String TASK_TYPE_PHONECALL = 'Phone Call';
    private static final String TASK_TYPE_TEXT_MESSAGE = 'Text Message';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final Set<String> TASK_TYPES_TO_CLONE_ON_WORK_ORDER = new Set<String>{
        TASK_TYPE_CALL,
        TASK_TYPE_PHONECALL,
        TASK_TYPE_TEXT_MESSAGE
    };

    /**
     * @description This method is used to return the ITasks interface
     * @param recordList - Orders record list
     * @return ITasks - Returns ITasks Interface
     */
    public static ITasks newInstance(List<Task> recordList) {
        return (ITasks) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Tasks(List<Task> sObjectList) {
        super(sObjectList, Schema.Task.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of Task domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of Task
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (Tasks.constructorMock != null) {
                return (fflib_ISObjects) Tasks.constructorMock.construct(objects);
            }
            return new Tasks((List<Task>) objects);
        }
    }

    /**
     * @description It is used to create and return Task instance by passed Mx Touchpoint
     * and Stakeholder records.
     * @JIRA# LEM-14728
     * @param mxTouchpoint
     * @param stakeholder
     * @return Task
     */
    public Task createTaskByPassedMxTouchpointAndStakeholder(
        Initiative__c mxTouchpoint,
        Stakeholder__c stakeholder
    ) {
        return new Task(
            Description = TASK_COMMENT,
            ActivityDate = mxTouchpoint.End_Date__c != null
                ? mxTouchpoint.End_Date__c
                : mxTouchpoint.Start_Date__c,
            Status = TASK_STATUS_COMPLETED,
            Subject = TASK_SUBJECT +
                mxTouchpoint.Type__c +
                BLANK_SPACE +
                String.valueOf(mxTouchpoint.Start_Date__c),
            Type = mxTouchpoint.Interaction_Type__c == INTERACTION_TYPE_PHONE_CALL ||
                mxTouchpoint.Interaction_Type__c == null
                ? INTERACTION_TYPE_PHONE_CALL
                : INTERACTION_TYPE_MEETING,
            Call_Result__c = TASK_CALL_RESULT,
            Call_Type__c = TASK_CALL_TYPE_OUTBOUND,
            OwnerId = stakeholder?.User__c == null ? mxTouchpoint.OwnerId : stakeholder.User__c,
            WhoId = stakeholder?.Contact__c,
            WhatId = mxTouchpoint.Id
        );
    }

    /**
     * @description It is used to update first and last activity on lead for Tasks
     * which are inserted
     */
    public void updateFirstAndLastActivityOnLead() {
        DateTime firstQualifiedActivity;
        List<Task> tasks = (List<task>) getRecords();
        Set<Id> leadIds = new Set<Id>();
        for (Task eachTask : tasks) {
            if (
                !String.isBlank(eachTask.whoId) &&
                eachTask.whoId.getSObjectType() == Lead.SObjectType
            ) {
                leadIds.add(eachTask.whoId);
            }
        }
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (leadIds.isEmpty()) {
            return;
        }
        for (Lead eachLead : leadsSelector.newInstance().selectById(leadIds)) {
            firstQualifiedActivity = (eachLead.First_Qualified_Activity__c == null)
                ? System.now()
                : eachLead.First_Qualified_Activity__c;
            uow.registerDirty(
                new Lead(
                    Id = eachLead.Id,
                    First_Qualified_Activity__c = firstQualifiedActivity,
                    Last_Qualified_Activity__c = System.Now()
                )
            );
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_FIRST_AND_LAST_ACTIVITY,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to update activity dates on related Opportunities for Tasks
     * which are inserted or updated.
     */
    public void updateActivityDatesOnOpportunity() {
        Set<Id> relatedOpportunityIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        for (Task eachTask : (List<Task>) getRecords()) {
            taskIds.add(eachTask.Id);
        }

        if (taskIds.isEmpty()) {
            return;
        }
 
        for (
            TaskRelation taskRelation : TaskRelationsSelector.newInstance()
                .selectByTaskIds(taskIds)
        ) {
            if(taskRelation.RelationId != null && taskRelation.RelationId.getSobjectType() == Opportunity.SObjectType) {
                relatedOpportunityIds.add(taskRelation.RelationId);                
            }
        }

        updateFirstAndLastActivityDatesOnOpportunity(relatedOpportunityIds, uow);

        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SOBJECT_BASED_ON_TASKS,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to update Count of call when a Task is inserted.
     */
    public void updateCallCountWhenAnyCallIsHappened() {
        Set<Id> callTaskIds = extractCallTaskIds((List<Task>) getRecords());
        Map<Id, Integer> relationIdWithSObjectCount = new Map<Id, Integer>();


        if (callTaskIds.isEmpty()) {
            return;
        }

        for (
            TaskRelation taskRelation : TaskRelationsSelector.newInstance().selectByTaskIds(callTaskIds)
        ) {
            if (relationIdWithSObjectCount.containsKey(taskRelation.RelationId)) {
                relationIdWithSObjectCount.put(
                    taskRelation.RelationId,
                    relationIdWithSObjectCount.get(taskRelation.RelationId) + 1
                );
            } else {
                relationIdWithSObjectCount.put(taskRelation.RelationId, 1);
            }
        }

        if (!relationIdWithSObjectCount.isEmpty()) {
            updateCallCountOnLead(relationIdWithSObjectCount, uow);
            updateCallCountOnContact(relationIdWithSObjectCount, uow);
            updateCallCountOnOpportunity(relationIdWithSObjectCount, uow);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SOBJECT_BASED_ON_TASKS,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }


    /**
     * @description Helper method to extract call Task IDs based on conditions
     * @param tasks
     * @return Set<Id>
     **/
    private Set<Id> extractCallTaskIds(List<Task> tasks) {
        Set<Id> callTaskIds = new Set<Id>();
        for (Task task : tasks) {
            if (isCompletedCallTask(task)) {
                callTaskIds.add(task.Id);
            }
        }
        return callTaskIds;
    }

    /**
     * @description Determines if a Task is a completed call
     * @param task
     * @return Boolean
     **/
    private Boolean isCompletedCallTask(Task task) {
        return task.Status == TASK_STATUS_COMPLETED &&
            (task.Type == TASK_TYPE_PHONECALL ||
            task.Subject == TASK_SUBJECT_CALL);
    }

    /**
     * @description It is used to update first and last activity dates on Opportunity.
     * @param opportunityIds
     * @param uow
     */
    private void updateFirstAndLastActivityDatesOnOpportunity(
        Set<Id> opportunityIds,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (opportunityIds.isEmpty() || opportunityIds == null) {
            return;
        }
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(opportunityIds)
        ) {
            DateTime firstQualifiedActivity;
            if (eachOpportunity.Account_Segment__c == ACCOUNT_SEGMENT_SMB) {
                firstQualifiedActivity = (eachOpportunity.First_Activity__c == null)
                    ? System.now()
                    : eachOpportunity.First_Activity__c;
            }
            uow.registerDirty(
                new Opportunity(
                    Id = eachOpportunity.Id,
                    First_Activity__c = firstQualifiedActivity,
                    Last_Activity__c = System.now()
                )
            );
        }
    }

    /**
     * @description Called to perform update Count of Call on Lead
     * @param relationIdWithLeadCount - lead id with Newly added calls
     * @param uow
     */
    private void updateCallCountOnLead(
        Map<Id, Integer> relationIdWithLeadCount,
        fflib_ISobjectUnitOfWork uow
    ) {
        for (
            Lead eachLead : LeadsSelector.newInstance().selectById(relationIdWithLeadCount.KeySet())
        ) {
            Decimal countOfCall = (eachLead.Count_of_Calls_Outbound_Inbound__c == null ||
                eachLead.Count_of_Calls_Outbound_Inbound__c == 0)
                ? relationIdWithLeadCount.get(eachLead.Id)
                : eachLead.Count_of_Calls_Outbound_Inbound__c +
                  relationIdWithLeadCount.get(eachLead.Id);
            uow.registerDirty(
                new Lead(Id = eachLead.Id, Count_of_Calls_Outbound_Inbound__c = countOfCall)
            );
        }
    }

    /**
     * @description Called to perform update Count of Call on Contact
     * @param relationidWithContactCount - Contact id with Newly added calls
     * @param uow
     */
    private void updateCallCountOnContact(
        Map<Id, Integer> relationidWithContactCount,
        fflib_ISobjectUnitOfWork uow
    ) {
        for (
            Contact eachContact : ContactsSelector.newInstance()
                .selectById(relationidWithContactCount.KeySet())
        ) {
            Decimal countOfCall = (eachContact.Count_of_Calls_Outbound_Inbound__c == null ||
                eachContact.Count_of_Calls_Outbound_Inbound__c == 0)
                ? relationidWithContactCount.get(eachContact.Id)
                : eachContact.Count_of_Calls_Outbound_Inbound__c +
                  relationidWithContactCount.get(eachContact.Id);
            uow.registerDirty(
                new Contact(Id = eachContact.Id, Count_of_Calls_Outbound_Inbound__c = countOfCall)
            );
        }
    }

    /**
     * @description Called to perform update Count of Call on Opportunity
     * @param relationidWithOpportunityCount - Opportunity id with Newly added calls
     * @param uow
     */
    private void updateCallCountOnOpportunity(
        Map<Id, Integer> relationidWithOpportunityCount,
        fflib_ISobjectUnitOfWork uow
    ) {
        if (relationidWithOpportunityCount.isEmpty() || relationidWithOpportunityCount == null) {
            return;
        }

        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectById(relationidWithOpportunityCount.KeySet())
        ) {
            Decimal countOfCall = (eachOpportunity.Count_of_Calls_Outbound_Inbound__c == null ||
                eachOpportunity.Count_of_Calls_Outbound_Inbound__c == 0)
                ? relationidWithOpportunityCount.get(eachOpportunity.Id)
                : eachOpportunity.Count_of_Calls_Outbound_Inbound__c +
                  relationidWithOpportunityCount.get(eachOpportunity.Id);
            uow.registerDirty(
                new Opportunity(
                    Id = eachOpportunity.Id,
                    Count_of_Calls_Outbound_Inbound__c = countOfCall
                )
            );
        }
    }

    /**
     * @description It is used to clone tasks on work orders (parent) from tasks
     * associated with work plans.
     * JIRA# LEM-16013
     */
    public void cloneTasksOnParentWorkOrdersByTasksOnWorkPlans() {
        if (((List<Task>) getRecords()).isEmpty()) {
            return;
        }
        Map<Id, List<Task>> workPlanIdToTasks = new Map<Id, List<Task>>();
        // Collect all Work Plan Ids.
        for (
            Task eachTask : TasksSelector.newInstance()
                .selectTasksWithWhatIdByIds((new Map<Id, Task>((List<Task>) getRecords())).KeySet())
        ) {
            if (
                eachTask.WhatId.getSobjectType() != Schema.WorkPlan.SObjectType ||
                String.isBlank(eachTask.Type) ||
                !TASK_TYPES_TO_CLONE_ON_WORK_ORDER.contains(eachTask.Type)
            ) {
                continue;
            }
            if (!workPlanIdToTasks.containsKey(eachTask.WhatId)) {
                workPlanIdToTasks.put(eachTask.WhatId, new List<Task>());
            }
            workPlanIdToTasks.get(eachTask.WhatId).add(eachTask);
        }
        // Clone Task on Work Order of Work Plan.
        createClonedTasksOnWorkOrders(workPlanIdToTasks);
    }

    /**
     * @description It is used to generate cloned tasks by the passed work plans.
     * JIRA# LEM-16013
     * @param workPlanIdToTasks
     */
    private void createClonedTasksOnWorkOrders(Map<Id, List<Task>> workPlanIdToTasks) {
        if (workPlanIdToTasks.isEmpty()) {
            return;
        }
        Task clonedTask;
        fflib_ISobjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansWithWorkOrderDetails(workPlanIdToTasks.KeySet())
        ) {
            for (Task eachTask : workPlanIdToTasks.get(eachWorkPlan.Id)) {
                clonedTask = eachTask.clone(false, false, false, false);
                clonedTask.WhatId = String.isBlank(eachWorkPlan.Parent_Work_Plan__c)
                    ? eachWorkPlan.WorkOrderId
                    : eachWorkPlan.WorkOrder.ParentWorkOrderId;
                unitOfWorkInstance.registerNew(clonedTask);
            }
        }
        commitWork(unitOfWorkInstance);
    }

    /**
     * @description It is a generic method to commitWork and
     * log fflib_ISobjectUnitOfWork exceptions.
     * JIRA# LEM-16013
     * @param unitOfWorkInstance
     */
    private void commitWork(fflib_ISobjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.LOW)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_TASKS_FAILURE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(unitOfWorkException)
            );
        }
    }
}