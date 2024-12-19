/**
 * @author Deloitte
 * @date 11/28/2022
 * @description Interface to add OpportunityBrandRelationshipsSelector class methods
 */
public interface IOpportunityBrandRelationshipsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used to get the list of Opportunity_Brand_Relationship__c
     * for opportunities
     * @param opportunityIds
     * @return List<Opportunity_Brand_Relationship__c>
     */
    List<Opportunity_Brand_Relationship__c> selectByOpportunity(Set<Id> opportunityIds);

    /**
     * @description Retrieves a list of Opportunity_Brand_Relationship__c records based on the provided Opportunity Id and Brand Association Id.
     *
     * @param opportunityId The Id of the Opportunity.
     * @param brandAsscIds The Id of the Brand Association.
     * @return A list of Opportunity_Brand_Relationship__c records that match the given Opportunity Id and Brand Association Id.
     */
    List<Opportunity_Brand_Relationship__c> selectByOpportunityAndBrandAsscs(Id opportunityId, Set<Id> brandAsscIds);
}