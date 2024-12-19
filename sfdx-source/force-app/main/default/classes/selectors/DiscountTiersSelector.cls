/**
 * @author Deloitte
 * @date 07/28/2024
 * @description Selector Class for Discount Tier Object.
 */
public inherited sharing class DiscountTiersSelector extends fflib_SObjectSelector implements IDiscountTiersSelector {
    /**
     * @description Default Constructor for the Discount Tier Selector Class
     * @return IDiscountTierSelector - Interface of IDiscountTierSelector
     */
    public static IDiscountTiersSelector newInstance() {
        return (IDiscountTiersSelector) Application.Selector.newInstance(
            SBQQ__DiscountTier__c.SObjectType
        );
    }

    /**
     * @description It is for getting fields on Discount Tier Object.
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ SBQQ__DiscountTier__c.Id };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__DiscountTier__c.SObjectType;
    }
    /**
     * @description It is used for getting Disccount Tier based on passed unique identifiers.
     * @param uniqueIdentifiersForSSOB
     * @return List<SBQQ__DiscountTier__c>
     */
    public List<SBQQ__DiscountTier__c> selectByUUID(Set<String> uniqueIdentifiersForSSOB) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('SBQQ__Schedule__r.SBQQ__Product__c')
            .selectField('Unique_Identifier__c')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiersForSSOB');
        return (List<SBQQ__DiscountTier__c>) Database.query(query.toSOQL());
    }
}