/**
 * @author Deloitte
 * @date 05/12/2024
 * @description The controller for OI Notification Flow (Mx Onboarding Link: Send Bell Notification).
 * This class is declared as without sharing as to avoid sharing issues in Guest User context.
 */
public without sharing class OINotificationsFlowController {
    /**
     * @description It is used to get Opportunity Team Members by the passed Opportunity Ids.
     * @JIRA# LEM-23683
     * @param opportunityIds
     * @return List<List<OpportunityTeamMember>>
     */
    @InvocableMethod(label='Get Opportunity Team Members')
    public static List<List<OpportunityTeamMember>> getOpportunityTeamMembers(
        List<String> opportunityIds
    ) {
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectAllOpportunityTeamMembersByOpportunityIds(new Set<String>(opportunityIds));
        return new List<List<OpportunityTeamMember>>{ opportunityTeamMembers} ;
    }
}