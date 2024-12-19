/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Test class for TasksHandler class.
 */
@isTest(SeeAllData=false)
private class TasksHandlerTest {
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Records are not present in database.';
    private static final String TASK_STATUS_COMPLETED = 'Completed';
    private static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    private static final String TASK_SUBJECT_CALL = 'Call';
    private static final String TASK_CONTACT_TRACE = 'Test Contact Trace';

    /**
     * @description This method is used to test Task TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Task> newTask = new List<Task>();
        TasksHandler taskObject = new TasksHandler(newTask);
        TasksHandler.Constructor objConstructor = new TasksHandler.Constructor();
        objConstructor.construct(newTask);
        System.assertNotEquals(
            taskObject,
            objConstructor.construct(newTask),
            'Expected result: both constructs are similar.'
        );
    }

    /**
     * @description To test invoking of 'updateFirstAndLastActivityOnLead' method
     * on Status change of Tasks.
     * JIRA# LEM-21484
     */
    @isTest
    private static void testWhenTasksInsertedThenInvokeUpdateActivityDatesOnLead() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
        Task mockTask = new Task(Id = mockTaskId, Status = TASK_STATUS_NOT_STARTED);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(new List<Task>{ mockTask });
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).updateFirstAndLastActivityOnLead();
    }
    /**
     * @description To test invoking of 'updateFirstAndLastActivityOnLead' method
     * on insert Tasks.
     * JIRA# LEM-21484
     */
    @isTest
    private static void testWhenTasksAddedThenInvokeUpdateActivityDatesOnLead() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
        Task mockTask = new Task(Id = mockTaskId, Status = TASK_STATUS_NOT_STARTED);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(new List<Task>{ mockTask });
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).updateFirstAndLastActivityOnLead();
    }

    /**
     * @description To test method call on Task insert
     */
    @IsTest
    private static void testWhenTasksInsertedThenCallupdateCallCountWhenAnyCallIsHappened() {
        List<Task> newTasks = new List<Task>{
            new Task(Subject = 'This is the Subject!', Status = 'Completed')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks taskMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(taskMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(taskMock);
        fflib_SObjectDomain.Test.Database.onInsert(newTasks);
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        ((ITasks) mocks.verify(taskMock, 1)).updateCallCountWhenAnyCallIsHappened();
        ((ITasks) mocks.verify(taskMock, 1)).updateActivityDatesOnOpportunity();
        System.assertEquals(
            newTasks[0].subject,
            'This is the Subject!',
            'Subject should be same as before'
        );
        System.assertEquals(newTasks.size(), 1, 'Number of Calls shoule be same');
    }

    /**
     * @description To test invoking of 'updateActivityDatesOnOpportunity' method
     * on Status change of Tasks.
     */
    @isTest
    private static void testWhenTasksInsertedThenInvokeUpdateActivityDatesOnOpportunity() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
        Task mockTask = new Task(Id = mockTaskId, Status = TASK_STATUS_NOT_STARTED);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(new List<Task>{ mockTask });
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).updateActivityDatesOnOpportunity();
    }

    /**
     * @description To test invoking of 'cloneTasksOnParentWorkOrdersByTasksOnWorkPlans' method
     * on change of AC Contact Trace of Tasks from null to some value.
     */
    @isTest
    private static void testWhenTasksContactTraceUpdatedFromNullThenInvokeCloneTasksOnParentWorkOrdersByTasksOnWorkPlans() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);

        Id mockACContactTraceRecordId = Fake.generateId(
            amazonconnect__AC_ContactTraceRecord__c.class
        );

        Map<Id, Task> mockOldTasks = new Map<Id, Task>{ mockTaskId => new Task(Id = mockTaskId) };
        Task mockTask = new Task(
            Id = mockTaskId,
            AC_Contact_Trace_Record__c = mockACContactTraceRecordId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(new List<Task>{ mockTask }, mockOldTasks);
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
    }

    /**
     * @description To test invoking of 'cloneTasksOnParentWorkOrdersByTasksOnWorkPlans' method
     * on change of AC Contact Trace of Tasks from some value to null.
     */
    @isTest
    private static void testWhenTasksContactTraceUpdatedToNullThenInvokeCloneTasksOnParentWorkOrdersByTasksOnWorkPlans() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
        Id mockACContactTraceRecordId = Fake.generateId(
            amazonconnect__AC_ContactTraceRecord__c.class
        );
        Map<Id, Task> mockOldTasks = new Map<Id, Task>{
            mockTaskId => new Task(
                Id = mockTaskId,
                AC_Contact_Trace_Record__c = mockACContactTraceRecordId
            )
        };
        Task mockTask = new Task(Id = mockTaskId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(new List<Task>{ mockTask }, mockOldTasks);
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
    }

    /**
     * @description To test invoking of 'cloneTasksOnParentWorkOrdersByTasksOnWorkPlans' method
     * on change of RelatedTo from null to WorkPlan Type.
     */
    @isTest
    private static void testWhenTasksRelatedToUpdatedFromNullThenInvokeCloneTasksOnParentWorkOrdersByTasksOnWorkPlans() {
        Id mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        WorkPlan parentWorkPlan = new WorkPlan(Id = parentWorkPlanId);
        Map<Id, Task> mockOldTasks = new Map<Id, Task>{ mockTaskId => new Task(Id = mockTaskId) };
        Task mockTask = new Task(Id = mockTaskId, WhatId = parentWorkPlan.Id);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITasks tasksMock = (ITasks) mocks.mock(ITasks.class);
        mocks.startStubbing();
        mocks.when(tasksMock.getType()).thenReturn(Schema.Task.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(tasksMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(new List<Task>{ mockTask }, mockOldTasks);
        fflib_SObjectDomain.triggerHandler(TasksHandler.class);
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        ((ITasks) mocks.verify(tasksMock, 1)).cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
    }
}