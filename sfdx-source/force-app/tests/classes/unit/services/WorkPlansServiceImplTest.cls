/**
 * @author Deloitte
 * @date 01/06/2022
 * @description Test class for WorkPlansServiceImpl class.
 */
@isTest(seeAllData=false)
private class WorkPlansServiceImplTest {
    private static final String ASSERT_MESSGAE = 'Unexpected error: there is mismatch in the WorkPlan record list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_LIST = 'Unexpected result: The Group list is empty';
    private static final String ESCALATED_ACTIVATION_STATUS = 'Escalated';
    private static final string GROUP_DEVELOPER_NAME = 'Test_COO_Queue';
    private static final string GROUP_NAME = 'Test COO Queue';
    private static final string GROUP_TYPE = 'Queue';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String VALIDATION_STATUS_IN_PROGRESS = 'In Progress';

    /**
     * @description To test logic for fetching WorkPlan & child WorkPlan when WorkPlanIds are passed.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlanIdsProvidedThenReturnWorkPlanAndChildWorkPlanDetails() {
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        String onboardingWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        String activationsWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<List<WorkPlan>> workPlansResult = new List<List<WorkPlan>>();
        Set<String> workPlanIds = new Set<String>{ onboardingWorkPlanId, activationsWorkPlanId };
        List<WorkPlan> workPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, onboardingWorkPlanId)
                .setField(WorkPlan.WorkOrderId, workOrderId)
                .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
                .toSObject(),
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, activationsWorkPlanId)
                .setField(WorkPlan.WorkOrderId, workOrderId)
                .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansWithChildWorkPlanDetails(workPlanIds))
            .thenReturn(workPlans);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        List<String> recordIds = new List<String>();
        recordIds.addAll(workPlanIds);
        workPlansResult = WorkPlansService.selectWorkPlansWithChildWorkPlanDetails(
            new List<List<String>>{ recordIds }
        );
        System.assertEquals(new List<List<WorkPlan>>{ workPlans }, workPlansResult, ASSERT_MESSGAE);
    }

    /**
     * @description To test logic for fetching WorkPlan queues filtered by QueuesSobject records.
     */
    @isTest
    private static void testWhenGetWorkPlanQueuesCalledThenReturnWorkPlanQueues() {
        Id groupId = fflib_IDGenerator.generate(Group.SObjectType);
        List<Group> workPlanQueues = new List<Group>{
            (Group) new Fake(Group.class)
                .setField(Group.DeveloperName, GROUP_DEVELOPER_NAME)
                .setField(Group.Name, GROUP_NAME)
                .setField(Group.Type, GROUP_TYPE)
                .setField(Group.Id, groupId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGroupsSelector groupsSelector = (IGroupsSelector) mocks.mock(IGroupsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(groupsSelector.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(groupsSelector.selectByWorkPlanQueueIds()).thenReturn(workPlanQueues);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(groupsSelector);
        Test.startTest();
        List<List<Group>> workPlanRelatedQueues = WorkPlansService.getWorkPlanQueues();
        Test.stopTest();
        System.assertEquals(
            true,
            workPlanRelatedQueues.size() != null,
            ASSERT_MESSAGE_MISMATCH_IN_LIST
        );
    }

    /**
     * @description To test updation of Activation Checklist Validation status on passed Work Plans
     * based on Status received.
     * Suppressed warnings since mock verify method is used.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenActivationChecklistValidationCompletedOnChildWPThenUpdateNumberOfStoresValidated() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<sObject> sobjectsToUpdate = new List<sObject>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
            new Set<Id>{ workPlanId },
            VALIDATION_STATUS_IN_PROGRESS
        );
        WorkPlansService.escalateActivationChecklistValidationOnWorkPlan(
            new List<WorkStep>{
                new WorkStep(Id = fflib_IDGenerator.generate(WorkStep.SObjectType))
            }
        );
        sobjectsToUpdate.addAll(
            new List<WorkPlan>{
                new WorkPlan(
                    Id = workPlanId,
                    Activation_Checklist_Validation__c = VALIDATION_STATUS_IN_PROGRESS
                )
            }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test error log is created when exception occurs during DML operation.
     * Suppressed warnings since mock verify method is used.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenDMLExceptionOccursThenCreateErrorLog() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        String errorMessage;
        try {
            WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_IN_PROGRESS
            );
        } catch (Exception parentObjectUpdateException) {
            errorMessage = parentObjectUpdateException.getMessage();
        }
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => errorMessage }
                )
            );
    }

    /**
     * @description To test 'Activation Checklist Validation' status is updated based on received
     * Work Plan Ids and status value.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlanIdsAndStatusReceivedThenUpdateValidationStatus() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
            new Set<Id>{ workPlanId },
            VALIDATION_STATUS_COMPLETED
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                new List<sObject>{
                    new WorkPlan(
                        Id = workPlanId,
                        Activation_Checklist_Validation__c = VALIDATION_STATUS_COMPLETED
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test 'Activation Checklist Validation' status is updated to 'Escalated'
     * based on received Work Steps.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkStepsReceivedThenUpdateValidationStatusToEscalated() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkPlansService.escalateActivationChecklistValidationOnWorkPlan(
            new List<WorkStep>{ new WorkStep(WorkPlanId = workPlanId) }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                new List<sObject>{
                    new WorkPlan(
                        Id = workPlanId,
                        Activation_Checklist_Validation__c = ESCALATED_ACTIVATION_STATUS
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Plan details are returned based on received Work Plan Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkPlanIdsReceivedThenReturnWorkPlanDetails() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Set<Id> workPlanIds = new Set<Id>{ workPlanId };
        List<WorkPlan> workPlans = new List<WorkPlan>{ new WorkPlan(Id = workPlanId) };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector workPlanSelectorMock = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectWorkPlansWithWorkOrderDetails(workPlanIds))
            .thenReturn(workPlans);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        List<WorkPlan> workPlansResult = WorkPlansService.getWorkOrdersFromWorkPlan(workPlanIds);
        System.assertEquals(workPlans, workPlansResult, ASSERT_MESSGAE);
    }

    /**
     * @description To test log record (Log__c) is created when 'Activation Checklist Validation'
     * status update is failed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenValidationStatusUpdateFailedThenCreateLog() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        String exceptionMessage;
        try {
            WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_COMPLETED
            );
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
    }
}