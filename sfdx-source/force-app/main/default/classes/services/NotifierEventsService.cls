/**
 * @author Deloitte
 * @date 16/05/2022
 * @description Service class for Notifier__e related logic.
 */
public inherited sharing class NotifierEventsService {
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
     * @description It creates instance of NotifierEventsServiceImpl class.
     * @return INotifierEventsService - return instance of NotifierEventsServiceImpl
     */
    private static INotifierEventsService service() {
        return (INotifierEventsService) Application.Service.newInstance(
            INotifierEventsService.class
        );
    }
}