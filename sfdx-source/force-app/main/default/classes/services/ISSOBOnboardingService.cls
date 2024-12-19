/**
 * @author Deloitte
 * @date 07/24/2024
 * @description Interface of service class for SSOBOnboardingService related logic.
 */
public interface ISSOBOnboardingService {
    /**
     * @description It is used to initiate SSOB records creation when instant ingestor event is fired.
     * @param instantIngestorEvents
     */
    void handleSSOBEvents(List<Instant_Ingestor__e> instantIngestorEvents);
}