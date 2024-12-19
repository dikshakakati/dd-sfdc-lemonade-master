/**
 * @author Deloitte
 * @date 04/05/2022
 * @description Test class for ActivationCheckValidationController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ActivationCheckValidationControllerTest {
    private static final String ASSERT_MESSAGE_WORK_STEPS_NOT_RETRIEVED = 'Unexpected Result: Work Steps presence not identified.';
    private static final String ASSERT_MESSAGE_PROGRESS_MESSAGE_NOT_RECEIVED = 'Unexpected Result: Expected Message not received.';
    private static final String ERROR_KEY = 'error';
    private static final String MESSAGE_KEY = 'message';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Cannot send API Callout.';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_KEY = 'status';
    private static final String WORK_STEP_TYPE_ACTIVATION_CHECKLIST = 'Activations Checklist';
    private static final String WORK_STEP_TYPE_MENU = 'Setup Menu';

    /**
     * @description To test validation returns true when child Activations Checklist Work Steps
     * present for passed parent Work Plan Id.
     */
    @isTest
    private static void testWhenChildActivationChecklistWorkStepsPresentThenReturnTrue() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATION_CHECKLIST)
            .setField(WorkStep.Store_Account__c, storeAccountId)
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep childWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            childWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectChildWorkStepsByWorkPlan(
                    workPlanId,
                    WORK_STEP_TYPE_ACTIVATION_CHECKLIST
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Boolean hasWorkStep = ActivationCheckValidationController.hasActivationsCheckListForSelectedWorkPlan(
            workPlanId
        );
        System.assertEquals(true, hasWorkStep, ASSERT_MESSAGE_WORK_STEPS_NOT_RETRIEVED);
    }

    /**
     * @description To test Success message is returned when child Work Steps are present
     * and validation is in progress.
     */
    @isTest
    private static void testWhenChildActivationChecklistWorkStepsPresentThenReturnSuccessMessage() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATION_CHECKLIST)
            .setField(WorkStep.Store_Account__c, storeAccountId)
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep childWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            childWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectChildWorkStepsByWorkPlan(
                    workPlanId,
                    WORK_STEP_TYPE_ACTIVATION_CHECKLIST
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Map<String, Object> successMessage = ActivationCheckValidationController.getChildActivationChecklistWorkSteps(
            workPlanId
        );
        System.assertEquals(
            System.Label.Activation_Checklist_Validation_In_progress,
            String.valueOf(successMessage.get(MESSAGE_KEY)),
            ASSERT_MESSAGE_PROGRESS_MESSAGE_NOT_RECEIVED
        );
    }

    /**
     * @description To test Warning message is returned when child Work Steps are not present
     * and validation is not started.
     */
    @isTest
    private static void testWhenChildActivationChecklistWorkStepsNotPresentThenReturnWarningMessage() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectChildWorkStepsByWorkPlan(
                    workPlanId,
                    WORK_STEP_TYPE_ACTIVATION_CHECKLIST
                )
            )
            .thenReturn(new List<WorkStep>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Map<String, Object> successMessage = ActivationCheckValidationController.getChildActivationChecklistWorkSteps(
            workPlanId
        );
        System.assertEquals(
            System.Label.Activation_Checklist_No_WorkStep_Found,
            String.valueOf(successMessage.get(MESSAGE_KEY)),
            ASSERT_MESSAGE_PROGRESS_MESSAGE_NOT_RECEIVED
        );
    }

    /**
     * @description To test Error message is returned when error occurs
     * when sending paylod for validation.
     */
    @isTest
    private static void testWhenExceptionOccursThenReturnErrorMessage() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATION_CHECKLIST)
            .setField(WorkStep.Store_Account__c, storeAccountId)
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep childWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            childWorkStepFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectChildWorkStepsByWorkPlan(
                    workPlanId,
                    WORK_STEP_TYPE_ACTIVATION_CHECKLIST
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        ((IWorkStepsService) mocks.doThrowWhen(
                new OutboundIntegrationException(MOCK_EXCEPTION_MESSAGE),
                workStepsServiceMock
            ))
            .collectChildActivationChecklistWorkStepsForOutboundIntegration(
                new Set<Id>{ childWorkStepId }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Map<String, Object> successMessage = ActivationCheckValidationController.getChildActivationChecklistWorkSteps(
            workPlanId
        );
        System.assertEquals(
            ERROR_KEY,
            String.valueOf(successMessage.get(STATUS_KEY)),
            ASSERT_MESSAGE_PROGRESS_MESSAGE_NOT_RECEIVED
        );
    }

    /**
     * @description To test validation returns true when dependee Work Steps exists for the passed
     * Work Plan Id.
     */
    @isTest
    private static void testWhenDependeeWorkStepsPresentThenReturnTrue() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepDependencyId = fflib_IDGenerator.generate(WorkStepDependency__c.SObjectType);
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Plan_Id__c;
        WorkStepDependency__c workStepDependencyFakeInstance = (WorkStepDependency__c) new Fake(
                WorkStepDependency__c.class
            )
            .setField(WorkStepDependency__c.Id, workStepDependencyId)
            .setParent(
                'Dependee_Work_Step__r',
                new Fake(WorkStep.class).setField(WorkStep.Name, WORK_STEP_TYPE_MENU)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesSelector workStepDependenciesSelectorMock = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepDependenciesSelectorMock.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                workStepDependenciesSelectorMock.selectDependeeWorkStepsByDependentSobjectIds(
                    new Set<Id>{ workPlanId },
                    fieldToFilter
                )
            )
            .thenReturn(new List<WorkStepDependency__c>{ workStepDependencyFakeInstance });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepDependenciesSelectorMock);
        Boolean hasDependeeWorkStep = ActivationCheckValidationController.hasOpenDependentWorkPlan(
            workPlanId
        );
        System.assertEquals(true, hasDependeeWorkStep, ASSERT_MESSAGE_WORK_STEPS_NOT_RETRIEVED);
    }

    /**
     * @description Exception type thrown if there is an issue with the outbound integration.
     **/
    public class OutboundIntegrationException extends Exception {
    }
}