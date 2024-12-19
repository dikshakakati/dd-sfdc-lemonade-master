/**
 * @author Deloitte
 * @date 05/12/2024
 * @description Interface used for dynamically generating service class related to a topic.
 * It needs to be implemented by every service class that requires to consume and
 * process the payload passed to Notifier Platform Event.
 * It allows NonInstantIngesterEvents handler to dynamically route payload to service class
 * without knowledge of underlying service layer implementation.
 */
public interface IHandleNonInstantIngestionEvents {
    /**
     * @description It allows NonInstantIngesterEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param events
     */
    void execute(List<Non_Instant_Ingestor__e> events);
}