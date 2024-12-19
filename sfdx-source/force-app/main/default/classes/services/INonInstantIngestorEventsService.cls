/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Interface for NonInstantInboundIngestionEventsService class.
 */
public interface INonInstantIngestorEventsService {
    /**
     * @description It creates multiple events of type Notifier__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    void publishBulkEvents(Map<String, List<String>> payloadsByTopic);

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    void publishEvents(Map<String, String> payloadsByTopic);

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow);
}