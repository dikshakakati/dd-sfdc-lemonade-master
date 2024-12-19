/**
 * @author Deloitte
 * @date 26/06/2024
 * @description Service class for Mx Onboarding Link related logic.
 */
public inherited sharing class MxOnboardingLinksService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It allows OnboardingEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description calling new Instance for Service class.
     * @return IMxOnboardingLinksService - returning interface.
     */
    private static IMxOnboardingLinksService service() {
        return (IMxOnboardingLinksService) Application.SERVICE.newInstance(
            IMxOnboardingLinksService.class
        );
    }
}