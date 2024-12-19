/**
 * @author Deloitte
 * @date 21/02/2022
 * @description Trigger on User Object
 */
trigger Users on User(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(UsersHandler.class);

}