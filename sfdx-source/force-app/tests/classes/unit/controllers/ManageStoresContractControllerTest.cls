/**
 * @description This is a test class created to test the Manage Stores Controller
 * @author deloitte
 * @date 14/11/2023
 */
@isTest(SeeAllData=false)
public with sharing class ManageStoresContractControllerTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_CHANNEL_PARTNER = 'Channel_Partner';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_CANCELLED = 'Cancelled';

    /**
     * @description This method is used to test SelectAssociatedAccounts
     */
    @isTest
    private static void testWhenSelectAssociatedAccountsThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .toSObject();

        Contract_Associated_Accounts__c association1 = (Contract_Associated_Accounts__c) new Fake(
                Contract_Associated_Accounts__c.class
            )
            .setField(Contract_Associated_Accounts__c.Contract__c, fakeContract.Id)
            .setField(Contract_Associated_Accounts__c.Order__c, 1)
            .setField(
                Contract_Associated_Accounts__c.Associated_Account_Ids__c,
                associatedAccountIds
            )
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractAssociatedAccountsSelector caaSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2 });
        mocks.when(caaSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.when(caaSelectorMock.selectByContractId(contractId))
            .thenReturn(new List<Contract_Associated_Accounts__c>{ association1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(caaSelectorMock);

        List<Account> accountList = ManageStoresContractController.selectAssociatedAccounts(
            String.valueOf(contractId)
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
    }

    /**
     * @description This method is used to test SelectAssociatedAccounts with no Associated_Account_Ids__c
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenSelectAssociatedAccountsEmptyThenDoNotCallSelector() {
        Id contractId = Fake.generateId(Contract.class);

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        ManageStoresController.selectAssociatedAccounts(String.valueOf(contractId));

        ((IAccountsSelector) mocks.verify(accountSelectorMock, 0))
            .selectById((Set<Id>) fflib_Match.anyObject());
    }

    /**
     * @description This method is used to test selectAccountsById
     * when all of the accounts in the list are already associated to the Contract
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectAlreadyContractedAccountsThenCallAccountSelectorSelectById() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3, accountId4 }
                )
            )
            .thenReturn(
                new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3, fakeAccount4 }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3),
            String.valueOf(accountId4)
        };
        ManageStoresContractController.selectAccountsById(
            accountstoSearchList,
            String.valueOf(contractId),
            false
        );

        ((IAccountsSelector) mocks.verify(accountSelectorMock, 1))
            .selectById((Set<Id>) fflib_Match.anyObject());
    }
    /**
     * @description This method is used to test uploadFile
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFileIsUploadedThenCallTheService() {
        Id contractId = Fake.generateId(Contract.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersionService contentVersionService = (IContentVersionService) mocks.mock(
            IContentVersionService.class
        );
        Application.SERVICE.setMock(IContentVersionService.class, contentVersionService);

        String blobdata = 'Id,Type,Recordtype';
        String testFileName = 'test.csv';

        ManageStoresContractController.uploadFile(blobdata, testFileName, contractId);

        ((IContentVersionService) mocks.verify(contentVersionService, 1))
            .createContentVersion(blobdata, testFileName, contractId);
    }

    @isTest
    private static void testWhenUploadedAccountNotFallInContractingAccountHierarchyThenThrowException() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, contractingAccountId)
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, contractingAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3)
        };
        String exceptionMessage = '';
        try {
            ManageStoresContractController.selectAccountsById(
                accountstoSearchList,
                String.valueOf(contractId),
                false
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(
            exceptionMessage.startsWith(
                ManageStoresContractController.ACCOUNT_HIERARCHY_EXCEPTION_START
            ),
            'Exception Messages was not thrown as expected'
        );
    }

    @isTest
    private static void testWhenAccountNotHierarchyButChannelPartnerThenDoNotThrowException() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, contractingAccountId)
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, contractingAccountId)
                    .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_CHANNEL_PARTNER)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3)
        };
        String exceptionMessage = '';
        try {
            ManageStoresContractController.selectAccountsById(
                accountstoSearchList,
                String.valueOf(contractId),
                false
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage == '', 'Exception Messages should not have been thrown');
    }

    /**
     * @description This method is used to test selectAccountsByStoreId
     */
    @isTest
    private static void testWhenSelectAccountsByStoreIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        // Id accountId1 = Fake.generateId(Account.class);
        // Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        String externalId1 = 'test-store-1';
        String externalId2 = 'test-store-2';

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        // Account fakeAccount1 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId1)
        //     .setField(Account.Name, 'Fake 1')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        // Account fakeAccount2 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId2)
        //     .setField(Account.Name, 'Fake 2')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 4')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Xref__c fakeXref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId3)
            .setField(Xref__c.External_ID__c, externalId1)
            .setField(Xref__c.Id, xrefId1)
            .toSObject();

        Xref__c fakeXref2 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId4)
            .setField(Xref__c.External_ID__c, externalId2)
            .setField(Xref__c.Id, xrefId2)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                xrefSelectorMock.selectXrefByExternalId(
                    new List<String>{ externalId1, externalId2 }
                )
            )
            .thenReturn(new List<Xref__c>{ fakeXref1, fakeXref2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<Account> accountList = ManageStoresContractController.selectAccountsByStoreId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId),
            false
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    /**
     * @description This method is used to test selectAccountsByBusinessId
     */
    @isTest
    private static void testWhenSelectAccountsByBusinessIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        // Id accountId1 = Fake.generateId(Account.class);
        // Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        Id busRefId1 = Fake.generateId(Business_Reference__c.class);
        Id busRefId2 = Fake.generateId(Business_Reference__c.class);

        String externalId1 = 'test-business-1';
        String externalId2 = 'test-business-2';

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        // Account fakeAccount1 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId1)
        //     .setField(Account.Name, 'Fake 1')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        // Account fakeAccount2 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId2)
        //     .setField(Account.Name, 'Fake 2')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        // Business_Reference__c fakeBusRef1 = (Business_Reference__c) new Fake(
        //         Business_Reference__c.class
        //     )
        //     .setField(Business_Reference__c.External_ID__c, externalId1)
        //     .setField(Business_Reference__c.Id, busRefId1)
        //     .toSObject();

        // Business_Reference__c fakeBusRef2 = (Business_Reference__c) new Fake(
        //         Business_Reference__c.class
        //     )
        //     .setField(Business_Reference__c.External_ID__c, externalId2)
        //     .setField(Business_Reference__c.Id, busRefId2)
        //     .toSObject();

        Xref__c fakeXref1 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId3)
            .setField(Xref__c.Business_Reference__c, busRefId1)
            .setField(Xref__c.Id, xrefId1)
            .toSObject();

        Xref__c fakeXref2 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, accountId4)
            .setField(Xref__c.Business_Reference__c, busRefId2)
            .setField(Xref__c.Id, xrefId2)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                xrefSelectorMock.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ externalId1, externalId2 }
                )
            )
            .thenReturn(new List<Xref__c>{ fakeXref1, fakeXref2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<Account> accountList = ManageStoresContractController.selectAccountsByBusinessId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId),
            false
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    @isTest
    private static void testWhenUploadedAccountNotFallInContractingAccountHierarchyThenDontThrowExceptionForBusinessAccounts() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(
                        RecordType.Name,
                        ManageStoresContractController.ACCOUNT_RECORDTYPE_BUSINESS
                    )
            )
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(
                        RecordType.Name,
                        ManageStoresContractController.ACCOUNT_RECORDTYPE_BUSINESS
                    )
            )
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, contractingAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(
                        RecordType.Name,
                        ManageStoresContractController.ACCOUNT_RECORDTYPE_BUSINESS
                    )
            )
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, contractingAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3)
        };
        String exceptionMessage = '';
        try {
            ManageStoresContractController.selectAccountsById(
                accountstoSearchList,
                String.valueOf(contractId),
                false
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage == '', 'Exception Messages should not have been thrown');
    }

    /**
     * @description This method is used to test selectAccountsById
     */
    @isTest
    private static void testWhenSelectAccountsByIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        // Id accountId1 = Fake.generateId(Account.class);
        // Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        // Account fakeAccount1 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId1)
        //     .setField(Account.Name, 'Fake 1')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        // Account fakeAccount2 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId2)
        //     .setField(Account.Name, 'Fake 2')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 4')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<Account> accountList = ManageStoresContractController.selectAccountsById(
            new List<String>{ accountId3, accountId4 },
            String.valueOf(contractId),
            false
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    /**
     * @description This method is used to test selectAccountsById
     */
    @isTest
    private static void testWhenSelectAccountsByIdThenCallSelectorDemoooo() {
        Id contractId = Fake.generateId(Contract.class);
        // Id accountId1 = Fake.generateId(Account.class);
        // Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Id fakeAgreementId4 = Fake.generateId(Agreement__c.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        // Account fakeAccount1 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId1)
        //     .setField(Account.Name, 'Fake 1')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        // Account fakeAccount2 = (Account) new Fake(Account.class)
        //     .setField(Account.Id, accountId2)
        //     .setField(Account.Name, 'Fake 2')
        //     .setField(Account.ParentId, parentAccountId)
        //     .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 4')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Status__c, STATUS_ACTIVE)
            .toSObject();
        Agreement__c fakeAgreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId4)
            .setField(Agreement__c.Status__c, STATUS_ACTIVE)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                agreementsSelectorMock.selectActiveAndCancelledAgreementsByAccountIds(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3, fakeAgreement4 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);

        List<Account> accountList = ManageStoresContractController.selectAccountsById(
            new List<String>{ accountId3, accountId4 },
            String.valueOf(contractId),
            true
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }
    @isTest
    private static void testWhenAccountsUploadedThenCalculateAllAreBusinessAccounts() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Boolean areAllBusinessAccountIds = true;

        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };

        List<Aggregate> corporateCount = new List<Aggregate>{
            new Aggregate().put('Id', null).put('accountIdCount', 2)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectCountOfAccounts(accountIdSet))
            .thenReturn(corporateCount);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        areAllBusinessAccountIds = ManageStoresContractController.areAllBusinessAccounts(
            new List<String>{ String.valueOf(accountId1), String.valueOf(accountId2) }
        );

        System.assertEquals(
            true,
            areAllBusinessAccountIds,
            'All accounts are business accounts, so the result should be true.'
        );
    }

    /**
     * @description This method is used to test calculateNewStoresAndCOO
     */
    @isTest
    private static void testWhenNewAccountsUploadedThenCalculateNewStoresAndCOO() {
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);

        mocks.when(
                agreementsSelectorMock.selectActiveAndCancelledAgreementsByAccountIds(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Agreement__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);

        Map<String, Boolean> variableBooleanResult = ManageStoresContractController.calculateNewStoresAndCOO(
            new List<String>{ accountId3, accountId4 }
        );

        System.assertEquals(
            true,
            variableBooleanResult.get('isProcessingOnlyNew'),
            'Uploaded accounts should be only new stores'
        );
    }

    /**
     * @description This method is used to test calculateNewStoresAndCOO for COO accounts
     */
    @isTest
    private static void testWhenCOOAccountsUploadedThenCalculateNewStoresAndCOO() {
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Id fakeAgreementId4 = Fake.generateId(Agreement__c.class);
        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .toSObject();
        Agreement__c fakeAgreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId4)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);

        mocks.when(
                agreementsSelectorMock.selectActiveAndCancelledAgreementsByAccountIds(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3, fakeAgreement4 });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);

        Map<String, Boolean> variableBooleanResult = ManageStoresContractController.calculateNewStoresAndCOO(
            new List<String>{ accountId3, accountId4 }
        );
        System.assertEquals(
            true,
            variableBooleanResult.get('isProcessingOnlyCoo'),
            'Uploaded accounts should be only coo stores'
        );
    }

    /**
     * @description This method is used to test calculateNewStoresAndCOO for COO and new accounts
     */
    @isTest
    private static void testWhenNewAccountsAndCooUploadedThenCalculateNewStoresAndCOO() {
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);

        mocks.when(
                agreementsSelectorMock.selectActiveAndCancelledAgreementsByAccountIds(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3 });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);

        Map<String, Boolean> variableBooleanResult = ManageStoresContractController.calculateNewStoresAndCOO(
            new List<String>{ accountId3, accountId4 }
        );
        System.assertEquals(
            true,
            variableBooleanResult.get('isProcessingNewAndCoo'),
            'Uploaded accounts should be new and coo stores'
        );
    }

    /**
     * @description This method is used to test validateStoreAssociationForAPContracts during Store Association with A&P Contract
     */
    @isTest
    private static void testWhenNewAccountAssociationInAPContractThenValidateCoreContractAssociation() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id coreContractId = Fake.generateId(Contract.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Name,'Fake Contract')
            .setField(Contract.accountId,parentAccountId)
            .toSObject();

        Contract fakeCoreContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, coreContractId)
            .setField(Contract.accountId,parentAccountId)
            .toSObject();

        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
		mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectCoreContractsByAccountIds(
                    new Set<Id>{parentAccountId}
                )
            )
            .thenReturn(new List<Contract>{ fakeCoreContract });
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByCoreContractIds(
                    new Set<Id>{ fakeCoreContract.Id }
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3 });
         mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{accountId1,accountId2}
                )
            )
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2 });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);

        List<Account> invalidAccounts = ManageStoresContractController.validateStoreAssociationForAPContracts(
            new List<Account>{ fakeAccount1, fakeAccount2 }, fakeContract
        );

        System.assertEquals(
            2,
            invalidAccounts.size(),
            'To associate Store(s) to the A&P Contract, Store should be associated with at least one Core Contract'
        );
    }
}
