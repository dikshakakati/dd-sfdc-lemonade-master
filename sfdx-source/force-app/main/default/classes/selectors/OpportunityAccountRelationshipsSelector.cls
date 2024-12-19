/**
 * @author Deloitte
 * @date 06/06/2022
 * @description Selector Class for Opportunity Account Relationship Object
 */
public inherited sharing class OpportunityAccountRelationshipsSelector extends fflib_SObjectSelector implements IOpportunityAccountRelationshipsSelector {
    /**
     * @description Default constructor for the Opportunity Account Relationships Selector class
     * @return IOpportunityAccountRelationshipsSelector - interface of IOpportunityAccountRelationshipsSelector
     */
    public static IOpportunityAccountRelationshipsSelector newInstance() {
        return (IOpportunityAccountRelationshipsSelector) Application.Selector.newInstance(
            Opportunity_Account_Relationship__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting the fields on Opportunity Account Relationship object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity_Account_Relationship__c.Id,
            Opportunity_Account_Relationship__c.Name,
            Opportunity_Account_Relationship__c.Account__c,
            Opportunity_Account_Relationship__c.Opportunity__c,
            Opportunity_Account_Relationship__c.Related_Account__c
        };
    }

    /**
     * @description This method is used for getting SObject type
     * @return Opportunity Account Relationship - Opportunity Account Relationship fields
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Account_Relationship__c.SObjectType;
    }

    /**
     * @description This method is sued to fetch records based on the Id
     * @param recordIds
     * @return List<Opportunity_Account_Relationship__c>
     */
    public List<Opportunity_Account_Relationship__c> selectById(Set<Id> recordIds) {
        return (List<Opportunity_Account_Relationship__c>) selectSObjectsById(recordIds);
    }

    /**
     * @description This method is used to fetch all Opportunity Account Relationship records filtered by Opportunity Ids.
     * @param parentOpportunityIds
     * @return List<Opportunity_Account_Relationship__c>
     */
    public List<Opportunity_Account_Relationship__c> fetchRelationshipsByParentOpportunities(
        Set<String> parentOpportunityIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Opportunity__c IN :parentOpportunityIds');
        return (List<Opportunity_Account_Relationship__c>) Database.query(query.toSOQL());
    }
}