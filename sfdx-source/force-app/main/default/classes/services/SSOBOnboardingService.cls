/**
 * @author Deloitte
 * @date 07/24/2024
 * @description Service class to create SSOB related records by JSON payload.
 *
 */
public inherited sharing class SSOBOnboardingService implements IHandleInstantIngestorEvents {
    /**
     * @description This method is used to handle the published Instant Ingestor events.
     * @param instantIngestorEvents list of platform events with payload
     */
    public static void execute(List<Instant_Ingestor__e> instantIngestorEvents) {
        service().handleSSOBEvents(instantIngestorEvents);
    }

    /**
     * @description This method is used to create an instance of SSOBOnboardingService class.
     * @return IISSOBOnboardingService - return instance of InstantIngestionOnboardingServiceImpl
     */
    private static ISSOBOnboardingService service() {
        return (ISSOBOnboardingService) Application.Service.newInstance(
            ISSOBOnboardingService.class
        );
    }
}