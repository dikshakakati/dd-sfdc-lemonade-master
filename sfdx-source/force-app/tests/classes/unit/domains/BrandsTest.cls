/**
 * @author Deloitte
 * @date 05/06/2022
 * @description This is test class for Contacts class
 */
@isTest(seeAllData=false)
private class BrandsTest {
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String BUSINESS_ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String BUSINESS_ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String BUSINESS_ACCOUNT_TEST_NAME_DOMINOS = 'Dominos';
    private static final String BUSINESS_ACCOUNT_TEST_NAME_PIZZAHUT = 'PizzaHut';
    private static final String BRAND_NAME = 'KFC';
    private static final String ACCOUNT_NAME = 'ACCOUNT 1';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Pets';
    private static final String TRIGGER_CONTEXT_AFTER = 'After';

    /**
     * @description This is method used to test Brands class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Brand__c> brandList = new List<Brand__c>();
        //Default Constructor Call
        Brands brandObject = new Brands(brandList);
        //IContacts Instance Creation Call
        Brands.newInstance(brandList);
        System.assertNotEquals(
            Brands.newInstance(brandList),
            brandObject,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description When the owner of a brand is changed then update the Figment on Business Reference.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandOwnerIsUpdatedThenFigmentOnBizRefShouldBeUpdated() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setFakeId()
            .toSObject();
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Brand_Owner__c, account.Id)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setField(Business_Reference__c.Mastered_In_Figment__c, true)
            .setFakeId()
            .toSObject();
        List<Brand__c> relatedBrands = new List<Brand__c>{ brand };
        List<Business_Reference__c> bizRefs = new List<Business_Reference__c>{ businessReference };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessReferences businessReferencesMock = BusinessReferences.newInstance(
            new List<Business_Reference__c>{}
        );
        businessReferencesMock.updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectByBrandOwnerId(new Set<Id>{ account.Id }))
            .thenReturn(bizRefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Test.startTest();
        Brands.newInstance(relatedBrands).initiateUpdateOnBusinessReferenceOnBrandOwnerChange();
        Test.stopTest();
        ((IBusinessReferences) mocks.verify(businessReferencesMock, 1))
            .updateMasteredInFigment(TRIGGER_CONTEXT_AFTER);
    }

    /**
     * @description This test method checking createBrandAssociationsBasedOnBrandOwner method
     * this method create new brand associations when a brand inserted
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandRecordsCreatedThenCreateNewBrandAssociations() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1'
        );
        Account childAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            ParentId = parentAccount.Id
        );
        Brand__c[] newBrands = new List<Brand__c>{
            new Brand__c(
                Id = Fake.generateId(Brand__c.class),
                Brand_Owner__c = childAccount.Id,
                Name = 'New Brand'
            )
        };
        List<Account> accountList = new List<Account>{ childAccount, parentAccount };
        Set<Id> accountIds = new Set<Id>{ childAccount.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectAllAccountsWithParent(accountIds))
            .thenReturn(accountList);

        mocks.stopStubbing();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Brands.newInstance(newBrands).createBrandAssociationsBasedOnBrandOwner();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description This test method testing removeOldBrandAssociations.
     * This method delete old brand associations and it used to create new brand associations.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandRecordsUpdatedThenUpdateBrandAssociations() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 1'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 2'
            )
        };
        Brand__c[] oldBrands = new List<Brand__c>{
            new Brand__c(
                Id = Fake.generateId(Brand__c.class),
                Brand_Owner__c = newAccounts[0].Id,
                Name = 'New Brand'
            )
        };
        Brand__c[] newBrands = new List<Brand__c>{
            new Brand__c(
                Id = oldBrands[0].Id,
                Brand_Owner__c = newAccounts[1].Id,
                Name = 'New Brand'
            )
        };
        Brand_Association__c[] brandAssosiations = new List<Brand_Association__c>{
            new Brand_Association__c(
                Id = Fake.generateId(Brand_Association__c.class),
                Brand_Name__c = oldBrands[0].Id,
                Business_Account_Name__c = newAccounts[0].Id
            )
        };
        Set<Id> accountIds = new Set<Id>{ newAccounts[0].Id };
        Set<Id> brandIds = new Set<Id>{ oldBrands[0].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBrandAssociationsSelector brandsAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.selectAllAccountsWithParent(accountIds))
            .thenReturn(newAccounts);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(brandsAssociationsSelectorMock.selectBrandAssociations(brandIds, accountIds))
            .thenReturn(brandAssosiations);
        mocks.when(brandsAssociationsSelectorMock.sObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.stopStubbing();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(brandsAssociationsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Brands.newInstance(oldBrands).removeOldBrandAssociations(newBrands);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }
    /**
     * @description It is used to test creation of Brands when SMB Account is inserted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBBusinesAccountPassedThenCreateBrands() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_DOMINOS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .toSObject();
        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_PIZZAHUT)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .toSObject();
        Account[] newAccounts = new List<Account>{ account1, account2 };
        Set<Id> accountIds = new Set<Id>{ newAccounts[0].Id, newAccounts[1].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.selectById(accountIds)).thenReturn(newAccounts);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Brands.createBrandAndBrandAssociation(accountIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description It is used to test creation of Brands when Enterprise Account is inserted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEnterpriseBusinesAccountPassedThenBrandsNotCreated() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_DOMINOS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_ENTERPRISE)
            .setFakeId()
            .toSObject();
        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_PIZZAHUT)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_ENTERPRISE)
            .setFakeId()
            .toSObject();
        Account[] newAccounts = new List<Account>{ account1, account2 };
        Set<Id> accountIds = new Set<Id>{ newAccounts[0].Id, newAccounts[1].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.selectById(accountIds)).thenReturn(newAccounts);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Brands.createBrandAndBrandAssociation(accountIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerNew(fflib_Match.anySObject());
    }
}