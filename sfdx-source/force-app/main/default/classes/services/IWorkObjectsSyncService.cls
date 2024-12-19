/**
 * @author Deloitte
 * @date 05/31/2022
 * @description Interface of service class for work objects related logic.
 */
public interface IWorkObjectsSyncService {
    /**
     * @description It is for getting Work object ids from the payload received
     * via Platform Event.
     * @JIRA# LEM-6198
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}