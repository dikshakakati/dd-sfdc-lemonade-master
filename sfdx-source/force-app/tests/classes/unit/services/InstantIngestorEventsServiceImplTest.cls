/**
 * @description Test class for InstantIngestorEventsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 * @author Deloitte
 * @date 05/14/2024
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InstantIngestorEventsServiceImplTest {
    private static final String FAILED_ASSERTION_MESSAGE = 'Assertion Failed';
    /**
     * @description Tests publishing events with UOW and payload using default event type (ADS_PROMOS).
     * Verifies that Instant_Ingestor__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndPayloadThenInstantIngestorEventPublishedByDefault() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        Instant_Ingestor__e expectedResult = new Instant_Ingestor__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(mockPayload, mockUOW);

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with UOW and payload for POSTSALES event type.
     * Verifies that PostSalesTransaction__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPostSalesAndPublishEventsCalledWithUOWAndPayloadThenPostSalesTransactionEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        PostSalesTransaction__e expectedResult = new PostSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(
            mockPayload,
            mockUOW,
            PostSalesTransaction__e.SObjectType
        );

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with UOW and payload for PRESALES event type.
     * Verifies that PreSalesTransaction__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPreSalesAndPublishEventsCalledWithUOWAndPayloadThenPostSalesTransactionEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        PreSalesTransaction__e expectedResult = new PreSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(
            mockPayload,
            mockUOW,
            PreSalesTransaction__e.SObjectType
        );

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with payload using default event type (ADS_PROMOS).
     * Verifies that Instant_Ingestor__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPayloadThenInstantIngestorEventPublishedByDefault() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        Instant_Ingestor__e expectedResult = new Instant_Ingestor__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(mockPayload);

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with payload for POSTSALES event type.
     * Verifies that PostSalesTransaction__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPostSalesAndPublishEventsCalledWithPayloadThenPostSalesTransactionEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        PostSalesTransaction__e expectedResult = new PostSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(
            mockPayload,
            PostSalesTransaction__e.SObjectType
        );

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with payload for PRESALES event type.
     * Verifies that PreSalesTransaction__e event is created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPreSalesAndPublishEventsCalledWithPayloadThenPreSalesTransactionEventPublished() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };

        PreSalesTransaction__e expectedResult = new PreSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = JSON.serialize(instantIngestorLogIds)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(mockPayload, PreSalesTransaction__e.SObjectType);

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e event
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult);
    }

    /**
     * @description Tests publishing events with UOW and null payload.
     * Verifies that no event is published.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithUOWAndNullPayloadThenNotifierEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(null, mockUOW);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description Tests publishing events with null payload.
     * Verifies that no event is published.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithNullPayloadThenInstantIngestorEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description Tests publishing events when event type is null.
     * Verifies that an InstantIngestorEventsServiceException is thrown.
     */
    @isTest
    private static void testWhenEventTypeIsNullAndPublishEventsCalledWithPayloadThenThrowException() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, String> mockPayload = new Map<String, String>{
            'WORK_ORDER_STORES_CALCULATION' => JSON.serialize(instantIngestorLogIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.eventType = null;

        try {
            InstantIngestorEventsService.publishEvents(mockPayload);
            Assert.fail(
                'Expected an instance of InstantIngestorEventsServiceException but did not receive any exceptions'
            );
        } catch (InstantIngestorEventsServiceImpl.InstantIngestorEventsServiceException e) {
            String expectedErrorMessage = 'Unable to determine the proper platform event to use for this use case.  The event type returned null.';
            Assert.areEqual(expectedErrorMessage, e.getMessage(), FAILED_ASSERTION_MESSAGE);
        } catch (Exception e) {
            Assert.fail(
                'Expected an instance of InstantIngestorEventsServiceException but received: ' +
                e.getMessage()
            );
        }

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description Tests bulk publishing of events using default event type (ADS_PROMOS).
     * Verifies that multiple Instant_Ingestor__e events are created and registered for publishing.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithPayloadThenInstantIngestorEventsArePublishedByDefault() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'WORK_ORDER_STORES_CALCULATION' => mockMergedPayloads
        };

        Instant_Ingestor__e expectedResult1 = new Instant_Ingestor__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[0]
        );
        Instant_Ingestor__e expectedResult2 = new Instant_Ingestor__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[1]
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishBulkEvents(mockPayload);

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e events
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult1);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult2);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
    }

    /**
     * @description Tests bulk publishing of events for POSTSALES event type.
     * Verifies that multiple PostSalesTransaction__e events are created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPostSaleAndPublishBulkEventsCalledWithPayloadThenPostSalesTransactionEventsArePublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'WORK_ORDER_STORES_CALCULATION' => mockMergedPayloads
        };

        PostSalesTransaction__e expectedResult1 = new PostSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[0]
        );
        PostSalesTransaction__e expectedResult2 = new PostSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[1]
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishBulkEvents(
            mockPayload,
            PostSalesTransaction__e.SObjectType
        );

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e events
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult1);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult2);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
    }

    /**
     * @description Tests bulk publishing of events for PRESALES event type.
     * Verifies that multiple PreSalesTransaction__e events are created and registered for publishing.
     */
    @isTest
    private static void testWhenEventTypeIsPreSaleAndPublishBulkEventsCalledWithPayloadThenPreSalesTransactionEventsArePublished() {
        List<String> mockMergedPayloads = new List<String>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        Map<String, List<String>> mockPayload = new Map<String, List<String>>{
            'WORK_ORDER_STORES_CALCULATION' => mockMergedPayloads
        };

        PreSalesTransaction__e expectedResult1 = new PreSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[0]
        );
        PreSalesTransaction__e expectedResult2 = new PreSalesTransaction__e(
            Topic__c = 'WORK_ORDER_STORES_CALCULATION',
            Payload__c = mockMergedPayloads[1]
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishBulkEvents(
            mockPayload,
            PreSalesTransaction__e.SObjectType
        );

        // Verify that commitWork was called
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        // Verify that registerPublishAfterSuccessTransaction was called with the correct Instant_Ingestor__e events
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult1);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(expectedResult2);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
    }

    /**
     * @description Tests bulk publishing of events with null payload.
     * Verifies that no events are published.
     */
    @isTest
    private static void testWhenPublishBulkEventsCalledWithNullPayloadThenInstantIngestorEventNotPublished() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InstantIngestorEventsService.publishBulkEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description Tests the generic logging functionality.
     * Verifies that a generic log is created and published.
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

        InstantIngestorEventsServiceImpl.genericLogs.add(
            InstantIngestorEventsServiceImpl.getGenericLog().logException(commitException)
        );
        InstantIngestorEventsServiceImpl.publishGenericLog();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description Tests the setPlatformEventType method for valid and invalid SObjectTypes.
     * Verifies that the correct PlatformEventType is set for valid SObjectTypes and
     * that an exception is thrown for invalid SObjectTypes.
     */
    @isTest
    private static void testWhenSetPlatformEventTypeCalledWithValidAndInvalidSObjectTypesThenCorrectEventTypesSetAndExceptionThrown() {
        InstantIngestorEventsServiceImpl service = new InstantIngestorEventsServiceImpl();

        // Test with PreSalesTransaction__e
        service.setPlatformEventType(PreSalesTransaction__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.PRESALES,
            InstantIngestorEventsService.eventType,
            'Event type should be set to PRESALES for PreSalesTransaction__e'
        );

        // Test with PostSalesTransaction__e
        service.setPlatformEventType(PostSalesTransaction__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.POSTSALES,
            InstantIngestorEventsService.eventType,
            'Event type should be set to POSTSALES for PostSalesTransaction__e'
        );

        // Test with Instant_Ingestor__e
        service.setPlatformEventType(Instant_Ingestor__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.ADS_PROMOS,
            InstantIngestorEventsService.eventType,
            'Event type should be set to ADS_PROMOS for Instant_Ingestor__e'
        );

        // Test with an invalid SObjectType (e.g., Account)
        try {
            service.setPlatformEventType(Account.SObjectType);
            System.assert(false, 'An exception should have been thrown for an invalid SObjectType');
        } catch (InstantIngestorEventsServiceImpl.InstantIngestorEventsServiceException e) {
            System.assertEquals(
                'The provided platformEventType is unknown.  Received: Account',
                e.getMessage(),
                'Exception message should match for invalid SObjectType'
            );
        }
    }

    /**
     * @description Tests the setPlatformEventType method of InstantIngestorEventsService for valid and invalid SObjectTypes.
     * Verifies that the correct PlatformEventType is set for valid SObjectTypes and
     * that an exception is thrown for invalid SObjectTypes.
     */
    @isTest
    private static void testWhenSetPlatformEventTypeCalledOnServiceWithValidAndInvalidSObjectTypesThenCorrectEventTypesSetAndExceptionThrown() {
        // Test with PreSalesTransaction__e
        InstantIngestorEventsService.setPlatformEventType(PreSalesTransaction__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.PRESALES,
            InstantIngestorEventsService.eventType,
            'Event type should be set to PRESALES for PreSalesTransaction__e'
        );

        // Test with PostSalesTransaction__e
        InstantIngestorEventsService.setPlatformEventType(PostSalesTransaction__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.POSTSALES,
            InstantIngestorEventsService.eventType,
            'Event type should be set to POSTSALES for PostSalesTransaction__e'
        );

        // Test with Instant_Ingestor__e
        InstantIngestorEventsService.setPlatformEventType(Instant_Ingestor__e.SObjectType);
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.ADS_PROMOS,
            InstantIngestorEventsService.eventType,
            'Event type should be set to ADS_PROMOS for Instant_Ingestor__e'
        );

        // Test with an invalid SObjectType (e.g., Account)
        try {
            InstantIngestorEventsService.setPlatformEventType(Account.SObjectType);
            System.assert(false, 'An exception should have been thrown for an invalid SObjectType');
        } catch (InstantIngestorEventsServiceImpl.InstantIngestorEventsServiceException e) {
            System.assertEquals(
                'The provided platformEventType is unknown.  Received: Account',
                e.getMessage(),
                'Exception message should match for invalid SObjectType'
            );
        }

        // Verify that setting an invalid SObjectType doesn't change the previous valid setting
        System.assertEquals(
            InstantIngestorEventsService.PlatformEventType.ADS_PROMOS,
            InstantIngestorEventsService.eventType,
            'Event type should remain ADS_PROMOS after attempting to set an invalid SObjectType'
        );
    }
}