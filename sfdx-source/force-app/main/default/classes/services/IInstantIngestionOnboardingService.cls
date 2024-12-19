/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Interface of service class for InstantIngestionOnboardingService related logic.
 */
public interface IInstantIngestionOnboardingService {
    /**
     * @description It is used to initiate InstantIngestion records creation when instant ingestor event is fired.
     * @param instantIngestorEvents
     */
    void handleInstantIngestorEvents(List<Instant_Ingestor__e> instantIngestorEvents);

    /**
     * @description It is used to initiate account, xref and business reference creation.
     * @param payLoadWrapperByIngestionLogUUID
     * @param sourceByUUID
     */
    void payloadDistributorForAccountsAndXrefsBizRefs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, String> sourceByUUID
    );

    /**
     * @description It is used to initiate Contact and ACR creation.
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     * @param sourceByUUID
     */
    void payloadDistributorForContactsAndACRs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR,
        Map<String, String> sourceByUUID
    );

    /**
     * @description This method is responsible for distributing the payload for RESSMO accounts and Xrefs BizRefs.
     *
     * @param payLoadWrapperByIngestionLogUUID The payload to be distributed.
     */
    void payloadDistributorForRESSMOAccountsAndXrefsBizRefs(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description Update the Quote to Contract Signed and Mx Onboarding link to success
     * @author VenkateshDD | 08-05-2024
     * @param payLoadWrapperByIngestionLogUUID
     **/
    void updateQuoteToContractSignedAndMxOnboardingLinkToSuccess(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to initiate the creation of Opportunities by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR
     * @param sourceByUUID
     * @param inboundIngestionLogByUUID
     */
    void payloadDistributorForOpportunities(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForOpportunityAndOCR,
        Map<String, String> sourceByUUID,
        Map<String, Inbound_Ingestion_Log__c> inboundIngestionLogByUUID
    );

    /**
     * @description It is used to initiate the creation of Quote and Quote Lines by the received payload.
     * @param payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
     */
    void payloadDistributorForQuotesAndQuoteLines(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForQuoteAndQuoteLines
    );
}