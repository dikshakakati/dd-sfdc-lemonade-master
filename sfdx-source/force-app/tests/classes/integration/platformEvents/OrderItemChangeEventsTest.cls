/**
 * @author Deloitte
 * @date 24/06/2022
 * @description Test class for OrderItemChangeEvents trigger.
 */
@isTest
private class OrderItemChangeEventsTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String INCORRECT_NUMBER_OF_CHILD_WORK_ORDERS_ASSERT_MESSAGE = 'Unexpected result: OrderItemChangeEvent failed to create child Work Orders';
    private static final Integer NUMBER_OF_CHILD_WORK_ORDERS = 1;
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String PRODUCT_NAME = 'Marketplace';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String WORK_ORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String IR_BATCH_ID = 'Batch001';

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
     * @description To test OrderItemChangeEvent on OrderItem insert.
     */
    @isTest
    private static void testWhenOrderItemChangeEventInsertThenRunTrigger() {
        Test.enableChangeDataCapture();
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        parentBusinessAccount.Corporate_Owned_Store_Count__c = 0;
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Opportunity corporateOpportunity = new Opportunity(
            AccountId = parentBusinessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            Batch_Id__c = IR_BATCH_ID
        );
        insert corporateOpportunity;
        WorkOrder marketplaceParentWorkOrder = new WorkOrder(
            AccountId = parentBusinessAccount.Id,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = System.today().addMonths(2),
            Activated_Centrally_AC__c = WORK_ORDER_ACTIVATED_CENTRALLY_YES,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM,
            Opportunity__c = corporateOpportunity.Id
        );
        insert marketplaceParentWorkOrder;
        WorkOrder marketplaceWorkOrder = new WorkOrder(
            AccountId = storeAccount.Id,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            ParentWorkOrderId = marketplaceParentWorkOrder.Id,
            Proposed_Date_of_Activation__c = System.today().addMonths(2),
            Activated_Centrally_AC__c = WORK_ORDER_ACTIVATED_CENTRALLY_YES,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SYSTEM,
            Opportunity__c = corporateOpportunity.Id
        );
        insert marketplaceWorkOrder;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 activeProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        insert activeProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            activeProduct.Id
        );
        insert pricebookEntry;
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            activeProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        insert orderItem;
        Test.getEventBus().deliver();
        List<WorkOrder> childWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE AccountId = :storeAccount.Id
        ];
        System.assertEquals(
            NUMBER_OF_CHILD_WORK_ORDERS,
            childWorkOrder.size(),
            INCORRECT_NUMBER_OF_CHILD_WORK_ORDERS_ASSERT_MESSAGE
        );
    }
}