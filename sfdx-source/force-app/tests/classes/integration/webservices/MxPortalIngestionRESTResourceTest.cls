/**
 * @author Deloitte
 * @date 11/10/2024
 * @description Test class for MxPortalIngestionRESTResource class.
 */
@isTest(SeeAllData=false)
private class MxPortalIngestionRESTResourceTest {
    private static final String ARRAY_OF_PAYLOAD = '[{"Mx Store Name":"Butter Chicken Corner"},{"Mx Store Name":"Just Taco"}]';
    private static final String NON_ARRAY_PAYLOAD = '{"Mx Store Name":"Yumm"}';
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String URL_MX_INGESTION_ONBOARDING = '/services/apexrest/mx/amend/';
    private static final String URL_MX_INGESTION_TEST = '/services/apexrest/mx/amend/test';
    private static final String TEST_EXCEPTION_PAYLOAD = 'Test_Exception';
    private static final String STOREFRONT = 'storefront';
    private static final String PACKAGE_SWITCH = 'packageswitch';
    private static final String SPONSORED_LISTINGS = 'sponsoredlistings';
    private static final String LOYALITY = 'loyalty';
    private static final String PROMOTIONS = 'promotions';

    /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMXStoreFrontEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_MX_INGESTION_ONBOARDING+STOREFRONT;
        request.httpMethod = 'POST';
        RestContext.request = request;
        MxPortalIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }
  /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMXPackageSwitchEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_MX_INGESTION_ONBOARDING+PACKAGE_SWITCH;
        request.httpMethod = 'POST';
        RestContext.request = request;
        MxPortalIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }  /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxSponsoredListingEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_MX_INGESTION_ONBOARDING+SPONSORED_LISTINGS;
        request.httpMethod = 'POST';
        RestContext.request = request;
        MxPortalIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }  /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMXLoyalityEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_MX_INGESTION_ONBOARDING+LOYALITY;
        request.httpMethod = 'POST';
        RestContext.request = request;
        MxPortalIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }  /**
     * @description It is used to test when onboarding event is ingested by mulesoft then payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMXPromotionsEventIngestedThenPayloadReceived() {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getOrgDomainURL().toExternalForm() + URL_MX_INGESTION_ONBOARDING+PROMOTIONS;
        request.httpMethod = 'POST';
        RestContext.request = request;
        MxPortalIngestionRESTResource.setEventPayload(NON_ARRAY_PAYLOAD);
    }
    
}