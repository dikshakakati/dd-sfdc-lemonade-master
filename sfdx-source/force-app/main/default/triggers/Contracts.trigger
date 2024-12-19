/**
 * @author ATG
 * @date 2022-04-11
 * @description Trigger on Contract Object
 */

trigger Contracts on Contract (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(ContractsHandler.class);
}