/**
 * @author Deloitte
 * @date 07/04/2024
 * @description Test class for OnboardingDetailsRESTResource class.
 */
@isTest(SeeAllData=false)
private class OnboardingDetailsRESTResourceTest {
    private static final String HEADER_CONTENT_TYPE = 'Content-Type';
    private static final String HEADER_CONTENT_TYPE_VALUE = 'application/json';
    private static final String HTTP_METHOD = 'GET';
    private static final String HTTP_REQUEST_BODY = '{}';
    private static final String MOCK_PAYLOAD = 'Mock Payload';
    private static final String MOCK_REQUEST_URI = 'https://test/OnboardingDetailsRESTResourceTest/1615955';
    private static final String MOCK_STORE_ID = '1615955';
    private static final String PAYLOAD_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Payload does not match.';
    private static final String RETURN_EXCEPTION_MESSAGE = 'Error while fetching onboarding details based on StoreId';
    private static final String RUNTIME_EXCEPTION_MESSAGE = 'Exception occurred during run time';

    /**
     * @description To test onboarding details payload is generated and returned
     * when Store Id is received.
     */
    @isTest
    private static void testWhenStoreIdReceivedThenGenerateAndReturnOnboardingDetailsPayload() {
        RestRequest newRequest = new RestRequest();
        RestResponse newResponse = new RestResponse();
        newRequest.requestURI = MOCK_REQUEST_URI;
        newRequest.addHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_VALUE);
        newRequest.httpMethod = HTTP_METHOD;
        newRequest.requestBody = Blob.valueof(HTTP_REQUEST_BODY);
        RestContext.request = newRequest;
        RestContext.response = newResponse;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOnboardingDetailsService onboardingDetailsSrvcMock = (IOnboardingDetailsService) mocks.mock(
            IOnboardingDetailsService.class
        );
        mocks.startStubbing();
        mocks.when(
                onboardingDetailsSrvcMock.collectOnboardingDetailsBasedOnStoreIds(
                    new Set<String>{ MOCK_STORE_ID }
                )
            )
            .thenReturn(new Map<String, String>{ MOCK_STORE_ID => MOCK_PAYLOAD });
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOnboardingDetailsService.class, onboardingDetailsSrvcMock);
        Test.startTest();
        String resultResponse = OnboardingDetailsRESTResource.getOnboadingDetails();
        Test.stopTest();
        System.assertEquals(MOCK_PAYLOAD, resultResponse, PAYLOAD_DOES_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test failure response is sent when exception occurs
     * while fetching onboarding details.
     */
    @isTest
    private static void testWhenExceptionOccursThenReturnFailureResponse() {
        RestRequest newRequest = new RestRequest();
        RestResponse newResponse = new RestResponse();
        newRequest.requestURI = MOCK_REQUEST_URI;
        newRequest.addHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_VALUE);
        newRequest.httpMethod = HTTP_METHOD;
        newRequest.requestBody = Blob.valueof(HTTP_REQUEST_BODY);
        RestContext.request = newRequest;
        RestContext.response = newResponse;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOnboardingDetailsService onboardingDetailsSrvcMock = (IOnboardingDetailsService) mocks.mock(
            IOnboardingDetailsService.class
        );
        mocks.startStubbing();
        ((IOnboardingDetailsService) mocks.doThrowWhen(
                new TestCommitException(RUNTIME_EXCEPTION_MESSAGE),
                onboardingDetailsSrvcMock
            ))
            .collectOnboardingDetailsBasedOnStoreIds(new Set<String>{ MOCK_STORE_ID });
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOnboardingDetailsService.class, onboardingDetailsSrvcMock);
        Test.startTest();
        String resultResponse = OnboardingDetailsRESTResource.getOnboadingDetails();
        Test.stopTest();
        System.assertEquals(
            true,
            resultResponse.contains(RETURN_EXCEPTION_MESSAGE),
            PAYLOAD_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}