/**
 * @author Venkatesh Rimmalapudi (Git: VenkateshDD)
 * @date 03/07/2024
 * @description sevice class to add Opportunity Brand Relations Logic
 */
public with sharing class OpportunityBrandRelationshipsService {

    /**
     * @description Creates a new Opportunity Brand Relationship record.
     *
     * @param opportunityId The Id of the Opportunity.
     * @param brandAsscId The Id of the Brand Association.
     * @return The newly created Opportunity Brand Relationship record.
     */
    public static Opportunity_Brand_Relationship__c createOpportunityBrandRelationShip(Id opportunityId, Id brandAsscId){
        return service().createOpportunityBrandRelationShip(opportunityId, brandAsscId);
    }

    /**
     * @description Creates Opportunity Brand Relationships for a given Opportunity and a set of Brand Association IDs.
     *
     * @param opportunityId The ID of the Opportunity for which the Brand Relationships are to be created.
     * @param brandAsscIds The set of Brand Association IDs to be associated with the Opportunity.
     * @return A list of Opportunity_Brand_Relationship__c records representing the created relationships.
     */
    public static List<Opportunity_Brand_Relationship__c> createOpportunityBrandRelationShips(Id opportunityId, Set<Id> brandAsscIds){
        return service().createOpportunityBrandRelationShips(opportunityId, brandAsscIds);
    }

    /**
     * @description This method is used to create an instance of OpportunityBrandRelationshipsService class.
     * @return IOpportunityBrandRelationshipsService - return instance of OpportunityBrandRelationshipsServiceImpl
     */
    private static IOpportunityBrandRelationshipsService service() {
        return (IOpportunityBrandRelationshipsService) Application.SERVICE.newInstance(IOpportunityBrandRelationshipsService.class);
    }
}