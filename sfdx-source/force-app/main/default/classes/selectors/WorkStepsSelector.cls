/**
 * @author Deloitte
 * @date 30/03/2022
 * @description Selector class for WorkStep object.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class WorkStepsSelector extends fflib_SObjectSelector implements IWorkStepsSelector {
    private static final Set<String> ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS = new Set<String>{
        'Android Tablet (Merchant Owns)',
        'POS and Tablet (Merchant Owns)'
    };
    private static final Set<String> NON_COMPLETE_STATUS = new Set<String>{ 'Complete', 'Dead' };
    private static final Set<String> WORK_ORDER_TYPES_MARKETPLACE = new Set<String>{
        'Marketplace',
        'Marketplace + Self Delivery',
        'Self Delivery',
        'Storefront'
    };

    private static final Set<String> WORK_ORDER_TYPES_COO = new Set<String>{ 'COO' };
    private static final String AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FIELDS = ' Parent_Work_Step__c parentWorkStepId, Status__c workStepStatus, Count(Id) workStepsCount';
    private static final String AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FILTER_CONDITION = 'Parent_Work_Step__c IN :parentIds AND (Status__c = :STATUS_BLOCKED OR Status__c = :STATUS_RESOLVED)';
    private static final String AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FILTER_CONDITION_BY_WORK_ORDER = ' WorkOrderId IN (SELECT Id From WorkOrder WHERE (ParentWorkOrderId = :workOrderId OR ( Id =: workOrderId AND Type__c =: WORK_ORDER_TYPE_DRIVE AND ParentWorkOrderId = null ))) AND (Status__c = :STATUS_BLOCKED OR Status__c = :STATUS_ESCALATED)';
    private static final String AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_GROUPBY_FIELDS = 'Parent_Work_Step__c, Status__c';
    private static final String AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_GROUPBY_STATUS = 'Status__c';
    private static final String AGGREGATE_QUERY_FIELDS = ' parentId,Status workStepStatus, Count(Id) workStepsCount';
    private static final String AGGREGATE_QUERY_FIELDS_FOR_WORK_STEP = ' Status__c workStepStatus, Count(Id) workStepsCount';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :parentIds';
    private static final String AGGREGATE_QUERY_GROUPBY_FIELDS = ',Status';
    private static final String AGGREGATE_QUERY_OPERATOR = ' AND ';
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_GONE_DARK = 'Gone Dark';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_RESOLVED = 'Resolved';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final Set<String> STATUS_BLOCKED_GONE_DARK = new Set<String>{
        STATUS_BLOCKED,
        STATUS_GONE_DARK
    };
    private static final Set<String> DELIVER_TABLET_APPLICABLE_WORK_STEP_STATUSES = new Set<String>{
        STATUS_NOT_STARTED,
        STATUS_NOT_WORKABLE
    };
    private static final String WHERE_CLAUSE = ' FROM WorkStep WHERE ';
    private static final Set<String> WORK_ORDER_PRIORITY_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_DELIVER_RETURN_LABEL = 'Deliver Return Label';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_LINK_IMPLEMENTATION = 'Link Implementation';
    private static final String WORK_STEP_TYPE_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT = 'Setup Storefront Page';
    private static final Set<String> WORK_STEP_IMPLEMENTATION_TYPES = new Set<String>{
        WORK_STEP_TYPE_IMPLEMENTATION_CALL,
        WORK_STEP_TYPE_LINK_IMPLEMENTATION
    };

    /**
     * @description Default constructor for the WorkSteps selector class.
     * @return IWorkStepsSelector
     */
    public static IWorkStepsSelector newInstance() {
        return (IWorkStepsSelector) Application.Selector.newInstance(WorkStep.SObjectType);
    }

    /**
     * @description It is used for getting the fields on WorkStep object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkStep.Id,
            WorkStep.Name,
            WorkStep.Number_of_Blocked_Work_Steps__c,
            WorkStep.Parent_Work_Step__c,
            WorkStep.Provisioning_Failure_Date_Time__c,
            WorkStep.Secondary_Email_Next_Schedule__c,
            WorkStep.Secondary_Email_Timer_Start_Time__c,
            WorkStep.Status,
            WorkStep.Status__c,
            WorkStep.WorkPlanId,
            WorkStep.WorkOrderId,
            WorkStep.Business_Reference__c,
            WorkStep.Status_Reason__c,
            WorkStep.Store_Account__c,
            WorkStep.Type__c
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkStep.SObjectType;
    }

    /**
     * @description It is used for getting count of Blocked and Resolved child WorkSteps
     * filtered by parentId and grouped by parentId and Status.
     * @JIRA# LEM-2043
     * @param parentIds - set of parent Work Step Ids
     * @return Aggregate[]
     */
    public Aggregate[] getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(
        Set<Id> parentIds
    ) {
        String workStepQuery =
            SELECT_CLAUSE +
            AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_GROUPBY_FIELDS;
        AggregateResult[] workStepAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workStepQuery)
        );
        return Aggregate.convertResults(workStepAggregateQueryResult);
    }

    /**
     * @description It is used to get WorkSteps details by
     * passed set of store Account Ids.
     * @JIRA# LEM-1087
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> getDeliverTabletWorkStepsDetailsByStoreAccount(Set<Id> storeAccountIds) {
        fflib_QueryFactory query = newQueryFactory(false);
        query.selectField('Id');
        query.selectField('WorkOrderId');
        query.selectField('Work_Order_Type__c');
        query.selectField('Figment_Id__c');
        query.setCondition(
            'Type__c = :WORK_STEP_TYPE_DELIVER_TABLET AND Store_Account__c IN :storeAccountIds' +
                ' AND Store_Account__r.Order_Protocol__c NOT IN :ACCOUNT_ORDER_PROTOCOL_MERCHANT_OWNS' +
                ' AND Status IN :DELIVER_TABLET_APPLICABLE_WORK_STEP_STATUSES'
        );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get WorkSteps details by
     * passed set of store Account Ids.
     * @JIRA# LEM-2181
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('WorkOrder.Type__c');
        query.selectField('WorkOrder.Provisioning_Status__c');
        query.selectField('WorkOrder.Status');
        query.selectField('WorkPlan.Business_Reference__c');
        query.setCondition(
            'Type__c = :WORK_STEP_TYPE_SETUP_BUSINESS AND Store_Account__c IN :storeAccountIds' +
            ' AND Status NOT IN :NON_COMPLETE_STATUS AND WorkOrder.Type__c in :WORK_ORDER_TYPES_MARKETPLACE'
        );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to query WorkSteps by the passed storeAccountIds and work step types.
     * @JIRA# LEM-15834
     * @param storeAccountIds
     * @param workSteptypes
     * @return List<WorkStep>
     */
    public List<WorkStep> selectWorkStepsByTypesAndStoreAccountIds(
        Set<Id> storeAccountIds,
        Set<String> workSteptypes
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Status')
            .selectField('WorkOrderId')
            .selectField('Store_Account__c')
            .setCondition('Type__c IN :workSteptypes AND Store_Account__c IN :storeAccountIds');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to get WorkSteps' details for COO
     * passed set of Store Account Ids.
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('WorkOrder.Type__c');
        query.selectField('WorkOrder.Provisioning_Status__c');
        query.selectField('WorkOrder.Status');
        query.selectField('WorkPlan.Business_Reference__c');
        query.setCondition(
            'Type__c = :WORK_STEP_TYPE_SETUP_BUSINESS AND Store_Account__c IN :storeAccountIds' +
            ' AND Status NOT IN :NON_COMPLETE_STATUS AND WorkOrder.Type__c in :WORK_ORDER_TYPES_COO'
        );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get WorkSteps details by
     * passed set of store Account Ids.
     * @JIRA# LEM-2203
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> getNonCompleteSetupStoreWorkStepsByStoreAccount(Set<Id> storeAccountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('WorkOrder.Type__c');
        query.selectField('WorkOrder.Sub_Type__c');
        query.selectField('WorkOrder.Provisioning_Status__c');
        query.selectField('WorkOrder.Status');
        query.selectField('WorkOrder.Bundled_with_Marketplace__c');
        query.selectField('WorkPlan.Business_Reference__c');
        query.selectField('WorkOrder.Segment__c');
        query.setCondition(
            '((Type__c = :WORK_STEP_TYPE_SETUP_STORE) OR ' +
                '(Type__c = :WORK_STEP_TYPE_SETUP_BUSINESS) OR ' +
                '(Type__c = :WORK_STEP_TYPE_SETUP_STOREFRONT) OR ' +
                ' ((WorkOrder.Type__c = :WORK_ORDER_TYPE_POST_SALES)' +
                ' AND (WorkOrder.Sub_Type__c = :WORK_ORDER_SUBTYPE_RATE_CHANGE)) )' +
                ' AND Store_Account__c IN :storeAccountIds' +
                ' AND Status NOT IN :NON_COMPLETE_STATUS'
        );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to get WorkSteps details by
     * passed set of store Account Ids.
     * @JIRA# LEM-3166
     * @param storeAccountIds
     * @return List<WorkStep>
     * TODO: Product Provisioning - getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore &
     * getNonCompleteWorkStepRecForDriveByBusinessAccount methods needs to be combined.
     */
    public List<WorkStep> getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('WorkOrder.Sub_Type__c')
            .selectField('WorkOrder.Provisioning_Status__c')
            .selectField('WorkOrder.Status')
            .selectField('WorkOrder.AccountID')
            .selectField('WorkOrder.Business_to_Store_Assignment__c')
            .selectField('WorkPlan.Business_Reference__c')
            .selectField('Start_Date_Time__c')
            .setCondition(
                ' Store_Account__c IN :storeAccountIds' + ' AND Status NOT IN :NON_COMPLETE_STATUS'
            );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to get WorkSteps details by
     * passed set of Store Account.
     * @JIRA# LEM-3166
     * @param businessAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> getNonCompleteWorkStepRecForDriveByBusinessAccount(
        Set<Id> businessAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('WorkOrder.Sub_Type__c')
            .selectField('WorkOrder.Provisioning_Status__c')
            .selectField('WorkOrder.Status')
            .selectField('WorkOrder.AccountID')
            .selectField('WorkOrder.Business_to_Store_Assignment__c')
            .selectField('WorkOrder.Withholding_with_Auto_Activations__c')
            .selectField('Business_Reference__r.Last_Completed_Step__c')
            .selectField('Start_Date_Time__c')
            .setCondition(
                'WorkOrder.AccountId IN :businessAccountIds AND Status NOT IN :NON_COMPLETE_STATUS'
            );
        return (List<WorkStep>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for getting count of WorkSteps filtered by passed condition and
     * parentId and grouped by passed field and Status.
     * @JIRA# LEM-582
     * @param condition
     * @param groupByField
     * @param parentIds
     * @return Aggregate[]
     */
    public Aggregate[] getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
        String condition,
        String groupByField,
        Set<Id> parentIds
    ) {
        String workStepQuery =
            SELECT_CLAUSE +
            groupByField +
            AGGREGATE_QUERY_FIELDS +
            WHERE_CLAUSE +
            groupByField +
            AGGREGATE_QUERY_FILTER_CONDITION;
        workStepQuery += String.isBlank(condition) ? '' : AGGREGATE_QUERY_OPERATOR + condition;
        workStepQuery += GROUP_BY_CLAUSE + groupByField + AGGREGATE_QUERY_GROUPBY_FIELDS;
        AggregateResult[] workStepAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workStepQuery)
        );
        return Aggregate.convertResults(workStepAggregateQueryResult);
    }

    /**
     * @description It is used to get WorkSteps by passed Ids.
     * @JIRA# LEM-2045
     * @param workStepIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectById(Set<Id> workStepIds) {
        return (List<WorkStep>) selectSObjectsById(workStepIds);
    }

    /**
     * @description It is used to get WorkSteps by passed Ids.
     * @param workStepIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectByIds(Set<Id> workStepIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('WorkPlanId')
            .selectField('WorkPlan.Parent_Work_Plan__c')
            .selectField('WorkPlan.Activation_Checklist_Validation__c')
            .selectField('WorkPlan.Last_Validation_Execution__c')
            .selectField('WorkPlan.WorkOrder.ParentWorkOrder.Proposed_Date_of_Activation__c')
            .selectField('WorkPlan.WorkOrderId')
            .selectField('Parent_Work_Step__c')
            .selectField('Parent_Work_Step__r.WorkPlanId')
            .selectField('WorkPlan.WorkOrder.ParentWorkOrder.Proposed_Date_of_Activation__c')
            .selectField('WorkPlan.WorkOrder.Status')
            .selectField('Store_Account__c')
            .selectField('Status__c')
            .selectField('Parent_Work_Step__r.Status__c')
            .selectField('Parent_Work_Step__r.WorkOrderId')
            .selectField('Status_Reason__c')
            .setCondition('Id IN :workStepIds');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query child WorkSteps by the passed parent WorkStep Ids.
     * @JIRA# LEM-530
     * @param parentWorkStepIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildWorkStepsByParentWorkStepIds(Set<Id> parentWorkStepIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Parent_Work_Step__c')
            .selectField('Parent_Work_Step__r.Status__c')
            .selectField('Parent_Work_Step__r.Status_Reason__c')
            .selectField('Parent_Work_Step__r.WorkPlanId')
            .selectField('Status__c')
            .selectField('Status_Reason__c')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Status')
            .selectField('WorkOrder.Store_Account_Activation_Status__c')
            .setCondition('Parent_Work_Step__c IN :parentWorkStepIds')
            .addOrdering('Parent_Work_Step__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query child Activation Checklist WorkSteps by the passed parent WorkStep Ids.
     * @JIRA# LEM-13305
     * @param parentWorkStepIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildActivationChecklistWorkStepsByParentWorkStepIds(
        Set<Id> parentWorkStepIds
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Parent_Work_Step__c')
            .selectField('Parent_Work_Step__r.WorkPlanId')
            .selectField('Store_Account__c')
            .selectField('WorkPlan.Business_ID__c')
            .selectField('WorkPlan.Xref__c')
            .selectField('WorkPlan.Xref__r.Business_Reference__c')
            .selectField('WorkPlan.Xref__r.External_ID__c')
            .setCondition('Parent_Work_Step__c IN :parentWorkStepIds')
            .addOrdering('Parent_Work_Step__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to get "Link Implementation" WorkSteps attached to passed WorkPlans
     * where Status is not Complete.
     * @JIRA# LEM-1115
     * @param workPlanIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectLinkImplementationWorkStepAttachedToWorkPlan(Set<Id> workPlanIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory()
            .selectField(WorkStep.Status__c)
            .selectField(WorkStep.Type__c)
            .setCondition(
                'Type__c IN :WORK_STEP_IMPLEMENTATION_TYPES AND WorkPlanId IN :workPlanIds'
            )
            .addOrdering('WorkPlanId', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('Type__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query first Work Step in execution order for Storefront
     * Work Order filtered by the passed store Account Ids.
     * @JIRA# LEM-2132
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectFirstStorefrontWorkStepByStoreAccountIds(Set<Id> storeAccountIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField(WorkStep.Parent_Work_Step__c)
            .selectField(WorkStep.Status__c)
            .setCondition(
                'ExecutionOrder = :EXECUTION_ORDER_FIRST' +
                    ' AND Store_Account__c IN :storeAccountIds' +
                    ' AND WorkOrder.Type__c = :WORK_ORDER_TYPE_STOREFRONT'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query WorkSteps by the passed parent WorkOrder Ids.
     * @JIRA# LEM-2193
     * @param workOrderIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectWorkStepsByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Type__c')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Sub_Type__c')
            .selectField('WorkPlanTemplateEntry__c')
            .selectField('WorkPlan.WorkOrderId')
            .selectField('Store_Account__c')
            .setCondition('WorkOrderId IN :workOrderIds');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query WorkSteps by the passed parent WorkOrder Ids.
     * @JIRA# LEM-5343
     * @param workOrderIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectWorkStepsAllFieldsByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory()
            .selectField('Type__c')
            .selectField('ExecutionOrder')
            .selectField('WorkPlanTemplateEntry__c')
            .selectField('Parent_Work_Step__c')
            .setCondition('WorkOrderId IN :workOrderIds');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query child Work Steps using the passed store Account Ids and
     * Work Plan Ids.
     * LEM-4892 Added Type check to fetch 'Deliver Tablet' Work Step details.
     * LEM-13492 Added Type check to fetch 'Setup Menu' Work Step details.
     * @param storeAccountIds
     * @param workOrderIds
     * @param workStepTypes
     * @JIRA# LEM-4524
     * @return List<WorkStep>
     */
    public List<WorkStep> selectByStoreAccountAndWorkOrderIds(
        Set<Id> storeAccountIds,
        Set<Id> workOrderIds,
        Set<String> workStepTypes
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.ParentWorkOrderId')
            .setCondition(
                'Store_Account__c IN :storeAccountIds AND' +
                    ' Type__c IN :workStepTypes AND' +
                    ' (WorkOrderId IN :workOrderIds' +
                    ' OR WorkOrder.ParentWorkOrderId IN :workOrderIds) AND' +
                    ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query all child Work Steps for the passed Parent WorkOrder Ids
     * @param parentWorkOrderIDs
     * @return List<WorkStep>
     */
    public List<WorkStep> selectAllChildWorkStepsByParentWorkOrderID(Set<Id> parentWorkOrderIDs) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkplanId')
            .selectField('WorkorderId')
            .selectField('Workorder.AccountId')
            .setCondition(
                'WorkOrder.parentWorkOrderID IN : parentWorkOrderIDs AND' +
                ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query all child Work Steps for StoreAccount by BatchID
     * @param storeAccountIds
     * @param batchIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndBatchId(
        Set<Id> storeAccountIds,
        Set<String> batchIds
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkplanId')
            .selectField('WorkorderId')
            .selectField('WorkOrder.AccountId')
            .selectField('Workorder.ParentWorkOrderID')
            .selectField('Workorder.ParentWorkOrder.Opportunity__c')
            .selectField('Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c')
            .setCondition(
                'Workorder.ParentWorkOrder.Opportunity__c != null AND ' +
                    'Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c != null AND ' +
                    'Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c IN :batchIds AND ' +
                    'Workorder.AccountId IN :storeAccountIds AND' +
                    ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query all child Work Steps for StoreAccount by Type and BatchID
     * @param storeAccountIds
     * @param type
     * @param batchIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(
        Set<Id> storeAccountIds,
        Set<String> type,
        Set<String> batchIds
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkplanId')
            .selectField('WorkorderId')
            .selectField('Status__c')
            .selectField('Workorder.AccountId')
            .selectField('Workorder.ParentWorkOrderID')
            .selectField('Workorder.ParentWorkOrder.Opportunity__c')
            .selectField('Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c')
            .setCondition(
                'Workorder.ParentWorkOrder.Opportunity__c != null AND ' +
                    'Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c != null AND ' +
                    'Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c IN :batchIds AND ' +
                    'Workorder.AccountId IN :storeAccountIds AND' +
                    ' Type__c IN :type AND' +
                    ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query child Work Steps for the passed store Account Ids and Type
     * @param storeAccountIds
     * @param type
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndType(
        Set<Id> storeAccountIds,
        Set<String> type
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkplanId')
            .selectField('WorkorderId')
            .selectField('Workorder.ParentWorkOrder.Opportunity__r.Batch_Id__c')
            .selectField('Workorder.Sub_Type__c')
            .selectField('Workorder.AccountId')
            .setCondition(
                'Workorder.AccountId IN :storeAccountIds AND' +
                    ' Type__c IN :type AND' +
                    ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query Work Steps which have Blocked status using the passed Work Order Ids.
     * @param workOrderIds
     * @param statuses
     * @JIRA# LEM-9934
     * @return List<WorkStep>
     */
    public List<WorkStep> selectWorkStepsByWorkOrderIdsAndStatuses(
        Set<Id> workOrderIds,
        Set<String> statuses
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__r.Name')
            .selectField('WorkPlanId')
            .selectField('WorkPlan.Name')
            .selectField('WorkPlan.Xref__r.Name')
            .selectField('WorkPlan.Xref__c')
            .selectField('WorkOrder.Store_Id__c')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.MINT_Store_Page__c')
            .selectField('Name')
            .selectField('Status__c')
            .selectField('Status_Reason__c')
            .selectField('Status_Reason_Details__c')
            .setCondition('WorkOrderId IN :workOrderIds AND Status__c IN :statuses');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used for getting count of WorkSteps filtered by WorkOrder and Status
     * @JIRA# LEM-11935
     * @param workOrderId
     * @return Aggregate[]
     */
    public Aggregate[] getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus(
        Id workOrderId
    ) {
        String workStepQuery =
            SELECT_CLAUSE +
            AGGREGATE_QUERY_FIELDS_FOR_WORK_STEP +
            WHERE_CLAUSE +
            AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_FILTER_CONDITION_BY_WORK_ORDER +
            GROUP_BY_CLAUSE +
            AGGREGATE_CHILD_WORK_STEP_COUNT_QUERY_GROUPBY_STATUS;
        AggregateResult[] workStepAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workStepQuery)
        );
        return Aggregate.convertResults(workStepAggregateQueryResult);
    }

    /**
     * @description It is used for retrieving Work steps based on parent Work Order Id & its work plan names
     * @param parentWorkOrderId
     * @param workPlanNames
     * @return List<WorkStep>
     */
    public List<WorkStep> selectWorkStepsByParentWorkOrderAndPlanName(
        Id parentWorkOrderId,
        List<String> workPlanNames
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .setCondition(
                'workorder.parentWorkorderId  = :parentWorkOrderId AND WorkPlan.Name IN :workPlanNames and Status NOT IN: NON_COMPLETE_STATUS'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query child Work Steps for the passed WorkPlan based on Work Step name.
     * @param workPlanId
     * @param workStepName
     * @return List<WorkStep>
     */
    public List<WorkStep> selectChildWorkStepsByWorkPlan(Id workPlanId, String workStepName) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Store_Account__c')
            .selectField('WorkplanId')
            .selectField('WorkorderId')
            .selectField('Workorder.AccountId')
            .setCondition(
                'WorkplanId = :workPlanId AND Name = :workStepName AND WorkOrder.Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query the Deliver Tablet WorkSteps by the passed parent
     * WorkOrder Ids.
     * @JIRA# LEM-13511
     * @param workOrderIds
     * @param types
     * @return List<WorkStep>
     */
    public List<WorkStep> selectReturnLabelWorkStepsByWorkOrderIdsAndType(
        Set<Id> workOrderIds,
        Set<String> types
    ) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Type__c')
            .selectField('WorkOrderId')
            .selectField('WorkPlanId')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Sub_Type__c')
            .selectField('WorkPlan.Parent_Work_Plan__c')
            .setCondition('WorkOrderId IN :workOrderIds AND Type__c IN :types');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query Work Steps by the passed parent Work Plan Ids.
     * @JIRA# LEM-14124
     * @param workPlanIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectByWorkPlanIds(Set<Id> workPlanIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('WorkPlanId')
            .setCondition('WorkPlanId IN :workPlanIds');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

    /**
     * @description It is used to query Work Steps by the passed parent Work Plan Ids.
     * @JIRA# LEM-13576
     * @param workPlanIds
     * @return List<WorkStep>
     */
    public List<WorkStep> selectEscalatedOrBlockedByWorkPlanIds(Set<Id> workPlanIds) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('WorkPlanId')
            .selectField('Status')
            .setCondition('WorkPlanId IN :workPlanIds and Status IN :STATUS_BLOCKED_GONE_DARK');
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }

     /**
     * @description It is used to query all child Work Steps for the passed Parent WorkOrder Ids if
     * Work Plan is dead and WS are not dead
     * @param workOrderIDs
     * @param wpName
     * @return List<WorkStep>
     */
    public List<WorkStep> selectAllChildWorkStepsByWorkOrderIDToDeadOut(Set<Id> workOrderIDs,String wpName) {
        fflib_QueryFactory workStepQuery = newQueryFactory(false)
            .selectField('Id')
            .setCondition(
                ' WorkOrderId IN : workOrderIDs AND' +
                ' WorkPlan.Name =: wpName AND ' +
                ' WorkPlan.Status__c =: STATUS_DEAD AND' +
                ' Status != :STATUS_DEAD'
            );
        return (List<WorkStep>) Database.query(workStepQuery.toSOQL());
    }
}