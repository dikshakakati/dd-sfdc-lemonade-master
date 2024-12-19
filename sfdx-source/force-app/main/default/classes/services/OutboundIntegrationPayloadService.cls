/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service class for outbound integration payloads related logic.
 */
public inherited sharing class OutboundIntegrationPayloadService {
    /**
     * @description It is used to collect related record Ids from Activation Checklist payload.
     * @JIRA# LEM-13305
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public static Map<String, Set<String>> collectRecordIdsFromActivationChecklistPayload(
        List<String> outboundPayloads
    ) {
        return service().collectRecordIdsFromActivationChecklistPayload(outboundPayloads);
    }

    /**
     * @description It is used to collect related record Ids from Email payload.
     * @JIRA# LEM-13778
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public static Map<String, Set<String>> collectRecordIdsFromEmailPayload(
        List<String> outboundPayloads
    ) {
        return service().collectRecordIdsFromEmailPayload(outboundPayloads);
    }

    /**
     * @description It is used to collect related record Ids from Mx Fraud Documents payloads.
     * @JIRA# LEM-15836
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    public static Map<String, Set<String>> collectRecordIdsFromMxFraudPayload(
        List<String> outboundPayloads
    ) {
        return service().collectRecordIdsFromMxFraudPayload(outboundPayloads);
    }

    /**
     * @description It is used to collect related record Ids from Mx Order payload.
     * @JIRA# LEM-13506
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    public static Map<String, Set<String>> collectRecordIdsFromMxOrderPayload(
        List<String> outboundPayloads
    ) {
        return service().collectRecordIdsFromMxOrderPayload(outboundPayloads);
    }

    /**
     * @description It is used to collect related record Ids from photoshoot Mx Order payload.
     * @JIRA# LEM-13499
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    public static Map<String, Set<String>> collectRecordIdsFromPhotoshootMxOrderPayload(
        List<String> outboundPayloads
    ) {
        return service().collectRecordIdsFromPhotoshootMxOrderPayload(outboundPayloads);
    }

    /**
     * @description It generates chunked payloads for Email integration based on
     * passed Interface Transactions and configured chunk size.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsForEmailIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        return service().generateChunkedPayloadsForEmailIntegration(interfaceTransactions);
    }

    /**
     * @description It generates chunked payloads for Mx Fraud Document integration based on
     * passed Interface Transactions and configured chunk size.
     * @JIRA# LEM-15836
     * @param interfaceTransactions
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsForMxFraudDocumentsIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        return service()
            .generateChunkedPayloadsForMxFraudDocumentsIntegration(interfaceTransactions);
    }

    /**
     * @description It generates chunked payloads for passed Interface Transactions
     * based on configured chunk size.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsForMxOrderIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        return service().generateChunkedPayloadsForMxOrderIntegration(interfaceTransactions);
    }

    /**
     * @description It generates chunked payloads for passed Interface Transactions based on
     * configured chunk size for Photoshoot orders.
     * @JIRA# LEM-13499
     * @param interfaceTransactions
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsForMxOrderPhotoshootIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        return service()
            .generateChunkedPayloadsForMxOrderPhotoshootIntegration(interfaceTransactions);
    }

    /**
     * @description - Returns an instance of IOutboundIntegrationPayloadService.
     * @JIRA# LEM-13506
     * @return IOutboundIntegrationPayloadService
     */
    private static IOutboundIntegrationPayloadService service() {
        return (IOutboundIntegrationPayloadService) Application.SERVICE.newInstance(
            IOutboundIntegrationPayloadService.class
        );
    }
}