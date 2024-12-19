/**
 * @description Order Object Trigger Handler
 * @author ATG
 * @date 2022-04-05
 */
public class OrdersHandler extends ApplicationDomainHandler {
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';

    /**
     * @description Constructor Method
     * @param sObjectList - Order Record List
     */
    public OrdersHandler(List<Order> sObjectList) {
        super(sObjectList);
        setContextBypass(Order.SObjectType, OrdersHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return AccountHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrdersHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Orders.newInstance(this.records).setReadyForActivation();
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        Orders.newInstance(getStatusChangedOrdersWithActivatedStatus())
            .updateEffectiveDateForMigratedOrders();
    }

    /**
     * @description Called to perform after update processing
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        Orders.newInstance(this.records).setActive();
        Orders.newInstance(this.records).setContracted();
        Orders.newInstance(this.records).setStatusForActivationOrder();
    }

    /**
     * @description gets orders with status changed and equal to Activated
     * @return set of ids
     */
    private List<Order> getStatusChangedOrdersWithActivatedStatus() {
        List<Order> statusChangedOrdersWithActiveStatus = new List<Order>();
        for (
            Order eachOrder : (List<Order>) getChangedRecords(new Set<SObjectField>{ Order.Status })
        ) {
            if (eachOrder.Status == ORDER_STATUS_ACTIVATED) {
                statusChangedOrdersWithActiveStatus.add(eachOrder);
            }
        }

        return statusChangedOrdersWithActiveStatus;
    }
}