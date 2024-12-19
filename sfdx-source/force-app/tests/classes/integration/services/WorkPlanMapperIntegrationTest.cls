@isTest
private without sharing class WorkPlanMapperIntegrationTest {
    @TestSetup
    static void setupConfigurationData() {
        Map<String, RecordTypeInfo> rtNameToCriterionRTInfo = Schema.SObjectType.Criterion__c.getRecordTypeInfosByName();
        Work_Order_Template__c wot = new Work_Order_Template__c(
            Type__c = 'Marketplace',
            Name = 'Marketplace'
        );
        insert wot;
        List<WorkPlanTemplate> wpts = new List<WorkPlanTemplate>{
            new WorkPlanTemplate(Name = 'Onboarding', Type__c = 'Onboarding'),
            new WorkPlanTemplate(Name = 'Activations', Type__c = 'Activations')
        };
        insert wpts;
        List<Work_Order_Template_Entry__c> wotes = new List<Work_Order_Template_Entry__c>{
            new Work_Order_Template_Entry__c(
                Name = 'MP - Onboarding',
                Work_Plan_Template__c = wpts[0].Id,
                Work_Order_Template__c = wot.Id
            ),
            new Work_Order_Template_Entry__c(
                Name = 'MP - Activations',
                Work_Plan_Template__c = wpts[1].Id,
                Work_Order_Template__c = wot.Id
            )
        };
        insert wotes;
        List<Criterion__c> criteria = new List<Criterion__c>{
            new Criterion__c(
                Work_Order_Template_Entry__c = wotes[1].Id,
                RecordTypeId = rtNameToCriterionRTInfo.get('Criterion').getRecordTypeId(),
                Order_Number__c = 1,
                Field__c = 'Account.Industry',
                Value__c = 'Agriculture',
                Comparator__c = 'EQUALS'
            ),
            new Criterion__c(
                Work_Order_Template_Entry__c = wotes[1].Id,
                RecordTypeId = rtNameToCriterionRTInfo.get('Criterion').getRecordTypeId(),
                Order_Number__c = 2,
                Field__c = 'Account.BillingCountry',
                Value__c = 'United States, Canada',
                Comparator__c = 'FIELD_IN_VALUE_ENTRIES'
            ),
            new Criterion__c(
                Work_Order_Template_Entry__c = wotes[1].Id,
                RecordTypeId = rtNameToCriterionRTInfo.get('Logic').getRecordTypeId(),
                Criterion_Name__c = '1 OR 2'
            )
        };
        insert criteria;
    }

    @isTest
    static void testWhenMarketplaceThenReturnApplicableMarketplacePlanTypes() {
        Map<String, RecordTypeInfo> rtNameToAccountRTInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Account acc = new Account(
            RecordTypeId = rtNameToAccountRTInfo.get('Business').getRecordTypeId(),
            Corporate_Owned_Store_Count__c = 1,
            Name = 'WorkPlanMapperIntegrationTest',
            BillingCountry = 'United States',
            BillingStreet = 'main street',
            BillingCity = 'Any City',
            BillingState = 'California',
            BillingPostalCode = '94223',
            Segment__c = 'Enterprise'
        );
        insert acc;
        WorkOrder wo = new WorkOrder(
            AccountId = acc.Id,
            Type__c = 'Marketplace',
            Order_Protocol__c = 'Email',
            Menu_to_be_Completed_By__c = 'None - Menu Setup Complete',
            Activated_Centrally_AC__c = 'No',
            Proposed_Date_of_Activation__c = Date.today().addDays(30)
        );
        insert wo;
        Map<Id, Set<String>> woIdToMappedPlanTypes = WorkPlanMapper.getMappedWorkPlanTypes(
            new List<String>{ wo.Id }
        );
        System.assertEquals(
            true,
            woIdToMappedPlanTypes.get(wo.Id).contains('Onboarding'),
            String.format(
                'Expect templatization framework to return [[{0}]]; Actual: [[{1}]]',
                new List<Object>{
                    new Set<String>{ 'Onboarding', 'Activations' },
                    woIdToMappedPlanTypes.get(wo.Id)
                }
            )
        );
    }
}