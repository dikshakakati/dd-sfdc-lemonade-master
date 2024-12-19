/**
 * @author DoorDash QTC
 * @date 07/31/2022
 * @description Interface to add OrdersSelector class methods
 */
public interface IOrdersSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return List<Order> - Orders List
     */
    List<Order> selectById(Set<Id> idSet);
    /**
     * @description This method is used for getting orders by AccoountIds
     * @param accountIds
     * @return List<Order>
     */
    List<Order> selectOrdersByAccountIds(Set<Id> accountIds);

    /**
     * @description This method is used for getting orders by opportunity Id
     * @param opportunityIds
     * @return List<Order>
     */
    List<Order> selectOrdersByOpportunityIds(Set<Id> opportunityIds);
    /**
     * @description This method is used for getting orders by opportunity Id
     * @param accountIds
     * @return List<Order>
     */
    List<Order> selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
        Set<Id> accountIds
    );
}