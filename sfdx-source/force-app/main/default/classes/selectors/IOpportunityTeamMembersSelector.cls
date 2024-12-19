/**
 * @author Deloitte
 * @date 05/02/2024
 * @description Interface to add Selector class methods.
 */
public interface IOpportunityTeamMembersSelector extends fflib_ISObjectSelector {
    /**
     * @description : It is used to query Opportunity Team Members by passed Opportunity Ids.
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    List<OpportunityTeamMember> selectByOpportunityIds(Set<Id> opportunityIds);
    /**
     * @description : It is used to query Opportunity Team Members by passed Opportunity Ids without Role.
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    List<OpportunityTeamMember> selectByOpportunityIdsWithoutRole(Set<Id> opportunityIds);

    /**
     * @description It is used to query all Opportunity Team Members by the passed Opportunity Ids
     * for OI notification flow.
     * @param opportunityIds
     * @return List<OpportunityTeamMember>
     */
    List<OpportunityTeamMember> selectAllOpportunityTeamMembersByOpportunityIds(
        Set<String> opportunityIds
    );
}