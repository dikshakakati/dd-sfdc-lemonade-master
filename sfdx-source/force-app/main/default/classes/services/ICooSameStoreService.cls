/**
 * @author DoorDash
 * @date 05/03/2023
 * @description Service class for processing coo same store requests.  
 */
public interface ICooSameStoreService {
    /**
     * @description It is used for getting coo requests.
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}