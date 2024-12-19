/**
 * @author BizApps
 * @date 04/25/2023
 * @description Service Class for CooWorkOrderService
 */
public with sharing class CooWorkOrderService {

    /**
     * @description It creates instance of CooWorkOrderServiceImpl class.
     * @return ICooWorkOrderService - return instance of CooWorkOrderServiceImpl
     */
    private static ICooWorkOrderService service() {
        return (ICooWorkOrderService) Application.SERVICE.newInstance(ICooWorkOrderService.class);
    }

    /**
     * @description Create event, it Create/Update the COO workorder
     * @JIRA# LEM-9090
     * @param intReqByBatch
     * @param batchIdToOppId
     */
    public static void createUpdateParentWorkOrder(List<Integration_Request__c> intReqByBatch, Map<String, Id> batchIdToOppId) {
        service().createUpdateParentWorkOrder(intReqByBatch, batchIdToOppId);
    }

    /**
     * @description Cancelled event, it updates the COO workorder to Dead
     * @JIRA# LEM-9090
     * @param intReqByBatch
     * @param batchIdToOppId
     */
    public static void updateWorkOrderToDead(List<Integration_Request__c> intReqByBatch, Map<String, Id> batchIdToOppId) {
        service().updateWorkOrderToDead(intReqByBatch, batchIdToOppId);
    }

    /**
     * @description On Completed event, it updates on COO workOrder to Complete
     * @JIRA# LEM-9090
     * @param intReqByBatch
     */
    public static void updateWorkOrderToComplete(List<Integration_Request__c> intReqByBatch) {
        service().updateWorkOrderToComplete(intReqByBatch);
    }

     /**
     * @description On Ready event,it ReEvaluates the COO workorder for POS workplans
     * @JIRA# LEM-9090
     * @param intReqByBatch
     */
    public static void processPosIntRequestOnReadyEvent(List<Integration_Request__c> intReqByBatch) {
        service().processPosIntRequestOnReadyEvent(intReqByBatch);
    }
}