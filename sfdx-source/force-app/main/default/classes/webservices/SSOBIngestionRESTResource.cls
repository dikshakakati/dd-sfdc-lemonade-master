/**
 * @author Deloitte
 * @date 06/08/2024
 * @description Apex REST resource for SSOB event ingestion.
 */
@RestResource(urlMapping='/ssobingestion/*')
global with sharing class SSOBIngestionRESTResource {
    private static final String BLANK_SUBENDPOINT_PAYLOAD_ERROR_MESSAGE = 'Endpoint or Payload can not be null/blank.';
    private static final String INCORRECT_SUBENDPOINT_ERROR_MESSAGE = 'No matching service class found for this endpoint.';
    private static final String INCORRECT_PAYLOAD_ERROR_MESSAGE = 'Payload cannot be parsed.';
    private static final String LOG_DOMAIN_SSOB_INBOUND_INTEGRATION = 'SSOB Inbound Integration';
    private static final String LOG_SERVICE_INGESTION_REST_RESOURCE = 'SSOB Ingestion REST Resource';
    private static final String EVENT_TYPE_SSOB = 'SSOB';
    private static final String EVENT_TYPE_SSOB_ONBOARDING = 'SSOB Onboarding Event';
    @TestVisible
    private static RestResponse customRestResponse;
    private static final String SEPARATOR = '/';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String UUID_NOT_PRESENT = 'UUID not present ';
    private static final String PENDING = 'pending';
    private static final String SSOB_ENDPOINT_ONBOARDING = 'onboarding';
    private enum SSOB_INGESTION_ENDPOINT_VALUES {
        SSOB_ENDPOINT_ONBOARDING
    }
    private static final Map<String, SSOB_INGESTION_ENDPOINT_VALUES> SSOB_INGESTION_ENDPOINT_MAPPINGS = new Map<String, SSOB_INGESTION_ENDPOINT_VALUES>{
        SSOB_ENDPOINT_ONBOARDING => SSOB_INGESTION_ENDPOINT_VALUES.SSOB_ENDPOINT_ONBOARDING
    };

    /**
     * @description It is used to recieve payload for different SSOB events.
     * @param payload
     */
    @HttpPost
    global static void setEventPayload(String payload) {
        String subEndPoint = RestContext.request.requestURI.substringAfterLast(SEPARATOR);
        if (String.isBlank(subEndPoint) || String.isBlank(payload)) {
            setResponseBody(400, false, BLANK_SUBENDPOINT_PAYLOAD_ERROR_MESSAGE);
            return;
        }
        switch on
            SSOB_INGESTION_ENDPOINT_MAPPINGS.get(
                RestContext.request.requestURI.substringAfterLast(SEPARATOR)
            ) {
            //"/ssobingestion/onboarding"
            when SSOB_ENDPOINT_ONBOARDING {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        EVENT_TYPE_SSOB_ONBOARDING,
                        payload,
                        EVENT_TYPE_SSOB
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    Logger.publish(
                        LogEntry.newExceptionLog(
                            recordsInsertException,
                            LogEntry.SeverityLevel.HIGH
                        )
                    );
                    GenericLoggerService.publish(
                        GenericLoggerService.createGenericLog(
                                LOG_SERVICE_INGESTION_REST_RESOURCE,
                                LOG_DOMAIN_SSOB_INBOUND_INTEGRATION,
                                GenericLogEntry.SeverityLevel.HIGH
                            )
                            .logException(recordsInsertException)
                    );
                }
            }
            when else {
                setResponseBody(400, false, INCORRECT_SUBENDPOINT_ERROR_MESSAGE);
            }
        }
    }

    /**
     * @description It is used to send the response message with the status code on received the payload.
     * @param statusCode
     * @param isSuccessful
     * @param message
     */
    private static void setResponseBody(Integer statusCode, Boolean isSuccessful, String message) {
        GenericRESTResourceResponseBody responseBody = new GenericRESTResourceResponseBody();
        responseBody.statusCode = statusCode;
        responseBody.successful = isSuccessful;
        responseBody.message = message;
        if (Test.isrunningtest()) {
            customRestResponse = new RestResponse();
            customRestResponse.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        } else {
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        }
    }
}