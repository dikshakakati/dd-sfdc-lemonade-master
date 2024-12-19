/**
 * @author Deloitte
 * @date 19/04/2022
 * @description Test class for WorkPlanTemplatesSelector class.
 */
@isTest
private class WorkPlanTemplatesSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE = 'Unexpected result: the object type must be WorkPlanTemplate';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_NO_WORK_PLAN_TEMPLATE_RECORDS = 'Unexpected result: the list does not contain any WorkPlanTemplate records';
    private static final String ASSERT_MESSAGE_NO_WPT_WITH_WPTE_RECORDS = 'Unexpected result: query returned no WorkPlanTempates with WorkPlanTempalteEntires records';
    private static final String MENU_TO_BE_COMPLETED_BY_MERCHANT = 'Merchant';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE = 'Prospecting';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String STOREFRONT_BUNDLED = 'Storefront Bundled';
    private static final string WORK_ORDER_AC = 'Yes';
    private static final string WORK_ORDER_STATUS = 'Planning';
    private static final string WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding COO';
    private static final string WORK_ORDER_TYPE_COO = 'COO';
    private static final String STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_NAME_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_PLAN_TEMPLATE_NAME = 'Onboarding';
    private static final String WORK_PLAN_TEMPLATE_POS = 'POS';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String WORK_STEP_TEMPLATE_CONFIGURE_POS = 'Configure POS';

    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupData() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
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
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert parentOpportunity;
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_COO,
            Type__c = WORK_ORDER_TYPE_COO
        );
        insert workOrderTemplate;
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME,
            Type__c = WORK_PLAN_TEMPLATE_NAME,
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
        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = parentAccount.Id,
            Status = WORK_ORDER_STATUS,
            Menu_To_Be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MERCHANT,
            Opportunity__c = parentOpportunity.Id,
            Type__c = WORK_ORDER_TYPE_COO,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Proposed_Date_of_Activation__c = System.today().addDays(7)
        );
        insert newWorkOrder;
        WorkPlan relatedWorkPlan = new WorkPlan(
            Name = STOREFRONT,
            ParentRecordId = newWorkOrder.Id,
            Status__c = WORK_PLAN_NAME_STATUS_NOT_STARTED
        );
        insert relatedWorkPlan;
    }

    /**
     * @description To test instantiation and return of correct sobjectType and sobject fields list.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkPlanTemplatesSelector workPlanTemplatesInstance = new WorkPlanTemplatesSelector();
        Schema.SObjectType typeOfObject = workPlanTemplatesInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workPlanTemplatesInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.WorkPlanTemplate.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkPlanTemplate.Id,
                WorkPlanTemplate.Name,
                WorkPlanTemplate.IsActive,
                WorkPlanTemplate.Type__c,
                WorkPlanTemplate.RelativeExecutionOrder,
                WorkPlanTemplate.Work_Plan_Default_Status__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS
        );
    }

    /**
     * @description To test query to get active WorkPlanTemplate records for given types.
     */
    @isTest
    private static void testWhenGivenWorkOrderTypesThenReturnWorkOrderTemplatesWithGivenType() {
        List<WorkPlanTemplate> workPlanTemplatesResult = WorkPlanTemplatesSelector.newInstance()
            .selectByType(new Set<String>{ WORK_ORDER_TYPE_COO });
        WorkPlanTemplatesSelector.newInstance();
        System.assertEquals(
            true,
            workPlanTemplatesResult != null,
            ASSERT_MESSAGE_NO_WORK_PLAN_TEMPLATE_RECORDS
        );
    }

    /**
     * @description To test query to get WorkPlanTemplates based on passed set of Ids.
     */
    @isTest
    private static void testWhenGivenWorkPlanTemplateIdThenReturnWorkPlanTemplates() {
        WorkPlanTemplate relatedWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME
        );
        insert relatedWorkPlanTemplate;
        WorkPlanTemplatesSelector workPlanTemplatesInstance = new WorkPlanTemplatesSelector();
        List<WorkPlanTemplate> workPlanTemplatesResult = workPlanTemplatesInstance.selectById(
            new Set<Id>{ relatedWorkPlanTemplate.Id }
        );
        WorkPlanTemplatesSelector.newInstance();
        System.assert(
            workPlanTemplatesResult != null,
            ASSERT_MESSAGE_NO_WORK_PLAN_TEMPLATE_RECORDS
        );
    }

    /**
     * @description To test query on WorkPlanTemplate by passed set of Ids
     * returns WorkPlanTemplates with WorkPlanTemplateEntries.
     */
    @isTest
    private static void testWhenSelectWorkPlanTemplatesWithWorkPlanTemplateEntriesIsCalledThenWPTWithWPTEReturned() {
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME
        );
        insert onboardingWorkPlanTemplate;
        WorkStepTemplate reviewTriageWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_STEP_TEMPLATE_NAME,
            IsActive = true
        );
        insert reviewTriageWorkStepTemplate;
        WorkPlanTemplateEntry newWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
            Active__c = true
        );
        insert newWorkPlanTemplateEntry;
        Test.startTest();
        List<WorkPlanTemplate> workPlanTemplatesResult = WorkPlanTemplatesSelector.newInstance()
            .selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                new Set<Id>{ onboardingWorkPlanTemplate.Id }
            );
        Test.stopTest();
        System.assertEquals(
            reviewTriageWorkStepTemplate.Name,
            workPlanTemplatesResult[0].WorkStepTemplates[0].WorkStepTemplate.Name,
            ASSERT_MESSAGE_NO_WPT_WITH_WPTE_RECORDS
        );
    }

    /**
     * @description LEM-5069 - Test query on WorkPlanTemplate in
     *              WorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries()
     * @author      Nathalie Mendezona
     * return      WorkPlanTemplates with WorkPlanTemplateEntries.
     */
    @isTest
    private static void testWhenSelectWorkPlanTemplatesWithWorkPlanTemplateEntriesIsCalledThenWPTwoInactiveWSTReturned() {
        WorkPlanTemplate posWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_POS
        );
        insert posWorkPlanTemplate;
        WorkStepTemplate configurePOSWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_STEP_TEMPLATE_CONFIGURE_POS,
            IsActive = true
        );
        insert configurePOSWorkStepTemplate;
        WorkPlanTemplateEntry activeWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = posWorkPlanTemplate.Id,
            WorkStepTemplateId = configurePOSWorkStepTemplate.Id,
            Active__c = true
        );
        WorkPlanTemplateEntry inactiveWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = posWorkPlanTemplate.Id,
            WorkStepTemplateId = configurePOSWorkStepTemplate.Id,
            Active__c = false
        );
        insert new List<WorkPlanTemplateEntry> {
            activeWorkPlanTemplateEntry,
            inactiveWorkPlanTemplateEntry
        };
        Test.startTest();
        List<WorkPlanTemplate> workPlanTemplatesResult = WorkPlanTemplatesSelector.newInstance()
            .selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                new Set<Id>{ posWorkPlanTemplate.Id }
            );
        Test.stopTest();
        System.assertEquals(
            1, workPlanTemplatesResult[0].WorkStepTemplates.size(),
            'There should only be a single WorkPlanTemplateEntry child record that is Active returned'
        );
    }
}