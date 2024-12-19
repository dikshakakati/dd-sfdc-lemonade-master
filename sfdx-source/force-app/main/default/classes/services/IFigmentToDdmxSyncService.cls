/**
 * @author Deloitte
 * @date 12/01/2023
 * @description Service class for processing Tablet Case Sync integration requests.  
 */
public interface IFigmentToDdmxSyncService {
    /**
     * @description It is for getting integration requests, sending workorder ids for work plan updation.
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}