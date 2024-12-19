/**
 * @author Deloitte
 * @date 08/08/2024
 * @description It is a Trigger on Bulk Order Creation Platform Event
 */
trigger BulkOrderCreations on Bulk_Order_Creation__e (after insert) {
    fflib_SObjectDomain.triggerHandler(BulkOrderCreationsHandler.class);
}