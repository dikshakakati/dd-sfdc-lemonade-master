/**
 * @author Deloitte
 * @date 04/11/2022
 * @description Test class for WorkOrdersSelector class.
 */
@isTest(SeeAllData=false)
private class WorkOrdersSelectorTest {
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_ACTIVATION_STATUS_DEACTIVATED = 'Deactivated';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_POS_INTEGRATION_TYPE = 'non_integrated_mx';
    private static final String ACCOUNT_TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS = 'bundledWithMarketplace';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS = 'childWorkOrderCount';
    private static final String AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS = 'provisioningStatus';
    private static final String AGGREGATE_UNIQUE_STORE_COUNT_ALIAS = 'uniqueStoreCount';
    private static final String AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS = 'posIntergrationType';
    private static final String AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS = 'tabletDeliveryMethod';
    private static final String ASSERT_MESSAGE_DEAD_WORK_ORDER_RETURNED = 'Unexpected result: Dead Work Order is retrieved in query';
    private static final String ASSERT_MESSAGE_WORK_ORDER_ID = 'Unexpected result: Work Order Id is not matching';
    private static final String ASSERT_MESSAGE_WORK_ORDER_EMAIL_REFERENCE_ID = 'Unexpected result: Work Order Email Reference Id is not matching';
    private static final String ASSERT_MESSAGE_WORK_ORDER_COO_BATCH_DATE = 'Unexpected result: Work Order COO Batch Run Date is not matching';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final Id BUSINESS_RECORD_TYPE_ID;
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'EEEE';
    private static final String DAY_OF_WEEK_SATURDAY = 'Saturday';
    private static final String DAY_OF_WEEK_SUNDAY = 'Sunday';
    private static final String EMAIL_REFERENCE_ID_END_KEYWORD = ':ref';
    private static final String EMAIL_REFERENCE_ID_START_KEYWORD = 'ref:';
    private static final String FULL_STOP_SEPARATOR = '.';
    private static final String WORKORDER_BUSINESS_TO_STORE_ASSIGNMENT_MANUAL = 'Manual';
    private static final String CONTRACT_STATUS = 'Draft';
    private static final String DEAD_STATUS_ERROR_ASSERT_MESSAGE = 'Unexpected result: WorkOrder Status update to Dead did not throw an error message';
    private static final String TABLET_CREDENTIALS_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: Tablet credentials did not match';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of Records returned does not match the expected outcome';
    private static final String GOOGLE_SHEET_URL = 'https://docs.google.com/spreadsheets/test';
    private static final String INCORRECT_NUMBER_OF_STORES_ASSERT_MESSAGE = 'Unexpected result: Number of Stores is not equal the expected value';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final Integer NUMBER_OF_STORES = 2;
    private static final Integer NUMBER_OF_WORKORDERS_RETURNED = 1;
    private static final Integer NUMBER_OF_ACTIVE_AND_DEAD_WORKORDERS_RETURNED = 2;
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.WorkOrder.FieldSets.Store_Readiness_Check_Fields;
    private static final Schema.Fieldset FIELDS_TO_QUERY_BANKING_INFORMATION = SObjectType.WorkOrder.FieldSets.Banking_Information;
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Order';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'WorkOrderSelectorTestMarketplaceNintexId';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any WorkOrders';
    private static final String QUERY_RETURN_INCORRECT_COUNT_OF_CHILD_WORKORDER_ASSERT_MESSAGE = 'Unexpected result: The query does not return expected number of child WorkOrders';
    private static final String QUERY_RETURN_NO_CHILD_WORK_STEPS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child WorkSteps';
    private static final String QUERY_RETURN_NO_CHILD_WORK_PLANS_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child WorkPlans';
    private static final String QUERY_RETURN_NO_CHILD_WORK_ORDERS_MATCHING_STORE_ID_ASSERT_MESSAGE = 'Unexpected result: The query does not return any child Work Orders with store account ids.';
    private static final String QUERY_RETURN_NO_PARENT_WORK_ORDERS_MATCHING_BUSINESS_TO_STORE_ASSIGNMENT_ASSERT_MESSAGE = 'Unexpected result: The query does not return any parent Work Orders with Business to Store Assignment.';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STORE_ACCOUNT_LEGAL_BUSINESS_NAME = 'Store Legal Business Name';
    private static final String TEST_USER_ALIAS = 'MockUser';
    private static final String TEST_USER_EMAIL_ID = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com';
    private static final String TEST_USER_NAME = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com.test';
    private static final String UPGRADE = 'Upgrade';
    private static final String STANDARD = 'Standard';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Mock User';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'GMT';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_COO_BATCH_RUN_DATE_FIELD = 'COO_Batch_Run_Date__c';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_SUBTYPE_WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WORK_PLAN_NAME = 'COO Test';
    private static final String WORK_STEP_NAME_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_POSTSALES = 'Post-Sales';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_ORDER_SUBTYPE_RATE_CHANGE = 'Rate Change';
    private static final String WORK_ORDER_SUBTYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U = 'Partnership creation/update';
    private static final String WORKPLAN_NAME_GRANT_PORTAL_ACCESS = 'Grant Portal Access';
    private static final String WORKPLAN_NAME_MENU = 'Menu';
    private static final String WORKPLAN_NAME_ONBOARDING = 'Onboarding';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORK_ORDER_STATUS_NOT_RETURNED = 'Work Orders not returned';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String TYPE_POS = 'POS';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String IR_BATCH_ID = 'Batch001';
    private static final String WO_SUBTYPE_COO = 'COO Same Store';
    private static final String TABLET_USERNAME = 'AccountsTest Username';
    private static final String TABLET_PASSWORD = 'AccountsTest Password';
    private static final String CHURNED_MERCHANT = 'Churned Merchant';

    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupData() {
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_MARKETPLACE,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert workOrderTemplate;
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = ONBOARDING_WORK_PLAN_TEMPLATE,
            Type__c = ONBOARDING_WORK_PLAN_TEMPLATE,
            isActive = true
        );
        insert onboardingWorkPlanTemplate;
        WorkStepTemplate reviewTriageWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_STEP_TEMPLATE_NAME,
            IsActive = true
        );
        insert reviewTriageWorkStepTemplate;
        WorkPlanTemplateEntry workPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
            ExecutionOrder = 1,
            Active__c = true
        );
        insert workPlanTemplateEntry;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Name = WORK_ORDER_TEMPLATE_ENTRY,
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = onboardingWorkPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
    }

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkOrdersSelector workOrdersInstance = new WorkOrdersSelector();
        Schema.SObjectType typeOfObject = workOrdersInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workOrdersInstance.getSObjectFieldList();
        WorkOrdersSelector.newInstance();
        System.assertEquals(
            Schema.WorkOrder.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
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
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test inner query on Work Order for fetching WorkOrders with related WorkSteps
     * filtered by WorkOrderIds.
     */
    @isTest
    private static void testWhenWorkOrderIdsArePassedThenWorkOrdersWithRelatedWorkStepsAreReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;
        List<WorkStep> childWorkSteps = new List<Workstep>{
            new WorkStep(
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status = STATUS_NOT_STARTED,
                Status__c = STATUS_NOT_STARTED,
                WorkPlanId = relatedWorkPlan.Id
            ),
            new Workstep(
                Name = WORK_STEP_NAME_SETUP_BUSINESS,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                WorkPlanId = relatedWorkPlan.Id
            )
        };
        insert childWorkSteps;
        //Update PDOA Date With Future Date
        newWorkOrder.PDOA_Delay_Reason__c = 'Readiness Check Failure';
        newWorkOrder.PDOA_Delay_Details__c = 'Delayed due to Readiness Failure';
        newWorkOrder.Proposed_Date_of_Activation__c = createPdoaDate(System.today() + 5);
        newWorkOrder.Status = 'Past Due';
        update newWorkOrder;
        List<WorkOrder> workOrderWithWorkStepsResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersAndWorkStepsUsingWorkOrderIds(new Set<Id>{ newWorkOrder.Id });
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult != null,
            QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult[0].WorkSteps != null,
            QUERY_RETURN_NO_CHILD_WORK_STEPS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkOrder to fetch WorkOrders with Status as PastDue and
     * PDOA is in past.
     */
    @isTest
    private static void testWhenQueryOnWorkOrdersWithStatusAsPastDueThenRecordsAreReturned() {
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
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = STATUS_PLANNING,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2))
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;
        List<WorkStep> childWorkSteps = new List<Workstep>{
            new WorkStep(
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status = STATUS_NOT_STARTED,
                Status__c = STATUS_NOT_STARTED,
                WorkPlanId = relatedWorkPlan.Id
            ),
            new Workstep(
                Name = WORK_STEP_NAME_SETUP_BUSINESS,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                WorkPlanId = relatedWorkPlan.Id
            )
        };
        insert childWorkSteps;
        List<WorkOrder> workOrderWithWorkStepsResult = WorkOrdersSelector.newInstance()
            .getWorkOrderRecordsForUpdateStatus();
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult != null,
            QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the number of unique Store Accounts selection grouped by parent WorkOrder Ids
     * based on the parent Work Order Ids.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsArePassedThenReturnNumberOfUniqueStoresWithParentWorkOrderId() {
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
        Account inactiveStoreAccount = new Account(
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
        Account parentStoreAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert new List<Account>{ storeAccount, parentStoreAccount, inactiveStoreAccount };
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            //Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        WorkOrder deadWorkOrder = new WorkOrder(
            AccountId = inactiveStoreAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_DEAD,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        WorkOrder childWorkOrderWithStoreAccount = new WorkOrder(
            AccountId = parentStoreAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Contract__c = contractInstance.Id,
            //Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        WorkOrder newChildWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            //Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        WorkOrder parentWorkOrderWithBusinessAccount = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            //Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            childWorkOrder,
            childWorkOrderWithStoreAccount,
            newChildWorkOrder,
            parentWorkOrderWithBusinessAccount,
            deadWorkOrder
        };
        insert childWorkOrders;
        Integer uniqueStoreCount = 0;
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrder.Id }
                )
        ) {
            System.assertEquals(
                parentWorkOrder.Id,
                (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
            uniqueStoreCount += Integer.valueOf(
                eachAggregate.get(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS)
            );
        }
        System.assertEquals(
            NUMBER_OF_STORES,
            uniqueStoreCount,
            INCORRECT_NUMBER_OF_STORES_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the WorkOrder and related WorkSteps selection
     * based on the passed Account Ids.
     **/
    @isTest
    private static void testWhenStoreAccountIdsArePassedThenWorkOrdersWithAccountOwnerEmailFieldReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        WorkOrder workOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2))
        );
        insert workOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByAccountIds(new Set<Id>{ businessAccount.Id });
        System.assertEquals(1, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To validate the WorkOrder selection
     * based on the passed business Account Ids.
     **/
    @isTest
    private static void testWhenBusinessAccountIdsArePassedThenReturnParentWorkOrders() {
        List<Account> businessAccounts = new List<Account>();
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(parentAccount);
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount);
        insert businessAccounts;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        WorkOrder storefrontWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_PLANNING,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2))
        );
        parentWorkOrders.add(storefrontWorkOrder);
        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = corporateOpportunity.Id
        );
        parentWorkOrders.add(marketplaceWorkOrder);
        insert parentWorkOrders;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByBusinessAccountIds(
                new Set<Id>{ parentAccount.Id, businessAccount.Id }
            );
        System.assertEquals(
            parentWorkOrders.size(),
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the WorkOrder selection based on the passed parent
     * WorkOrder Ids and store Account Ids.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsAndStoreAccountIdsArePassedThenReturnWorkOrders() {
        List<Account> businessAccounts = new List<Account>();
        List<Account> storeAccounts = new List<Account>();
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();
        List<WorkOrder> childWorkOrders = new List<WorkOrder>();
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(parentAccount);
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount);
        insert businessAccounts;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = parentAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        storeAccounts.add(storeAccount);
        Account newStoreAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        storeAccounts.add(newStoreAccount);
        insert storeAccounts;
        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = corporateOpportunity.Id
        );
        parentWorkOrders.add(marketplaceWorkOrder);
        insert parentWorkOrders;
        WorkOrder childMarketplaceWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = marketplaceWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        childWorkOrders.add(childMarketplaceWorkOrder);
        insert childWorkOrders;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectChildWorkOrdersByStoreAccountIds(
                new Set<Id>{ marketplaceWorkOrder.Id },
                new Set<Id>{ storeAccount.Id, newStoreAccount.Id }
            );
        System.assertEquals(
            childWorkOrders.size(),
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test the aggregate query to get number of child Work Orders
     * grouped by Provisioning Status based on the passed parent Work Order Ids.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsArePassedThenReturnCountOfChildWorkOrdersByProvisioningStatus() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        List<Account> storeAccounts = new List<Account>{
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
        };
        insert storeAccounts;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Opportunity__c = corporateOpportunity.Id;
        insert parentWorkOrder;
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[0].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[1].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[2].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[3].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[4].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[5].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            )
        };
        childWorkOrders[0].Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_FAILED;
        childWorkOrders[1].Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_FAILED;
        childWorkOrders[2].Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_COMPLETE;
        childWorkOrders[3].Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_COMPLETE;
        childWorkOrders[4].Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING;
        childWorkOrders[5].Provisioning_Status__c = PROVISIONING_STATUS_PROVISIONING_FAILED;
        childWorkOrders[5].Status = STATUS_DEAD;
        Map<Id, Map<String, Integer>> parentWorkOrderIdToProvisioningStatusToCount = new Map<Id, Map<String, Integer>>();
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
        ) {
            Id parentWorkOrderId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS);
            String workOrderProvisioningStatus = (String) eachAggregate.get(
                AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS
            );
            if (!parentWorkOrderIdToProvisioningStatusToCount.containsKey(parentWorkOrderId)) {
                parentWorkOrderIdToProvisioningStatusToCount.put(
                    parentWorkOrderId,
                    new Map<String, Integer>()
                );
            }
            if (
                !parentWorkOrderIdToProvisioningStatusToCount.get(parentWorkOrderId)
                    .containsKey(workOrderProvisioningStatus)
            ) {
                parentWorkOrderIdToProvisioningStatusToCount.get(parentWorkOrderId)
                    .put(
                        workOrderProvisioningStatus,
                        Integer.valueOf(eachAggregate.get(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS))
                    );
            }
        }
        for (Id eachWorkOrderId : parentWorkOrderIdToProvisioningStatusToCount.keySet()) {
            Map<String, Integer> workOrderProvisioningStatusToCount = parentWorkOrderIdToProvisioningStatusToCount.get(
                eachWorkOrderId
            );
            Integer numberOfProvisionCompleteWorkOrders = workOrderProvisioningStatusToCount.get(
                PROVISIONING_STATUS_PROVISIONING_COMPLETE
            );
            Integer numberOfProvisionFaliedWorkOrders = workOrderProvisioningStatusToCount.get(
                PROVISIONING_STATUS_PROVISIONING_FAILED
            );
            Integer totalNumberOfChildWorkOrders = 0;
            for (String eachStatus : workOrderProvisioningStatusToCount.keySet()) {
                totalNumberOfChildWorkOrders += workOrderProvisioningStatusToCount.get(eachStatus);
            }
            System.assertEquals(
                2,
                numberOfProvisionCompleteWorkOrders,
                QUERY_RETURN_INCORRECT_COUNT_OF_CHILD_WORKORDER_ASSERT_MESSAGE
            );
            System.assertEquals(
                2,
                numberOfProvisionFaliedWorkOrders,
                QUERY_RETURN_INCORRECT_COUNT_OF_CHILD_WORKORDER_ASSERT_MESSAGE
            );
            System.assertEquals(
                5,
                totalNumberOfChildWorkOrders,
                QUERY_RETURN_INCORRECT_COUNT_OF_CHILD_WORKORDER_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description To validate the WorkOrder selection based on the passed WorkOrder Ids.
     **/
    @isTest
    private static void testWhenWorkOrderIdsArePassedThenReturnWorkOrders() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        WorkOrder workOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today())
        );
        insert workOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectById(new Set<Id>{ workOrder.Id });
        System.assertEquals(1, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(workOrder.Id, workOrderQueryResult[0].Id, ASSERT_MESSAGE_WORK_ORDER_ID);
    }

    /**
     * @description To validate the selection of WorkOrders, child WorkOrder and related
     * WorkPlans based on the passed Parent WorkOrder Ids.
     **/
    @isTest
    @SuppressWarnings('PMD.EmptyCatchBlock')
    private static void testWhenParentWorkOrderIdsPassedThenReturnWorkOrdersWithWorkPlans() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Opportunity__c = corporateOpportunity.Id;
        parentWorkOrder.HasWorkPlansGenerated__c = true;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrder.HasWorkPlansGenerated__c = true;
        insert childWorkOrder;
        WorkOrder deadWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        deadWorkOrder.Status = STATUS_DEAD;
        deadWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        deadWorkOrder.HasWorkPlansGenerated__c = true;
        try {
            insert deadWorkOrder;
        } catch (exception e) {
            //Not Required
        }

        List<WorkPlan> parentWorkPlans = new List<WorkPlan>{
            ServiceIntegrationDataBuilder.createWorkPlanInstance(parentWorkOrder.Id),
            ServiceIntegrationDataBuilder.createWorkPlanInstance(parentWorkOrder.Id),
            ServiceIntegrationDataBuilder.createWorkPlanInstance(parentWorkOrder.Id)
        };
        parentWorkPlans[0].Name = WORKPLAN_NAME_GRANT_PORTAL_ACCESS;
        parentWorkPlans[1].Name = WORKPLAN_NAME_MENU;
        parentWorkPlans[2].Name = WORKPLAN_NAME_ONBOARDING;
        insert parentWorkPlans;
        WorkPlan childWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            childWorkOrder.Id
        );
        childWorkPlan.Name = WORKPLAN_NAME_MENU;
        insert childWorkPlan;
        WorkPlan deadWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            deadWorkOrder.Id
        );
        deadWorkPlan.Name = WORKPLAN_NAME_MENU;
        deadWorkPlan.ParentRecordId = childWorkOrder.Id;
        insert deadWorkPlan;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersWithWorkPlansByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        Map<Id, WorkOrder> idToWorkOrder = new Map<Id, WorkOrder>(workOrderQueryResult);
        System.assertEquals(2, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertNotEquals(
            3,
            workOrderQueryResult.size(),
            ASSERT_MESSAGE_DEAD_WORK_ORDER_RETURNED
        );
        System.assertEquals(
            3,
            idToWorkOrder.get(parentWorkOrder.Id).WorkPlans.size(),
            QUERY_RETURN_NO_CHILD_WORK_PLANS_ASSERT_MESSAGE
        );
        System.assertEquals(
            2,
            idToWorkOrder.get(childWorkOrder.Id).WorkPlans.size(),
            QUERY_RETURN_NO_CHILD_WORK_PLANS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the WorkOrder and associated Account details selection
     * when WorkOrder Ids are passed.
     **/
    @isTest
    private static void testWhenWorkOrderIdsArePassedThenReturnWorkOrderAndAccountDetails() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        insert childWorkOrder;
        WorkOrder deadWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        deadWorkOrder.Status = STATUS_DEAD;
        deadWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        insert deadWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersWithAccountDetailsByIds(
                (Schema.FieldSet) FIELDS_TO_QUERY,
                new Set<Id>{ childWorkOrder.Id }
            );
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertNotEquals(
            NUMBER_OF_ACTIVE_AND_DEAD_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            ASSERT_MESSAGE_DEAD_WORK_ORDER_RETURNED
        );
    }

    /**
     * @description To validate the child WorkOrders selection based on parent WorkOrder Ids.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsArePassedThenReturnChildWorkOrders() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the Account's POS Integration Type and
     * Tablet Delivery Method grouped by parent WorkOrder Ids based on the parent Work order Ids.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsPassedThenPOSIntegrationTypeAndTabletDeliveryMethodWithParentWorkOrderIdReturned() {
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
            Tablet_Delivery_Method__c = ACCOUNT_TABLET_DELIVERY_METHOD,
            POS_Integration_Type__c = ACCOUNT_POS_INTEGRATION_TYPE
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert childWorkOrder;
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrder.Id }
                )
        ) {
            System.assertEquals(
                parentWorkOrder.Id,
                (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
            System.assertEquals(
                ACCOUNT_TABLET_DELIVERY_METHOD,
                eachAggregate.get(AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
            System.assertEquals(
                ACCOUNT_POS_INTEGRATION_TYPE,
                eachAggregate.get(AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
            System.assertEquals(
                BUNDLED_WITH_MARKETPLACE_NO,
                eachAggregate.get(AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description To validate fetching of child work orders by parent work order id with
     * store account id populated.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsPassedThenChildWorkOrdersReturned() {
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
            Tablet_Delivery_Method__c = ACCOUNT_TABLET_DELIVERY_METHOD,
            POS_Integration_Type__c = ACCOUNT_POS_INTEGRATION_TYPE
        );
        insert storeAccount;

        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert childWorkOrder;

        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });

        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );

        System.assertEquals(
            storeAccount.Id,
            workOrderQueryResult[0].AccountId,
            QUERY_RETURN_NO_CHILD_WORK_ORDERS_MATCHING_STORE_ID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate fetching of child work orders by parent work order id with
     * store account id populated.
     **/
    @isTest
    private static void testWhenParentWorkOrderIdsPassedThenWorkOrdersWithBusinessToStoreAssinmentReturned() {
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
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Business_to_Store_Assignment__c = WORKORDER_BUSINESS_TO_STORE_ASSIGNMENT_MANUAL,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;

        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectById(new Set<Id>{ parentWorkOrder.Id });

        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );

        System.assertEquals(
            WORKORDER_BUSINESS_TO_STORE_ASSIGNMENT_MANUAL,
            workOrderQueryResult[0].Business_to_Store_Assignment__c,
            QUERY_RETURN_NO_PARENT_WORK_ORDERS_MATCHING_BUSINESS_TO_STORE_ASSIGNMENT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the WorkOrders selection based on Opportunity Ids.
     **/
    @isTest
    private static void testWhenOpportunityIdsPassedThenWorkOrdersReturned() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentWorkOrdersByOpportunityIds(new Set<Id>{ parentOpportunity.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate fetching of parent Work orders by Opportunity Ids.
     **/
    @isTest
    private static void testWhenOpportunityIdsPassedThenParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentWorkOrdersByOpportunityIds(new Set<Id>{ parentOpportunity.Id });

        List<WorkOrder> workOrderQueryResultParentForOpp = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByOpportunityId(parentOpportunity.Id);

        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResultParentForOpp.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResultParentForOpp[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /**
     * @description To validate Non Complete Drive Work Orders are returned by AccountId
     **/
    @isTest
    private static void testWhenNonCompleteDriveWorkOrdersByAccountIdsThenCorrectWorkOrdersReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount.Id,
            true
        );
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
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        WorkOrder parentStorefrontWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert parentStorefrontWorkOrder;
        WorkOrder storefrontWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            ParentWorkOrderId = parentStorefrontWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES
        );
        insert storefrontWorkOrder;
        WorkOrder parentDriveWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert parentDriveWorkOrder;
        WorkOrder driveWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            ParentWorkOrderId = parentDriveWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert driveWorkOrder;
        WorkOrder driveDeadWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_DEAD,
            ParentWorkOrderId = parentDriveWorkOrder.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2))
        );
        insert driveDeadWorkOrder;
        WorkPlanTemplate workPlanTemplate = new WorkPlanTemplate(
            IsActive = true,
            Name = WORKORDER_TYPE_DRIVE,
            Type__c = WORKORDER_TYPE_DRIVE
        );
        insert workPlanTemplate;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORKORDER_TYPE_DRIVE,
            Type__c = WORKORDER_TYPE_DRIVE
        );
        insert workOrderTemplate;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        WorkOrder driveBusinessAccountWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert driveBusinessAccountWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .queryNonCompleteDriveWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id });
        System.assertEquals(1, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            driveWorkOrder.Id,
            workOrderQueryResult[0].Id,
            'Incorrect Work Order Returned'
        );
    }

    /**
     * @description To validate query on Work orders by Nintex Ids associated to Opportunity.
     **/
    @isTest
    private static void testWhenNintexIdsPassedThenWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            Marketplace_Nintex_Id__c = OPPORTUNITY_MARKETPLACE_NINTEX_ID,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectByNintexIds(new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /**
     * @description To test query on Work Order when encrypted FieldSet
     * and Work Order Ids are passed.
     **/
    @isTest
    private static void testWhenFieldSetAndWorkOrderIdsPassedThenReturnWorkOrderFieldsUsingFieldSet() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            Legal_Business_Name__c = STORE_ACCOUNT_LEGAL_BUSINESS_NAME,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM,
            Opportunity__c = corporateOpportunity.Id
        );
        insert parentWorkOrder;
        WorkOrder workOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert workOrder;
        List<SObject> sObjects = ((IEncryptedDataSelector) Application.Selector.newInstance(
                workOrder.Id.getSobjectType()
            ))
            .selectEncryptedData(
                (Schema.FieldSet) FIELDS_TO_QUERY_BANKING_INFORMATION,
                new Set<Id>{ workOrder.Id }
            );
        System.assertEquals(1, sObjects.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To validate fetching of parent Work Orders by Contract Ids.
     **/
    @isTest
    private static void testWhenContractIdsPassedThenParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrder.Contract__c = contractInstance.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentWorkOrdersByContractIds(new Set<Id>{ contractInstance.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }
    /**
     * @description To validate fetching of parent Work Orders by Contract Ids.
     **/
    @isTest
    private static void testWhenWorkOrderIdsPassedThenAmendamentParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_POSTSALES
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_RATE_CHANGE;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrder.Contract__c = contractInstance.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectAmendedOpportunityWorkOrdersByWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            childWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /**
     * @description To validate fetching of Drive Amendment Work Orders by Contract Ids.
     **/
    @isTest
    private static void testWhenWorkOrderIdsPassedThenDriveAmendmentParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount.Id,
            true
        );
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U;
        parentWorkOrder.Google_Sheet_URL__c = GOOGLE_SHEET_URL;
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        childWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_PARTNERSHIP_C_U;
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrder.Opportunity__c = parentOpportunity.Id;
        childWorkOrder.Contract__c = contractInstance.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectDriveAmendedOpportunityWorkOrdersByWorkOrderIds(
                new Set<Id>{ parentWorkOrder.Id }
            );
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            childWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /**
     * @description To validate Work Orders selection based on Email Reference Ids.
     **/
    @isTest
    private static void testWhenEmailReferenceIdsPassedThenReturnWorkOrders() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        WorkOrder workOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        insert workOrder;
        // Email Reference Id is a formula field, applying logic to extract Email_Reference_Id__c.
        String workOrderId = workOrder.Id;
        String trimmedWorkOrderId = workOrderId.substring(0, 15);
        String organizationId = UserInfo.getOrganizationId().substring(0, 15);
        String emailReferenceId =
            EMAIL_REFERENCE_ID_START_KEYWORD +
            organizationId.left(4) +
            organizationId.right(4) +
            FULL_STOP_SEPARATOR +
            trimmedWorkOrderId.left(4) +
            trimmedWorkOrderId.right(5) +
            EMAIL_REFERENCE_ID_END_KEYWORD;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectByEmailReferenceIds(new Set<String>{ emailReferenceId });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            emailReferenceId,
            workOrderQueryResult[0].Email_Reference_Id__c,
            ASSERT_MESSAGE_WORK_ORDER_EMAIL_REFERENCE_ID
        );
    }

    /**
     * @description Validate COO Work Orders selection based on the critieria.
     * LEM-3648
     **/
    @isTest
    private static void testWhenCOOWorkOrdersThenReturnPDOABatchDate() {
        User mockUser = new User(
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = TEST_USER_NAME
        );
        System.runAs(mockUser) {
            Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            insert businessAccount;
            Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            insert storeAccount;
            WorkOrder workOrderObj = ServiceIntegrationDataBuilder.createWorkOrderInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE
            );
            workOrderObj.Proposed_Date_of_Activation__c = createPdoaDate(
                System.now().dateGMT().addDays(10)
            );
            workOrderObj.Provisioning_Status__c = 'Readiness Check Complete';
            insert workOrderObj;
            WorkOrder childWorkOrderObj = ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccount.Id,
                WORK_ORDER_TYPE
            );
            childWorkOrderObj.ParentWorkOrderId = workOrderObj.Id;
            childWorkOrderObj.Proposed_Date_of_Activation__c = createPdoaDate(
                System.today().addDays(10)
            );
            childWorkOrderObj.Provisioning_Status__c = 'Readiness Check Complete';
            insert childWorkOrderObj;
            workOrderObj.Proposed_Date_of_Activation__c = createPdoaDate(System.today());
            workOrderObj.PDOA_Delay_Reason__c = 'Readiness Check Failure';
            workOrderObj.PDOA_Delay_Details__c = 'Delayed due to Readiness Failure';
            update workOrderObj;

            DateTime originalPdoaDate = (DateTime) createPdoaDate(System.today());
            Date expectedBatchRunDate = createPdoaDate(System.today());
            if (originalPdoaDate.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUNDAY) {
                expectedBatchRunDate = Date.valueOf(originalPdoaDate.addDays(-2));
            } else {
                expectedBatchRunDate = Date.valueOf(originalPdoaDate.addDays(-1));
            }
            WorkOrder recalculatedWorkOrder = (WorkOrder) Formula.recalculateFormulas(
                    new List<WorkOrder>{ workOrderObj }
                )[0]
                .getSObject();
            Date batchRunDate = (Date) recalculatedWorkOrder.get(
                WORK_ORDER_COO_BATCH_RUN_DATE_FIELD
            );
            System.assertEquals(
                expectedBatchRunDate,
                batchRunDate,
                ASSERT_MESSAGE_WORK_ORDER_COO_BATCH_DATE
            );
        }
    }

    /**
     * @description To validate the Work Orders selection based on the passed Account Ids.
     **/
    @isTest
    private static void testWhenAccountIdsPassedThenWorkOrdersReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = businessAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            Tablet_User_Name__c = TABLET_USERNAME,
            Tablet_Password__c = TABLET_PASSWORD
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Opportunity__c = corporateOpportunity.Id
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORKORDER_TYPE_STOREFRONT
        );
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectByAccountIds(new Set<Id>{ businessAccount.Id, storeAccount.Id });
        System.assertEquals(2, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            TABLET_USERNAME,
            workOrderQueryResult[1].Account.Tablet_User_Name__c,
            TABLET_CREDENTIALS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            TABLET_PASSWORD,
            workOrderQueryResult[1].Account.Tablet_Password__c,
            TABLET_CREDENTIALS_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the WorkOrder and Parent WorkOrder based on the passed Account Id.
     **/
    @isTest
    private static void testWhenStoreAccountIdsArePassedThenWorkOrdersWithParentWorkOrderFieldsReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
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
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert parentWorkOrder;
        WorkOrder workOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES
        );
        insert workOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByAccountId(storeAccount.Id);
        System.assertEquals(1, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].ParentWorkOrderId,
            QUERY_RETURN_NO_PARENT_WORK_ORDERS_MATCHING_BUSINESS_TO_STORE_ASSIGNMENT_ASSERT_MESSAGE
        );
    }

    /**
     * @description child workorders grouped by Parent work orderID and PDOx fields
     * for a parentWorkOrderID
     **/
    @isTest
    private static void testWhenPassedParentWorkOrderIDsThenChildWorkOrdersGroupedByStoreLevelDatePODxIndicators() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        List<Account> storeAccounts = new List<Account>{
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
        };
        insert storeAccounts;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Opportunity__c = corporateOpportunity.Id;
        insert parentWorkOrder;
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[0].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            ),
            ServiceIntegrationDataBuilder.createWorkOrderInstance(
                storeAccounts[1].Id,
                WORK_ORDER_TYPE_MARKETPLACE
            )
        };
        childWorkOrders[0].ParentWorkOrderId = parentWorkOrder.Id;
        childWorkOrders[1].ParentWorkOrderId = parentWorkOrder.Id;
        insert childWorkOrders;
        storeAccounts[0].Proposed_Date_of_Activation__c = createPdoaDate(
            System.today().addMonths(3)
        );
        update storeAccounts[0];
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    new Set<Id>{ parentWorkOrder.Id }
                )
        ) {
            System.assertEquals(
                parentWorkOrder.Id,
                (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS),
                QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description Retrieves a valid PDOA Date for testing - these dates cannot fall on weekends.
     * @param proposedDateToUse
     * @return Date
     **/
    private static Date createPdoaDate(Date proposedDateToUse) {
        Date dateToReturn = proposedDateToUse;
        Datetime dt = (DateTime) dateToReturn; // Needed to get the day of the week
        String dayOfWeek = dt.formatGmt('EEEE');

        if (dayOfWeek == DAY_OF_WEEK_SATURDAY || dayOfWeek == DAY_OF_WEEK_SUNDAY) {
            // Set the date to sometime during the week
            dateToReturn = dateToReturn.addDays(3);
        }
        return dateToReturn;
    }

    /**
     * @description To validate parent and child Work Orders selection not having Status
     * as Dead using the passed Work Order Ids.
     **/
    @isTest
    private static void testWhenWorkOrderIdsPassedThenReturnParentAndChildWorkOrders() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE
        );
        childWorkOrder.ParentWorkOrderId = parentWorkOrder.Id;
        insert childWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentAndChildrenByIds(new Set<Id>{ parentWorkOrder.Id });
        System.assertEquals(2, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To validate the workorders and workplans received when accountIds passed.
     **/
    @isTest
    private static void testWhenAccountIdsAndStatusAndTypePassedThenReturnWorkOrderAndWorkPlans() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = TYPE_POS,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            ParentWorkOrderId = parentWorkOrder.Id,
            Type__c = TYPE_POS,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES
        );
        insert childWorkOrder;
        WorkPlan parentWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            parentWorkOrder.Id
        );
        parentWorkPlan.Name = TYPE_POS;
        parentWorkPlan.Type__c = TYPE_POS;
        insert parentWorkPlan;
        WorkPlan childWorkPlan = ServiceIntegrationDataBuilder.createWorkPlanInstance(
            childWorkOrder.Id
        );
        childWorkPlan.Name = WORKPLAN_NAME_MENU;
        insert childWorkPlan;

        Set<String> status = new Set<String>{ STATUS_IN_PROGRESS };
        Set<String> types = new Set<String>{ TYPE_POS };
        Set<Id> accountIds = new Set<Id>{ businessAccount.Id, storeAccount.Id };
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(accountIds, Status, types);
        System.assertEquals(2, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(1, workOrderQueryResult[0].workplans.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To validate query on parent Work orders by Opportunity Ids
     * excludes Dead Work orders.
     **/
    @isTest
    private static void testWhenOpportunityIdsPassedThenNonDeadParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Opportunity parentOpportunityRelatedToDeadWorkOrder = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunityRelatedToDeadWorkOrder;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        WorkOrder parentWorkOrderInDeadStatus = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrderInDeadStatus.Opportunity__c = parentOpportunityRelatedToDeadWorkOrder.Id;
        parentWorkOrderInDeadStatus.Status = STATUS_DEAD;
        insert parentWorkOrderInDeadStatus;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentWorkOrdersByOpportunityIds(
                new Set<Id>{ parentOpportunity.Id, parentWorkOrderInDeadStatus.Id }
            );
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /*
     * @description To validate the Work Orders selection based on the passed Ids
     **/
    @isTest
    static void testWhenSelectManageableByIdCalledThenReturnQueriedRecord() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE
        );
        parentWorkOrder.Associated_Account_Ids__c = storeAccount.Id;
        insert parentWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectManageableById(new Set<Id>{ parentWorkOrder.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To fetch the parent work orders and store account selection based on the
     * passed child work order Ids.
     **/
    @isTest
    private static void testWhenChildWorkOrderIdsArePassedThenReturnRelatedParentWorkOrdersAndStoreAccounts() {
        List<Account> businessAccounts = new List<Account>();
        List<Account> storeAccounts = new List<Account>();
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();
        List<WorkOrder> childWorkOrders = new List<WorkOrder>();
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        parentAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        businessAccounts.add(parentAccount);
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        businessAccounts.add(businessAccount);
        insert businessAccounts;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccounts.add(storeAccount);
        Account newstoreAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccounts.add(newStoreAccount);
        insert storeAccounts;
        WorkOrder marketplaceWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        marketplaceWorkOrder.Opportunity__c = corporateOpportunity.Id;
        parentWorkOrders.add(marketplaceWorkOrder);
        insert parentWorkOrders;
        WorkOrder childMarketplaceWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        childMarketplaceWorkOrder.ParentWorkOrderId = marketplaceWorkOrder.Id;
        childWorkOrders.add(childMarketplaceWorkOrder);
        insert childWorkOrders;
        List<SObject> workOrderQueryResult = ((IWorkObjectsSyncSelector) Application.SELECTOR.newInstance(
                WorkOrder.SObjectType
            ))
            .selectParentDetailsByChildIds(new Set<Id>{ childMarketplaceWorkOrder.Id });
        System.assertEquals(
            childWorkOrders.size(),
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate child Work Orders are returned by ParentworkorderId
     **/
    @isTest
    private static void testWhenWorkOrdersFetchedByParentWOIdThenChildWorkOrdersReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
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
        WorkOrder parentStorefrontWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert parentStorefrontWorkOrder;
        WorkOrder storefrontWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Status = STATUS_IN_PROGRESS,
            ParentWorkOrderId = parentStorefrontWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert storefrontWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentAndChildWOsByWorkOrderIds(parentStorefrontWorkOrder.Id);
        System.assertEquals(1, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            storefrontWorkOrder.Id,
            workOrderQueryResult[0].Id,
            'Incorrect Work Order Returned'
        );
    }

    /**
     * @description To validate Parent Work Orders are returned by
     * Status, Type, SubType, OppdId and BatchID are passed
     **/
    @isTest
    private static void testWhenStatusAndTypeAndSubTypeAndOppIdAndBatchIDArePassedThenChildandParentWorkOrdersForDriveReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity corporateOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount.Id,
            true
        );
        WorkOrder parentDriveWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            ParentWorkOrderId = null,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert parentDriveWorkOrder;
        WorkOrder driveWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            ParentWorkOrderId = parentDriveWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert driveWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectParentAndChildWOsByWorkOrderIds(parentDriveWorkOrder.Id);
        System.assertEquals(2, workOrderQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            parentDriveWorkOrder.Id,
            workOrderQueryResult[1].Id,
            'Incorrect Work Order Returned'
        );
    }

    /*
     * @description To validate the Work Orders selection based on Account.
     **/
    @isTest
    private static void testWhenSelectingWorkOrderDetailsForAccountThenReturnRelatedNewWorkOrders() {
        List<Account> businessAccounts = new List<Account>();
        List<WorkOrder> workOrders = new List<WorkOrder>();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount);
        Account businessAccount2 = new Account(
            Name = ACCOUNT_NAME + ' 2',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount2);
        insert businessAccounts;
        Opportunity corporateOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount.Id,
            true
        );
        Opportunity corporateOpportunity2 = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount2.Id,
            true
        );
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
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        WorkOrder planningWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_PLANNING,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(planningWorkOrder);

        WorkOrder confirmedWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_CONFIRMED,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(confirmedWorkOrder);

        WorkOrder deadWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_DEAD,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(deadWorkOrder);

        WorkOrder inProgressWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(inProgressWorkOrder);

        WorkOrder otherWorkOrder = new WorkOrder(
            AccountId = businessAccount2.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_PLANNING,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity2.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(otherWorkOrder);
        WorkOrder marketplacePlanningWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        marketplacePlanningWorkOrder.Status = STATUS_PLANNING;
        marketplacePlanningWorkOrder.Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES;
        marketplacePlanningWorkOrder.Opportunity__c = corporateOpportunity.Id;
        workOrders.add(marketplacePlanningWorkOrder);
        insert workOrders;
        List<WorkOrder> queryResults = WorkOrdersSelector.newInstance()
            .selectWorkOrderDetailsForAccount(businessAccount.Id);
        System.assertEquals(1, queryResults.size(), EMPTY_LIST_ASSERT_MESSAGE);
        String incorrectWorkOrdersAssertMsg = 'Only Confirmed or Planning Work Orders should be returned';
        System.assert(
            queryResults[0].Status == STATUS_PLANNING || queryResults[0].Status == STATUS_CONFIRMED,
            incorrectWorkOrdersAssertMsg
        );
    }

    /*
     * @description To validate the Work Orders selection based on Status, Type, SubTpe, OppotunityId and Batch Id
     **/
    @isTest
    static void testWhenWorkOrdersFetchedByParentWOIdThenParentWorkOrdersReturned() {
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
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE,
            Sub_Type__c = WO_SUBTYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addDays(10)),
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY
        );
        insert parentWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                new Set<String>{ WORK_ORDER_STATUS },
                new Set<String>{ WORK_ORDER_TYPE },
                new Set<String>{ WO_SUBTYPE_COO },
                new Set<Id>{ parentOpportunity.Id },
                new Set<String>{ IR_BATCH_ID }
            );
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the Work Orders selection based on Account.
     **/
    @isTest
    private static void testWhenSelectingWorkOrderDetailsForAccountsThenReturnRelatedNewWorkOrders() {
        List<Account> businessAccounts = new List<Account>();
        List<WorkOrder> workOrders = new List<WorkOrder>();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount);
        Account businessAccount2 = new Account(
            Name = ACCOUNT_NAME + ' 2',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        businessAccounts.add(businessAccount2);
        insert businessAccounts;
        Opportunity corporateOpportunity = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount.Id,
            true
        );
        Opportunity corporateOpportunity2 = CPQTestDataFactory.createClosedWonOpportunityWithBypassedValidations(
            businessAccount2.Id,
            true
        );

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
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        WorkOrder planningWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_PLANNING,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(planningWorkOrder);

        WorkOrder confirmedWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_CONFIRMED,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(confirmedWorkOrder);

        WorkOrder deadWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_DEAD,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(deadWorkOrder);
        WorkOrder inProgressWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_IN_PROGRESS,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(inProgressWorkOrder);

        WorkOrder otherWorkOrder = new WorkOrder(
            AccountId = businessAccount2.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_TYPE,
            Status = STATUS_PLANNING,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity2.Id,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        workOrders.add(otherWorkOrder);
        WorkOrder marketplacePlanningWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        marketplacePlanningWorkOrder.Status = STATUS_PLANNING;
        marketplacePlanningWorkOrder.Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES;
        marketplacePlanningWorkOrder.Opportunity__c = corporateOpportunity.Id;
        workOrders.add(marketplacePlanningWorkOrder);
        insert workOrders;
        List<WorkOrder> queryResults = WorkOrdersSelector.newInstance()
            .selectWorkOrderDetailsForAccount(businessAccount.Id);
        System.assertEquals(1, queryResults.size(), EMPTY_LIST_ASSERT_MESSAGE);
        String incorrectWorkOrdersAssertMsg = 'Only Confirmed or Planning Work Orders should be returned';
        System.assert(
            queryResults[0].Status == STATUS_PLANNING || queryResults[0].Status == STATUS_CONFIRMED,
            incorrectWorkOrdersAssertMsg
        );
    }

    /**
     * @description To validate the selection of Non-Dead 'Drive' Work Orders
     * with sub-type as ‘Auto-Activations’ based on the passed Account Ids.
     **/
    @isTest
    private static void testWhenAccountIdsPassedThenReturnNonDeadDriveAutoActivationsWorkOrders() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        WorkOrder workOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORKORDER_TYPE_DRIVE,
            Sub_Type__c = WORK_ORDER_SUBTYPE_AUTO_ACTIVATIONS,
            Status = STATUS_PLANNING,
            Proposed_Date_of_Activation__c = System.today().addMonths(2),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Work_Order_Source__c = WORKORDER_SOURCE_SALES,
            Opportunity__c = corporateOpportunity.Id
        );
        insert workOrder;

        List<WorkOrder> queryResults = WorkOrdersSelector.newInstance()
            .selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(
                new Set<Id>{ businessAccount.Id }
            );
        System.assertEquals(1, queryResults.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To validate fetching of Withholding parent Work Orders by Contract Ids.
     **/
    @isTest
    private static void testWhenContractIdsPassedThenWithholdingParentWorkOrdersReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard',
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_WITHHOLDING;
        parentWorkOrder.Google_Sheet_URL__c = GOOGLE_SHEET_URL;
        parentWorkOrder.Provisioning_Status__c = STATUS_NOT_STARTED;
        parentWorkOrder.Google_Sheet_URL__c = GOOGLE_SHEET_URL;
        insert parentWorkOrder;
        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectWithholdingParentWorkOrdersByContractIds(new Set<Id>{ contractInstance.Id });
        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }
    /**
     * @description It queries child WOs using its associated Account Ids
     * @jira# LEM-12911
     */
    @isTest
    private static void testWhenSelectInProgressWorkOrdersThenParentDetailsByAccountIds() {
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
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
            Tablet_Delivery_Method__c = ACCOUNT_TABLET_DELIVERY_METHOD,
            POS_Integration_Type__c = ACCOUNT_POS_INTEGRATION_TYPE
        );
        insert storeAccount;

        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;

        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert childWorkOrder;

        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectInProgressWorkOrdersWithParentDetailsByAccountIds(
                new Set<Id>{ storeAccount.Id }
            );

        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            workOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description It queries child WOs using its parent Work Order Id & by order protocol
     * @jira# LEM-12911
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectAllChildWosThenReturnOrderProtocol() {
        Account parentAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Account storeAccount = new Account(
            Name = ACCOUNT_NAME_STORE,
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_DEACTIVATED,
            BillingStreet = ACCOUNT_BILLING_STREET,
            ParentId = parentAccount.Id,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Tablet_Delivery_Method__c = ACCOUNT_TABLET_DELIVERY_METHOD,
            POS_Integration_Type__c = ACCOUNT_POS_INTEGRATION_TYPE
        );
        insert storeAccount;

        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            StageName = OPPORTUNITY_STAGE,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;

        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            createddate = system.today()
        );
        insert parentWorkOrder;

        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = parentOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = 'Complete',
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert childWorkOrder;

        List<WorkOrder> allChildWoworkOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectAllChildWosByOrderProtocol(
                parentWorkOrder.Id,
                parentWorkOrder.Order_Protocol__c
            );

        System.assertEquals(
            NUMBER_OF_WORKORDERS_RETURNED,
            allChildWoworkOrderQueryResult.size(),
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }

    /**
     * @description To fetch market place WorkOrder fetched by accountIDs
     **/
    @isTest
    private static void testWhenFetchMarketPlaceAndDriveWorkOrderCalledThenReturnFilteredWorkOrder() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;

        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Google_Sheet_URL__c = GOOGLE_SHEET_URL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id
        );
        insert marketplaceWorkOrder;

        List<WorkOrder> workOrderQueryResult = WorkOrdersSelector.newInstance()
            .selectMarketplaceAndDriveWorkOrderInAllowedStatusByAccounts(
                new Set<Id>{ businessAccount.Id }
            );
        System.assertEquals(
            marketplaceWorkOrder.Id,
            workOrderQueryResult[0].Id,
            ASSERT_MESSAGE_WORK_ORDER_ID
        );
    }

    /**
     * @description To validate fetching of Work Orders with Parent Work Order Ids by Account Ids.
     **/
    @isTest
    private static void testWhenSelectWorkOrdersByParentIdThenReturnWorkOrders() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_WITHHOLDING;
        parentWorkOrder.Provisioning_Status__c = STATUS_NOT_STARTED;
        parentWorkOrder.Google_Sheet_URL__c = GOOGLE_SHEET_URL;
        insert parentWorkOrder;

        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByParentId(parentWorkOrder.Id);
        Test.stopTest();

        System.assertNotEquals(1, result.size(), 'Work Orders returned');
    }

    /**
     * @description To validate fetching of Work Orders with Parent Work Order Ids by Account Ids.
     **/
    @isTest
    private static void testWhenSelectWorkOrdersWithParentWorkOrderIdByAccountIdsThenReturnStoreAccount() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Sub_Type__c = WORK_ORDER_SUBTYPE_WITHHOLDING;
        parentWorkOrder.Provisioning_Status__c = STATUS_NOT_STARTED;
        parentWorkOrder.Google_Sheet_URL__c = GOOGLE_SHEET_URL;
        insert parentWorkOrder;

        Test.startTest();
        Set<Id> storeAccountIds = new Set<Id>{ storeAccount.Id };
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectWorkOrdersWithParentWorkOrderIdByAccountIds(storeAccountIds);
        Test.stopTest();

        System.assertNotEquals(1, result.size(), 'Work Orders returned');
    }

    /**
     * @description To Work Orders for fetched with related WorkSteps details based on passed
     * WorkOrderIds and WorkStep Types.
     */
    @isTest
    private static void testWhenWorkOrderIdsAndWorkStepTypesPassedThenWorkOrdersWithRelatedWorkStepsAreReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;
        List<WorkStep> childWorkSteps = new List<Workstep>{
            new WorkStep(
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status = STATUS_NOT_STARTED,
                Status__c = STATUS_NOT_STARTED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = relatedWorkPlan.Id
            ),
            new Workstep(
                Name = WORK_STEP_NAME_SETUP_BUSINESS,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_BUSINESS,
                WorkPlanId = relatedWorkPlan.Id
            )
        };
        insert childWorkSteps;
        List<WorkOrder> workOrderWithWorkStepsResult = WorkOrdersSelector.newInstance()
            .selectMarketplaceWorkOrdersAndWorkStepsByAccountIdsAndWorkStepTypes(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ WORK_STEP_NAME_SETUP_BUSINESS }
            );
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult != null,
            QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult[0].WorkSteps != null,
            QUERY_RETURN_NO_CHILD_WORK_STEPS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate fetching of Parent Work Orders by SSMO UUIDs.
     */
    @isTest
    private static void testWhenUniqueIdentifiersPassedThenReturnParentWorkOrders() {
        String uniqueIdentifier = '123456789';
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        parentWorkOrder.Unique_Identifier__c = uniqueIdentifier;
        parentWorkOrder.Status = STATUS_PLANNING;

        insert parentWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectParentWorkOrdersByUniqueIdentifiers(new Set<String>{ uniqueIdentifier });
        Test.stopTest();
        System.assertEquals(1, result.size(), WORK_ORDER_STATUS_NOT_RETURNED);
    }

    /**
     * @description To test when Account Ids are passed then Work Orders where Account Segment is
     * 'SMB'.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnWorkOrdersWhereAccountSegmentSMB() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectWorkOrdersBySegment(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(1, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Account Ids are passed then Work Orders where Account Segment is
     * 'SMB' and not 'Enterprise'.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDoNotReturnWorkOrdersWhereAccountSegmentNotSMB() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_ENTERPRISE;
        insert businessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        storeAccount.Segment__c = ACCOUNT_SEGMENT_ENTERPRISE;
        insert storeAccount;
        Contract contractInstance = new Contract(
            AccountId = storeAccount.Id,
            Status = CONTRACT_STATUS
        );
        insert contractInstance;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            SBQQ__AmendedContract__c = contractInstance.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Contract__c = contractInstance.Id;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectWorkOrdersBySegment(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(0, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }
    /**
     * @description To test Work Orders are fetched with related WorkSteps details based on passed
     * Account Ids, Work Order Types and Work Step Types.
     */
    @isTest
    private static void testWhenAccountIdsAndWorkOrderTypesAndWorkStepTypesPassedThenWorkOrdersAndWorkStepsAreReturned() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addMonths(6),
            Pricebook2Id = Test.getStandardPricebookId(),
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORKORDER_TYPE_STOREFRONT
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME,
            WorkOrderId = newWorkOrder.Id
        );
        insert relatedWorkPlan;
        List<WorkStep> childWorkSteps = new List<Workstep>{
            new WorkStep(
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status = STATUS_NOT_STARTED,
                Status__c = STATUS_NOT_STARTED,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = relatedWorkPlan.Id
            ),
            new Workstep(
                Name = WORK_STEP_NAME_SETUP_BUSINESS,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_BUSINESS,
                WorkPlanId = relatedWorkPlan.Id
            )
        };
        insert childWorkSteps;
        List<WorkOrder> workOrderWithWorkStepsResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
                new Set<Id>{ businessAccount.Id },
                new Set<String>{ WORKORDER_TYPE_STOREFRONT },
                new Set<String>{ WORK_STEP_TYPE_IMPLEMENTATION_CALL }
            );
        System.assertEquals(
            true,
            workOrderWithWorkStepsResult != null,
            QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE
        );
        System.assertEquals(
            1,
            workOrderWithWorkStepsResult[0].WorkSteps.size(),
            QUERY_RETURN_NO_CHILD_WORK_STEPS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Originating Work Order Ids are passed and Marketplace Work Orders
     * contain Marketing Kit Work Orders then return Marketing Kit Work Orders.
     */
    @isTest
    private static void testWhenOriginatingWorkOrderIdsPassedContainsMarketingKitWorkOrdersThenReturnMarketingKitWorkOrders() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert marketplaceWorkOrder;
        WorkOrder marketingKitWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_IN_PROGRESS,
            Type__c = WORK_ORDER_TYPE_MARKETING_KIT,
            Originating_Work_Order__c = marketplaceWorkOrder.Id
        );
        insert marketingKitWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectMarketingKitWorkOrdersByOriginatingWorkOrder(
                new Set<Id>{ marketplaceWorkOrder.Id }
            );
        Test.stopTest();
        System.assertEquals(1, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Originating Work Order Ids are passed and Marketplace Work Order
     * does not contain any active Marketing Kit Work Orders then do not return Marketing Kit Work Orders.
     */
    @isTest
    private static void testWhenOriginatingWorkOrderIdsPassedDoesNotContainActiveMarketingKitWorkOrderThenDoNotReturnMarketingKitWorkOrders() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_DEAD,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert marketplaceWorkOrder;
        WorkOrder marketingKitWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_DEAD,
            Type__c = WORK_ORDER_TYPE_MARKETING_KIT,
            Originating_Work_Order__c = marketplaceWorkOrder.Id
        );
        insert marketingKitWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectMarketingKitWorkOrdersByOriginatingWorkOrder(
                new Set<Id>{ marketplaceWorkOrder.Id }
            );
        Test.stopTest();
        System.assertEquals(0, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Account Ids are passed then return Marketplace Work Order with
     * Provisioning Status as Ready for Provisioning.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnReadyForProvisioningMarketplaceWorkOrder() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;

        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = UPGRADE,
            Deal_Type__c = STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;

        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_CONFIRMED,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert marketplaceWorkOrder;
        WorkOrder storefrontWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_CONFIRMED,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORKORDER_TYPE_STOREFRONT
        );
        insert storefrontWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(
                new Set<Id>{ businessAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(1, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Business Account Ids are passed then return
     * Parent and Child Work Orders with Work Plans.
     */
    @IsTest
    private static void testWhenBusinessAccountIdsPassedThenReturnWorkOrdersWithWorkPlans() {
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;

        Opportunity corporateOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID,
            Opportunity_Sub_Type__c = UPGRADE,
            Deal_Type__c = STANDARD,
            Estimated_Number_of_Stores__c = 2
        );
        insert corporateOpportunity;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            corporateOpportunity,
            businessAccount,
            null,
            true
        );
        Order churnedMxOrder = CPQTestDataFactory.createOrder(
            businessAccount,
            corporateOpportunity,
            quote,
            false
        );
        churnedMxOrder.Type = CHURNED_MERCHANT;
        churnedMxOrder.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert churnedMxOrder;
        Contract churnedMxContracts = new Contract(
            StartDate = Date.today() + 1,
            Status = CONTRACT_STATUS,
            AccountId = businessAccount.Id,
            SBQQ__Order__c = churnedMxOrder.Id,
            Is_Churned_Mx_Contract_Processed__c = false
        );
        insert churnedMxContracts;

        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Opportunity__c = corporateOpportunity.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_CONFIRMED,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Contract__c = churnedMxContracts.Id
        );
        insert marketplaceWorkOrder;
        WorkOrder storefrontWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Opportunity__c = corporateOpportunity.Id,
            Proposed_Date_of_Activation__c = createPdoaDate(System.today().addMonths(2)),
            Status = STATUS_CONFIRMED,
            Provisioning_Status__c = PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            Type__c = WORKORDER_TYPE_STOREFRONT,
            Contract__c = churnedMxContracts.Id
        );
        insert storefrontWorkOrder;
        Test.startTest();
        List<WorkOrder> result = WorkOrdersSelector.newInstance()
            .selectParentAndChildWorkOrdersWithWorkPlansByBusinessAccountIds(
                new Set<Id>{ businessAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(2, result.size(), QUERY_RETURN_NO_WORK_ORDERS_ASSERT_MESSAGE);
    }
}