/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Service Interface for Store Association.
 */
public interface IStoreAssociationService {
    /**
     * @description It is used to handle and route the published Onboarding Activations Events.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );
}