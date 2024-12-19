/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Service Interface for Activation Checklist related functionality.
 */
public interface IActivationChecklistService {
    /**
     * @description This method is used to handle the published onboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It is used to generate chunked payload for Activation Checklist outbound integration.
     * @param activationChecklistDetails
     */
    void generatePayloadAndInitiateOutboundIntegration(
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails
    );
}