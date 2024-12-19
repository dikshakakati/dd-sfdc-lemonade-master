/**
 * @author Venkatesh Rimmalapudi (Git: VenkateshDD)
 * @date 03/07/2024
 * @description Interface to add OpportunityBrandRelationshipsService class methods
 */
public interface IOpportunityBrandRelationshipsService {

    /**
     * @description Creates a new Opportunity Brand Relationship record.
     * @param opportunityId The Id of the Opportunity.
     * @param brandAsscId The Id of the Brand Association.
     * @return The created Opportunity Brand Relationship record.
     */
    Opportunity_Brand_Relationship__c createOpportunityBrandRelationShip(Id opportunityId, Id brandAsscId);

    /**
     * @description Creates Opportunity Brand Relationships for a given Opportunity and a set of Brand Association IDs.
     * @param opportunityId The ID of the Opportunity for which the relationships need to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Opportunity.
     * @return A list of Opportunity_Brand_Relationship__c records representing the created relationships.
     */
    List<Opportunity_Brand_Relationship__c> createOpportunityBrandRelationShips(Id opportunityId, Set<Id> brandAsscIds);
}