/**
 * @author Deloitte
 * @date 12/03/2024
 * @description Service implementation class for logic related to re-processing of halted self-serve quotes.
 */
public inherited sharing class HaltedSelfServeQuotesReprocessorServImpl implements IHaltedSelfServeQuotesReprocessorService {
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String LOG_SERVICE_NAME = 'Self-Serve Stuck Records Processing';
    private static final String LOG_DOMAIN_NAME = 'Self-Serve Stuck Quotes Processing';
    private static final String SUCCESS = 'Success';
    /**
     * @description It initiates the re-processing of halted self serve quotes due to cpq managed package queueable calculator jobs row locks.
     * @JIRA #LEM-23462
     * @param selfServeHaltedQuotes
     */
    public void initiateHaltedSelfServeQuotesReprocessing(
        List<SBQQ__Quote__c> selfServeHaltedQuotes
    ) {
        Set<Id> inboundIngestionLogIds = new Set<Id>();
        Map<Id, SBQQ__Quote__c> quotesByIngestionLogId = new Map<Id, SBQQ__Quote__c>();
        UpdateUnitOfWorkHelper updateUnitOfWorkHelperForQuotes = new UpdateUnitOfWorkHelper();
        try {
            for (SBQQ__Quote__c eachQuote : selfServeHaltedQuotes) {
                inboundIngestionLogIds.add(eachQuote.SBQQ__Opportunity2__r.Ingestion_log_Id__c);
                quotesByIngestionLogId.put(
                    eachQuote.SBQQ__Opportunity2__r.Ingestion_log_Id__c,
                    eachQuote
                );
            }
            prepareQuotesForUpdate(
                inboundIngestionLogIds,
                quotesByIngestionLogId,
                updateUnitOfWorkHelperForQuotes
            );
        } catch (Exception processingExceptions) {
            publishExceptionToGenericLog(processingExceptions);
        }
    }

    /**
     * @description It is used to collect and prepare quotes for update.
     * @param inboundIngestionLogIds
     * @param quotesByIngestionLogId
     * @param updateUnitOfWorkHelperForQuotes
     */
    private void prepareQuotesForUpdate(
        Set<Id> inboundIngestionLogIds,
        Map<Id, SBQQ__Quote__c> quotesByIngestionLogId,
        UpdateUnitOfWorkHelper updateUnitOfWorkHelperForQuotes
    ) {
        Set<id> quoteIdsToUpdate = new Set<id>();
        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectById(inboundIngestionLogIds)
        ) {
            if (
                eachInboundIngestionLog.Status__c == SUCCESS &&
                quotesByIngestionLogId.containsKey(eachInboundIngestionLog.Id)
            ) {
                quoteIdsToUpdate.add(quotesByIngestionLogId.get(eachInboundIngestionLog.Id).Id);
            }
        }
        if (quoteIdsToUpdate.isEmpty()) {
            return;
        }
        InstantIngestorEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    quoteIdsToUpdate,
                    Integer.valueof(System.Label.Instant_Ingestor_Chunk_Size)
                )
            }
        );
    }

    /**
     * @description It is used to publish error details in case of any exception/failure
     * @param processingExceptions
     */
    private void publishExceptionToGenericLog(Exception processingExceptions) {
        Logger.publish(processingExceptions, LogEntry.SeverityLevel.HIGH);
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_NAME,
                    LOG_DOMAIN_NAME,
                    GenericLogEntry.SeverityLevel.MEDIUM
                )
                .logException(processingExceptions)
        );
    }
}