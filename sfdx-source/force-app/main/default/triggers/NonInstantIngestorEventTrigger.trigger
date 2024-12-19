/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Trigger on Non Inbound Ingestion Platform Event.
 */
trigger NonInstantIngestorEventTrigger on Non_Instant_Ingestor__e (after insert) {
    fflib_SObjectDomain.triggerHandler(NonInstantIngestionEventsHandler.class);
}