/**
 * @author Deloitte
 * @description Interface to add Selector class methods
 */
public interface IBrandsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return Map<Id, Brand__c> - Map of Brands
     */
    List<Brand__c> selectById(Set<Id> idSet);

    /**
     * @description It is used to validate Brand Names, whether they already exist in Database.
     * @param brandNames
     * @return List<Brand__c>
     */
    List<Brand__c> getBrandsByBrandName(List<String> brandNames);

    /**
     * @description Retrieves a list of Brand__c  with 5 levels of AccountIds records based on the provided set of brandIds.
     * @param brandIds A set of Brand__c record Ids.
     * @return A list of Brand__c records matching the provided brandIds.
     */
    List<Brand__c> selectBrandsByIdWithParentIds(Set<Id> brandIds);

    /**
     * @description It is used to get the brand records by the passed uniqueIdentifiers.
     * @param uniqueIdentifiers
     * @return List<Brand__c>
     */
    List<Brand__c> selectBrandsByUniqueIdentifiers(Set<String> uniqueIdentifiers);

    /**
     * @description It is used to get the brand records by the passed AccountIds.
     * @param accountIds
     * @return List<Brand__c>
     */
    List<Brand__c> selectBrandsByAccountIds(Set<Id> accountIds);
}