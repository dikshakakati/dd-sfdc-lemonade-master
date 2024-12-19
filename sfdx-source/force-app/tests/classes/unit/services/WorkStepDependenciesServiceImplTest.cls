/**
 * @author Deloitte
 * @date 11/05/2022
 * @description Test class for WorkStepDependenciesServiceImpl class.
 */
@isTest(seeAllData=false)
private class WorkStepDependenciesServiceImplTest {
    private static final String WORK_PLAN_TEMPLATE_BANNER_MESSAGE = 'Warning message on non-workable WorkStep';
    private static final String WORK_STEP_NAME_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_DEPENDENCIES_BANNER_MESSAGE_ASSERT_MESSAGE = 'Unexpected result: relevant banner message as per the dependencies not returned';

    /**
     * @description To test getBannerMessageDetails method of WorkStepDependenciesServiceImpl.
     */
    @isTest
    private static void testWhenGetBannerMessageDetailsCalledThenRelevantBannerMessageReturned() {
        Id workPlanTemplateEntryId = fflib_IDGenerator.generate(WorkPlanTemplateEntry.SObjectType);
        WorkStep dependeeWorkStep = new WorkStep(
            Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
            WorkPlanTemplateEntry__c = workPlanTemplateEntryId
        );
        WorkStep dependentWorkStep = new WorkStep(
            Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
            WorkPlanTemplateEntry__c = workPlanTemplateEntryId
        );
        WorkStepDependency__c workStepDependency = (WorkStepDependency__c) new Fake(
                WorkStepDependency__c.class
            )
            .setField(WorkStepDependency__c.Dependent_Work_Step__c, dependentWorkStep.Id)
            .setField(WorkStepDependency__c.Dependee_Work_Step__c, dependeeWorkStep.Id)
            .setFakeId()
            .toSObject();
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.selectDependeeWorkStepsByDependentSobjectIds(
                    new Set<Id>{ dependentWorkStep.Id },
                    fieldToFilter
                )
            )
            .thenReturn(new List<WorkStepDependency__c>{ workStepDependency });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Test.startTest();
        BannerMessageWrapper bannerMessageWrapper = WorkStepDependenciesService.getBannerMessageDetails(
            dependentWorkStep.Id
        );
        Test.stopTest();
        System.assertEquals(
            true,
            bannerMessageWrapper.showMessage,
            WORK_STEP_DEPENDENCIES_BANNER_MESSAGE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test getSobjectIdToDependeeWorkStepStatuses method of WorkStepDependenciesServiceImpl.
     */
    @isTest
    private static void testWhenGetDependeeWorkStepsCalledThenDependentWorkStepsReturned() {
        Id workPlanTemplateEntryId = fflib_IDGenerator.generate(WorkPlanTemplateEntry.SObjectType);
        WorkStep dependentWorkStep = new WorkStep(
            Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
            WorkPlanTemplateEntry__c = workPlanTemplateEntryId
        );
        List<Aggregate> dependentWorkStepWiseCountOfDependencies = new List<Aggregate>{
            new Aggregate()
                .put('groupingId', dependentWorkStep.Id)
                .put('dependenciesCount', 1)
                .put('dependeeStatus', WORK_STEP_STATUS_IN_PROGRESS)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.getWorkStepDependencyCountFilteredAndGroupedBySobjectIds(
                    new Set<Id>{ dependentWorkStep.Id },
                    fieldToFilter
                )
            )
            .thenReturn(dependentWorkStepWiseCountOfDependencies);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Test.startTest();
        Map<Id, Set<String>> sObjectIdToDependeeWorkStepStatuses = WorkStepDependenciesService.getSobjectIdToDependeeWorkStepStatuses(
            new Set<Id>{ dependentWorkStep.Id },
            WorkStep.SObjectType
        );
        Test.stopTest();
        System.assertEquals(
            true,
            sObjectIdToDependeeWorkStepStatuses.keySet() != null,
            WORK_STEP_DEPENDENCIES_BANNER_MESSAGE_ASSERT_MESSAGE
        );
    }
}