/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class for IngestionPayloadHandlerServiceImpl.
 *
 */
public inherited sharing class IngestionPayloadHandlerService {
    /**
     * @description It is used to insert 'Inbound Ingestion Log' record with the JSON payload data
     * into the 'Payload' field.
     * @param eventType
     * @param payload
     * @param source
     */
    public static void insertInboundIngestionLogs(String eventType, String payload, String source) {
        service().insertInboundIngestionLogs(eventType, payload, source);
    }

    /**
     * @description It is used to create an instance of IngestionPayloadHandlerServiceImpl class.
     * @return IngestionPayloadHandlerService - return instance of IngestionPayloadHandlerServiceImpl
     */
    private static IIngestionPayloadHandlerService service() {
        return (IIngestionPayloadHandlerService) Application.Service.newInstance(
            IIngestionPayloadHandlerService.class
        );
    }
}