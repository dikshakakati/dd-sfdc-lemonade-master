/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Interface of service class for Log related logic.
 */
public interface ILogsService {
    /**
     * @description It handles platform events and creates Log records
     * based on the passed payload.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}