/**
 * @author Deloitte
 * @date 14/11/2024
 * @description Trigger on Work Order Processor Platform Event
 */
trigger WorkOrderProcessor on Work_Order_Processor__e(after insert) {
    fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
}