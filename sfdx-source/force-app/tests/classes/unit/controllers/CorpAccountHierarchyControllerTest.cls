@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts,PMD.UnusedLocalVariable')
private class CorpAccountHierarchyControllerTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String CONTRACT_NAME = 'Test Contract';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_NAME_TEST1 = 'Test Account 1';
    private static final String ACCOUNT_NAME_TEST2 = 'Test Account 2';
    private static final String VERTICAL = 'Grocery';
    private static final String CHILD_ACCOUNT ='Test Child 2';
    private static final String CORE_CATEGORY = 'Core';
    private static final String VALUES_DOES_NOT_MATCH = 'Unexpected result: The value does not match';
    private static final String LIST_SIZE_DOES_NOT_MATCH ='Unexpected result: The list size does not match';
    private static final String ACTIVE ='Active';
    private static final String SMB ='SMB';
    private static final String MDS ='MDS';

    @isTest
    private static void testWhenUltimateAccountIdPassedThenReturnUltimateParentAccount() {
        String ultimateParentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake ultimateParentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                'Rx',
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, ultimateParentAccountId)
            .setField(Account.BillingCountryCode, 'AU')
            .setField(Account.BillingStateCode, 'QLD')
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account ultimateParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            ultimateParentAccountFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.getUltimateParentAccount(
                    new Set<String>{ ultimateParentAccountId }
                )
            )
            .thenReturn(new List<Account>{ ultimateParentAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelector);
        CorporateAccountHierarchyController.getUltimateParentAccount(ultimateParentAccountId);
        ((IAccountsSelector) mocks.verify(accountsSelector, 1))
            .getUltimateParentAccount(new Set<String>{ ultimateParentAccountId });
    }

    @isTest
    private static void testWhenAccountIdPassedThenReturnUltimateParentAccount() {
        String ultimateParentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake ultimateParentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                'Rx',
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, ultimateParentAccountId)
            .setField(Account.BillingCountryCode, 'AU')
            .setField(Account.BillingStateCode, 'QLD')
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account ultimateParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            ultimateParentAccountFakeInstance
        );
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                'Rx',
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, 'AU')
            .setField(Account.BillingStateCode, 'QLD')
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(Account.Ultimate_Parent_Account__c, ultimateParentAccountId)
            .setParent('Ultimate_Parent_Account__r', ultimateParentAccountFakeInstance);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.getUltimateParentAccount(new Set<String>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(
                accountsSelector.getUltimateParentAccount(
                    new Set<String>{ ultimateParentAccountId }
                )
            )
            .thenReturn(new List<Account>{ ultimateParentAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelector);
        CorporateAccountHierarchyController.getUltimateParentAccount(businessAccountId);
        ((IAccountsSelector) mocks.verify(accountsSelector, 1))
            .getUltimateParentAccount(new Set<String>{ ultimateParentAccountId });
    }

    /**
     * @description To test get child accounts for corporate account hierarchy
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingCorporateChildAccountsDetailsThenAccountRecordsWithTheCorrectFieldsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);
        Id storeId = Fake.generateId(Account.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id businessId = Fake.generateId(Account.class);
        Id businessId1 = Fake.generateId(Account.class);
        Id agreementId = Fake.generateId(Agreement__c.class);
        Id contractId = Fake.generateId(Contract.class);

        List<Account> returnedAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId)
                .setField(Account.Name, 'Test Account 1')
                .setField(Account.ParentId, parentId1)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId1)
                .setField(Account.Name, 'Test Account 2')
                .setField(Account.ParentId, parentId2)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject()
        };

        Fake storeFakeInstance = new Fake(Account.class)
            .setField(Account.Id, storeId)
            .setField(Account.Name, 'Test Child 2')
            .setField(Account.ParentId, parentId2)
            .setField(Account.REcordTypeId, storeRecordTypeId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Id, storeRecordTypeId)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_STORE)
            );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Name, CONTRACT_NAME)
            .setField(Contract.Contract_Split_Category__c, CORE_CATEGORY)
            .setField(Contract.Status, ACTIVE)
            .setParent(
                        'Account',
                        new Fake(Account.class)
                        .setField(Account.Id, storeId)
            );
            
        List<Xref__c> newXref = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xrefId)
                .setField(Xref__c.External_ID_Source__c, 'MDS')
                .setField(Xref__c.Xref_Status__c, ACTIVE)
                .setField(Xref__c.Salesforce_Account_Name__c, businessRecordTypeId)
                .setParent(
                    'Salesforce_Account_Name__r',
                    storeFakeInstance.setField(Account.ParentId, parentId2)
                        .setParent(
                            'Parent',
                            new Fake(Account.class).setField(Account.Id, parentId2)
                        )
                )
                .toSObject()
        };
		
        List<Agreement__c> newAgreement = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Id, agreementId)
                .setField(Agreement__c.Status__c, ACTIVE)
                .setField(Agreement__c.Account__c, storeId)
                .setField(Agreement__c.Contract__c, contractId)
                .setParent(
                    'Account__r',
                    storeFakeInstance.setField(Account.ParentId, parentId2)
                        .setParent(
                            'Parent',
                            new Fake(Account.class)
                            .setField(Account.Id, parentId2)
                            .setField(Account.RecordType.Id, storeRecordTypeId)
                    		.setField(Account.Segment__c, SMB)
                            .setField(Account.RecordType.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
                        )
                )
                .setParent(
                        'Contract__r',
                        new Fake(Contract.class)
                            .setField(Contract.Contract_Split_Category__c, CORE_CATEGORY)
                            .setField(Contract.Name, CONTRACT_NAME)
                            .setField(Contract.Id, contractId)
                            .setField(Contract.Status, ACTIVE)
                            .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                 )
                .toSObject()
        };
        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'RecordType.developerName',
            'Name'
        };

        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(childAccountFields);
        List<CorporateAccountHierarchyController.BusinessAccount> businessAccountsInfo = new List<CorporateAccountHierarchyController.BusinessAccount>();
        businessAccountsInfo.add(
            new CorporateAccountHierarchyController.BusinessAccount(returnedAccounts[0])
        );
        businessAccountsInfo.add(
            new CorporateAccountHierarchyController.BusinessAccount(new CorporateAccountHierarchyController.storeAccount(newXref[0],new List<Contract>{}))
        );

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractsSelector contractSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IPaymentAccountsSelector paymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.getCorporateAccountHierarchyByUltimateParentAccount(
                    fieldsToQuery,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.when(contractSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(paymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectByStoreAccounts(new Set<Id>{ parentId1, parentId2 }))
            .thenReturn(newXref);
        
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectActiveAgreementsAndCoreContractsByStoreAccountIds(new Set<Id>{ storeId }))
            .thenReturn(newAgreement);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(paymentAccountsSelector);
        Application.SELECTOR.setMock(contractSelector);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Test.startTest();
        List<CorporateAccountHierarchyController.BusinessAccount> retrievedChildAccounts = CorporateAccountHierarchyController.getChildAccounts(
            accountIds,
            null,
            null,
            null
        );
        Test.stopTest();
        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .getCorporateAccountHierarchyByUltimateParentAccount(fieldsToQuery, accountIds);
        System.assertEquals(3, retrievedChildAccounts.size(), LIST_SIZE_DOES_NOT_MATCH);
        System.assertEquals(
            retrievedChildAccounts[0].businessAccount.Name,
            'Test Account 1',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[0].businessAccount.ParentId,
            parentId1,
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].businessAccount.Name,
            'Test Account 2',
            'The value does not match'
        );
        System.assertEquals(
            retrievedChildAccounts[1].businessAccount.ParentId,
            parentId2,
            'The value does not match'
        );
    }

    /**
     * @description To test get child accounts for corporate account hierarchy
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingCorporateChildAccountsDetailsThenExceptionReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);
        Id storeId = Fake.generateId(Account.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id businessId = Fake.generateId(Account.class);
        Id businessId1 = Fake.generateId(Account.class);

        List<Account> returnedAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId)
                .setField(Account.Name, ACCOUNT_RECORD_TYPE_NAME_STORE)
                .setField(Account.ParentId, parentId1)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId1)
                .setField(Account.Name, ACCOUNT_RECORD_TYPE_NAME_STORE)
                .setField(Account.ParentId, parentId2)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject()
        };

        Fake storeFakeInstance = new Fake(Account.class)
            .setField(Account.Id, storeId)
            .setField(Account.Name, CHILD_ACCOUNT)
            .setField(Account.ParentId, parentId2)
            .setField(Account.REcordTypeId, storeRecordTypeId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Id, storeRecordTypeId)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_STORE)
            );
        List<Xref__c> newXref = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xrefId)
                .setField(Xref__c.External_ID_Source__c, MDS)
                .setField(Xref__c.Xref_Status__c, ACTIVE)
                .setField(Xref__c.Salesforce_Account_Name__c, businessRecordTypeId)
                .setParent(
                    'Salesforce_Account_Name__r',
                    storeFakeInstance.setField(Account.ParentId, parentId2)
                        .setParent(
                            'Parent',
                            new Fake(Account.class).setField(Account.Id, parentId2)
                        )
                )
                .toSObject()
        };

        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'RecordType.developerName',
            'Name'
        };

        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(childAccountFields);
        List<CorporateAccountHierarchyController.BusinessAccount> businessAccountsInfo = new List<CorporateAccountHierarchyController.BusinessAccount>();
        businessAccountsInfo.add(
            new CorporateAccountHierarchyController.BusinessAccount(returnedAccounts[0])
        );

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractsSelector contractSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IPaymentAccountsSelector paymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.getCorporateAccountHierarchyByUltimateParentAccount(
                    fieldsToQuery,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.when(contractSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(paymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectByStoreAccounts(new Set<Id>{ parentId2 }))
            .thenReturn(newXref);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(paymentAccountsSelector);
        Application.SELECTOR.setMock(contractSelector);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Test.startTest();
        try {
            List<CorporateAccountHierarchyController.BusinessAccount> retrievedChildAccounts = CorporateAccountHierarchyController.getChildAccounts(
                accountIds,
                'No Fills',
                'Grocery',
                'MDS'
            );
        } catch (Exception ex) {
            System.assertEquals(
                System.Label.Failed_Retrieve_Child_Accounts,
                ex.getMessage(),
                'The error message does not match'
            );
        }
    }

    /**
     * @description To test get selected account method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingTheAccountDetailsThenAccountRecordsWithTheCorrectFieldsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
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
        Set<String> fieldsToQuery = new Set<String>();
        List<String> selectedAccountsFields = new List<String>{
            'Id',
            'RecordType.DeveloperName',
            'ParentId',
            'Parent.ParentId',
            'Parent.Parent.ParentId',
            'Parent.Parent.Parent.ParentId',
            'Ultimate_Parent_Account__c'
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
        List<Account> selectedAccount = CorporateAccountHierarchyController.getAccountDetails(
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
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .getRecordTypeId();

        Id parentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId
            )
        };
        Set<String> fieldsToQuery = new Set<String>();
        List<String> selectedAccountsFields = new List<String>{
            'Id',
            'RecordType.DeveloperName',
            'ParentId',
            'Parent.ParentId',
            'Parent.Parent.ParentId',
            'Parent.Parent.Parent.ParentId',
            'Ultimate_Parent_Account__c'
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
            CorporateAccountHierarchyController.getAccountDetails(newAccounts[0].Id);
        } catch (Exception ex) {
            System.assertEquals(
                System.Label.Failed_Retrieve_Account,
                ex.getMessage(),
                'The error message does not match'
            );
        }
    }

    /**
     * @description To test filtered records retrieved when search keys passed.
     */
    @isTest
    private static void testWhenRequestingBrandsAndVerticalsThenAccountRecordsWithTheMatchingBrandsAndVerticalsAreReturned() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id ultimateParentId = Fake.generateId(Account.class);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId();
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                ultimateParentId,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Brand__r', brandFakeInstance);
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID_Source__c, MDS)
            .setField(Xref__c.Xref_Status__c, ACTIVE)
            .setField(Xref__c.External_ID__c, '12345')
            .setField(Xref__c.Id, xrefId)
            .setParent('Salesforce_Account_Name__r', childAccountFakeInstance)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        XrefsSelector xrefSelectorMock = (XrefsSelector) mocks.mock(XrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectByUltimateParentAccountsForBrandsAndVerticals(
                    new Set<Id>{ ultimateParentId }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefSelectorMock);
        List<CorporateAccountHierarchyController.FilterCriteria> filteredData = CorporateAccountHierarchyController.getBrandsAndVerticals(
            ultimateParentId
        );

        ((IXrefsSelector) mocks.verify(xrefSelectorMock, 1))
            .selectByUltimateParentAccountsForBrandsAndVerticals(new Set<Id>{ ultimateParentId });
        System.assertEquals(1, filteredData.size(), 'The list size does not match');
    }
    
    /**
     * @description To test get child accounts for corporate account hierarchy.
     */
    @IsTest
    private static void testWhenRequestingCorporateChildAccountsDetailsThenAccountRecordsWithTheCoreContractsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
            .getRecordTypeId();

        Id parentId1 = Fake.generateId(Account.class);
        Id parentId2 = Fake.generateId(Account.class);
        Id storeId = Fake.generateId(Account.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id businessId = Fake.generateId(Account.class);
        Id businessId1 = Fake.generateId(Account.class);
        Id agreementId = Fake.generateId(Agreement__c.class);
        Id contractId = Fake.generateId(Contract.class);

        List<Account> returnedAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId)
                .setField(Account.Name, ACCOUNT_NAME_TEST1)
                .setField(Account.ParentId, parentId1)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Id, businessId1)
                .setField(Account.Name, ACCOUNT_NAME_TEST2)
                .setField(Account.ParentId, parentId2)
                .setField(Account.REcordTypeId, businessRecordTypeId)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, businessRecordTypeId)
                        .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                )
                .toSObject()
        };

        Fake storeFakeInstance = new Fake(Account.class)
            .setField(Account.Id, storeId)
            .setField(Account.Name, CHILD_ACCOUNT)
            .setField(Account.ParentId, parentId2)
            .setField(Account.REcordTypeId, storeRecordTypeId)
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Id, storeRecordTypeId)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_STORE)
            );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Name, CONTRACT_NAME)
            .setField(Contract.Contract_Split_Category__c, CORE_CATEGORY)
            .setField(Contract.Status, ACTIVE)
            .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeId)
            );
            
        List<Xref__c> newXref = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xrefId)
                .setField(Xref__c.External_ID_Source__c, MDS)
                .setField(Xref__c.Xref_Status__c, ACTIVE)
                .setField(Xref__c.Salesforce_Account_Name__c, businessRecordTypeId)
                .setParent(
                    'Salesforce_Account_Name__r',
                    storeFakeInstance.setField(Account.ParentId, parentId2)
                        .setParent(
                            'Parent',
                            new Fake(Account.class).setField(Account.Id, parentId2)
                        )
                )
                .toSObject()
        };
		
        List<Agreement__c> newAgreement = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Id, agreementId)
                .setField(Agreement__c.Status__c, ACTIVE)
                .setField(Agreement__c.Account__c, storeId)
                .setField(Agreement__c.Contract__c, contractId)
                .setParent(
                    'Account__r',
                    storeFakeInstance.setField(Account.ParentId, parentId2)
                        .setParent(
                            'Parent',
                            new Fake(Account.class)
                            .setField(Account.Id, parentId2)
                            .setField(Account.RecordType.Id, storeRecordTypeId)
                    		.setField(Account.Segment__c, SMB)
                            .setField(Account.RecordType.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
                        )
                )
                .setParent(
                        'Contract__r',
                        new Fake(Contract.class)
                            .setField(Contract.Contract_Split_Category__c, CORE_CATEGORY)
                            .setField(Contract.Name, CONTRACT_NAME)
                            .setField(Contract.Id, contractId)
                            .setField(Contract.Status, ACTIVE)
                            .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                 )
                .toSObject()
        };
        List<String> childAccountFields = new List<String>{
            'Id',
            'ParentId',
            'RecordType.developerName',
            'Name'
        };

        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(childAccountFields);
        List<CorporateAccountHierarchyController.BusinessAccount> businessAccountsInfo = new List<CorporateAccountHierarchyController.BusinessAccount>();
        businessAccountsInfo.add(
            new CorporateAccountHierarchyController.BusinessAccount(returnedAccounts[0])
        );
        businessAccountsInfo.add(
            new CorporateAccountHierarchyController.BusinessAccount(new CorporateAccountHierarchyController.StoreAccount(newXref[0],new List<Contract>{}))
        );

        List<Id> accountIds = new List<Id>{ parentId1, parentId2 };

        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractsSelector contractSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IPaymentAccountsSelector paymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.getCorporateAccountHierarchyByUltimateParentAccount(
                    fieldsToQuery,
                    accountIds
                )
            )
            .thenReturn(returnedAccounts);
        mocks.when(contractSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(paymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectByStoreAccounts(new Set<Id>{ parentId1, parentId2 }))
            .thenReturn(newXref);
        mocks.when(xrefsSelectorMock.selectByStoreAccountsAndOtherFilters(new Set<Id>{parentId1, parentId2 }, null))
            .thenReturn(newXref);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(paymentAccountsSelector);
        Application.SELECTOR.setMock(contractSelector);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Test.startTest();
        List<CorporateAccountHierarchyController.BusinessAccount> retrievedChildAccounts = CorporateAccountHierarchyController.getChildAccounts(
            accountIds,
            null,
            null,
            null
        );
        Test.stopTest();
        ((IAccountsSelector) mocks.verify(selectorMock, 1))
            .getCorporateAccountHierarchyByUltimateParentAccount(fieldsToQuery, accountIds);
        System.assertEquals(3, retrievedChildAccounts.size(), LIST_SIZE_DOES_NOT_MATCH);
        System.assertEquals(
            retrievedChildAccounts[0].businessAccount.Name,
            ACCOUNT_NAME_TEST1,
            VALUES_DOES_NOT_MATCH
        );
        System.assertEquals(
            retrievedChildAccounts[0].businessAccount.ParentId,
            parentId1,
            VALUES_DOES_NOT_MATCH
        );
        System.assertEquals(
            retrievedChildAccounts[1].businessAccount.Name,
            ACCOUNT_NAME_TEST2,
            VALUES_DOES_NOT_MATCH
        );
        System.assertEquals(
            retrievedChildAccounts[1].businessAccount.ParentId,
            parentId2,
            VALUES_DOES_NOT_MATCH
        );
    }

}