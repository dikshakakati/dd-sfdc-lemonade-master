/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Trigger for OpportunityTeamMember
 */
trigger OpportunityTeamMembers on OpportunityTeamMember(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(OpportunityTeamMembersHandler.class);
}