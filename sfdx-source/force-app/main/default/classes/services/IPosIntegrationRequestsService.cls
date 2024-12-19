/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Service class for processing new integration requests and making work plan current. 
 */
public interface IPosIntegrationRequestsService {

    /**
     * @description It is for getting new integration requests, sending workorder ids for work plan creation and make work plan current.
     * via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It is for making workplan as current after the work plans are created from bat pos requests. 
     * via Platform Event.
     * @param workOrders
     */
    void makePosWorkPlansCurrent(List<WorkOrder> workOrders);
}