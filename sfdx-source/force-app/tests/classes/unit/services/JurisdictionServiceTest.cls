/**
 * @author BizApps
 * @date 17-April-2024
 * @description Test class for the JurisidictionService
 **/
@isTest
private class JurisdictionServiceTest {
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String SEATTLE_ZIP_CODE = '98109';
    private static final String TORONTO = 'Toronto';
    private static final String CANADA = 'Canada';
    private static final String VANCOUVER = 'Vancouver';
    private static final String WASHINGTON = 'Washington';
    private static final String TEXAS = 'Texas';
    private static final String USA = 'United States';
    private static final String ASSERT_MSG_CONTACT_TRUE = 'This Contact should be in the relevant jurisdiction for this rule';
    private static final String ASSERT_MSG_CONTACT_FALSE = 'This Contact should NOT be in the relevant jurisdiction for this rule';
    private static final String ASSERT_MSG_CANADA_TRUE = 'This Account should be in the Canada jurisdiction';
    private static final String ASSERT_MSG_SEATTLE_TRUE = 'This Account should be in the Seattle jurisdiction';
    private static final String ASSERT_MSG_SEATTLE_FALSE = 'This Account should NOT be in the Seattle jurisdiction';
    private static final String ASSERT_MSG_CANADA_FALSE = 'This Account should NOT be in the Canada jurisdiction';
    private static final String ASSERT_MSG_CANADA_WORK_ORDER_FALSE = 'This Work Order should NOT be considered Canadian';
    private static final String ASSERT_MSG_CANADA_WORK_ORDER_TRUE = 'This Work Order should be considered Canadian';
    private static final String ASSERT_MSG_ALL_JURISDICTIONS_FALSE = 'This Account should NOT be in all the supplied jurisdictions';

    @isTest
    static void testWhenMerchantIsInJurisdictionThenReturnTrue() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id accountId = Fake.generateId(Account.class);

        Account testAccount = new Account(
            Id = accountId,
            Name = ACCOUNT_NAME,
            BillingCity = TORONTO,
            BillingCountry = CANADA
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ testAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);

