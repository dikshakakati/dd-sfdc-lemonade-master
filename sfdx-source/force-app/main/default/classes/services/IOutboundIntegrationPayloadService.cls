/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Interface of service class for outbound integration payloads related logic.
 */
public interface IOutboundIntegrationPayloadService {
    /**
     * @description It is used to collect related record Ids from Activation Checklist payload.
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    Map<String, Set<String>> collectRecordIdsFromActivationChecklistPayload(
        List<String> outboundPayloads
    );

    /**
     * @description It is used to collect related record Ids from Email payload.
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    Map<String, Set<String>> collectRecordIdsFromEmailPayload(List<String> outboundPayloads);

    /**
     * @description It is used to collect related record Ids from Mx Fraud Documents payloads.
     * @param outboundPayloads
     * @return Map<String, Set<Id>>
     */
    Map<String, Set<String>> collectRecordIdsFromMxFraudPayload(List<String> outboundPayloads);

    /**
     * @description It is used to collect related record Ids from Mx Order payload.
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    Map<String, Set<String>> collectRecordIdsFromMxOrderPayload(List<String> outboundPayloads);

    /**
     * @description It is used to collect related record Ids from photoshoot Mx Order payload.
     * @param outboundPayloads
     * @return Map<String, Set<String>>
     */
    Map<String, Set<String>> collectRecordIdsFromPhotoshootMxOrderPayload(
        List<String> outboundPayloads
    );

    /**
     * @description It generates chunked payloads for Email integration based on
     * passed Interface Transactions and configured chunk size.
     * @param interfaceTransactions
     * @return List<String>
     */
    List<String> generateChunkedPayloadsForEmailIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    );

    /**
     * @description It generates chunked payloads for Mx Fraud Document integration based on
     * passed Interface Transactions and configured chunk size.
     * @param interfaceTransactions
     * @return List<String>
     */
    List<String> generateChunkedPayloadsForMxFraudDocumentsIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    );

    /**
     * @description It generates chunked payloads for passed Interface Transactions
     * based on configured chunk size.
     * @param interfaceTransactions
     * @return List<String>
     */
    List<String> generateChunkedPayloadsForMxOrderIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    );

    /**
     * @description It generates chunked payloads for passed Interface Transactions
     * based on configured chunk size.
     * @param interfaceTransactions
     * @return List<String>
     */
    List<String> generateChunkedPayloadsForMxOrderPhotoshootIntegration(
        List<Interface_Transaction__c> interfaceTransactions
    );
}