/**
 * @author ATG
 * @date 2022-04-11
 * @description This is test class for Quotes class
 */
@isTest(seeAllData=false)
public class ContractsTest {
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String ASSERT_MESSAGE = 'Unexpected result: There is a mismatch in Contracts data';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String SSMO = 'SSMO';
    private static final String SSOB = 'SSOB';
    private static final String CORE = 'Core';
    private static final String ADS_PROMO = 'A&P';
    private static final Boolean ADS_PROMO_APPLICABILITY = true;
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final String STORE_ACCOUNT_NAME = 'Los Pinchos de mi Abuela Store';
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String QUOTE_SEGMENT_SMB = 'SMB';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    /**
     * @description To test activate call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractUpdatedThenActivate() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractId2 = Fake.generateId(Contract.class);

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, Status = 'Draft'),
            new Contract(Id = contractId2, Status = 'Draft')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IContracts contractInstance = Contracts.newInstance(contractList);

        contractInstance.activate();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Contract.Id => contractId,
                        Contract.Status => Contracts.ACTIVATED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Contract.Id => contractId2,
                        Contract.Status => Contracts.ACTIVATED
                    }
                )
            );
    }

    /**
     * @description To test setAssociatedAccounts call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractCalledThenSetAssociatedAccounts() {
        Id contractId = Fake.generateId(Contract.class);

        Id accountId = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id accountId4 = Fake.generateId(Account.class);
        Id quoteLineGroup1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id quoteLineGroup2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id productId1 = fflib_IDGenerator.generate(Product2.SObjectType);

        SBQQ__Subscription__c mockSubscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productId1)
                    .setField(Product2.Name, 'Marketplace')
            )
            .toSObject();

        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id productId2 = fflib_IDGenerator.generate(Product2.SObjectType);
        SBQQ__Subscription__c mockSubscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Delivery')
            .setField(SBQQ__Subscription__c.Package__c, productId1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productId2)
                    .setField(Product2.Name, 'Delivery')
            )
            .toSObject();

        String productName = mockSubscription1.SBQQ__ProductName__c;
        Id productId = mockSubscription1.Id;
        String packageName = mockSubscription2.SBQQ__ProductName__c;
        Id packageId = mockSubscription2.Id;

        List<String> productDeselected = new List<String>{ productId };

        String accountIdsString1 = String.valueOf(accountId) + ',' + String.valueOf(accountId2);
        String accountIdsString2 = String.valueOf(accountId3) + ',' + String.valueOf(accountId4);
        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, Status = 'Draft')
        };

        AssociatedAccountsWrapper.ProductSubId productSubWrap = new AssociatedAccountsWrapper.ProductSubId(
            productId,
            productName
        );
        List<AssociatedAccountsWrapper.ProductSubId> productSubIdList = new List<AssociatedAccountsWrapper.ProductSubId>{
            productSubWrap
        };
        AssociatedAccountsWrapper.SelectedPackage selectedWrapper = new AssociatedAccountsWrapper.SelectedPackage(
            packageId,
            packageName,
            productSubIdList
        );
        AssociatedAccountsWrapper.DeselectedPackage deselectedWrapper = new AssociatedAccountsWrapper.DeselectedPackage(
            packageId,
            productDeselected
        );

        List<AssociatedAccountsWrapper.SelectedPackage> selectedList = new List<AssociatedAccountsWrapper.SelectedPackage>();
        selectedList.add(selectedWrapper);
        List<AssociatedAccountsWrapper.DeselectedPackage> deselectedList = new List<AssociatedAccountsWrapper.DeselectedPackage>();
        deselectedList.add(deselectedWrapper);

        AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements selectedAndDeselectedEntitlements = new AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements(
            selectedList,
            deselectedList
        );

        List<AssociatedAccountsWrapper> associatedAccountsWrapperList = new List<AssociatedAccountsWrapper>();
        AssociatedAccountsWrapper aaw1 = new AssociatedAccountsWrapper(
            quoteLineGroup1,
            accountIdsString1,
            contractId,
            true,
            selectedAndDeselectedEntitlements
        );

        AssociatedAccountsWrapper aaw2 = new AssociatedAccountsWrapper(
            quoteLineGroup2,
            accountIdsString2,
            contractId,
            true,
            selectedAndDeselectedEntitlements
        );

        associatedAccountsWrapperList.add(aaw1);
        associatedAccountsWrapperList.add(aaw2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IContracts contractInstance = Contracts.newInstance(contractList);

        contractInstance.setAssociatedAccountsWithGroups(associatedAccountsWrapperList, true, 'No');

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test setQuotesFieldsOnContract call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractInsertedThenSetQuoteFields() {
        Id contractId = Fake.generateId(Contract.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        List<Contract> contractList = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, contractId)
                .setField(Contract.SBQQ__Quote__c, quoteId)
                .toSobject()
        };

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.Id, quoteId)
                .setField(SBQQ__Quote__c.Franchise_Supplemental_Agreement_Link__c, 'FSA')
                .setField(SBQQ__Quote__c.Signed_Contract_link__c, 'MSA')
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectById(new Set<Id>{ quoteId })).thenReturn(quoteList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quotesSelectorMock);
        //Act
        Contracts.newInstance(contractList).setQuotesFieldsOnContract();
        //Assert
        System.assertEquals(
            contractList[0].Franchise_Supplemental_Agreement_URL__c,
            'FSA',
            'Contracts field missmatch'
        );
        System.assertEquals(
            contractList[0].Master_Supplemental_Agreement_URL__c,
            'MSA',
            'Contracts field missmatch'
        );
    }

    /**
     * @description To test Contract Trigger
     */
    @isTest
    private static void testWhenContractInsertedThenRun() {
        Account acc = new Account(
            Name = 'Test 1',
            Segment__c = 'SMB',
            BillingCountry = 'United States',
            Legal_Business_Name__c = 'Test',
            Primary_Vertical__c = 'Rx'
        );
        insert acc;

        Contract contract = new Contract(AccountId = acc.Id);
        insert contract;
        System.assertNotEquals(null, contract.Id, 'Id is null');
    }

