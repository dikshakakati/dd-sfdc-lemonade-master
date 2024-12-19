/**
 * @author Deloitte
 * @date 12/21/2022
 * @description Selector class for Quote Brief Relationships object.
 */
public inherited sharing class QuoteBriefRelationshipsSelector extends fflib_SObjectSelector implements IQuoteBriefRelationshipsSelector {
    /**
     * @description Default constructor for the class.
     * @return IQuoteBriefRelationshipsSelector - interface of QuoteBriefRelationshipsSelector
     */
    public static IQuoteBriefRelationshipsSelector newInstance() {
        return (IQuoteBriefRelationshipsSelector) Application.Selector.newInstance(
            Quote_Brief_Relationship__c.SObjectType
        );
    }

    /**
     * @description It is used to fetch list of SObjectFields.
     * @return List<Schema.SObjectField> - returns list of sObject fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Quote_Brief_Relationship__c.Id,
            Quote_Brief_Relationship__c.Brief__c,
            Quote_Brief_Relationship__c.Campaign_of_Brief__c,
            Quote_Brief_Relationship__c.Quote__c,
            Quote_Brief_Relationship__c.Account__c
        };
    }

    /**
     * @description It provides the SObjectType for the object of the Selector.
     * @return Schema.SObjectType - returns sObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Quote_Brief_Relationship__c.SObjectType;
    }

    /**
     * @description It is used to fetch Quote Brief Relationships by Id
     * @param quoteBriefRelationshipIds
     * @return List<Quote_Brief_Relationship__c>
     */
    public List<Quote_Brief_Relationship__c> selectById(Set<Id> quoteBriefRelationshipIds){
        return (List<Quote_Brief_Relationship__c>) selectSObjectsById(quoteBriefRelationshipIds);
    }
}