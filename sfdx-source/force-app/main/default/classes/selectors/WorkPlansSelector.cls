/**
 * @author Deloitte
 * @date 08/04/2022
 * @description Selector class for WorkPlan object.
 */
public inherited sharing class WorkPlansSelector extends fflib_SObjectSelector implements IWorkPlansSelector, IWorkObjectsSyncSelector {
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = System.Label.StoreAccountRecordTypeName;
    private static final String ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS = System.Label.BusinessAccountRecordTypeName;
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = ' parentId, COUNT(Id) childWorkPlans, Activation_Checklist_Validation__c validationStatus';
    private static final String AGGREGATE_COUNT_QUERY_FILTER_CONDITION = ' IN :parentIds';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD = 'Parent_Work_Plan__c, Activation_Checklist_Validation__c';
    private static final String AGGREGATE_SUM_QUERY_FIELDS = ' parentId, SUM(Number_of_Workable_WorkSteps_Roll_Up__c) workableWorkSteps';
    private static final String AGGREGATE_SUM_QUERY_GROUPBY_FIELD = 'Parent_Work_Plan__c';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :parentIds';
    private static final String FAILURE = 'Failure';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String STATUS_DEAD = 'Dead';
    private static final String SUCCESS = 'Success';
    private static final String WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String WHERE_CLAUSE = ' FROM WorkPlan WHERE ';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_TABLET = 'Tablet';
    private static final String WORK_PLAN_STATUS_DEAD = 'Dead';
    private static final String VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final Schema.Fieldset WORK_PLAN_PARENT_TO_CHILD_SYNC_FIELD_SET = SObjectType.WorkPlan.FieldSets.Parent_Fields_To_Sync_On_Childs;
    private static final String ACCOUNT_TYPE_VIRTUAL = 'Virtual';
    private static final String ACCOUNT_SEGMENT_SMB ='SMB';
    private static final List<String> VERIFIED_POS_INTEGRATION_TYPES = System.Label.Verified_POS_Integration_Types.split(';');

    /**
     * @description Default constructor for the WorkPlans Selector class.
     * @return IWorkPlansSelector - interface of IWorkPlansSelector
     */
    public static IWorkPlansSelector newInstance() {
        return (IWorkPlansSelector) Application.Selector.newInstance(WorkPlan.SObjectType);
    }

    /**
     * @description It is for getting the fields on WorkPlan object.
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkPlan.Id,
            WorkPlan.Name,
            WorkPlan.Parent_Work_Order_Creation_Source__c,
            WorkPlan.Parent_Work_Plan__c,
            WorkPlan.Type__c,
            WorkPlan.Status__c,
            WorkPlan.WorkOrderId
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkPlan.SObjectType;
    }

    /**
     * @description It is used for gettung sum of workable WorkSteps on Child WorkPlan
     * grouped by Parent WorkPlan.
     * @JIRA# LEM-1181
     * @param parentIds - Set of Parent WorkPlan Ids
     * @return Aggregate[]
     */
    public Aggregate[] getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
        Set<Id> parentIds
    ) {
        String workPlanQuery =
            SELECT_CLAUSE +
            AGGREGATE_SUM_QUERY_GROUPBY_FIELD +
            AGGREGATE_SUM_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_SUM_QUERY_GROUPBY_FIELD +
            AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_SUM_QUERY_GROUPBY_FIELD;
        AggregateResult[] workPlanAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workPlanQuery)
        );
        return Aggregate.convertResults(workPlanAggregateQueryResult);
    }

    /**
     * @description It is used for getting count of validated Child WorkPlans with "Completed"
     * Acivation Checklist Validation Status grouped by Parent WorkPlan.
     * @JIRA# LEM-13305
     * @param parentIds - Set of Parent WorkPlan Ids
     * @return Aggregate[]
     */
    public Aggregate[] getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
        Set<Id> parentIds
    ) {
        String workPlanQuery =
            SELECT_CLAUSE +
            AGGREGATE_SUM_QUERY_GROUPBY_FIELD +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_SUM_QUERY_GROUPBY_FIELD +
            AGGREGATE_COUNT_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD;
        AggregateResult[] workPlanAggregateQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(workPlanQuery)
        );
        return Aggregate.convertResults(workPlanAggregateQueryResult);
    }

    /**
     * @description It is used for getting WorkPlan records by set of Ids.
     * @JIRA# LEM-1397
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectById(Set<Id> workPlanIds) {
        return (List<WorkPlan>) selectSObjectsById(workPlanIds);
    }

    /**
     * @description It is for getting Work Plan record on basis of Id.
     * TODO: Parent_Work_Plan__c != null needs to be adjusted in-case
     * single store onboarding does not have a Parent Work Plan associated with it.
     * @JIRA# LEM-1158 & LEM-1397
     * @param workPlanId - WorkPlan Id
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectByIdAndStoreAccountRecordType(Id workPlanId) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Name')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Name')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Contract__c')
            .selectField('WorkOrder.ParentWorkOrder.Id')
            .selectField('WorkOrder.Account.ParentId')
            .selectField('WorkOrder.Opportunity__c')
            .selectField('WorkOrder.ParentWorkOrder.AccountId')
            .selectField('WorkOrder.ParentWorkOrder.Opportunity__c')
            .setCondition(
                '((Id = :workPlanId AND ((Parent_Work_Plan__c != null AND' +
                    ' WorkOrder.Type__c != :WORK_ORDER_TYPE_DRIVE) OR' +
                    ' (WorkOrder.Type__c = :WORK_ORDER_TYPE_DRIVE) OR' +
                    ' (WorkOrder.Type__c = :WORK_ORDER_TYPE_TABLET)))' +
                    ' OR Parent_Work_Plan__c = :workPlanId)'
            )
            // It ensures business Account is retrieved first.
            .setOrdering(
                'WorkOrder.Account.RecordType.DeveloperName',
                fflib_QueryFactory.SortOrder.ASCENDING
            )
            .addOrdering('WorkOrder.Account.Name', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries WorkPlans with WorkOrder details.
     * @JIRA# LEM-732
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithWorkOrderDetails(Set<Id> workPlanIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Is_Store_Active__c')
            .selectField('Work_Plan_Template__c')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Creation_Source__c')
            .selectField('WorkOrder.Order_Protocol__c')
            .selectField('WorkOrder.Contract__c')
            .selectField('WorkOrder.Nintex_Use_Case__c')
            .selectField('WorkOrder.Opportunity__c')
            .selectField('WorkOrder.ParentWorkOrderId')
            .selectField('WorkOrder.Segment__c')
            .selectField('WorkOrder.Sub_Type__c')
            .selectField('WorkOrder.Type__c')
            .setCondition('Id IN :workPlanIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries parent and child WorkPlans by passed recordIds.
     * @JIRA# LEM-1536
     * @param recordIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithChildWorkPlanDetails(Set<String> recordIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Id')
            .selectField('OwnerId')
            .setCondition('Id IN :recordIds OR Parent_Work_Plan__c IN :recordIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries WorkPlans associated with WorkOrders.
     * @JIRA# LEM-658
     * @param workOrderIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('WorkOrderId')
            .selectField('ExecutionOrder')
            .setCondition('WorkOrderId IN :workOrderIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description Gets integration info for all Work Plans with this Parent Work Plan Id
     * @param parentWorkPlanId
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectIntegrationInfoForWorkPlansByParentWorkPlanId(Id parentWorkPlanId) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Business_Reference__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Business_Reference__r.Last_Completed_Step__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Default_Type__c')
            .selectField('Xref__c')
            .selectField('Xref__r.Business_Reference__c')
            .selectField('Xref__r.External_ID_Source__c')
            .selectField('Xref__r.Integration_Status__c')
            .selectField('Xref__r.Business_Reference__r.Integration_Status__c')
            .selectField('Xref__r.Business_Reference__r.Default_Type__c')
            .setCondition(
                '(Parent_Work_Plan__c = :parentWorkPlanId OR' +
                    ' (Id = :parentWorkPlanId AND WorkOrder.Type__c = :WORK_ORDER_TYPE_DRIVE AND' +
                    ' WorkOrder.Actual_Number_Of_Stores__c = null))' +
                    ' AND ((Business_Reference__c != null AND' +
                    ' Business_Reference__r.Integration_Status__c = :FAILURE) OR' +
                    ' (Xref__c != null AND (Xref__r.Integration_Status__c = :FAILURE OR' +
                    ' (Xref__r.Integration_Status__c = :WAITING_FOR_BUSINESS AND' +
                    ' Xref__r.Business_Reference__r.Integration_Status__c = :SUCCESS))))'
            );
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /** @description It queries WorkPlans and worksteps associated with IntegrationRequests.
     * @param integrationRequestIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByIntegrationRequestId(Set<Id> integrationRequestIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Integration_Request__r.Onboarding_Id__c')
            .setCondition(
                'Integration_request__c IN :IntegrationRequestIds ' +
                'AND Status__c != :WORK_PLAN_STATUS_DEAD'
            );
        new WorkStepsSelector().addQueryFactorySubselect(workPlanQuery, 'WorkSteps');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description This method is being used to get workplan details using generic workobject
     * selector class
     * @JIRA# 6198
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectParentDetailsByChildIds(Set<Id> sobjectIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectFieldSet(WORK_PLAN_PARENT_TO_CHILD_SYNC_FIELD_SET)
            .setCondition('Id IN :sobjectIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description This method is being used to get child work plan details using parent
     * work plans
     * @JIRA# 6198
     * @param parentWorkPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectByParentWorkPlanIds(Set<Id> parentWorkPlanIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .setCondition('Parent_Work_Plan__c IN :parentWorkPlanIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries WorkPlans associated with ParentWorkOrder of Type = Drive and Actual_Number_Of_Stores__c = 0
     * @JIRA# LEM-7366
     * @param parentWorkOrderId
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectIntegrationInfoForWorkPlansByParentWorkOrderDriveId(
        Id parentWorkOrderId
    ) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Business_Reference__c')
            .selectField('Business_Reference__r.Integration_Status__c')
            .selectField('Business_Reference__r.Last_Completed_Step__c')
            .selectField('Business_Reference__r.External_Id_Source__c')
            .selectField('Business_Reference__r.Default_Type__c')
            .selectField('Xref__c')
            .selectField('Xref__r.Business_Reference__c')
            .selectField('Xref__r.External_ID_Source__c')
            .selectField('Xref__r.Integration_Status__c')
            .selectField('Xref__r.Business_Reference__r.Integration_Status__c')
            .selectField('Xref__r.Business_Reference__r.Default_Type__c')
            .setCondition(
                'WorkOrderId  = :parentWorkOrderId AND WorkOrder.Type__c = :WORK_ORDER_TYPE_DRIVE AND' +
                    ' WorkOrder.Actual_Number_Of_Stores__c = null' +
                    ' AND ((Business_Reference__c != null AND' +
                    ' Business_Reference__r.Integration_Status__c = :FAILURE) OR' +
                    ' (Xref__c != null AND Xref__r.Integration_Status__c = :FAILURE))'
            );
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description Select workplans by passed workorderIDs by Type
     * @JIRA# LEM-8993
     * @param storeAccIds -storeAccountIds
     * @param type - WorkPlanTpe
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByStoreAccountIDAndType(
        Set<Id> storeAccIds,
        Set<String> type
    ) {
        // LEM-18563 - Bypassed CRUD check for this query only during Trigger execution.
        if (Trigger.isExecuting) {
            ignoreCRUD();
        }
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Name')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Name')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Account.ParentId')
            .selectField('WorkOrder.ParentWorkOrder.AccountId')
            .selectField('WorkOrder.ParentWorkOrder.Opportunity__c')
            .setCondition(
                'WorkOrder.AccountID IN :storeAccIds AND Type__c IN :type' +
                ' AND Status__c != :WORK_PLAN_STATUS_DEAD'
            );
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries WorkPlans with WorkOrder and Photoshoot Store Location details.
     * @JIRA# LEM-13504
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithWorkOrderAndPhotoshootStoreLocationDetails(
        Set<Id> workPlanIds
    ) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Creation_Source__c')
            .selectField('WorkOrder.ContactId')
            .selectField('WorkOrder.Reason_for_Additional_Photoshoot__c')
            .selectField('WorkOrder.Reason_if_Other__c')
            .selectField('WorkOrder.Menu_Preview_Link__c')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__c')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.BillingCountryCode')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.BillingStateCode')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.BillingPostalCode')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.BillingStreet')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.BillingCity')
            .selectField('WorkOrder.Store_Location_for_Photoshoot__r.Menu_URL__c')
            .selectField('WorkOrder.Photoshoot_Address__City__s')
            .selectField('WorkOrder.Photoshoot_Address__CountryCode__s')
            .selectField('WorkOrder.Photoshoot_Address__StateCode__s')
            .selectField('WorkOrder.Photoshoot_Address__PostalCode__s')
            .selectField('WorkOrder.Photoshoot_Address__Street__s')
            .selectField('WorkOrder.Photoshoot_Review_Notes_and_Tags__c')
            .selectField('WorkOrder.Photoshoot_Vendor__c')
            .selectField('WorkOrder.Photoshoot_Date__c')
            .selectField('WorkOrder.Photoshoot_Time__c')
            .setCondition(
                'Id IN :workPlanIds AND WorkOrder.Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_DEVELOPERNAME_BUSINESS ' +
                ' AND WorkOrder.ParentWorkOrderId = null AND Type__c =:VENDOR_PHOTOSHOOT'
            );
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries Work Plans with Work Order details by the passed Work Plan Ids and Types.
     * @JIRA# LEM-15318
     * @param workPlanIds - WorkPlanIds
     * @param types - WorkPlanTpe
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByWorkPlanIdsAndTypes(
        Set<Id> workPlanIds,
        Set<String> types
    ) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Name')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrder.Account.BillingCountryCode')
            .selectField('WorkOrder.Account.BillingCity')
            .selectField('WorkOrder.Account.BillingStreet')
            .selectField('WorkOrder.Account.BillingStateCode')
            .selectField('WorkOrder.Account.BillingPostalCode')
            .selectField('WorkOrder.Account.Deck_Rank__c')
            .selectField('WorkOrder.Account.Order_Protocol__c')
            .selectField('WorkOrder.Account.Segment__c')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Creation_Source__c')
            .selectField('WorkOrder.ContactId')
            .selectField('WorkOrder.Order_Protocol__c')
            .selectField('WorkOrder.ParentWorkOrder.ContactId')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Account.ParentId')
            .selectField('WorkOrder.ParentWorkOrderId')
            .selectField('WorkOrder.ParentWorkOrder.Creation_Source__c')
            .selectField('WorkOrder.ParentWorkOrder.Product_Bundle__c')
            .selectField('WorkOrder.ParentWorkOrder.AccountId')
            .selectField('WorkOrder.ParentWorkOrder.Opportunity__c')
            .selectField('WorkOrder.ParentWorkOrder.Order_Protocol__c')
            .selectField('WorkOrder.ParentWorkOrder.Photoshoot_Address__CountryCode__s')
            .selectField('WorkOrder.ParentWorkOrder.Photoshoot_Address__City__s')
            .selectField('WorkOrder.ParentWorkOrder.Photoshoot_Address__Street__s')
            .selectField('WorkOrder.ParentWorkOrder.Photoshoot_Address__StateCode__s')
            .selectField('WorkOrder.ParentWorkOrder.Photoshoot_Address__PostalCode__s')
            .setCondition(
                'Id IN :workPlanIds AND Type__c IN :types' +
                ' AND Status__c != :WORK_PLAN_STATUS_DEAD'
            );

        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It fetches Work Plans with Work Order details using the passed Work Plan Ids.
     * @JIRA# LEM-15997
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithWorkOrderDetailsByParentWorkPlanIds(
        Set<Id> workPlanIds
    ) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Name')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.WorkOrderId')
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.Name')
            .selectField('Number_of_Call_Attempts__c')
            .setCondition('Parent_Work_Plan__c IN :workPlanIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It queries WorkPlans by Email Reference Id.
     * @JIRA LEM-13576
     * @param emailRefIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByEmailRefId(set<String> emailRefIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Status__c')
            .selectField('Email_Reference_Id__c')
            .setCondition('Email_Reference_Id__c IN :emailRefIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It is used to fetch work plan details
     * @JIRA# LEM-13577
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectByWorkPlanIds(Set<Id> workPlanIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Type__c')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.ParentId')
            .selectField('WorkOrder.Account.Parent.Name')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrderId')
            .selectField('Decision_Maker_Email__c')
            .selectField('Email_Reference_Id__c')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.WorkOrderId')
            .selectField('Rescue_Email_Status__c')
            .setCondition('Id IN :workPlanIds');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description Select workplans by passed parent workplan, storeIds and Type
     * @JIRA# LEM-13578
     * @param storeAccIds -storeAccountIds
     * @param type - WorkPlanTpe
     * @param parentWorkplan - parentWorkPlan
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansByParentWorkPlanAndStoreAccount(
        Set<Id> storeAccIds,
        Set<String> type,
        Id parentWorkplan
    ) {
        fflib_QueryFactory workPlanQuery = newQueryFactory()
            .selectField('Name')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Name')
            .selectField('WorkOrderId')
            .selectField('Decision_Maker_Email__c')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.Account.Name')
            .selectField('WorkOrder.Account.RecordType.DeveloperName')
            .selectField('WorkOrder.Type__c')
            .selectField('WorkOrder.Account.ParentId')
            .selectField('WorkOrder.ParentWorkOrder.AccountId')
            .selectField('WorkOrder.ParentWorkOrder.Opportunity__c')
            .setCondition(
                'WorkOrder.AccountID IN :storeAccIds AND WorkOrder.Status !=: STATUS_DEAD AND Type__c IN :type' +
                ' AND Parent_Work_Plan__c =: parentWorkplan '
            );

        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }
    /**
     * @description It queries WorkPlans with WorkOrder associated to Virtual Stores.
     * @JIRA# LEM-21618
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithWorkOrderAssociatedToVirtualStores(Set<Id> workPlanIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory(false)
            .selectField('WorkOrderId')
            .selectField('WorkOrder.AccountId')
            .selectField('WorkOrder.ParentWorkOrderId')
            .selectField('WorkOrder.Segment__c')
            .selectField('WorkOrder.Account_Type__c')
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Is_Virtual_Store__c')
            .selectField('Is_Virtual_Store__c')
            .selectField('Segment__c')
            .setCondition('Id IN :workPlanIds AND WorkOrder.Account_Type__c =: ACCOUNT_TYPE_VIRTUAL'+
                         ' AND Parent_Work_Plan__r.Is_Virtual_Store__c = false'+
                         ' AND Segment__c =: ACCOUNT_SEGMENT_SMB');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }

    /**
     * @description It is used to query WorkPlans with verified POS Intergation Types.
     * @JIRA# LEM-25823
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    public List<WorkPlan> selectWorkPlansWithVerifiedPOSIntegrationTypes(Set<Id> workPlanIds) {
        fflib_QueryFactory workPlanQuery = newQueryFactory(false)
            .selectField('Parent_Work_Plan__c')
            .selectField('Parent_Work_Plan__r.Is_POS_Integration_Verified__c')
            .selectField('Is_POS_Integration_Verified__c')
            .setCondition('Id IN :workPlanIds AND POS_Integration_Type__c IN :VERIFIED_POS_INTEGRATION_TYPES'+
                         ' AND Parent_Work_Plan__r.Is_POS_Integration_Verified__c = false');
        return (List<WorkPlan>) Database.query(workPlanQuery.toSOQL());
    }
}