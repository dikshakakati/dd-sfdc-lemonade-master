/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Apex REST resource for Mx Portal Amendment ingestion
 */
@RestResource(urlMapping='/mx/amend/*')
global with sharing class MxPortalIngestionRESTResource {
    private static final String BLANK_SUBENDPOINT_PAYLOAD_ERROR_MESSAGE = 'Endpoint or Payload can not be null/blank.';
    private static final String INCORRECT_SUBENDPOINT_ERROR_MESSAGE = 'No matching service class found for this endpoint.';
    private static final String INCORRECT_PAYLOAD_ERROR_MESSAGE = 'Payload cannot be parsed.';
    private static final String LOG_DOMAIN_SSOB_INBOUND_INTEGRATION = 'SSOB Inbound Integration';
    private static final String LOG_SERVICE_INGESTION_REST_RESOURCE = 'SSOB Ingestion REST Resource';
    private static final String EVENT_SOURCE_MX_PORTAL = 'Mx Portal';
    @TestVisible
    private static RestResponse customRestResponse;
    private static final String SEPARATOR = '/';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String UUID_NOT_PRESENT = 'UUID not present ';
    private static final String PENDING = 'pending';
    private static final String MXP_EVENT_TYPE_STOREFRONT = 'Mx Portal Add Storefront';
    private static final String MXP_EVENT_TYPE_PACKAGE_SWITCH = 'Mx Portal Package Switch';
    private static final String MXP_EVENT_TYPE_ADS_AND_PROMOS = 'Mx Portal Ads And Promos';
    private static final String MX_PORTAL_ENDPOINT_STOREFRONT = 'storefront';
    private static final String MX_PORTAL_ENDPOINT_PACKAGE_SWITCH = 'packageswitch';
    private static final String MX_PORTAL_ENDPOINT_SPONSORED_LISTINGS = 'sponsoredlistings';
    private static final String MX_PORTAL_ENDPOINT_LOYALTY = 'loyalty';
    private static final String MX_PORTAL_ENDPOINT_ALCOHOL = 'alcohol';
    private static final String MX_PORTAL_ENDPOINT_PROMOTIONS = 'promotions';
    private enum MX_PORTAL_INGESTION_ENDPOINT_VALUES {
        MX_PORTAL_ENDPOINT_STOREFRONT,
        MX_PORTAL_ENDPOINT_PACKAGE_SWITCH,
        MX_PORTAL_ENDPOINT_SPONSORED_LISTINGS,
        MX_PORTAL_ENDPOINT_LOYALTY,
        MX_PORTAL_ENDPOINT_ALCOHOL,
        MX_PORTAL_ENDPOINT_PROMOTIONS
    }
    private static final Map<String, MX_PORTAL_INGESTION_ENDPOINT_VALUES> MX_PORTAL_INGESTION_ENDPOINT_MAPPINGS = new Map<String, MX_PORTAL_INGESTION_ENDPOINT_VALUES>{
        MX_PORTAL_ENDPOINT_STOREFRONT => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_STOREFRONT,
        MX_PORTAL_ENDPOINT_PACKAGE_SWITCH => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_PACKAGE_SWITCH,
        MX_PORTAL_ENDPOINT_SPONSORED_LISTINGS => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_SPONSORED_LISTINGS,
        MX_PORTAL_ENDPOINT_LOYALTY => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_LOYALTY,
        MX_PORTAL_ENDPOINT_ALCOHOL => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_ALCOHOL,
        MX_PORTAL_ENDPOINT_PROMOTIONS => MX_PORTAL_INGESTION_ENDPOINT_VALUES.MX_PORTAL_ENDPOINT_PROMOTIONS
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
            MX_PORTAL_INGESTION_ENDPOINT_MAPPINGS.get(
                RestContext.request.requestURI.substringAfterLast(SEPARATOR)
            ) {
            //"mx/amend/storefront"
            when MX_PORTAL_ENDPOINT_STOREFRONT {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        MXP_EVENT_TYPE_STOREFRONT,
                        payload,
                        EVENT_SOURCE_MX_PORTAL
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    catchAndPublishExceptions(recordsInsertException);
                }
            }
            //"mx/amend/packageswitch"
            when MX_PORTAL_ENDPOINT_PACKAGE_SWITCH {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        MXP_EVENT_TYPE_PACKAGE_SWITCH,
                        payload,
                        EVENT_SOURCE_MX_PORTAL
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    catchAndPublishExceptions(recordsInsertException);
                }
            }
            //"mx/amend/sponsoredlistings"
            when MX_PORTAL_ENDPOINT_SPONSORED_LISTINGS {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        MXP_EVENT_TYPE_ADS_AND_PROMOS,
                        payload,
                        EVENT_SOURCE_MX_PORTAL
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    catchAndPublishExceptions(recordsInsertException);
                }
            }
            //"mx/amend/loyalty"
            when MX_PORTAL_ENDPOINT_LOYALTY {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        MXP_EVENT_TYPE_ADS_AND_PROMOS,
                        payload,
                        EVENT_SOURCE_MX_PORTAL
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    catchAndPublishExceptions(recordsInsertException);
                }
            }
            //"mx/amend/promotions"
            when MX_PORTAL_ENDPOINT_PROMOTIONS {
                try {
                    IngestionPayloadHandlerService.insertInboundIngestionLogs(
                        MXP_EVENT_TYPE_ADS_AND_PROMOS,
                        payload,
                        EVENT_SOURCE_MX_PORTAL
                    );
                    setResponseBody(200, true, SUCCESS_MESSAGE);
                } catch (Exception recordsInsertException) {
                    setResponseBody(400, false, INCORRECT_PAYLOAD_ERROR_MESSAGE);
                    catchAndPublishExceptions(recordsInsertException);
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

    /**
     * @description It is used to catch and insert the exceptions
     * @param recordsInsertException
     */
    private static void catchAndPublishExceptions(Exception recordsInsertException) {
        Logger.publish(
            LogEntry.newExceptionLog(recordsInsertException, LogEntry.SeverityLevel.HIGH)
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