/**
 * @author Deloitte
 * @date 22/09/2023
 * @description Trigger for OrderItem object.
 */
trigger OrderItems on OrderItem(after insert, after update, before insert) {
    fflib_SObjectDomain.triggerHandler(OrderItemsHandler.class);
}