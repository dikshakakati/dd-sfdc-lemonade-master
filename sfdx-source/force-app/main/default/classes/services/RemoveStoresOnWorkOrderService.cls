/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description Service class for RemoveStoresOnWorkOrderController related logic.
 */
public inherited sharing class RemoveStoresOnWorkOrderService {
    /**
     * @description It removes stores associated to the parent Work Orders
     * @JIRA# LEM-5343
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @param markAsDead
     * @param workOrderPDOA
     * @return String - validation error message
     */
    public static String removeStores(Id parentWorkOrderId, String storeAccountIds,Boolean markAsDead,Date workOrderPDOA) {
        return service().removeStores(parentWorkOrderId, storeAccountIds,markAsDead,workOrderPDOA);
    }

    /**
     * @description It creates instance of RemoveStoresOnWorkOrderServiceImpl class.
     * @return IRemoveStoresOnWorkOrderService - instance of RemoveStoresOnWorkOrderServiceImpl
     */
    private static IRemoveStoresOnWorkOrderService service() {
        return (IRemoveStoresOnWorkOrderService) Application.Service.newInstance(
            IRemoveStoresOnWorkOrderService.class
        );
    }
}