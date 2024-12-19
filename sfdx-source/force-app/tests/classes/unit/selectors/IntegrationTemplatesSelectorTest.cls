/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Test class for WorkOrdersSelector class.
 */
@isTest(SeeAllData=false)
private class IntegrationTemplatesSelectorTest {
    private static final String COMPARATOR_EQUALS = 'EQUALS';
    private static final String CRITERIA_NAME_OPPORTUNITY_STAGE_CLOSED_WON = 'Opportunity Stage Closed Won';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION = 'Criterion';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String INTEGRATION_TEMPLATE_NAME = 'Opportunity_Closed_Won';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Integration Template.';
    private static final String OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The Integration Template is not returned.';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGENAME_FIELD_API_NAME = 'StageName';
    private static final String REFERENCE_TYPE_FIELD_API_NAME = 'Field API Name';
    private static final String SOBJECT_NAME_FIELD = 'Name';
    private static final String SOBJECT_TYPE_INTEGRATION_TEMPLATE = 'Integration_Template__c';
    private static final String SOBJECT_TYPE_OPPORTUNITY = 'Opportunity';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        IntegrationTemplatesSelector integrationTemplatesSelectorInstance = new IntegrationTemplatesSelector();
        Schema.SObjectType typeOfObject = integrationTemplatesSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = integrationTemplatesSelectorInstance.getSObjectFieldList();
        IntegrationTemplatesSelector.newInstance();
        System.assertEquals(
            Schema.Integration_Template__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Integration_Template__c.Id,
                Integration_Template__c.Immediate_Communication__c,
                Integration_Template__c.Is_Active__c,
                Integration_Template__c.Name,
                Integration_Template__c.SObject_Type__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test active Integration Template records are returned
     * filtered by Integration Template Ids.
     */
    @isTest
    private static void testWhenIntegrationTemplateIdsArePassedThenReturnIntegrationTemplates() {
        Integration_Template__c newIntegrationTemplate = new Integration_Template__c(
            Immediate_Communication__c = true,
            Is_Active__c = true,
            Name = INTEGRATION_TEMPLATE_NAME,
            SObject_Type__c = SOBJECT_TYPE_OPPORTUNITY
        );
        insert newIntegrationTemplate;
        List<Integration_Template__c> queryResult = IntegrationTemplatesSelector.newInstance()
            .selectByIds(new Set<Id>{ newIntegrationTemplate.Id });
        System.assertEquals(
            newIntegrationTemplate.Id,
            queryResult[0].Id,
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test active Integration Template records are returned
     * filtered by sObject Types.
     */
    @isTest
    private static void testWhenSObjectTypesArePassedThenReturnIntegrationTemplates() {
        Id criterionRecordTypeId = Schema.SObjectType.Criterion__c.getRecordTypeInfosByDeveloperName()
            .get(CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION)
            .getRecordTypeId();
        Integration_Template__c newIntegrationTemplate = new Integration_Template__c(
            Immediate_Communication__c = true,
            Is_Active__c = true,
            Name = INTEGRATION_TEMPLATE_NAME,
            SObject_Type__c = SOBJECT_TYPE_OPPORTUNITY
        );
        insert newIntegrationTemplate;
        Criterion__c newCriteria = new Criterion__c(
            Comparator__c = COMPARATOR_EQUALS,
            Field__c = OPPORTUNITY_STAGENAME_FIELD_API_NAME,
            Field_Reference_Type__c = REFERENCE_TYPE_FIELD_API_NAME,
            Integration_Template__c = newIntegrationTemplate.Id,
            Name = CRITERIA_NAME_OPPORTUNITY_STAGE_CLOSED_WON,
            Order_Number__c = 1,
            RecordTypeId = criterionRecordTypeId,
            Value__c = OPPORTUNITY_STAGE_CLOSED_WON
        );
        insert newCriteria;
        List<Integration_Template__c> queryResult = IntegrationTemplatesSelector.newInstance()
            .selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
                new Set<String>{ SOBJECT_TYPE_OPPORTUNITY }
            );
        System.assertEquals(
            newIntegrationTemplate.Id,
            queryResult[0].Id,
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newCriteria.Id,
            queryResult[0].Criteria__r[0].Id,
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test SObject details are retrieved
     * based on passed SObject Type, fields list and Ids.
     */
    @isTest
    private static void testWhenSObjectTypesPassedWithFieldsAndIdsThenReturnSObjectDetails() {
        Integration_Template__c newIntegrationTemplate = new Integration_Template__c(
            Immediate_Communication__c = true,
            Is_Active__c = true,
            Name = INTEGRATION_TEMPLATE_NAME,
            SObject_Type__c = SOBJECT_TYPE_OPPORTUNITY
        );
        insert newIntegrationTemplate;
        List<SObject> queryResult = IntegrationTemplatesSelector.newInstance()
            .selectSObjectDetailsWithPassedFieldsByIds(
                new Set<String>{ SOBJECT_NAME_FIELD },
                new Set<Id>{ newIntegrationTemplate.Id },
                SOBJECT_TYPE_INTEGRATION_TEMPLATE
            );
        System.assertEquals(
            newIntegrationTemplate.Name,
            queryResult[0].get(SOBJECT_NAME_FIELD),
            OBJECT_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}