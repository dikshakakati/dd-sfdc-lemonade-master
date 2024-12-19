/**
 * @author Deloitte
 * @date 2023-08-21
 * @description Domain Class for OrderItem Object
 */
public inherited sharing class OrderItems extends fflib_SObjects implements IOrderItems {
    public static final String PRIMARY_ORDER_RECORD_TYPE = 'Primary Order';

    /**
     * @description This method is used to return the IOrderItems interface
     * @param recordList - OrderItem record list
     * @return IOrderItems - Returns IOrderItems Interface
     */
    public static IOrderItems newInstance(List<OrderItem> recordList) {
        return (IOrderItems) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public OrderItems(List<OrderItem> sObjectList) {
        super(sObjectList, Schema.Contract.SObjectType);
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return OrderItems - List of OrderItem
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (OrderItems.constructorMock != null) {
                return (fflib_SObjects) OrderItems.constructorMock.construct(objectList);
            }
            return new OrderItems((List<SObject>) objectList);
        }
    }

    /**
     * @description Updates Quote line Group Fields on order item
     */
    public void populateQuoteLineGroup() {
        List<OrderItem> primaryOrderItemList = new List<OrderItem>();

        Map<Id, OrderItem> newOrderItemMap = new Map<Id, OrderItem>((List<OrderItem>) getRecords());
        if (newOrderItemMap.isEmpty()) {
            return;
        }

        primaryOrderItemList = OrderItemsSelector.newInstance()
            .selectOrderItemsWithPrimaryOrderFields(newOrderItemMap.keySet());

        if (primaryOrderItemList.isEmpty()) {
            return;
        }
        OrderItemsService.populateQuoteLineGroup(primaryOrderItemList);
    }

    /**
     * @description It is used to update orders based on the OrderType by OrderIds.
     * @JIRA# LEM-14231
     */
    public void updateOrderByOrderItemSplitCategory() {
        Map<Id, String> orderIdToType = new Map<Id, String>();
        String orderType;

        for (OrderItem eachOrderItem : (List<OrderItem>) getRecords()) {
            orderType = eachOrderItem.Split_Category__c;
            if (
                String.isNotEmpty(orderType) &&
                !orderIdToType.containsKey(eachOrderItem.OrderId) &&
                eachOrderItem.Order_Record_Type__c == PRIMARY_ORDER_RECORD_TYPE
            ) {
                orderIdToType.put(eachOrderItem.OrderId, orderType);
            }
        }

        if (orderIdToType.isEmpty()) {
            return;
        }
        OrdersService.updateOrderByOrderItemSplitCategory(orderIdToType);
    }

    /**
     * @description It is used to default the order item fields.
     * @JIRA# LEM-21389, LEM-16377
     */
    public void defaultOrderItemFields() {
        for (OrderItem eachOrderItem : (List<OrderItem>) getRecords()) {
            eachOrderItem.SMB_Pricing_Tier_Clone__c = eachOrderItem.SMB_Pricing_Tier__c;
        }
    }
}