/**
 * @description Trigger on PreSalesTransaction Platform Event.
 * The PreSalesTransaction and PreSalesTransaction platform events have the same shape as the Instant_Ingestor
 * type.  We leverage the same event handler for all three types
 */
trigger PreSalesTransactionEvents on PreSalesTransaction__e ( after insert ) {
    fflib_SObjectDomain.triggerHandler(InstantIngestorEventsHandler.class);
}