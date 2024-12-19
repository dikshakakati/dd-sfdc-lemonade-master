/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Selector Class for Brief Item Object
 */
public inherited sharing class BriefItemsSelector extends fflib_SObjectSelector implements IBriefItemsSelector {
    static final String STATUS_WAITING_FOR_INPUTS = 'Waiting for Inputs';
    /**
     * @description default constructor for the Brief Items Selector class
     * @return IBriefItemsSelector - interface of IBriefItemsSelector
     */
    public static IBriefItemsSelector newInstance() {
        return (IBriefItemsSelector) Application.Selector.newInstance(Brief_Item__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Brief Item object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {


        List<Schema.SobjectField> briefItemFields = new List<Schema.SObjectField>{
            Brief_Item__c.Id,
            Brief_Item__c.Brief__c,
            Brief_Item__c.Status__c,
            Brief_Item__c.Quote_Line__c,
            Brief_Item__c.Quote_Line_Id__c,
            Brief_Item__c.Opportunity_ID__c,
            Brief_Item__c.Start_Date__c,
            Brief_Item__c.End_Date__c

        };
        return briefItemFields;

    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Brief_Item__c.SObjectType;
    }

    /**
     * @description This method is used for fetching Brief Items related to the passed Brief Ids
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectByBriefAndStatus(Set<Id> briefIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Brief__c IN :briefIds AND Status__c = :STATUS_WAITING_FOR_INPUTS');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for fetching Brief Items related to the passed Brief Ids.
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectByBrief(Set<Id> briefIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Brief__c IN :briefIds');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }

     /**
     * @description This method is used for fetching Brief Items related to the passed Quote Line Items
     * @param quoteLineItemIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectByQuoteLineItems(Set<Id> quoteLineItemIds) {
        List<Schema.SObjectField> additionalFields = QuoteLineBriefItemMappingSelector.newInstance().getBriefItemFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
            query.setCondition('Quote_Line__c IN :quoteLineItemIds AND Quote_Line__r.Has_Brief_Item__c = true');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }
    /**
     * @description fetches brief items by opp Ids
     * @param oppIds
     * @return List<Brief_Item__C>
     */
    public List<Brief_Item__c> selectByOpportunities(Set<Id> oppIds){
        List<Schema.SObjectField> additionalFields = QuoteLineBriefItemMappingSelector.newInstance().getBriefItemFieldsList();
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.setCondition('Opportunity_ID__c IN :oppIds');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }
    /**
     * @description fetches brief Items by brief Item Ids
     * @param briefItemIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectByIds(Set<Id> briefItemIds){
        List<Schema.SObjectField> additionalFields = new List<Schema.SObjectField>();
        additionalFields.addAll(BriefItemTrackingSelector.newInstance().getAllTrackingFields().keySet());
        fflib_QueryFactory query = newQueryFactory();
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Opportunity_Owner__c.Email');
        query.selectField('Ops_Owner__c.Email');
        query.selectField('Owner.Email');
        query.selectField('Quote_Line__c');
        query.selectField('Name');
        query.selectField('Opportunity_Owner__c.Name');
        query.selectField('Campaign_Name__c');
        query.selectField('Account_Val__c');
        query.selectField('In_Campaign_Change__c');
        query.selectField('Quote_Line__c.SBQQ__Quote__c');
        query.selectField('Quote_Line__c.SBQQ__Quote__c.SBQQ__Account__c');
        query.setCondition('Id IN :briefItemIds');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to query brief items with fields required for setting
     * configuration field on associated brief
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectBriefItemsWithRoutingAndCustomCreative(Set<Id> briefIds){
        List<Schema.SObjectField> additionalFields = new List<Schema.SObjectField>();
        additionalFields.addAll(BriefItemTrackingSelector.newInstance().getAllTrackingFields().keySet());
        fflib_QueryFactory query = newQueryFactory().setCondition('Brief__c IN :briefIds');
        for(Schema.SObjectField field: additionalFields){
            query.selectField(field);
        }
        query.selectField('Custom_Creative_Required__c');
        query.selectField('Brief_Routing__c');
        query.selectField('Brief__c');
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used to query brief items with quote Ids
     * @param quoteIds
     * @return List<Brief_Item__c>
     */
    public List<Brief_Item__c> selectBriefItemsWithQuoteIds(Set<Id> quoteIds){
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Draft_Agency_Contract__c');
        query.selectField('Draft_Contract__c');
        query.selectField('Quote_Line__c');
        query.selectField('Quote_Line__r.SBQQ__Quote__c');
        query.selectField('Brief__r.Opportunity_Name__c');
        query.selectField('Brief__r.Opportunity_Name__r.Agency__c');
        query.setCondition(
            'Quote_Line__c != NULL ' +
            'AND Quote_Line__r.SBQQ__Quote__c != NULL ' +
            'AND Quote_Line__r.SBQQ__Quote__c IN :quoteIds'
        );
        return (List<Brief_Item__c>) Database.query(query.toSOQL());
    }
}