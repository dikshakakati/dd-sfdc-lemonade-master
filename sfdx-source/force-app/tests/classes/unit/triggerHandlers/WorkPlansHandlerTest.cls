/**
 * @author Deloitte
 * @date 13/04/2022
 * @description Test class for WorkPlansHandler class.
 */
@isTest(seeAllData=false)
private class WorkPlansHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_PLAN_NAME = 'Storefront';
    private static final String WORK_PLAN_NOTES = 'Test Notes';
    private static final String WORK_PLAN_OLD_NOTES = 'Test Old Notes';
    private static final String WORK_PLAN_TEMPLATE_NAME = 'Storefront';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<WorkPlan> workPlansList = new List<WorkPlan>();
        WorkPlans.newInstance(workPlansList);
        WorkPlans workPlansObject = new WorkPlans(workPlansList);
        WorkPlans.Constructor constructorObject = new WorkPlans.Constructor();
        constructorObject.construct(workPlansList);
        System.assertNotEquals(
            WorkPlans.newInstance(workPlansList),
            workPlansObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when after insert called then after insert domain method is called.
     */
    @isTest
    private static void testWhenWorkPlanAfterInsertIsCalledThenAfterInsertDomainMethodCalled() {
        WorkPlan newWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Work_Plan_Template__c = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkPlans workPlansMock = (IWorkPlans) mocks.mock(IWorkPlans.class);
        mocks.startStubbing();
        mocks.when(workPlansMock.getType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workPlansMock);
        WorkPlans.setConstructorMock(constructor);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<WorkPlan>{ newWorkPlan });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkPlansHandler.class);
        ((IWorkPlans) mocks.verify(workPlansMock, 1)).onAfterInsertHandleRelatedRecords();
    }

    /**
     * @description To test when after update called then after update domain method is called.
     */
    @isTest
    private static void testWhenWorkPlanAfterUpdateIsCalledThenAfterUpdateDomainMethodCalled() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c, 0)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c, 1)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkPlans workPlansMock = (IWorkPlans) mocks.mock(IWorkPlans.class);
        mocks.startStubbing();
        mocks.when(workPlansMock.getType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workPlansMock);
        WorkPlans.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkPlan>{ newChildWorkPlan },
            oldWorkPlans
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkPlansHandler.class);
        ((IWorkPlans) mocks.verify(workPlansMock, 1))
            .onAfterUpdateHandleRelatedRecords(oldWorkPlans);
    }

    /**
     * @description To test when before update called then before update domain method is called.
     */
    @isTest
    private static void testWhenWorkPlanBeforeUpdateIsCalledThenBeforeUpdateDomainMethodCalled() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkPlan> oldWorkPlans = new Map<Id, WorkPlan>();
        WorkPlan oldChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c, 0)
            .toSObject();
        oldWorkPlans.put(workPlanId, oldChildWorkPlan);
        WorkPlan newChildWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c, 1)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkPlans workPlansMock = (IWorkPlans) mocks.mock(IWorkPlans.class);
        mocks.startStubbing();
        mocks.when(workPlansMock.getType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workPlansMock);
        WorkPlans.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkPlan>{ newChildWorkPlan },
            oldWorkPlans
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkPlansHandler.class);
        ((IWorkPlans) mocks.verify(workPlansMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkPlanFields(oldWorkPlans);
    }

    /**
     * @description To test when the field 'Notes' parent work plans modified, it triggers
     * child work plans modification
     */
    @isTest
    private static void testWhenParentWorkPlanFieldsChangedThenUpdateChildWorkPlanFields() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        WorkPlan parentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Notes__c, WORK_PLAN_NOTES)
            .toSObject();
        WorkPlan oldParentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Notes__c, WORK_PLAN_OLD_NOTES)
            .toSObject();
        List<WorkPlan> mockWorkPlans = new List<WorkPlan>{ parentWorkPlan };
        List<WorkPlan> oldMockWorkPlans = new List<WorkPlan>{ oldParentWorkPlan };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlans workPlansMock = (IWorkPlans) mocks.mock(IWorkPlans.class);
        mocks.startStubbing();
        mocks.when(workPlansMock.getType()).thenReturn(Schema.WorkPlan.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workPlansMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkPlans,
            new Map<Id, WorkPlan>(oldMockWorkPlans)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkPlansHandler.class);
        ((IWorkPlans) mocks.verify(workPlansMock, 1))
            .collectParentWorkPlansWithUpdatedInformation(mockWorkPlans);
    }
}