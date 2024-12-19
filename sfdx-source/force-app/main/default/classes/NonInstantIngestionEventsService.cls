/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Service class for Inbound_Ingestion_Log__e related logic.
 */
public inherited sharing class NonInstantIngestionEventsService {
    /**
     * @description It creates multiple events of type Notifier__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be passed
     */
    public static void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        service().publishBulkEvents(payloadsByTopic);
    }

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public static void publishEvents(Map<String, String> payloadsByTopic) {
        service().publishEvents(payloadsByTopic);
    }

    /**
     * @description It creates events of type Notifier__e using the passed topic
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
     * @description It creates instance of InboundIngestionEventsServiceImpl class.
     * @return INonInstantIngestorEventsService - return instance of NonInstantIngestorEventsServiceImpl
     */
    private static INonInstantIngestorEventsService service() {
        return (INonInstantIngestorEventsService) Application.Service.newInstance(
            INonInstantIngestorEventsService.class
        );
    }
}