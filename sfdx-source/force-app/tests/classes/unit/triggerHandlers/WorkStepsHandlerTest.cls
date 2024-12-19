/**
 * @author Deloitte
 * @date 18/04/2022
 * @description Test class for WorkStepsHandler class.
 */
@isTest(seeAllData=false)
private class WorkStepsHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String WORK_STEP_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_NAME_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_MENU_ERROR_TYPE = 'Formatting';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_REASON_OTHER = 'Other';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<WorkStep> workStepsList = new List<WorkStep>();
        WorkSteps.newInstance(workStepsList);
        WorkSteps workStepsObject = new WorkSteps(workStepsList);
        WorkSteps.Constructor constructorObject = new WorkSteps.Constructor();
        constructorObject.construct(workStepsList);
        System.assertNotEquals(
            WorkSteps.newInstance(workStepsList),
            workStepsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test copy custom Status field value to Standard Status field on insert.
     */
    @isTest
    private static void testWhenInsertThenValidateAndUpdateWorkStepFields() {
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<WorkStep>{ newWorkStep });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1))
            .onBeforeInsertValidateAndUpdateWorkStepFields();
    }

    /**
     * @description To test copy custom Status Field value to Standard Status field on update.
     */
    @isTest
    private static void testWhenUpdateThenValidateAndUpdateWorkStepFields() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        WorkStep oldWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = workPlanId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status = WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_STORE,
            WorkPlanId = workPlanId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(workStepsMock);
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        WorkSteps.setConstructorMock(constructor);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkStep>{ newWorkStep },
            new Map<Id, WorkStep>{ newWorkStep.Id => oldWorkStep }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkStepFields(
                new Map<Id, WorkStep>{ newWorkStep.Id => oldWorkStep }
            );
    }

    /**
     * @description To test blanking the Menu Error Type Field when Escalation is resolved.
     */
    @isTest
    private static void testWhenUpdateThenValidateAndUpdateMenuErrorTypeField() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        WorkStep oldWorkStep = new WorkStep(
            Id = workStepId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Name = WORK_STEP_NAME_SETUP_MENU,
            Status = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
            WorkPlanId = workPlanId
        );
        WorkStep newWorkStep = new WorkStep(
            Id = workStepId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Name = WORK_STEP_NAME_SETUP_STORE,
            Status = WORK_STEP_STATUS_IN_PROGRESS,
            WorkPlanId = workPlanId
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(workStepsMock);
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        WorkSteps.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkStep>{ newWorkStep },
            new Map<Id, WorkStep>{ workStepId => oldWorkStep }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkStepFields(
                new Map<Id, WorkStep>{ workStepId => oldWorkStep }
            );
    }

    /**
     * @description To test update WorkStep related records on After Update trigger event.
     */
    @isTest
    private static void testWhenUpdateThenHandleRelatedRecords() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        WorkStep oldWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = workPlanId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_STORE,
            WorkPlanId = workPlanId,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(workStepsMock);
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        WorkSteps.setConstructorMock(constructor);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkStep>{ newWorkStep },
            new Map<Id, WorkStep>{ newWorkStep.Id => oldWorkStep }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1))
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>{ newWorkStep.Id => oldWorkStep }
            );
    }

    /**
     * @description To test update on date fields utilized for tracking WorkStep Status change
     * when Status is updated.
     */
    @isTest
    private static void testWhenWorkStepStatusIdUpdatedThenValidateAndUpdateAssociatedDateTrackingFields() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(workStepsMock);
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        WorkSteps.setConstructorMock(constructor);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onUpdate(new List<WorkStep>{ newWorkStep }, oldWorkSteps);
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
    }

    /**
     * @description To test when Work Step inserted then after insert domain method is called.
     */
    @isTest
    private static void testWhenWorkStepInsertedThenHandleRelatedRecords() {
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_DELIVER_TABLET,
            WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Type__c = WORK_STEP_DELIVER_TABLET,
            Status = WORK_STEP_STATUS_NOT_WORKABLE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IWorkSteps workStepsMock = (IWorkSteps) mocks.mock(IWorkSteps.class);
        mocks.startStubbing();
        mocks.when(workStepsMock.getType()).thenReturn(Schema.WorkStep.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workStepsMock);
        WorkSteps.setConstructorMock(constructor);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<WorkStep>{ newWorkStep });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkStepsHandler.class);
        ((IWorkSteps) mocks.verify(workStepsMock, 1)).onAfterInsertHandleRelatedRecords();
    }
}