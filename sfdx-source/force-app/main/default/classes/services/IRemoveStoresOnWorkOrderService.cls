/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description Interface for service class of RemoveStoresOnWorkOrder controller related logic.
 */
public interface IRemoveStoresOnWorkOrderService {
    /**
     * @description To remove stores associated to parent Work Order
     * for the selected stores.
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @param markAsDead
     * @param workOrderPDOA
     * @return String
     */
    String removeStores(Id parentWorkOrderId, String storeAccountIds,Boolean markAsDead,Date workOrderPDOA);

}