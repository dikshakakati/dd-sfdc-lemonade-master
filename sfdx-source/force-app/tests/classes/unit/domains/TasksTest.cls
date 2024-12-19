/**
 * @description Tasks Domain class Test
 * @author Deloitte
 * @date 04/30/2024
 */
@isTest(SeeAllData=false)
public class TasksTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ASSERT_MESSAGE_INCORRECT_ACTIVTY_DATE = 'Unexpected result: activity dates on Opportunity is populated incorrectly.';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String TASK_CALLTYPE_INBOUND = 'Inbound';
    private static final String TASK_CALLTYPE_OUTBOUND = 'Outbound';
    private static final String TASK_TYPE_PHONECALL = 'Phone Call';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String VERTICAL_RX = 'Rx';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;
    private static final String TASK_TYPE_TEXT_MESSAGE = 'Text Message';
    private static final String TASK_TYPE_EMAIL = 'Email';
    private static final String LEAD_LAST_NAME = 'Lead Last Name';
    private static final String LEAD_PHONE = '1234567899';
    private static final String LEAD_EMAIL = 'abc@Email.com';
    private static final String TASK_STATUS_INPROGRESS = 'In Progress';

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Task> taskInstantiate = new List<Task>();
        Tasks.newInstance(taskInstantiate);
        Tasks newTask = new Tasks(taskInstantiate);
        Tasks.Constructor constructorObject = new Tasks.Constructor();
        constructorObject.construct(taskInstantiate);
        System.assertNotEquals(
            Tasks.newInstance(taskInstantiate),
            newTask,
            'These objects should not be similar'
        );
    }

    /**
     * @description To test whether Call count field is updated on lead when a task inserted
     */
    @isTest
    private static void testWhenTaskInsertedThenUpdateCallCountOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, 'Lead 1')
            .setField(Lead.Email, 'abc@abc.com')
            .setField(Lead.Company, 'Example')
            .setField(Lead.Count_of_Calls_Outbound_Inbound__c, 1)
            .toSObject();

        Id taskId = Fake.generateId(Task.class);
        Task newTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Status, STATUS_COMPLETED)
            .toSObject();

        Id taskrelationId = Fake.generateId(TaskRelation.class);
        TaskRelation taskLeadRelation = (TaskRelation) new Fake(TaskRelation.class)
            .setField(TaskRelation.Id, taskrelationId)
            .setField(TaskRelation.taskId, taskId)
            .setField(TaskRelation.relationId, leadId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITaskRelationsSelector selectorMock = (ITaskRelationsSelector) mocks.mock(
            ITaskRelationsSelector.class
        );
        ILeadsSelector mocksLeadsselector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsselector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsselector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.TaskRelation.SObjectType);
        mocks.when(selectorMock.selectByTaskIds(new Set<Id>{ newTask.Id }))
            .thenReturn(new List<TaskRelation>{ taskLeadRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksLeadsselector);

        Test.startTest();
        Tasks.newInstance(new List<Task>{ newTask }).updateCallCountWhenAnyCallIsHappened();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether Call count field is updated on Contact when a task inserted
     */
    @isTest
    private static void testWhenTaskInsertedThenUpdateCallCountOnContact() {
        Id contactId = Fake.generateId(Contact.class);
        Contact contact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.LastName, 'Contact 1')
            .setField(Contact.Email, 'abc@abc.com')
            .setField(Contact.Count_of_Calls_Outbound_Inbound__c, 1)
            .toSObject();

        Id taskId = Fake.generateId(Task.class);
        Task newTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Status, STATUS_COMPLETED)
            .toSObject();

        Id taskrelationId = Fake.generateId(TaskRelation.class);
        TaskRelation taskContactRelation = (TaskRelation) new Fake(TaskRelation.class)
            .setField(TaskRelation.Id, taskrelationId)
            .setField(TaskRelation.taskId, taskId)
            .setField(TaskRelation.relationId, contactId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITaskRelationsSelector selectorMock = (ITaskRelationsSelector) mocks.mock(
            ITaskRelationsSelector.class
        );
        IContactsSelector mocksContactsSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksContactsSelector.sObjectType()).thenReturn(Schema.Contact.SObjectType);
        mocks.when(mocksContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ contact });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.TaskRelation.SObjectType);
        mocks.when(selectorMock.selectByTaskIds(new Set<Id>{ newTask.Id }))
            .thenReturn(new List<TaskRelation>{ taskContactRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksContactsSelector);

        Test.startTest();
        Tasks.newInstance(new List<Task>{ newTask }).updateCallCountWhenAnyCallIsHappened();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether Call count field is updated on Opportunity when a task inserted
     */
    @isTest
    private static void testWhenTaskInsertedThenUpdateCallCountOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.CloseDate, Date.today())
            .setField(Opportunity.Count_of_Calls_Outbound_Inbound__c, 1)
            .toSObject();

        Id taskId = Fake.generateId(Task.class);
        Task newTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Status, STATUS_COMPLETED)
            .toSObject();

        Id taskrelationId = Fake.generateId(TaskRelation.class);
        TaskRelation taskOpportunityRelation = (TaskRelation) new Fake(TaskRelation.class)
            .setField(TaskRelation.Id, taskrelationId)
            .setField(TaskRelation.taskId, taskId)
            .setField(TaskRelation.relationId, opportunityId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITaskRelationsSelector selectorMock = (ITaskRelationsSelector) mocks.mock(
            ITaskRelationsSelector.class
        );
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.TaskRelation.SObjectType);
        mocks.when(selectorMock.selectByTaskIds(new Set<Id>{ newTask.Id }))
            .thenReturn(new List<TaskRelation>{ taskOpportunityRelation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);

        Test.startTest();
        Tasks.newInstance(new List<Task>{ newTask }).updateCallCountWhenAnyCallIsHappened();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether activity dates are updated on Opportunity when Task status
     * is completed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTaskUpdatedThenUpdateActivityDatesOnOpportunity() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity relatedOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.First_Activity__c, null)
            .setField(Opportunity.Last_Activity__c, null)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.CloseDate, Date.today().addDays(5))
            .toSObject();
        Id taskId = Fake.generateId(Task.class);
        Task updatedTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Status, STATUS_COMPLETED)
            .toSObject();
        Id taskrelationId = Fake.generateId(TaskRelation.class);
        TaskRelation taskOpportunityRelation = (TaskRelation) new Fake(TaskRelation.class)
            .setField(TaskRelation.Id, taskrelationId)
            .setField(TaskRelation.taskId, updatedTask.Id)
            .setField(TaskRelation.relationId, relatedOpportunity.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITaskRelationsSelector mockTaskRelationsSelector = (ITaskRelationsSelector) mocks.mock(
            ITaskRelationsSelector.class
        );
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ relatedOpportunity });
        mocks.when(mockTaskRelationsSelector.sObjectType())
            .thenReturn(Schema.TaskRelation.SObjectType);
        mocks.when(mockTaskRelationsSelector.selectByTaskIds(new Set<Id>{ updatedTask.Id }))
            .thenReturn(new List<TaskRelation>{ taskOpportunityRelation });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTaskRelationsSelector);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ updatedTask }).updateActivityDatesOnOpportunity();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test whether activity dates are updated on Lead when Task status
     * is completed.
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTaskUpdatedThenUpdateActivityDatesOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, LEAD_LAST_NAME)
            .setField(Lead.Phone, LEAD_PHONE)
            .setField(Lead.Email, LEAD_EMAIL)
            .setField(Lead.First_Qualified_Activity__c, null)
            .setField(Lead.Last_Qualified_Activity__c, null)
            .toSObject();
        Id taskId = Fake.generateId(Task.class);
        Task updatedTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.WhoId, leadId)
            .setField(Task.Status, STATUS_COMPLETED)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mocksLeadsSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ updatedTask }).updateFirstAndLastActivityOnLead();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test whether activity dates are updated on Lead when Task status
     * is not completed.
     * @JIRA# LEM-21484
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTaskInsertedWithAnyStatusThenUpdateActivityDatesOnLead() {
        Id leadId = Fake.generateId(Lead.class);
        Lead lead = (Lead) new Fake(Lead.class)
            .setField(Lead.Id, leadId)
            .setField(Lead.LastName, LEAD_LAST_NAME)
            .setField(Lead.Phone, LEAD_PHONE)
            .setField(Lead.Email, LEAD_EMAIL)
            .setField(Lead.First_Qualified_Activity__c, null)
            .setField(Lead.Last_Qualified_Activity__c, null)
            .toSObject();
        Id taskId = Fake.generateId(Task.class);
        Task updatedTask = (Task) new Fake(Task.class)
            .setField(Task.Id, taskId)
            .setField(Task.WhoId, leadId)
            .setField(Task.Status, TASK_STATUS_INPROGRESS)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ILeadsSelector mocksLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(mocksLeadsSelector.sObjectType()).thenReturn(Schema.Lead.SObjectType);
        mocks.when(mocksLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{ lead });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mocksLeadsSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ updatedTask }).updateFirstAndLastActivityOnLead();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tasks with CallType as 'Inbound' gets created on Work Plan then
     * it does not gets cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInboundCallTypeTaskOnWorkPlanInsertedThenDoNotCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_INBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockTask.Id }))
            .thenReturn(new List<Task>{ mockTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockParentWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockParentWorkPlan });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tasks with CallType as 'Outbound' gets created on Account then
     * it does not gets cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOutboundCallTypeTaskOnAccountInsertedThenDoNotCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentAccount.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockTask.Id }))
            .thenReturn(new List<Task>{ mockTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockParentWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockParentWorkPlan });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test when Tasks with CallType as 'Outbound' gets created on Work Plan then
     * it gets cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOutboundCallTypeTaskOnWorkPlanInsertedThenCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockTask.Id }))
            .thenReturn(new List<Task>{ mockTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockParentWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockParentWorkPlan });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Task.WhatId => mockParentWorkOrder.Id }
                )
            );
    }

    /**
     * @description To test when Tasks with CallType as 'Outbound' get
     * created on Child Work Plan then it gets cloned on Parent Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOutboundCallTypeTaskOnChildWorkPlanInsertedThenCloneTasksOnParentWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                mockParentAccount.Id,
                VERTICAL_RX
            )
            .setField(Account.ParentId, mockParentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account mockStoreAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                mockStoreAccount.Id,
                TYPE_MARKETPLACE,
                mockParentWorkOrder.Id
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder mockChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithParentWorkPlanId(
                mockParentWorkPlan.Id,
                mockChildWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockChildWorkOrder.Id)
            .setField(WorkPlan.Parent_Work_Plan__c, mockParentWorkPlan.Id)
            .setParent('WorkOrder', childWorkOrderFakeInstance);

        WorkPlan mockChildWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Task mockTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockChildWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockTask.Id }))
            .thenReturn(new List<Task>{ mockTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockChildWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockChildWorkPlan });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Task.WhatId => mockParentWorkOrder.Id }
                )
            );
    }

    /**
     * @description To test when Tasks with CallType as 'Outbound' gets created on Work Plan
     * and exception occurss then it does not gets cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOutboundCallTypeTaskOnWorkPlanInsertedAndExceptionOccurredThenDoNotCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_PHONECALL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockTask.Id }))
            .thenReturn(new List<Task>{ mockTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockParentWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockParentWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        String exceptionMessage;
        try {
            Tasks.newInstance(new List<Task>{ mockTask })
                .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
    }

    /**
     * @description To test when Tasks with Type as 'Text Message' gets tagged to Work Plan then
     * it gets cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTextMessageTypeTaskOnWorkPlanUpdatedThenCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockUpdatedTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_TEXT_MESSAGE)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockUpdatedTask.Id }))
            .thenReturn(new List<Task>{ mockUpdatedTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(
                    new Set<Id>{ mockParentWorkPlan.Id }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockParentWorkPlan });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockUpdatedTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Task.WhatId => mockParentWorkOrder.Id }
                )
            );
    }

    /**
     * @description To test when Tasks with Type as 'Email' gets tagged to Work Plan then
     * it does not get cloned on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmailTypeTaskOnWorkPlanUpdatedThenDoNotCloneTasksOnWorkOrders() {
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL_RX,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account mockParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        WorkOrder mockParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(
                mockParentAccount.Id,
                TYPE_MARKETPLACE
            )
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                mockParentWorkOrder.Id,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.WorkOrderId, mockParentWorkOrder.Id);
        WorkPlan mockParentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Task mockUpdatedTask = (Task) new Fake(Task.class)
            .setField(Task.Id, Fake.generateId(Task.class))
            .setField(Task.Type, TASK_TYPE_EMAIL)
            .setField(Task.Call_Type__c, TASK_CALLTYPE_OUTBOUND)
            .setField(Task.Status, STATUS_COMPLETED)
            .setField(Task.WhatId, mockParentWorkPlan.Id)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ITasksSelector mockTasksSelector = (ITasksSelector) mocks.mock(ITasksSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockTasksSelector.sObjectType()).thenReturn(Schema.Task.SObjectType);
        mocks.when(mockTasksSelector.selectTasksWithWhatIdByIds(new Set<Id>{ mockUpdatedTask.Id }))
            .thenReturn(new List<Task>{ mockUpdatedTask });
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockTasksSelector);
        Test.startTest();
        Tasks.newInstance(new List<Task>{ mockUpdatedTask })
            .cloneTasksOnParentWorkOrdersByTasksOnWorkPlans();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}