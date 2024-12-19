/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Instant Ingestor Events trigger handler class.
 */
public class InstantIngestorEventsHandler extends ApplicationDomainHandler {
    private static final String TOPIC_API_NAME = 'Topic__c';
    /**
     * @description Constructor for the Instant_Ingestor event type
     * @param sObjects The list of events from the trigger
     */
    public InstantIngestorEventsHandler(List<Instant_Ingestor__e> sObjects) {
        // Ads & Promos
        super(sObjects);
        setContextBypass(Instant_Ingestor__e.SObjectType, InstantIngestorEventsHandler.class);
    }

    /**
     * @description Constructor for PostSalesTransaction event type
     * @param sObjects The list of events from the trigger
     */
    public InstantIngestorEventsHandler(List<PostSalesTransaction__e> sObjects) {
        // Postsale scenarios
        super(sObjects);
        setContextBypass(PostSalesTransaction__e.SObjectType, InstantIngestorEventsHandler.class);
    }

    /**
     * @description Constructor for PreSalesTransaction event type
     * @param sObjects The list of events from the trigger
     */
    public InstantIngestorEventsHandler(List<PreSalesTransaction__e> sObjects) {
        // Presales Scenarios
        super(sObjects);
        setContextBypass(PreSalesTransaction__e.SObjectType, InstantIngestorEventsHandler.class);
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

        /*
            20240912 - This handler is being used to route all three of the platform event types after discovering
            that the throughput for the kafka events coming from SSMO and Mx Portal was not high enough to consume
            the volume we would be getting.  Part of the quick solution to that is to break the load out into 3 channels
            which we've done with PostSalesTransaction__e, PreSalesTransaction__e, and Instant_Ingestor__e.
            To minimize the impact to all the classes downstream from here (this is being modified at the 11th hour before
            go live of SMB Transformation) we're transforming the PreSalesTransaction__e and PostSalesTransaction__e
            records into the original Instant_Ingestor__e before routing it off to the InstantIngestorEventsService class.
            In order for this to work, we've made sure that all 3 platform events have exactly the same api
            (Payload__c, Topic__c) so they are interchangeable.
            TODO: This needs to be refactored after go live.  This hacky workaround is brittle since it relies on the
            implicit expectation that these events will always be the same shape.  At the very least, we need more tests
            to ensure that any changes to the event fields themselves that breaks this expectation is made visible through
            a failing test class.

            Of course there is also the opportunity to bulkify this process.  At the moment it is only handling 1 event
            at a time for each channel.
         */
        List<Instant_Ingestor__e> eventsData = new List<Instant_Ingestor__e>();
        String topicName = (String) this.records[0].get(TOPIC_API_NAME);
        try {
            Integer scopeSize = Application.INSTANT_INGESTOR_EVENT.retrieveScopeSize(topicName);

            for (
                Integer counter = 0; counter < scopeSize && counter < this.records.size(); counter++
            ) {
                SObject eachInstantIngestorEvent = this.records[counter];
                if (
                    eachInstantIngestorEvent == null ||
                    ((String) eachInstantIngestorEvent.get('Topic__c')) != topicName
                ) {
                    break;
                }
                Instant_Ingestor__e objEvent = new Instant_Ingestor__e(
                    Topic__c = (String) eachInstantIngestorEvent.get('Topic__c'),
                    Payload__c = (String) eachInstantIngestorEvent.get('Payload__c')
                );
                eventsData.add(objEvent);
                EventBusTriggerContext.setResumeCheckpoint(
                    (String) eachInstantIngestorEvent.get('ReplayId')
                );

                // To ensure that the correct Platform Event object is used to publish any downstream events
                // after this one has completed, set the InstantIngestorEventService.eventType to reflect the
                // same SObjectType as the inbound Platform Event.  The eventFactory will use this to dynamically
                // generate the same Platform Event.
                InstantIngestorEventsService.setPlatformEventType(
                    eachInstantIngestorEvent.getSObjectType()
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
     * and passes Instant Ingestor events for further processing of payload.
     * @param topicName
     * @param eventsData
     */
    public void routeEvents(String topicName, List<Instant_Ingestor__e> eventsData) {
        if (eventsData.isEmpty()) {
            return;
        }
        try {
            IHandleInstantIngestorEvents service = (IHandleInstantIngestorEvents) Application.INSTANT_INGESTOR_EVENT.newInstance(
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
         * @param sObjects
         * @return InstantIngestorEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            if (sObjects.isEmpty()) {
                return new InstantIngestorEventsHandler((List<Instant_Ingestor__e>) sObjects);
            }
            if (sObjects[0].getSObjectType() === PostSalesTransaction__e.SObjectType) {
                return new InstantIngestorEventsHandler((List<PostSalesTransaction__e>) sObjects);
            }
            if (sObjects[0].getSObjectType() === PreSalesTransaction__e.SObjectType) {
                return new InstantIngestorEventsHandler((List<PreSalesTransaction__e>) sObjects);
            }
            return new InstantIngestorEventsHandler((List<Instant_Ingestor__e>) sObjects);
        }
    }
}