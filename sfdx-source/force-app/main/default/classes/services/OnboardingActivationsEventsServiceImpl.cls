/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Service Implementation for Onboarding & Activations Event Channel.
 */
public with sharing class OnboardingActivationsEventsServiceImpl implements IOnboardingActivationsEventsService{
    private static final String LOG_SERVICE = 'Onboarding & Activations Events Service';
    private static final String LOG_DOMAIN = 'Sales';
    @TestVisible
    private static List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();

    /**
     * @description It creates multiple events of type Onboarding_Activation__e using the passed topic
     * and corresponding payload in a single transaction.
     * @param payloadsByTopic - map of topic to payloads to be created
     */
    public void publishBulkEvents(Map<String, List<String>> payloadsByTopic) {
        if (payloadsByTopic == null) {
            return;
        }
        fflib_ISObjectUnitOfWork eventsUOW = Application.UNITOFWORK.newInstance();
        for (String eachTopicName : payloadsByTopic.keySet()) {
            for (String eachPayload : payloadsByTopic.get(eachTopicName)) {
                eventsUOW.registerPublishAfterSuccessTransaction(
                    new Onboarding_Activation__e(Payload__c = eachPayload, Topic__c = eachTopicName)
                );
            }
        }
        commitWork(eventsUOW);
    }

    /**
     * @description It creates events of type Onboarding_Activation__e using the passed topic
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
     * @description It creates events of type Onboarding_Activation__e using the passed topic
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
     * @description It creates events of type Onboarding_Activation__e using the passed topic
     * and corresponding payload.
     * @param payloadsByTopic - map of topic to payload
     * @param uow - instance of UnitOfWork
     */
    private void createEvents(Map<String, String> payloadsByTopic, fflib_ISObjectUnitOfWork uow) {
        for (String eachTopic : payloadsByTopic.keySet()) {
            uow.registerPublishAfterSuccessTransaction(
                new Onboarding_Activation__e(
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
    private static IGenericLogEntry getGenericLog() {
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
    private static void publishGenericLog() {
        GenericLoggerService.publish(genericLogList);
        genericLogList.clear();
    }
}