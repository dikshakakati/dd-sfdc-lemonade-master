/**
 * @author Deloitte
 * @date 06/08/2024
 * @description Test class for SSOBIngestionRESTResource class.
 */
@isTest(SeeAllData=false)
private class SSOBIngestionRESTResourceTest {
    private static final String ARRAY_OF_PAYLOAD = '[{"Mx Store Name":"Butter Chicken Corner"},{"Mx Store Name":"Just Taco"}]';
    private static final String NON_ARRAY_PAYLOAD = '{"Mx Store Name":"Yumm"}';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String URL_SSOB_INGESTION_ONBOARDING = '/services/apexrest/ssobingestion/onboarding';
    private static final String URL_SSOB_INGESTION_TEST = '/services/apexrest/ssobingestion/test';
    private static final String TEST_EXCEPTION_PAYLOAD = 'Test_Exception';

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSOB_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSOBIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload in form of array is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingEventIngestedThenPayloadInArrayReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSOB_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSOBIngestionRESTResource.setEventPayload(ARRAY_OF_PAYLOAD);
    }

    /**
     * @description It is used to test when non onboarding event is ingested by mulesoft then onboarding payload is not received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonOnboardingEventIngestedThenOnboardingPayloadNotReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSOB_INGESTION_TEST;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSOBIngestionRESTResource.setEventPayload(ARRAY_OF_PAYLOAD);
    }

    /**
     * @description It is used to test when empty event is ingested by mulesoft then error response is sent.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingEventWithEmptyPayloadIngestedThenErrorResponseReturned() {
        String emptyPayload = '';
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSOB_INGESTION_TEST;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSOBIngestionRESTResource.setEventPayload(emptyPayload);
    }

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then
     * any exception thrown is caught.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingEventFailsThenExceptionThrown() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_SSOB_INGESTION_ONBOARDING;
        request.httpMethod = 'POST';
        RestContext.request = request;
        SSOBIngestionRESTResource.setEventPayload(TEST_EXCEPTION_PAYLOAD);
    }
}