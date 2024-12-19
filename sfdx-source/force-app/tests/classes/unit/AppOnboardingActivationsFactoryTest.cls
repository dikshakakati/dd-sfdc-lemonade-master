/**
 * @author Deloitte
 * @date 2024-04-05
 * @description Unit tests for ApplicationOnbaordingActivationsFactory class
 */
@IsTest( IsParallel=true )
private class AppOnboardingActivationsFactoryTest {
    private Map<String, Onboarding_Events_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST  = 'CREATE_ACTIVATION_CHECKLIST';

    @IsTest
    private static void testWhenCallingOnboardingActivationFactoryThenReturnRegisteredImplementationsAndMocks() {

        Onboarding_Events_Binding__mdt[] bindings = new List<Onboarding_Events_Binding__mdt>{
            new Onboarding_Events_Binding__mdt(
                Class_Name__c = 'ActivationChecklistService',
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST
            )
        };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleOnboardingActivationsEvents handleOnboardingActivationEventsMock = (IHandleOnboardingActivationsEvents) mocks.mock(
            IHandleOnboardingActivationsEvents.class
        );

        IOnboardActivationEventBindingSelector selectorMock = (IOnboardActivationEventBindingSelector) mocks.mock(
            IOnboardActivationEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Onboarding_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.ONBOARDING_AND_ACTIVATIONS_EVENT.setMock(
            EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
            handleOnboardingActivationEventsMock
        );

        NOTIFICATION.setMock(EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST, handleOnboardingActivationEventsMock);
        NOTIFICATION.newInstance(EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST);
        NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST);
        System.assert( NOTIFICATION.retrieveScopeSize(EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST) == 5, 'Expected a retriveval size of 5' );
    }


      // Configure and create the NotificationFactory for this Application
    public static final ApplicationOnboardingActivationsFactory NOTIFICATION =
        new ApplicationOnboardingActivationsFactory(
        );
}