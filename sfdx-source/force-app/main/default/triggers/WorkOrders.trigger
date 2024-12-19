/**
 * @author Deloitte
 * @date 30/03/2022
 * @description Trigger on WorkOrder object.
 */
trigger WorkOrders on WorkOrder(
    after delete,
    after insert,
    after undelete,
    after update,
    before insert,
    before update
) {
    fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
}