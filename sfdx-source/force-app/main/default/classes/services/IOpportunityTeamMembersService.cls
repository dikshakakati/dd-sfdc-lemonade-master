/**
 * @author Deloitte
 * @date   14/04/2023
 * @description Interface of service class for  OpportunityTeamMember related logic
 */
public interface IOpportunityTeamMembersService {
    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     * @param newOpportunities
     */
    void createOpportunityTeamMembersForManagers(List<Opportunity> newOpportunities);
}