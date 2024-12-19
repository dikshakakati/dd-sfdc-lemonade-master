/**
 * @author Deloitte
 * @date 06/05/2022
 * @description Selector class for WorkStepDependency object.
 */
public inherited sharing class WorkStepDependenciesSelector extends fflib_SObjectSelector implements IWorkStepDependenciesSelector {
    private static final String AGGREGATE_DEPENDENCY_COUNT_QUERY_FIELDS = ', Dependee_Work_Step__r.Status__c dependeeStatus, Count(Id) dependenciesCount';
    private static final String AGGREGATE_DEPENDENCY_COUNT_QUERY_FILTER_CONDITION = ' IN :sObjectIds';
    private static final String DEPENDENCY_DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = ' groupingId';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_STATUS_FIELD = ', Dependee_Work_Step__r.Status__c';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM WorkStepDependency__c WHERE ';
    private static final Set<String> WORK_STEP_COMPLETE_STATUSES = new Set<String>{
        'Complete',
        'Complete - DoorDash to implement link',
        'Complete - Mx to implement link',
        'Complete - Implemented on the call'
    };
    private static final String WORK_STEP_DEAD_STATUS = 'Dead';

    /**
     * @description Default constructor for the WorkStepDependency selector class.
     * @return IWorkStepDependenciesSelector - interface of IWorkStepDependenciesSelector
     */
    public static IWorkStepDependenciesSelector newInstance() {
        return (IWorkStepDependenciesSelector) Application.Selector.newInstance(
            WorkStepDependency__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on WorkStepDependency__c object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkStepDependency__c.Id,
            WorkStepDependency__c.Dependee_Work_Step__c,
            WorkStepDependency__c.Dependent_Work_Step__c
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkStepDependency__c.SObjectType;
    }

    /**
     * @description It is used for getting count of WorkStepDependencies filtered by
     * passed sObjectIds and grouped by passed field.
     * @JIRA# LEM-1217
     * @param sObjectIds - Set of sObject Ids (WorkPlan/WorkStep)
     * @param fieldToFilter - Field used for filtering and grouping
     * @return Aggregate[]
     */
    public Aggregate[] getWorkStepDependencyCountFilteredAndGroupedBySobjectIds(
        Set<Id> sObjectIds,
        SObjectField fieldToFilter
    ) {
        String workStepDependencyQuery =
            SELECT_CLAUSE +
            fieldToFilter +
            DEPENDENCY_DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS +
            AGGREGATE_DEPENDENCY_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            fieldToFilter +
            AGGREGATE_DEPENDENCY_COUNT_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            fieldToFilter +
            AGGREGATE_COUNT_QUERY_GROUPBY_STATUS_FIELD;
        AggregateResult[] workStepDependencyAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workStepDependencyQuery)
        );
        return Aggregate.convertResults(workStepDependencyAggregateCountQueryResult);
    }

    /**
     * @description It fetches WorkStepDependencies where Dependent_Work_Step__c is
     * in the passed set of WorkStep Ids.
     * @JIRA# LEM-1142
     * @param sObjectIds - Set of WorkStep/WorkPlan Ids
     * @param fieldToFilter
     * @return List<WorkStepDependency__c>
     */
    public List<WorkStepDependency__c> selectDependeeWorkStepsByDependentSobjectIds(
        Set<Id> sObjectIds,
        SObjectField fieldToFilter
    ) {
        fflib_QueryFactory workStepDependencyQuery = newQueryFactory()
            .selectField('Dependee_Work_Step__r.Name')
            .selectField('Dependent_Work_Step__r.WorkPlanId')
            .setCondition(
                'Dependee_Work_Step__r.Status__c NOT IN :WORK_STEP_COMPLETE_STATUSES' +
                    ' AND ' +
                    'Dependee_Work_Step__r.Status__c != :WORK_STEP_DEAD_STATUS' +
                    ' AND ' +
                    fieldToFilter +
                    ' IN :sObjectIds'
            )
            .setOrdering(
                'Dependent_Work_Step__r.Work_Step_Sequence__c',
                fflib_QueryFactory.SortOrder.ASCENDING,
                true
            )
            .addOrdering(
                'Dependee_Work_Step__r.Work_Step_Sequence__c',
                fflib_QueryFactory.SortOrder.ASCENDING,
                true
            );
        return (List<WorkStepDependency__c>) Database.query(workStepDependencyQuery.toSOQL());
    }

    /**
     * @description It fetches WorkStepDependencies where Dependee_WorkStep__c is
     * in passed set of WorkStep Ids.
     * @JIRA# LEM-1142
     * @param dependeeWorkStepIds - Set of WorkStep Ids
     * @return List<WorkStepDependency__c>
     */
    public List<WorkStepDependency__c> selectDependenciesByDependeeWorkStepsIds(
        Set<Id> dependeeWorkStepIds
    ) {
        fflib_QueryFactory workStepDependencyQuery = newQueryFactory()
            .selectField('Dependent_Work_Step__r.Status__c')
            .setCondition('Dependee_Work_Step__c IN :dependeeWorkStepIds');
        return (List<WorkStepDependency__c>) Database.query(workStepDependencyQuery.toSOQL());
    }

    /**
     * @description It fetches WorkStepDependencies where Dependent_WorkStep__c is
     * in passed set of WorkStep Ids.
     * @JIRA# LEM-15575
     * @param dependentWorkStepIds - Set of WorkStep Ids
     * @return List<WorkStepDependency__c>
     */
    public List<WorkStepDependency__c> selectDependenciesByDependentWorkStepsIds(
        Set<Id> dependentWorkStepIds
    ) {
        fflib_QueryFactory workStepDependencyQuery = newQueryFactory()
            .selectField('Dependee_Work_Step__r.Status__c')
            .setCondition('Dependent_Work_Step__c IN :dependentWorkStepIds');
        return (List<WorkStepDependency__c>) Database.query(workStepDependencyQuery.toSOQL());
    }

    /**
     * @description It fetches WorkStepDependencies where Dependee_WorkStep__c's WorkOrder
     * or Dependent_Work_Step__r's WorkOrder is in the passed set of WorkOrder Ids.
     * @JIRA# LEM-2349
     * @param workOrderIds
     * @return List<WorkStepDependency__c>
     */
    public List<WorkStepDependency__c> selectDependenciesByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workStepDependencyQuery = newQueryFactory()
            .selectField('Id')
            .setCondition(
                'Dependee_Work_Step__r.WorkOrderId IN :workOrderIds OR' +
                ' Dependent_Work_Step__r.WorkOrderId IN :workOrderIds'
            );
        return (List<WorkStepDependency__c>) Database.query(workStepDependencyQuery.toSOQL());
    }
}