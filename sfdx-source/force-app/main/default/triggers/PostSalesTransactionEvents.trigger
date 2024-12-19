/**
 * @description Trigger on PostSalesTransaction Platform Event.
 * The PostSalesTransaction and PreSalesTransaction platform events have the same shape as the Instant_Ingestor
 * type.  We leverage the same event handler for all three types
 */
trigger PostSalesTransactionEvents on PostSalesTransaction__e ( after insert ) {
    fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
}