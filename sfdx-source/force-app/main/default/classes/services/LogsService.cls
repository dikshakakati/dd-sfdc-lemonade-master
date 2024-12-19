/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Service class for Log related logic.
 */
public inherited sharing class LogsService implements IHandleNotifierEvents {
    /**
     * @description It handles platform events and creates Log records
     * based on the passed payloads.
     * @JIRA# LEM-10033, LEM-10035
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description It creates instance of LogsServiceImpl class.
     * @return ILogsService
     */
    private static ILogsService service() {
        return (ILogsService) Application.SERVICE.newInstance(ILogsService.class);
    }
}