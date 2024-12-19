/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Service class for Activation Checklist related functionality.
 */
public inherited sharing class ActivationChecklistService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It is used to handle the published Onboarding_Activation__e events.
     * @param onboardingActivationEvents list of platform events with payload
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationEvents);
    }

    /**
     * @description It is used to generate chunked payload for Activation Checklist outbound integration.
     * @JIRA# LEM-13305
     * @param activationChecklistDetails
     */
    public static void generatePayloadAndInitiateOutboundIntegration(
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails
    ) {
        service().generatePayloadAndInitiateOutboundIntegration(activationChecklistDetails);
    }

    /**
     * @description It is used to create an interface instance of the service.
     * @return IActivationChecklistService
     */
    private static IActivationChecklistService service() {
        return (IActivationChecklistService) Application.Service.newInstance(
            IActivationChecklistService.class
        );
    }
}