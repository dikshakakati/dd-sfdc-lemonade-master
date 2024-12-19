/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Test class for BrandAssociationsServiceImpl
 */
@isTest(SeeAllData=false)
private class BrandAssociationsServiceImplTest {
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
    private static final String ACCOUNT_NAME_MCDONALD = 'Mc Donald';
    private static final String BRAND_NAME_POP_TATES = 'Pop Tates';
    private static final String LICENSOR = 'Licensor';
    private static final String LICENSEE = 'Licensee';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();

    /**
     * @description To test new Brand Association record not created when a
     * Brand is associated with parent Account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandAssociationExistsOnParentAccountThenBrandNotAssociatedWithParentAccount() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Account> newAccounts = new List<Account>{
            new Account(
                Id = storeAccountId,
                Name = 'Mc Donnald',
                RecordTypeId = STORE_RECORD_TYPE_ID,
                ParentId = parentAccount.Id,
                Brand__c = brand.Id
            )
        };
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(
                Brand_Association__c.class
            )
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBrandAssociationsSelector brandAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(brandAssociationsSelectorMock.SObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                brandAssociationsSelectorMock.selectByBrandsAndBusinessAccountIds(
                    new Set<Id>{ brand.Id },
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<Brand_Association__c>{ brandAssociation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandAssociationsSelectorMock);
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            newAccounts
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test new Brand Association record is created when a Brand is
     * associated with parent Account of type Corporate.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandAssociationDoesNotExistsOnCorporateParentAccountThenLicensorTypeBrandAssociated() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop Tates')
            .setFakeId()
            .toSObject();
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Brand__c, brand.Id)
            .setField(Account.Parent_Type__c, ACCOUNT_TYPE_CORPORATE)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.Type, ACCOUNT_TYPE_CORPORATE)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector brandAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(brandAssociationsSelectorMock.SObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                brandAssociationsSelectorMock.selectByBrandsAndBusinessAccountIds(
                    new Set<Id>{ brand.Id },
                    new Set<Id>{ parentAccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandAssociationsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            new List<Account>{ newAccount }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(
                new List<Brand_Association__c>{
                    new Brand_Association__c(
                        Brand_Name__c = brand.Id,
                        Business_Account_Name__c = parentAccountId
                    )
                }
            );
    }

    /**
     * @description To test new Brand Association record is created when a Brand is
     * associated with parent Account of type Franchisee.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandAssociationDoesNotExistsOnCorporateParentAccountThenLicenseeTypeBrandAssociated() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setFakeId()
            .toSObject();
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Brand__c, brand.Id)
            .setField(Account.Parent_Type__c, ACCOUNT_TYPE_FRANCHISEE)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.Type, ACCOUNT_TYPE_FRANCHISEE)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector brandAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(brandAssociationsSelectorMock.SObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                brandAssociationsSelectorMock.selectByBrandsAndBusinessAccountIds(
                    new Set<Id>{ brand.Id },
                    new Set<Id>{ parentAccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandAssociationsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            new List<Account>{ newAccount }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(
                new List<Brand_Association__c>{
                    new Brand_Association__c(
                        Brand_Name__c = brand.Id,
                        Business_Account_Name__c = parentAccountId
                    )
                }
            );
    }

    /**
     * @description To test new Brand Association record is created when a brand is
     * associated with franchise account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandAssociationExistsOnFranchiseAccountThenLicenseeTypeBrandAssociated() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setFakeId()
            .toSObject();
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.Brand__c, brand.Id)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector brandAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(brandAssociationsSelectorMock.SObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                brandAssociationsSelectorMock.selectByBrandsAndBusinessAccountIds(
                    new Set<Id>{ brand.Id },
                    new Set<Id>{ parentAccountId, franchiseAccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandAssociationsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BrandAssociationsService.associateBrandsOnParentAccountsByBrandValueOnStoreAccounts(
            new List<Account>{ newAccount }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(
                new List<Brand_Association__c>{
                    new Brand_Association__c(
                        Brand_Name__c = brand.Id,
                        Business_Account_Name__c = parentAccountId
                    ),
                    new Brand_Association__c(
                        Brand_Name__c = brand.Id,
                        Business_Account_Name__c = franchiseAccountId
                    )
                }
            );
    }

    /**
     * @description To test new Brand Association record is created when a brand is
     * associated with franchise account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandIsCreatedThenBrandAssociationShouldbeCreated() {
        Id brandId = Fake.generateId(Brand__c.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, franchiseAccountId)
            .setField(Brand__c.Id, brandId)
            .toSObject();
        List<Brand__c> brands = new List<Brand__c>();
        brands.add(brand);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        BrandAssociationsServiceImpl.createBrandAssociationsForSMBBusinessAccounts(brands);

       ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }

    /**
     * @description To test new Brand Association record is created when a brand is
     * associated with franchise account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandIdIsPassedThenCreateBrandAssociation() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id brandId = Fake.generateId(Brand__c.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, storeAccountId)
            .setField(Brand__c.Id, brandId)
            .toSObject();

        List<Brand__c> brands = new List<Brand__c>();
        brands.add(brand);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandsSelector brandSelectorMock = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();

        mocks.when(brandSelectorMock.SObjectType())
            .thenReturn(Brand__c.SObjectType);
        mocks.when( brandSelectorMock.selectBrandsByIdWithParentIds(new Set<Id>{  brand.Id }))
            .thenReturn(new List<Brand__c>(brands));

        mocks.when(accountSelectorMock.SObjectType())
            .thenReturn(Account.SObjectType);
        mocks.when( accountSelectorMock.selectById(new Set<Id>{  newAccount.Id }))
            .thenReturn(new List<Account>{newAccount});

        mocks.stopStubbing();

        Application.SELECTOR.setMock(brandSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);

        Application.UNITOFWORK.setMock(mockUOW);
        BrandAssociationsService.createBrandAssociations(
            new Set<Id>{  brand.Id}
        );
       ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }
}