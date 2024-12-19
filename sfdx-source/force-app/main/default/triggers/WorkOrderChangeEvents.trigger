/**
 * @author Deloitte
 * @date 18/07/2022
 * @description Trigger to subscribe WorkOrder change data capture events.
 */
trigger WorkOrderChangeEvents on WorkOrderChangeEvent(after insert) {
    fflib_SObjectDomain.triggerHandler(WorkOrderChangeEventsHandler.class);
}