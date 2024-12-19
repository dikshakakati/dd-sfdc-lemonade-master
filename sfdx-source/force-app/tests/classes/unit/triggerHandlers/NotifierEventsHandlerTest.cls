/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Test class for NotifierEventsHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NotifierEventsHandlerTest {
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Notifier event is already published';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: failed to publish Notifier event';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER = 'UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER';
    private static final String EVENT_TOPIC_NO_IMPLEMENTATION = 'NO_IMPLEMENTATION_TOPIC';
    private static final String LOG_TYPE = 'fflib_Application.DeveloperException';
    private static final String LOG_MESSAGE =
        'No implementation registered for event topic ' + EVENT_TOPIC_NO_IMPLEMENTATION;
    private static final String MOCK_UUID = 'UUID_Mock_NotifierEventsHandlerTest';

    /**
     * @description To test execute method of NotifierEvents handler class
     * is called on Notifier event publish.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Notifier__e> mockNotifierEvent = new List<Notifier__e>{
            (Notifier__e) new Fake(Notifier__e.class)
                .setField(Notifier__e.Topic__c, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION)
                .setField(Notifier__e.Payload__c, JSON.serialize(parentWorkOrderIds))
                .setField(Notifier__e.EventUuid, MOCK_UUID)
                .toSObject()
        };

        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'AccountsService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleNotifierEvents handleNotifierEventsMock = (IHandleNotifierEvents) mocks.mock(
            IHandleNotifierEvents.class
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
        Application.NOTIFIER_EVENT.setMock(
            EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
            handleNotifierEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockNotifierEvent);
        fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
        mockNotifierEvent[0].UUID__c = MOCK_UUID;
        ((IHandleNotifierEvents) mocks.verify(handleNotifierEventsMock, 1))
            .execute(
                new List<Notifier__e>{
                    new Notifier__e(
                        Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
                        Payload__c = JSON.serialize(parentWorkOrderIds),
                        UUID__c = MOCK_UUID
                    )
                }
            );
    }

    /**
     * @description To test execute method of NotifierEvents handler class for multiple topics
     * is called on Multiple Notifier event publish.
     */
    @isTest
    private static void testWhenMultiplateTopicsWithImplementationPassedThenSingleTopicIsExecuted() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };

        List<Notifier__e> mockNotifierEvent = new List<Notifier__e>{
            (Notifier__e) new Fake(Notifier__e.class)
                .setField(Notifier__e.Topic__c, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION)
                .setField(Notifier__e.Payload__c, JSON.serialize(parentWorkOrderIds))
                .setField(Notifier__e.EventUuid, MOCK_UUID)
                .toSObject(),
            (Notifier__e) new Fake(Notifier__e.class)
                .setField(Notifier__e.Topic__c, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION)
                .setField(Notifier__e.Payload__c, JSON.serialize(parentWorkOrderIds))
                .setField(Notifier__e.EventUuid, MOCK_UUID)
                .toSObject()
        };

        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'AccountsService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleNotifierEvents handleNotifierEventsMock = (IHandleNotifierEvents) mocks.mock(
            IHandleNotifierEvents.class
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
        Application.NOTIFIER_EVENT.setMock(
            EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
            handleNotifierEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockNotifierEvent);
        fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);

        ((IHandleNotifierEvents) mocks.verify(handleNotifierEventsMock, 1))
            .execute(
                new List<Notifier__e>{
                    new Notifier__e(
                        Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
                        Payload__c = JSON.serialize(parentWorkOrderIds),
                        UUID__c = MOCK_UUID
                    ),
                    new Notifier__e(
                        Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
                        Payload__c = JSON.serialize(parentWorkOrderIds),
                        UUID__c = MOCK_UUID
                    )
                }
            );
        ((IHandleNotifierEvents) mocks.verify(handleNotifierEventsMock, 1))
            .execute((List<Notifier__e>) fflib_Match.anyList());
    }

    /**
     * @description To test scope size executed for Notifier events.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenVerifyScopeSizeExecuted() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Notifier__e> mockNotifierEvent = new List<Notifier__e>();
        List<Notifier__e> mockNotifierEventWithinScope = new List<Notifier__e>();

        for (Integer i = 0; i < 400; i++) {
            Notifier__e notifierRecord = (Notifier__e) new Fake(Notifier__e.class)
                .setField(
                    Notifier__e.Topic__c,
                    EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER
                )
                .setField(Notifier__e.Payload__c, JSON.serialize(parentWorkOrderIds))
                .setField(Notifier__e.EventUuid, MOCK_UUID)
                .toSObject();
            Notifier__e notifierMockRecord = (Notifier__e) new Fake(Notifier__e.class)
                .setField(
                    Notifier__e.Topic__c,
                    EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER
                )
                .setField(Notifier__e.Payload__c, JSON.serialize(parentWorkOrderIds))
                .setField(Notifier__e.UUID__c, MOCK_UUID)
                .toSObject();
            mockNotifierEvent.add(notifierRecord);
            if (i < 200) {
                mockNotifierEventWithinScope.add(notifierMockRecord);
            }
        }

        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'AccountsService',
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IHandleNotifierEvents handleNotifierEventsMock = (IHandleNotifierEvents) mocks.mock(
            IHandleNotifierEvents.class
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
        Application.NOTIFIER_EVENT.setMock(
            EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER,
            handleNotifierEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockNotifierEvent);
        fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
        ((IHandleNotifierEvents) mocks.verify(handleNotifierEventsMock, 1))
            .execute(mockNotifierEventWithinScope);
        ((IHandleNotifierEvents) mocks.verify(handleNotifierEventsMock, 1))
            .execute((List<Notifier__e>) fflib_Match.anyList());
    }

    /**
     * @description To verify when topic without implementation is passed then an exception is thrown.
     */
    @isTest
    private static void testWhenTopicWithoutImplementationPassedThenExceptionIsThrown() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Notifier__e> mockNotifierEvent = new List<Notifier__e>{
            new Notifier__e(
                Topic__c = EVENT_TOPIC_NO_IMPLEMENTATION,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onInsert(mockNotifierEvent);
        fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
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
}