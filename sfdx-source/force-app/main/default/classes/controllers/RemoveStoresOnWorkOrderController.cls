/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description Controller class for removeStoresOnWorkOrder lightning web component.
 */
public with sharing class RemoveStoresOnWorkOrderController {

    /**
     * @description It removes child Work Orders for the selected stores.
     * @JIRA# LEM-5343
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @param markAsDead
     * @param workOrderPDOA
     * @return String - validation error message
     */
    @AuraEnabled
    public static String removeStores(Id parentWorkOrderId, String storeAccountIds,Boolean markAsDead,Date workOrderPDOA) {
        return RemoveStoresOnWorkOrderService.removeStores(parentWorkOrderId,storeAccountIds,markAsDead,workOrderPDOA);
    }

}