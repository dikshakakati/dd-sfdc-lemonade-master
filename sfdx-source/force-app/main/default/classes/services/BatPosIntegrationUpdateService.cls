/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Service class for handling pos work step updates from bat integration pos requests. 
 */
public with sharing class BatPosIntegrationUpdateService implements IHandleNotifierEvents {
    private static IBatPosIntegrationUpdateService service() {
        return (IBatPosIntegrationUpdateService) Application.SERVICE.newInstance(IBatPosIntegrationUpdateService.class);
    }
    /**
     * @description It is used for getting parent Integration Requests from the payload received via Platform Event.
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }
}