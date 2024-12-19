/**
 * @author Deloitte
 * @date 26/05/2022
 * @description Service implementation class for External_Notifier__e related logic.
 */
public inherited sharing class ExternalNotifierEventsServiceImpl implements IExternalNotifierEventsService {
    private static final String LOG_SERVICE = 'External Notifier Events Service';
    private static final String LOG_DOMAIN = 'Sales';
    @TestVisible
    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();
    
    /**
     * @description It creates events of type External_Notifier__e using the passed topic
     * and corresponding payload and publishes the events.
     * @param payloadsByTopic - map of topic to payload
     */
    public void publishEvents(Map<String, String> payloadsByTopic) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        createEvents(payloadsByTopic, eventsUOW);
        commitWork(eventsUOW);
    }

    /**
     * @description It creates events of type External_Notifier__e using the passed topic
     * and corresponding payload. It combines publish of the events with other records commit
     * in a single transaction.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    public void publishEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        if (payloadsByTopic == null) {
            return;
        }
        createEvents(payloadsByTopic, uow);
        commitWork(uow);
    }

    /**
     * @description Creates multiple events of type External_Notifier__e using the passed topic
     * and corresponding payloads and publishes the events.
     * @param topic - topic of the event
     * @param payloadsList - List of Payloads
     */
    public void publishEventsFromList(String topic, List<String> payloadsList) {
        if ((String.isBlank(topic)) || (payloadsList.isEmpty())) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String payload : payloadsList) {
            eventsUOW.registerPublishAfterSuccessTransaction(
                new External_Notifier__e(
                    Payload__c = payload,
                    Topic__c = topic
                )
            );
        }
        commitWork(eventsUOW);
    }

    /**
     * @description It creates events of type External_Notifier__e using the passed topic
     * and corresponding payload.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    private void createEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        for (String eachTopic : payloadsByTopic.keySet()) {
            uow.registerPublishAfterSuccessTransaction(
                new External_Notifier__e(
                    Payload__c = payloadsByTopic.get(eachTopic),
                    Topic__c = eachTopic
                )
            );
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
     * @description Get log instance of IGenericLogEntry implementation
     * @return instance of IGenericLogEntry imlementation
     */
    @TestVisible
    private static IGenericLogEntry getGenericLog(){
        return GenericLoggerService.createGenericLog(
            LOG_SERVICE,
            LOG_DOMAIN,
            GenericLogEntry.SeverityLevel.HIGH
        );
    }

    /**
     * @description Publish log instances added to list
     */
    @TestVisible
    private static void publishGenericLog(){
        GenericLoggerService.publish(genericLogList);
        genericLogList.clear();
    }
}