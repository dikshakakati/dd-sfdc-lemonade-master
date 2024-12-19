/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Test class for InstantIngestorEventsHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InstantIngestorEventsHandlerTest {
    private static final String CLASS_NAME = 'SSMOOnboardingService';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Instant Ingestor Event is already published';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: failed to publish Instant Ingestor Event';
    private static final String EVENT_TOPIC_SSMO_ACCOUNT_CREATION = 'EVENT_TOPIC_SSMO_ACCOUNT_CREATION';
    private static final String EVENT_TOPIC_SSMO_XREF_CREATION = 'EVENT_TOPIC_SSMO_XREF_CREATION';
    private static final String EVENT_TOPIC_NO_IMPLEMENTATION = 'NO_IMPLEMENTATION_TOPIC';
    private static final String LOG_TYPE = 'fflib_Application.DeveloperException';
    private static final String LOG_MESSAGE =
        'No implementation registered for event topic ' + EVENT_TOPIC_NO_IMPLEMENTATION;

    /**
     * @description To test execute method of InstantIngestorEvents handler class
     * is called on InstantIngestor event publish.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>{
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = 'SSMOOnboardingService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleInstantIngestorEvents handleInstantIngestorEventsMock = (IHandleInstantIngestorEvents) mocks.mock(
            IHandleInstantIngestorEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IInstantIngestorEventBindingsSelector selectorMock = (IInstantIngestorEventBindingsSelector) mocks.mock(
            IInstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Instant_Ingestor_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_XREF_CREATION,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(mockInstantIngestorEvent);
    }

    /**
     * @description To test execute method of InstantIngestorEvents handler class for multiple topics
     * is called on multiple InstantIngestor event publish.
     */
    @isTest
    private static void testWhenMultiplateTopicsWithImplementationPassedThenExecuteSingleTopic() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };

        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>{
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            ),
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = CLASS_NAME,
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleInstantIngestorEvents handleInstantIngestorEventsMock = (IHandleInstantIngestorEvents) mocks.mock(
            IHandleInstantIngestorEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IInstantIngestorEventBindingsSelector selectorMock = (IInstantIngestorEventBindingsSelector) mocks.mock(
            IInstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Instant_Ingestor_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_XREF_CREATION,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);

        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(
                new List<Instant_Ingestor__e>{
                    mockInstantIngestorEvent[0],
                    mockInstantIngestorEvent[1]
                }
            );
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute((List<Instant_Ingestor__e>) fflib_Match.anyList());
    }

    /**
     * @description To test scope size executed for InstantIngestor events.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenVerifyScopeSizeExecuted() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>();
        List<Instant_Ingestor__e> mockInstantIngestorEventWithinScope = new List<Instant_Ingestor__e>();

        for (Integer i = 0; i < 400; i++) {
            Instant_Ingestor__e instantIngestorRecord = new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_ACCOUNT_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            );
            mockInstantIngestorEvent.add(instantIngestorRecord);
            if (i < 200) {
                mockInstantIngestorEventWithinScope.add(instantIngestorRecord);
            }
        }

        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = 'SSMOOnboardingService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_ACCOUNT_CREATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IHandleInstantIngestorEvents handleInstantIngestorEventsMock = (IHandleInstantIngestorEvents) mocks.mock(
            IHandleInstantIngestorEvents.class
        );
        InstantIngestorEventBindingsSelector selectorMock = (InstantIngestorEventBindingsSelector) mocks.mock(
            InstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Instant_Ingestor_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_ACCOUNT_CREATION,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(mockInstantIngestorEventWithinScope);
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute((List<Instant_Ingestor__e>) fflib_Match.anyList());
    }

    /**
     * @description To verify when topic without implementation is passed then an exception is thrown.
     */
    @isTest
    private static void testWhenTopicWithoutImplementationPassedThenExceptionIsThrown() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>{
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_NO_IMPLEMENTATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => LOG_TYPE,
                        Log__c.Detailed_Message__c => LOG_MESSAGE,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.MEDIUM.name()
                    }
                )
            );
    }

    /**
     * @description Tests the handling of PostSalesTransaction__e events in the InstantIngestorEventsHandler.
     * This test verifies that when a PostSalesTransaction__e event is inserted:
     * 1. The handler correctly processes the event.
     * 2. The event is transformed into an equivalent Instant_Ingestor__e event.
     * 3. The corresponding service method (execute) is called with the transformed event.
     * This ensures that the PostSalesTransaction__e events are properly routed and processed
     * in the same manner as the original Instant_Ingestor__e events.
     */
    @isTest
    private static void testWhenPostSalesTransactionEventWithTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        // This event type gets saved to the DB and initiates the trigger
        List<PostSalesTransaction__e> mockPostSalesTransactionEvent = new List<PostSalesTransaction__e>{
            new PostSalesTransaction__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };
        // The PostSalesTransaction__e events will get translated into an instance of the Instant_Ingestor__e event
        // and that is what will get passed to the instance of IHandleInstantIngestorEvents
        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>{
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = 'SSMOOnboardingService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleInstantIngestorEvents handleInstantIngestorEventsMock = (IHandleInstantIngestorEvents) mocks.mock(
            IHandleInstantIngestorEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IInstantIngestorEventBindingsSelector selectorMock = (IInstantIngestorEventBindingsSelector) mocks.mock(
            IInstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Instant_Ingestor_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_XREF_CREATION,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockPostSalesTransactionEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(mockInstantIngestorEvent);
    }

    /**
     * @description Tests the handling of PreSalesTransaction__e events in the InstantIngestorEventsHandler.
     * This test ensures that when a PreSalesTransaction__e event is inserted:
     * 1. The handler correctly processes the event.
     * 2. The event is transformed into an equivalent Instant_Ingestor__e event.
     * 3. The corresponding service method (execute) is called with the transformed event.
     * This test verifies that PreSalesTransaction__e events are correctly routed and processed
     * in the same way as the original Instant_Ingestor__e events, maintaining consistency
     * across different event types.
     */
    @isTest
    private static void testWhenPreSalesTransactionEventWithTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> instantIngestorLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        // This event type gets saved to the DB and initiates the trigger
        List<PreSalesTransaction__e> mockPreSalesTransactionEvent = new List<PreSalesTransaction__e>{
            new PreSalesTransaction__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };
        // The PostSalesTransaction__e events will get translated into an instance of the Instant_Ingestor__e event
        // and that is what will get passed to the instance of IHandleInstantIngestorEvents
        List<Instant_Ingestor__e> mockInstantIngestorEvent = new List<Instant_Ingestor__e>{
            new Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        Instant_Ingestor_Event_Binding__mdt[] bindings = new List<Instant_Ingestor_Event_Binding__mdt>{
            new Instant_Ingestor_Event_Binding__mdt(
                Class_Name__c = 'SSMOOnboardingService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_XREF_CREATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleInstantIngestorEvents handleInstantIngestorEventsMock = (IHandleInstantIngestorEvents) mocks.mock(
            IHandleInstantIngestorEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IInstantIngestorEventBindingsSelector selectorMock = (IInstantIngestorEventBindingsSelector) mocks.mock(
            IInstantIngestorEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Instant_Ingestor_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_XREF_CREATION,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockPreSalesTransactionEvent);
        fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
        ((IHandleInstantIngestorEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(mockInstantIngestorEvent);
    }

    /**
     * @description Feature test to verify that publishing a PostSalesTransaction__e event
     * results in another PostSalesTransaction__e event being published at the end of the transaction.
     */
    //    @isTest
    //    private static void testWhenPostSalesTransactionEventPublishedThenAnotherPostSalesTransactionEventIsPublishedAtEndOfTransaction() {
    //        // Prepare test data
    //        Set<Id> instantIngestorLogIds = new Set<Id>{
    //            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
    //            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
    //        };
    //        String topic = EVENT_TOPIC_SSMO_XREF_CREATION;
    //        String payload = JSON.serialize(instantIngestorLogIds);
    //
    //        // Create the initial PostSalesTransaction__e event
    //        PostSalesTransaction__e initialEvent = new PostSalesTransaction__e(
    //            Topic__c = topic,
    //            Payload__c = payload
    //        );
    //
    //        // Set up the test
    //        Test.startTest();
    //
    //        // Enable event publishing for PostSalesTransaction__e
    //        Test.enableChangeDataCapture();
    //
    //        // Publish the initial event
    //        EventBus.publish(initialEvent);
    //
    //        // Wait for the asynchronous processing to complete
    //        Test.getEventBus().deliver();
    //
    //        Test.stopTest();
    //
    //        // Query for PostSalesTransaction__e events published after the initial event
    //        List<EventBusSubscriber> subscribers = [
    //            SELECT ExternalId, Topic, Type, Position
    //            FROM EventBusSubscriber
    //            WHERE Topic = 'PostSalesTransaction__e'
    //        ];
    //
    //        System.assertEquals(1, subscribers.size(), 'Expected one subscriber for PostSalesTransaction__e');
    //
    //        // Retrieve the replay ID of the last processed event
    //        Long replayId = subscribers[0].Position;
    //
    //        // Query for events published after the initial event
    //        List<PostSalesTransaction__e> publishedEvents = Test.getEventBus().deliver();
    //
    //        // Filter events to only include those after the initial event
    //        List<PostSalesTransaction__e> newEvents = new List<PostSalesTransaction__e>();
    //        for (PostSalesTransaction__e evt : publishedEvents) {
    //            if (Long.valueOf(evt.ReplayId) > replayId) {
    //                newEvents.add(evt);
    //            }
    //        }
    //
    //        // Assert that at least one more PostSalesTransaction__e event was published
    //        System.assert(!newEvents.isEmpty(), 'Expected at least one more PostSalesTransaction__e event to be published');
    //
    //        // Verify the details of the last published event
    //        PostSalesTransaction__e lastPublishedEvent = newEvents[newEvents.size() - 1];
    //        System.assertEquals(topic, lastPublishedEvent.Topic__c, 'The topic of the published event should match the initial event');
    //        System.assertEquals(payload, lastPublishedEvent.Payload__c, 'The payload of the published event should match the initial event');
    //    }
}