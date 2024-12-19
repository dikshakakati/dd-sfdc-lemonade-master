/**
 * @author DoorDash
 * @date 20-Sep-2023
 * @description Schedules the BulkStoreOnboardingBatch for loading bulk Stores
**/
public class BulkStoreOnboardingScheduler implements Schedulable {
    private Id flowRequestId;
    
    /**
     * @description Constructor - needs to accept a PFR Id for the Request
     * @param flowRequestId
    **/
    public BulkStoreOnboardingScheduler(Id flowRequestId) {
        this.flowRequestId = flowRequestId;
    }
    
    /**
     * @description Schedulable interface method to execute this class.
     * @param sc
    **/
    public void execute(SchedulableContext sc){
        BulkCorporateOnboardingRequestService.checkAndExecuteBatch(flowRequestId);
    }
}