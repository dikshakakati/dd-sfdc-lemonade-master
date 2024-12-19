/**
 * @author Deloitte
 * @date 16/05/2022
 * @description Interface used for dynamically generating service class related to a topic.
 * It needs to be implemented by every service class that requires to consume and
 * process the payload passed to Notifier Platform Event.
 * It allows NotifierEvents handler to dynamically route payload to service class
 * without knowledge of underlying service layer implementation.
 */
public interface IHandleNotifierEvents {
    /**
     * @description It allows NotifierEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param events
     */
    void execute(List<Notifier__e> events);
}