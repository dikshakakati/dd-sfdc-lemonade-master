/**
 * @author Deloitte
 * @date 04/18/2022
 * @description Test class for WorkStepsSelector class.
 */
@isTest(SeeAllData=false)
private class WorkStepsSelectorTest {
    private static final String ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Inactive';
    private static final string ACCOUNT_BILLING_CITY = 'Missoula';
    private static final string ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final string ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '123 Street';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_BUSINESS_RECORD_TYPE)
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Test KFC';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_STORE_RECORD_TYPE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_STORE_RECORD_TYPE)
        .getRecordTypeId();
    private static final String AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS = 'parentWorkStepId';
    private static final String AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS = 'workStepStatus';
    private static final String AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS = 'workStepsCount';
    private static final String ASSERT_MESSAGE_DELIVER_TABLET_QUERY_FAILED = 'Unexpected result: failed to query Deliver Tablet WorkSteps by Store Account Ids';
    private static final String ASSERT_MESSAGE_QUERY_BY_BUSINESS_FAILED = 'Unexpected result: failed to query WorkSteps by Business Account Ids';
    private static final String ASSERT_MESSAGE_QUERY_BY_WORKPLANID_FAILED = 'Unexpected result: failed to query WorkSteps by Work Plan Ids and store Account Ids';
    private static final String ASSERT_MESSAGE_QUERY_BY_STORE_FAILED = 'Unexpected result: failed to query WorkSteps by Store Account Ids';
    private static final String BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: number of blocked Work Steps count does not match';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Steps count does not match';
    private static final String EXTERNAL_ID = '123456';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String LINK_IMPLEMENTATION_UPDATE_FAILED_ASSERT_MESSAGE = 'Unexpected result: failed to update Link Implementation WorkStep Status to Complete';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Step';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_DEAL_TYPE = 'Standard';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String OPPORTUNITY_SUB_TYPE = 'Upgrade';
    private static final String RESCUE_PROCESS_FAILED_ASSERT_MESSAGE = 'Unexpected result: failed to create Case and populate on WorkStep record';
    private static final String RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: number of resolved Work Steps count does not match';
    private static final String SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step secondary email timer value does not match';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_REASON_INACTIVE_MENU = 'Inactive menu';
    private static final String STATUS_REASON_INVALID_ADDRESS = 'Invalid Address';
    private static final String ULTIMATE_PARENT_WORK_ORDER_CONDITION = 'WorkOrder.ParentWorkOrder.Status NOT IN :WORK_ORDER_PRIORITY_STATUSES';
    private static final String ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD = 'WorkOrder.ParentWorkOrderId';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WO_SUBTYPE_COO = 'COO Same Store';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_ORDER_SUBTYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORKORDER_ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String WORK_PLAN_NAME_TABLET = 'Tablet';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_NAME_STOREFRONT_BUNDLED = 'Storefront Bundled';
    private static final Integer WORK_STEP_COUNT = 5;
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_NAME_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String WORK_STEP_MENU_ERROR_TYPE = 'Formatting';
    private static final String WORK_STEP_NAME = 'Activations Checklist';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step Status does not match';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL = 'Complete - Implemented on the call';
    private static final String WORK_STEP_STATUS_DEAD = 'Dead';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_REASON_OTHER = 'Other';
    private static final String WORK_STEP_STATUS_RESOLVED = 'Resolved';
    private static final String WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_LINK_IMPLEMENTATION = 'Link Implementation';
    private static final String WORK_STEP_TYPE_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String IR_BATCH_ID = 'Batch001';
    private static final String MARKETPLACE = 'Marketplace';
    private static final String GOOGLE_SHEET_URL = 'https://docs.google.com/spreadsheets/test';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkStepsSelector workStepsSelectorInstance = new WorkStepsSelector();
        Schema.SObjectType typeOfObject = workStepsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workStepsSelectorInstance.getSObjectFieldList();
        WorkStepsSelector.newInstance();
        System.assertEquals(
            Schema.WorkStep.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
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
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test aggregate query on Work Step grouped by ParentIds and Status.
     */
    @isTest
    private static void testWhenWorkStepsFilteredThenGroupByParentAndStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(15),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = relatedWorkPlan.Id,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = STATUS_NOT_STARTED
        );
        insert newWorkStep;
        Set<Id> parentIds = new Set<Id>{ parentWorkOrder.Id };
        WorkStepsSelector workStepsInstance = new WorkStepsSelector();
        Aggregate[] workStepsUltimateParentStatus = workStepsInstance.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
            ULTIMATE_PARENT_WORK_ORDER_CONDITION,
            ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
            parentIds
        );
        System.assertEquals(
            1,
            workStepsUltimateParentStatus[0].get('workStepsCount'),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test aggregate query on Work Step grouped by WorkOrderId and Status.
     */
    @isTest
    private static void testWhenWorkStepsCountFilteredByConditionThenGroupByWorkOrderIdAndStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(15),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            WorkOrderId = newWorkOrder.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = relatedWorkPlan.Id,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert newWorkStep;

        Id workOrderID = parentWorkOrder.Id;
        Test.startTest();
        WorkStepsSelector workStepsInstance = new WorkStepsSelector();
        Aggregate[] workStepsUltimateCount = workStepsInstance.getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus(
            workOrderID
        );
        Test.stopTest();
        System.assertEquals(
            1,
            workStepsUltimateCount[0].get('workStepsCount'),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test work order with drive are considered in the aggregate query on Work Step grouped by WorkOrderId and Status.
     */
    @isTest
    private static void testWhenWorkOrderIdPassedThenReturnWorkStepsAggregateResult() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Enterprise'
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(15),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_SUBTYPE_NET_NEW_BUSINESS,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;

        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            WorkOrderId = parentWorkOrder.Id,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = relatedWorkPlan.Id,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert newWorkStep;

        Id workOrderID = parentWorkOrder.Id;
        Test.startTest();
        WorkStepsSelector workStepsInstance = new WorkStepsSelector();
        Aggregate[] workStepsUltimateCount = workStepsInstance.getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus(
            workOrderID
        );
        Test.stopTest();
        System.assertEquals(
            1,
            workStepsUltimateCount[0].get('workStepsCount'),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Work Step for getting Work Order details.
     */
    @isTest
    private static void testWhenWorkStepsFilteredByWorkStepIdsThenWorkStepsWithWorOrderDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            ParentWorkOrderId = parentWorkOrder.Id
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_SETUP_MENU,
            WorkPlanId = relatedWorkPlan.Id,
            Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
            Status__c = STATUS_NOT_STARTED
        );
        insert newWorkStep;
        Test.startTest();
        update new WorkStep(
            Id = newWorkStep.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        Test.stopTest();
        WorkStep updatedWorkStep = [SELECT Id, Status FROM WorkStep WHERE Id = :newWorkStep.Id];
        System.assertEquals(
            true,
            updatedWorkStep.Status == WORK_STEP_STATUS_BLOCKED,
            RESCUE_PROCESS_FAILED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test "Link Implementation Call Outcome" is updated to
     * "Mx to implement link” on "Implemenatation Call" WorkStep then
     * "Link Implementation" WorkStep Status is marked In Progress.
     */
    @isTest
    private static void testWhenCallOutcomeUpdatedToMxToImplementeLinkThenLinkImplementationWorkStepIsInProgress() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_PLAN_NAME_STOREFRONT,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_PLAN_NAME_STOREFRONT,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            ParentWorkOrderId = parentWorkOrder.Id
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep implementationCallWorkStep = new WorkStep(
            Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL
        );
        WorkStep linkImplementationWorkStep = new WorkStep(
            Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION
        );
        insert new List<WorkStep>{ implementationCallWorkStep, linkImplementationWorkStep };
        implementationCallWorkStep.Status__c = WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL;
        Test.startTest();
        update implementationCallWorkStep;
        Test.stopTest();
        WorkStep updatedLinkImplementationWorkStep = [
            SELECT Id, Status__c
            FROM WorkStep
            WHERE Id = :linkImplementationWorkStep.Id
        ];
        System.assertEquals(
            true,
            updatedLinkImplementationWorkStep.Status__c == WORK_STEP_STATUS_COMPLETE,
            LINK_IMPLEMENTATION_UPDATE_FAILED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkStep for getting WorkStep details by Store Account
     * Ids and Deliver Tablet type.
     */
    @isTest
    private static void testWhenWorkStepsFilteredByStoreAccountThenDeliverTabletWorkStepsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Segment__c = 'Enterprise'
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(1),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_DELIVER_TABLET,
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET
        );
        insert newWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getDeliverTabletWorkStepsDetailsByStoreAccount(new Set<Id>{ storeAccount.Id });
        Test.stopTest();
        System.assertEquals(
            newWorkStep.Id,
            workStepsQueryResult[0].Id,
            ASSERT_MESSAGE_DELIVER_TABLET_QUERY_FAILED
        );
    }

    /**
     * @description To test query on Non-Complete WorkSteps by Store Account
     * Ids and Setup Business type.
     */
    @isTest
    private static void testWhenGetNonCompleteSetupBusinessThenWorkStepsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        Account storeAccount2 = new Account(
            Name = 'Store Account 2',
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = '123 Main Street',
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = 'Sarasota',
            BillingPostalCode = '34238',
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = 'Florida'
        );
        insert storeAccount2;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(1),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Opportunity__c = parentOpportunity.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = WORKORDER_ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today().addDays(30),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Order_Protocol__c = WORKORDER_ORDER_PROTOCOL_EMAIL,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(30),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStepDeliverTablet = new WorkStep(
            Name = 'NotReturned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET
        );
        insert newWorkStepDeliverTablet; //Not returned for this test
        WorkStep newWorkStepSetupBusiness = new WorkStep(
            Name = 'Returned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepSetupBusiness; //Returned for this test
        WorkStep newWorkStepCompleted = new WorkStep(
            Name = 'NotReturned2',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepCompleted; //Not Returned for this test
        WorkStep newWorkStepDead = new WorkStep(
            Name = 'NotReturned3',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_DEAD,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepDead; //Not Returned for this test
        //Not Workable is not a valid vaule for Setup Business type.  Status is a dependant picklist.
        WorkStep newWorkStepDifferentAccount = new WorkStep(
            Name = 'NotReturned4',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount2.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepDifferentAccount; //Not Returned for this test

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
                new Set<Id>{ storeAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(
            1,
            workStepsQueryResult.size(),
            'Query returning incorrect number of records.'
        );
        System.assertEquals(
            newWorkStepSetupBusiness.Id,
            workStepsQueryResult[0].Id,
            'Query returning incorrect results.'
        );
    }

    /**
     * @description To test query on Non-Complete COO WorkSteps by Store Account
     * Ids and Setup Business type.
     */
    @isTest
    private static void testWhenGetNonCompleteCOOSetupBusinessThenWorkStepsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        Account storeAccount2 = new Account(
            Name = 'Store Account 2',
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = '123 Main Street',
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = 'Sarasota',
            BillingPostalCode = '34238',
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = 'Florida'
        );
        insert storeAccount2;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(1),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = WORKORDER_ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today().addDays(30),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Order_Protocol__c = WORKORDER_ORDER_PROTOCOL_EMAIL,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(30),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep newWorkStepDeliverTablet = new WorkStep(
            Name = 'NotReturned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET
        );
        insert newWorkStepDeliverTablet; //Not returned for this test
        WorkStep newWorkStepSetupBusiness = new WorkStep(
            Name = 'Returned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepSetupBusiness; //Returned for this test
        WorkStep newWorkStepCompleted = new WorkStep(
            Name = 'NotReturned2',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepCompleted; //Not Returned for this test
        WorkStep newWorkStepDead = new WorkStep(
            Name = 'NotReturned3',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_DEAD,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepDead; //Not Returned for this test
        //Not Workable is not a valid vaule for Setup Business type.  Status is a dependant picklist.
        WorkStep newWorkStepDifferentAccount = new WorkStep(
            Name = 'NotReturned4',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount2.Id,
            Type__c = WORK_STEP_TYPE_SETUP_BUSINESS
        );
        insert newWorkStepDifferentAccount; //Not Returned for this test

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(new Set<Id>{ storeAccount.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            workStepsQueryResult.size(),
            'Query returning incorrect number of records.'
        );
        System.assertEquals(
            newWorkStepSetupBusiness.Id,
            workStepsQueryResult[0].Id,
            'Query returning incorrect results.'
        );
    }
    /**
     * @description To test query on Non-Complete WorkSteps by Store Account
     * Ids and Setup Store type.
     */
    @isTest
    private static void testWhenGetNonCompleteSetupStoreThenWorkStepsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        Account storeAccount2 = new Account(
            Name = 'Store Account 2',
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = '123 Main Street',
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = 'Sarasota',
            BillingPostalCode = '34238',
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = 'Florida'
        );
        insert storeAccount2;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(1),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Opportunity__c = parentOpportunity.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkOrder parentRateChangeWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_SUBTYPE_RATE_CHANGE,
            Type__c = WORK_ORDER_TYPE_POST_SALES,
            Opportunity__c = parentOpportunity.Id
        );
        insert parentRateChangeWorkOrder;
        WorkOrder rateChangeWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_POST_SALES,
            Sub_Type__c = WORK_ORDER_SUBTYPE_RATE_CHANGE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentRateChangeWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert rateChangeWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkPlan rateChangeWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = rateChangeWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert rateChangeWorkPlan;

        WorkStep newWorkStepDeliverTablet = new WorkStep(
            Name = 'NotReturned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET
        );
        insert newWorkStepDeliverTablet; //Not returned for this test
        WorkStep newWorkStepSetupBusiness = new WorkStep(
            Name = 'Returned1',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_STORE
        );
        insert newWorkStepSetupBusiness; //Returned for this test
        WorkStep newWorkStepCompleted = new WorkStep(
            Name = 'NotReturned2',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_STORE
        );
        insert newWorkStepCompleted; //Not Returned for this test
        WorkStep newWorkStepDead = new WorkStep(
            Name = 'NotReturned3',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_DEAD,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_STEP_TYPE_SETUP_STORE
        );
        insert newWorkStepDead; //Not Returned for this test
        WorkStep newWorkStepDifferentAccount = new WorkStep(
            Name = 'NotReturned5',
            WorkPlanId = relatedWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount2.Id,
            Type__c = WORK_STEP_TYPE_SETUP_STORE
        );
        insert newWorkStepDifferentAccount;
        WorkStep newWorkStepRateChange = new WorkStep(
            Name = 'Returned2',
            WorkPlanId = rateChangeWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id,
            Type__c = WORK_ORDER_SUBTYPE_RATE_CHANGE
        );
        insert newWorkStepRateChange; //Not Returned for this test different Account

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getNonCompleteSetupStoreWorkStepsByStoreAccount(new Set<Id>{ storeAccount.Id });
        Test.stopTest();
        System.assertEquals(
            2,
            workStepsQueryResult.size(),
            'Query returning incorrect number of records.'
        );
        System.assertEquals(
            newWorkStepSetupBusiness.Id,
            workStepsQueryResult[0].Id,
            'Query returning incorrect results.'
        );
    }

    /**
     * @description To test query on WorkStep for getting the child Work Step details
     * by the passed parent WorkStep Ids.
     */
    @isTest
    private static void testWhenSelectChildWorkStepsByParentWorkStepIdsCalledThenWorkStepsDetailsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        businessAccount.Segment__c = 'Enterprise';
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = businessAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = parentWorkPlan.Id
        );
        insert parentWorkStep;
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkPlan;
        List<WorkStep> newWorkStepRecords = new List<WorkStep>{
            new WorkStep(
                Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
                Parent_Work_Step__c = parentWorkStep.Id,
                Status__c = STATUS_NOT_STARTED,
                Status_Reason__c = STATUS_REASON_INACTIVE_MENU,
                Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
                WorkPlanId = childWorkPlan.Id
            ),
            new WorkStep(
                Name = WORK_STEP_SETUP_STORE,
                Parent_Work_Step__c = parentWorkStep.Id,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Status_Reason__c = STATUS_REASON_INVALID_ADDRESS,
                Type__c = WORK_STEP_SETUP_STORE,
                WorkPlanId = childWorkPlan.Id
            ),
            new WorkStep(
                Name = WORK_STEP_SETUP_STOREFRONT_PAGE,
                Parent_Work_Step__c = parentWorkStep.Id,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
                Type__c = WORK_STEP_SETUP_STOREFRONT_PAGE,
                WorkPlanId = childWorkPlan.Id
            ),
            new WorkStep(
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Parent_Work_Step__c = parentWorkStep.Id,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = childWorkPlan.Id
            ),
            new WorkStep(
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Parent_Work_Step__c = parentWorkStep.Id,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = childWorkPlan.Id
            )
        };
        insert newWorkStepRecords;
        Set<Id> workStepIds = new Set<Id>{ parentWorkStep.Id };
        Test.startTest();
        List<WorkStep> workSteps = WorkStepsSelector.newInstance()
            .selectChildWorkStepsByParentWorkStepIds(workStepIds);
        Test.stopTest();
        System.assertEquals(false, workSteps.isEmpty(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(WORK_STEP_COUNT, workSteps.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test query on WorkStep for getting the Work Step details
     * by the passed parent WorkOrder Ids .
     */
    @isTest
    private static void testWhenSelectWorkStepsByWorkOrderIdsCalledThenWorkStepsWithWorkOrderDetailsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        businessAccount.Segment__c = 'Enterprise';
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = businessAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(5),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Status__c = STATUS_NOT_STARTED,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = parentWorkPlan.Id
        );
        insert parentWorkStep;
        Test.startTest();
        List<WorkStep> workSteps = WorkStepsSelector.newInstance()
            .selectWorkStepsByWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        Test.stopTest();
        System.assertEquals(false, workSteps.isEmpty(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(1, workSteps.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test query on WorkStep for getting the number of Blocked
     * and Resolved child WorkSteps by the passed parent WorkStep Ids.
     */
    @isTest
    private static void testWhenParentWorkStepIdsPassedThenCountOfBlackedAndResolvedChildWorkStepsReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Corporate_Owned_Store_Count__c = 1;
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = parentAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            parentAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        insert childWorkOrder;
        WorkPlan parentWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = ServiceIntegrationDataBuilder.createWorkStepInstance(
            parentWorkPlan.Id
        );
        insert parentWorkStep;
        WorkPlan childWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            childWorkOrder.Id
        );
        childWorkPlan.Parent_Work_Plan__c = parentWorkPlan.Id;
        insert childWorkPlan;
        List<WorkStep> newWorkStepRecords = new List<WorkStep>{
            ServiceIntegrationDataBuilder.createChildWorkStepInstance(
                parentWorkStep.Id,
                WORK_STEP_STATUS_BLOCKED,
                childWorkPlan.Id
            ),
            ServiceIntegrationDataBuilder.createChildWorkStepInstance(
                parentWorkStep.Id,
                WORK_STEP_STATUS_BLOCKED,
                childWorkPlan.Id
            ),
            ServiceIntegrationDataBuilder.createChildWorkStepInstance(
                parentWorkStep.Id,
                WORK_STEP_STATUS_RESOLVED,
                childWorkPlan.Id
            ),
            ServiceIntegrationDataBuilder.createChildWorkStepInstance(
                parentWorkStep.Id,
                WORK_STEP_STATUS_RESOLVED,
                childWorkPlan.Id
            ),
            ServiceIntegrationDataBuilder.createChildWorkStepInstance(
                parentWorkStep.Id,
                WORK_STEP_STATUS_IN_PROGRESS,
                childWorkPlan.Id
            )
        };
        insert newWorkStepRecords;
        Set<Id> parentIds = new Set<Id>{ parentWorkStep.Id };
        WorkStepsSelector workStepsInstance = new WorkStepsSelector();
        Aggregate[] workStepQueryAggregateResult = workStepsInstance.getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(
            parentIds
        );
        Map<Id, Map<String, Integer>> parentWorkStepIdToStatusToCount = new Map<Id, Map<String, Integer>>();
        Id parentWorkStepId;
        String workStepStatus;
        for (Aggregate eachAggregate : workStepQueryAggregateResult) {
            parentWorkStepId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKSTEPID_FIELD_ALIAS);
            workStepStatus = (String) eachAggregate.get(AGGREGATE_WORK_STEP_STATUS_FIELD_ALIAS);
            if (!parentWorkStepIdToStatusToCount.containsKey(parentWorkStepId)) {
                parentWorkStepIdToStatusToCount.put(parentWorkStepId, new Map<String, Integer>());
            }
            if (
                !parentWorkStepIdToStatusToCount.get(parentWorkStepId).containsKey(workStepStatus)
            ) {
                parentWorkStepIdToStatusToCount.get(parentWorkStepId)
                    .put(
                        workStepStatus,
                        Integer.valueOf(
                            eachAggregate.get(AGGREGATE_NUMBER_OF_CHILD_WORKSTEPS_ALIAS)
                        )
                    );
            }
        }
        Map<String, Integer> workStepStatusToCount = parentWorkStepIdToStatusToCount.get(
            parentWorkStepId
        );
        Integer numberOfBlockedWorkSteps = workStepStatusToCount.get(WORK_STEP_STATUS_BLOCKED);
        Integer numberOfResolvedWorkSteps = workStepStatusToCount.get(WORK_STEP_STATUS_RESOLVED);
        System.assertEquals(
            2,
            numberOfBlockedWorkSteps,
            BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            2,
            numberOfResolvedWorkSteps,
            RESOLVED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkStep for getting the WorkStep details
     * based on WorkStep Ids.
     */
    @isTest
    private static void testWhenWorkStepIdsPassedThenWorkStepsDetailsReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        parentAccount.Corporate_Owned_Store_Count__c = 1;
        insert parentAccount;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = parentAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            parentAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.id;
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkStep parentWorkStep = ServiceIntegrationDataBuilder.createWorkStepInstance(
            parentWorkPlan.Id
        );
        parentWorkStep.Number_of_Blocked_Work_Steps__c = 2;
        parentWorkStep.Secondary_Email_Timer_Start_Time__c = System.now();
        parentWorkStep.Status__c = WORK_STEP_STATUS_BLOCKED;
        insert parentWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectById(new Set<Id>{ parentWorkStep.Id });
        Test.stopTest();
        System.assertEquals(
            false,
            workStepsQueryResult.isEmpty(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            2,
            workStepsQueryResult[0].Number_of_Blocked_Work_Steps__c,
            BLOCKED_WORKSTEP_COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_STEP_STATUS_BLOCKED,
            workStepsQueryResult[0].Status__c,
            WORK_STEP_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            System.now().dateGMT(),
            workStepsQueryResult[0].Secondary_Email_Timer_Start_Time__c.dateGMT(),
            SECONDARY_EMAIL_TIMER_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the query returns "Setup Storefront Page" Work Step for
     * the first "Not Workable" Work Step of Storefront Work Plan associated with store Account.
     *
     **/
    @isTest
    private static void testWhenSelectFirstStorefrontWorkStepByStoreAccountIdsCalledThenSetupStorefrontPageWorkStepOfStorefrontReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert corporateOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = parentAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentStorefrontWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            parentAccount.Id,
            WORK_ORDER_TYPE_STOREFRONT
        );
        parentStorefrontWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentStorefrontWorkOrder;

        WorkOrder storefrontWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_STOREFRONT
        );
        storefrontWorkOrder.ParentWorkOrderId = parentStorefrontWorkOrder.Id;
        insert storefrontWorkOrder;
        WorkPlan storefrontWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            storefrontWorkOrder.Id
        );
        storefrontWorkPlan.Name = WORK_PLAN_NAME_STOREFRONT;
        insert storefrontWorkPlan;
        List<WorkStep> workStepsToInsert = new List<WorkStep>();
        WorkStep setupStorefrontPage = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        setupStorefrontPage.Name = WORK_STEP_SETUP_STOREFRONT_PAGE;
        setupStorefrontPage.Type__c = WORK_STEP_SETUP_STOREFRONT_PAGE;
        setupStorefrontPage.ExecutionOrder = 1;
        setupStorefrontPage.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(setupStorefrontPage);
        WorkStep implementationCall = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        implementationCall.Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL;
        implementationCall.Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL;
        implementationCall.ExecutionOrder = 2;
        implementationCall.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(implementationCall);
        WorkStep linkImplementation = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        linkImplementation.Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION;
        linkImplementation.Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION;
        linkImplementation.ExecutionOrder = 3;
        linkImplementation.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(linkImplementation);
        insert workStepsToInsert;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectFirstStorefrontWorkStepByStoreAccountIds(new Set<Id>{ storeAccount.Id });
        Test.stopTest();
        System.assertEquals(
            false,
            workStepsQueryResult.isEmpty(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            setupStorefrontPage.Id,
            workStepsQueryResult[0].Id,
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the query returns "Setup Store" Work Step for the first
     * "Not Workable" Work Step of Storefront Bundled Work Plan associated with store Account.
     *
     **/
    @isTest
    private static void testWhenSelectFirstStorefrontWorkStepByStoreAccountIdsCalledThenSetupStoreWorkStepOfStorefrontBundledReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert corporateOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = parentAccount.Id,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentStorefrontWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            parentAccount.Id,
            WORK_ORDER_TYPE_STOREFRONT
        );
        parentStorefrontWorkOrder.Opportunity__c = parentOpportunity.id;
        insert parentStorefrontWorkOrder;
        WorkOrder storefrontWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_STOREFRONT
        );
        storefrontWorkOrder.ParentWorkOrderId = parentStorefrontWorkOrder.Id;
        insert storefrontWorkOrder;
        WorkPlan storefrontWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            storefrontWorkOrder.Id
        );
        storefrontWorkPlan.Name = WORK_PLAN_NAME_STOREFRONT_BUNDLED;
        insert storefrontWorkPlan;
        List<WorkStep> workStepsToInsert = new List<WorkStep>();
        WorkStep setupStore = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        setupStore.Name = WORK_STEP_SETUP_STOREFRONT_PAGE;
        setupStore.Type__c = WORK_STEP_SETUP_STOREFRONT_PAGE;
        setupStore.ExecutionOrder = 1;
        setupStore.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(setupStore);
        WorkStep setupStorefrontPage = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        setupStorefrontPage.Name = WORK_STEP_SETUP_STORE;
        setupStorefrontPage.Type__c = WORK_STEP_SETUP_STORE;
        setupStorefrontPage.ExecutionOrder = 2;
        setupStorefrontPage.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(setupStorefrontPage);
        WorkStep implementationCall = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        implementationCall.Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL;
        implementationCall.Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL;
        implementationCall.ExecutionOrder = 3;
        implementationCall.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(implementationCall);
        WorkStep linkImplementation = ServiceIntegrationDataBuilder.createWorkStepInstance(
            storefrontWorkPlan.Id
        );
        linkImplementation.Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION;
        linkImplementation.Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION;
        linkImplementation.ExecutionOrder = 4;
        linkImplementation.Store_Account__c = storeAccount.Id;
        workStepsToInsert.add(linkImplementation);
        insert workStepsToInsert;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectFirstStorefrontWorkStepByStoreAccountIds(new Set<Id>{ storeAccount.Id });
        Test.stopTest();
        System.assertEquals(
            false,
            workStepsQueryResult.isEmpty(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            setupStore.Id,
            workStepsQueryResult[0].Id,
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Non-Complete WorkSteps by Store Account Ids
     */
    @isTest
    private static void testWhenGetNonCompleteWorkstepsByStoresThenWorkStepsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkPlan workPlan = new workplan(
            WorkOrderId = newWorkOrder.Id,
            Name = WORK_PLAN_NAME_STOREFRONT
        );
        insert workPlan;
        WorkStep workStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = workPlan.Id,
            Number_of_Blocked_Work_Steps__c = 2,
            Secondary_Email_Timer_Start_Time__c = System.now(),
            Status__c = STATUS_NOT_STARTED,
            Store_Account__c = storeAccount.Id
        );
        insert workStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
                new Set<Id>{ storeAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(
            workStep.Id,
            workStepsQueryResult[0].Id,
            ASSERT_MESSAGE_QUERY_BY_STORE_FAILED
        );
    }

    /**
     * @description To test query on Non-Complete WorkSteps by workorder business Account Ids
     */
    @isTest
    private static void testWhenGetNonCompleteSetupBusinessAccountThenWorkStepsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert newWorkOrder;
        WorkPlan workPlan = new workplan(
            WorkOrderId = newWorkOrder.Id,
            Name = WORK_PLAN_NAME_STOREFRONT
        );
        insert workPlan;
        WorkStep workStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = workPlan.Id,
            Number_of_Blocked_Work_Steps__c = 2,
            Secondary_Email_Timer_Start_Time__c = System.now(),
            Status__c = STATUS_NOT_STARTED
        );
        insert workStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .getNonCompleteWorkStepRecForDriveByBusinessAccount(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(
            workStep.Id,
            workStepsQueryResult[0].Id,
            ASSERT_MESSAGE_QUERY_BY_BUSINESS_FAILED
        );
    }

    /**
     * @description To validate the query returns child Work Steps by using the passed
     * store Account and child Work Order Id.
     */
    @isTest
    private static void testWhenStoreIdAndChildWorkOrderIdPassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_DELIVER_TABLET,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_DELIVER_TABLET,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectByStoreAccountAndWorkOrderIds(
                new Set<Id>{ storeAccount.Id },
                new Set<Id>{ childWorkOrder.Id },
                new Set<String>{ WORK_STEP_NAME_DELIVER_TABLET }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            childWorkStep.Id,
            workStepsQueryResult[0].Id,
            ASSERT_MESSAGE_QUERY_BY_WORKPLANID_FAILED
        );
    }

    /**
     * @description To validate the query returns child Work Steps by using the passed
     * store Account and parent Work Order Id.
     */
    @isTest
    private static void testWhenStoreIdAndParentWorkOrderIdPassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_DELIVER_TABLET,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_NAME_DELIVER_TABLET,
            Type__c = WORK_STEP_NAME_DELIVER_TABLET,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectByStoreAccountAndWorkOrderIds(
                new Set<Id>{ storeAccount.Id },
                new Set<Id>{ parentWorkOrder.Id },
                new Set<String>{ WORK_STEP_NAME_DELIVER_TABLET }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            childWorkStep.Id,
            workStepsQueryResult[0].Id,
            ASSERT_MESSAGE_QUERY_BY_WORKPLANID_FAILED
        );
    }
    /**
     * @description To validate the query returns child Work Steps by using the passed
     * Parent WorkOrder Ids
     */
    @isTest
    private static void testWhenParentWorkOrderIdPassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectAllChildWorkStepsByParentWorkOrderID(new Set<Id>{ parentWorkOrder.Id });
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns child Work Steps by using the passed
     * Store Account ids Ids and BatchID
     */
    @isTest
    private static void testWhenStoreAccountIDAndBatchIDdPassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectChildWorkStepsByStoreAccountIdsAndBatchId(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ IR_BATCH_ID }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns child Work Steps by using the passed
     * Store Account ids Ids and BatchID and workstep type
     */
    @isTest
    private static void testWhenStoreAccountIDAndTypeAndBatchIDdPassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ 'COO Same Store' },
                new Set<String>{ IR_BATCH_ID }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns child Work Steps by using the passed
     * Store Account ids Ids and workstep type
     */
    @isTest
    private static void testWhenStoreAccountIDAndTypePassedThenReturnChildWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectChildWorkStepsByStoreAccountIdsAndType(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ 'COO Same Store' }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns Work Steps where Status is Blocked by
     * using the passed Work Order ids Ids.
     */
    @isTest
    private static void testWhenWorkOrderIdsPassedThenReturnBlockedWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enterprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WO_SUBTYPE_COO,
            Type__c = WO_SUBTYPE_COO,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectWorkStepsByWorkOrderIdsAndStatuses(
                new Set<Id>{ parentWorkOrder.Id },
                new Set<String>{ WORK_STEP_STATUS_BLOCKED }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns child Work Steps using the passed
     * parent Work Plan Id and Work Step Name.
     */
    @isTest
    private static void testWhenParentWorkPlanIdAndWorkStepNamePassedThenReturnWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = 'Enterprise';
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enteprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_NAME,
            Type__c = WORK_STEP_NAME,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_NAME,
            Parent_Work_Step__c = parentWorkStep.Id,
            Type__c = WORK_STEP_NAME,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectChildWorkStepsByWorkPlan(parentWorkPlan.Id, WORK_STEP_NAME);
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns Work Steps using the passed
     * store ids and Work Step Types.
     */
    @isTest
    private static void testWhenStoreIdsAndWorkStepTypesPassedThenReturnWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE,
            Estimated_Number_of_Stores__c = 1
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Parent_Work_Step__c = parentWorkStep.Id,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert childWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectWorkStepsByTypesAndStoreAccountIds(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE }
            );
        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the query returns no Work Steps using the passed
     * store ids and Work Step Types.
     */
    @isTest
    private static void testWhenStoreIdsAndWorkStepTypesPassedThenReturnNoWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE,
            Estimated_Number_of_Stores__c = 1
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            Parent_Work_Step__c = parentWorkStep.Id,
            Type__c = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert childWorkStep;
        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance()
            .selectWorkStepsByTypesAndStoreAccountIds(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ WORK_STEP_TYPE_SETUP_BUSINESS }
            );
        Test.stopTest();
        System.assertEquals(0, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

     /**
     * @description To query Work Steps using the passed parent Work Plan Ids.
     */
    @isTest
    private static void testWhenParentWorkPlanIdsPassedThenReturnWorkSteps() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = 'Enteprise';
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = parentWorkOrder.Id,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_TABLET,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;
        WorkStep parentWorkStep = new WorkStep(
            Name = WORK_STEP_NAME,
            Type__c = WORK_STEP_NAME,
            WorkPlanId = parentWorkPlan.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert parentWorkStep;
        WorkStep childWorkStep = new WorkStep(
            Name = WORK_STEP_NAME,
            Parent_Work_Step__c = parentWorkStep.Id,
            Type__c = WORK_STEP_NAME,
            WorkPlanId = childWorkPlan.Id,
            Store_Account__c = storeAccount.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED
        );
        insert childWorkStep;

        Test.startTest();
        List<WorkStep> workStepsQueryResult = WorkStepsSelector.newInstance().
            selectChildWorkStepsByWorkPlan(parentWorkPlan.Id, WORK_STEP_NAME);

        Test.stopTest();
        System.assertEquals(1, workStepsQueryResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }
}
