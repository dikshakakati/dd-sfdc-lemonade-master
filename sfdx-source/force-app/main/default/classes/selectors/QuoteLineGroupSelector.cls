/**
 * @author Deloitte
 * @date 07/09/2023
 * @description Selector Class for SBQQ__QuoteLineGroup__c Object
 */
public inherited sharing class QuoteLineGroupSelector extends fflib_SObjectSelector implements IQuoteLineGroupSelector {
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.SBQQ__QuoteLineGroup__c.FieldSets.Quote_Group_Clone_Fields;

    /**
     * @description New instance method to call application selector
     * @param SBQQ__QuoteLineGroup__c.SObjectType - SBQQ__QuoteLineGroup__c object type
     * @return IQuoteLineGroupSelector - interface of IQuoteLineGroupSelector
     */
    public static IQuoteLineGroupSelector newInstance() {
        return (IQuoteLineGroupSelector) Application.Selector.newInstance(
            SBQQ__QuoteLineGroup__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on SBQQ__QuoteLineGroup__c object
     * @return SBQQ__QuoteLineGroup__c object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SBQQ__QuoteLineGroup__c.Id,
            SBQQ__QuoteLineGroup__c.Name,
            SBQQ__QuoteLineGroup__c.SBQQ__Quote__c,
            SBQQ__QuoteLineGroup__c.SBQQ__Account__c
        };
    }

    /**
     * @description This method id for getting object type
     * @return SBQQ__QuoteLineGroup__c Object type
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__QuoteLineGroup__c.SObjectType;
    }

    /**
     * @description This method is for getting SBQQ__QuoteLineGroup__c based on the provided list of ids
     * @return Database.QueryLocator- DML operation result
     * @param groupRecIds - SBQQ__QuoteLineGroup__c Record Ids
     */
    public Map<Id, SBQQ__QuoteLineGroup__c> selectGroupRecords(Set<Id> groupRecIds) {
        Map<Id, SBQQ__QuoteLineGroup__c> groupMap = new Map<Id, SBQQ__QuoteLineGroup__c>();
        fflib_QueryFactory query = newQueryFactory();
        query.selectFieldSet(FIELDS_TO_QUERY);
        query.selectField('Name');
        query.setCondition('Id IN: groupRecIds');
        List<SBQQ__QuoteLineGroup__c> groupList = (List<SBQQ__QuoteLineGroup__c>) Database.query(
            query.toSOQL()
        );
        for (SBQQ__QuoteLineGroup__c groups : groupList) {
            groupMap.put(groups.id, groups);
        }
        return groupMap;
    }
    /**
     * @description This method is for getting SBQQ__QuoteLineGroup__c based on the provided list of ids
     * @return List<SBQQ__QuoteLineGroup__c>
     * @param quoteIds - SBQQ__QuoteLineGroup__c Record Ids
     */
    public List<SBQQ__QuoteLineGroup__c> selectGroupRecordsFromQuote(Set<Id> quoteIds) {
        fflib_QueryFactory groupQuery = newQueryFactory();
        groupQuery.selectFieldSet(FIELDS_TO_QUERY);
        groupQuery.setCondition('SBQQ__Quote__c IN :quoteIds AND SBQQ__Source__c != NULL');
        return (List<SBQQ__QuoteLineGroup__c>) Database.query(groupQuery.toSOQL());
    }

    /**
     * @description It is used query QuoteLineGroups by the passed Quote Ids.
     * @param quoteIds
     * @return List<SBQQ__QuoteLineGroup__c>
     */
    public List<SBQQ__QuoteLineGroup__c> selectQuoteLineGroupsByQuoteIds(Set<Id> quoteIds) {
        fflib_QueryFactory groupQuery = newQueryFactory()
            .setCondition('SBQQ__Quote__c IN :quoteIds ');
        return (List<SBQQ__QuoteLineGroup__c>) Database.query(groupQuery.toSOQL());
    }

    /**
     * @description This method is for getting SBQQ__QuoteLineGroup__c based on the provided list of ids
     * @param groupIds - SBQQ__QuoteLineGroup__c Record Ids
     * @param quotelineGroupFields - Quoteline Groups Fields list
     * @return List<SBQQ__QuoteLineGroup__c>
     */
    public List<SBQQ__QuoteLineGroup__c> selectQuoteLineGroupByGroupIdWithDynamicFields(
        Set<Id> groupIds,
        Set<String> quotelineGroupFields
    ) {
        fflib_QueryFactory groupQuery = newQueryFactory();
        if (quotelineGroupFields != null) {
            groupQuery.selectFields(quotelineGroupFields);
        }
        groupQuery.selectField('Name');
        groupQuery.setCondition('Id IN :groupIds');
        return (List<SBQQ__QuoteLineGroup__c>) Database.query(groupQuery.toSOQL());
    }
}