/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Selector class for Integration Template object.
 */
public inherited sharing class IntegrationTemplatesSelector extends fflib_SObjectSelector implements IIntegrationTemplatesSelector {
    private static final String COMMA_SEPARATOR = ',';
    private static final String FROM_CLAUSE = ' FROM ';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION = 'Criterion';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_LOGIC = 'Logic';
    private static final String CRITERION_RECORD_TYPE_DEVELOPERNAME_MERGE_FIELD = 'Merge_Field_Mapping';
    private static final List<String> CRITERION_RECORD_TYPES = new List<String>{
        CRITERION_RECORD_TYPE_DEVELOPERNAME_CRITERION,
        CRITERION_RECORD_TYPE_DEVELOPERNAME_LOGIC,
        CRITERION_RECORD_TYPE_DEVELOPERNAME_MERGE_FIELD
    };
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' WHERE Id In :recordIds';

    /**
     * @description Default constructor for the class.
     * @return IIntegrationTemplatesSelector
     */
    public static IIntegrationTemplatesSelector newInstance() {
        return (IIntegrationTemplatesSelector) Application.Selector.newInstance(
            Integration_Template__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Integration_Template__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Integration Template.
     * @JIRA# LEM-13778
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Integration_Template__c.Id,
            Integration_Template__c.Immediate_Communication__c,
            Integration_Template__c.Is_Active__c,
            Integration_Template__c.Name,
            Integration_Template__c.SObject_Type__c
        };
    }

    /**
     * @description It returns Integration templates based on passed Ids.
     * @JIRA# LEM-13778
     * @param integrationTemplateIds
     * @return List<Integration_Template__c>
     */
    public List<Integration_Template__c> selectByIds(Set<Id> integrationTemplateIds) {
        fflib_QueryFactory integrationTemplateQuery = newQueryFactory(true)
            .setCondition('Id IN :integrationTemplateIds AND Is_Active__c = true');
        return (List<Integration_Template__c>) Database.query(integrationTemplateQuery.toSOQL());
    }

    /**
     * @description It returns Integration templates with child Criteria records of Record Type - Criteria, Logic, Action
     * based on the passed SObject types.
     * @JIRA# LEM-13778
     * @param sObjectTypes
     * @return List<Integration_Template__c>
     */
    public List<Integration_Template__c> selectIntegrationTemplatesAndChildCriteriaBasedOnSObjectType(
        Set<String> sObjectTypes
    ) {
        fflib_QueryFactory integrationTemplateQuery = newQueryFactory()
            .selectField('Id')
            .selectField('Immediate_Communication__c')
            .selectField('Is_Active__c')
            .selectField('Name')
            .selectField('SObject_Type__c')
            .setCondition('SObject_Type__c IN :sObjectTypes AND Is_Active__c = true');
        new CriteriaSelector()
            .addQueryFactorySubselect(integrationTemplateQuery, 'Criteria__r')
            .selectField('Comparator__c')
            .selectField('Criterion_Name__c')
            .selectField('Field__c')
            .selectField('Field_Reference_Type__c')
            .selectField('Integration_Template__c')
            .selectField('Name')
            .selectField('Order_Number__c')
            .selectField('RecordTypeId')
            .selectField('RecordType.Name')
            .selectField('Service_Method_Name__c')
            .selectField('Value__c')
            .setCondition('RecordType.DeveloperName IN :CRITERION_RECORD_TYPES');
        return (List<Integration_Template__c>) Database.query(integrationTemplateQuery.toSOQL());
    }

    /**
     * @description It returns SObject details based on passed fields and record Id.
     * @JIRA LEM-13778
     * @param fields
     * @param recordIds
     * @param sObjectType
     * @return List<SObject>
     */
    public List<SObject> selectSObjectDetailsWithPassedFieldsByIds(
        Set<String> fields,
        Set<Id> recordIds,
        String sObjectType
    ) {
        String sObjectQuery =
            SELECT_CLAUSE +
            String.join(fields, COMMA_SEPARATOR) +
            FROM_CLAUSE +
            sObjectType +
            WHERE_CLAUSE;
        return (List<SObject>) Database.query(String.escapeSingleQuotes(sObjectQuery));
    }
}