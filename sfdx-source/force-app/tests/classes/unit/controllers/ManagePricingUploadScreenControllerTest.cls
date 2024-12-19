/**
 * @description This is a test class created to test the Manage Pricing Upload Screen Controller
 * @author deloitte
 * @date 27/03/2024
 */
@isTest(SeeAllData=false)
private class ManagePricingUploadScreenControllerTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_CHANNEL_PARTNER = 'Channel_Partner';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_STORE_AGREEMENT = 'Store Agreement';

    @isTest
    private static void testWhenUploadedAccountWithoutActiveAgreementThenThrowException() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);

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
                    .setField(Account.Record_Type_Name__c, ManagePricingUploadScreenController.ACCOUNT_RECORDTYPE_BUSINESS)
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
            ManagePricingUploadScreenController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(
            exceptionMessage.startsWith(ManagePricingUploadScreenController.ACCOUNT_WITHOUT_AGREEMENT_EXCEPTION),
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
        Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Id fakeAgreementId4 = Fake.generateId(Agreement__c.class);
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

        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId1)
            .setField(Agreement__c.Contract__c, contractId)
            .toSObject();

        Agreement__c fakeAgreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId2)
            .setField(Agreement__c.Contract__c, contractId)
            .toSObject();

        Agreement__c fakeAgreement5 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Contract__c, contractId)
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
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });
        mocks.when(
                accountSelectorMock.selectAccountsWithParentDetailsById(
                    new Set<Id>{ accountId1, accountId2, accountId3 }
                )
            )
            .thenReturn(new List<Account>{ fakeAccount1, fakeAccount2, fakeAccount3 });
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAccountContractIds(
                    new Set<Id>{ accountId1, accountId2, accountId3 }, contractId
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3, fakeAgreement4, fakeAgreement5 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId1),
            String.valueOf(accountId2),
            String.valueOf(accountId3)
        };
        String exceptionMessage = '';
        try {
            ManagePricingUploadScreenController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
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
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
		Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Id fakeAgreementId4 = Fake.generateId(Agreement__c.class);
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        String externalId1 = 'test-store-1';
        String externalId2 = 'test-store-2';

        Set<Id> accountIdSet = new Set<Id>{ accountId3, accountId4 };

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, contractingAccountId)
                    .setField(Account.Record_Type_Name__c, ManagePricingUploadScreenController.ACCOUNT_RECORDTYPE_BUSINESS)
            )
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

        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Contract__c, contractId)
            .toSObject();

        Agreement__c fakeAgreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId4)
            .setField(Agreement__c.Contract__c, contractId)
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
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
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
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAccountContractIds(
                    new Set<Id>{ accountId3, accountId4 }, contractId
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3, fakeAgreement4 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);

        List<Account> accountList = ManagePricingUploadScreenController.selectNonAssociatedAccountsByStoreId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId)
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
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);
		Id fakeAgreementId3 = Fake.generateId(Agreement__c.class);
        Id fakeAgreementId4 = Fake.generateId(Agreement__c.class);
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
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, contractingAccountId)
                    .setField(Account.Record_Type_Name__c, ManagePricingUploadScreenController.ACCOUNT_RECORDTYPE_BUSINESS)
            )
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

        Agreement__c fakeAgreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId3)
            .setField(Agreement__c.Name, 'Fake Agreement 3')
            .setField(Agreement__c.Account__c, accountId3)
            .setField(Agreement__c.Contract__c, contractId)
            .toSObject();

        Agreement__c fakeAgreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, fakeAgreementId4)
            .setField(Agreement__c.Name, 'Fake Agreement 4')
            .setField(Agreement__c.Account__c, accountId4)
            .setField(Agreement__c.Contract__c, contractId)
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
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
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
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAccountContractIds(
                    new Set<Id>{ accountId3, accountId4 }, contractId
                )
            )
            .thenReturn(new List<Agreement__c>{ fakeAgreement3, fakeAgreement4 });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);

        List<Account> accountList = ManagePricingUploadScreenController.selectNonAssociatedAccountsByBusinessId(
            new List<String>{ externalId1, externalId2 },
            String.valueOf(contractId)
        );

        System.assertEquals(accountList.size(), 2, 'The list should Contain 2 Accounts');
        System.assertEquals(accountList[0].Id, accountId3, 'AccountId3 should be returned');
        System.assertEquals(accountList[1].Id, accountId4, 'AccountId4 should be returned');
    }

    @isTest
    private static void testWhenUploadedBusinessAccountThenThrowExceptionForBusinessAccounts() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .setField(Account.ParentId, parentAccountId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Name, ManagePricingUploadScreenController.ACCOUNT_RECORDTYPE_BUSINESS)
            )
            .toSObject();

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, contractingAccountId)
                    .setField(Account.Record_Type_Name__c, ManagePricingUploadScreenController.ACCOUNT_RECORDTYPE_BUSINESS)
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
                    new Set<Id>{ accountId2}
                )
            )
            .thenReturn(new List<Account>{ fakeAccount2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<String> accountstoSearchList = new List<String>{
            String.valueOf(accountId2)
        };
        String exceptionMessage = '';
        try {
            ManagePricingUploadScreenController.selectNonAssociatedAccountsById(
                accountstoSearchList,
                String.valueOf(contractId)
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(
            exceptionMessage.startsWith(ManagePricingUploadScreenController.BUSINESS_ACCOUNT_EXCEPTION),
            'Exception Messages was not thrown as expected'
        );
    }
}