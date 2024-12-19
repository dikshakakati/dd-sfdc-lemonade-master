/**
 * @author Deloitte
 * @date 04/24/2024
 * @description Apex REST resource for SSMO event ingestion.
 */
@RestResource(urlMapping='/ssmoingestion/*')
global with sharing class SSMOIngestionRESTResource {
    private static final String BLANK_SUBENDPOINT_PAYLOAD_ERROR_MESSAGE = 'Endpoint or Payload can not be null/blank.';
    private static final String FALLOUT = 'fallout';
    private static final String INCORRECT_SUBENDPOINT_ERROR_MESSAGE = 'No matching service class found for this endpoint.';
    private static final String INCORRECT_PAYLOAD_ERROR_MESSAGE = 'Payload cannot be parsed.';
    private static final String LOG_DOMAIN_SSMO_INBOUND_INTEGRATION = 'SSMO Inbound Integration';
    private static final String LOG_SERVICE_INGESTION_REST_RESOURCE = 'SSMO Ingestion REST Resource';
    private static final String ONBOARDING = 'onboarding';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String CUSTOM_EXCEPTION_STACK_TRACE = 'IngestionPayloadHandlerServiceImpl.throwcustomValidationException';
    private static final String INVALID_PAYLOAD = 'Invalid Payload';
    private static final String SALESFORCE = 'Salesforce';
    private static final String SELF_SERVING_ONBOARDING_SERVICE_CPQ = 'selfServiceOnboardingService (CPQ)';
    private static final String SELF_SERVING_FALLOUT_SERVICE_SALES = 'selfServiceFalloutService (Sales)';
    private static final String ERROR_STATUS_CODE_400 = '400';
    private static final String COLON_SEPERATOR = ':';

    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String ONBOARDING_SOURCE = 'onboardingSource';
    private static final String JSON_NON_ARRAY_IDENTIFIER = '{';
    private static final String JSON_ARRAY_IDENTIFIER = '[';

    @TestVisible
    private static RestResponse customRestResponse;
    private static final String SEPARATOR = '/';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String UUID_NOT_PRESENT = 'UUID not present ';
    private static final String FALLOUTEVENT = 'Fallout event';
    private static final String PENDING = 'pending';
    private static final String SOURCE_SSMO = 'SSMO';
    private static boolean invalidPayload = false;
    private enum SSMO_INGESTION_ENDPOINT_VALUES {
        FALLOUT,
        ONBOARDING
    }
    private static final Map<String, SSMO_INGESTION_ENDPOINT_VALUES> SSMO_INGESTION_ENDPOINT_MAPPINGS = new Map<String, SSMO_INGESTION_ENDPOINT_VALUES>{
        FALLOUT => SSMO_INGESTION_ENDPOINT_VALUES.FALLOUT,
        ONBOARDING => SSMO_INGESTION_ENDPOINT_VALUES.ONBOARDING
    };

    /**
     * @description It is used to recieve payload for different SSMO events.
     * @param payload
     */
    @HttpPost
    global static void setEventPayload(String payload) {
        String subEndPoint = RestContext.request.requestURI.substringAfterLast(SEPARATOR);
        Request reqInfo = Request.getCurrent();
        String currentRequestId = reqInfo.getRequestId();
        if (String.isBlank(subEndPoint) || String.isBlank(payload)) {
            setResponseBody(400, false, BLANK_SUBENDPOINT_PAYLOAD_ERROR_MESSAGE);
            return;
        }
        switch on
            SSMO_INGESTION_ENDPOINT_MAPPINGS.get(
                RestContext.request.requestURI.substringAfterLast(SEPARATOR)
            ) {
            //"/ssmoingestion/fallout"
            when FALLOUT {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        FALLOUTEVENT,
                        payload,
                        SOURCE_SSMO
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    handleCustomValidationException(
                        currentRequestId,
                        FALLOUTEVENT,
                        recordsInsertException.getMessage(),
                        recordsInsertException.getStackTraceString()
                    );
                    GenericLoggerService.publish(
                        GenericLoggerService.createGenericLog(
                                LOG_SERVICE_INGESTION_REST_RESOURCE,
                                LOG_DOMAIN_SSMO_INBOUND_INTEGRATION,
                                GenericLogEntry.SeverityLevel.HIGH
                            )
                            .logException(recordsInsertException)
                    );
                }
            }
            //"/ssmoingestion/onboarding"
            when ONBOARDING {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        ONBOARDING_EVENT,
                        payload,
                        getSourceForOnboardingPayload(payload)
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    handleCustomValidationException(
                        currentRequestId,
                        ONBOARDING_EVENT,
                        recordsInsertException.getMessage(),
                        recordsInsertException.getStackTraceString()
                    );
                    GenericLoggerService.publish(
                        GenericLoggerService.createGenericLog(
                                LOG_SERVICE_INGESTION_REST_RESOURCE,
                                LOG_DOMAIN_SSMO_INBOUND_INTEGRATION,
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
     * @description It is used to handle the custom validation exception received from the payload.
     * @param currentRequestId
     * @param eventType
     * @param exceptionMessage
     * @param exceptionStackTrace
     */
    private static void handleCustomValidationException(
        String currentRequestId,
        String eventType,
        String exceptionMessage,
        String exceptionStackTrace
    ) {
        if (exceptionStackTrace.contains(CUSTOM_EXCEPTION_STACK_TRACE)) {
            String source = eventType == ONBOARDING_EVENT
                ? SELF_SERVING_ONBOARDING_SERVICE_CPQ
                : SELF_SERVING_FALLOUT_SERVICE_SALES;
            setResponseBody(400, false, String.valueof(exceptionMessage.split(COLON_SEPERATOR)[1]));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        source,
                        SALESFORCE,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .setCategory(INVALID_PAYLOAD)
                    .setRequestId(currentRequestId)
                    .setUUId(exceptionMessage.split(COLON_SEPERATOR)[0])
                    .setStatusCode(ERROR_STATUS_CODE_400)
                    .logMessage(exceptionMessage.split(COLON_SEPERATOR)[1])
            );
        } else {
            setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
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

    /**
    * @description @Onboarding Source either RESSMO or SSMO
    * @author VenkateshDD | 08-08-2024
    * @param payload
    * @return String
    **/
    private static String getSourceForOnboardingPayload(String payload){
        String source = SOURCE_SSMO;
        if (payload.startsWith(JSON_NON_ARRAY_IDENTIFIER)){
            Map<String, Object> jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(payload);
            source = jsonKeyToValue.get(ONBOARDING_SOURCE) != null && jsonKeyToValue.get(ONBOARDING_SOURCE).equals(SOURCE_RESSMO)
                ? SOURCE_RESSMO : SOURCE_SSMO;
        }
        else if(payload.startsWith(JSON_ARRAY_IDENTIFIER)){
            List<Object> payloadList = (List<Object>) JSON.deserializeUntyped(
                            payload
                        );
            Map<String, Object> jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(payloadList[0]));
            source = jsonKeyToValue.get(ONBOARDING_SOURCE) != null && jsonKeyToValue.get(ONBOARDING_SOURCE).equals(SOURCE_RESSMO)
                ? SOURCE_RESSMO : SOURCE_SSMO;
        }
        return source;
    }
}