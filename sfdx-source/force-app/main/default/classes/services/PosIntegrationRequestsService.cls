/**
 * @author DoorDash
 * @date 03/09/2023
 * @description Service class for processing pos integration requests.  
 */
public with sharing class PosIntegrationRequestsService implements IHandleNotifierEvents{
    
    private static IPosIntegrationRequestsService service() {
        return (IPosIntegrationRequestsService) Application.SERVICE.newInstance(IPosIntegrationRequestsService.class);
    }
    /**
     * @description It is used for getting parent Integration Requests from the payload received via Platform Event.
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }
    /**
    * @description this method will be called make newly created work plans to current. 
    * this method will be called from these classes PosIntegrationRequestServiceImpl and WorkOrdersServiceImpl. 
    * @param workOrders a list of WorkOrder objects representing the work orders whose associated work plans should be made current.
    */
    public static void makePosWorkPlansCurrent(List<WorkOrder> workOrders) {
        service().makePosWorkPlansCurrent(workOrders);
    }
}