/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Interface to add Selector class methods.
 */
public interface IBrandAssociationsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting BA based on ID
     * @param brandIds
     * @param businessIds
     * @return List<Brand_Association__c>
     */
    List<Brand_Association__c> selectBrandAssociations(
        Set<Id> brandIds,
        Set<Id> businessIds
    );

    /**
     * @description It is used to get Brand Associations by Brands and Business Account Ids.
     * @param brands
     * @param businessAccountIds
     * @return List<Brand_Association__c>
     */
    List<Brand_Association__c> selectByBrandsAndBusinessAccountIds(
        Set<Id> brands,
        Set<Id> businessAccountIds
    );

    /**
     * @description It is used to get Brand Associations by AccountId and ignores those brands having MDS business references.
     * @param accountId
     * @return List<Brand_Association__c>
     */
    List<Brand_Association__c> selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(
        Id accountId
    );

    /**
     * @description  It is used to get Brand Associations by Business Account Ids.
     * @param businessAccountIds
     * @return List<Brand_Association__c>
     */
    List<Brand_Association__c> selectByBusinessAccountIds(Set<Id> businessAccountIds);

    /**
     * @description It is used for getting number of Brand Associations
     * grouped by Brand Name values using passed set of business Account Ids.
     * @param businessAccountIds
     * @return Aggregate[]
     */
    Aggregate[] getBrandAssociationsCountFilteredByBusinessAccountIdsGroupedByBrandName(
        Set<Id> businessAccountIds
    );

    /**
     * @description This method is used for getting BrandAssoication by unique identifiers.
     * @param uniqueIdentifiers
     * @return List<Brand_Association__c>
     */
    List<Brand_Association__c> selectBrandAssociationsByUniqueIdentifiers(
        Set<String> uniqueIdentifiers
    );
}