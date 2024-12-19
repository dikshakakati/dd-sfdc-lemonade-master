/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Interface used for dynamically generating service class related to a topic.
 * It needs to be implemented by every service class that requires to consume and
 * process the payload passed to Onboaridng & Activations Platform Event.
 * It allows Onboarding & Activations handler to dynamically route payload to service class
 * without knowledge of underlying service layer implementation.
 */
public interface IHandleOnboardingActivationsEvents {
    /**
     * @description It allows NotifierEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param events
     */
    void execute(List<Onboarding_Activation__e> events);
}