/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Dynamic Resolution for Email Outbound Integrations Platform event Subscribers.
 */
public inherited sharing class ApplicationEmailOutboundFactory extends fflib_Application {
    private final String exceptionMessage = 'No implementation registered for event topic ';
    private Map<String, Email_Outbound_Events_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    /**
     * @description Constructor.
     */
    public ApplicationEmailOutboundFactory() {
        implementationsByEventTopic = new Map<String, Email_Outbound_Events_Binding__mdt>();
        mockImplementationsByEventTopic = new Map<String, Object>();
    }

    /**
     * @description It is used to return scope size of topic provided.
     * @param topicName
     * @return Integer
     */
    public Integer retrieveScopeSize(String topicName) {
        if (implementationsByEventTopic.isEmpty()) {
            implementationsByEventTopic = this.getEmailOutboundEventBindingMetadata;
        }

        if (!implementationsByEventTopic.containsKey(topicName)) {
            throw new DeveloperException(exceptionMessage + topicName);
        }

        return Integer.valueOf(implementationsByEventTopic.get(topicName).Scope_Size__c);
    }

    /**
     * @description It is used to return the IHandleEmailOutboundIntegrationsEvents interface for instantiation.
     * @param eventTopic
     * @return IHandleEmailOutboundIntegrationsEvents
     */
    public IHandleEmailOutboundIntegrationsEvents newInstance(String eventTopic) {
        // Mock implementation
        if (mockImplementationsByEventTopic.containsKey(eventTopic)) {
            return (IHandleEmailOutboundIntegrationsEvents) mockImplementationsByEventTopic.get(
                eventTopic
            );
        }

        if (!implementationsByEventTopic.containsKey(eventTopic)) {
            throw new DeveloperException(exceptionMessage + eventTopic);
        }

        // Create an instance of the implementation for the given topic
        return (IHandleEmailOutboundIntegrationsEvents) Type.forName(
                implementationsByEventTopic.get(eventTopic).Class_Name__c
            )
            .newInstance();
    }

    /**
     * @description To get map of topic and event data.
     */
    @TestVisible
    private Map<String, Email_Outbound_Events_Binding__mdt> getEmailOutboundEventBindingMetadata {
        get {
            if (implementationsByEventTopic.isEmpty()) {
                implementationsByEventTopic = new Map<String, Email_Outbound_Events_Binding__mdt>();
                for (
                    Email_Outbound_Events_Binding__mdt metadataRecord : EmailOutboundEventBindingSelector.newInstance()
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
     * @description It allows mocking of EventHandlerFactory.
     * @param eventTopic
     * @param implementation
     */
    @TestVisible
    private void setMock(String eventTopic, IHandleEmailOutboundIntegrationsEvents implementation) {
        mockImplementationsByEventTopic.put(eventTopic, implementation);
    }
}