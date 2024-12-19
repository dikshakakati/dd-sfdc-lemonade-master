/**
 * @description Interface for InstantIngestorEventsService class.
 * @author Deloitte
 * @date 05/11/2024
 */
public interface IInstantIngestorEventsService {
    /**
     * @description Sets the platform event type based on the provided SObjectType.
     * This method maps the given SObjectType to the corresponding PlatformEventType enum.
     * It throws an InstantIngestorEventsServiceException if an unknown SObjectType is provided.
     * The method updates the global eventType used for subsequent event publishing operations.
     * @param platformEventType The SObjectType of the platform event to be used
     */
    void setPlatformEventType(Schema.SObjectType platformEventType);

    /**
     * @description It creates multiple events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    void publishBulkEvents(Map<String, List<String>> payloadsByTopic);

    /**
     * @description Publishes multiple events of the specified SObjectType using the provided topics and payloads.
     * This method allows for bulk creation and publishing of platform events of a specific type.
     * It creates a new unit of work, registers the events for publishing, and commits the work.
     * @param payloadsByTopic Map of topic to list of payloads to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    void publishBulkEvents(
        Map<String, List<String>> payloadsByTopic,
        Schema.SObjectType platformEventType
    );

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    void publishEvents(Map<String, String> payloadsByTopic);

    /**
     * @description Publishes events of the specified SObjectType using the provided topics and payloads.
     * This method creates and publishes platform events of a specific type in a single transaction.
     * It uses a new unit of work to register and commit the events.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    void publishEvents(Map<String, String> payloadsByTopic, Schema.SObjectType platformEventType);

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow);

    /**
     * @description Publishes events of the specified SObjectType using the provided topics, payloads, and unit of work.
     * This method allows for creating and publishing platform events of a specific type
     * while combining them with other database operations in a single transaction.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param uow Instance of UnitOfWork for transaction management
     * @param platformEventType The SObjectType of the platform event to be published
     */
    void publishEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow,
        Schema.SObjectType platformEventType
    );
}