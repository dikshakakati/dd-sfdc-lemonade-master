/**
 * @description Service class for Instant_Ingestor__e related logic.
 * @author Deloitte
 * @date 05/11/2024
 */
public inherited sharing class InstantIngestorEventsService {
    /**
     * @description Defines the different platform event channels that could be used to route the messages
     */
    public enum PlatformEventType {
        PRESALES,
        POSTSALES,
        ADS_PROMOS
    }

    /**
     * @description Defines the platform event channel that will be used to route messages in this transaction
     * The type defaults to the ADS_PROMOS type to limit impact to the time sensitive channels.  If something goes
     * ary, this could lead to a Pre/Post sales event getting stuck in the high volume queue, but that will surface as
     * a bug and we can address.  Making an assumption that this is more of an edge case and a better outcome than
     * having a bunch of high volume event accidentally polluting the time sensitive channels.
     * TODO: This should probably be refactored to a getter/setter so we can prevent it from being set to null.
     */
    public static PlatformEventType eventType = PlatformEventType.ADS_PROMOS;

    /**
     * @description Sets the platform event type to be used for event publishing.
     * This method delegates the setting of the event type to the service implementation.
     * It allows for dynamic switching between different platform event types (PRESALES, POSTSALES, ADS_PROMOS)
     * based on the SObjectType provided.
     * @param platformEventType The SObjectType of the platform event to be used
     */
    public static void setPlatformEventType(Schema.SObjectType platformEventType) {
        service().setPlatformEventType(platformEventType);
    }

    /**
     * @description It creates multiple events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    public static void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        service().publishBulkEvents(payloadsByTopic);
    }

    /**
     * @description Publishes multiple events of the specified SObjectType using the provided topics and payloads.
     * This method allows for bulk creation and publishing of platform events of a specific type.
     * It creates a new unit of work, registers the events for publishing, and commits the work.
     * @param payloadsByTopic Map of topic to list of payloads to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public static void publishBulkEvents(
        Map<String, List<String>> payloadsByTopic,
        Schema.SObjectType platformEventType
    ) {
        service().publishBulkEvents(payloadsByTopic, platformEventType);
    }

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public static void publishEvents(Map<String, String> payloadsByTopic) {
        service().publishEvents(payloadsByTopic);
    }

    /**
     * @description Publishes events of the specified SObjectType using the provided topics and payloads.
     * This method creates and publishes platform events of a specific type in a single transaction.
     * It uses a new unit of work to register and commit the events.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public static void publishEvents(
        Map<String, String> payloadsByTopic,
        Schema.SObjectType platformEventType
    ) {
        service().publishEvents(payloadsByTopic, platformEventType);
    }

    /**
     * @description It creates events of type Instant_Ingestor__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    public static void publishEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow
    ) {
        service().publishEvents(payloadsByTopic, uow);
    }

    /**
     * @description Publishes events of the specified SObjectType using the provided topics, payloads, and unit of work.
     * This method allows for creating and publishing platform events of a specific type
     * while combining them with other database operations in a single transaction.
     * @param payloadsByTopic Map of topic to payload to be published
     * @param uow Instance of UnitOfWork for transaction management
     * @param platformEventType The SObjectType of the platform event to be published
     */
    public static void publishEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow,
        Schema.SObjectType platformEventType
    ) {
        service().publishEvents(payloadsByTopic, uow, platformEventType);
    }

    /**
     * @description It creates instance of InstantIngestorEventsServiceImpl class.
     * @return IInstantIngestorEventsService - return instance of InstantIngestorEventsServiceImpl
     */
    private static IInstantIngestorEventsService service() {
        return (IInstantIngestorEventsService) Application.Service.newInstance(
            IInstantIngestorEventsService.class
        );
    }
}