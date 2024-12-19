/**
 * @author Deloitte
 * @date 14/10/2022
 * @description Interface of service class for Brand Association related logic.
 */
public interface IBrandAssociationsService {
    /**
     * @description  It is used to create Brand Associations on parent Accounts based on the
     * brand value populated on store Accounts.
     * @param storesAccountsWithBrands
     */
    void associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
        List<Account> storesAccountsWithBrands
    );

    /**
     * @description It is used to create Brand Associations on SMB Accounts.
     * @JIRA# 13833
     * @param brands
     */
    void createBrandAssociationsForSMBBusinessAccounts(List<Brand__c> brands);

    /**
     * @description
     * @author Samiksha | 05-20-2024
     * @param brandIds
     * @param ;
     * @return List<Brand_Association__c>
     **/
    List<Brand_Association__c> createBrandAssociations(Set<Id> brandIds);
}