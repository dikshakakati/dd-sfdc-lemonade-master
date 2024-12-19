/**
 * @description : Service Implimentation class for Order Object
 * @author DoorDash QTC
 * @date 07/29/2022
 */
public inherited sharing class OrdersServiceImpl implements IOrdersService {
    private static final String LOG_SERVICE = 'Order Split';
    private static final String LOG_DOMAIN = 'CPQ';
    private static final String ORDER_TYPE_CORE = 'Core';
    private static final String NINTEX_MWP = 'Middleware Provider';
    private Map<Id, Set<String>> orderIdToBackEndSystems;

    /**
     * @description - Update Orders Based on Order Items
     * @param orderItemIds
     */
    public void populateBackEndSystemsFieldOnOrder(Set<Id> orderItemIds) {
        orderIdToBackEndSystems = new Map<Id, Set<String>>();

        List<OrderItem> orderItemsList = OrderItemsSelector.newInstance()
            .selectProductBackEndByOrderItemIds(getOrderIds(orderItemIds));

        for (OrderItem eachActivatedOrderItem : orderItemsList) {
            if (!orderIdToBackEndSystems.containsKey(eachActivatedOrderItem.OrderId)) {
                orderIdToBackEndSystems.put(eachActivatedOrderItem.OrderId, new Set<String>());
            }

            orderIdToBackEndSystems.get(eachActivatedOrderItem.OrderId)
                .add(eachActivatedOrderItem.Product2.Backend_System__c);
        }
        setBackEndSystemsOnOrder();
    }

    private Set<Id> getOrderIds(Set<Id> orderItemIds) {
        Set<Id> orderIdSet = new Set<Id>();
        List<OrderItem> orderItemsList = OrderItemsSelector.newInstance().selectById(orderItemIds);

        for (OrderItem oi : orderItemsList) {
            orderIdSet.add(oi.OrderId);
        }
        return orderIdSet;
    }

    private void setBackEndSystemsOnOrder() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (Id orderId : orderIdToBackEndSystems.keyset()) {
            if (orderId != null) {
                String backendSystems = String.join(
                    new List<String>(orderIdToBackEndSystems.get(orderId)),
                    ';'
                );
                Order orderObj = new Order(Id = orderId, Backend_Systems__c = backendSystems);
                uow.registerDirty(orderObj);
            }
        }

        try {
            uow.commitWork();
        } catch (Exception uowException) {
            Logger.publish(LogEntry.newExceptionLog(uowException, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to update orders based on the OrderType by OrderIds.
     * @JIRA# LEM-14231
     * @param orderIdToType
     */
    public void updateOrderByOrderItemSplitCategory(Map<Id, String> orderIdToType) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, Id> quoteIdsToOrderIds = new Map<Id, Id>();
        List<Order> orders = OrdersSelector.newInstance().selectById(orderIdToType.keySet());
        for (Order eachOrder : orders) {
            if (orderIdToType.get(eachOrder.Id) == ORDER_TYPE_CORE) {
                quoteIdsToOrderIds.put(eachOrder.SBQQ__Quote__c, eachOrder.Id);
            }
        }
        List<SBQQ__Quote__c> quotes = QuotesSelector.newInstance()
            .selectById(quoteIdsToOrderIds.keySet());
        for (SBQQ__Quote__c eachQuote : quotes) {
            if (eachQuote.Nintex_Use_Case__c == NINTEX_MWP) {
                orderIdToType.put(quoteIdsToOrderIds.get(eachQuote.Id), NINTEX_MWP);
            }
        }

        for (Id eachOrderId : orderIdToType.keySet()) {
            uow.registerDirty(new Order(Id = eachOrderId, Type = orderIdToType.get(eachOrderId)));
        }

        try {
            uow.commitWork();
        } catch (Exception uowException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.HIGH
                )
            );
        }
    }
}