/**
 * @author Deloitte
 * @date 08/22/2022
 * @description Interface of service class for OrderItem related logic.
 */
public interface IOrderItemsService {
    /**
     * @description It is used to collect store Accounts having Storefront Product sold together
     * with Markteplace Product from the passed Order Products by checking Products attached
     * to Primary Order Product's Order.
     * @param activatedOrderItems
     * @return Map<Id, Boolean>
     */
    Map<Id, Boolean> getStoresWithBundledOrderProducts(List<OrderItem> activatedOrderItems);

    /**
     * @description It gets OrderItem Ids from the payload received via platform event
     * and initiates child Work Orders creation.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It sends notifier events for initiating child Work Orders creation from
     * the passed orderItemIds.
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    void initiateChildWorkOrdersCreation(Set<Id> orderItemIds, Boolean isManagePricingProcess);

    /**
     * @description It collects Contracts linked to Order Items associated with Primary Order
     * to associate on parent Work Orders.
     * @param orderItemIds
     */
    void invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(Set<Id> orderItemIds);

    /**
     * @description It is used to populate parent Work Order on the passed Order Items
     * by matching associated OrderId and Work Order Type & Sub-Type of associated Product.
     * @param orderItemIdentifierToWorkOrder
     * @param orderItems
     */
    void populateWorkOrderOnOrderItems(
        Map<String, WorkOrder> orderItemIdentifierToWorkOrder,
        List<OrderItem> orderItems
    );

    /**
     * @description It populates the Active rates on primary order products
     * from the passed list of subscriptions
     * @param activeRatesAppliedSubscriptions
     */
    void populateActiveRatesOnPrimaryOrderItems(
        List<SBQQ__Subscription__c> activeRatesAppliedSubscriptions
    );

    /**
     * @description It is used to populate quote line group on the passed Order Items
     * @param orderItemList
     */
    void populateQuoteLineGroup( List<OrderItem> orderItemList );
}