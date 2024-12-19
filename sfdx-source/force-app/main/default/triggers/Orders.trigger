/**
 * @author ATG
 * @date 2022-04-05
 * @description Trigger on Order Object
 */

trigger Orders on Order (
    before insert,
    before update,
    after insert,
    after update,
    before delete,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(OrdersHandler.class);
}