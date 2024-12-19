/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Test class for NonInstantIngestionEventsHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NonInstantIngestionEventsHandlerTest {
    private static final String CLASS_NAME = 'SSMOFalloutHandlerService';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Instant Ingestor Event is already published';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: failed to publish Instant Ingestor Event';
    private static final String EVENT_TOPIC_SSMO_FALLOUT = 'SSMO_FALLOUT';
    private static final String LOG_TYPE = 'fflib_Application.DeveloperException';
    private static final String LOG_MESSAGE =
        'No implementation registered for event topic ' + EVENT_TOPIC_SSMO_FALLOUT;
    private static final String EVENT_TOPIC_NO_IMPLEMENTATION = 'NO_IMPLEMENTATION_TOPIC';
    private static final String LOG_SERVICE = 'Non Instant Ingestion Event Handler';

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
        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_FALLOUT,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            )
        };

        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'SSMOFalloutHandlerService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_FALLOUT
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleNonInstantIngestionEvents handleInstantIngestorEventsMock = (IHandleNonInstantIngestionEvents) mocks.mock(
            IHandleNonInstantIngestionEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        INotifierEventBindingsSelector selectorMock = (INotifierEventBindingsSelector) mocks.mock(
            INotifierEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Notifier_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.NON_INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_FALLOUT,
            handleInstantIngestorEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(NonInstantIngestionEventsHandler.class);
        ((IHandleNonInstantIngestionEvents) mocks.verify(handleInstantIngestorEventsMock, 1))
            .execute(mockInstantIngestorEvent);
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
        List<Non_Instant_Ingestor__e> mockInstantIngestorEvent = new List<Non_Instant_Ingestor__e>();
        List<Non_Instant_Ingestor__e> mockInstantIngestorEventWithinScope = new List<Non_Instant_Ingestor__e>();

        for (Integer i = 0; i < 400; i++) {
            Non_Instant_Ingestor__e instantIngestorRecord = new Non_Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_SSMO_FALLOUT,
                Payload__c = JSON.serialize(instantIngestorLogIds)
            );
            mockInstantIngestorEvent.add(instantIngestorRecord);
            if (i < 200) {
                mockInstantIngestorEventWithinScope.add(instantIngestorRecord);
            }
        }

        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'SSMOFalloutHandlerService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_SSMO_FALLOUT
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IHandleNonInstantIngestionEvents handleNonInstantIngestionEventsMock = (IHandleNonInstantIngestionEvents) mocks.mock(
            IHandleNonInstantIngestionEvents.class
        );
        INotifierEventBindingsSelector selectorMock = (INotifierEventBindingsSelector) mocks.mock(
            INotifierEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Notifier_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.NON_INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_FALLOUT,
            handleNonInstantIngestionEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(NonInstantIngestionEventsHandler.class);
        ((IHandleNonInstantIngestionEvents) mocks.verify(handleNonInstantIngestionEventsMock, 1))
            .execute(mockInstantIngestorEventWithinScope);
        ((IHandleNonInstantIngestionEvents) mocks.verify(handleNonInstantIngestionEventsMock, 1))
            .execute((List<Non_Instant_Ingestor__e>) fflib_Match.anyList());
    }

    /**
     * @description To verify when topic without implementation is passed then an exception is thrown.
     */
    @isTest
    private static void testWhenTopicWithoutImplementationPassedThenExceptionThrown() {
        Set<Id> nonInstantIngestionLogIds = new Set<Id>{
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType),
            fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType)
        };
        List<Non_Instant_Ingestor__e> mockNonInstantIngestorEvent = new List<Non_Instant_Ingestor__e>{
            new Non_Instant_Ingestor__e(
                Topic__c = EVENT_TOPIC_NO_IMPLEMENTATION,
                Payload__c = JSON.serialize(nonInstantIngestionLogIds)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger logServiceMock = (IGenericLogger) mocks.mock(IGenericLogger.class);
        Application.SERVICE.setMock(IGenericLogger.class, logServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(mockNonInstantIngestorEvent);
        fflib_SObjectDomain.triggerHandler(NonInstantIngestionEventsHandler.class);
        Test.stopTest();
        ((IGenericLogger) mocks.verify(logServiceMock, 1))
            .publish((IGenericLogEntry) fflib_Match.anyObject());
    }
}