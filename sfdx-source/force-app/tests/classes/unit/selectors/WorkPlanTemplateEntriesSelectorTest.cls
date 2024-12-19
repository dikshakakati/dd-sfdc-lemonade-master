/**
 * @author Deloitte
 * @date 13/04/2022
 * @description Test class for WorkPlanTemplateEntriesSelector class.
 */
@isTest(seeAllData=false)
private class WorkPlanTemplateEntriesSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Work Plan Template Entry';
    private static final String ASSERT_MESSAGE_WORK_PLAN_TEMPLATE_ENTRIES_DO_NOT_EXIST = 'Unexpected result: The list does not contain any Work Plan Template Entries';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WORK_PLAN_NAME = 'Storefront';
    private static final String WORK_PLAN_NAME_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_PLAN_TEMPLATE_NAME = 'Onboarding';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_MENU_ERROR_TYPE = 'Formatting';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkPlanTemplateEntriesSelector workPlanTemplateEntriesInstance = new WorkPlanTemplateEntriesSelector();
        Schema.SObjectType typeOfObject = workPlanTemplateEntriesInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workPlanTemplateEntriesInstance.getSObjectFieldList();
        WorkPlanTemplateEntriesSelector.newInstance();
        System.assertEquals(
            Schema.WorkPlanTemplateEntry.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkPlanTemplateEntry.Id,
                WorkPlanTemplateEntry.Active__c,
                WorkPlanTemplateEntry.WorkPlanTemplateEntryNumber,
                WorkPlanTemplateEntry.ExecutionOrder,
                WorkPlanTemplateEntry.WorkPlanTemplateId,
                WorkPlanTemplateEntry.WorkStepTemplateId,
                WorkPlanTemplateEntry.Work_Step_Default_Status__c,
                WorkPlanTemplateEntry.Work_Step_Sequence__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
}