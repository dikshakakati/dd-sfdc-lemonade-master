/**
 * @author Deloitte
 * @date 16/06/2022
 * @description OrderItemChangeEvent trigger handler.
 * Note: Batch size is defaulted to 200 using PlatformEventSubscriberConfig.
 */
public class OrderItemChangeEventsHandler extends ApplicationDomainHandler {
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String CONTRACT_ID_FIELD_NAME = 'SBQQ__Contract__c';

    /**
     * @description Constructor to instantiate list of OrderItemChangeEvent.
     * @param sObjectList - OrderItemChangeEvent records
     */
    public OrderItemChangeEventsHandler(List<OrderItemChangeEvent> sObjectList) {
        super(sObjectList);
        setContextBypass(OrderItemChangeEvent.SobjectType, OrderItemChangeEventsHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        Set<Id> orderItemIds = new Set<Id>();
        Set<Id> orderItemIdsWithChangedContract = new Set<Id>();
        for (
            OrderItemChangeEvent eachOrderItemChangeEvent : (List<OrderItemChangeEvent>) this.records
        ) {
            EventBus.ChangeEventHeader header = eachOrderItemChangeEvent.ChangeEventHeader;
            if (header.changeType == CHANGE_TYPE_CREATE) {
                orderItemIds.addAll(
                    (Set<Id>) JSON.deserialize(JSON.serialize(header.recordIds), Set<Id>.class)
                );
            }
            if (header.changeType == CHANGE_TYPE_UPDATE) {
                for (String eachChangedField : header.changedFields) {
                    if (eachChangedField == CONTRACT_ID_FIELD_NAME) {
                        orderItemIdsWithChangedContract.addAll(
                            (Set<Id>) JSON.deserialize(
                                JSON.serialize(header.recordIds),
                                Set<Id>.class
                            )
                        );
                    }
                }
            }
        }
        OrderItemsService.invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(
            orderItemIdsWithChangedContract
        );
        OrdersService.populateBackEndSystemsFieldOnOrder(orderItemIds);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain.IConstructable interface.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - list of SObjects
         * @return OrderItemChangeEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new OrderItemChangeEventsHandler(sObjects);
        }
    }
}