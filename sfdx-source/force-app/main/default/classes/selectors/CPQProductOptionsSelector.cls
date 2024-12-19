/**
 * @author Deloitte
 * @date 05/21/2024
 * @description Selector Class for CPQ Product Options
 */
public inherited sharing class CPQProductOptionsSelector extends fflib_SObjectSelector implements ICPQProductOptionsSelector {
    /**
     * @description Default Constructor for the Product Options Selector Class
     * @return ICPQProductOptionsSelector - Interface of ICPQProductOptionsSelector
     */
    public static ICPQProductOptionsSelector newInstance() {
        return (ICPQProductOptionsSelector) Application.Selector.newInstance(
            SBQQ__ProductOption__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Product Options Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SBQQ__ProductOption__c.Id,
            SBQQ__ProductOption__c.SBQQ__ConfiguredSKU__r.Name,
            SBQQ__ProductOption__c.SBQQ__OptionalSKU__r.Name
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__ProductOption__c.SObjectType;
    }

    /**
     * @description This method is used for getting Product Options based on Product Ids passed.
     * @param optionalSKUNames
     * @param configuredSKUNames
     * @return List<SBQQ__ProductOption__c>
     */
    public List<SBQQ__ProductOption__c> selectByProductNames(
        Set<String> optionalSKUNames,
        Set<String> configuredSKUNames
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('SBQQ__ConfiguredSKU__r.Name')
            .selectField('SBQQ__Feature__c')
            .selectField('SBQQ__OptionalSKU__r.Name')
            .selectField('SBQQ__OptionalSKU__r.Description')
            .setCondition(
                'SBQQ__OptionalSKU__r.Name IN :optionalSKUNames AND SBQQ__ConfiguredSKU__r.Name IN :configuredSKUNames'
            );
        return (List<SBQQ__ProductOption__c>) Database.query(query.toSOQL());
    }
}