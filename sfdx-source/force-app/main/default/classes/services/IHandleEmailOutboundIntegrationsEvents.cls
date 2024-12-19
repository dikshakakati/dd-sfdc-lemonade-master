/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Interface used for dynamically generating service class related to a topic.
 * It needs to be implemented by every service class that requires to consume and
 * process the payload passed to Email Outbound Integrations Platform Event.
 * It allows Email Outbound Integrations handler to dynamically route payload to service class
 * without knowledge of underlying service layer implementation.
 */
public interface IHandleEmailOutboundIntegrationsEvents {
    /**
     * @description It allows Email Outbound Integrations handler to pass events to the service class
     * corresponding to a topic.
     * @param events
     */
    void execute(List<Email_Outbound_Integration__e> events);
}