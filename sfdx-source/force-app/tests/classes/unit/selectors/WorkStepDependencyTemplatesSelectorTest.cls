/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Test class for WorkStepDependencyTemplatesSelector class.
 */
@isTest
private class WorkStepDependencyTemplatesSelectorTest {
    private static final String ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE = 'Unexpected result: the object type must beWorkStepDependencyTemplate';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS = 'Unexpected result: there is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_NO_WORK_STEP_DEPENDENCY_RECORDS = 'Unexpected result: query returned no dependee WorkStep';
    private static final String WORK_PLAN_TEMPLATE_NAME_ONBOARDING = 'Onboarding';
    private static final String WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_TEMPLATE_NAME_REVIEW_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_TEMPLATE_NAME_SETUP_BANKING = 'SETUP_BANKING';

    /**
     * @description To test instantiation and return of correct sobjectType and sobject fields list.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkStepDependencyTemplatesSelector workStepDependencyTemplatesSelectorInstance = new WorkStepDependencyTemplatesSelector();
        Schema.SObjectType typeOfObject = workStepDependencyTemplatesSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workStepDependencyTemplatesSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.WorkStepDependencyTemplate__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_INCORRECT_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkStepDependencyTemplate__c.Id,
                WorkStepDependencyTemplate__c.Dependee_Work_Plan_Template_Entry__c,
                WorkStepDependencyTemplate__c.Dependent_Work_Plan_Template_Entry__c,
                WorkStepDependencyTemplate__c.Is_Active__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_SOBJECT_FIELDS
        );
    }

    /**
     * @description To test query on WorkPlanTemplate by passed set of Ids
     * returns WorkPlanTemplates with WorkPlanTemplateEntries.
     */
    @isTest
    private static void testWhenSelectDependeeWorkStepDependencyTemplatesIsCalledThenWorkStepDependencyTemplatesReturned() {
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_ONBOARDING
        );
        WorkPlanTemplate setupBankingWorkPlanTemplate = new WorkPlanTemplate(
            Name = WORK_PLAN_TEMPLATE_NAME_SETUP_BANKING
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
        WorkPlanTemplateEntry onboardingWorkPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
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
        WorkStepDependencyTemplate__c workStepDepenencyTemplate = new WorkStepDependencyTemplate__c(
            Dependee_Work_Plan_Template_Entry__c = onboardingWorkPlanTemplateEntry.Id,
            Dependent_Work_Plan_Template_Entry__c = setupBankingWorkPlanTemplateEntry.Id,
            Is_Active__c = true
        );
        insert workStepDepenencyTemplate;
        Test.startTest();
        List<WorkStepDependencyTemplate__c> workStepDependencyTemplatesResult = WorkStepDependencyTemplatesSelector.newInstance()
            .selectDependeeWorkStepDependencyTemplates(
                new Set<Id>{ setupBankingWorkPlanTemplateEntry.Id }
            );
        Test.stopTest();
        System.assertEquals(
            onboardingWorkPlanTemplateEntry.Id,
            workStepDependencyTemplatesResult[0].Dependee_Work_Plan_Template_Entry__c,
            ASSERT_MESSAGE_NO_WORK_STEP_DEPENDENCY_RECORDS
        );
    }
}