/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Dynamic resolution of event subscribers.
 */

public inherited sharing class ApplicationInstantIngestorFactory extends fflib_Application {
    private final String exceptionMessage = 'No implementation registered for event topic ';
    private Map<String, Instant_Ingestor_Event_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    /**
     * @description It is used to get map of topic and instant ingestor event data.
     */
    @TestVisible
    private Map<String, Instant_Ingestor_Event_Binding__mdt> getInstantIngestorEventBindingMetadata {
        get {
            if (implementationsByEventTopic.isEmpty()) {
                implementationsByEventTopic = new Map<String, Instant_Ingestor_Event_Binding__mdt>();
                for (
                    Instant_Ingestor_Event_Binding__mdt eachInstantIngestorEventBinding : InstantIngestorEventBindingsSelector.newInstance()
                        .getAllValues()
                ) {
                    implementationsByEventTopic.put(
                        eachInstantIngestorEventBinding.Topic__c,
                        eachInstantIngestorEventBinding
                    );
                }
            }
            return implementationsByEventTopic;
        }
        private set;
    }

    /**
     * @description Constructor to initialize class level variables.
     */
    public ApplicationInstantIngestorFactory() {
        implementationsByEventTopic = new Map<String, Instant_Ingestor_Event_Binding__mdt>();
        mockImplementationsByEventTopic = new Map<String, Object>();
    }

    /**
     * @description It is used to return scope size of topic provided.
     * @param topicName
     * @return Integer
     */
    public Integer retrieveScopeSize(String topicName) {
        if (implementationsByEventTopic.isEmpty()) {
            implementationsByEventTopic = this.getInstantIngestorEventBindingMetadata;
        }

        if (!implementationsByEventTopic.containsKey(topicName)) {
            throw new DeveloperException(exceptionMessage + topicName);
        }

        return Integer.valueOf(implementationsByEventTopic.get(topicName).Scope_Size__c);
    }

    /**
     * @description It is used to return the IHandleInstantIngestorEvents interface for instantiation.
     * @param eventTopic
     * @return IHandleInstantIngestorEvents
     */
    public IHandleInstantIngestorEvents newInstance(String eventTopic) {
        // Mock implementation
        if (mockImplementationsByEventTopic.containsKey(eventTopic)) {
            return (IHandleInstantIngestorEvents) mockImplementationsByEventTopic.get(eventTopic);
        }

        if (implementationsByEventTopic.isEmpty()) {
            implementationsByEventTopic = this.getInstantIngestorEventBindingMetadata;
        }

        if (!implementationsByEventTopic.containsKey(eventTopic)) {
            throw new DeveloperException(exceptionMessage + eventTopic);
        }

        // Create an instance of the implementation for the given topic
        return (IHandleInstantIngestorEvents) Type.forName(
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
    private void setMock(String eventTopic, IHandleInstantIngestorEvents implementation) {
        mockImplementationsByEventTopic.put(eventTopic, implementation);
    }
}