    /**
     * @description To test notifier event is published when Withholding Opt-out
     * Franchise Form Request gets approved.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOrderIdChangedOnContractAmendmentThenUpdateNotifierEventPublished() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id corporateAccountId = Fake.generateId(Account.class);
        Id orderIdNew = Fake.generateId(Order.class);
        Id orderIdOld = Fake.generateId(Order.class);

        Fake oldContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Order__c, orderIdOld)
            .setField(Contract.MP_Bz_Id__c, '1234')
            .setField(Contract.Payment_Method__c, 'Invoicing');
        Contract oldContract = (Contract) oldContractFakeInstance.toSObject();
        List<Contract> oldContractList = new List<Contract>();
        oldContractList.add(oldContract);

        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Order__c, orderIdNew)
            .setField(Contract.MP_Bz_Id__c, '1234')
            .setField(Contract.Payment_Method__c, 'Withholding');
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        INotifierEventsService notifierEventsServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        Application.Domain.setMock(contractsMock);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventsServiceMock);

        Test.startTest();
        Contracts.newInstance(newContractList)
            .publishNotifierEventsOnWithholdingAmendment(new Map<Id, Contract>(oldContractList));
        Test.stopTest();

        ((INotifierEventsService) mocks.verify(notifierEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING => new List<String>{
                        JSON.serialize(new List<Id>{ corporateAccountId })
                    }
                }
            );
    }

    /**
     * @description To test notifier event is published when Withholding Opt-out
     * Franchise Form Request gets approved.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMpBzIdIsChangedFromBlankToAValueThenUpdateNotifierEventPublished() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id corporateAccountId = Fake.generateId(Account.class);
        Id orderIdNew = Fake.generateId(Order.class);
        Id orderIdOld = Fake.generateId(Order.class);

        Fake oldContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Order__c, orderIdOld)
            .setField(Contract.MP_Bz_Id__c, null)
            .setField(Contract.Payment_Method__c, 'Withholding');
        Contract oldContract = (Contract) oldContractFakeInstance.toSObject();
        List<Contract> oldContractList = new List<Contract>();
        oldContractList.add(oldContract);

        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Order__c, orderIdNew)
            .setField(Contract.MP_Bz_Id__c, '1234')
            .setField(Contract.Payment_Method__c, 'Withholding');
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        INotifierEventsService notifierEventsServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        Application.Domain.setMock(contractsMock);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventsServiceMock);

        Test.startTest();
        Contracts.newInstance(newContractList)
            .publishNotifierEventsOnWithholdingAmendment(new Map<Id, Contract>(oldContractList));
        Test.stopTest();

        ((INotifierEventsService) mocks.verify(notifierEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING => new List<String>{
                        JSON.serialize(new List<Id>{ corporateAccountId })
                    }
                }
            );
    }
    /**
     * @description To validate if the contract term of activated Ads and Promos contracts
     * are left blank.
     */
    /*@isTest
    private static void testWhenAdsPromoContractIsActivatedThenBlankOutContractTerms() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id orderId = Fake.generateId(Order.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, quoteId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.SBQQ__Quote__c, contractId)
            .setField(Contract.status, contractId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.Contract_Split_Category__c, System.Label.SplitCategoryAandP);
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        Application.Domain.setMock(contractsMock);
        Contracts.newInstance(newContractList).blankOutContractTermForAdsAndPromos();
        System.assertEquals(2, newContractList[0].ContractTerm, ASSERT_MESSAGE);
    }*/

