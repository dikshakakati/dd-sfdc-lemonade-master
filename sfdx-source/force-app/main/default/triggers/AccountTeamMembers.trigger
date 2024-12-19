/*
 * @author Deloitte
 * @date 19/06/2023
 * @description Trigger on AccountTeamMembers Object
*/
trigger AccountTeamMembers on AccountTeamMember (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(AccountTeamMembersHandler.class);
}