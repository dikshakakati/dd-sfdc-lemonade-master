/**
 * @author Deloitte
 * @date 11/27/2022
 * @description Selector Class for Opportunity Brand Relationship Object
 */
public inherited sharing class OpportunityBrandRelationshipsSelector extends fflib_SObjectSelector implements IOpportunityBrandRelationshipsSelector {
    private static final String BUSINESS_ACCOUNT_NAME = 'Business';
    /**
     * @description Default constructor for the OpportunityBrandRelationshipsSelector class
     * @return IOpportunityBrandRelationshipsSelector - Interface of IOpportunityBrandRelationshipsSelector
     */
    public static IOpportunityBrandRelationshipsSelector newInstance() {
        return (IOpportunityBrandRelationshipsSelector) Application.Selector.newInstance(
            Opportunity_Brand_Relationship__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting the fields on Opportunity_Brand_Relationship__c
     * object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity_Brand_Relationship__c.Id,
            Opportunity_Brand_Relationship__c.Opportunity__c,
            Opportunity_Brand_Relationship__c.Brand__c
        };
    }

    /**
     * @description This method is used for getting object type
     * @return Opportunity Brand Relationship fields
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Brand_Relationship__c.SObjectType;
    }

    /**
     * @description This method is used to get the list of Opportunity_Brand_Relationship__c
     * for opportunities
     * @param opportunityIds
     * @return List<Opportunity_Brand_Relationship__c>
     */
    public List<Opportunity_Brand_Relationship__c> selectByOpportunity(Set<Id> opportunityIds) {
        fflib_QueryFactory relationshipQuery = newQueryFactory()
            .selectField('Brand__r.Brand_Name__c')
            .selectField('Opportunity__r.ContractId')
            .selectField('Brand__r.Brand_Name__r.Name')
            .setCondition('Opportunity__c IN :opportunityIds')
            .setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Opportunity_Brand_Relationship__c>) Database.query(relationshipQuery.toSOQL());
    }

    /**
     * @description Retrieves a list of Opportunity_Brand_Relationship__c records based on the provided Opportunity Id and Brand Association Id.
     * @param opportunityId The Id of the Opportunity.
     * @param brandAsscIds The Id of the Brand Association.
     * @return A list of Opportunity_Brand_Relationship__c records that match the given Opportunity Id and Brand Association Id.
     */
    public List<Opportunity_Brand_Relationship__c> selectByOpportunityAndBrandAsscs(Id opportunityId, Set<Id> brandAsscIds) {
        return (List<Opportunity_Brand_Relationship__c>) Database.query(
            newQueryFactory()
                .setCondition('Opportunity__c = :opportunityId AND Brand__c IN :brandAsscIds')
                .toSOQL()
        );
    }
}