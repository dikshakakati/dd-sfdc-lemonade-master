/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Selector class for Solutions object.
 */
public inherited sharing class SolutionsSelector extends fflib_SObjectSelector implements ISolutionsSelector {
    private static final String ACTIVE_STATUS = 'Active';
    static final List<String> VSP_SOLUTIONS_TYPES = new List<String>{
        'Growth',
        'Operational',
        'Tip'
    };

    /**
     * @description Default constructor for the class.
     * @return ISolutionsSelector
     */
    public static ISolutionsSelector newInstance() {
        return (ISolutionsSelector) Application.Selector.newInstance(
            Campaign_Product__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Campaign_Product__c.SObjectType;
    }

    /**
     * @description It is used to get the SObjectFields.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Campaign_Product__c.Id,
            Campaign_Product__c.VSP_Code__c,
            Campaign_Product__c.Type__c,
            Campaign_Product__c.Status__c,
            Campaign_Product__c.Rank__c,
            Campaign_Product__c.Points__c,
            Campaign_Product__c.Metric__c,
            Campaign_Product__c.Category__c,
            Campaign_Product__c.Name,
            Campaign_Product__c.Number_of_Stores__c,
            Campaign_Product__c.Product_Family__c,
            Campaign_Product__c.IncrementalSales__c
        };
    }

    /**
     * @description It is used to get the active Solutions by passed vsp codes.
     * @return List<Campaign_Product__c>
     */
    public List<Campaign_Product__c> selectActiveSolutionsByVSPCodes() {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Status__c = :ACTIVE_STATUS AND TYPE__C IN :VSP_SOLUTIONS_TYPES');
        return (List<Campaign_Product__c>) Database.query(query.toSOQL());
    }
}