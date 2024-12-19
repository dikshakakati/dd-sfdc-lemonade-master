/**
 * @author Deloitte
 * @date 07/28/2024
 * @description Selector Class for Discount Schedule Object
 */
public inherited sharing class DiscountSchedulesSelector extends fflib_SObjectSelector implements IDiscountSchedulesSelector {
    /**
     * @description Default Constructor for the Discount Schedule Selector Class
     * @return IDiscountSchedulesSelector - Interface of DiscountSchedulesSelector
     */
    public static IDiscountSchedulesSelector newInstance() {
        return (IDiscountSchedulesSelector) Application.Selector.newInstance(
            SBQQ__DiscountSchedule__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Discount Schedule Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ SBQQ__DiscountSchedule__c.Id };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__DiscountSchedule__c.SObjectType;
    }

    /**
     * @description It is used for getting Disccount Schedule based on Product name.
     * @param optionProductNameWithProductDetails
     * @return List<SBQQ__DiscountSchedule__c>
     */
    public List<SBQQ__DiscountSchedule__c> selectByProductName(
        Set<String> optionProductNameWithProductDetails
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('SBQQ__Product__r.Name')
            .setCondition(
                'SBQQ__UserDefined__c = FALSE AND SBQQ__Product__r.Name IN :optionProductNameWithProductDetails'
            );
        return (List<SBQQ__DiscountSchedule__c>) Database.query(query.toSOQL());
    }
}