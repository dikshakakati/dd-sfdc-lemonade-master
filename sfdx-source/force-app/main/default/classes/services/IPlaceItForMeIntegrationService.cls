/**
 * @author Deloitte
 * @date 07/07/2024
 * @description Interface of service class for "Place It For Me" inbound integration related logic.
 */
public interface IPlaceItForMeIntegrationService {
    /**
     * @description It is used to handle the payload received via Platform Event.
     * @param events
     */
    void handleOnboardingActivationsEvents(List<Onboarding_Activation__e> events);

    /**
     * @description  It is used to update the Work Plan Notes based on payload and assign Work Plans
     * to 'Storefront - Mx Escalation' queue.
     * @param placeItForMeStorefrontWPs
     */
    void updatePlaceItForMeStorefrontWorkPlans(List<WorkPlan> placeItForMeStorefrontWPs);
}