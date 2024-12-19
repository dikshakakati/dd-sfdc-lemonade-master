/**
 * @author DoorDash
 * @date 05/03/2023
 * @description Service class for processing coo same store requests.  
 */
public with sharing class CooSameStoreService implements IHandleNotifierEvents{
    private static ICooSameStoreService service() {
        return (ICooSameStoreService) Application.SERVICE.newInstance(ICooSameStoreService.class);
    }
     /**
     * @description It is used for getting coo requests.
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }
}