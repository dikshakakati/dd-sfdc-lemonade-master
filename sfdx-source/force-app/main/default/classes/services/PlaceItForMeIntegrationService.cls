/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Service class for "Place It For Me" inbound integration related logic.
 */
public inherited sharing class PlaceItForMeIntegrationService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It is used to handle the payload received via Platform Event.
     * @JIRA# LEM-15585
     * @param events
     */
    public static void execute(List<Onboarding_Activation__e> events) {
        service().handleOnboardingActivationsEvents(events);
    }

    /**
     * @description  It is used to update the Work Plan Notes based on payload and assign Work Plans
     * to 'Storefront - Mx Escalation' queue.
     * @JIRA# LEM-15585
     * @param placeItForMeStorefrontWPs
     */
    public static void updatePlaceItForMeStorefrontWorkPlans(
        List<WorkPlan> placeItForMeStorefrontWPs
    ) {
        service().updatePlaceItForMeStorefrontWorkPlans(placeItForMeStorefrontWPs);
    }

    /**
     * @description It creates instance of PlaceItForMeIntegrationServiceImpl class.
     * @return IPlaceItForMeIntegrationService - return instance of PlaceItForMeIntegrationServiceImpl
     */
    private static IPlaceItForMeIntegrationService service() {
        return (IPlaceItForMeIntegrationService) Application.Service.newInstance(
            IPlaceItForMeIntegrationService.class
        );
    }
}