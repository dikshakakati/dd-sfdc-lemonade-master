/**
 * @description Trigger on OpportunityContactRole
 * @author Deloitte
 * @date 27/04/2022
 */
trigger OpportunityContactRoles on OpportunityContactRole(
    before insert,
    after insert,
    before update,
    after update,
    after delete
) {
    fflib_SObjectDomain.triggerHandler(OpportunityContactRoleHandler.class);
}