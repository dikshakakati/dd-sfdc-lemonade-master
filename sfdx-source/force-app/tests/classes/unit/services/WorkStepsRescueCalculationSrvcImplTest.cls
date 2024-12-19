/**
 * @author Deloitte
 * @date 05/07/2022
 * @description Test class for WorkStepsRescueCalculationServiceImpl class.
 */
@isTest(seeAllData=false)
private class WorkStepsRescueCalculationSrvcImplTest {
    private static final String AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS = 'workStepsCount';
    private static final String AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS = 'parentWorkStepId';
    private static final String AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS = 'workStepStatus';
    private static final String BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: number of blocked Work Steps count does not match';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Steps count does not match';
    private static final String EVENT_TOPIC_WORK_STEPS_CALCULATION = 'WORK_STEPS_RESCUE_PROCESS_CALCULATION';
    private static final String RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: number of resolved Work Steps count does not match';
    private static final String SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step secondary email timer value does not match';
    private static final String WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step Id does not match';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_RESOLVED = 'Resolved';

    /**
     * @description To test calculation of number of blocked WorkSteps
     * along with secondary email timer start time on parent WorkStep
     * when NotifierEvent is captured for blocked child Work Steps.
     */
    @isTest
    private static void testWhenNotifierEventPayloadReceivedForBlockedChildWorkStepsThenCorrectFieldsUpdatedOnParentWorkStep() {
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_BLOCKED
            )
            .setField(WorkStep.Number_of_Blocked_Work_Steps__c, 2)
            .setField(WorkStep.Secondary_Email_Timer_Start_Time__c, System.now() - 1)
            .setField(WorkStep.Secondary_Email_Next_Schedule__c, System.now() - 1);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Aggregate mockAggregateBlockedParentWorkStep = new Aggregate();
        mockAggregateBlockedParentWorkStep.put(
            AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS,
            parentWorkStep.Id
        );
        mockAggregateBlockedParentWorkStep.put(
            AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS,
            WORK_STEP_STATUS_BLOCKED
        );
        mockAggregateBlockedParentWorkStep.put(AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS, 3);
        List<Aggregate> mockAggregates = new List<Aggregate>{ mockAggregateBlockedParentWorkStep };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = parentWorkStep.Id,
                Number_of_Blocked_Work_Steps__c = 3,
                Number_of_Resolved_Work_Steps__c = 0,
                Secondary_Email_Timer_Start_Time__c = System.now()
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(
                    new Set<Id>{ parentWorkStep.Id }
                )
            )
            .thenReturn(mockAggregates);
        mocks.when(mockWorkStepsSelector.selectById(new Set<Id>{ parentWorkStep.Id }))
            .thenReturn(new List<WorkStep>{ parentWorkStep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkStep.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEPS_CALCULATION
        );
        WorkStepsRescueCalculationService.execute(new List<Notifier__e>{ mockNotifierEvent });
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<sObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty((List<sObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<WorkStep> capturedArguments = (List<WorkStep>) capturedInsertUOWArguments.getValue();
        System.assertEquals(1, capturedArguments.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            newWorkSteps[0].Id,
            capturedArguments[0].Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Number_of_Blocked_Work_Steps__c,
            capturedArguments[0].Number_of_Blocked_Work_Steps__c,
            BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Number_of_Resolved_Work_Steps__c,
            capturedArguments[0].Number_of_Resolved_Work_Steps__c,
            RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Secondary_Email_Timer_Start_Time__c.dateGMT(),
            capturedArguments[0].Secondary_Email_Timer_Start_Time__c.dateGMT(),
            SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test calculation of number of blocked and number of resolved child WorkSteps
     * along with secondary email timer start time on parent WorkStep
     * when NotifierEvent is captured for blocked and resolved child Work Steps.
     */
    @isTest
    private static void testWhenNotifierEventPayloadReceivedForBlockedAndResolvedChildWorkStepsThenCorrectFieldsUpdatedOnParentWorkStep() {
        Fake newParentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_RESOLVED
            )
            .setField(WorkStep.Number_of_Blocked_Work_Steps__c, 1)
            .setField(WorkStep.Secondary_Email_Timer_Start_Time__c, System.now())
            .setField(WorkStep.Secondary_Email_Next_Schedule__c, System.now());
        WorkStep newParentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newParentWorkStepFakeInstance
        );
        Fake parentWorkStepWithStatusUpdateFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Number_of_Blocked_Work_Steps__c, 1)
            .setField(WorkStep.Secondary_Email_Timer_Start_Time__c, System.now() - 1)
            .setField(WorkStep.Secondary_Email_Next_Schedule__c, System.now() - 1);
        WorkStep parentWorkStepWithStatusUpdate = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepWithStatusUpdateFakeInstance
        );
        Aggregate mockAggregateResolvedParentWorkStep = new Aggregate();
        mockAggregateResolvedParentWorkStep.put(
            AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS,
            newParentWorkStep.Id
        );
        mockAggregateResolvedParentWorkStep.put(
            AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS,
            WORK_STEP_STATUS_RESOLVED
        );
        mockAggregateResolvedParentWorkStep.put(AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS, 1);
        List<Aggregate> mockAggregates = new List<Aggregate>{ mockAggregateResolvedParentWorkStep };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = newParentWorkStep.Id,
                Number_of_Blocked_Work_Steps__c = 0,
                Number_of_Resolved_Work_Steps__c = 1,
                Secondary_Email_Timer_Start_Time__c = null
            ),
            new WorkStep(
                Id = parentWorkStepWithStatusUpdate.Id,
                Number_of_Blocked_Work_Steps__c = 0,
                Number_of_Resolved_Work_Steps__c = 0,
                Secondary_Email_Timer_Start_Time__c = null
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(
                    new Set<Id>{ newParentWorkStep.Id, parentWorkStepWithStatusUpdate.Id }
                )
            )
            .thenReturn(mockAggregates);
        mocks.when(
                mockWorkStepsSelector.selectById(
                    new Set<Id>{ newParentWorkStep.Id, parentWorkStepWithStatusUpdate.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ newParentWorkStep, parentWorkStepWithStatusUpdate });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        String eventPayload = JSON.serialize(
            new Set<Id>{ newParentWorkStep.Id, parentWorkStepWithStatusUpdate.Id }
        );
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEPS_CALCULATION
        );
        WorkStepsRescueCalculationService.execute(new List<Notifier__e>{ mockNotifierEvent });

        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<sObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty((List<sObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<WorkStep> capturedArguments = (List<WorkStep>) capturedInsertUOWArguments.getValue();
        System.assertEquals(2, capturedArguments.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            newWorkSteps[0].Id,
            capturedArguments[0].Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Number_of_Blocked_Work_Steps__c,
            capturedArguments[0].Number_of_Blocked_Work_Steps__c,
            BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Number_of_Resolved_Work_Steps__c,
            capturedArguments[0].Number_of_Resolved_Work_Steps__c,
            RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[0].Secondary_Email_Timer_Start_Time__c,
            capturedArguments[0].Secondary_Email_Timer_Start_Time__c,
            SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[1].Id,
            capturedArguments[1].Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[1].Number_of_Blocked_Work_Steps__c,
            capturedArguments[1].Number_of_Blocked_Work_Steps__c,
            BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[1].Number_of_Resolved_Work_Steps__c,
            capturedArguments[1].Number_of_Resolved_Work_Steps__c,
            RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newWorkSteps[1].Secondary_Email_Timer_Start_Time__c,
            capturedArguments[1].Secondary_Email_Timer_Start_Time__c,
            SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}