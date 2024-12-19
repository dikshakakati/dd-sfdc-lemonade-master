/**
 * @author Deloitte
 * @date 05/31/2023
 * @description Service class for Work Objects related logic.
 */
public inherited sharing class WorkObjectsSyncService implements IHandleNotifierEvents {
    /**
     * @description This method is used to handle the published Notifier events.
     * @JIRA# LEM-6198
     * @param notifierEvents list of platform events with payload
     */
    public static void execute(List<Notifier__e> notifierEvents) {
        service().handleNotifierEvents(notifierEvents);
    }

    /**
     * @description Calling Service Implementation class for implementing the interface
     * @JIRA# LEM-6198
     * @return IWorkObjectsSyncService
     */
    private static IWorkObjectsSyncService service() {
        return (IWorkObjectsSyncService) Application.SERVICE.newInstance(
            IWorkObjectsSyncService.class
        );
    }
}