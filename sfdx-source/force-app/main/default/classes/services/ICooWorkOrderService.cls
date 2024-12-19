/**
 * @author DoorDash
 * @date 08/28/2023
 * @description Interface of service class for COOWorkOrder Service related logic.
 */
public interface ICooWorkOrderService {

    /**
     * @description Create event, it Create/Update the COO workorder
     * @param intReqByBatch
     * @param batchIdToOppId
     */
    void createUpdateParentWorkOrder(List<Integration_Request__c> intReqByBatch, Map<String, Id> batchIdToOppId);

    /**
     * @description Cancelled event, it updates the COO workorder to Dead
     * @param intReqByBatch
     * @param batchIdToOppId
     */
    void updateWorkOrderToDead(List<Integration_Request__c> intReqByBatch, Map<String, Id> batchIdToOppId);

     /**
     * @description On Completed event, it updates the COO workOrder to Complete
     * @param intReqByBatch
     */
    void updateWorkOrderToComplete(List<Integration_Request__c> intReqByBatch);

    /**
     * @description On Ready event, it Reevaluates the COO WorkOrder for POS workplans
     * @param intReqByBatch
     */
    void processPosIntRequestOnReadyEvent(List<Integration_Request__c> intReqByBatch);
}