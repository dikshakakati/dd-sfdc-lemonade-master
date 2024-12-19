/**
 * @author Deloitte
 * @date   14/04/2023
 * @description This is the service class for OpportunityTeamMember
 */
public inherited sharing class OpportunityTeamMembersService {
    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     * @param newOpportunities
     */
    public static void createOpportunityTeamMembersForManagers(List<Opportunity> newOpportunities) {
        service().createOpportunityTeamMembersForManagers(newOpportunities);
    }
    private static IOpportunityTeamMembersService service() {
        return (IOpportunityTeamMembersService) Application.Service.newInstance(
            IOpportunityTeamMembersService.class
        );
    }
}