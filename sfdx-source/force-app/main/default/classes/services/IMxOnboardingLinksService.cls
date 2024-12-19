/**
 * @author Deloitte
 * @date 26/06/2024
 * @description Service Interface for Mx Onboarding Link related logic.
 */
public interface IMxOnboardingLinksService {
    /**
     * @description It is used to handle and route the published
     * OnboardingActivationsEvents.
     * @param onboardingActivationsEvents
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );
}