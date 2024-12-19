/**
 * @author Deloitte
 * @date 06/05/2022
 * @description Test class for WorkStepDependenciesSelector class.
 */
@isTest
private class WorkStepDependenciesSelectorTest {
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final String ACCOUNT_NAME = 'Test KFC';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE = 'Unexpected result: the object type must be Work Step Dependency';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_DEPENDENCY_RECORD = 'Unexpected result: Work Step Dependency record not found for Dependent WorkStep';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_INCORRENT_WORK_STEP_DEPENDENCY_COUNT = 'Unexpected result: the aggregate query returned incorrect count';
    private static final String ASSERT_MESSAGE_NO_WORK_STEP_DEPENDENCY_RECORDS = 'Unexpected result: the query does not return any WorkStepDependency records';
    private static final String ASSERT_MESSAGE_WORK_STEP_DEPENDENCY_RETURNED_FOR_DEAD_STATUS = 'Unexpected result: the query returned WorkStepDependency records when dependee WorkStep Status is Dead';
    private static final String DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'dependentWorkStep';
    private static final String DEPENDENCY_DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'groupingId';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String OPPORTUNITY_NAME = 'Baker Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_REASON_OTHER = 'Other';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_TEMPLATE_NAME_ONBOARDING = 'Onboarding';
    private static final String WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
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
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
        );
        insert businessAccount;
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
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Opportunity__c = parentOpportunity.Id,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
        WorkStep dependeeWorkStep = new WorkStep(
            Name = WORK_STEP_SETUP_STORE,
            Status__c = WORK_STEP_STATUS_COMPLETE,
            Type__c = WORK_STEP_SETUP_STORE,
            WorkPlanId = relatedWorkPlan.Id,
            Work_Step_Sequence__c = 1
        );
        insert dependeeWorkStep;
        WorkStep dependentWorkStep = new WorkStep(
            Name = WORK_STEP_SETUP_STOREFRONT_PAGE,
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
            Type__c = WORK_STEP_SETUP_STOREFRONT_PAGE,
            WorkPlanId = relatedWorkPlan.Id,
            Work_Step_Sequence__c = 1
        );
        insert dependentWorkStep;
        WorkStepDependency__c workStepDependency = new WorkStepDependency__c(
            Dependee_Work_Step__c = dependeeWorkStep.Id,
            Dependent_Work_Step__c = dependentWorkStep.Id,
            Work_Step_Dependency_Template__c = workStepDepenencyTemplate.Id
        );
        insert workStepDependency;
    }

    /**
     * @description To test instantiation and return of correct sobjectType and sobject fields list.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkStepDependenciesSelector workStepDependenciesInstance = new WorkStepDependenciesSelector();
        Schema.SObjectType typeOfObject = workStepDependenciesInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workStepDependenciesInstance.getSObjectFieldList();
        WorkStepDependenciesSelector.newInstance();
        System.assertEquals(
            Schema.WorkStepDependency__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkStepDependency__c.Id,
                WorkStepDependency__c.Dependee_Work_Step__c,
                WorkStepDependency__c.Dependent_Work_Step__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS
        );
    }

    /**
     * @description To test query on WorkStepDependency__c for getting dependent WorkSteps
     * of passed sObject Ids.
     */
    @isTest
    private static void testWhenGetWorkStepDependencyCountFilteredAndGroupedBySobjectIdsIsCalledThenDependeciesCountIsReturned() {
        WorkStepDependency__c workStepdepedency = [
            SELECT Id, Dependee_Work_Step__c, Dependent_Work_Step__c
            FROM WorkStepDependency__c
            LIMIT 1
        ];
        WorkStep workStep = [
            SELECT Id
            FROM WorkStep
            WHERE Type__c = :WORK_STEP_SETUP_STOREFRONT_PAGE
            LIMIT 1
        ];
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
        Test.startTest();
        Aggregate[] aggregateQueryResult = WorkStepDependenciesSelector.newInstance()
            .getWorkStepDependencyCountFilteredAndGroupedBySobjectIds(
                new Set<Id>{ workStepdepedency.Dependent_Work_Step__c },
                fieldToFilter
            );
        Test.stopTest();
        System.assertEquals(
            workStep.Id,
            (Id) aggregateQueryResult[0]
                .get(DEPENDENCY_DEPENDENCY_COUNT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
            ASSERT_MESSAGE_INCORRENT_WORK_STEP_DEPENDENCY_COUNT
        );
    }

    /**
     * @description To test query on WorkStepDependency__c for getting dependent WorkSteps
     * of passed WorkStep Ids.
     */
    @isTest
    private static void testWhenSelectDependenciesByDependeeWorkStepsIdsIsCalledThenRelevantDependeciesAreReturned() {
        WorkStepDependency__c workStepdepedency = [
            SELECT Dependee_Work_Step__c, Dependent_Work_Step__c
            FROM WorkStepDependency__c
            LIMIT 1
        ];
        Test.startTest();
        List<WorkStepDependency__c> workStepDependenciesResult = WorkStepDependenciesSelector.newInstance()
            .selectDependenciesByDependeeWorkStepsIds(
                new Set<Id>{ workStepdepedency.Dependee_Work_Step__c }
            );
        Test.stopTest();
        System.assertEquals(
            false,
            workStepDependenciesResult.isEmpty(),
            ASSERT_MESSAGE_NO_WORK_STEP_DEPENDENCY_RECORDS
        );
    }

    /**
     * @description To test query that fetches WorkStepDependencies where Dependent_Work_Step__c
     * is in the passed set of WorkStep Ids
     */
    @isTest
    private static void testWhenSelectDependeeWorkStepsByDependentIdsCalledThenWorkStepDependeciesReturned() {
        WorkStep dependeeWorkStep = [
            SELECT Id, Status__c
            FROM WorkStep
            WHERE Type__c = :WORK_STEP_SETUP_STORE
            LIMIT 1
        ];
        dependeeWorkStep.Status__c = STATUS_IN_PROGRESS;
        update dependeeWorkStep;
        WorkStep dependentWorkStep = [
            SELECT Id
            FROM WorkStep
            WHERE Type__c = :WORK_STEP_SETUP_STOREFRONT_PAGE
            LIMIT 1
        ];
        Test.startTest();
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
        List<WorkStepDependency__c> dependenciesResult = WorkStepDependenciesSelector.newInstance()
            .selectDependeeWorkStepsByDependentSobjectIds(
                new Set<Id>{ dependentWorkStep.Id },
                fieldToFilter
            );
        Test.stopTest();
        System.assertEquals(
            dependentWorkStep.Id,
            dependenciesResult[0].Dependent_Work_Step__c,
            ASSERT_MESSAGE_MISMATCH_IN_DEPENDENCY_RECORD
        );
    }

    /**
     * @description To test query that fetches WorkStepDependencies where Dependee_WorkStep__c's WorkOrder
     * or Dependent_Work_Step__r's WorkOrder is in the passed set of WorkOrder Ids.
     */
    @isTest
    private static void testWhenSelectDependenciesByWorkOrderIdsCalledThenWorkStepDependeciesReturned() {
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE ParentWorkOrderId != NULL LIMIT 1];
        Test.startTest();
        List<WorkStepDependency__c> dependenciesResult = WorkStepDependenciesSelector.newInstance()
            .selectDependenciesByWorkOrderIds(new Set<Id>{ workOrder.Id });
        Test.stopTest();
        System.assertEquals(
            true,
            dependenciesResult.size() != 0,
            ASSERT_MESSAGE_MISMATCH_IN_DEPENDENCY_RECORD
        );
    }

    /**
     * @description To test query does not fetch any WorkStepDependencies when dependee WorkStep
     * Status is Dead and Dependent_Work_Step__c is in the passed set of Work Step Ids.
     */
    @isTest
    private static void testWhenDependeeWorkStepStatusDeadThenWorkStepDependeciesNotReturned() {
        WorkStep dependeeWorkStep = [
            SELECT Id, Status__c
            FROM WorkStep
            WHERE Type__c = :WORK_STEP_SETUP_STORE
            LIMIT 1
        ];
        dependeeWorkStep.Status__c = STATUS_DEAD;
        dependeeWorkStep.Status_Reason__c = STATUS_REASON_OTHER;
        update dependeeWorkStep;
        WorkStep dependentWorkStep = [
            SELECT Id
            FROM WorkStep
            WHERE Type__c = :WORK_STEP_SETUP_STOREFRONT_PAGE
            LIMIT 1
        ];
        Test.startTest();
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Step__c;
        List<WorkStepDependency__c> dependenciesResult = WorkStepDependenciesSelector.newInstance()
            .selectDependeeWorkStepsByDependentSobjectIds(
                new Set<Id>{ dependentWorkStep.Id },
                fieldToFilter
            );
        Test.stopTest();
        System.assertEquals(
            0,
            dependenciesResult.size(),
            ASSERT_MESSAGE_WORK_STEP_DEPENDENCY_RETURNED_FOR_DEAD_STATUS
        );
    }

    /**
     * @description To test query on WorkStepDependency__c for getting dependee WorkSteps status
     * by passed WorkStep Ids.
     */
    @isTest
    private static void testWhenDependentWorkStepIdsReceivedThenDependeeWorkStepsStatusReturned() {
        WorkStepDependency__c workStepdepedency = [
            SELECT Dependee_Work_Step__c, Dependent_Work_Step__c
            FROM WorkStepDependency__c
            LIMIT 1
        ];
        Test.startTest();
        List<WorkStepDependency__c> workStepDependenciesResult = WorkStepDependenciesSelector.newInstance()
            .selectDependenciesByDependentWorkStepsIds(
                new Set<Id>{ workStepdepedency.Dependent_Work_Step__c }
            );
        Test.stopTest();
        System.assertEquals(
            false,
            workStepDependenciesResult.isEmpty(),
            ASSERT_MESSAGE_NO_WORK_STEP_DEPENDENCY_RECORDS
        );
    }
}