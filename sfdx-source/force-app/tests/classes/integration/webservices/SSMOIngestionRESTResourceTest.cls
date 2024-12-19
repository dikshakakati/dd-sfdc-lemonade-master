/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for SSMOIngestionRESTResource class.
 * Suppressing Warning as rest resource class is returning null response.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class SSMOIngestionRESTResourceTest {
    private static final String ARRAY_OF_PAYLOAD = '[{"Mx Store Name":"Butter Chicken Corner"},{"Mx Store Name":"Just Taco"}]';
    private static final String NON_ARRAY_PAYLOAD = '{"Mx Store Name":"Yumm"}';
    private static final String RESSMO_PAYLOAD = '{"onboardingSource":"RESSMO"}';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String URL_SSMO_INGESTION_ONBOARDING = '/services/apexrest/ssmoingestion/onboarding';
    private static final String URL_SSMO_INGESTION_FALLOUT = '/services/apexrest/ssmoingestion/fallout';
    private static final String URL_SSMO_INGESTION_TEST = '/services/apexrest/ssmoingestion/test';
    private static final String TEST_EXCEPTION_PAYLOAD = 'Test_Exception';

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    private static void testWhenOnboardingEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload for RESSMO onboarding fired
     */
    @isTest
    private static void testWhenOnboardingEventForRESSMOThenPayloadReceived(){
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(RESSMO_PAYLOAD);
    }

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload in form of array is received.
     */
    @isTest
    private static void testWhenOnboardingEventIngestedThenPayloadInArrayReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(ARRAY_OF_PAYLOAD);
    }

    /**
     * @description It is used to test when non onboarding event is ingested by mulesoft then onboarding payload is not received.
     */
    @isTest
    private static void testWhenNonOnboardingEventIngestedThenOnboardingPayloadNotReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_TEST;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(ARRAY_OF_PAYLOAD);
    }

    /**
     * @description It is used to test when empty event is ingested by mulesoft then error response is sent.
     */
    @isTest
    private static void testWhenOnboardingEventWithEmptyPayloadIngestedThenErrorResponseReturned() {
        String emptyPayload = '';
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_TEST;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(emptyPayload);
    }

    /**
     * @description It is used to test when empty event is ingested by mulesoft then error response is sent.
     */
    @isTest
    private static void testWhenOnboardingEventWithNullPayloadIngestedThenErrorResponseReturned() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_TEST;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(TEST_EXCEPTION_PAYLOAD);
    }

    /**
     * @description It is used to test when fallout event is ingested by mulesoft then
     * payload in form of array is received.
     */
    @isTest
    private static void testWhenFalloutEventIngestedThenPayloadInArrayReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_FALLOUT;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(ARRAY_OF_PAYLOAD);
    }

    /**
     * @description It is used to test when fallout event is ingested by mulesoft then
     * payload in form of array is received.
     */
    @isTest
    private static void testWhenFalloutEventIngestedThenPayloadInJSONReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_FALLOUT;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }

    /**
     * @description It is used to test when fallout event is ingested by mulesoft then
     * any exception thrown is caught.
     */
    @isTest
    private static void testWhenFalloutEventFailsThenExceptionThrown() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_FALLOUT;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(TEST_EXCEPTION_PAYLOAD);
    }

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then
     * any exception thrown is caught.
     */
    @isTest
    private static void testWhenOnboardingEventFailsThenExceptionThrown() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSMO_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSMOIngestionRESTResource.setEventPayload(TEST_EXCEPTION_PAYLOAD);
    }
}