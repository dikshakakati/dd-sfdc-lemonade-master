/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Dynamic Resolution for Onboarding & Activations Event Subscribers.
 */
public inherited sharing class ApplicationOnboardingActivationsFactory extends fflib_Application {
    private final String exceptionMessage = 'No implementation registered for event topic ';
    private Map<String, Onboarding_Events_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    /**
     * @description To get map of topic and notifier event data.
     */
    @TestVisible
    private Map<String, Onboarding_Events_Binding__mdt> getOnboardingActivationEventBindingMetadata {
        get {
            if (implementationsByEventTopic.isEmpty()) {
                implementationsByEventTopic = new Map<String, Onboarding_Events_Binding__mdt>();
                for (
                    Onboarding_Events_Binding__mdt metadataRecord : OnboardingActivationEventBindingSelector.newInstance()
                        .getAllValues()
                ) {
                    implementationsByEventTopic.put(metadataRecord.Topic__c, metadataRecord);
                }
            }
            return implementationsByEventTopic;
        }
        private set;
    }

    /**
     * @description Constructor.
     */
    public ApplicationOnboardingActivationsFactory() {
        implementationsByEventTopic = new Map<String, Onboarding_Events_Binding__mdt>();
        mockImplementationsByEventTopic = new Map<String, Object>();
    }

    /**
     * @description It is used to return scope size of topic provided.
     * @param topicName
     * @return Integer
     */
    public Integer retrieveScopeSize(String topicName) {
        if (implementationsByEventTopic.isEmpty()) {
            implementationsByEventTopic = this.getOnboardingActivationEventBindingMetadata;
        }

        if (!implementationsByEventTopic.containsKey(topicName)) {
            throw new DeveloperException(exceptionMessage + topicName);
        }

        return Integer.valueOf(implementationsByEventTopic.get(topicName).Scope_Size__c);
    }

    /**
     * @description It is used to return the IHandleOnboardingActivationsEvents interface for instantiation.
     * @param eventTopic
     * @return IHandleOnboardingActivationsEvents
     */
    public IHandleOnboardingActivationsEvents newInstance(String eventTopic) {
        // Mock implementation
        if (mockImplementationsByEventTopic.containsKey(eventTopic)) {
            return (IHandleOnboardingActivationsEvents) mockImplementationsByEventTopic.get(
                eventTopic
            );
        }

        if (!implementationsByEventTopic.containsKey(eventTopic)) {
            throw new DeveloperException(exceptionMessage + eventTopic);
        }

        // Create an instance of the implementation for the given topic
        return (IHandleOnboardingActivationsEvents) Type.forName(
                implementationsByEventTopic.get(eventTopic).Class_Name__c
            )
            .newInstance();
    }

    /**
     * @description It allows mocking of EventHandlerFactory.
     * @param eventTopic
     * @param implementation
     */
    @TestVisible
    private void setMock(String eventTopic, IHandleOnboardingActivationsEvents implementation) {
        mockImplementationsByEventTopic.put(eventTopic, implementation);
    }
}