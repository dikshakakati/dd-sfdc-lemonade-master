/**
 * @author Deloitte
 * @date 06/07/2024
 * @description Test class for WorkOrderCreationTriggerServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
private class WorkOrderCreationTriggerServiceImplTest {
    private static final Integer GENERIC_WORK_ORDER_CREATION_CHUNK_SIZE = 40;
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';

    /**
     * @description To test when SObject Ids are passed then create Interface Transaction using passed Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSObjectIdsPassedThenCreateInterfaceTransaction() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId3 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Set<Id> sObjectIds = new Set<Id>{ subscriptionId1, subscriptionId2, subscriptionId3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        WorkOrderCreationTriggerService.initiateWorkOrderCreation(
            sObjectIds,
            GENERIC_WORK_ORDER_CREATION
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when SObject Ids and Event Topic is passed then create Onboarding Activations
     * Platform Event.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSObjectIdsAndEventTopicPassedThenCreateOnboardingActivationsPlatformEvent() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SobjectType
        );
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId3 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Set<Id> sObjectIds = new Set<Id>{
            subscriptionId1,
            subscriptionId2,
            subscriptionId3,
            interfaceTransactionId
        };
        List<String> eventPayload = new List<String>{ JSON.serialize(sObjectIds) };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsService = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    sObjectIds,
                    GENERIC_WORK_ORDER_CREATION_CHUNK_SIZE
                )
            )
            .thenReturn(eventPayload);
        mocks.stopStubbing();
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsService
        );
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );
        Test.startTest();
        WorkOrderCreationTriggerService.fireonboardingActivationsEventsForWorkOrderCreation(
            sObjectIds,
            GENERIC_WORK_ORDER_CREATION
        );
        Test.stopTest();
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingActivationsEventsService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{ GENERIC_WORK_ORDER_CREATION => eventPayload }
            );
    }
}