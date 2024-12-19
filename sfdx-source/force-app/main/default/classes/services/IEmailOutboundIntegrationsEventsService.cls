/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Service Interface for Email Outbound Integration Event channel.
 */
public interface IEmailOutboundIntegrationsEventsService {
    /**
     * @description It creates multiple events of type Email_Outbound_Integration__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    void publishBulkEvents(Map<String, List<String>> payloadsByTopic);

    /**
     * @description It creates events of type Email_Outbound_Integration__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    void publishEvents(Map<String, String> payloadsByTopic);

    /**
     * @description It creates events of type Email_Outbound_Integration__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow);
}