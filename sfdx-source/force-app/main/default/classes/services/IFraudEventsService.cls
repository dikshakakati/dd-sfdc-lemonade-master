/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Service Interface for processing Fraud Events.
 */
public interface IFraudEventsService {
    /**
     * @description It is used to handle the published onboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );
}