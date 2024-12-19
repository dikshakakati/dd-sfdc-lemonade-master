/**
 * @author DoorDash QTC
 * @date   07/29/2022
 * @description This is the service class for Order related logic
 */
public inherited sharing class OrdersService {

/**
    * @description Constructor to perform before update processing
    * @param orderItemIds
    */
    public static void populateBackEndSystemsFieldOnOrder(Set<Id> orderItemIds) {
        service().populateBackEndSystemsFieldOnOrder(orderItemIds);
    }

    /**
    * @description It is used to update orders based on the OrderType by OrderIds.
    * @param orderIdToType
    */
    public static void updateOrderByOrderItemSplitCategory(Map<Id,String> orderIdToType) {
        service().updateOrderByOrderItemSplitCategory(orderIdToType);
    }

    private static IOrdersService service() {
        return (IOrdersService) Application.Service.newInstance(IOrdersService.class);
    }
}