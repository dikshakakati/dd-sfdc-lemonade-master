/**
 * @author Deloitte
 * @date 05/10/2024
 * @description Service class for Store Association.
 */
public inherited sharing class StoreAssociationService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It allows NotifierEvents handler to pass events to the service class
     * corresponding to event topic.
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description calling newInstance for service class.
     * @return IStoreAssociationService - returning interface.
     */
    private static IStoreAssociationService service() {
        return (IStoreAssociationService) Application.SERVICE.newInstance(
            IStoreAssociationService.class
        );
    }
}