/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Selector class for Stakeholders.
 */
public with sharing class StakeholdersSelector extends fflib_SObjectSelector implements IStakeholdersSelector {
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'Initiative__c mxTouchpointId, COUNT(Id) stakeholdersCount';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :mxTouchpointIds';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD = 'Initiative__c';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM Stakeholder__c WHERE ';

    /**
     * @description Default constructor for the StakeholdersSelector class.
     * @return IStakeholdersSelector
     */
    public static IStakeholdersSelector newInstance() {
        return (IStakeholdersSelector) Application.Selector.newInstance(Stakeholder__c.SObjectType);
    }

    /**
     * @description It is used for getting Stakeholder__c object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Stakeholder__c.SObjectType;
    }

    /**
     * @description It is used for getting the fields of Stakeholder__c.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Stakeholder__c.Id,
            Stakeholder__c.Initiative__c,
            Stakeholder__c.Contact__c
        };
    }

    /**
     * @description It gets count of Stakeholders filtered by and grouped by
     * passed Mx Touchpoint Ids.
     * @JIRA# LEM-14667
     * @param mxTouchpointIds
     * @return Aggregate[]
     */
    public Aggregate[] getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
        Set<Id> mxTouchpointIds
    ) {
        String stakeholdersQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD +
            AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD;
        AggregateResult[] stakeholdersCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(stakeholdersQuery)
        );
        return Aggregate.convertResults(stakeholdersCountQueryResult);
    }

    /**
     * @description It fetches Stakeholders having Contacts by passed set of
     * Mx Touchpoint Ids.
     * @param mxTouchpointIds
     * @return List<Stakeholder__c>
     */
    public List<Stakeholder__c> getStakeholderContactsByMxTouchPointIds(Set<Id> mxTouchpointIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('User__c')
            .selectField('Initiative__r.Start_Date__c')
            .selectField('Initiative__r.End_Date__c')
            .selectField('Initiative__r.Type__c')
            .selectField('Initiative__r.Interaction_Type__c')
            .selectField('Initiative__r.OwnerId')
            .selectField('Initiative__c')
            .setCondition('Contact__c != null AND Initiative__c  IN: mxTouchpointIds');
        return (List<Stakeholder__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It fetches Stakeholders having users by passed set of
     * Mx Touchpoint Ids where User is not null
     * @param mxTouchpointIds
     * @return List<Stakeholder__c>
     */
    public List<Stakeholder__c> getStakeholderUsersByMxTouchPointIds(Set<Id> mxTouchpointIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('User__c')
            .selectField('Initiative__r.Start_Date__c')
            .selectField('Initiative__r.End_Date__c')
            .selectField('Initiative__r.Type__c')
            .selectField('Initiative__r.Interaction_Type__c')
            .selectField('Initiative__r.OwnerId')
            .selectField('Initiative__r.Status__c')
            .selectField('Initiative__r.Account_Segment__c')
            .selectField('Initiative__c')
            .setCondition('User__c != null AND Initiative__c  IN: mxTouchpointIds');
        return (List<Stakeholder__c>) Database.query(query.toSOQL());
    }
}