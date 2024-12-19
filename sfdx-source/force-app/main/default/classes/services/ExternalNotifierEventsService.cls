/**
 * @author Deloitte
 * @date 26/05/2022
 * @description Service class for External_Notifier__e related logic.
 */
public inherited sharing class ExternalNotifierEventsService {
    /**
     * @description It creates events of type External_Notifier__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public static void publishEvents(Map<String, String> payloadsByTopic) {
        service().publishEvents(payloadsByTopic);
    }

    /**
     * @description It creates events of type External_Notifier__e using the passed topic
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
     * @description Creates multiple events of type External_Notifier__e using the passed topic
     * and corresponding payloads and publishes the events.
     * @param topic - topic of the event
     * @param payloadsList - List of Payloads
     */
    public static void publishEventsFromList(String topic, List<String> payloadsList) {
        service().publishEventsFromList(topic, payloadsList);
    }

    /**
     * @description It creates instance of ExternalNotifierEventsServiceImpl class.
     * @return IExternalNotifierEventsService - return instance of ExternalNotifierEventsServiceImpl
     */
    private static IExternalNotifierEventsService service() {
        return (IExternalNotifierEventsService) Application.Service.newInstance(
            IExternalNotifierEventsService.class
        );
    }
}