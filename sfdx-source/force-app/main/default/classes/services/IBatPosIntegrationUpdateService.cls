/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Interface for handling pos work step updates from bat integration pos requests. 
 */
public interface IBatPosIntegrationUpdateService {
    /**
     * @description it will get the update request platform events raised from integration gration requests domain class. 
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);
}