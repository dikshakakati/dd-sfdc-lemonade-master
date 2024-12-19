/**
 * @author Deloitte
 * @date 16/05/2022
 * @description Notifier events trigger handler class.
 */
public class NotifierEventsHandler extends ApplicationDomainHandler {
    private static final String LOG_NOTIFIER_EVENT = 'NOTIFIER EVENT SUBSCRIBER';
    private static final String LOG_NOTIFIER_POST_PROCESSING = 'NOTIFIER SUBSCRIBER POST PROCESSING';
    private static final String LOG_NOTIFIER_PRE_PROCESSING = 'NOTIFIER SUBSCRIBER PRE PROCESSING';
    private static final String PAYLOAD_FIELD_NAME = 'Payload__c';
    private static final String REPLAY_ID = 'ReplayId';
    private static final String TOPIC_FIELD_NAME = 'Topic__c';
    private static final String UUID_FIELD_NAME = 'EventUuid';

    /**
     * @description Constructor method.
     * @param sObjectList - Notifier event list
     */
    public NotifierEventsHandler(List<Notifier__e> sObjectList) {
        super(sObjectList);
        setContextBypass(Notifier__e.SObjectType, NotifierEventsHandler.class);
    }

    /**
     * @description Constructor for Rollup event type
     * @param sObjects
     */
    public NotifierEventsHandler(List<Work_Order_Processor__e> sObjects) {
        super(sObjects);
        setContextBypass(Work_Order_Processor__e.SObjectType, NotifierEventsHandler.class);
    }

    /**
     * @description Constructor for Rollup event type
     * @param sObjects
     */
    public NotifierEventsHandler(List<Integration_Request_Processor__e> sObjects) {
        super(sObjects);
        setContextBypass(Integration_Request_Processor__e.SObjectType, NotifierEventsHandler.class);
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
        List<Notifier__e> eventsData = new List<Notifier__e>();
        String topicName = (String) this.records[0].get(TOPIC_FIELD_NAME);
        try {
            Integer scopeSize = Application.NOTIFIER_EVENT.retrieveScopeSize(topicName);

            for (
                Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++
            ) {
                SObject eachNotifierEvent = this.records[counter];
                if (
                    eachNotifierEvent == null ||
                    ((String) eachNotifierEvent.get(TOPIC_FIELD_NAME)) != topicName
                ) {
                    break;
                }
                Notifier__e platformEventInstance = new Notifier__e(
                    Topic__c = (String) eachNotifierEvent.get(TOPIC_FIELD_NAME),
                    Payload__c = (String) eachNotifierEvent.get(PAYLOAD_FIELD_NAME),
                    UUID__c = (String) eachNotifierEvent.get(UUID_FIELD_NAME)
                );
                eventsData.add(platformEventInstance);
                EventBusTriggerContext.setResumeCheckpoint(
                    (String) eachNotifierEvent.get(REPLAY_ID)
                );
            }
            routeEvents(topicName, eventsData);
            //publishGenericLogEvents(this.records);
        } catch (Exception routeEventsException) {
            // Exception logging to allow processing of other topics in the iteration.
            Logger.publish(routeEventsException, LogEntry.SeverityLevel.MEDIUM);
        }
    }

    /**
     * @description It calls service class corresponding to each passed topic
     * and passes Notifier events for further processing of payload.
     * @param topicName
     * @param eventsData - list of Notifier events
     */
    public void routeEvents(String topicName, List<Notifier__e> eventsData) {
        if (eventsData.isEmpty()) {
            return;
        }
        try {
            IHandleNotifierEvents service = (IHandleNotifierEvents) Application.NOTIFIER_EVENT.newInstance(
                topicName
            );
            List<Generic_Log__c> genericLogsInstances = new List<Generic_Log__c>();
            genericLogsInstances.addAll(
                createGenericLogInstance(eventsData, LOG_NOTIFIER_PRE_PROCESSING)
            );
            service.execute(eventsData);
            genericLogsInstances.addAll(
                createGenericLogInstance(eventsData, LOG_NOTIFIER_POST_PROCESSING)
            );
            publishLogs(genericLogsInstances);
        } catch (Exception routeEventsException) {
            // Exception logging to allow processing of other topics in the iteration.
            Logger.publish(routeEventsException, LogEntry.SeverityLevel.MEDIUM);
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
            if (sObjectList.isEmpty()) {
                return new NotifierEventsHandler((List<Notifier__e>) sObjectList);
            }
            if (sObjectList[0].getSObjectType() === Integration_Request_Processor__e.SObjectType) {
                return new NotifierEventsHandler(
                    (List<Integration_Request_Processor__e>) sObjectList
                );
            }
            if (sObjectList[0].getSObjectType() === Work_Order_Processor__e.SObjectType) {
                return new NotifierEventsHandler((List<Work_Order_Processor__e>) sObjectList);
            }
            return new NotifierEventsHandler((List<Notifier__e>) sObjectList);
        }
    }

    /**
     * @description It publishes events into the Generic Logger (Scalyr).
     * @param  events - list of subscribed events
     * @param processingType - Type of logger.(Pre vs post)
     * @return  List<Generic_Log__c> - List of Generic log
     */
    @TestVisible
    private static List<Generic_Log__c> createGenericLogInstance(
        List<Notifier__e> events,
        String processingType
    ) {
        List<Generic_Log__c> genericLogs = new List<Generic_Log__c>();
        for (Notifier__e eachEvent : events) {
            genericLogs.add(
                new Generic_Log__c(
                    Log_Details__c = GenericLoggerService.createGenericLog(
                            processingType,
                            eachEvent.Topic__c,
                            GenericLogEntry.SeverityLevel.LOW
                        )
                        .logCallout('', eachEvent.payload__c, '', '')
                        .setUUId(
                            eachEvent.EventUuid == null ? eachEvent.UUID__c : eachEvent.EventUuid
                        )
                        .setCategory(GenericLogEntry.GENERIC_LOG_INFORMATION)
                        .setLogLevel(GenericLogEntry.GENERIC_LOG_INFORMATION)
                        .convertToJSON()
                )
            );
        }
        return genericLogs;
    }

    /**
     * @description It publishes events into the Generic Logger (Scalyr).
     * @param  genericLogsInstances
     */
    private static void publishLogs(List<Generic_Log__c> genericLogsInstances) {
        Integer dmlStatementsUsed = Limits.getDmlStatements();
        Integer dmlStatementsRemaining = Limits.getLimitDmlStatements() - dmlStatementsUsed;
        Integer recordsProcessed = Limits.getDmlRows();
        Integer recordsRemaining = Limits.getLimitDmlRows() - recordsProcessed;

        if (dmlStatementsRemaining > 1 && recordsRemaining > genericLogsInstances.size()) {
            fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(genericLogsInstances);
            uow.commitWork();
        }
    }
}