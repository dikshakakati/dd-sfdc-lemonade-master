/**
 * @author DoorDash QTC
 * @date 07/28/2022
 * @description Interface of service class for Orders related logic.
 */
public interface IOrdersService {
    /**
    * @description It is used to update orders based on the OrdemItems by OrderIds.
    * @param orderItemIds
    */
    void populateBackEndSystemsFieldOnOrder(Set<Id> orderItemIds);
    /**
    * @description It is used to update orders based on the OrderType by OrderIds.
    * @param orderIdToType
    */
    void updateOrderByOrderItemSplitCategory(Map<Id,String> orderIdToType);
}
