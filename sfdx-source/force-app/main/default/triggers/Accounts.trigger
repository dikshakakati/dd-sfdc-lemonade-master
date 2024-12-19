/**
 * @author Deloitte
 * @date 21/02/2022
 * @description Trigger on Account Object
 */

trigger Accounts on Account(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(AccountsHandler.class);

}