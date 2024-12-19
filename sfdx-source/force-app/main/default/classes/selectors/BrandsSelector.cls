/**
 * @author Deloitte
 * @date 04/05/2022
 * @description Selector Class for Brand Object
 */
public inherited sharing class BrandsSelector extends fflib_SObjectSelector implements IBrandsSelector {
    /**
     * @description default constructor for the Brand Selector class
     * @return IBrandsSelector - interface of IBrandsSelector
     */
    public static IBrandsSelector newInstance() {
        return (IBrandsSelector) Application.Selector.newInstance(Brand__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Brand object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Brand__c.Id, Brand__c.Name, Brand__c.Price_Range__c };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Brand__c.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Brand__c>
     */
    public List<Brand__c> selectById(Set<Id> idSet) {
        return (List<Brand__c>) selectSObjectsById(idSet);
    }

    /**
     * @description It is used to validate Brand Names, whether they already exist in Database.
     * @JIRA# LEM-12957
     * @param brandNames
     * @return List<Brand__c>
     */
    public List<Brand__c> getBrandsByBrandName(List<String> brandNames) {
        fflib_QueryFactory brandQuery = newQueryFactory().setCondition('Name IN :brandNames ');
        return (List<Brand__c>) Database.query(brandQuery.toSOQL());
    }

    /**
     * @description Retrieves a list of Brand__c  with 5 levels of AccountIds records based on the provided set of brandIds.
     * @param brandIds A set of Brand__c record Ids.
     * @return A list of Brand__c records matching the provided brandIds.
     */
    public List<Brand__c> selectBrandsByIdWithParentIds(Set<Id> brandIds) {
        fflib_QueryFactory brandQuery = newQueryFactory()
            .setCondition('Id IN :brandIds')
            .selectField('Brand_Owner__c')
            .selectField('Brand_Owner__r.ParentId')
            .selectField('Brand_Owner__r.Parent.ParentId')
            .selectField('Brand_Owner__r.Parent.Parent.ParentId')
            .selectField('Brand_Owner__r.Parent.Parent.Parent.ParentId');
        return (List<Brand__c>) Database.query(brandQuery.toSOQL());
    }

    /**
     * @description It is used to get the brand records by the passed Unique Identifier.
     * @param uniqueIdentifiers
     * @return List<Brand__c>
     */
    public List<Brand__c> selectBrandsByUniqueIdentifiers(Set<String> uniqueIdentifiers) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Unique_Identifier__c')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers');
        return (List<Brand__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get the brand records by the passed AccountIds.
     * @param accountIds
     * @return List<Brand__c>
     */
    public List<Brand__c> selectBrandsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Brand_Owner__c')
            .selectField('Unique_Identifier__c')
            .setCondition('Brand_Owner__c IN :accountIds');
        return (List<Brand__c>) Database.query(query.toSOQL());
    }
}