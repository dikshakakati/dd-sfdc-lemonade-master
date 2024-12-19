/**
 * @author Deloitte
 * @date 2022/05/15
 * @description Dynamic resolution of event subscribers
 */

 public inherited sharing class ApplicationNotificationFactory extends fflib_Application {
    private final String exceptionMessage = 'No implementation registered for event topic ';
    private Map<String, Notifier_Event_Binding__mdt> implementationsByEventTopic;
    private Map<String, Object> mockImplementationsByEventTopic;

    /**
     * @description To get map of topic and notifier event data.
     */
    @TestVisible
    private Map<String, Notifier_Event_Binding__mdt> getNotifierEventBindingMetadata {
        get {
            if( implementationsByEventTopic.isEmpty() ) {
                implementationsByEventTopic = new Map<String, Notifier_Event_Binding__mdt>();
                for(
                    Notifier_Event_Binding__mdt metadataRecord : NotifierEventBindingsSelector.newInstance()
                    .getAllValues()
                ) {
                    implementationsByEventTopic.put( metadataRecord.Topic__c, metadataRecord );
                }
            }
            return implementationsByEventTopic;
        }
        private set;
    }

    /**
     * @description Constructor.
     */
    public ApplicationNotificationFactory() {
        implementationsByEventTopic = new Map<String, Notifier_Event_Binding__mdt>();
        mockImplementationsByEventTopic = new Map<String, Object>();
    }

    /**
     * @description It is used to return scope size of topic provided.
     * @param topicName
     * @return Integer
     */
    public Integer retrieveScopeSize( String topicName ) {
        if( implementationsByEventTopic.isEmpty() ) {
            implementationsByEventTopic = this.getNotifierEventBindingMetadata;
        }

        if( !implementationsByEventTopic.containsKey( topicName ) ) {
            throw new DeveloperException( exceptionMessage + topicName );
        }

        return Integer.valueOf( implementationsByEventTopic.get( topicName ).Scope_Size__c );
    }

    /**
     * @description It is used to return partition key based on topic.
     * @param topicName
     * @return String
     */
    public String retrievePartitionKey( String topicName ) {
        if( implementationsByEventTopic.isEmpty() ) {
            implementationsByEventTopic = this.getNotifierEventBindingMetadata;
        }
        if( !implementationsByEventTopic.containsKey( topicName ) ) {
            throw new DeveloperException( exceptionMessage + topicName );
        }
        return implementationsByEventTopic.get( topicName ).Partition_Key__c;
    }

    /**
     * @description It is used to return platform event to which the current topic needs to be redirected.
     * @param topicName
     * @return String
     */
    public String retrievePlatformEventChannelName( String topicName ) {
        if( implementationsByEventTopic.isEmpty() ) {
            implementationsByEventTopic = this.getNotifierEventBindingMetadata;
        }

        if( !implementationsByEventTopic.containsKey( topicName ) ) {
            throw new DeveloperException( exceptionMessage + topicName );
        }

        return implementationsByEventTopic.get( topicName ).Platform_Event_Channel__c;
    }

    /**
     * @description It is used to return the IHandleNotifierEvents interface for instantiation.
     * @param eventTopic
     * @return IHandleNotifierEvents
     */
    public IHandleNotifierEvents newInstance( String eventTopic ) {
        // Mock implementation
        if( mockImplementationsByEventTopic.containsKey( eventTopic ) ) {
            return (IHandleNotifierEvents) mockImplementationsByEventTopic.get( eventTopic );
        }

        if( !implementationsByEventTopic.containsKey( eventTopic ) ) {
            throw new DeveloperException( exceptionMessage + eventTopic );
        }

        // Create an instance of the implementation for the given topic
        return (IHandleNotifierEvents) Type.forName(
            implementationsByEventTopic.get( eventTopic ).Class_Name__c
        )
            .newInstance();
    }

    /**
     * @description It allows mocking of EventHandlerFactory.
     * @param eventTopic
     * @param implementation
     */
    @TestVisible
    private void setMock( String eventTopic, IHandleNotifierEvents implementation ) {
        mockImplementationsByEventTopic.put( eventTopic, implementation );
    }
}