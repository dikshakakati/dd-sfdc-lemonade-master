/**
 * @author Deloitte
 * @date   05/14/2024
 * @description Dynamic resolution of event subscribers
 */

public inherited sharing class ApplicationNonInstantIngestionFactory extends fflib_Application {
    private final String exceptionMessage = 'No implementation registered for event topic ';
    private Map<String, Notifier_Event_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    /**
     * @description To get map of topic and notifier event data.
     */
    @TestVisible
    private Map<String, Notifier_Event_Binding__mdt> getNotifierEventBindingMetadata {
        get {
            if (implementationsByEventTopic.isEmpty()) {
                implementationsByEventTopic = new Map<String, Notifier_Event_Binding__mdt>();
                for (
                    Notifier_Event_Binding__mdt metadataRecord : NotifierEventBindingsSelector.newInstance()
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
     * @description Constructor Method.
     */
    public ApplicationNonInstantIngestionFactory() {
        implementationsByEventTopic = new Map<String, Notifier_Event_Binding__mdt>();
        mockImplementationsByEventTopic = new Map<String, Object>();
    }

    /**
     * @description It is used to return scope size of topic provided.
     * @param topicName
     * @return Integer
     */
    public Integer retrieveScopeSize(String topicName) {
        if (implementationsByEventTopic.isEmpty()) {
            implementationsByEventTopic = this.getNotifierEventBindingMetadata;
        }

        if (!implementationsByEventTopic.containsKey(topicName)) {
            throw new DeveloperException(exceptionMessage + topicName);
        }

        return Integer.valueOf(implementationsByEventTopic.get(topicName).Scope_Size__c);
    }

    /**
     * @description It is used to return the IHandleNonInstantIngestionEvents interface for instantiation.
     * @param eventTopic
     * @return IHandleNonInstantIngestionEvents
     */
    public IHandleNonInstantIngestionEvents newInstance(String eventTopic) {
        // Mock implementation
        if (mockImplementationsByEventTopic.containsKey(eventTopic)) {
            return (IHandleNonInstantIngestionEvents) mockImplementationsByEventTopic.get(eventTopic);
        }

        if (!implementationsByEventTopic.containsKey(eventTopic)) {
            throw new DeveloperException(exceptionMessage + eventTopic);
        }

        // Create an instance of the implementation for the given topic
        return (IHandleNonInstantIngestionEvents) Type.forName(
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
    private void setMock(String eventTopic, IHandleNonInstantIngestionEvents implementation) {
        mockImplementationsByEventTopic.put(eventTopic, implementation);
    }
}