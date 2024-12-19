/**
 * @description Service implementation class for Instant_Ingestor__e related logic.
 * @author Deloitte
 * @date 05/11/2024
 */
public inherited sharing class InstantIngestorEventsServiceImpl implements IInstantIngestorEventsService {
    private static final String LOG_SERVICE = 'Instant Ingestor Events Service';
    private static final String LOG_DOMAIN = 'SSMO';
    @TestVisible
    private static List<IGenericLogEntry> genericLogs = new List<IGenericLogEntry>();

    private static final Map<InstantIngestorEventsService.PlatformEventType, Schema.SObjectType> EVENT_SOBJECT_TYPES_BY_PLATFORM_EVENT_TYPE = new Map<InstantIngestorEventsService.PlatformEventType, Schema.SObjectType>{
        InstantIngestorEventsService.PlatformEventType.PRESALES => PreSalesTransaction__e.SObjectType,
        InstantIngestorEventsService.PlatformEventType.POSTSALES => PostSalesTransaction__e.SObjectType,
        InstantIngestorEventsService.PlatformEventType.ADS_PROMOS => Instant_Ingestor__e.SObjectType // mapping the existing event type to ads/promos
    };
    private static final Map<Schema.SObjectType, InstantIngestorEventsService.PlatformEventType> PLATFORM_EVENT_TYPES_BY_EVENT_SOBJECT_TYPE = new Map<Schema.SObjectType, InstantIngestorEventsService.PlatformEventType>{
        PreSalesTransaction__e.SObjectType => InstantIngestorEventsService.PlatformEventType.PRESALES,
        PostSalesTransaction__e.SObjectType => InstantIngestorEventsService.PlatformEventType.POSTSALES,
        Instant_Ingestor__e.SObjectType => InstantIngestorEventsService.PlatformEventType.ADS_PROMOS
    };

    /**
     * @description Sets the platform event type based on the provided SObjectType.
     * This method maps the given SObjectType to the corresponding PlatformEventType enum.
     * It throws an InstantIngestorEventsServiceException if an unknown SObjectType is provided.
     * The method updates the global eventType used for subsequent event publishing operations.
     * @param platformEventType The SObjectType of the platform event to be used
     *
     * @throws InstantIngestorEventsServiceException if an unknown SObjectType is provided
     */
    public void setPlatformEventType(Schema.SObjectType platformEventType) {
        InstantIngestorEventsService.PlatformEventType eventType = PLATFORM_EVENT_TYPES_BY_EVENT_SOBJECT_TYPE.get(
            platformEventType
        );
        if (eventType == null) {
            throw new InstantIngestorEventsServiceException(
                'The provided platformEventType is unknown.  Received: ' + platformEventType
            );
        }
        InstantIngestorEventsService.eventType = eventType;
    }

    /**
     * @description It creates multiple events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be created
     */
    public void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachTopicName : payloadsByTopic.keySet()) {
            for (String eachPayload : payloadsByTopic.get(eachTopicName)) {
                eventsUOW.registerPublishAfterSuccessTransaction(
                    eventFactory(eachPayload, eachTopicName) // Factory return the event as an SObject
                );
            }
        }
        commitWork(eventsUOW);
    }

    /**
     * @description Publishes multiple events of the specified SObjectType using the provided topics and payloads.
     * This method allows for bulk creation and publishing of platform events of a specific type.
     * It creates a new unit of work, registers the events for publishing, and commits the work.
     * @param payloadsByTopic Map of topic to list of payloads to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public void publishBulkEvents(
        Map<String, List<String>> payloadsByTopic,
        Schema.SObjectType platformEventType
    ) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachTopicName : payloadsByTopic.keySet()) {
            for (String eachPayload : payloadsByTopic.get(eachTopicName)) {
                eventsUOW.registerPublishAfterSuccessTransaction(
                    eventFactory(eachPayload, eachTopicName, platformEventType) // Factory return the event as an SObject
                );
            }
        }
        commitWork(eventsUOW);
    }

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public void publishEvents(Map<String, String> payloadsByTopic) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        createEvents(payloadsByTopic, eventsUOW);
        commitWork(eventsUOW);
    }

    /**
     * @description Publishes events of the specified SObjectType using the provided topics and payloads.
     * This method creates and publishes platform events of a specific type in a single transaction.
     * It uses a new unit of work to register and commit the events.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public void publishEvents(
        Map<String, String> payloadsByTopic,
        Schema.SObjectType platformEventType
    ) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        createEvents(payloadsByTopic, eventsUOW, platformEventType);
        commitWork(eventsUOW);
    }

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    public void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        if (payloadsByTopic == null) {
            return;
        }
        createEvents(payloadsByTopic, uow);
        commitWork(uow);
    }

    /**
     * @description Publishes events of the specified SObjectType using the provided topics, payloads, and unit of work.
     * This method allows for creating and publishing platform events of a specific type
     * while combining them with other database operations in a single transaction.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param uow Instance of UnitOfWork for transaction management
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public void publishEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow,
        Schema.SObjectType platformEventType
    ) {
        if (payloadsByTopic == null) {
            return;
        }
        createEvents(payloadsByTopic, uow, platformEventType);
        commitWork(uow);
    }

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    private void createEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        for (String eachTopic : payloadsByTopic.keySet()) {
            uow.registerPublishAfterSuccessTransaction(
                eventFactory(payloadsByTopic.get(eachTopic), eachTopic) // Factory return the event as an SObject
            );
        }
    }

    /**
     * @description Creates events of the specified SObjectType using the provided topics and payloads.
     * This private method is used internally to create platform events of a specific type
     * and register them with the provided unit of work for publishing.
     * @param payloadsByTopic Map of topic to payload for event creation
     * @param uow Instance of UnitOfWork for registering the events
     * @param platformEventType The SObjectType of the platform event to be created
     */
    private void createEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow,
        Schema.SObjectType platformEventType
    ) {
        for (String eachTopic : payloadsByTopic.keySet()) {
            uow.registerPublishAfterSuccessTransaction(
                eventFactory(payloadsByTopic.get(eachTopic), eachTopic, platformEventType) // Factory return the event as an SObject
            );
        }
    }

    /**
     * @description Generates an instance of the Platform Event to be fired
     * Given that there are multiple different Platform Event channels being used to orchestrate
     * the various events coming from product systems, we are using a factory to take responsibility for generating
     * the right object.
     * @param payload - Value to be set as the Payload__c attribute on the event object
     * @param topic - Value to be set as the Topic__c attribute on the event object
     * @return Hydrated Platform Event object
     */
    private SObject eventFactory(String payload, String topic) {
        Schema.SObjectType eventType = EVENT_SOBJECT_TYPES_BY_PLATFORM_EVENT_TYPE.get(
            InstantIngestorEventsService.eventType
        );
        if (eventType == null) {
            throw new InstantIngestorEventsServiceException(
                'Unable to determine the proper platform event to use for this use case.  The event type returned null.'
            );
        }
        return eventFactory(payload, topic, eventType);
    }

    /**
     * @description Generates an instance of a specific Platform Event type.
     * This factory method creates and hydrates a platform event of the specified SObjectType
     * with the provided payload and topic.
     * @param payload Value to be set as the Payload__c attribute on the event object
     * @param topic Value to be set as the Topic__c attribute on the event object
     * @param platformEventType The SObjectType of the platform event to be created
     * @return Hydrated Platform Event object
     * @throws InstantIngestorEventsServiceException if the provided platformEventType is null
     */
    private SObject eventFactory(
        String payload,
        String topic,
        Schema.SObjectType platformEventType
    ) {
        if (platformEventType == null) {
            throw new InstantIngestorEventsServiceException(
                'Unable to determine the proper platform event to use for this use case.  The platform event type was null.'
            );
        }
        SObject objEvent = platformEventType.newSObject();
        objEvent.put('Topic__c', topic);
        objEvent.put('Payload__c', payload);
        return objEvent;
    }

    /**
     * @description It publishes the events along with committing other records (if applicable).
     * @param uow - instance of UnitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception commitWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(commitWorkException, LogEntry.SeverityLevel.HIGH)
            );

            genericLogs.add(getGenericLog().logException(commitWorkException));
            publishGenericLog();
        }
    }

    /**
     * @description Get log instance of IGenericLogEntry implementation
     * @return instance of IGenericLogEntry imlementation
     */
    @TestVisible
    private static IGenericLogEntry getGenericLog() {
        return GenericLoggerService.createGenericLog(
            LOG_SERVICE,
            LOG_DOMAIN,
            GenericLogEntry.SeverityLevel.HIGH
        );
    }

    /**
     * @description Publish log instances added to list
     */
    @TestVisible
    private static void publishGenericLog() {
        GenericLoggerService.publish(genericLogs);
        genericLogs.clear();
    }

    /**
     * @description Custom class for handling exceptions.
     */
    public class InstantIngestorEventsServiceException extends Exception {
    }
}