/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Trigger on Instant Ingestor Platform Event.
 * The Instant_Ingestor platform events have the same shape as the PreSalesTransaction and PostSalesTransaction
 * types.  We leverage the same event handler for all three types
 */
trigger InstantIngestorEvents on Instant_Ingestor__e(after insert) {
    fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
}