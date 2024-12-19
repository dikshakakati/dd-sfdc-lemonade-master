/**
 * @author Deloitte
 * @date 04/11//2022
 * @description Selector class for WorkOrder object.
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public inherited sharing class WorkOrdersSelector extends fflib_SObjectSelector implements IEncryptedDataSelector, IWorkOrdersSelector, IWorkObjectsSyncSelector {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS = System.Label.BusinessAccountRecordTypeName;
    private static final String ACCOUNT_RECORD_TYPE_DEVELOPERNAME_STORE = System.Label.StoreAccountRecordTypeName;
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'AccountId parentAccountId, COUNT(Id) workOrdersCount';
    private static final String AGGREGATE_COUNT_QUERY_FIELDS_ACCOUNTID = 'ParentWorkOrderId parentWorkOrderId, COUNT_DISTINCT(AccountId) uniqueStoreCount';
    private static final String AGGREGATE_COUNT_QUERY_ON_PROVISIONING_STATUS_FIELDS = 'COUNT(Id) childWorkOrderCount, ParentWorkOrderId parentWorkOrderId, Provisioning_Status__c provisioningStatus';
    private static final String AGGREGATE_COUNT_QUERY_ON_STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS = System.Label.Store_Level_Work_Plans_Indicator_Fields_Aggregate_Count_Query_Select_Clause;
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :workOrderAccountIds AND Type__c = :WORK_ORDER_TYPE_MARKETPLACE';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION_PARENTWORKORDERID = ' IN: parentWorkOrderIds';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION_PARENTWORKORDERID_AND_STOREACCOUNTRECORDTYPE = ' IN :parentWorkOrderIds AND Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_DEVELOPERNAME_STORE';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD = 'AccountId';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTWORKORDERID = 'ParentWorkOrderId';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTWORKORDERID_AND_PROVISIONINGSTATUS = 'ParentWorkOrderId, Provisioning_Status__c';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS = System.Label.Store_Level_Work_Plans_Indicator_Fields_Aggregate_Count_Query_Group_By_Clause;
    private static final String AGGREGATE_COUNT_QUERY_WHERE_CLAUSE_FIELD_PARENTWORKORDERID = 'ParentWorkOrderId';
    private static final String AGGREGATE_QUERY_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD = 'ParentWorkOrderId parentWorkOrderId, Account.Proposed_Date_of_Activation__c proposedDateOfActivaton, Account.Proposed_Date_of_Menu__c proposedDateOfMenu';
    private static final Schema.Fieldset BULK_ONBOARDING_WORK_ORDER_FIELDSET = SObjectType.WorkOrder.FieldSets.Fields_To_Bulk_Onboard_Work_Orders;
    private static final String AGGREGATE_QUERY_FILTER_CONDITION_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD = 'ParentWorkOrderId IN : parentWorkOrderIds';
    private static final String AGGREGATE_QUERY_GROUPBY_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD = 'ParentWorkOrderId, Account.Proposed_Date_of_Activation__c, Account.Proposed_Date_of_Menu__c';
    private static final String COMMA_SPLIT = ',';
    private static final String DEAD_STATUS = 'Dead';
    private static final Set<String> ELIGIBLE_WORK_ORDER_STATUS_TO_PAST_DUE = new Set<String>(
        System.Label.Status_Update_With_Past_Due.split(COMMA_SPLIT)
    );
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String ONBOARDING_COMPLETE_STATUS = 'Onboarding Complete';
    private static final String QUERY_FILTER_CONDITION_WORK_ORDER_STATUS_NOTEQUALTO_DEAD = ' AND Status != :DEAD_STATUS';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final Schema.Fieldset STORE_READINESS_CHECK_PARENT_WORK_ORDER_FIELDSET = SObjectType.WorkOrder.FieldSets.Store_Readiness_Check_Parent_WO_Fields;
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String WHERE_CLAUSE = ' FROM WorkOrder WHERE ';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUBTYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U = 'Partnership creation/update';
    private static final String WORK_ORDER_SUBTYPE_WITHHOLDING = 'Withholding';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String WORK_ORDER_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_ORDER_CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final Set<String> WORK_ORDER_TYPES_FOR_AUTO_WORK_PLAN_CREATION = new Set<String>{
        'Marketing Kit',
        'Photoshoot'
    };
    private static final Set<String> WORK_ORDER_CREATION_SOURCE_FOR_AUTO_WORK_PLAN_CREATION = new Set<String>{
        'Mx Portal'
    };
    private static final List<String> WORK_ORDER_ALLOWED_PROVISIONING_STATUSES = new List<String>{
        'Not Started',
        'Readiness Check',
        'Readiness Check Failed'
    };
    private static final List<String> WORK_ORDER_ALLOWED_STATUSES = new List<String>{
        'Planning',
        'Confirmed',
        'In Progress',
        'At Risk',
        'Past Due'
    };
    private static final List<String> WORK_ORDER_INITIAL_STATUSES = new List<String>{
        'Planning',
        'Confirmed'
    };
    private static final Set<String> DRIVE_WORK_ORDER_TYPES = new Set<String>{ 'Drive' };
    private static final Set<String> COMPLETE_STATUS = new Set<String>{
        'Complete',
        'Dead',
        'Not Workable'
    };
    private static final Set<String> VALID_TYPES_FOR_OP_UPDATES = new Set<String>{
        'Marketplace',
        'COO'
    };
    private static final List<String> IGNORED_STATUSES = new List<String>{
        'Dead',
        'Onboarding Complete'
    };
    private static final List<String> PROVISIONING_STATUS_ELIGIBLE_FOR_BUSINESS_REFERENCE_CREATION = new List<String>{
        PROVISIONING_STATUS_PROVISIONING_FAILED,
        PROVISIONING_STATUS_READY_FOR_PROVISIONING
    };
    private static final String WORK_ORDER_ACTIVATED_CENTRALLY_NO = 'No';
    private static final String WORK_ORDER_TYPE_ONLY_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_MX_REQUESTED_PHOTOSHOOT = 'Yes';
    private static final String WORK_ORDER_SEGMENT = 'SMB';
    private static final String WORK_ORDER_COO_BATCH_UPDATE_CRITIERIA = System.Label.WorkOrder_COO_Batch_Update_Condition;
    private static final Schema.Fieldset WORK_ORDER_RELATED_LIST_FIELD_SET = SObjectType.WorkOrder.FieldSets.Store_Account_Related_List_Fields;
    private static final Schema.Fieldset WORK_ORDER_PARENT_TO_CHILD_SYNC_FIELD_SET = SObjectType.WorkOrder.FieldSets.Parent_Fields_To_Sync_On_Childs;

    /**
     * @description Default constructor for the class
     * @return IWorkOrdersSelector
     */
    public static IWorkOrdersSelector newInstance() {
        return (IWorkOrdersSelector) Application.Selector.newInstance(WorkOrder.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkOrder.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Order
     * @JIRA# LEM-985
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkOrder.Id,
            WorkOrder.AccountId,
            WorkOrder.Account_Owner__c,
            WorkOrder.Account_Record_Type_Name__c,
            WorkOrder.Activated_Centrally_AC__c,
            WorkOrder.Actual_Number_Of_Stores__c,
            WorkOrder.Bundled_with_Marketplace__c,
            WorkOrder.Business_to_Store_Assignment__c,
            WorkOrder.Contract__c,
            WorkOrder.COO_Graveyard_Business_Id__c,
            WorkOrder.Creation_Source__c,
            WorkOrder.Decision_Maker__c,
            WorkOrder.Estimated_Number_Of_Stores__c,
            WorkOrder.Execute_Readiness_Check__c,
            WorkOrder.HasCatalogWorkPlan__c,
            WorkOrder.HasMenuWorkPlan__c,
            WorkOrder.HasWorkPlansGenerated__c,
            WorkOrder.Integration_Request_Id__c,
            WorkOrder.Integration_Request_Ids__c,
            WorkOrder.IsStoresAssociationInProgress__c,
            WorkOrder.Matched_By__c,
            WorkOrder.Menu_Setup_Method__c,
            WorkOrder.Menu_to_be_Completed_By__c,
            WorkOrder.Menu_UI_Type__c,
            WorkOrder.Nintex_Use_Case__c,
            WorkOrder.Opportunity__c,
            WorkOrder.Mx_Onboarding_Link__c,
            WorkOrder.Order_Protocol__c,
            WorkOrder.Originating_Work_Order__c,
            WorkOrder.OwnerId,
            WorkOrder.ParentWorkOrderId,
            WorkOrder.POS_Integration_ID__c,
            WorkOrder.POS_Integration_Type__c,
            WorkOrder.Photoshoot_Date__c,
            WorkOrder.Photoshoot_Time__c,
            WorkOrder.POS_Integration_ID__c,
            WorkOrder.POS_Integration_Type__c,
            WorkOrder.Proposed_Date_of_Activation__c,
            WorkOrder.Proposed_Date_of_Implementation__c,
            WorkOrder.Proposed_Date_of_Menu__c,
            WorkOrder.Proposed_Date_of_Tablet__c,
            WorkOrder.Provisioning_Status__c,
            WorkOrder.Segment__c,
            WorkOrder.Status,
            WorkOrder.Store_Account_Activation_Status__c,
            WorkOrder.Store_Id__c,
            WorkOrder.Store_Location_for_Photoshoot__c,
            WorkOrder.Mx_Requested_Photoshoot__c,
            WorkOrder.Sub_Type__c,
            WorkOrder.Type__c,
            WorkOrder.Vertical__c,
            WorkOrder.Work_Order_Source__c,
            WorkOrder.Associated_Account_Ids__c,
            WorkOrder.WorkOrderNumber,
            WorkOrder.Work_Order_Name__c,
            WorkOrder.Business_Id__c,
            WorkOrder.Sales_Notes_for_Menu_Team__c,
            WorkOrder.Sales_Rep_Name__c
        };
    }

    /**
     * @description It is used for getting number of child Work Orders
     * grouped by Provisioning Status values using given set of parent Work Order Ids.
     * @JIRA# LEM-2083
     * @param parentWorkOrderIds
     * @return Aggregate[]
     */
    public Aggregate[] getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
        Set<Id> parentWorkOrderIds
    ) {
        String workOrderQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_ON_PROVISIONING_STATUS_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTWORKORDERID +
            AGGREGATE_QUERY_FILTER_CONDITION_PARENTWORKORDERID +
            QUERY_FILTER_CONDITION_WORK_ORDER_STATUS_NOTEQUALTO_DEAD +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_PARENTWORKORDERID_AND_PROVISIONINGSTATUS;
        AggregateResult[] workOrderAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workOrderQuery)
        );
        return Aggregate.convertResults(workOrderAggregateCountQueryResult);
    }

    /**
     * @description It is used for getting count of WorkOrders filtered by passed AccountIds and
     * grouped by passed AccountIds.
     * @JIRA# LEM-1113 & LEM-582
     * @param workOrderAccountIds - Set of WorkOrder AccountIds
     * @return Aggregate[]
     */
    public Aggregate[] getMarketplaceWorkOrdersCountFilteredByAccountIdsGroupedByAccountId(
        Set<Id> workOrderAccountIds
    ) {
        String workOrderQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD +
            AGGREGATE_QUERY_FILTER_CONDITION +
            QUERY_FILTER_CONDITION_WORK_ORDER_STATUS_NOTEQUALTO_DEAD +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD;
        AggregateResult[] workOrderAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workOrderQuery)
        );
        return Aggregate.convertResults(workOrderAggregateCountQueryResult);
    }

    /**
     * @description It is used for getting unique number of Store Accounts from child Work Orders
     * using given set of parent Work Order Ids.
     * @JIRA# LEM-955
     * @param parentWorkOrderIds - Set of parent WorkOrder Ids
     * @return Aggregate[]
     */
    public Aggregate[] getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
        Set<Id> parentWorkOrderIds
    ) {
        String workOrderQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS_ACCOUNTID +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_WHERE_CLAUSE_FIELD_PARENTWORKORDERID +
            AGGREGATE_QUERY_FILTER_CONDITION_PARENTWORKORDERID_AND_STOREACCOUNTRECORDTYPE +
            QUERY_FILTER_CONDITION_WORK_ORDER_STATUS_NOTEQUALTO_DEAD +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_WHERE_CLAUSE_FIELD_PARENTWORKORDERID;
        AggregateResult[] workOrderAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workOrderQuery)
        );
        return Aggregate.convertResults(workOrderAggregateCountQueryResult);
    }

    /**
     * @description It is used for getting unique number of child WorkOrders grouped by store Account's
     * POS Integration Type, Menu UI Type & Tablet Delivery Method and Work Order's Bundled with Marketplace fields
     * using passed parent WorkOrder Ids.
     * @JIRA# LEM-2370, LEM-3493
     * @param parentWorkOrderIds
     * @return Aggregate[]
     */
    public Aggregate[] getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
        Set<Id> parentWorkOrderIds
    ) {
        String workOrderQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_ON_STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_WHERE_CLAUSE_FIELD_PARENTWORKORDERID +
            AGGREGATE_QUERY_FILTER_CONDITION_PARENTWORKORDERID +
            QUERY_FILTER_CONDITION_WORK_ORDER_STATUS_NOTEQUALTO_DEAD +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_STORE_LEVEL_WORK_PLANS_INDICATOR_FIELDS;
        AggregateResult[] workOrderAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workOrderQuery)
        );
        return Aggregate.convertResults(workOrderAggregateCountQueryResult);
    }

    /**
     * @description This method is being used for get Work Orders from the click event
     * @JIRA# LEM-985
     * @return Database.QueryLocator
     */
    public List<WorkOrder> getWorkOrderRecordsForUpdateStatus() {
        return (List<WorkOrder>) Database.query(getWorkOrderQueryUpdate().toSOQL());
    }

    /**
     * @description This method is being used for get Work Orders from the Batch.
     * @JIRA# LEM-985
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getWorkOrderRecordsForUpdateStatusFromBatch() {
        return Database.getQueryLocator(getWorkOrderQueryUpdate().toSOQL());
    }

    /**
     * @description This method is being used to get the query.
     * @JIRA# LEM-985 & LEM-1011
     * @return fflib_QueryFactory
     */
    private fflib_QueryFactory getWorkOrderQueryUpdate() {
        return newQueryFactory()
            .setCondition(
                '((Proposed_Date_of_Menu__c < TODAY' +
                    ' AND Proposed_Date_of_Menu__c != null)' +
                    ' OR (Proposed_Date_of_Tablet__c < TODAY' +
                    ' AND Proposed_Date_of_Tablet__c != null)' +
                    ' OR Proposed_Date_of_Activation__c < TODAY)' +
                    ' AND Status IN :ELIGIBLE_WORK_ORDER_STATUS_TO_PAST_DUE'
            );
    }

    /**
     * @description It queries Work Orders associated with the passed Account Ids.
     * @JIRA# LEM-4005
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Account.Tablet_User_Name__c')
            .selectField('Account.Tablet_Password__c')
            .selectField('Account.Order_Protocol__c')
            .setCondition('AccountId IN :accountIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used for getting WorkOrders by the passed Ids.
     * @JIRA# LEM-2013
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectById(Set<Id> workOrderIds) {
        return (List<WorkOrder>) Database.query(
            newQueryFactory(true)
                .selectField('Originating_Work_Order__r.AccountId')
                .selectField('WO_Email_Status__c')
                .setCondition('id in :workOrderIds')
                .toSOQL()
        );
    }

    /**
     * @description It is used for getting the WorkOrders and related account fields by the passed Ids.
     * @param idSet
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectManageableById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: idSet');
        query.selectField('Account.Id');
        query.selectField('Account.BillingCountry');
        query.selectField('Account.BillingCountryCode');
        query.selectField('Account.ShippingCountry');
        query.selectField('Account.ShippingCountryCode');
        return (List<WorkOrder>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for retrieving Work Orders.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrderForPhotoshoot(Set<Id> workOrderIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Id IN :workOrderIds' +
                    ' AND Type__c = :WORK_ORDER_TYPE_ONLY_MARKETPLACE' +
                    ' AND Activated_Centrally_AC__c = :WORK_ORDER_ACTIVATED_CENTRALLY_NO' +
                    ' AND Mx_Requested_Photoshoot__c = :WORK_ORDER_MX_REQUESTED_PHOTOSHOOT' +
                    ' AND Segment__c = :WORK_ORDER_SEGMENT'
            );
        return (List<WorkOrder>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Work Orders by the passed parent Work Order Ids.
     * @JIRA# LEM-1684
     * @param parentWorkOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectByParentWorkOrderIds(Set<Id> parentWorkOrderIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Account.ParentId')
            .selectField('Account.Activated_Centrally_AC__c')
            .selectField('Account.Menu_Setup_Method__c')
            .selectField('Account.Franchise_Parent__c')
            .selectField('Account.Menu_to_be_Completed_By__c')
            .selectField('Account.Order_Protocol__c')
            .selectField('Account.Change_of_Ownership_Effective_Date__c')
            .selectField('Account.Sales_Notes_for_Menu_Team__c')
            .selectField('Account.Proposed_Date_of_Activation__c')
            .selectField('Account.Disallow_PDOA_Override__c')
            .selectField('Account.User_Sets_PDOT_Value__c')
            .selectField('Account.User_Sets_PDOM_Value__c')
            .selectField('AccountId')
            .selectField('ParentWorkOrderId')
            .selectField('ParentWorkOrder.Contract__r.SBQQ__Order__r.SBQQ__Quote__c')
            .setCondition('ParentWorkOrderId IN :parentWorkOrderIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description This method is for getting work order records by given set of Ids
     * @description It queries WorkOrders and associated WorkSteps by set of WorkOrder Ids.
     * TODO: Replace hard-coded Strings with Constants.
     * @JIRA# LEM-582
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersAndWorkStepsUsingWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Contract__r.Contract_Split_Category__c')
            .selectField('ParentWorkOrderId')
            .selectField('ParentWorkOrder.Status')
            .selectField('ParentWorkOrder.Proposed_Date_of_Menu__c')
            .selectField('ParentWorkOrder.Proposed_Date_of_Tablet__c')
            .selectField('ParentWorkOrder.Proposed_Date_of_Activation__c')
            .selectField('Status')
            .setCondition('Id IN :workOrderIds');
        new WorkStepsSelector()
            .addQueryFactorySubselect(workOrderQuery, 'WorkSteps')
            .selectField('Parent_Work_Step__c')
            .selectField('WorkPlan.Parent_Work_Plan__c')
            .setOrdering('Work_Step_Sequence__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries WorkOrders and related WorkSteps by set of Account Ids.
     * @JIRA# LEM-746
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Account_Owner_Email_Calculated__c')
            .selectField('Account_Record_Type_Name__c')
            .selectField('Account_Type__c')
            .selectField('Account.Franchise_Parent__c')
            .selectField('Business_Id__c')
            .selectField('Contract__r.SBQQ__Order__r.SBQQ__Quote__c')
            .selectField('MP_Bz_Id__c')
            .selectField('Withholding_with_Auto_Activations__c')
            .setCondition('AccountId IN :accountIds');
        new WorkStepsSelector().addQueryFactorySubselect(workOrderQuery, 'WorkSteps');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries WorkOrders associated with passed Business Account Ids.
     * @JIRA# LEM-658
     * @param businessAccountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersByBusinessAccountIds(Set<Id> businessAccountIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Opportunity__r.Marketplace_Nintex_Id__c')
            .selectField('Opportunity__r.Drive_Nintex_Id__c')
            .selectField('Creation_Source__c')
            .setCondition(
                'AccountId IN :businessAccountIds AND ' +
                    'Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS' +
                    ' AND ParentWorkOrderId = null' +
                    ' AND Status IN :WORK_ORDER_INITIAL_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries WorkOrders with Account and WorkOrder details by
     * the passed WorkOrder Ids.
     * @JIRA# LEM-658
     * @param parentWorkOrderIds
     * @param storeAccountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectChildWorkOrdersByStoreAccountIds(
        Set<Id> parentWorkOrderIds,
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrderId')
            .selectField('AccountId')
            .setCondition(
                'AccountId IN :storeAccountIds AND ParentWorkOrderId IN :parentWorkOrderIds'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used to get the encrypted data stored in the passed fields
     * by the passed sObjectIds.
     * @JIRA# LEM-3184
     * @param fieldSet
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectEncryptedData(Schema.FieldSet fieldSet, Set<Id> sobjectIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :sobjectIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Non-Dead Drive Auto Activations Work Orders by passed Account Ids.
     * @JIRA# LEM-11612
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                'AccountId IN :accountIds' +
                    ' AND Type__c =: WORK_ORDER_TYPE_DRIVE' +
                    ' AND Status !=: DEAD_STATUS' +
                    ' AND Sub_Type__c =: WORK_ORDER_SUBTYPE_AUTO_ACTIVATIONS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries parent Work Orders by passed Opportunity Ids.
     * @JIRA# LEM-2348
     * @param opportunityIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentWorkOrdersByOpportunityIds(Set<Id> opportunityIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Opportunity__r.FranchiseAmendmentProcess__c')
            .selectField('Opportunity__r.Nintex_Use_Case__c')
            .setCondition(
                'Opportunity__c IN :opportunityIds AND ParentWorkOrderId = null' +
                ' AND Status != :DEAD_STATUS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Work Orders with Account and related details
     * by the passed Work Order Ids where Provisioning Status is in the allowed status.
     * @JIRA# LEM-1684
     * @param workOrderFieldSet
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersWithAccountDetailsByIds(
        Schema.FieldSet workOrderFieldSet,
        Set<Id> workOrderIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectFieldSet(workOrderFieldSet)
            .selectFieldSet(STORE_READINESS_CHECK_PARENT_WORK_ORDER_FIELDSET)
            .selectField('CreatedBy.Name')
            .selectField('MP_Bz_Id__c')
            .selectField('Account.Segment__c')
            .selectField('Account.Deck_Rank__c')
            .selectField('Account.Experience__c')
            .selectField('Account.Menu_URL__c')
            .selectField('Account.Segment__c')
            .selectField('Account.Storefront_Mx_Has_Website__c')
            .selectField('Account.Storefront_Website__c')
            .selectField('Opportunity__c')
            .selectField('Opportunity__r.StageName')
            .selectField('ParentWorkOrder.Account.BillingCountryCode')
            .selectField('ParentWorkOrder.Account.BillingStateCode')
            .selectField('ParentWorkOrder.Account.Duplicate_Status__c')
            .selectField('ParentWorkOrder.Account.Legal_Business_Name__c')
            .selectField('ParentWorkOrder.Account.Phone')
            .selectField('ParentWorkOrder.Account.Segment__c')
            .selectField('ParentWorkOrder.Account.Provincial_Tax_ID__c')
            .selectField('ParentWorkOrder.Account.TaxID__c')
            .selectField('ParentWorkOrder.CreatedBy.Name')
            .selectField('ParentWorkOrder.Opportunity__r.StageName')
            .selectField('Opportunity__r.MP_Bz_Id__c')
            .selectField('Opportunity__r.Nintex_Use_Case__c')
            .selectField('Contract__r.MP_Bz_Id__c')
            .selectField('ParentWorkOrder.Business_Id__c')
            .selectField('ParentWorkOrder.Segment__c')
            .setCondition(
                'Id IN :workOrderIds' +
                    ' AND Provisioning_Status__c IN :WORK_ORDER_ALLOWED_PROVISIONING_STATUSES' +
                    ' AND Status != :DEAD_STATUS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries parent and child Work Orders along with related Work Plans
     * by the passed parent Work Order Ids.
     * @JIRA# LEM-1956
     * @param parentWorkOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersWithWorkPlansByParentWorkOrderIds(
        Set<Id> parentWorkOrderIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('HasPOSWorkPlan__c')
            .selectField('HasTabletWorkPlan__c')
            .selectField('ParentWorkOrderId')
            .selectField('Integration_Request_Ids__c')
            .selectField('Associated_Account_Ids__c')
            .selectField('ParentWorkOrder.Integration_Request_Ids__c')
            .selectField('ParentWorkOrder.Associated_Account_Ids__c')
            .setCondition(
                '(Id IN :parentWorkOrderIds OR ParentWorkOrderId IN :parentWorkOrderIds)' +
                    ' AND HasWorkPlansGenerated__c = TRUE' +
                    ' AND Status != :DEAD_STATUS'
            );
        new WorkPlansSelector().addQueryFactorySubselect(workOrderQuery, 'WorkPlans');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }
    /**
     * @description It is used to get WorkOrder that are not Complete, and of Type Drive, by AccountId
     * @JIRA# LEM-2772
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> queryNonCompleteDriveWorkOrdersByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Provisioning_Status__c');
        query.selectField('Status');
        query.setCondition(
            'AccountId IN :accountIds' +
            ' AND Status NOT IN :COMPLETE_STATUS AND Type__c in :DRIVE_WORK_ORDER_TYPES'
        );
        return (List<WorkOrder>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries WorkOrders with passed Nintex Ids from associated Opportunity.
     * @JIRA# LEM-2994
     * @param nintexIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectByNintexIds(Set<String> nintexIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Opportunity__r.Marketplace_Nintex_Id__c')
            .selectField('Opportunity__r.Drive_Nintex_Id__c')
            .setCondition(
                'ParentWorkOrderId = null' +
                    ' AND Account_Record_Type_Name__c = :ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS' +
                    ' AND (Opportunity__r.Marketplace_Nintex_Id__c IN :nintexIds' +
                    ' OR Opportunity__r.Drive_Nintex_Id__c IN :nintexIds)' +
                    ' AND Status IN :WORK_ORDER_INITIAL_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Work Orders using passed Email Reference Ids.
     * @JIRA# LEM-3548
     * @param emailReferenceIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectByEmailReferenceIds(Set<String> emailReferenceIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory(false)
            .selectField('Email_Reference_Id__c')
            .setCondition('Email_Reference_Id__c IN :emailReferenceIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries parent Work Orders by the passed Contract Ids.
     * @JIRA# LEM-3357
     * @param contractIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentWorkOrdersByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Opportunity__r.Type')
            .selectField('Opportunity__r.Opportunity_Sub_Type__c')
            .setCondition(
                'Contract__c IN :contractIds AND ParentWorkOrderId = null' +
                ' AND Status IN :WORK_ORDER_INITIAL_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries the workorders which has amended Opportunity/Contract by the passed WorkOrders Ids.
     * @JIRA# LEM-3170
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectAmendedOpportunityWorkOrdersByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Opportunity__r.SBQQ__AmendedContract__c')
            .selectField('ParentWorkOrder.Type__c')
            .selectField('ParentWorkOrder.Sub_Type__c')
            .setCondition(
                '((ParentWorkOrder.Opportunity__r.SBQQ__AmendedContract__c != null OR ' +
                    '(ParentWorkOrder.Type__c = :WORK_ORDER_TYPE_STOREFRONT AND ' +
                    'Bundled_with_Marketplace__c = :BUNDLED_WITH_MARKETPLACE_NO AND ' +
                    'ParentWorkOrder.Opportunity__r.SBQQ__AmendedContract__c = null)) OR ' +
                    ' ((ParentWorkOrder.Type__c = :WORK_ORDER_TYPE_POST_SALES)' +
                    ' AND (ParentWorkOrder.Sub_Type__c = :WORK_ORDER_SUBTYPE_RATE_CHANGE)) )' +
                    ' AND ParentWorkOrderId IN :workOrderIds' +
                    ' AND Status IN :WORK_ORDER_ALLOWED_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }
    /**
     * @description It queries the workorders which has amended Opportunity/Contract by the passed WorkOrders Ids.
     * @JIRA# LEM-4223
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectDriveAmendedOpportunityWorkOrdersByWorkOrderIds(
        Set<Id> workOrderIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Type__c')
            .selectField('ParentWorkOrder.Sub_Type__c')
            .setCondition(
                'ParentWorkOrder.Type__c = :WORK_ORDER_TYPE_DRIVE' +
                    ' AND ParentWorkOrder.Sub_Type__c = :WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U' +
                    ' AND ParentWorkOrderId IN :workOrderIds' +
                    ' AND Status IN :WORK_ORDER_INITIAL_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description This method is being used to get the query for COO work Orders based on PDOA date
     * @JIRA# LEM-3648
     * @return fflib_QueryFactory
     */
    public Database.QueryLocator selectCOOWorkOrdersBasedOnPDOADate() {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('COO_Batch_Run_Date__c')
            .setCondition(WORK_ORDER_COO_BATCH_UPDATE_CRITIERIA);
        return Database.getQueryLocator(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries the workorders and parent workorder fields by the passed account id.
     * @JIRA# LEM-4850
     * @param accountId
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersByAccountId(Id accountId) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Work_Order_Name__c')
            .selectField('ParentWorkOrder.Status')
            .selectField('ParentWorkOrder.Type__c')
            .selectField('ParentWorkOrder.WorkOrderNumber')
            .selectField('ParentWorkOrder.Proposed_Date_of_Activation__c')
            .selectField('ParentWorkOrder.CreatedDate')
            .selectField('ParentWorkOrder.CreatedById')
            .selectField('ParentWorkOrder.CreatedBy.Name')
            .setCondition('AccountId =: accountId')
            .setOrdering('ParentWorkOrder.CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries the parent workorder fields by the passed opportunity id.
     * @JIRA# LEM-5270
     * @param opportunityId
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersByOpportunityId(Id opportunityId) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectFieldSet(WORK_ORDER_RELATED_LIST_FIELD_SET)
            .selectField('CreatedBy.Name')
            .setCondition('Opportunity__c = :opportunityId' + ' AND ParentWorkOrderId = null')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used for getting unique number of child Work Orders grouped by store Account’s
     * PDOx fields using passed parent WorkOrder Ids.
     * @JIRA# LEM-5126
     * @param parentWorkOrderIds
     * @return List<WorkOrder>
     */
    public Aggregate[] selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
        Set<Id> parentWorkOrderIds
    ) {
        String workOrderQuery =
            SELECT_CLAUSE +
            AGGREGATE_QUERY_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD +
            WHERE_CLAUSE +
            AGGREGATE_QUERY_FILTER_CONDITION_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD +
            GROUP_BY_CLAUSE +
            AGGREGATE_QUERY_GROUPBY_STORE_LEVEL_PDOX_WORK_ORDER_INDICATOR_FIELD;
        AggregateResult[] workOrderAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workOrderQuery)
        );
        return Aggregate.convertResults(workOrderAggregateCountQueryResult);
    }

    /**
     * @description It queries parent and child Work Orders not having Status
     * as Dead using the passed Work Order Ids.
     * @JIRA# LEM-5273
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentAndChildrenByIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Provisioning_Status__c')
            .setCondition(
                '((Id IN :workOrderIds' +
                    ' AND ((Account_Record_Type_Name__c = :ACCOUNT_RECORD_TYPE_NAME_BUSINESS' +
                    ' OR (Type__c = \'POS\' AND ParentWOrkOrderId = null)) OR ' +
                    '(Account_Record_Type_Name__c = :ACCOUNT_RECORD_TYPE_NAME_STORE AND ' +
                    '(Type__c IN :WORK_ORDER_TYPES_FOR_AUTO_WORK_PLAN_CREATION OR ' +
                    ' Creation_Source__c =: WORK_ORDER_CREATION_SOURCE_FOR_AUTO_WORK_PLAN_CREATION))))' +
                    ' OR (ParentWorkOrderId IN :workOrderIds' +
                    ' AND Account_Record_Type_Name__c = :ACCOUNT_RECORD_TYPE_NAME_STORE))' +
                    ' AND Status != :DEAD_STATUS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description This method is used for getting workOrders and workplans by AccountIds, status and types
     * @param accountIds
     * @param status
     * @param type
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(
        Set<Id> accountIds,
        Set<String> status,
        Set<String> type
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('HasPOSWorkPlan__c')
            .selectField('ParentWorkOrderId')
            .selectField('Integration_Request_Ids__c')
            .selectField('ParentWorkOrder.Order_Protocol__c')
            .setCondition(
                'AccountId IN :accountIds' + ' AND Status IN :Status' + ' AND Type__c IN :Type'
            );

        new WorkPlansSelector()
            .addQueryFactorySubselect(workOrderQuery, 'WorkPlans')
            .selectField('Integration_Request__r.Integration_Id__c')
            .selectField('Integration_Request__c')
            .selectField('status__c');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description This method is being used to get workorder details using generic workobject
     * selector class
     * @JIRA# 6198
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectParentDetailsByChildIds(Set<Id> sobjectIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectFieldSet(WORK_ORDER_PARENT_TO_CHILD_SYNC_FIELD_SET)
            .setCondition('Id IN :sobjectIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used for getting Child WorkOrders and parent WorkOrders for Drive
     * @JIRA# LEM-6941
     * @param recordId
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentAndChildWOsByWorkOrderIds(Id recordId) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                'ParentWorkOrderId = :recordId' +
                ' OR (ParentWorkOrderId = null AND Id = :recordId AND Type__c = :WORK_ORDER_TYPE_DRIVE)'
            )
            .setOrdering('ParentWorkOrderId', fflib_QueryFactory.SortOrder.ASCENDING, true);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Marketplace WorkOrders which are not Dead and Onboarding Complete by accountIds.
     * @JIRA# LEM-7912
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectOpenMarketPlaceWorkOrdersByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Work_Order_Name__c')
            .setCondition(
                'AccountId IN :accountIds' +
                    ' AND Type__c =: WORK_ORDER_TYPE_MARKETPLACE' +
                    ' AND Status !=: DEAD_STATUS' +
                    ' AND Status !=: ONBOARDING_COMPLETE_STATUS'
            )
            .setOrdering(
                WorkOrder.Proposed_Date_of_Activation__c,
                fflib_QueryFactory.SortOrder.ASCENDING,
                true
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Parent WorkOrders By Status, Type, SubTpe, OppotunityId and Batch Id
     * @JIRA# LEM-9052
     * @param status
     * @param type
     * @param subType
     * @param oppIds
     * @param batchIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
        Set<String> status,
        Set<String> type,
        Set<String> subType,
        Set<Id> oppIds,
        Set<String> batchIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('AccountId')
            .selectField('Opportunity__c')
            .selectField('Opportunity__r.Batch_Id__c')
            .setCondition(
                'Opportunity__c != null AND ' +
                    'Opportunity__c IN :oppIds AND ' +
                    'Opportunity__r.Batch_Id__c IN : batchIds AND ' +
                    'Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS' +
                    ' AND ParentWorkOrderId = null' +
                    ' AND Status IN :status' +
                    ' AND Type__c IN :Type' +
                    ' AND Sub_Type__c IN :suBType'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description Retrieves details from the current WorkOrder related to an Account.
     * @param accountId
     * @return List<WorkOrder>
     **/
    public List<WorkOrder> selectWorkOrderDetailsForAccount(Id accountId) {
        fflib_QueryFactory workOrderQuery = newQueryFactory(false)
            .selectFieldSet(BULK_ONBOARDING_WORK_ORDER_FIELDSET)
            .setCondition(
                'AccountId = :accountId' +
                    ' AND Status IN :WORK_ORDER_INITIAL_STATUSES' +
                    ' AND Type__c = :WORK_ORDER_TYPE_MARKETPLACE'
            )
            .setOrdering('Proposed_Date_of_Activation__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Withholding parent Work Orders by the passed Contract Ids.
     * @JIRA# LEM-11117
     * @param contractIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWithholdingParentWorkOrdersByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                'Contract__c IN :contractIds AND ParentWorkOrderId = null' +
                    ' AND Type__c = :WORK_ORDER_TYPE_DRIVE' +
                    ' AND Sub_Type__c = :WORK_ORDER_SUBTYPE_WITHHOLDING' +
                    ' AND Status NOT IN :COMPLETE_STATUS' +
                    ' AND Provisioning_Status__c IN :WORK_ORDER_ALLOWED_PROVISIONING_STATUSES'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description Retrieves the list of WorkOrders by the parent WorkOrder ID.
     * @param workOrderId The ID of the parent WorkOrder.
     * @return List<WorkOrder> The list of WorkOrders.
     */
    public List<WorkOrder> selectWorkOrdersByParentId(Id workOrderId) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.CreatedDate')
            .selectField('ParentWorkOrder.Type__c')
            .setCondition('ParentWorkOrderId = :workOrderId AND AccountId != NULL');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description Retrieves the list of ParentWorkOrders by the store Account ID.
     * @param storeAccountIds The ID of the store Accounts.
     * @return List<WorkOrder> The list of WorkOrders.
     */
    public List<WorkOrder> selectWorkOrdersWithParentWorkOrderIdByAccountIds(
        Set<Id> storeAccountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition('AccountId IN :storeAccountIds');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description select Market place and Drive Work Order in Allowed Status by Accounts
     * @author rishab.goyal | 03-20-2024
     * @param accountIds
     * @return List<WorkOrder>
     **/
    public List<WorkOrder> selectMarketplaceAndDriveWorkOrderInAllowedStatusByAccounts(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                '(Type__c = :WORK_ORDER_TYPE_MARKETPLACE OR Type__c = :WORK_ORDER_TYPE_DRIVE)' +
                    ' AND AccountId In :accountIds' +
                    ' AND Status IN :WORK_ORDER_ALLOWED_STATUSES'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries child WOs using its associated Account Ids
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectInProgressWorkOrdersWithParentDetailsByAccountIds(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Status')
            .selectField('AccountId')
            .selectField('Order_Protocol__c')
            .selectField('ParentWorkOrderId')
            .selectField('ParentWorkOrder.Status')
            .selectField('Account.Order_Protocol__c')
            .selectField('ParentWorkOrder.Actual_Number_Of_Stores__c')
            .setCondition(
                'AccountId IN :accountIds AND Status NOT IN :IGNORED_STATUSES AND Type__c IN :VALID_TYPES_FOR_OP_UPDATES'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }
    /**
     * @description It queries child WOs using its parent Work Order Id & by order protocol
     * @param parentWorkOrderId
     * @param orderProtocol
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectAllChildWosByOrderProtocol(
        Id parentWorkOrderId,
        String orderProtocol
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                'ParentWorkOrderId = :parentWorkOrderId AND Status NOT IN :IGNORED_STATUSES AND Order_Protocol__c = :orderProtocol '
            )
            .setOrdering('createddate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries child Work Orders along with Work Step details
     * based on Store Account Ids and Work Step Types.
     * @JIRA# LEM-16642
     * @param accountIds
     * @param workStepTypes
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectMarketplaceWorkOrdersAndWorkStepsByAccountIdsAndWorkStepTypes(
        Set<Id> accountIds,
        Set<String> workStepTypes
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('CreatedDate')
            .selectField('Status')
            .selectField('ParentWorkOrder.Opportunity__r.Type')
            .selectField('ParentWorkOrder.Opportunity__r.Opportunity_Sub_Type__c')
            .selectField('ParentWorkOrder.Proposed_Date_of_Activation__c')
            .selectField('ParentWorkOrder.Proposed_Date_of_Menu__c')
            .setCondition('AccountId IN :accountIds AND Type__c = :WORK_ORDER_TYPE_MARKETPLACE')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        new WorkStepsSelector()
            .addQueryFactorySubselect(workOrderQuery, 'WorkSteps')
            .selectField('Status__c')
            .selectField('Status_Reason__c')
            .selectField('Status_Reason_Details__c')
            .selectField('Type__c')
            .setCondition('Type__c IN :workStepTypes');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Parent Work Orders by passed Unique Identifiers
     * @param uuids
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentWorkOrdersByUniqueIdentifiers(set<String> uuids) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Unique_Identifier__c')
            .selectField('Sales_Rep_Name__c')
            .setCondition(
                'ParentWorkOrderId = null AND Unique_Identifier__c IN :uuids ' +
                'AND ((Status IN :WORK_ORDER_INITIAL_STATUSES) OR (Status = :WORK_ORDER_STATUS_IN_PROGRESS AND Creation_Source__c = :WORK_ORDER_CREATION_SOURCE_RESSMO))'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Work Orders using passed Account Ids where the Account Segment 'SMB'.
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersBySegment(Set<Id> accountIds) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrder.Business_Id__c')
            .setCondition('AccountId IN :accountIds' + ' AND Segment__c = :WORK_ORDER_SEGMENT');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Work Orders along with Work Step details
     * based on passed Account Ids, Work Order Types and Work Step Types.
     * @JIRA# LEM-15585
     * @param accountIds
     * @param workOrderTypes
     * @param workStepTypes
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
        Set<Id> accountIds,
        Set<String> workOrderTypes,
        Set<String> workStepTypes
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('CreatedDate')
            .selectField('Status')
            .setCondition(
                '(AccountId IN :accountIds OR ParentWorkOrder.AccountId IN :accountIds)' +
                    ' AND Status NOT IN :IGNORED_STATUSES' +
                    ' AND Type__c IN :workOrderTypes'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        new WorkStepsSelector()
            .addQueryFactorySubselect(workOrderQuery, 'WorkSteps')
            .selectField('Status__c')
            .selectField('Status_Reason__c')
            .selectField('WorkPlanId')
            .selectField('Type__c')
            .setCondition('Type__c IN :workStepTypes');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries Parent and Child Work Orders with Work Plans
     * by Business Account Ids.
     * @JIRA# LEM-23780
     * @param businessAccountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectParentAndChildWorkOrdersWithWorkPlansByBusinessAccountIds(
        Set<Id> businessAccountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory(false)
            .selectField('ParentWorkOrderId')
            .selectField('Contract__c')
            .selectField('Contract__r.Contract_Split_Category__c')
            .selectField('ParentWorkOrder.Contract__r.Contract_Split_Category__c')
            .setCondition(
                '(AccountId IN :businessAccountIds OR ParentWorkOrder.AccountId IN :businessAccountIds)'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        new WorkPlansSelector().addQueryFactorySubselect(workOrderQuery, 'WorkPlans', false);
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used to select WorkOrders by Originating Work Order.
     * @JIRA# LEM-18140
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectMarketingKitWorkOrdersByOriginatingWorkOrder(
        Set<Id> workOrderIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .setCondition(
                'Originating_Work_Order__c IN :workOrderIds AND ' +
                    'Type__c = :WORK_ORDER_TYPE_MARKETING_KIT AND ' +
                    'Status != :DEAD_STATUS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It queries parent Work Orders by passed Bulk Parent Order Keys.
     * @JIRA# LEM-15978
     * @param bulkParentOrderKeys
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectWorkOrdersByBulkParentOrderKeys(Set<String> bulkParentOrderKeys) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('Bulk_Parent_Order_Key__c')
            .setCondition('Bulk_Parent_Order_Key__c IN :bulkParentOrderKeys');
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }

    /**
     * @description It is used to query Work Orders eligible for Business Reference creation by the passed Acccount Ids.
     * @JIRA# LEM-20169
     * @param accountIds
     * @return List<WorkOrder>
     */
    public List<WorkOrder> selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(
        Set<Id> accountIds
    ) {
        fflib_QueryFactory workOrderQuery = newQueryFactory()
            .selectField('ParentWorkOrderId')
            .selectField('ParentWorkOrder.Provisioning_Status__c')
            .setCondition(
                'AccountId IN :accountIds AND ' +
                    'Provisioning_Status__c IN :PROVISIONING_STATUS_ELIGIBLE_FOR_BUSINESS_REFERENCE_CREATION ' +
                    'AND Type__c = :WORK_ORDER_TYPE_MARKETPLACE AND Status != :DEAD_STATUS'
            );
        return (List<WorkOrder>) Database.query(workOrderQuery.toSOQL());
    }
}