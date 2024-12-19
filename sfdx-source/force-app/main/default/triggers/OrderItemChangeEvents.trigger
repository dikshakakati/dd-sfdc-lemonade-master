/**
 * @author Deloitte
 * @date 16/06/2022
 * @description Trigger to subscribe OrderItem change data capture events.
 */
trigger OrderItemChangeEvents on OrderItemChangeEvent(after insert) {
    fflib_SObjectDomain.triggerHandler(OrderItemChangeEventsHandler.class);
}