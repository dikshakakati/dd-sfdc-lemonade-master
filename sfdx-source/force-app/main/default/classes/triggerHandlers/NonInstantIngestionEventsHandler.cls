/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Non Instant Ingestion events trigger handler class.
 */
public class NonInstantIngestionEventsHandler extends ApplicationDomainHandler {
    private static final String LOG_SERVICE = 'Non Instant Ingestion Event Handler';
    private static final String LOG_DOMAIN = 'SSMO';

    /**
     * @description Constructor method.
     * @param sObjectList
     */
    public NonInstantIngestionEventsHandler(List<Non_Instant_Ingestor__e> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Non_Instant_Ingestor__e.SObjectType,
            NonInstantIngestionEventsHandler.class
        );
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        /**
         * In this approach payload corresponding to a single topic will be processed
         * in a transaction. If a topic changes in the list of events then
         * iteration will break and further procssesing will happen with payload collected
         * previously for a single topic. In addition to that iteration will also break in-case
         * counter limit for the particular topic is exceeded.
         * It reduces the chances of hitting governor limits
         * by executing limited payload corresponding to a single topic in a for loop.
         */
        List<Non_Instant_Ingestor__e> eventsData = new List<Non_Instant_Ingestor__e>();
        String topicName = (String) this.records[0].get('Topic__c');
        try {
            Integer scopeSize = Application.NON_INSTANT_INGESTOR_EVENT.retrieveScopeSize(topicName);

            for (
                Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++
            ) {
                Non_Instant_Ingestor__e eachInboundIngestionEvent = (Non_Instant_Ingestor__e) this.records[
                        counter
                    ];
                if (
                    eachInboundIngestionEvent == null ||
                    eachInboundIngestionEvent.Topic__c != topicName
                ) {
                    break;
                }
                eventsData.add(eachInboundIngestionEvent);
                EventBusTriggerContext.setResumeCheckpoint(eachInboundIngestionEvent.ReplayId);
            }
            routeEvents(topicName, eventsData);
        } catch (Exception routeEventsException) {
            // Exception logging to allow processing of other topics in the iteration.
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE,LOG_DOMAIN,GenericLogEntry.SeverityLevel.LOW)
                    .logException(routeEventsException)
            );
        }
    }

    /**
     * @description It calls service class corresponding to each passed topic
     * and passes Notifier events for further processing of payload.
     * @param topicName
     * @param eventsData - list of Notifier events
     */
    public void routeEvents(String topicName, List<Non_Instant_Ingestor__e> eventsData) {
        if (eventsData.isEmpty()) {
            return;
        }
        try {
            IHandleNonInstantIngestionEvents service = (IHandleNonInstantIngestionEvents) Application.NON_INSTANT_INGESTOR_EVENT.newInstance(
                topicName
            );
            service.execute(eventsData);
        } catch (Exception routeEventsException) {
            // Exception logging to allow processing of other topics in the iteration.
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE,LOG_DOMAIN,GenericLogEntry.SeverityLevel.LOW) 
                    .logException(routeEventsException)
            );
        }
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description It implements construct method of fflib_SObjectDomain.IConstructable.
         * @param sObjectList - List of SObjects
         * @return NotifierEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new NonInstantIngestionEventsHandler(sObjectList);
        }
    }
}