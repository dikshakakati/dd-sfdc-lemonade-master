/**
 * @author Deloitte
 * @date 07/02/2024
 * @description Apex REST resource to send Onboarding Details for Activation Tracker.
 */
@RestResource(urlMapping='/onboardingdetails/*')
global with sharing class OnboardingDetailsRESTResource {
    private static final String BACK_SLASH_URL = '/';
    private static final String EXCEPTION_MESSAGE = 'Error while fetching onboarding details based on StoreId';
    private static final Integer FAILURE_STATUS_CODE = 400;
    private static final String HEADER_CONTENT_TYPE = 'Content-Type';
    private static final String HEADER_CONTENT_TYPE_VALUE = 'application/json';
    private static final String LOG_DOMAIN_ACTIVATION_TRACKER_INTEGRATION = 'Activation Tracker Outbound Integration';
    private static final String LOG_SERVICE_ACTIVATION_TRACKER = 'Activation Tracker Onboarding Details';
    /**
     * @description It collects the onboarding details based on the passed Store Id
     * and returns the details for activation tracker.
     * @return String
     */
    @HttpGet
    global static String getOnboadingDetails() {
        RestRequest newRequest = RestContext.request;
        RestResponse newResponse = RestContext.response;
        newResponse.addHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_VALUE);
        String storeId = newRequest.requestURI.substring(
            newRequest.requestURI.lastIndexOf(BACK_SLASH_URL) + 1
        );
        Map<String, String> storeIdToOnboardingDetails = new Map<String, String>();
        try {
            storeIdToOnboardingDetails = OnboardingDetailsService.collectOnboardingDetailsBasedOnStoreIds(
                new Set<String>{ storeId }
            );
        } catch (Exception onboardingdetailsException) {
            Logger.publish(
                LogEntry.newExceptionLog(onboardingdetailsException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_DOMAIN_ACTIVATION_TRACKER_INTEGRATION,
                        LOG_SERVICE_ACTIVATION_TRACKER,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(onboardingdetailsException)
            );
            storeIdToOnboardingDetails.put(
                storeId,
                JSON.serialize(
                    new OnboardingDetailsWrapper.FailureResponseWrapper(
                        EXCEPTION_MESSAGE,
                        false,
                        FAILURE_STATUS_CODE
                    )
                )
            );
        }
        return storeIdToOnboardingDetails.get(storeId);
    }
}