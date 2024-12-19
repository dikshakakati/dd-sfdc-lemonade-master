/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Interface of service class for SSMOOnboardingService related logic.
 */
public interface ISSMOOnboardingService {
    /**
     * @description This method is used to initiate SSMO records creation when instant ingestor event is fired.
     * @param instantIngestorEvents
     */
    void handleInstantIngestorEvents(List<Instant_Ingestor__e> instantIngestorEvents);
}