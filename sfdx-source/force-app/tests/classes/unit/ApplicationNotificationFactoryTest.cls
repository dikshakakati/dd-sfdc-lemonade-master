/**
 * @author BizApps
 * @date 2023-10-03
 * @description Unit tests for ApplicationNotificationFactory class
 */
@IsTest(IsParallel=true)
private class ApplicationNotificationFactoryTest {
    private Map<String, Notifier_Event_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';

    @IsTest
    private static void testWhenCallingNotificationFactoryThenReturnRegisteredImplementationsAndMocks() {
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

        INotifierEventBindingsSelector selectorMock = (INotifierEventBindingsSelector) mocks.mock(
            INotifierEventBindingsSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Notifier_Event_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.NOTIFIER_EVENT.setMock(
            EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
            handleNotifierEventsMock
        );

        NOTIFICATION.setMock(EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION, handleNotifierEventsMock);
        NOTIFICATION.newInstance(EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
        NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
        System.assert(
            NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION) == 200,
            'Expected a retriveval size of 200'
        );
    }

    // Configure and create the NotificationFactory for this Application
    public static final ApplicationNotificationFactory NOTIFICATION = new ApplicationNotificationFactory();
}