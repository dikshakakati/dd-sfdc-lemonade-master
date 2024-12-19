/**
 * @author ATG
 * @date 10/24/2023
 * @description Selector class for Opportunity Brief Relationships object.
 */
public inherited sharing class OppBriefRelationshipsSelector extends fflib_SObjectSelector implements IOppBriefRelationshipsSelector{
    /**
     * @description default constructor for the Briefs Selector class
     * @return IOppBriefRelationshipsSelector - interface of IOppBriefRelationshipsSelector
     */
    public static IOppBriefRelationshipsSelector newInstance() {
        return (IOppBriefRelationshipsSelector) Application.Selector.newInstance(Opportunity_Brief_Relationship__c.SObjectType);
    }

    /**
     * @description It is used to fetch list of SObjectFields.
     * @return List<Schema.SObjectField> - returns list of sObject fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity_Brief_Relationship__c.Id,
            Opportunity_Brief_Relationship__c.Brief__c,
            Opportunity_Brief_Relationship__c.Opportunity__c
        };
    }

    /**
     * @description It provides the SObjectType for the object of the Selector.
     * @return Schema.SObjectType - returns sObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Opportunity_Brief_Relationship__c.SObjectType;
    }

    /**
     * @description This method is used for querying all Briefs with Quote Brief Relationships
     * related to Quotes associated with provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Opportunity_Brief_Relationship__c>
     */
    public List<Opportunity_Brief_Relationship__c> selectByOpportunities(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Opportunity__c');
        query.selectField('Brief__c');
        query.selectField('Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Type__c');
        query.setCondition('Opportunity__c IN :opportunityIds');
        return (List<Opportunity_Brief_Relationship__c>) Database.query(query.toSOQL());
    }

}