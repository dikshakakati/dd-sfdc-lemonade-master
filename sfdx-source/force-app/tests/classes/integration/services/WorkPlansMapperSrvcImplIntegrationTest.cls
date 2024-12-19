/**
 * @author Deloitte
 * @date 07/04/2022
 * @description Integration test class for WorkPlansMapperService class.
 */
@isTest(SeeAllData=false)
private class WorkPlansMapperSrvcImplIntegrationTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ASSERT_MESSAGE_NO_WORK_PLAN_CREATED = 'Unexpected result: the list does not contain any WorkPlans created for WorkOrder';
    private static final String ASSERT_MESSAGE_WORK_PLAN_NAME_MISMATHCH = 'Unexpected result: failed to create Onboarding WorkPlan on WorkOrder';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final string OPPORTUNITY_STAGE = 'Prospecting';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_STATUS_PLANNING = 'Planning';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding COO';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_PLAN_NAME_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';

    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupData() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_COO,
            Type__c = WORK_ORDER_TYPE_COO
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
     * @description To test whether WorkPlanMapper returns correct map of Work Order Id
     * to Work Plan types which create Work Plans on Work Order.
     */
    @isTest
    private static void testWhenWorkOrderInsertedThenReturnWorkPlansCreated() {
        Account parentAccount = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            LIMIT 1
        ];
        Account storeAccount = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_NAME_STORE
            LIMIT 1
        ];
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS_PLANNING,
            Type__c = WORK_ORDER_TYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(7),
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT
        );
        insert parentWorkOrder;
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Status = WORK_ORDER_STATUS_PLANNING,
            Type__c = WORK_ORDER_TYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            ParentWorkOrderId = parentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(7),
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM
        );
        insert newWorkOrder;
        // deliver change events related to parent and child Work Order insertion
        Test.getEventBus().deliver();
        Test.startTest();
        newWorkOrder.Provisioning_Status__c = PROVISIONING_STATUS_READINESS_CHECK_COMPLETE;
        update newWorkOrder;
        Test.stopTest();
        Test.getEventBus().deliver();
        List<WorkPlan> workPlans = new List<WorkPlan>(
            [SELECT Id, Name FROM WorkPlan WHERE ParentRecordId = :newWorkOrder.Id]
        );
        System.assertEquals(false, workPlans.isEmpty(), ASSERT_MESSAGE_NO_WORK_PLAN_CREATED);
        System.assertEquals(
            ONBOARDING_WORK_PLAN_TEMPLATE,
            workPlans[0].Name,
            ASSERT_MESSAGE_WORK_PLAN_NAME_MISMATHCH
        );
    }
}