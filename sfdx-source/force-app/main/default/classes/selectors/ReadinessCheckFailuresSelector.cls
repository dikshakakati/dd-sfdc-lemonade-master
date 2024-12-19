/**
 * @author Deloitte
 * @date 07/19/2022
 * @description Selector class for Readiness Check Failure object.
 */
public inherited sharing class ReadinessCheckFailuresSelector extends fflib_SObjectSelector implements IReadinessCheckFailuresSelector {
    private static List<String> statuses = new List<String>{'Resolved'};
    private static string daysForReadinessFailureBatch  = System.Label.DaysForReadinessFailureBatch;
    private static dateTime days;
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'Child_Work_Order__c childWorkOrderId, COUNT(Id) readinessCheckFailuresCount';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :workOrderIds';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD = 'Child_Work_Order__c';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM Readiness_Check_Failure__c WHERE Status__c NOT IN : statuses AND ';

    /**
     * @description Default constructor for the ReadinessCheckFailuresSelector class.
     * @return IReadinessCheckFailuresSelector - instance of IReadinessCheckFailuresSelector
     */
    public static IReadinessCheckFailuresSelector newInstance() {
        return (IReadinessCheckFailuresSelector) Application.Selector.newInstance(
            Readiness_Check_Failure__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields of Readiness_Check_Failure__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Readiness_Check_Failure__c.Id };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Readiness_Check_Failure__c.SObjectType;
    }

    /**
     * @description It is used for getting count of Readiness Check Failures filtered by passed
     * WorkOrder Ids and grouped by passed WorkOrder Ids.
     * @JIRA# LEM-1684
     * @param workOrderIds
     * @return Aggregate[]
     */
    public Aggregate[] getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
        Set<Id> workOrderIds
    ) {
        String readinessCheckFailureQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD +
            AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD;
        AggregateResult[] readinessCheckFailuresCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(readinessCheckFailureQuery)
        );
        return Aggregate.convertResults(readinessCheckFailuresCountQueryResult);
    }

    /**
     * @description It queries Readiness Check Failures by the passed child WorkOrder Ids.
     * @JIRA# LEM-2455 @jira LEM-13963
     * @param workOrderIds
     * @return List<Readiness_Check_Failure__c>
     */
    public List<Readiness_Check_Failure__c> selectByChildWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory readinessCheckFailureQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Account_Name__c')
            .selectField('Child_Work_Order__c')
            .selectField('Parent_Work_Order__c')
            .selectField('Error_Message__c')
            .selectField('Object_Name__c')
            .selectField('Field_Name__c')
            .selectField('Status__c')
            .setCondition('Child_Work_Order__c IN :workOrderIds' + ' AND Status__c NOT IN : statuses');
        return (List<Readiness_Check_Failure__c>) Database.query(
            readinessCheckFailureQuery.toSOQL()
        );
    }

    /**
     * @description It queries Readiness Check Failures by the passed parent WorkOrder Ids.
     * @JIRA# LEM-1684 @jira LEM-13963
     * @param parentWorkOrderIds
     * @return List<Readiness_Check_Failure__c>
     */
    public List<Readiness_Check_Failure__c> selectByParentWorkOrderIds(Set<Id> parentWorkOrderIds) {
        fflib_QueryFactory readinessCheckFailureQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Account_Name__c')
            .selectField('Account_Name__r.Name')
            .selectField('Child_Work_Order__c')
            .selectField('Parent_Work_Order__c')
            .selectField('Error_Message__c')
            .selectField('Object_Name__c')
            .selectField('Field_Name__c')
            .selectField('Fix_Error_Link__c')
            .selectField('Object_Link__c')
            .selectField('Status__c')
            .setCondition('Parent_Work_Order__c IN :parentWorkOrderIds'+ ' AND Status__c NOT IN : statuses');
        return (List<Readiness_Check_Failure__c>) Database.query(
            readinessCheckFailureQuery.toSOQL()
        );
    }

    /**
     * @description It is used to get the Readiness Check Failure Record.
     * Status is equal to Resolved and createddate less than week.
     * @JIRA# LEM-13963
     * @return List<Readiness_Check_Failure__c>
     */

    public List<Readiness_Check_Failure__c> selectByReadinessCheckFailureId() {
        Integer lastNdays;
        if(integer.valueof(daysForReadinessFailureBatch) > 1){
            lastNdays = integer.valueof(daysForReadinessFailureBatch);
        }else{
            lastNdays = 7;
        }
        days = System.now().addDays(-(lastNdays));
        fflib_QueryFactory readinessCheckFailureQuery = newQueryFactory()
            .setCondition('Status__c IN : statuses AND CreatedDate <: days' );
        return (List<Readiness_Check_Failure__c>) Database.query(
            readinessCheckFailureQuery.toSOQL()
        );
    }
}