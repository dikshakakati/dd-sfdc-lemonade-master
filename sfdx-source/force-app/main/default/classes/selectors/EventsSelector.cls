/**
 * @author Deloitte
 * @date 06/11/2024
 * @description Selector class for Event object.
 */
public inherited sharing class EventsSelector extends fflib_SObjectSelector implements IEventsSelector {
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String AGGREGATE_EVENT_COUNT_QUERY_FIELDS = 'WhatId,COUNT(Id) countIds ';
    private static final String WHERE_CLAUSE = 'FROM Event WHERE ';
    private static final String AGGREGATE_EVENT_COUNT_QUERY_FILTER_CONDITION = 'WhatId IN :relatedToIds AND Event_Status__c =: eventStatus ';
    private static final String GROUP_BY_CLAUSE = 'GROUP BY ';
    private static final String AGGREGATE_EVENT_COUNT_QUERY_GROUPBY_FIELDS = 'WhatId ';

    /**
     * @description Default constructor for the class.
     * @return IEventsSelector
     */
    public static IEventsSelector newInstance() {
        return (IEventsSelector) Application.Selector.newInstance(Event.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Event.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id.
     * @param idSet
     * @return List<Event>
     */
    public List<Event> selectById(Set<Id> idSet) {
        return (List<Event>) selectSObjectsById(idSet);
    }

    /**
     * @description It is used to get the SObjectFields.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Event.Id,
            Event.OwnerId,
            Event.Event_Status__c,
            Event.WhoId,
            Event.WhatId,
            Event.Subject,
            Event.StartDateTime
        };
    }

    /**
     * @description It is used for get count of events by passing status and related Sobject Ids.
     * @param relatedToIds
     * @param eventStatus
     * @return Aggregate[]
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    // As we have provided FLS/CRUD access to queried fields/object, we don't need to check CRUD Access.
    public Aggregate[] selectCountOfEventsByStatusAndRelatedToIds(
        Set<Id> relatedToIds,
        String eventStatus
    ) {
        String eventQuery =
            SELECT_CLAUSE +
            AGGREGATE_EVENT_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_EVENT_COUNT_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_EVENT_COUNT_QUERY_GROUPBY_FIELDS;
        AggregateResult[] eventAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(eventQuery)
        );
        return Aggregate.convertResults(eventAggregateQueryResult);
    }

    /**
     * @description This method querying Events based on WhatId and WhoId
     * @param sObjectIds
     * @return List<Event>
     */
    public List<Event> selectByWhatIdAndWhoId(Set<Id> sObjectIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('WhatId IN :sObjectIds OR WhoId IN:sObjectIds ');
        return (List<Event>) Database.query(query.toSOQL());
    }
}