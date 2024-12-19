/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Service class for processing Fraud Events.
 */
public inherited sharing class FraudEventsService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It is used to handle the published Onboarding_Activation__e events.
     * @param onboardingActivationEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationEvents);
    }

    /**
     * @description It is used to create an interface instance of the service.
     * @return IFraudEventsService
     */
    private static IFraudEventsService service() {
        return (IFraudEventsService) Application.Service.newInstance(IFraudEventsService.class);
    }
}