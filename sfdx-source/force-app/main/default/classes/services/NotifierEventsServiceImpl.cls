/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Service implementation class for Notifier__e related logic.
 */
public inherited sharing class NotifierEventsServiceImpl implements INotifierEventsService {
    private static final String EVENT_UUID_FIELD_NAME = 'EventUuid';
    private static final String GENERIC = 'Generic';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_NOTIFIER_EVENT = 'NOTIFIER EVENT PUBLISHER';
    private static final String LOG_NOTIFIER_POST_PROCESSING = 'NOTIFIER SUBSCRIBER POST PROCESSING';
    private static final String LOG_NOTIFIER_PRE_PROCESSING = 'NOTIFIER SUBSCRIBER PRE PROCESSING';
    private static final String LOG_SERVICE = 'Notifier Events Service';
    private static final String NOTIFIER_EVENT_NAME = 'Notifier__e';
    private static final String PARTITION_KEY = 'Partition_Key__c';
    private static final String PARTITION_KEY_GENERIC = 'Generic';
    private static final String PAYLOAD_FIELD_NAME = 'Payload__c';
    private static final String TOPIC_FIELD_NAME = 'Topic__c';
    private static final String UUID_FIELD_NAME = 'UUID__c';
    @TestVisible
    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();

    /**
     * @description It creates multiple events of type Notifier__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be created
     */
    public void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        List<sObject> notifierEvents = new List<sObject>();
        sObject platformEventInstance;
        for (String eachTopicName : payloadsByTopic.keySet()) {
            for (String eachPayload : payloadsByTopic.get(eachTopicName)) {
                platformEventInstance = createEventByTopic(eachPayload, eachTopicName);
                eventsUOW.registerPublishAfterSuccessTransaction(platformEventInstance);
                notifierEvents.add(platformEventInstance);
            }
        }
        commitWork(eventsUOW);
        publishGenericLogEvents(notifierEvents);
    }

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public void publishEvents(Map<String, String> payloadsByTopic) {
        publishEvents(payloadsByTopic, Application.UNITOFWORK.newInstance());
    }

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    public void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        if (payloadsByTopic == null) {
            return;
        }
        List<sObject> notifierEvents = new List<sObject>();
        createEvents(payloadsByTopic, uow, notifierEvents);
        commitWork(uow);
        publishGenericLogEvents(notifierEvents);
    }

    /**
     * @description It initiates and retuns SObject instance with the event details
     * based on received Topic and Payload.
     * @param eventPayload
     * @param eventTopic
     * @return SObject
     */
    private SObject createEventByTopic(String eventPayload, String eventTopic) {
        String eventName;
        eventName = Application.NOTIFIER_EVENT.retrievePlatformEventChannelName(eventTopic) <> null
            ? Application.NOTIFIER_EVENT.retrievePlatformEventChannelName(eventTopic)
            : NOTIFIER_EVENT_NAME;
        SObject eventInstance = ((SObject) Type.forName(eventName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getSObjectType()
            .newSObject(null, true);
        return setPlatformEventFields(
            eventInstance.getSObjectType().getDescribe().fields.getMap(),
            eventInstance,
            eventPayload,
            eventTopic,
            getPartitionKey(eventTopic)
        );
    }

    /**
     * @description It creates events of type Notifier__e using the passed topic
     * and corresponding payload.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     * @param notifierEvents
     */
    private void createEvents(
        Map<String, String> payloadsByTopic,
        fflib_ISObjectUnitOfWork uow,
        List<sObject> notifierEvents
    ) {
        sObject platformEventInstance;
        for (String eachTopic : payloadsByTopic.keySet()) {
            platformEventInstance = createEventByTopic(payloadsByTopic.get(eachTopic), eachTopic);
            uow.registerPublishAfterSuccessTransaction(platformEventInstance);
            notifierEvents.add(platformEventInstance);
        }
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
            genericLogList.add(getGenericLog().logException(commitWorkException));
            publishGenericLog();
        }
    }

    /**
     * @description It is used to return partition key based on topic provided.
     * @param topicName
     * @return String
     */
    private String getPartitionKey(String topicName) {
        return Application.NOTIFIER_EVENT.retrievePartitionKey(topicName) != null
            ? Application.NOTIFIER_EVENT.retrievePartitionKey(topicName)
            : PARTITION_KEY_GENERIC;
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
     * @description It publishes events into the Generic Logger (Scalyr).
     * @param notifierEvents - list of published events
     */
    @TestVisible
    private static void publishGenericLogEvents(List<sObject> notifierEvents) {
        List<Generic_Log__c> genericLogs = new List<Generic_Log__c>();
        for (sObject eachEvent : notifierEvents) {
            genericLogs.add(
                new Generic_Log__c(
                    Log_Details__c = GenericLoggerService.createGenericLog(
                            LOG_NOTIFIER_EVENT,
                            (String) eachEvent.get(TOPIC_FIELD_NAME),
                            GenericLogEntry.SeverityLevel.LOW
                        )
                        .logCallout('', (String) eachEvent.get(PAYLOAD_FIELD_NAME), '', '')
                        .setUUId((String) eachEvent.get(EVENT_UUID_FIELD_NAME))
                        .setCategory(GenericLogEntry.GENERIC_LOG_INFORMATION)
                        .setLogLevel(GenericLogEntry.GENERIC_LOG_INFORMATION)
                        .convertToJSON()
                )
            );
        }
        publishLogs(genericLogs);
    }

    /**
     * @description Publish log instances added to list
     */
    @TestVisible
    private static void publishGenericLog() {
        GenericLoggerService.publish(genericLogList);
        genericLogList.clear();
    }

    /**
     * @description It publishes events into the Generic Logger (Scalyr).
     * @param genericLogsInstances
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

    /**
     * @description It is used map field values for the current event.
     * @param platformEventFields
     * @param platformEventInstance
     * @param payloadValue
     * @param topicNameValue
     * @param partitionKeyValue
     * @return sObject
     */
    private sObject setPlatformEventFields(
        Map<String, Schema.SObjectField> platformEventFields,
        SObject platformEventInstance,
        String payloadValue,
        String topicNameValue,
        String partitionKeyValue
    ) {
        if (platformEventFields.containsKey(PAYLOAD_FIELD_NAME)) {
            platformEventInstance.put(platformEventFields.get(PAYLOAD_FIELD_NAME), payloadValue);
        }
        if (platformEventFields.containsKey(TOPIC_FIELD_NAME)) {
            platformEventInstance.put(platformEventFields.get(TOPIC_FIELD_NAME), topicNameValue);
        }
        if (platformEventFields.containsKey(PARTITION_KEY)) {
            platformEventInstance.put(platformEventFields.get(PARTITION_KEY), partitionKeyValue);
        }
        return platformEventInstance;
    }
}