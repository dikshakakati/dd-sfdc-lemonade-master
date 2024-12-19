/**
 * @author Deloitte
 * @date 12/01/2023
 * @description Service class for processing Tablet Case Sync integration requests.
 */
public with sharing class FigmentToDdmxSyncService implements IHandleNotifierEvents {
    private static IFigmentToDdmxSyncService service() {
        return (IFigmentToDdmxSyncService) Application.SERVICE.newInstance(
            IFigmentToDdmxSyncService.class
        );
    }
    /**
     * @description It is used for getting parent Integration Requests from the payload received via Platform Event.
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }
}