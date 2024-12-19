/**
 * @author Doordash
 * @date 04/01/2024
 * @description Selector class for Submarket__c record data.
 */
public inherited sharing class SubmarketsSelector extends fflib_SObjectSelector implements ISubmarketsSelector {
    /**
     * @description Default constructor for the SubmarketsSelector class.
     * @return ISubmarketsSelector - interface of ISubmarketsSelector
     */
    public static ISubmarketsSelector newInstance() {
        return (ISubmarketsSelector) Application.Selector.newInstance(Submarket__c.SObjectType);
    }

    /**
     * @description It is used for getting Submarket__c object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Submarket__c.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Submarket__c.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Submarket__c.Id,
            Submarket__c.Name,
            Submarket__c.Submarket_ID__c
        };
    }

    /**
     * @description It is used for retrieving all Submarket__c records by Submarket_ID__c and matching by Name.
     * @param subMarketId
     * @param subMarketName
     * @return List<Submarket__c>
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<Submarket__c> getSubmarketsByIdAndName(String subMarketId, String subMarketName) {
        String searchNameKeyMatcher = '%' + String.escapeSingleQuotes(subMarketName) + '%';
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Submarket_ID__c =: subMarketId AND Name LIKE: searchNameKeyMatcher');
        return (List<Submarket__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for retrieving all Submarket records by the passed submarketId.
     * @param submarketId
     * @return List<Submarket__c>
     */
    public List<Submarket__c> getSubmarketById(String submarketId) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Submarket_ID__c =: subMarketId')
            .setLimit(1);
        return (List<Submarket__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for retrieving all Submarket records by the passed submarketIds.
     * @param submarketIds
     * @return List<Submarket__c>
     */
    public List<Submarket__c> getSubmarketsByIds(Set<String> submarketIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Submarket_ID__c  IN :submarketIds');
        return (List<Submarket__c>) Database.query(query.toSOQL());
    }
}