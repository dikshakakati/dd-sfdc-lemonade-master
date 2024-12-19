/**
 * @author Deloitte
 * @date 05/05/2022
 * @description This is test class for Brands Trigger Handler class
 */
@isTest
private class BrandsHandlerTest {
    /**
     * @description This method is used to test Brands TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Brand__c> brands = new List<Brand__c>();
        BrandsHandler brandHandlerObject = new BrandsHandler(brands);
        BrandsHandler.Constructor objConstructor = new BrandsHandler.Constructor();
        objConstructor.construct(brands);
        System.assertNotEquals(
            brandHandlerObject,
            objConstructor.construct(brands),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on brand update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandUpdatedThenCall() {
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
                Name = 'Test Account 1'
            )
        };

        Id brandId1 = Fake.generateId(Brand__c.class);
        Brand__c[] newBrands = new List<Brand__c>{
            new Brand__c(Id = brandId1, Name = 'Test 1', Brand_Owner__c = newAccounts[0].Id)
        };

        Brand__c[] oldBrands = new List<Brand__c>{
            new Brand__c(Id = brandId1, Name = 'Test 1', Brand_Owner__c = newAccounts[1].Id)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrands brandsMock = (IBrands) mocks.mock(IBrands.class);
        mocks.startStubbing();
        mocks.when(brandsMock.getType()).thenReturn(Schema.Brand__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(brandsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newBrands, new Map<Id, Brand__c>(oldBrands));
        fflib_SObjectDomain.triggerHandler(BrandsHandler.class);

        ((IBrands) mocks.verify(brandsMock, 1)).removeOldBrandAssociations(newBrands);
    }

    /**
     * @description To test method call on brand insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBrandInsertedThenCall() {
        Brand__c[] newBrands = new List<Brand__c>{
            new Brand__c(
                Id = fflib_IDGenerator.generate(Brand__c.SObjectType),
                Name = 'Test 1',
                Brand_Owner__c = fflib_IDGenerator.generate(Account.SObjectType)
            ),
            new Brand__c(
                Id = fflib_IDGenerator.generate(Brand__c.SObjectType),
                Name = 'Test 2',
                Brand_Owner__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrands brandsMock = (IBrands) mocks.mock(IBrands.class);
        mocks.startStubbing();
        mocks.when(brandsMock.getType()).thenReturn(Schema.Brand__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(brandsMock);

        fflib_SObjectDomain.Test.Database.onInsert(newBrands);
        fflib_SObjectDomain.triggerHandler(BrandsHandler.class);

        ((IBrands) mocks.verify(brandsMock, 1)).createBrandAssociationsBasedOnBrandOwner();
    }
}