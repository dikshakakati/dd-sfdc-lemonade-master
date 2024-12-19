/**
 * @author Deloitte
 * @date 14/10/2022
 * @description Service class for Brand Association related logic.
 */
public inherited sharing class BrandAssociationsService {
    /**
     * @description It is used to create Brand Associations on parent Accounts based on the
     * brand value populated on store Accounts.
     * @JIRA# LEM-3211
     * @param storeAccounts
     */
    public static void associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
        List<Account> storeAccounts
    ) {
        service().associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(storeAccounts);
    }


    /**
     * @description Creates brand associations.
     * @param brandIds brand IDs.
     * @return A list of Brand_Association__c records representing the created brand associations.
     */
    public static List<Brand_Association__c> createBrandAssociations(Set<Id> brandIds){
        return service().createBrandAssociations(brandIds);
    }

    /**
     * @description This method is used to create an instance of BrandAssociationsService class.
     * @return IBrandAssociationsService - return instance of BrandAssociationsServiceImpl
     */
    private static IBrandAssociationsService service() {
        return (IBrandAssociationsService) Application.Service.newInstance(
            IBrandAssociationsService.class
        );
    }
}