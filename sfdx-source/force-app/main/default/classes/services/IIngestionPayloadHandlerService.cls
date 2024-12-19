/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for IngestionPayloadHandlerService.
 */
public interface IIngestionPayloadHandlerService {
    /**
     * @description It is used to insert 'Inbound Ingestion Log' record with the JSON payload data
     * into the 'Payload' field.
     * @param eventType
     * @param payload
     * @param source
     */
    void insertInboundIngestionLogs(String eventType, String payload, String source);
}