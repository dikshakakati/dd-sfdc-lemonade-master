/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Unit tests for ApplicationEmailOutboundFactory class
 */
@IsTest(IsParallel=true)
private class ApplicationEmailOutboundFactoryTest {
    private static final String ASSERT_MESSAGE_SCOPE_SIZE = 'Expected a retriveval size of 200';
    private static final String EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String SERVICE_CLASS_NAME = 'IntegrationOutboundService';
    private Map<String, Email_Outbound_Events_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    @IsTest
    private static void testWhenCallingEmailOutboundFactoryThenReturnRegisteredImplementationsAndMocks() {
        Email_Outbound_Events_Binding__mdt[] bindings = new List<Email_Outbound_Events_Binding__mdt>{
            new Email_Outbound_Events_Binding__mdt(
                Class_Name__c = SERVICE_CLASS_NAME,
                Scope_Size__c = 200,
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleEmailOutboundIntegrationsEvents handleEmailOutboundEventsMock = (IHandleEmailOutboundIntegrationsEvents) mocks.mock(
            IHandleEmailOutboundIntegrationsEvents.class
        );

        IEmailOutboundEventBindingSelector selectorMock = (IEmailOutboundEventBindingSelector) mocks.mock(
            IEmailOutboundEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Email_Outbound_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.setMock(
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
            handleEmailOutboundEventsMock
        );

        EMAIL_OUTBOUND.setMock(
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
            handleEmailOutboundEventsMock
        );
        EMAIL_OUTBOUND.newInstance(EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION);
        EMAIL_OUTBOUND.retrieveScopeSize(EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION);
        System.assert(
            EMAIL_OUTBOUND.retrieveScopeSize(EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION) == 200,
            ASSERT_MESSAGE_SCOPE_SIZE
        );
    }

    // Configure and create the EmailOutboundFactory for this Application
    public static final ApplicationEmailOutboundFactory EMAIL_OUTBOUND = new ApplicationEmailOutboundFactory();
}