    /**
     * @description To validate if the contract term of Draft Ads and Promos contracts
     *  are populated.
     */
    /*@isTest
    private static void testWhenAdsPromoContractIsNotActivatedThenDoNotBlankOutContractTerms() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id orderId = Fake.generateId(Order.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, quoteId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.SBQQ__Quote__c, contractId)
            .setField(Contract.status, contractId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, System.Label.SplitCategoryAandP);
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContracts contractsMock = (IContracts) mocks.mock(IContracts.class);
        Application.Domain.setMock(contractsMock);
        Contracts.newInstance(newContractList).blankOutContractTermForAdsAndPromos();
        System.assertEquals(2, newContractList[0].ContractTerm, ASSERT_MESSAGE);
    }*/

    /**
     * @description It is used to validate when the contract is activated then store agreements
     * creation initiated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractActivatedThenStoreAgreementCreationInitiated() {
        String externalId1 = 'test-store-1';
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Fake testFakeAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID);

        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Contract.Integration_Source__c, SSMO)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.Store_Id__c, externalId1);

        Fake newXrefInstance = new Fake(Xref__c.class)
            .setField(Xref__c.External_ID__c, externalId1)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.Id, xrefId);
        Xref__c newXref = (Xref__c) newXrefInstance.toSObject();
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        Account testAccount = (Account) testFakeAccount.toSObject();
        Account testChildAccount = (Account) testFakeAccount.toSObject();

        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectChildAccountsByCorporateOrFranchiseParent(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{ testAccount });
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                xrefSelectorMock.selectXrefByExternalIdOnly(
                    new List<String>{ externalId1}
                )
            )
            .thenReturn(new List<Xref__c>{ newXref});
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ testChildAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        Contracts.newInstance(newContractList).initiateSSMOStoreAgreementCreationOnContracts();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To validate When the contract is activated then business agreements creation initiated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractActivatedThenBusinessAgreementCreationInitiated() {
        Id contractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Fake testFakeAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Fake parentFakeAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Fake newContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Contract.Integration_Source__c, SSOB)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId);
        Contract newContract = (Contract) newContractFakeInstance.toSObject();
        Account testAccount = (Account) testFakeAccount.toSObject();
        Account testParentAccount = (Account) parentFakeAccount.toSObject();

        List<Contract> newContractList = new List<Contract>();
        newContractList.add(newContract);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectChildAccountsByCorporateOrFranchiseParent(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{ testAccount });
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ testParentAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        Contracts.newInstance(newContractList).initiateSSMOStoreAgreementCreationOnContracts();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description It test if the Ads and Promo Contract with a related Opportunity (new or existing) is activated, then auto-associates stores.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAdsPromoContractActivatedThenAssociateStores() {
        Id contractId = Fake.generateId(Contract.class);
        Id coreContractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);

        Fake storeAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, businessAccountId);

        Fake coreContractInstance = new Fake(Contract.class)
            .setField(Contract.Id, coreContractId)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Contract_Split_Category__c, CORE);

        Contract coreContract = (Contract) coreContractInstance.toSObject();

        Contract adsAndPromContractInstance = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Ads_Promo_Applicability__c, ADS_PROMO_APPLICABILITY)
            .setField(Contract.Has_Store_Count_Changed_On_Amendment__c, ADS_PROMO_APPLICABILITY)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Contract_Split_Category__c, ADS_PROMO)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .toSObject();
        Agreement__c coreAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, Fake.generateId(Agreement__c.class))
            .setField(Agreement__c.Contract__c, coreContractId)
            .setField(Agreement__c.Account__c, storeAccountId)
            .setParent('Contract__r', coreContractInstance)
            .setParent('Account__r', storeAccount)
            .toSObject();

        List<Contract> newContractList = new List<Contract>();
        newContractList.add(adsAndPromContractInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectCoreContractsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Contract>{ coreContract });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByCoreContractIds(
                    new Set<Id>{ coreContractId }
                )
            )
            .thenReturn(new List<Agreement__c>{ coreAgreement });
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAdsPromosContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<Agreement__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        Contracts.newInstance(newContractList)
            .initiateAdsAndPromoStoreAgreementsCreationOnContracts();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description It checks if the Ads and Promo Contract linked to an Opportunity (neither new nor existing) is activated. If it is, then stores are not automatically associated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractWithNonNewOpportunityActivatedThenNoContractAssociation() {
        Id contractId = Fake.generateId(Contract.class);
        Id businessAccountId = Fake.generateId(Account.class);

        Contract adsAndPromContractInstance = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Contract_Split_Category__c, ADS_PROMO)
            .toSObject();

        List<Contract> newContractList = new List<Contract>();
        newContractList.add(adsAndPromContractInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        Contracts.newInstance(newContractList)
            .initiateAdsAndPromoStoreAgreementsCreationOnContracts();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}