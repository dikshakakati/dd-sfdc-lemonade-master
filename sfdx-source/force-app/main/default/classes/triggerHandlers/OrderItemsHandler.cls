/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Handler class for OrderItem related logic.
 */
public class OrderItemsHandler extends ApplicationDomainHandler {
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    private static final String ACTIVATED_STATUS = 'Activated';
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    /**
     * @description Constructor to instantiate a List of Subscription
     * @param sObjectList
     */
    public OrderItemsHandler(List<OrderItem> sObjectList) {
        super(sObjectList);
        setContextBypass(OrderItem.SObjectType, OrderItemsHandler.class);
    }
    /**
     * @description Constructor Class which implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return OrderItemsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrderItemsHandler(sObjectList);
        }
    }

    /**
     * @description It is used to perform before insert processing.
     */
    public override void onBeforeInsert() {
        OrderItems.newInstance(this.records).defaultOrderItemFields();
    }

    /**
     * @description Called to perform after Insert processing
     */
    public override void onafterInsert() {
        OrderItems.newInstance(orderItemsWithQuoteLines()).populateQuoteLineGroup();
        OrderItems.newInstance(orderItemsWithQuoteLines()).updateOrderByOrderItemSplitCategory();
    }

    /**
     * @description Called to perform after Update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, OrderItem> activeRatesAppliedOrderItemIdsMap = new Map<Id, OrderItem>();
        activeRatesAppliedOrderItemIdsMap = recordsWithUpdatedActiveRates();
        SubscriptionRateChangeService.setSubscriptionRateChangeComplete(
            OrderItemsSelector.newInstance()
                .selectPrimaryOrderItemsByIds(activeRatesAppliedOrderItemIdsMap.keySet())
        );
    }

    /**
     * @description Common method to return primary order product records when Active rates are updated
     * @return List<OrderItem>
     */
    private Map<Id, OrderItem> recordsWithUpdatedActiveRates() {
        List<OrderItem> updatedOrderProductsWithActiveRates = new List<OrderItem>(
            (List<OrderItem>) getChangedRecords(
                new Set<SObjectField>{
                    OrderItem.Active_fee__c,
                    OrderItem.Active_commission__c,
                    OrderItem.Subscription_Rate_Change__c
                }
            )
        );

        Map<Id, OrderItem> orderItemIdsToOrderItems = new Map<Id, OrderItem>(
            updatedOrderProductsWithActiveRates
        );

        return orderItemIdsToOrderItems;
    }

    /**
     * @description common method to return OrderItems with Quote Lines
     * @return List<OrderItem>
     */
    private List<OrderItem> orderItemsWithQuoteLines() {
        return new List<OrderItem>(
            (List<OrderItem>) getRecordsWithNotBlankFieldValues(OrderItem.SBQQ__QuoteLine__c)
        );
    }
}