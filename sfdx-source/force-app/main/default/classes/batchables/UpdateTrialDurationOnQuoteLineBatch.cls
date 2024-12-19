/**
 * @author Deloitte
 * @date 03/12/2024
 * @description Batch class that updates the trial duration on quoteline from the ingestion logs.
 */
public with sharing class UpdateTrialDurationOnQuoteLineBatch implements Database.Batchable<SObject> {
    private static final String STANDARD_STOREFRONT_PACKAGE = 'Standard Storefront Package';
    private static final String STOREFRONT = 'Storefront';

    /**
     * @description It queries all the success ingestion log that have integration type as
     * onboarding event or mx portal new store expansion
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return InboundIngestionLogsSelector.newInstance()
            .selectSuccessIngestionLogsWithSSMOSourceORMxPortalNSEIntegrationType();
    }

    /**
     * @description It updates trial period and segment on the self serve quoteLines where trial period is blank
     * @param batchableContext
     * @param inboundIngestionLogs
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs
    ) {
        Set<String> uuids = new Set<String>();
        Map<String, String> payloadTrialDurationByUniqueKey = new Map<String, String>();

        processInboundLogs(inboundIngestionLogs, uuids, payloadTrialDurationByUniqueKey);

        updateQuoteLines(uuids, payloadTrialDurationByUniqueKey);
    }

    /**
     * @description It is used to process the inbound ingestion logs and populate trial duration map.
     * @param inboundIngestionLogs
     * @param uuids
     * @param payloadTrialDurationByUniqueKey
     */
    private void processInboundLogs(
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs,
        Set<String> uuids,
        Map<String, String> payloadTrialDurationByUniqueKey
    ) {
        String uniqueKey;
        InstantIngestionPayloadParser payload;
        for (Inbound_Ingestion_Log__c log : inboundIngestionLogs) {
            uuids.add(log.UUID__c);
            payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
                log.Payload__c,
                InstantIngestionPayloadParser.class
            );
            for (
                InstantIngestionPayloadParser.OrderProductsDetails orderProduct : payload.store.orderProducts
            ) {
                for (
                    InstantIngestionPayloadParser.ProductOptionsDetails productOption : orderProduct.productOptions
                ) {
                    if (orderProduct.name == STANDARD_STOREFRONT_PACKAGE) {
                        orderProduct.name = STOREFRONT;
                    }
                    uniqueKey = payload.uuid + orderProduct.name + productOption.name;
                    payloadTrialDurationByUniqueKey.put(uniqueKey, productOption.trialDuration);
                }
            }
        }
    }

    /**
     * @description It is used to update the quote lines's trial period and segment based on the uuids and trial duration map.
     * @param uuids
     * @param payloadTrialDurationByUniqueKey
     */
    private void updateQuoteLines(
        Set<String> uuids,
        Map<String, String> payloadTrialDurationByUniqueKey
    ) {
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        String uniqueKey, trialDuration;
        for (
            SBQQ__QuoteLine__c quoteLine : QuoteLineItemsSelector.newInstance()
                .selectSelfServeQuoteLineItemsWithBlankTrialPeriodByUUIDs(uuids)
        ) {
            uniqueKey =
                quoteLine.Unique_Identifier__c +
                quoteLine.Package__c +
                quoteLine.SBQQ__ProductName__c;
            trialDuration = payloadTrialDurationByUniqueKey.get(uniqueKey);
            if (trialDuration != null && quoteLine.SBQQ__Quote__r.Segment__c != null) {
                quoteLinesToUpdate.add(
                    new SBQQ__QuoteLine__c(
                        Id = quoteLine.Id,
                        Segment__c = quoteLine.SBQQ__Quote__r.Segment__c,
                        Trial_Period__c = trialDuration
                    )
                );
            }
        }
        if (!quoteLinesToUpdate.isEmpty()) {
            SBQQ.TriggerControl.Disable();
            update quoteLinesToUpdate;
            SBQQ.TriggerControl.Enable();
        }
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}