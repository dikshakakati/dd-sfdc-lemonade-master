/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Test class for OnboardingActivationsEventsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class OnboardingActivationsEvntServiceImplTest {
    /**
     * @description To test creation of Onboarding and Activations events on publishEvents method call
     * with UOW instance and payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenOnboardingActivationsEventPublished() {
        Set<Id> mockParentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(mockParentWorkOrderIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishEvents(mockPayload, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Onboarding and Activations events on publishEvents method call with payload.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenOnboardingActivationsEventPublished() {
        Set<Id> mockParentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(mockParentWorkOrderIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Onboarding and Activations event is not published on publishEvents method call with
     * UOW instance and payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenOnboardingActivationsEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Onboarding and Activations event is not published on publishEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenOnboardingActivationsEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test creation of Onboarding and Activations events on publishBulkEvents method call with payloads.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithPayloadThenOnboardingActivationsEventPublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'WORK_ORDER_STORES_CALCULATION' => mockMergedPayloads
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishBulkEvents(mockPayload);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Onboarding and Activations event is not published on publishBulkEvents method call with
     * payload as null.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithNullPayloadThenOnboardingActivationsEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OnboardingActivationsEventsService.publishBulkEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
    /**
     * @description To test Generic log
     * call with list of payloads, and only 1 commit.
     */
    @isTest
    private static void testWhenGetGenericLogThenPublishGenericLog() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Exception commitException = new System.DmlException();
		commitException.setMessage('Error occured');

        OnboardingActivationsEventsServiceImpl.genericLogList.add(
            OnboardingActivationsEventsServiceImpl.getGenericLog().logException(commitException));
            OnboardingActivationsEventsServiceImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }
}