/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Trigger on Email Outbound Integrations Platform event creation.
 */
public class EmailOutboundIntegrationsEventsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor method.
     * @param sObjectList - Email Outbound Integrations Platform event
     */
    public EmailOutboundIntegrationsEventsHandler(List<Email_Outbound_Integration__e> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Email_Outbound_Integration__e.SObjectType,
            EmailOutboundIntegrationsEventsHandler.class
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
        List<Email_Outbound_Integration__e> eventsData = new List<Email_Outbound_Integration__e>();
        String topicName = (String) this.records[0].get('Topic__c');
        try {
            Integer scopeSize = Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.retrieveScopeSize(
                topicName
            );

            for (
                Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++
            ) {
                Email_Outbound_Integration__e eachEmailOutboundIntegrationEvent = (Email_Outbound_Integration__e) this.records[
                        counter
                    ];
                if (
                    eachEmailOutboundIntegrationEvent == null ||
                    eachEmailOutboundIntegrationEvent.Topic__c != topicName
                ) {
                    break;
                }
                eventsData.add(eachEmailOutboundIntegrationEvent);
                EventBusTriggerContext.setResumeCheckpoint(
                    eachEmailOutboundIntegrationEvent.ReplayId
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
     * and passes events for further processing of payload.
     * @param topicName
     * @param eventsData - list of events
     */
    public void routeEvents(String topicName, List<Email_Outbound_Integration__e> eventsData) {
        if (eventsData.isEmpty()) {
            return;
        }
        try {
            IHandleEmailOutboundIntegrationsEvents service = (IHandleEmailOutboundIntegrationsEvents) Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.newInstance(
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
         * @return EmailOutboundIntegrationsEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new EmailOutboundIntegrationsEventsHandler(sObjectList);
        }
    }
}