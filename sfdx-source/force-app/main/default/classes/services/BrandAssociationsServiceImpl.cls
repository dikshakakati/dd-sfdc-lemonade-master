/**
 * @author Deloitte
 * @date 14/10/2022
 * @description Service implementation class for Brand Association related logic.
 */
public inherited sharing class BrandAssociationsServiceImpl implements IBrandAssociationsService {
    private static final String FRANCHISEE = 'Franchisee';
    private static final String HYPHEN_SEPARATOR = '-';
    private static final String LICENSOR = 'Licensor';
    private static final String LICENSEE = 'Licensee';
    private static final String LOG_SERVICE = 'Brand Association Service';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';

    /**
     * @description It is used to create Brand Associations on parent Accounts based on the
     * brand value populated on store Accounts.
     * @param storesAccountsWithBrands
     */
    public void associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
        List<Account> storesAccountsWithBrands
    ) {
        if (storesAccountsWithBrands.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();

        Set<String> brandToBusinessAccount = getBrandByBusinessAccountMappings(
            storesAccountsWithBrands
        );
        Set<Brand_Association__c> brandAssociationsToInsert = new Set<Brand_Association__c>();
        for (Account eachStoreAccount : storesAccountsWithBrands) {
            if (eachStoreAccount.Brand__c == null) {
                continue;
            }
            brandAssociationsToInsert.add(
                createBrandAssociationByParentId(eachStoreAccount, brandToBusinessAccount)
            );
            if (eachStoreAccount.Franchise_Parent__c != null) {
                brandAssociationsToInsert.add(
                    createBrandAssociationByFranchiseAccountId(
                        eachStoreAccount,
                        brandToBusinessAccount
                    )
                );
            }
        }
        brandAssociationsToInsert.remove(null);
        unitOfWorkInstance.registerNew(new List<Brand_Association__c>(brandAssociationsToInsert));
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception associateBrandsOnParentAccountsByBrandValueOnStoreAccountsException) {
            Logger.publish(LogEntry.newExceptionLog(associateBrandsOnParentAccountsByBrandValueOnStoreAccountsException,LogEntry.SeverityLevel.HIGH ));

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.HIGH
                ).logException (
                    associateBrandsOnParentAccountsByBrandValueOnStoreAccountsException
                )
            );
        }
    }
    /**
     * @description It is used to create Brand Associations on SMB Accounts.
     * @JIRA# 13833
     * @param brands
     */
    public static void createBrandAssociationsForSMBBusinessAccounts(List<Brand__c> brands) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        List<Brand_Association__c> newBrandAssociations = new List<Brand_Association__c>();
        if (brands == null) {
            return;
        }
        for (Brand__c eachBrand : brands) {
            newBrandAssociations.add(
                new Brand_Association__c(
                    Brand_Name__c = eachBrand.Id,
                    Business_Account_Name__c = eachBrand.Brand_Owner__c,
                    Relationship_Type__c = LICENSOR
                )
            );
        }

        unitOfWorkInstance.registerNew(newBrandAssociations);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception createBrandAssociationsForSMBBusinessAccounts) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(createBrandAssociationsForSMBBusinessAccounts)
            );
        }
    }

    /**
     * @description It is used to create a brand association record with corporate account.
     * @param storeAccount
     * @param brandToBusinessAccount
     * @return Brand_Association__c
     */
    private Brand_Association__c createBrandAssociationByParentId(
        Account storeAccount,
        Set<String> brandToBusinessAccount
    ) {
        Brand_Association__c corporateBrandAssociation;
        if (
            !brandToBusinessAccount.contains(
                storeAccount.Brand__c +
                HYPHEN_SEPARATOR +
                storeAccount.ParentId
            )
        ) {
            corporateBrandAssociation = new Brand_Association__c(
                Brand_Name__c = storeAccount.Brand__c,
                Business_Account_Name__c = storeAccount.ParentId
            );
        }
        return corporateBrandAssociation;
    }

    /**
     * @description It is used to create a brand association record with franchise account.
     * @param storeAccount
     * @param brandToBusinessAccount
     * @return Brand_Association__c
     */
    private Brand_Association__c createBrandAssociationByFranchiseAccountId(
        Account storeAccount,
        Set<String> brandToBusinessAccount
    ) {
        Brand_Association__c franchiseBrandAssociation;
        if (
            !brandToBusinessAccount.contains(
                storeAccount.Brand__c +
                HYPHEN_SEPARATOR +
                storeAccount.Franchise_Parent__c
            )
        ) {
            franchiseBrandAssociation = new Brand_Association__c(
                Brand_Name__c = storeAccount.Brand__c,
                Business_Account_Name__c = storeAccount.Franchise_Parent__c
            );
        }
        return franchiseBrandAssociation;
    }

    /**
     * @description It is used to create a unique mapping for Brand Ids and Business Account Ids.
     * @param storeAccounts
     * @return Set<String>
     */
    private Set<String> getBrandByBusinessAccountMappings(List<Account> storeAccounts) {
        Set<Id> brandIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Set<String> brandToBusinessAccount = new Set<String>();
        for (Account eachAccount : storeAccounts) {
            brandIds.add(eachAccount.Brand__c);
            parentIds.add(eachAccount.ParentId);
            if (eachAccount.Franchise_Parent__c != null) {
                parentIds.add(eachAccount.Franchise_Parent__c);
            }
        }
        for (
            Brand_Association__c eachBrandAssociation : BrandAssociationsSelector.newInstance()
                .selectByBrandsAndBusinessAccountIds(brandIds, parentIds)
        ) {
            brandToBusinessAccount.add(
                eachBrandAssociation.Brand_Name__c +
                HYPHEN_SEPARATOR +
                eachBrandAssociation.Business_Account_Name__c
            );
        }
        return brandToBusinessAccount;
    }



    /**
    * @description
    * @author Samiksha | 05-20-2024
    * @param brandIds
    * @return List<Brand_Association__c>
    **/
    public static List<Brand_Association__c> createBrandAssociations(Set<Id> brandIds){
        List<Brand__c> brands = BrandsSelector.newInstance().selectBrandsByIdWithParentIds(brandIds);

        List<Brand_Association__c> brandAssociations = new List<Brand_Association__c>();
        for(Brand__c brand : brands) {
            if (brand.Brand_Owner__c != null) {
                brandAssociations.add(new Brand_Association__c(Brand_Name__c = brand.Id, Business_Account_Name__c = brand.Brand_Owner__c));
            }
            if (brand.Brand_Owner__r.ParentId != null) {
                brandAssociations.add(new Brand_Association__c(Brand_Name__c = brand.Id, Business_Account_Name__c = brand.Brand_Owner__r.ParentId));
            }
            if (brand.Brand_Owner__r.Parent.ParentId != null) {
                brandAssociations.add(new Brand_Association__c(Brand_Name__c = brand.Id, Business_Account_Name__c = brand.Brand_Owner__r.Parent.ParentId));
            }
            if (brand.Brand_Owner__r.Parent.Parent.ParentId != null) {
                brandAssociations.add(new Brand_Association__c(Brand_Name__c = brand.Id, Business_Account_Name__c = brand.Brand_Owner__r.Parent.Parent.ParentId));
            }
            if (brand.Brand_Owner__r.Parent.Parent.Parent.ParentId != null) {
                brandAssociations.add(new Brand_Association__c(Brand_Name__c = brand.Id, Business_Account_Name__c = brand.Brand_Owner__r.Parent.Parent.Parent.ParentId));
            }
        }

        try {

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(brandAssociations);
            uow.commitWork();
            return brandAssociations;

        } catch (Exception createBrandAssociationsException) { //ask exception definiton

            String serviceName = 'Brand And BizRef Automation - createBrandAssociations';
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(serviceName,LOG_DOMAIN_SALES_TO_CONTRACT,GenericLogEntry.SeverityLevel.MEDIUM).logException (createBrandAssociationsException));

        }
        return NULL;
    }
}