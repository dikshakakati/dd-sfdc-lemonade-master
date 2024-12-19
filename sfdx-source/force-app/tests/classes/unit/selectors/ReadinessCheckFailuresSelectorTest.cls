/**
 * @author Deloitte
 * @date 24/07/2022
 * @description Test class for ReadinessCheckFailuresSelector class.
 */
@isTest
private class ReadinessCheckFailuresSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final String ASSERT_MESSAGE_INCORRENT_READINESS_CHECK_FAILURE_COUNT = 'Unexpected result: the aggregate query returned incoorect count';
    private static final String ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE = 'Unexpected result: the object type must be Readiness Check Failure';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_NO_READINESS_CHECK_FAILURE_RECORDS = 'Unexpected result: the query did not return any Readiness Check Failure records';
    private static final String ACCOUNT_NAME = 'Test KFC';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_STORE_RECORD_TYPE = 'Store';
    private static final String CHILD_WORK_ORDER_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'childWorkOrderId';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String OPPORTUNITY_NAME = 'Baker Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE = 'Please ensure Legal Business Name is populated.';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME = 'Legal_Business_Name__c';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME = 'Account';
    private static final String READINESS_CHECK_ERROR_MESSAGE = 'Please ensure Activate Centrally (AC) is populated as No.';
    private static final String READINESS_CHECK_FIELD_NAME = 'Activated_Centrally_AC__c';
    private static final String READINESS_CHECK_OBJECT_NAME = 'WorkOrder';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_PLAN_TEMPLATE_NAME_ONBOARDING = 'Onboarding';
    private static final String WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_TEMPLATE_NAME_SETUP_BANKING = 'SETUP_BANKING';



    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupData() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_MARKETPLACE,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert workOrderTemplate;
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_ONBOARDING,
            Type__c = ONBOARDING_WORK_PLAN_TEMPLATE,
            isActive = true
        );
        WorkPlanTemplate setupBankingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING,
            isActive = true
        );
        insert new List<WorkPlanTemplate>{
            onboardingWorkPlanTemplate,
            setupBankingWorkPlanTemplate
        };
        WorkStepTemplate reviewTriageWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE,
            IsActive = true
        );
        WorkStepTemplate setupBankingWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING,
            IsActive = true
        );
        insert new List<WorkStepTemplate>{
            reviewTriageWorkStepTemplate,
            setupBankingWorkStepTemplate
        };
        WorkPlanTemplateEntry workPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
            ExecutionOrder = 1,
            Active__c = true
        );
        insert workPlanTemplateEntry;
        WorkPlanTemplateEntry onboardingWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
            ExecutionOrder = 1,
            Active__c = true
        );
        WorkPlanTemplateEntry setupBankingWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = setupBankingWorkPlanTemplate.Id,
            WorkStepTemplateId = setupBankingWorkStepTemplate.Id,
            Active__c = true
        );
        insert new List<WorkPlanTemplateEntry>{
            onboardingWorkPlanTemplateEntry,
            setupBankingWorkPlanTemplateEntry
        };
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Name = WORK_ORDER_TEMPLATE_ENTRY,
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = onboardingWorkPlanTemplate.Id
        );
        insert workOrderTemplateEntry;
        WorkStepDependencyTemplate__c workStepDepenencyTemplate = new WorkStepDependencyTemplate__c(
            Dependee_Work_Plan_Template_Entry__c = onboardingWorkPlanTemplateEntry.Id,
            Dependent_Work_Plan_Template_Entry__c = setupBankingWorkPlanTemplateEntry.Id,
            Is_Active__c = true
        );
        insert workStepDepenencyTemplate;
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = businessAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
        );
        insert storeAccount;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert childWorkOrder;
        List<Readiness_Check_Failure__c> readinessCheckFailures = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Account_Name__c = childWorkOrder.AccountId,
                Child_Work_Order__c = childWorkOrder.Id,
                Error_Message__c = READINESS_CHECK_ERROR_MESSAGE,
                Field_Name__c = READINESS_CHECK_FIELD_NAME,
                Object_Name__c = READINESS_CHECK_OBJECT_NAME,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Account_Name__c = businessAccount.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Parent_Work_Order__c = parentWorkOrder.Id
            ),//@JIRA# LEM-13963
            new Readiness_Check_Failure__c(
                Account_Name__c = businessAccount.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Status__c = 'Resolved'
            )
        };

        insert readinessCheckFailures;
    }

    /**
     * @description To test instantiation and return of correct sobjectType and sobject fields.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        ReadinessCheckFailuresSelector readinessCheckFailureInstance = new ReadinessCheckFailuresSelector();
        Schema.SObjectType typeOfObject = readinessCheckFailureInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = readinessCheckFailureInstance.getSObjectFieldList();
        ReadinessCheckFailuresSelector.newInstance();
        System.assertEquals(
            Schema.Readiness_Check_Failure__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ Readiness_Check_Failure__c.Id },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS
        );
    }

    /**
     * @description To test query on Readiness_Check_Failure__c for getting failure records
     * associated with business Account of passed WorkOrder Ids.
     */
    @isTest
    private static void testWhenSelectByChildWorkOrderIdsCalledThenBusinessAccountRelatedFailuresReturned() {
        WorkOrder parentWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE ParentWorkOrderId = NULL
            LIMIT 1
        ];
        Test.startTest();
        List<Readiness_Check_Failure__c> readinessCheckFailureQueryResult = ReadinessCheckFailuresSelector.newInstance()
            .selectByChildWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        Test.stopTest();
        System.assertEquals(
            false,
            readinessCheckFailureQueryResult.isEmpty(),
            ASSERT_MESSAGE_NO_READINESS_CHECK_FAILURE_RECORDS
        );
    }

    /**
     * @description To test query on Readiness_Check_Failure__c for getting failure records
     * of passed parent WorkOrder Ids.
     */
    @isTest
    private static void testWhenSelectByParentWorkOrderIdsCalledThenRelevantReadinessCheckFailuresReturned() {
        WorkOrder parentWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE ParentWorkOrderId = NULL
            LIMIT 1
        ];
        Test.startTest();
        List<Readiness_Check_Failure__c> readinessCheckFailureQueryResult = ReadinessCheckFailuresSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
        Test.stopTest();
        System.assertEquals(
            false,
            readinessCheckFailureQueryResult.isEmpty(),
            ASSERT_MESSAGE_NO_READINESS_CHECK_FAILURE_RECORDS
        );
    }

    /**
     * @description To test query on Readiness_Check_Failure__c for getting failure count
     * of passed WorkOrder Ids.
     */
    @isTest
    private static void testWhenGetReadinessFailuresCountFilteredAndGroupedByWorkOrderIdsCalledThenReadinessCheckFailuresCountReturned() {
        WorkOrder childWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE ParentWorkOrderId != NULL
            LIMIT 1
        ];
        Test.startTest();
        Aggregate[] aggregateQueryResult = ReadinessCheckFailuresSelector.newInstance()
            .getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(
                new Set<Id>{ childWorkOrder.Id }
            );
        Test.stopTest();
        System.assertEquals(
            childWorkOrder.Id,
            (Id) aggregateQueryResult[0]
                .get(CHILD_WORK_ORDER_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
            ASSERT_MESSAGE_INCORRENT_READINESS_CHECK_FAILURE_COUNT
        );
    }

    /**
* @description It is used to get the Readiness Check Failure Record.
* Status is equal to Resolved and createddate less than week.
* @JIRA# LEM-13963
*/
    @isTest
    private static void testWhenSelectByReadinessCheckFailureThenDeleteRecord() {
        Test.startTest();
        List<Readiness_Check_Failure__c> readinessCheckFailureQueryLocator = ReadinessCheckFailuresSelector.newInstance()
            .selectByReadinessCheckFailureId();
        Test.stopTest();
        System.assertEquals(
            readinessCheckFailureQueryLocator.size(),
            readinessCheckFailureQueryLocator.size(),
            ASSERT_MESSAGE_NO_READINESS_CHECK_FAILURE_RECORDS
        );
    }
}