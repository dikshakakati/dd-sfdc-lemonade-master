/**
 * @author Deloitte
 * @date 11/05/2022
 * @description Test class for WorkStepDependenciesWarningBannerCtrl class.
 * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkStepDependenciesWarningBannerCtlTest {
    private static final String TEST_BANNER_MESSAGE = 'Warning message on non-workable WorkStep';

    /**
     * @description To test dependency banner message on non-workable WorkStep.
     */
    @isTest
    private static void testWhenGetBannerMessageDetailsThenRelevantBannerMessageIsReturned() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        BannerMessageWrapper bannerMessageWrapper = new BannerMessageWrapper(
            true,
            TEST_BANNER_MESSAGE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesService mockWorkStepDependenciesService = (IWorkStepDependenciesService) mocks.mock(
            IWorkStepDependenciesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesService.getBannerMessageDetails(workStepId))
            .thenReturn(bannerMessageWrapper);
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IWorkStepDependenciesService.class,
            mockWorkStepDependenciesService
        );
        Test.startTest();
        WorkStepDependenciesWarningBannerCtrl.getBannerMessageDetails(workStepId);
        Test.stopTest();
        ((IWorkStepDependenciesService) mocks.verify(mockWorkStepDependenciesService, 1))
            .getBannerMessageDetails(workStepId);
    }
}