/**
 * @description This is a test class created to test the Manage Stores Controller
 * @author atg
 * @date 05/05/2022
 */
@isTest(SeeAllData=false)
private class ManageStoresControllerTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_CHANNEL_PARTNER = 'Channel_Partner';

    /**
     * @description This method is used to test SelectAssociatedAccounts
     */
    @isTest
    private static void testWhenSelectAssociatedAccountsThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderID = Fake.generateId(WorkOrder.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };

        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Associated_Account_Ids__c, associatedAccountIds)
            .setField(WorkOrder.Id, workOrderID)
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, associatedAccountIds)
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

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IContractAssociatedAccountsSelector caaSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectManageableById(new Set<Id>{ workOrderID }))
            .thenReturn(new List<WorkOrder>{ fakeWorkOrder });
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2 });
        mocks.when(caaSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(caaSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelector);

        List<Account> accountList = ManageStoresController.selectAssociatedAccounts(
            String.valueOf(workOrderID)
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
            .setField(Contract.Associated_Account_Ids__c, '')
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
     * @description This method is used to test selectNonAssociatedAccountsById
     */
    @isTest
    private static void testWhenSelectNonAssociatedAccountsByIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderID = Fake.generateId(WorkOrder.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Associated_Account_Ids__c, associatedAccountIds)
            .setField(WorkOrder.Id, workOrderID)
            .setField(WorkOrder.AccountId, parentAccountId)
            .setField(WorkOrder.Type__c, 'POS')
            .toSObject();

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
            .setField(Account.Name, 'Fake 4')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
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
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectManageableById(new Set<Id>{ workOrderID }))
            .thenReturn(new List<WorkOrder>{ fakeWorkOrder });
        mocks.when(accountSelectorMock.selectById(accountIdSet))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3, accountId4 }
                )
            )
            .thenReturn(
                new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3, fakeAccount4 }
            );
        mocks.when(caaSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(caaSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelector);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3),
            String.valueOf(accountId4)
        };
        List<Account> accountList = ManageStoresController.selectNonAssociatedAccountsById(
            accountstoSearchList,
            String.valueOf(workOrderID)
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    /**
     * @description This method is used to test selectNonAssociatedAccountsById
     * when all of the accounts in the list are already associated to the Contract
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectAlreadyContractedAccountsThenDoNotCallAccountSelectorSelectById() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderID = Fake.generateId(WorkOrder.class);
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
            .setField(Account.Name, 'Fake 4')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();
        String associatedAccountIds =
            String.valueOf(accountId1) +
            ',' +
            String.valueOf(accountId2) +
            ',' +
            String.valueOf(accountId3) +
            +',' +
            String.valueOf(accountId4);

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .toSObject();

        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Associated_Account_Ids__c, associatedAccountIds)
            .setField(WorkOrder.Id, workOrderID)
            .setField(WorkOrder.AccountId, parentAccountId)
            .setField(WorkOrder.Type__c, 'POS')
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
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractAssociatedAccountsSelector caaSelectorMock = (IContractAssociatedAccountsSelector) mocks.mock(
            IContractAssociatedAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectManageableById(new Set<Id>{ workOrderID }))
            .thenReturn(new List<WorkOrder>{ fakeWorkOrder });
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
        mocks.when(caaSelectorMock.sObjectType())
            .thenReturn(Contract_Associated_Accounts__c.SObjectType);
        mocks.when(caaSelectorMock.selectByContractId(contractId))
            .thenReturn(new List<Contract_Associated_Accounts__c>{ association1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(caaSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelector);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3),
            String.valueOf(accountId4)
        };
        ManageStoresController.selectNonAssociatedAccountsById(
            accountstoSearchList,
            String.valueOf(workOrderID)
        );

        ((IAccountsSelector) mocks.verify(accountSelectorMock, 0))
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

        ManageStoresController.uploadFile(blobdata, testFileName, contractId);

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
            ManageStoresController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(
            exceptionMessage.startsWith(ManageStoresController.ACCOUNT_HIERARCHY_EXCEPTION_START),
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
            ManageStoresController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage == '', 'Exception Messages should not have been thrown');
    }

    /**
     * @description This method is used to test selectNonAssociatedAccountsByStoreId
     */
    @isTest
    private static void testWhenSelectNonAssociatedAccountsByStoreIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        String externalId1 = 'test-store-1';
        String externalId2 = 'test-store-2';

        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, associatedAccountIds)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
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

        List<Account> accountList = ManageStoresController.selectNonAssociatedAccountsByStoreId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId)
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    /**
     * @description This method is used to test selectNonAssociatedAccountsByBusinessId
     */
    @isTest
    private static void testWhenSelectNonAssociatedAccountsByBusinessIdThenCallSelector() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        Id busRefId1 = Fake.generateId(Business_Reference__c.class);
        Id busRefId2 = Fake.generateId(Business_Reference__c.class);

        String externalId1 = 'test-business-1';
        String externalId2 = 'test-business-2';

        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, associatedAccountIds)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
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

        List<Account> accountList = ManageStoresController.selectNonAssociatedAccountsByBusinessId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId)
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
                    .setField(RecordType.Name, ManageStoresController.ACCOUNT_RECORDTYPE_BUSINESS)
            )
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Name, ManageStoresController.ACCOUNT_RECORDTYPE_BUSINESS)
            )
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.ParentId, contractingAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Name, ManageStoresController.ACCOUNT_RECORDTYPE_BUSINESS)
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
            ManageStoresController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage == '', 'Exception Messages should not have been thrown');
    }

    /**
     * @description This method is used to test selectNonAssociatedAccountsById, ParentSobject = WorkOrder
     */
    @isTest
    private static void testWhenSelectNonAssociatedAccountsByIdForWorkOrderThenCallSelector() {
        Id workOrderID = Fake.generateId(WorkOrder.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Associated_Account_Ids__c, associatedAccountIds)
            .setField(WorkOrder.Id, workOrderID)
            .setField(WorkOrder.Type__c, 'POS')
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, accountId4)
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.Coverage__c, 'In Coverage')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 4')
            .setField(Account.Coverage__c, 'In Coverage')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, accountId3)
                .setField(Agreement__c.Contract__c, fakeContract.Id)
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, accountId4)
                .setField(Agreement__c.Contract__c, fakeContract.Id)
                .toSObject()
        };

        List<Merchant_Service__c> services = new List<Merchant_Service__c>{
            (Merchant_Service__c) new Fake(Merchant_Service__c.class)
                .setField(Merchant_Service__c.Account__c, accountId3)
                .toSObject(),
            (Merchant_Service__c) new Fake(Merchant_Service__c.class)
                .setField(Merchant_Service__c.Account__c, accountId4)
                .toSObject()
        };

        List<Order> orders = new List<Order>{
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, accountId3)
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
                .toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, accountId4)
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAgreementsSelector agreementsSelector = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        IMerchantSelector servicesSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectManageableById(new Set<Id>{ workOrderID }))
            .thenReturn(new List<WorkOrder>{ fakeWorkOrder });
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelector.selectAgreementsByAccounts(new Set<Id>{ accountId3, accountId4 })
            )
            .thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelector.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(ordersSelector.selectOrdersByAccountIds(new Set<Id>{ accountId3, accountId4 }))
            .thenReturn(orders);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ accountId3, accountId4 }))
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId3, accountId4 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount3, fakeAccount4 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(servicesSelector);
        Application.SELECTOR.setMock(ordersSelector);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId3),
            String.valueOf(accountId4)
        };
        List<Account> accountList = ManageStoresController.selectNonAssociatedAccountsById(
            accountstoSearchList,
            String.valueOf(workOrderID)
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    /**
     * @description This method is used to test selectNonAssociatedAccountsById, ParentSobject = WorkOrder,
     *  Accounts are not in Coverage, expects an Exception
     */
    @isTest
    private static void testWhenSelectNonAssociatedAccountsByIdForWorkOrdeAccoutsNotInCoveragerThenThrowException() {
        Id workOrderID = Fake.generateId(WorkOrder.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        String associatedAccountIds = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);

        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Associated_Account_Ids__c, associatedAccountIds)
            .setField(WorkOrder.Id, workOrderID)
            .toSObject();

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Coverage__c, 'In Coverage')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.Coverage__c, 'In Coverage')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount3 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId3)
            .setField(Account.Name, 'Fake 3')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Account fakeAccount4 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId4)
            .setField(Account.Name, 'Fake 4')
            .setField(Account.Address_Verification_Status__c, 'Verified')
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectManageableById(new Set<Id>{ workOrderID }))
            .thenReturn(new List<WorkOrder>{ fakeWorkOrder });
        mocks.when(
                accountSelectorMock.selectById(
                    new Set<Id>{ accountId1, accountId2, accountId3, accountId4 }
                )
            )
            .thenReturn(
                new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3, fakeAccount4 }
            );
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
        Application.SELECTOR.setMock(workOrderSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3),
            String.valueOf(accountId4)
        };
        String exceptionMessage;
        try {
            ManageStoresController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(workOrderID)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(
            exceptionMessage.startsWith(ManageStoresController.ACCOUNT_COVERAGE_EXCEPTION_START),
            'Exception Messages was not thrown as expected'
        );
    }

    /**
     * @description This method is used to test SaveAssociatedAccounts
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSaveAssociatedAccountsThenCallDomain() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id account = Fake.generateId(Account.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrderServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );

        Application.Service.setMock(IWorkOrdersService.class, workOrderServiceMock);

        ManageStoresController.saveAssociatedAccounts(
            String.valueOf(workOrderId),
            String.valueOf(account)
        );

        ((IWorkOrdersService) mocks.verify(workOrderServiceMock, 1))
            .setAssociatedAccounts(
                new Map<Id, String>{ String.valueOf(workOrderId) => String.valueOf(account) }
            );
    }
}