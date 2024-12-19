/**
 * @author Deloitte
 * @date 08/22/2022
 * @description Service class for OrderItem related logic.
 */
public inherited sharing class OrderItemsService implements IHandleNotifierEvents {
    /**
     * @description It is used for getting OrderItem Ids from the payload
     * received via platform event.
     * @JIRA# LEM-3255
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description It is used to collect store Accounts having Storefront Product sold together
     * with Markteplace Product from the passed Order Products by checking Products attached
     * to Primary Order Product's Order.
     * @JIRA# LEM-2132
     * @param activatedOrderItems
     * @return Map<Id, Boolean>
     */
    public static Map<Id, Boolean> getStoresWithBundledOrderProducts(
        List<OrderItem> activatedOrderItems
    ) {
        return service().getStoresWithBundledOrderProducts(activatedOrderItems);
    }

    /**
     * @description It sends notifier events for initiating child Work Orders creation from
     * the passed orderItemIds.
     * @JIRA# LEM-3255
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    public static void initiateChildWorkOrdersCreation(
        Set<Id> orderItemIds,
        Boolean isManagePricingProcess
    ) {
        service().initiateChildWorkOrdersCreation(orderItemIds, isManagePricingProcess);
    }

    /**
     * @description It collects Contracts linked to Order Items associated with Primary Order
     * to associate on parent Work Orders.
     * @JIRA# LEM-4005
     * @param orderItemIds
     */
    public static void invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(
        Set<Id> orderItemIds
    ) {
        service().invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(orderItemIds);
    }

    /**
     * @description It is used to populate parent Work Order on the passed Order Items
     * by matching associated OrderId and Work Order Type & Sub-Type of associated Product.
     * @JIRA# LEM-2445, LEM-3200
     * @param orderItemIdentifierToWorkOrder
     * @param orderItems
     */
    public static void populateWorkOrderOnOrderItems(
        Map<String, WorkOrder> orderItemIdentifierToWorkOrder,
        List<OrderItem> orderItems
    ) {
        service().populateWorkOrderOnOrderItems(orderItemIdentifierToWorkOrder, orderItems);
    }

    /**
     * @description It populates the Active rates on primary order products
     * from the passed list of subscriptions
     * @param activeRatesAppliedSubscriptions
     */
    public static void populateActiveRatesOnPrimaryOrderItems(
        List<SBQQ__Subscription__c> activeRatesAppliedSubscriptions
    ) {
        service().populateActiveRatesOnPrimaryOrderItems(activeRatesAppliedSubscriptions);
    }

    /**
     * @description It creates instance of OrderItemsServiceImpl class.
     * @return IOrderItemsService - instance of OrderItemsServiceImpl
     */
    private static IOrderItemsService service() {
        return (IOrderItemsService) Application.Service.newInstance(IOrderItemsService.class);
    }

    /**
     * @description It is used to populate quote line group on the passed Order Items
     * @param orderItemList
     */
    public static void populateQuoteLineGroup( List<OrderItem> orderItemList ) {
        service().populateQuoteLineGroup(orderItemList);
    }
}