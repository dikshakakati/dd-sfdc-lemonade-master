/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Domain Class for Brand Object
 */
public inherited sharing class Brands extends fflib_SObjects implements IBrands {
    static final String ACCOUNT_RECORD_TYPE_NAME = 'Business';
    static final String ACCOUNT_SEGMENT = 'SMB';
    static final String LICENSOR = 'Licensor';
    static final String LOG_DOMAIN = 'Brands';
    static final String DEFAULT_PRICE_RANGE = '$$';
    static final String LOG_CREATE_BRANDS_FOR_SMB_ACCOUNTS = 'Create Brands for SMB Accounts';
    private static final string TRIGGER_CONTEXT_AFTER = 'After';
    /**
     * @description This method is to return the IBrands interface
     * @param recordList - Brands record list
     * @return IBrands - Returns IBrands Interface
     */
    public static IBrands newInstance(List<Brand__c> recordList) {
        return (IBrands) Application.Domain.newInstance(recordList);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     */
    public Brands(List<Brand__c> sObjectList) {
        super(sObjectList, Schema.Brand__c.SObjectType);
    }

    /**
     * @description It updates Mastered In Figment on Business Reference when Brand Owner is updated on Brand.
     */
    public void initiateUpdateOnBusinessReferenceOnBrandOwnerChange() {
        Set<Id> accountsIds = new Set<Id>();
        for (Brand__c eachBrand : (List<Brand__c>) getRecords()) {
            accountsIds.add(eachBrand.Brand_Owner__c);
        }

        BusinessReferences.newInstance(
                BusinessReferencesSelector.newInstance().selectByBrandOwnerId(accountsIds)
            )
            .updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
    }

    /**
     * @description This method used to create brand Association records based on Brand owner.
     */
    public void createBrandAssociationsBasedOnBrandOwner() {
        Set<Id> brandOwnerIds = new Set<Id>();
        for (Brand__c brand : (List<Brand__c>) getRecords()) {
            if (brand.Source__c == null) {
                brandOwnerIds.add(brand.Brand_Owner__c);
            }
        }
        Map<Id, Set<Id>> brandOwnerIdWithParentIds = brandOwnerIdWithParentIds(brandOwnerIds);
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Brand__c brand : (List<Brand__c>) getRecords()) {
            if (
                brandOwnerIdWithParentIds.containsKey(brand.Brand_Owner__c) &&
                !brandOwnerIdWithParentIds.get(brand.Brand_Owner__c).isEmpty()
            ) {
                for (Id accountId : brandOwnerIdWithParentIds.get(brand.Brand_Owner__c)) {
                    Brand_Association__c brandAssociation = new Brand_Association__c();
                    brandAssociation.Brand_Name__c = brand.Id;
                    brandAssociation.Business_Account_Name__c = accountId;
                    brandAssociation.Relationship_Type__c = LICENSOR;
                    uow.registerNew(brandAssociation);
                }
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to create Brand and Brand Association records for SMB Accounts.
     * @JIRA# 13833
     * @param accountIdsFromConvertedLeads
     */
    public static void createBrandAndBrandAssociation(Set<Id> accountIdsFromConvertedLeads) {
        List<Account> smbAccounts = new List<Account>();
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectById(accountIdsFromConvertedLeads)
        ) {
            if (
                eachAccount.Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME &&
                eachAccount.Segment__c == ACCOUNT_SEGMENT
            ) {
                smbAccounts.add(eachAccount);
            }
        }
        createBrandsForSMBBusinessAccounts(smbAccounts);
    }

    /**
     * @description It is used to create Brand records for SMB Accounts.
     * @param smbAccounts
     */
    private static void createBrandsForSMBBusinessAccounts(List<Account> smbAccounts) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Brand__c> newBrands = new List<Brand__c>();
        if (smbAccounts == null) {
            return;
        }
        for (Account eachAccount : smbAccounts) {
            String priceRange = eachAccount.Price_Range__c != null
                ? eachAccount.Price_Range__c
                : DEFAULT_PRICE_RANGE;

            newBrands.add(
                new Brand__c(
                    Name = eachAccount.Name,
                    Brand_Owner__c = eachAccount.Id,
                    Price_Range__c = priceRange
                )
            );
        }
        uow.registerNew(newBrands);
        BrandAssociationsServiceImpl.createBrandAssociationsForSMBBusinessAccounts(newBrands);
        try {
            uow.commitWork();
        } catch (Exception createBrandsForSMBBusinessAccounts) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_CREATE_BRANDS_FOR_SMB_ACCOUNTS,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(createBrandsForSMBBusinessAccounts)
            );
        }
    }

    /**
     * @description This method used to remove old Brand Associations and create new Brand Associations based on Brand owner.
     * @param updatedBrands
     */
    public void removeOldBrandAssociations(List<Brand__c> updatedBrands) {
        Set<Id> brandIds = new Set<Id>();
        Set<Id> brandOwnerIds = new Set<Id>();

        Set<Id> brandIdsUpdateWithOwner = new Set<Id>();
        for (Brand__c brand : updatedBrands) {
            brandIdsUpdateWithOwner.add(brand.Id);
        }
        if (brandIdsUpdateWithOwner.isEmpty()) {
            return;
        }

        for (Brand__c brand : (List<Brand__c>) getRecords()) {
            if (brandIdsUpdateWithOwner.contains(brand.Id)) {
                brandOwnerIds.add(brand.Brand_Owner__c);
                brandIds.add(brand.Id);
            }
        }
        Map<String, Set<Id>> oldAssociationToIds = getOldBrandAssociationRecords(
            brandIds,
            brandOwnerIds
        );
        Map<Id, Set<Id>> brandOwnerIdWithParentIds = brandOwnerIdWithParentIds(brandOwnerIds);
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Brand__c brand : (List<Brand__c>) getRecords()) {
            if (brandIdsUpdateWithOwner.contains(brand.Id)) {
                prepareBrandAssociationsDeletion(
                    brandOwnerIdWithParentIds,
                    brand,
                    oldAssociationToIds,
                    uow
                );
            }
        }
        try {
            uow.commitWork();
            Brands.newInstance(updatedBrands).createBrandAssociationsBasedOnBrandOwner();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description To reduce the cyclomatic complexity used this method to prepare brand association needs to deleted.
     * @param brandOwnerIdWithParentIds
     * @param brand
     * @param oldAssociationToIds
     * @param uow
     */
    private static void prepareBrandAssociationsDeletion(
        Map<Id, Set<Id>> brandOwnerIdWithParentIds,
        Brand__c brand,
        Map<String, Set<Id>> oldAssociationToIds,
        fflib_ISobjectUnitOfWork uow
    ) {
        for (Id accountId : brandOwnerIdWithParentIds.get(brand.Brand_Owner__c)) {
            String mapKey = (String) brand.Id + (String) accountId;
            if (oldAssociationToIds.containsKey(mapKey)) {
                for (Id brandAssociationId : oldAssociationToIds.get(mapKey)) {
                    Brand_Association__c removeBrandAssociation = new Brand_Association__c(
                        Id = brandAssociationId
                    );
                    uow.registerDeleted(removeBrandAssociation);
                }
            }
        }
    }

    /**
     * @description This method used to query the existing Brand association records based on old Brand Owner
     * @param brandIds
     * @param brandOwnerIds
     * @return Map<String, Set<Id>>
     */
    private Map<String, Set<Id>> getOldBrandAssociationRecords(
        Set<Id> brandIds,
        Set<Id> brandOwnerIds
    ) {
        Map<String, Set<Id>> oldAssociationToIds = new Map<String, Set<Id>>();
        for (
            Brand_Association__c oldBrandAssociation : BrandAssociationsSelector.newInstance()
                .selectBrandAssociations(brandIds, brandOwnerIds)
        ) {
            String mapKey =
                (String) oldBrandAssociation.Brand_Name__c +
                (String) oldBrandAssociation.Business_Account_Name__c;
            if (oldAssociationToIds.containsKey(mapKey)) {
                oldAssociationToIds.get(mapKey).add(oldBrandAssociation.Id);
            } else {
                oldAssociationToIds.put(mapKey, new Set<Id>{ oldBrandAssociation.Id });
            }
        }
        return oldAssociationToIds;
    }

    /**
     * @description This method used to get Account Id of all parent accounts.
     * @param brandOwnerIds
     * @return Map<Id,Set<Id>>
     */
    private Map<Id, Set<Id>> brandOwnerIdWithParentIds(Set<Id> brandOwnerIds) {
        Map<Id, Set<Id>> brandOwnerIdWithParentIds = new Map<Id, Set<Id>>();
        for (
            Account account : AccountsSelector.newInstance()
                .selectAllAccountsWithParent(brandOwnerIds)
        ) {
            Set<Id> brandOwnerParentIds = new Set<Id>();
            brandOwnerParentIds.add(account.Id);
            if (account.ParentId != null) {
                brandOwnerParentIds.add(account.ParentId);
            }
            if (account.Parent.ParentId != null) {
                brandOwnerParentIds.add(account.Parent.ParentId);
            }
            if (account.Parent.Parent.ParentId != null) {
                brandOwnerParentIds.add(account.Parent.Parent.ParentId);
            }
            if (account.Parent.Parent.Parent.ParentId != null) {
                brandOwnerParentIds.add(account.Parent.Parent.Parent.ParentId);
            }
            brandOwnerIdWithParentIds.put(account.Id, brandOwnerParentIds);
        }
        return brandOwnerIdWithParentIds;
    }

    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description constructor menthod implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Brands - List of Brands
         */
        public fflib_SObjects construct(List<Object> objectList) {
            return new Brands((List<SObject>) objectList);
        }
    }
}