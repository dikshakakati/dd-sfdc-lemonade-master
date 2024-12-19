/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Selector Class for Brief Object
 */
public inherited sharing class BriefsSelector extends fflib_SObjectSelector implements IBriefsSelector {
    /**
     * @description default constructor for the Briefs Selector class
     * @return IBriefsSelector - interface of IBriefsSelector
     */
    public static IBriefsSelector newInstance() {
        return (IBriefsSelector) Application.Selector.newInstance(Brief__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Brief object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> briefFields = new List<Schema.SObjectField>{
            Brief__c.Id,
            Brief__c.Name,
            Brief__c.CampaignName__c,
            Brief__c.Start_Date__c,
            Brief__c.End_Date__c,
            Brief__c.Are_All_Brief_Items_in_Campaign_Building__c,
            Brief__c.Opportunity_Name__c,
            Brief__c.SBQQ_Quote__c
        };
        return briefFields;
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Brief__c.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param briefIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectById(Set<Id> briefIds) {
        return (List<Brief__c>) selectSObjectsById(briefIds);
    }

    /**
     * @description This method is used for fetching Briefs by parent Account and related Campaigns.
     * @param accountIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory briefQuery = newQueryFactory()
            .selectField('Name')
            .setCondition('Opportunity_Name__r.AccountId IN :accountIds OR Agency_Opportunity_Name__r.AccountId IN :accountIds');

        new QuoteBriefRelationshipsSelector()
            .addQueryFactorySubselect(briefQuery, 'Quote_Brief_Relationships__r')
            .setCondition('Campaign_of_Brief__c != null AND Brief__c != null');
        return (List<Brief__c>) Database.query(briefQuery.toSOQL());
    }

    /**
     * @description This method is used for querying all Briefs with Quote Brief Relationships
     * related to Quotes associated with provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectByOpportunities(Set<Id> opportunityIds) {
        List<Schema.SObjectField> additionalFields = OpportunityToBriefMappingSelector.newInstance().getBriefFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Agency_Opportunity_Name__c');
        query.setCondition('Id IN (SELECT Brief__c FROM Quote_Brief_Relationship__c WHERE Quote__r.SBQQ__Opportunity2__c IN :opportunityIds)');
        return (List<Brief__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param briefIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectByIdIncludingAccountId(Set<Id> briefIds) {
        List<Schema.SObjectField> additionalFields = OpportunityToBriefMappingSelector.newInstance().getBriefFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Opportunity_Name__r.AccountId');
        query.selectField('Agency_Opportunity_Name__r.AccountId');
        query.setCondition('Id IN :briefIds');
        return (List<Brief__c>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for querying all Briefs with Opportunity Brief Relationships
     * provided set of opportunity Ids.
     * @param opportunityIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectByOpportunityBriefRelationship(Set<Id> opportunityIds) {
        List<Schema.SObjectField> additionalFields = OpportunityToBriefMappingSelector.newInstance().getBriefFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Agency_Opportunity_Name__c');
        query.selectField('Opportunity_Name__c');
        query.setCondition('Id IN (SELECT Brief__c FROM Opportunity_Brief_Relationship__c WHERE Opportunity__c IN :opportunityIds)');
        return (List<Brief__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method querys briefs with their primary vertical field
     * @param briefIds
     * @return List<Brief__c>
     */
    public List<Brief__c> selectBriefWithPrimaryVertical(Set<Id> briefIds) {
        List<Schema.SObjectField> additionalFields = OpportunityToBriefMappingSelector.newInstance().getBriefFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Primary_Vertical__c');
        query.setCondition('Id IN :briefIds');
        return (List<Brief__c>) Database.query(query.toSOQL());
    }
}