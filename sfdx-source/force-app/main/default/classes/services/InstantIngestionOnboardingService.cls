/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class to create SSMO and SSOB related records by JSON payload.
 *
 */
public inherited sharing class InstantIngestionOnboardingService implements IHandleInstantIngestorEvents {
    /**
     * @description This method is used to handle the published Instant Ingestor events.
     * @param instantIngestorEvents list of platform events with payload
     */
    public static void execute(List<Instant_Ingestor__e> instantIngestorEvents) {
        service().handleInstantIngestorEvents(instantIngestorEvents);
    }

    /**
     * @description It is used to initiate account, xref and business reference creation.
     * @param payLoadWrapperByIngestionLogUUID
     * @param sourceByUUID
     */
    public static void payloadDistributorForAccountsAndXrefsBizRefs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, String> sourceByUUID
    ) {
        service()
            .payloadDistributorForAccountsAndXrefsBizRefs(
                payLoadWrapperByIngestionLogUUID,
                sourceByUUID
            );
    }

    /**
     * @description It is used to initiate Contact and ACR creation.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @param sourceByUUID
     */
    public static void payloadDistributorForContactsAndACRs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR,
        Map<String, String> sourceByUUID
    ) {
        service()
            .payloadDistributorForContactsAndACRs(
                payLoadWrapperByIngestionLogUUIDForContactAndACR,
                sourceByUUID
            );
    }

    /**
     * @description It is used to initiate the creation of Opportunities by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     * @param sourceByUUID
     * @param inboundIngestionLogByUUID
     */
    public static void payloadDistributorForOpportunities(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
        Map<String, String> sourceByUUID,
        Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID
    ) {
        service()
            .payloadDistributorForOpportunities(
                payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
                sourceByUUID,
                inboundIngestionLogByUUID
            );
    }

    /**
     * @description It is used to initiate the creation of Quote and Quote Lines by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    public static void payloadDistributorForQuotesAndQuoteLines(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    ) {
        service()
            .payloadDistributorForQuotesAndQuoteLines(
                payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
            );
    }

    /**
     * @description This method is used to create an instance of InstantIngestionOnboardingService class.
     * @return IInstantIngestionOnboardingService - return instance of InstantIngestionOnboardingServiceImpl
     */
    private static IInstantIngestionOnboardingService service() {
        return (IInstantIngestionOnboardingService) Application.Service.newInstance(
            IInstantIngestionOnboardingService.class
        );
    }
}