        Boolean result = JurisdictionService.isMerchantInJurisdiction(
            accountId,
            JurisdictionService.Jurisdiction.CANADA
        );
        System.assert(result, ASSERT_MSG_CANADA_TRUE);
    }

    @isTest
    static void testWhenMerchantIsNotInJurisdictionThenReturnFalse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Account testUnitedStatesAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = ACCOUNT_NAME,
            BillingCity = VANCOUVER,
            BillingState = WASHINGTON,
            BillingCountry = USA
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ testUnitedStatesAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);

        Boolean result = JurisdictionService.isMerchantInJurisdiction(
            testUnitedStatesAccount.Id,
            JurisdictionService.Jurisdiction.CANADA
        );
        System.assert(!result, ASSERT_MSG_CANADA_FALSE);
    }

    @isTest
    static void testWhenMerchantIsInAllJurisdictionsThenReturnTrue() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Account testAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = ACCOUNT_NAME,
            BillingPostalCode = SEATTLE_ZIP_CODE
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ testAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);

        Boolean result = JurisdictionService.isMerchantInAllJurisdictions(
            testAccount.Id,
            new List<JurisdictionService.Jurisdiction>{ JurisdictionService.Jurisdiction.SEATTLE }
        );
        System.assert(result, ASSERT_MSG_SEATTLE_TRUE);
    }

    @isTest
    static void testWhenMerchantIsInAllJurisdictionsThenReturnFalse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Account testAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = ACCOUNT_NAME,
            BillingPostalCode = SEATTLE_ZIP_CODE
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ testAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);

        Boolean result = JurisdictionService.isMerchantInAllJurisdictions(
            testAccount.Id,
            new List<JurisdictionService.Jurisdiction>{
                JurisdictionService.Jurisdiction.SEATTLE,
                JurisdictionService.Jurisdiction.CANADA
            }
        );
        System.assert(!result, ASSERT_MSG_ALL_JURISDICTIONS_FALSE);
    }

    @IsTest
    static void testWhenContactInJurisdictionThenReturnTrue() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Jurisdiction_Rule__mdt thisRule = new Jurisdiction_Rule__mdt(City__c = VANCOUVER);

        Contact testContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'Test',
            LastName = 'Contact',
            MailingCity = VANCOUVER
        );

        IContactsSelector contactsSelectorMock = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelectorMock.selectContactsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Contact>{ testContact });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contactsSelectorMock);

        SObject thisCon = JurisdictionServiceHelper.fetchDataById(testContact.Id);

        Boolean shouldBeTrue = JurisdictionServiceImpl.matchesJurisdiction(thisCon, thisRule);
        System.assert(shouldBeTrue, ASSERT_MSG_CONTACT_TRUE);
    }

    @IsTest
    static void testWhenContactInJurisdictionThenReturnFalse() {
        Jurisdiction_Rule__mdt thisRule = new Jurisdiction_Rule__mdt(
            State_Province__c = WASHINGTON
        );

        Jurisdiction_Rule__mdt thisCityRule = new Jurisdiction_Rule__mdt(City__c = VANCOUVER);
        Jurisdiction_Rule__mdt thisZipRule = new Jurisdiction_Rule__mdt(Postal_Code__c = '11111');

        Contact testContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'Test',
            LastName = 'Contact',
            MailingState = TEXAS
        );

        Boolean result = JurisdictionServiceImpl.matchesJurisdiction(testContact, thisRule);
        System.assert(!result, ASSERT_MSG_CONTACT_FALSE);

        Boolean cityResult = JurisdictionServiceImpl.matchesJurisdiction(testContact, thisCityRule);
        System.assert(!cityResult, ASSERT_MSG_CONTACT_FALSE);

        Boolean zipResult = JurisdictionServiceImpl.matchesJurisdiction(testContact, thisZipRule);
        System.assert(!zipResult, ASSERT_MSG_CONTACT_FALSE);
    }

    @IsTest
    static void testWhenCallingAnyMxInJurisdictionThenReturnResult() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id accountId = Fake.generateId(Account.class);
        Account testAccount = new Account(
            Id = accountId,
            Name = ACCOUNT_NAME,
            BillingCity = TORONTO,
            BillingCountry = CANADA
        );

        Id contactId = Fake.generateId(Contact.class);
        Contact testContact = new Contact(
            Id = contactId,
            FirstName = 'Test',
            LastName = 'Contact',
            MailingCity = VANCOUVER,
            MailingState = WASHINGTON
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContactsSelector contactsSelectorMock = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ testAccount });

        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelectorMock.selectContactsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Contact>{ testContact });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);

        Boolean shouldBeTrue = JurisdictionService.areAnyMerchantsInJurisdiction(
            new Set<Id>{ accountId, contactId },
            JurisdictionService.Jurisdiction.CANADA
        );
        System.assert(shouldBeTrue, ASSERT_MSG_CANADA_TRUE);

        Boolean shouldBeFalse = JurisdictionService.areAnyMerchantsInJurisdiction(
            new Set<Id>{ accountId, contactId },
            JurisdictionService.Jurisdiction.SEATTLE
        );
        System.assert(!shouldBeFalse, ASSERT_MSG_SEATTLE_FALSE);

        Boolean nullScenarioShouldBeFalse = JurisdictionService.areAnyMerchantsInJurisdiction(
            null,
            JurisdictionService.Jurisdiction.SEATTLE
        );
        System.assert(!nullScenarioShouldBeFalse, ASSERT_MSG_SEATTLE_FALSE);
    }

    @IsTest
    static void testWhenIsInvalidInputThenReturnErrors() {
        Jurisdiction_Rule__mdt thisRule = Jurisdiction_Rule__mdt.getAll().values()[0];

        Boolean shouldBeFalse = JurisdictionServiceImpl.matchesJurisdiction(null, thisRule);
        System.assert(!shouldBeFalse, 'Null input should return false');

        Boolean shouldThrowException = false;
        try {
            JurisdictionServiceImpl.matchesJurisdiction(new Product2(), thisRule);
        } catch (Exception ex) {
            shouldThrowException = ex.getMessage()
                .containsIgnoreCase(JurisdictionServiceImpl.UNSUPPORTED_OBJECT_EXCEPTION_MSG);
        }

        System.assert(
            shouldThrowException,
            'An exception for unsupported object type should have been thrown'
        );
    }

    @IsTest
    static void testWhenCheckingSetOfIdsInJurisdictionThenReturnResultMap() {
        Id bizAccountId1 = Fake.generateId(Account.class);
        Id bizAccountId2 = Fake.generateId(Account.class);
        Id bizAccountId3 = Fake.generateId(Account.class);

        List<Account> accounts = new List<Account>{
            new Account(Id = bizAccountId1, BillingCountry = USA),
            new Account(Id = bizAccountId2, BillingCountry = USA),
            new Account(Id = bizAccountId3, BillingCountry = CANADA)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(accounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);

        Map<Id, Boolean> results = JurisdictionService.checkIdsInJurisdiction(
            new Map<Id, Account>(accounts).keySet(),
            JurisdictionService.Jurisdiction.CANADA
        );

        System.assert(!results.get(bizAccountId1), ASSERT_MSG_CANADA_FALSE);
        System.assert(!results.get(bizAccountId2), ASSERT_MSG_CANADA_FALSE);
        System.assert(results.get(bizAccountId3), ASSERT_MSG_CANADA_TRUE);
    }

    @IsTest
    static void testWhenCheckParentAndChildrenLogicIsRunThenReturnParentResults() {
        Id bizAccountId1 = Fake.generateId(Account.class);
        Id bizAccountId2 = Fake.generateId(Account.class);
        Id bizAccountId3 = Fake.generateId(Account.class);

        Id storeAccountId1a = Fake.generateId(Account.class);
        Id storeAccountId1b = Fake.generateId(Account.class);
        Id storeAccountId1c = Fake.generateId(Account.class);
        Id storeAccountId2a = Fake.generateId(Account.class);
        Id storeAccountId2b = Fake.generateId(Account.class);
        Id storeAccountId2c = Fake.generateId(Account.class);
        Id storeAccountId3a = Fake.generateId(Account.class);
        Id storeAccountId3b = Fake.generateId(Account.class);
        Id storeAccountId3c = Fake.generateId(Account.class);

        Id parentWorkOrderId1 = Fake.generateId(WorkOrder.class);
        Id parentWorkOrderId2 = Fake.generateId(WorkOrder.class);
        Id parentWorkOrderId3 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId1 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId2 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId3 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId4 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId5 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId6 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId7 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId8 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId9 = Fake.generateId(WorkOrder.class);

        // Parent Account 1 = In Canada (via Business Account) 🇨🇦
        // Parent Account 2 = In Canada (via Store Account) 🇨🇦
        // Parent Account 3 = NOT In Canada 🇺🇸
        List<Account> accounts = new List<Account>{
            new Account(Id = bizAccountId1, BillingCountry = CANADA),
            new Account(Id = storeAccountId1a, ParentId = bizAccountId1),
            new Account(Id = storeAccountId1b, ParentId = bizAccountId1),
            new Account(Id = storeAccountId1c, ParentId = bizAccountId1),
            new Account(Id = bizAccountId2, BillingCountry = USA),
            new Account(Id = storeAccountId2a, ParentId = bizAccountId2),
            new Account(Id = storeAccountId2b, ParentId = bizAccountId2, BillingCountry = CANADA),
            new Account(Id = storeAccountId2c, ParentId = bizAccountId2),
            new Account(Id = bizAccountId3, BillingCountry = USA),
            new Account(Id = storeAccountId3a, ParentId = bizAccountId3, BillingCountry = USA),
            new Account(Id = storeAccountId3b, ParentId = bizAccountId3, BillingCountry = USA),
            new Account(Id = storeAccountId3c, ParentId = bizAccountId3, BillingCountry = USA)
        };

        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(Id = parentWorkOrderId1, AccountId = bizAccountId1),
            new WorkOrder(
                Id = childWorkOrderId1,
                AccountId = storeAccountId1a,
                ParentWorkOrderId = parentWorkOrderId1
            ),
            new WorkOrder(
                Id = childWorkOrderId2,
                AccountId = storeAccountId1b,
                ParentWorkOrderId = parentWorkOrderId1
            ),
            new WorkOrder(
                Id = childWorkOrderId3,
                AccountId = storeAccountId1c,
                ParentWorkOrderId = parentWorkOrderId1
            ),
            new WorkOrder(Id = parentWorkOrderId2, AccountId = bizAccountId2),
            new WorkOrder(
                Id = childWorkOrderId4,
                AccountId = storeAccountId2a,
                ParentWorkOrderId = parentWorkOrderId2
            ),
            new WorkOrder(
                Id = childWorkOrderId5,
                AccountId = storeAccountId2b,
                ParentWorkOrderId = parentWorkOrderId2
            ),
            new WorkOrder(
                Id = childWorkOrderId6,
                AccountId = storeAccountId2c,
                ParentWorkOrderId = parentWorkOrderId2
            ),
            new WorkOrder(Id = parentWorkOrderId3, AccountId = bizAccountId3),
            new WorkOrder(
                Id = childWorkOrderId7,
                AccountId = storeAccountId3a,
                ParentWorkOrderId = parentWorkOrderId3
            ),
            new WorkOrder(
                Id = childWorkOrderId8,
                AccountId = storeAccountId3b,
                ParentWorkOrderId = parentWorkOrderId3
            ),
            new WorkOrder(
                Id = childWorkOrderId9,
                AccountId = storeAccountId3c,
                ParentWorkOrderId = parentWorkOrderId3
            )
        };

        Map<Id, Set<Id>> parentAndChildMap = new Map<Id, Set<Id>>{
            parentWorkOrderId1 => new Set<Id>{
                childWorkOrderId1,
                childWorkOrderId2,
                childWorkOrderId3
            },
            parentWorkOrderId2 => new Set<Id>{
                childWorkOrderId4,
                childWorkOrderId5,
                childWorkOrderId6
            },
            parentWorkOrderId3 => new Set<Id>{
                childWorkOrderId7,
                childWorkOrderId8,
                childWorkOrderId9
            }
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(accounts);

        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(workOrders);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);

        // TEST CASE #1 - USE WORK ORDERS
        Map<Id, Boolean> results = JurisdictionService.checkParentAndChildrenInJurisdiction(
            parentAndChildMap,
            JurisdictionService.Jurisdiction.CANADA
        );

        System.assert(results.get(parentWorkOrderId1), ASSERT_MSG_CANADA_WORK_ORDER_TRUE);
        System.assert(results.get(parentWorkOrderId2), ASSERT_MSG_CANADA_WORK_ORDER_TRUE);
        System.assert(!results.get(parentWorkOrderId3), ASSERT_MSG_CANADA_WORK_ORDER_FALSE);

        Map<Id, Set<Id>> accountParentAndChildMap = new Map<Id, Set<Id>>{
            bizAccountId1 => new Set<Id>{ storeAccountId1a, storeAccountId1b, storeAccountId1c },
            bizAccountId2 => new Set<Id>{ storeAccountId2a, storeAccountId2b, storeAccountId2c },
            bizAccountId3 => new Set<Id>{ storeAccountId3a, storeAccountId3b, storeAccountId3c }
        };

        // TEST CASE #2 - USE ACCOUNTS
        Map<Id, Boolean> accountResults = JurisdictionService.checkParentAndChildrenInJurisdiction(
            accountParentAndChildMap,
            JurisdictionService.Jurisdiction.CANADA
        );

        System.assert(accountResults.get(bizAccountId1), ASSERT_MSG_CANADA_TRUE);
        System.assert(accountResults.get(bizAccountId2), ASSERT_MSG_CANADA_TRUE);
        System.assert(!accountResults.get(bizAccountId3), ASSERT_MSG_CANADA_FALSE);
    }

    @IsTest
    static void testWhenConvertingParentChildMapToIdsThenFlattenIntoSet() {
        Id parentWorkOrderId1 = Fake.generateId(WorkOrder.class);
        Id parentWorkOrderId2 = Fake.generateId(WorkOrder.class);
        Id parentWorkOrderId3 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId1 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId2 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId3 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId4 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId5 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId6 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId7 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId8 = Fake.generateId(WorkOrder.class);
        Id childWorkOrderId9 = Fake.generateId(WorkOrder.class);

        Map<Id, Set<Id>> parentAndChildMap = new Map<Id, Set<Id>>{
            parentWorkOrderId1 => new Set<Id>{
                childWorkOrderId1,
                childWorkOrderId2,
                childWorkOrderId3
            },
            parentWorkOrderId2 => new Set<Id>{
                childWorkOrderId4,
                childWorkOrderId5,
                childWorkOrderId6
            },
            parentWorkOrderId3 => new Set<Id>{
                childWorkOrderId7,
                childWorkOrderId8,
                childWorkOrderId9
            }
        };

        Integer numberOfIdsForTesting = 0;
        for (Id thisParentId : parentAndChildMap.keySet()) {
            numberOfIdsForTesting += (parentAndChildMap.get(thisParentId).size() + 1); // Add 1 for the parent to its number of children
        }

        Set<Id> results = JurisdictionServiceHelper.convertParentChildMapToSetOfIds(
            parentAndChildMap
        );
        System.assertEquals(
            numberOfIdsForTesting,
            results.size(),
            'Incorrect number of IDs in the result Set'
        );

        for (Id thisParentId : parentAndChildMap.keySet()) {
            System.assert(
                results.contains(thisParentId),
                'Parent ID not present in result Set: ' + String.valueOf(thisParentId)
            );

            for (Id thisChildId : parentAndChildMap.get(thisParentId)) {
                System.assert(
                    results.contains(thisChildId),
                    'Child ID not present in result Set: ' + String.valueOf(thisParentId)
                );
            }
        }

        Set<Id> resultsForNullScenario = JurisdictionServiceHelper.convertParentChildMapToSetOfIds(
            null
        );
        System.assert(
            resultsForNullScenario.isEmpty(),
            'The null scenario should return an empty list.'
        );
    }
}