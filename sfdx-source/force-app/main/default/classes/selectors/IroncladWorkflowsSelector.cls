/**
 * @author Deloitte
 * @date 05/28/2024
 * @description Selector Class for Ironclad Workflows object.
 */
public inherited sharing class IroncladWorkflowsSelector extends fflib_SObjectSelector implements IIroncladWorkflowsSelector {
    private static final String OUT_FOR_SIGNATURE = 'Out for Signature';

    /**
     * @description Default Constructor for the IroncladWorkflowsSelector class.
     * @return IIroncladWorkflowsSelector - Interface of IroncladWorkflows
     */
    public static IIroncladWorkflowsSelector newInstance() {
        return (IIroncladWorkflowsSelector) Application.Selector.newInstance(
            ironclad__Ironclad_Workflow__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on IronClad object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ ironclad__Ironclad_Workflow__c.Quote__c };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ironclad__Ironclad_Workflow__c.SObjectType;
    }

    /**
     * @description It is used to fetch Quote fields from Ironclad Workflow record based on the passed
     * Opportunity Ids where Quote is 'Primary' and Quote's Status is 'Out for Signature'.
     * @param opportunityIds
     * @JIRA LEM-15269
     * @return List<ironclad__Ironclad_Workflow__c>
     */
    public List<ironclad__Ironclad_Workflow__c> selectIroncladWorkflowsWithOutForSignaturePrimaryQuotesByOpportunityIds(
        Set<Id> opportunityIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('ironclad__Workflow_Status__c')
            .selectField('Quote__c')
            .selectField('Quote__r.SBQQ__Status__c')
            .selectField('Quote__r.SBQQ__Opportunity2__c')
            .selectField('Quote__r.SBQQ__Primary__c')
            .setCondition(
                'Quote__r.SBQQ__Opportunity2__c IN : opportunityIds AND ' +
                    'Quote__r.SBQQ__Primary__c = true AND ' +
                    'Quote__r.SBQQ__Status__c = :OUT_FOR_SIGNATURE'
            );
        return (List<ironclad__Ironclad_Workflow__c>) Database.query(query.toSOQL());
    }
}