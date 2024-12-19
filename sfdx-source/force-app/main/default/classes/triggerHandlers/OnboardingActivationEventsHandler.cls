/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Trigger Handler for Onboarding and Activations Event creation.
 */
public class OnboardingActivationEventsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor method.
     * @param sObjectList - Onboarding & Activations event list
     */
    public OnboardingActivationEventsHandler(List<Onboarding_Activation__e> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Onboarding_Activation__e.SObjectType,
            OnboardingActivationEventsHandler.class
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
        List<Onboarding_Activation__e> eventsData = new List<Onboarding_Activation__e>();
        String topicName = (String) this.records[0].get('Topic__c');
        try {
            Integer scopeSize = Application.ONBOARDING_AND_ACTIVATIONS_EVENT.retrieveScopeSize(
                topicName
            );

            for (
                Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++
            ) {
                Onboarding_Activation__e eachOnboardingAndActivationsEvent = (Onboarding_Activation__e) this.records[
                        counter
                    ];
                if (
                    eachOnboardingAndActivationsEvent == null ||
                    eachOnboardingAndActivationsEvent.Topic__c != topicName
                ) {
                    break;
                }
                eventsData.add(eachOnboardingAndActivationsEvent);
                EventBusTriggerContext.setResumeCheckpoint(
                    eachOnboardingAndActivationsEvent.ReplayId
                );
            }
            routeEvents(topicName, eventsData);
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
    public void routeEvents(String topicName, List<Onboarding_Activation__e> eventsData) {
        if (eventsData.isEmpty()) {
            return;
        }
        try {
            IHandleOnboardingActivationsEvents service = (IHandleOnboardingActivationsEvents) Application.ONBOARDING_AND_ACTIVATIONS_EVENT.newInstance(
                topicName
            );
            service.execute(eventsData);
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
         * @return OnboardingActivationEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OnboardingActivationEventsHandler(sObjectList);
        }
    }
}