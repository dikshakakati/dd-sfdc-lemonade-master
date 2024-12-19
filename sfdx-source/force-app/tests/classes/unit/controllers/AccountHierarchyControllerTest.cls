/**
 * @author Deloitte
 * @date   05/10/2022
 * @description Test class for Account Hierarchy Controller
 */
@isTest(seeAllData=false)
public with sharing class AccountHierarchyControllerTest {
    /**
     * @description To test get selected account method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingTheAccountDetailsThenAccountRecordsWithTheCorrectFieldsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id parentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId
            )
        };

        List<String> columns = new List<String>{ 'Id', 'Name', 'ParentId', 'RecordTypeId' };
        Set<String> fieldsToQuery = new Set<String>(columns);
        List<String> selectedAccountsFields = new List<String>{
            'Id',
            'RecordType.DeveloperName',
            'ParentId',
            'Parent.ParentId',
            'Parent.Parent.ParentId',
            'Parent.Parent.Parent.ParentId',
            'Ultimate_Parent_Account__c',
            'Franchise_Parent__c',
            'Franchise_Parent__r.ParentId',
            'Franchise_Parent__r.Parent.ParentId',
            'Franchise_Parent__r.Parent.Parent.ParentId',
            'Franchise_Parent__r.Ultimate_Parent_Account__c'
        };
        fieldsToQuery.addAll(selectedAccountsFields);

        List<Id> accountIds = new List<Id>{ newAccounts[0].Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectFilteredAccount(fieldsToQuery, accountIds))
            .thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Account> selectedAccount = AccountHierarchyController.getAccountDetails(
            columns,
            newAccounts[0].Id
        );

        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .selectFilteredAccount(fieldsToQuery, accountIds);
        System.assertEquals(1, selectedAccount.size(), 'The list size does not match');
        System.assertEquals(selectedAccount[0].Name, 'Test 1', 'The value does not match');
        System.assertEquals(selectedAccount[0].ParentId, parentId, 'The value does not match');
    }

    /**
     * @description To test exception message for selected account method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingWrongFieldsForAccountDetailsThenReturnExceptionMessage() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id parentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId
            )
        };

        List<String> columns = new List<String>{ 'Id', 'Name', 'ParentId', 'RecordTypeId' };
        Set<String> fieldsToQuery = new Set<String>(columns);
        List<String> selectedAccountsFields = new List<String>{
            'Id',
            'RecordType.Developer',
            'ParentId',
            'Parent.ParentId',
            'Parent.Parent.ParentId',
            'Parent.Parent.Parent.ParentId',
            'Ultimate_Parent_Account__c',
            'Franchise_Parent__c',
            'Franchise_Parent__r.ParentId',
            'Franchise_Parent__r.Parent.ParentId',
            'Franchise_Parent__r.Parent.Parent.ParentId',
            'Franchise_Parent__r.Ultimate_Parent_Account__c'
        };
        fieldsToQuery.addAll(selectedAccountsFields);

        List<Id> accountIds = new List<Id>{ newAccounts[0].Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectFilteredAccount(fieldsToQuery, accountIds))
            .thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        try {
            AccountHierarchyController.getAccountDetails(columns, newAccounts[0].Id);
            System.assert(false, System.Label.Failed_Retrieve_Account);
        } catch (Exception ex) {
            System.assertEquals(
                System.Label.Failed_Retrieve_Account,
                ex.getMessage(),
                'The error message does not match'
            );
        }
    }

    /**
     * @description To test get child accounts for corporate account hierarchy
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingCorporateChildAccountsDetailsThenAccountRecordsWithTheCorrectFieldsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);

        List<Account> returnedAccounts = new List<Account>{
            new Account(
                Name = 'Test Child 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId1,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            ),
            new Account(
                Name = 'Test Child 2',
                RecordTypeId = storeRecordTypeId,
                ParentId = parentId2,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            )
        };

        List<String> columns = new List<String>{ 'Id', 'Name', 'ParentId', 'RecordTypeId' };
        Set<String> fieldsToQuery = new Set<String>(columns);
        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'Franchise_Parent__c',
            'RecordType.DeveloperName'
        };
        fieldsToQuery.addAll(childAccountFields);

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectHierachyChildAccounts(
                    fieldsToQuery,
                    parentSObjectField,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Account> retrievedChildAccounts = AccountHierarchyController.getChildAccounts(
            columns,
            'ParentId',
            accountIds
        );
        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .selectHierachyChildAccounts(fieldsToQuery, parentSObjectField, accountIds);
        System.assertEquals(2, retrievedChildAccounts.size(), 'The list size does not match');
        System.assertEquals(
            retrievedChildAccounts[0].Name,
            'Test Child 1',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[0].ParentId,
            parentId1,
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].Name,
            'Test Child 2',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].ParentId,
            parentId2,
            'The value does not match'
        );
    }

    /**
     * @description To test excpetion message for get child accounts method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingWrongFieldsForChildAccountsDetailsThenReturnExceptionMessage() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);

        List<Account> returnedAccounts = new List<Account>{
            new Account(
                Name = 'Test Child 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId1,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            ),
            new Account(
                Name = 'Test Child 2',
                RecordTypeId = storeRecordTypeId,
                ParentId = parentId2,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            )
        };

        List<String> columns = new List<String>{ 'Id', 'Name', 'ParentId', 'RecordTypeId' };
        Set<String> fieldsToQuery = new Set<String>(columns);
        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'Franchise_Parent__c',
            'RecordType.Developer'
        };
        fieldsToQuery.addAll(childAccountFields);

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectHierachyChildAccounts(
                    fieldsToQuery,
                    parentSObjectField,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        try {
            AccountHierarchyController.getChildAccounts(columns, 'ParentId', accountIds);
            System.assert(false, System.Label.Failed_Retrieve_Child_Accounts);
        } catch (Exception ex) {
            System.assertEquals(
                System.Label.Failed_Retrieve_Child_Accounts,
                ex.getMessage(),
                'The error message does not match'
            );
        }
    }

    /**
     * @description To test get child accounts for franchise account hierarchy
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingFranchiseChildAccountsDetailsThenAccountRecordsWithTheCorrectFieldsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);

        List<Account> returnedAccounts = new List<Account>{
            new Account(
                Name = 'Test Child 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId1,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            ),
            new Account(
                Name = 'Test Child 2',
                RecordTypeId = storeRecordTypeId,
                Franchise_Parent__c = parentId2,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801'
            )
        };

        List<String> columns = new List<String>{
            'Id',
            'Name',
            'Franchise_Parent__c',
            'RecordTypeId'
        };
        Set<String> fieldsToQuery = new Set<String>(columns);
        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'Franchise_Parent__c',
            'RecordType.DeveloperName'
        };
        fieldsToQuery.addAll(childAccountFields);

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('Franchise_Parent__c');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectHierachyChildAccounts(
                    fieldsToQuery,
                    parentSObjectField,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Account> retrievedChildAccounts = AccountHierarchyController.getChildAccounts(
            columns,
            'Franchise_Parent__c',
            accountIds
        );
        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .selectHierachyChildAccounts(fieldsToQuery, parentSObjectField, accountIds);
        System.assertEquals(2, retrievedChildAccounts.size(), 'The list size does not match');
        System.assertEquals(
            retrievedChildAccounts[0].Name,
            'Test Child 1',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[0].ParentId,
            parentId1,
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].Name,
            'Test Child 2',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].Franchise_Parent__c,
            parentId2,
            'The value does not match'
        );
    }

    /**
     * @description To test get metadata record by label
     */
    @IsTest
    private static void testWhenGetMetadataRecordByDeveloperNameThenGetAppropriateRecord() {
        List<Static_Configurations__mdt> customMetadataMocks = new List<Static_Configurations__mdt>{
            new Static_Configurations__mdt(
                Label = 'Corporate Hierarchy Report Id',
                DeveloperName = 'Corporate_Hierarchy_Report_Id'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StaticConfigurationsSelector mockStaticConfigurations = (StaticConfigurationsSelector) mocks.mock(
            StaticConfigurationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.selectByDeveloperName('Corporate_Hierarchy_Report_Id'))
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);

        Static_Configurations__mdt staticConfiguration = AccountHierarchyController.getMetadataRecord(
            'Corporate_Hierarchy_Report_Id'
        );

        System.assertEquals(
            staticConfiguration.DeveloperName,
            'Corporate_Hierarchy_Report_Id',
            'Unexpected Error: Mismatch in Static Configuration Metadata'
        );
    }

    /**
     * @description To test get metadata record by label
     */
    @IsTest
    private static void testWhenGetMetadataRecordByDeveloperNameNotPresentThenReturnNull() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        StaticConfigurationsSelector mockStaticConfigurations = (StaticConfigurationsSelector) mocks.mock(
            StaticConfigurationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.selectByDeveloperName('Corporate_Hierarchy_ReportId'))
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);

        Static_Configurations__mdt staticConfigurationEmpty = AccountHierarchyController.getMetadataRecord(
            'Corporate_Hierarchy_ReportId'
        );

        System.assertEquals(
            staticConfigurationEmpty,
            null,
            'Unexpected Error: Mismatch in Static Configuration Metadata'
        );
    }
}