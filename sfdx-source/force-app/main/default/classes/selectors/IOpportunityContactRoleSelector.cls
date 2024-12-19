/**
 * @author Deloitte
 * @date 24/03/2022
 * @description Interface to add OpportunityContactRoleSelector class methods
 */
public interface IOpportunityContactRoleSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting OpportunityContactRole based on Id
     * @param setIds Set of Ids
     * @return List<OpportunityContactRole>
     */
    List<OpportunityContactRole> selectById(Set<Id> setIds);

    /**
     * @description This method is used to get the list of OpportunityContactRole for opportunities
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    List<OpportunityContactRole> selectByOpportunity(Set<Id> opportunityIds);

    /**
     * @description It is used to get the list of Primary OpportunityContactRole for the passed
     * Opportunities and role.
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    List<OpportunityContactRole> selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
        Set<Id> opportunityIds
    );
    /**
     * @description This method is used to get the list of OpportunityContactRole for opportunities
     *              with Contract Signatory as Role
     * @param opportunityIds
     * @return List<OpportunityContactRole>
     */
    List<OpportunityContactRole> selectContractSignatoryOppContactRole(Set<Id> opportunityIds);

    /**
     * @description This method is used to get the list of Contract Signatory
     *  OpportunityContactRole for opportunities by quote id.
     * @param quoteIds
     * @return List<OpportunityContactRole>
     */
    List<OpportunityContactRole> selectByQuoteIdAndFilterByContractSignatory(Set<Id> quoteIds);
}