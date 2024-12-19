/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Unit tests for ApplicationNonInstantIngestionFactory class
 */
@IsTest(IsParallel=true)
private class AppNonInstantIngestionFactoryTest {
    private Map<String, Notifier_Event_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;
    private static final String EVENT_TOPIC_SSMO_FALLOUT = 'SSMO_FALLOUT';

    @IsTest
    private static void testWhenCallingNotificationFactoryThenReturnRegisteredImplementationsAndMocks() {
        Notifier_Event_Binding__mdt[] bindings = new List<Notifier_Event_Binding__mdt>{
            new Notifier_Event_Binding__mdt(
                Class_Name__c = 'SSMOFalloutHandlerService',
                Scope_Size__c = 2,
                Topic__c = EVENT_TOPIC_SSMO_FALLOUT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
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
        Application.NON_INSTANT_INGESTOR_EVENT.setMock(
            EVENT_TOPIC_SSMO_FALLOUT,
            handleNonInstantIngestionEventsMock
        );

        NOTIFICATION.setMock(EVENT_TOPIC_SSMO_FALLOUT, handleNonInstantIngestionEventsMock);
        NOTIFICATION.newInstance(EVENT_TOPIC_SSMO_FALLOUT);
        NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_SSMO_FALLOUT);
        System.assert(
            NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_SSMO_FALLOUT) == 2,
            'Expected a retriveval size of 2'
        );
    }

    // Configure and create the NotificationFactory for this Application
    public static final ApplicationNonInstantIngestionFactory NOTIFICATION = new ApplicationNonInstantIngestionFactory();
}