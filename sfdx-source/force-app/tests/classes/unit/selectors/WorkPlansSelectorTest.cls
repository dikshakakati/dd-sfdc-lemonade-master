/**
 * @author Deloitte
 * @date 15/04/2022
 * @description Test class for WorkPlansSelector class.
 */
@isTest(seeAllData=false)
private class WorkPlansSelectorTest {
    private static final string ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final string ACCOUNT_BILLING_CITY = 'Missoula';
    private static final string ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final string ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final string ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final string BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String ASSERT_MESSAGE_STORE_ACCOUNT_DO_NOT_MATCH = 'Unexpected result: query on WorkPlan with WorkOrder returned incorrect result';
    private static final String ASSERT_MESSAGE_ID_DO_NOT_MATCH = 'Unexpected result: query on WorkPlan with WorkOrder returned incorrect Id';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Steps count does not match';
    private static final String DEAL_TYPE_STANDARD = 'Standard';
    private static final string FIELD_VALUE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: Work Plan field is not fetched with expected value';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String GOOGLE_SHEET_URL = 'https://docs.google.com/spreadsheets/test';
    private static final String INCORRECT_DATA_ASSERT_MESSAGE = 'Incorrect data returned';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Plan';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS = 'childWorkPlans';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_SUM_ALIAS = 'workableWorkSteps';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS = 'validationStatus';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_PLANNING = 'Planning';
    private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String SUCCESS = 'Success';
    private static final String TEST_NOTES = 'Notes Test';
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String WORKABLE_WORKSTEPS_ERROR_ASSERT_MESSAGE = 'Unexpected result: Number of workable Worksteps count is not matching';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_PLAN_NAME = 'COO Test';
    private static final String WORK_PLAN_TEMPLATE_NAME_COO = 'COO';
    private static final String WORK_PLAN_DETAILS_ASSERT_MESSAGE = 'Unexpected result: incorrect WorkPlan and child WorkPlan records are returned';
    private static final String WORK_PLAN_SELECTBYID_ASSERT_MESSAGE = 'Unexpected result: incorrect WorkPlan records are returned';
    private static final String WORK_PLAN_FIELD_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: incorrect field mismatch';
    private static final String WORK_STEP_NAME_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'DriveDb';
    private static final String STORE_ID = '24680';
    private static final String WORK_PLAN_NAME_POS = 'POS';
    private static final String WORK_PLAN_NAME_VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final String WORK_PLAN_NAME_MARKETING_KIT = 'Marketing Kit';
    private static final Set<String> WORK_PLAN_SET_TYPE_POS = new Set<String>{ 'POS' };
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';
    private static final String WORK_PLAN_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String EMAIL_REFERENCE_ID_END_KEYWORD = ':ref';
    private static final String EMAIL_REFERENCE_ID_START_KEYWORD = 'ref:';
    private static final String FULL_STOP_SEPARATOR = '.';
    private static final String ACCOUNT_TYPE_VIRTUAL = 'Virtual';
    private static final String ACCOUNT_TYPE_FOOD_TRUCK = 'Food Truck';
    private static final String POS_INTEGRATION_TYPE_CLOVER = 'clover';
    private static final String POS_INTEGRATION_TYPE_ADORA = 'adora';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkPlansSelector workPlansSelectorInstance = new WorkPlansSelector();
        Schema.SObjectType typeOfObject = workPlansSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workPlansSelectorInstance.getSObjectFieldList();
        WorkPlansSelector.newInstance();
        System.assertEquals(
            Schema.WorkPlan.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkPlan.Id,
                WorkPlan.Name,
                WorkPlan.Parent_Work_Order_Creation_Source__c,
                WorkPlan.Parent_Work_Plan__c,
                WorkPlan.Type__c,
                WorkPlan.Status__c,
                WorkPlan.WorkOrderId
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkPlans when Parent WorkPlanIds are passed
     * then sum of number of workable Worksteps are returned..
     */
    @isTest
    private static void testWhenParentWorkPlanIdsdsArePassedThenSumOfWorkableWorkStepsAreReturned() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id
        );
        insert relatedParentWorkPlan;
        WorkPlan relatedChildWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = childWorkOrder.Id,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id
        );
        insert relatedChildWorkPlan;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
            IsActive = true,
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workPlanTemplate;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workOrderTemplate;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_TYPE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_ORDER_TYPE_DRIVE,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_ORDER_TYPE_DRIVE,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = newWorkOrder.Id
        );
        insert childWorkPlan;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectByIdAndStoreAccountRecordType(
            relatedWorkPlan.Id
        );
        // Parent Work Plan and Child Work Plan are selected with Account details.
        System.assertEquals(2, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test Work Plan query on passing COO parent WorkPlan Id.
     */
    @isTest
    private static void testWhenCOOParentWorkPlanIdReceivedThenFetchWorkPlansWithStoreAccounts() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
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
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkPlan;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectByIdAndStoreAccountRecordType(
            relatedWorkPlan.Id
        );
        // Only Child Work Plan is selected with Account details for COO Type.
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test Work Plan query on passing child WorkPlan Id.
     */
    @isTest
    private static void testWhenChildWorkPlanIdGivenThenFetchWorkPlansWithStoreAccounts() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
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
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert childWorkPlan;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectByIdAndStoreAccountRecordType(
            childWorkPlan.Id
        );
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            newWorkOrder.Id,
            workPlanRecord[0].WorkOrderId,
            ASSERT_MESSAGE_ID_DO_NOT_MATCH
        );
        System.assertEquals(
            storeAccount.Id,
            workPlanRecord[0].WorkOrder.AccountId,
            ASSERT_MESSAGE_ID_DO_NOT_MATCH
        );
    }

    /**
     * @description To test query on WorkPlan by passing WorkPlan Ids
     * returns WorkPlan with WorkOrder details.
     */
    @isTest
    private static void testWhenSelectWorkPlansWithWorkOrderDetailsIsCalledThenWorkPlansWithWorkOrdersIsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
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
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlanTemplate cooWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_COO
        );
        insert cooWorkPlanTemplate;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = childWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Work_Plan_Template__c = cooWorkPlanTemplate.Id
        );
        insert childWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderDetails(new Set<Id>{ childWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            storeAccount.Id,
            workPlansResult[0].WorkOrder.AccountId,
            ASSERT_MESSAGE_STORE_ACCOUNT_DO_NOT_MATCH
        );
    }

    /**
     * @description To test query on WorkPlan when set of Ids are passed.
     */
    @isTest
    private static void testWhenSelectByIdCalledThenWorkPlansReturned() {
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(20),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id
        );
        insert relatedParentWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectById(new Set<Id>{ relatedParentWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            WORK_PLAN_NAME,
            workPlansResult[0].Name,
            WORK_PLAN_SELECTBYID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkPlan when set of Ids are passed.
     */
    @isTest
    private static void testWhenSelectByIdCalledThenParentAndChildWorkPlansReturned() {
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id
        );
        insert relatedParentWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithChildWorkPlanDetails(new Set<String>{ relatedParentWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
    }

    /**
     * @description To test Work Plan query on passing Parent Work Plan Id.
     */
    @isTest
    private static void testWhenParentWorkPlanGivenThenFetchIntegrationInfoForChildWorkPlans() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Business_Reference__c busRefFailure = new Business_Reference__c();
        busRefFailure.Integration_Status__c = STATUS_FAILURE;
        insert busRefFailure;
        Xref__c xrefFailure = new Xref__c();
        xrefFailure.Integration_Status__c = STATUS_FAILURE;
        xrefFailure.External_ID__c = 'abc123';
        xrefFailure.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xrefFailure.Salesforce_Account_Name__c = storeAccount.Id;
        insert xrefFailure;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkPlan childWorkPlanBusinessRef = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = busRefFailure.Id
        );
        insert childWorkPlanBusinessRef;
        WorkPlan childWorkPlanXref = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Xref__c = xrefFailure.Id
        );
        insert childWorkPlanXref;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecords = workPlansInstance.selectIntegrationInfoForWorkPlansByParentWorkPlanId(
            relatedWorkPlan.Id
        );
        System.assertEquals(2, workPlanRecords.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        Set<Id> workPlanQueryResultIds = new Map<Id, WorkPlan>(workPlanRecords).keySet();
        System.assertEquals(
            true,
            workPlanQueryResultIds.contains(childWorkPlanBusinessRef.Id),
            'Incorrect WorkPlan selected'
        );
        System.assertEquals(
            true,
            workPlanQueryResultIds.contains(childWorkPlanXref.Id),
            'Incorrect WorkPlan selected'
        );
        //This field is not set in the test data but make sure we don't get an exception when trying to read it.
        System.assertEquals(
            workPlanRecords[0].Xref__r.Business_Reference__r.Integration_Status__c,
            null,
            'Field not returned in SOQL query'
        );
    }

    /**
     * @description It is used to check whether the Xref with “Integration Status” as ‘Waiting for Business’
     * and Business Reference with “Integration Status” as ‘Success’ returned on passing Parent Work Plan Id.
     */
    @isTest
    private static void testWhenParentWorkPlanGivenThenReturnXrefWithWaitingForBusinessIntegrationStatusAndBizRefWithSuccessIntegrationStatusRelatedToChildWorkPlans() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Business_Reference__c businessReference = new Business_Reference__c();
        businessReference.Integration_Status__c = SUCCESS;
        insert businessReference;
        Xref__c xref = new Xref__c();
        xref.Business_Reference__c = businessReference.Id;
        xref.Integration_Status__c = WAITING_FOR_BUSINESS;
        xref.External_ID__c = 'abc123';
        xref.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xref.Salesforce_Account_Name__c = storeAccount.Id;
        insert xref;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkPlan childWorkPlanBusinessRef = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = businessReference.Id
        );
        insert childWorkPlanBusinessRef;
        WorkPlan childWorkPlanXref = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Xref__c = xref.Id
        );
        insert childWorkPlanXref;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecords = workPlansInstance.selectIntegrationInfoForWorkPlansByParentWorkPlanId(
            relatedWorkPlan.Id
        );
        System.assertEquals(1, workPlanRecords.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            workPlanRecords[0].Xref__r.Business_Reference__r.Integration_Status__c,
            SUCCESS,
            INCORRECT_DATA_ASSERT_MESSAGE
        );
        System.assertEquals(
            workPlanRecords[0].Xref__r.Integration_Status__c,
            WAITING_FOR_BUSINESS,
            INCORRECT_DATA_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Work Plan query to get integration info by passing parent Work Plan Id
     * without any associated stores.
     */
    @isTest
    private static void testWhenDriveParentWorkPlanPassedThenIntegrationInfoReceivedWithoutChildWorkPlans() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c ='SMB'
        );
        insert parentAccount;
        Business_Reference__c busRefFailure = new Business_Reference__c();
        busRefFailure.Integration_Status__c = STATUS_FAILURE;
        insert busRefFailure;
        Xref__c xrefFailure = new Xref__c();
        xrefFailure.Integration_Status__c = STATUS_FAILURE;
        xrefFailure.External_ID__c = 'abc123';
        xrefFailure.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xrefFailure.Salesforce_Account_Name__c = parentAccount.Id;
        insert xrefFailure;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            parentAccount.Id,
            true
        );
        WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
            IsActive = true,
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workPlanTemplate;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workOrderTemplate;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_TYPE,
            Type__c = WORK_ORDER_TYPE_DRIVE,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert parentWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = busRefFailure.Id,
            Xref__c = xrefFailure.Id
        );
        insert relatedWorkPlan;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectIntegrationInfoForWorkPlansByParentWorkPlanId(
            relatedWorkPlan.Id
        );
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            xrefFailure.Id,
            workPlanRecord[0].Xref__c,
            'Field not returned in SOQL query'
        );
        System.assertEquals(
            busRefFailure.Id,
            workPlanRecord[0].Business_Reference__c,
            'Field not returned in SOQL query'
        );
    }

    /**
     * @description To test query on WorkPlan when set of Ids are passed.
     */
    @isTest
    private static void testWhenSelectByIntegrationRequestIdThenReturnWorkPlans() {
        Account parentAccount = new Account(Name = PARENT_ACCOUNT_NAME, Segment__c = 'SMB');
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            parentAccount.Id,
            true
        );
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().adddays(7),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        Integration_Request__c irRequest = ServiceIntegrationDataBuilder.createIntegrationRequestInstance(
            STORE_ID
        );
        insert irRequest;

        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id,
            Integration_request__c = irRequest.Id
        );
        insert relatedParentWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansByIntegrationRequestId(new Set<Id>{ irRequest.Id });
        Test.stopTest();
        System.assertEquals(
            WORK_PLAN_NAME,
            workPlansResult[0].Name,
            WORK_PLAN_SELECTBYID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on child work plan when set of parent work plan Ids are passed.
     */
    @isTest
    private static void testWhenParentWorkPlanIdsArePassedThenChildWorkPlansReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Business_Reference__c busRefFailure = new Business_Reference__c();
        busRefFailure.Integration_Status__c = STATUS_FAILURE;
        insert busRefFailure;
        Xref__c xrefFailure = new Xref__c();
        xrefFailure.Integration_Status__c = STATUS_FAILURE;
        xrefFailure.External_ID__c = 'abc123';
        xrefFailure.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xrefFailure.Salesforce_Account_Name__c = storeAccount.Id;
        insert xrefFailure;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id
        );
        insert relatedParentWorkPlan;
        WorkPlan childWorkPlanBusinessRef = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = busRefFailure.Id
        );
        insert childWorkPlanBusinessRef;
        WorkPlan childWorkPlanXref = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Xref__c = xrefFailure.Id
        );
        insert childWorkPlanXref;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectByParentWorkPlanIds(new Set<Id>{ relatedParentWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
    }

    /**
     * @description To test query on related parent work plans of child work plans when set of
     * child work plan Ids are passed.
     */
    @isTest
    private static void testWhenChildWorkPlanIdsArePassedThenRelatedParentWorkPlanValuesReturned() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Business_Reference__c busRefFailure = new Business_Reference__c();
        busRefFailure.Integration_Status__c = STATUS_FAILURE;
        insert busRefFailure;
        Xref__c xrefFailure = new Xref__c();
        xrefFailure.Integration_Status__c = STATUS_FAILURE;
        xrefFailure.External_ID__c = 'abc123';
        xrefFailure.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xrefFailure.Salesforce_Account_Name__c = storeAccount.Id;
        insert xrefFailure;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id,
            Notes__c = TEST_NOTES
        );
        insert relatedParentWorkPlan;
        WorkPlan childWorkPlanBusinessRef = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = busRefFailure.Id,
            Notes__c = TEST_NOTES
        );
        insert childWorkPlanBusinessRef;
        WorkPlan childWorkPlanXref = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Xref__c = xrefFailure.Id,
            Notes__c = TEST_NOTES
        );
        insert childWorkPlanXref;
        Test.startTest();
        List<SObject> workPlansResult = ((IWorkObjectsSyncSelector) Application.SELECTOR.newInstance(
                WorkPlan.SObjectType
            ))
            .selectParentDetailsByChildIds(
                new Set<Id>{ childWorkPlanBusinessRef.Id, childWorkPlanXref.Id }
            );
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
    }

    /**
     * @description To test Work Plan query to get integration info by passing parent Work Plan Id
     * without any associated stores.
     */
    @isTest
    private static void testWhenDriveParentWorkOrderPassedThenIntegrationInfoReceivedWithoutChildWorkPlans() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c ='SMB'
        );
        insert parentAccount;
        Business_Reference__c busRefFailure = new Business_Reference__c();
        busRefFailure.Integration_Status__c = STATUS_FAILURE;
        insert busRefFailure;
        Xref__c xrefFailure = new Xref__c();
        xrefFailure.Integration_Status__c = STATUS_FAILURE;
        xrefFailure.External_ID__c = 'abc123';
        xrefFailure.External_ID_Source__c = EXTERNAL_ID_SOURCE_DRIVE;
        xrefFailure.Salesforce_Account_Name__c = parentAccount.Id;
        insert xrefFailure;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            parentAccount.Id,
            true
        );
        WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
            IsActive = true,
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workPlanTemplate;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_DRIVE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert workOrderTemplate;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_TYPE,
            Type__c = WORK_ORDER_TYPE_DRIVE,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert parentWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Business_Reference__c = busRefFailure.Id,
            Xref__c = xrefFailure.Id
        );
        insert relatedWorkPlan;
        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectIntegrationInfoForWorkPlansByParentWorkOrderDriveId(
            parentWorkOrder.Id
        );
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            xrefFailure.Id,
            workPlanRecord[0].Xref__c,
            'Field not returned in SOQL query'
        );
        System.assertEquals(
            busRefFailure.Id,
            workPlanRecord[0].Business_Reference__c,
            'Field not returned in SOQL query'
        );
    }

    /**
     * @description To test query on child work plan when set of Store Account IDs are passed filtered by WorkPlan Type
     */
    @isTest
    private static void testWhenAccountIDsAndTypePassedThenReturnWorkPlans() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
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
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
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
            Name = WORK_PLAN_NAME_POS,
            ParentRecordId = parentWorkOrder.Id,
            Type__c = WORK_PLAN_NAME_POS,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_POS,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            Type__c = WORK_PLAN_NAME_POS,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;

        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansByStoreAccountIDAndType(
                new Set<Id>{ storeAccount.Id },
                WORK_PLAN_SET_TYPE_POS
            );
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
    }

    /**
     * @description To test aggregate query returns count of child Work Plans
     * grouped by Activation Checklist Validation status and Parent Work Plan Id.
     */
    @isTest
    private static void testWhenParentWPIdsPassedThenReturnCountOfActivationChecklistValidationCompletedWorkPlans() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
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
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
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
            Name = WORK_PLAN_NAME_POS,
            ParentRecordId = parentWorkOrder.Id,
            Type__c = WORK_PLAN_NAME_POS,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_POS,
            Activation_Checklist_Validation__c = VALIDATION_STATUS_COMPLETED,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            Type__c = WORK_PLAN_NAME_POS,
            WorkOrderId = childWorkOrder.Id
        );
        insert childWorkPlan;

        Test.startTest();
        Aggregate[] workPlansResult = WorkPlansSelector.newInstance()
            .getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
                new Set<Id>{ parentWorkPlan.Id }
            );
        Test.stopTest();
        System.assertEquals(
            1,
            Integer.valueOf(workPlansResult[0].get(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS)),
            FIELD_VALUE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlan.Id,
            (Id) (workPlansResult[0].get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS)),
            FIELD_VALUE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            VALIDATION_STATUS_COMPLETED,
            (String) workPlansResult[0]
                .get(PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS),
            FIELD_VALUE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test if work plan with related work orders and store accounts are returned
     * when workPlan Ids are passed
     */
    @isTest
    private static void testWhenWorkPlansPassedThenReturnWorkPlansWithWorkOrderAndPhotoshhotStoreLocationDetails() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE_PHOTOSHOOT,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_VENDOR_PHOTOSHOOT,
            ParentRecordId = parentWorkOrder.Id,
            Type__c = WORK_PLAN_NAME_VENDOR_PHOTOSHOOT,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_VENDOR_PHOTOSHOOT,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            Type__c = WORK_PLAN_NAME_VENDOR_PHOTOSHOOT,
            WorkOrderId = parentWorkOrder.Id
        );
        insert childWorkPlan;

        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderAndPhotoShootStoreLocationDetails(
                new Set<Id>{ childWorkPlan.Id, parentWorkPlan.Id }
            );
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
        System.assertEquals(
            WORK_PLAN_NAME_VENDOR_PHOTOSHOOT,
            workPlansResult[0].Type__c,
            WORK_PLAN_FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test if work plan with related work orders and store accounts are returned
     * when workPlan Ids and Types are passed.
     */
    @isTest
    private static void testWhenWorkPlanIdsAndTypesPassedThenReturnWorkPlansWithWorkOrderAndRelatedAccountDetails() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert parentAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE_MARKETING_KIT,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_MARKETING_KIT,
            ParentRecordId = parentWorkOrder.Id,
            Type__c = WORK_PLAN_NAME_MARKETING_KIT,
            WorkOrderId = parentWorkOrder.Id
        );
        insert parentWorkPlan;
        WorkPlan childWorkPlan = new workplan(
            Name = WORK_PLAN_NAME_MARKETING_KIT,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            Type__c = WORK_PLAN_NAME_MARKETING_KIT,
            WorkOrderId = parentWorkOrder.Id
        );
        insert childWorkPlan;

        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansByWorkPlanIdsAndTypes(
                new Set<Id>{ childWorkPlan.Id, parentWorkPlan.Id },
                new Set<String>{ WORK_PLAN_NAME_MARKETING_KIT }
            );
        Test.stopTest();
        System.assertEquals(false, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
        System.assertEquals(
            WORK_PLAN_NAME_MARKETING_KIT,
            workPlansResult[0].Type__c,
            WORK_PLAN_FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkPlan using email reference Id.
     */
    @isTest
    private static void testWhenSelectByWorkPlanEmailReferenceIdThenReturnedWorkPlan() {
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_TYPE_SETUP_BANKING,
            WorkOrderId = parentWorkOrder.Id,
            Status__c = 'Blocked'
        );
        insert relatedParentWorkPlan;

        String workPlanId = relatedParentWorkPlan.Id;
        String trimmedWorkPlanId = workPlanId.substring(0, 15);
        String organizationId = UserInfo.getOrganizationId().substring(0, 15);
        String emailReferenceId =
            EMAIL_REFERENCE_ID_START_KEYWORD +
            organizationId.left(4) +
            organizationId.right(4) +
            FULL_STOP_SEPARATOR +
            trimmedWorkPlanId.left(4) +
            trimmedWorkPlanId.right(5) +
            EMAIL_REFERENCE_ID_END_KEYWORD;

        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansByEmailRefId(new Set<String>{ emailReferenceId });
        Test.stopTest();
        System.assertEquals(true, workPlansResult.isEmpty(), WORK_PLAN_SELECTBYID_ASSERT_MESSAGE);
    }

    /**
     * @description To test query on WorkPlans when WorkPlanIds are passed.
     * @JIRA# LEM-13577
     * then details of work plans are returned.
     */
    @isTest
    private static void testWhenWorkPlanIdsdsArePassedThenDetailsAreReturned() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id
        );
        insert relatedParentWorkPlan;
        WorkPlan relatedChildWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = childWorkOrder.Id,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id
        );
        insert relatedChildWorkPlan;


        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_TYPE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_ORDER_TYPE_DRIVE,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;

        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectByWorkPlanIds(
            new Set<Id>{relatedWorkPlan.Id}
        );
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test query on WorkPlans when Parent WorkPlan and StoreIds are passed.
     * @JIRA# LEM-13577
     */
    @isTest
    private static void testWhenSelectWorkPlansByParentWorkPlanAndStoreAccountThenDetailsAreReturned() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(6),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlan relatedParentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = parentWorkOrder.Id,
            Type__c = WORK_PLAN_TYPE_ONBOARDING
        );
        insert relatedParentWorkPlan;
        WorkPlan relatedChildWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = childWorkOrder.Id,
            Parent_Work_Plan__c = relatedParentWorkPlan.Id,
            Type__c = WORK_PLAN_TYPE_ONBOARDING
        );
        insert relatedChildWorkPlan;


        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        WorkOrder newWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Sub_Type__c = WORK_ORDER_TYPE,
            Type__c = WORK_ORDER_TYPE_DRIVE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_ORDER_TYPE_DRIVE,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = newWorkOrder.Id,
            Type__c = WORK_PLAN_TYPE_ONBOARDING

        );
        insert relatedWorkPlan;

        WorkPlan relatedChildWorkPlan2 = new WorkPlan(
            Name = WORK_ORDER_TYPE_DRIVE,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = newWorkOrder.Id,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            Type__c = WORK_PLAN_TYPE_ONBOARDING
        );
        insert relatedChildWorkPlan2;

        WorkPlansSelector workPlansInstance = new WorkPlansSelector();
        List<WorkPlan> workPlanRecord = workPlansInstance.selectWorkPlansByParentWorkPlanAndStoreAccount(
            new Set<Id>{storeAccount.Id}, new Set<String>{ WORK_PLAN_TYPE_ONBOARDING },relatedWorkPlan.Id
        );
        System.assertEquals(1, workPlanRecord.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }
    /**
     * @description To test query on WorkPlan by passing WorkPlan Ids
     * returns WorkPlan with WorkOrder associated to Virtual Stores.
     */
    @isTest
    private static void testWhenWorkPlanIdsPassedThenReturnWorkPlansWithIsVirtualStoreAsFalseOnParent() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Type = ACCOUNT_TYPE_VIRTUAL
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlanTemplate cooWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_COO
        );
        insert cooWorkPlanTemplate;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = childWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Work_Plan_Template__c = cooWorkPlanTemplate.Id
        );
        insert childWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderAssociatedToVirtualStores(new Set<Id>{ childWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            workPlansResult.size(),
            ASSERT_MESSAGE_STORE_ACCOUNT_DO_NOT_MATCH
        );
        System.assertEquals(
            childWorkPlan.Id,
            workPlansResult[0].Id,
            WORK_PLAN_FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test query on WorkPlan by passing WorkPlan Ids
     * returns WorkPlan with WorkOrder not associated to Virtual Stores.
     */
    @isTest
    private static void testWhenWorkPlanIdsPassedThenDoNotReturnWorkPlansWithNonVirtualStoreWorkOrder() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Type = ACCOUNT_TYPE_FOOD_TRUCK
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlanTemplate cooWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_COO
        );
        insert cooWorkPlanTemplate;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = relatedWorkPlan.Id,
            ParentRecordId = childWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Work_Plan_Template__c = cooWorkPlanTemplate.Id
        );
        insert childWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderAssociatedToVirtualStores(new Set<Id>{ childWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            0,
            workPlansResult.size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkPlan by passing WorkPlan Ids
     * with Verified POS Integartion Types in Parent WorkPlan returns WorkPlans.
     */
    @isTest
    private static void testWhenChildWorkPlanIdWithVerifiedPOSIntegartionTypesPassedReturnsChildWorkPlan() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Type = ACCOUNT_TYPE_FOOD_TRUCK,
            POS_Integration_Type__c = POS_INTEGRATION_TYPE_CLOVER
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlanTemplate cooWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_COO
        );
        insert cooWorkPlanTemplate;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Is_POS_Integration_Verified__c = false
        );
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            ParentRecordId = childWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Work_Plan_Template__c = cooWorkPlanTemplate.Id
        );
        insert childWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithVerifiedPOSIntegrationTypes(new Set<Id>{ childWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            workPlansResult.size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkPlan by passing WorkPlan Ids
     * without Verified POS Integartion Types in Parent WorkPlan returns no WorkPlans.
     */
    @isTest
    private static void testWhenChildWorkPlanIdWithoutVerifiedPOSIntegartionTypesPassedReturnsNoWorkPlans() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Type = ACCOUNT_TYPE_FOOD_TRUCK,
            POS_Integration_Type__c = POS_INTEGRATION_TYPE_ADORA
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_UPGRADE,
            Deal_Type__c = DEAL_TYPE_STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            ParentWorkOrderId = parentWorkOrder.Id,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE
        );
        insert childWorkOrder;
        WorkPlanTemplate cooWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_COO
        );
        insert cooWorkPlanTemplate;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Is_POS_Integration_Verified__c = false
        );
        WorkPlan childWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            ParentRecordId = childWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED,
            Work_Plan_Template__c = cooWorkPlanTemplate.Id
        );
        insert childWorkPlan;
        Test.startTest();
        List<WorkPlan> workPlansResult = WorkPlansSelector.newInstance()
            .selectWorkPlansWithVerifiedPOSIntegrationTypes(new Set<Id>{ childWorkPlan.Id });
        Test.stopTest();
        System.assertEquals(
            0,
            workPlansResult.size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}