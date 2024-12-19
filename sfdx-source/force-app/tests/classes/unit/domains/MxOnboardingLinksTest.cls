/**
 * @author Deloitte
 * @date 04/07/2024
 * @description Test class for MxOnboardingLinks class.
 */
@isTest(seeAllData=false)
private class MxOnboardingLinksTest {
    private static final String CREATION_STATUS_SUCCESS = 'Success';
    private static final String CREATION_STATUS_WO_CREATION_SUCCESS = 'WO Creation Success';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String STORE_ACCOUNT_NAME = 'Los Pinchos de mi Abuela Store';
    private static final String CORE_TYPE = 'Core';
    private static final String A_P_TYPE = 'A&P';
    private static final String BUSINESS_ACCOUNT_NAME = 'Testing Business Accounts';
    private static final String MXSTORE_ACCOUNT_NAME = 'Testing Stores Accounts';
    private static final String ACCOUNT_TYPE = 'Corporate';
    private static final String ACCOUNT_PARTNERSHIP_STATUS_PROSPECTIVEPARTNER = 'Prospective Partner';
    private static final String ACCOUNT_LIFECYCLE_STATUS_UNVETTED = 'Unvetted';
    private static final String ACCOUNT_PRIMARYVERTICAL_CONVENIENCE = 'Convenience';
    private static final String ACCOUNT_BILLINGCOUNTRY = 'United States';
    private static final String ACCOUNT_BILLINGCITY = 'New York';
    private static final String ACCOUNT_BILLINGPOSTALCODE = 'lem990';
    private static final String ACCOUNT_BILLINGSTATE = 'New York';
    private static final String ACCOUNT_BILLINGSTREET = 'Test Street';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STORE_RECORD_TYPE_NAME = 'Store';
    private static final String AGREEMENTTYPE_STOREAGREEMENT = 'Store Agreement';
    private static final String ONBOARDING_SCENARIO_NEW_STORE_EXPANSION = 'NSE';
    private static final String MOCK_USER_EMAIL = 'mock@MxOnboardingLinksTest.com';
    private static final String MOCK_USER_FULL_NAME = 'Mock User';
    private static final String MXONBOARDINGLINKS_UUID = 'h123456c-595d-1234-99d8-3d8c931d9f82';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    /**
     * @description To test when Mx Onboarding Links are inserted then initaite Work Order
     * creation
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOnboardingLinksInsertedThenInitiateWorkOrderCreation() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Record_Creation_Status__c, CREATION_STATUS_SUCCESS)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        MxOnboardingLinks.newInstance(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake })
            .initiateWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(
                new Set<Id>{ mxOnboardingLinkId },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        Account parentAccount = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType));
        Mx_Onboarding_Link__c[] onboardingLinks = new List<Mx_Onboarding_Link__c>{
            new Mx_Onboarding_Link__c(
                Id = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType),
                Business_Account__c = parentAccount.Id,
                Record_Creation_Status__c = 'Success',
                Status__c = 'Active'
            )
        };

        //IProductInsights Instance Creation Call
        MxOnboardingLinks.newInstance(onboardingLinks);

        //Default Constructor Call
        MxOnboardingLinks onboardingLinksInstance = new MxOnboardingLinks(onboardingLinks);

        //fflib_IDomainConstructor Call
        MxOnboardingLinks.Constructor constructorObject = new MxOnboardingLinks.Constructor();

        constructorObject.construct(onboardingLinks);
        System.assertNotEquals(
            MxOnboardingLinks.newInstance(onboardingLinks),
            onboardingLinksInstance,
            'These obejct should not be similar'
        );
    }

    /**
     * @description To test Store Agreement creation when Record Creation Status of Mx Onboarding Link is Success
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingLinkActiveThenStoreAgreementCreationInitiated() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id apContractId = Fake.generateId(Contract.class);
        Id coreContractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId = Fake.generateId(Order.class);
        Id mxOnboardingLinkId = Fake.generateId(Mx_Onboarding_Link__c.class);
        String uuid = 'testuuid';

        Fake testFakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.parentId, businessAccountId)
            .setField(Account.Record_Type_Name__c, STORE_RECORD_TYPE_NAME);

        Fake testContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, CORE_TYPE);

        Fake testAPContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, apContractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, A_P_TYPE);

        Fake testMxOnboardingFakeInstance = new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
            .setField(Mx_Onboarding_Link__c.UUID__c, uuid)
            .setField(
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                CREATION_STATUS_WO_CREATION_SUCCESS
            );
        Agreement__c testAgreementFakeInstance1 = (Agreement__c) new Fake(Agreement__c.class)
            .setFakeId()
            .setField(Agreement__c.Name, MXSTORE_ACCOUNT_NAME)
            .setField(Agreement__c.Account__c, accountId2)
            .setField(Agreement__c.Contract__c, coreContractId)
            .setField(Agreement__c.Deactivation_Date__c, null)
            .setField(Agreement__c.Type__c, AGREEMENTTYPE_STOREAGREEMENT)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, '')
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId2)
                    .setField(Account.Franchise_Parent__c, '')
                    .setField(Account.Marketplace_Nintex_Id__c, '')
            )
            .setParent(
                'Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, coreContractId)
                    .setField(Contract.AccountId, businessAccountId)
                    .setField(Contract.SBQQ__Quote__c, quoteId)
                    .setField(Contract.SBQQ__Order__c, orderId)
                    .setField(Contract.SBQQ__Opportunity__c, opportunityId)
                    .setParent(
                        'SBQQ__Order__r',
                        new Fake(Order.class)
                            .setField(Order.Id, orderId)
                            .setField(Order.AccountId, businessAccountId)
                            .setField(Order.SBQQ__Quote__c, quoteId)
                            .setField(Order.OpportunityId, opportunityId)
                            .setParent(
                                'SBQQ__Quote__r',
                                new Fake(SBQQ__Quote__c.class)
                                    .setField(SBQQ__Quote__c.Id, quoteId)
                                    .setField(SBQQ__Quote__c.Segment__c, SEGMENT_SMB)
                                    .setParent(
                                        'SBQQ__Opportunity2__r',
                                        new Fake(Opportunity.class)
                                            .setField(Opportunity.Id, opportunityId)
                                            .setField(
                                                Opportunity.Owner_Full_Name__c,
                                                MOCK_USER_FULL_NAME
                                            )
                                            .setParent(
                                                'Owner',
                                                new Fake(User.class)
                                                    .setField(User.Email, MOCK_USER_EMAIL)
                                            )
                                    )
                            )
                    )
            )
            .toSobject();

        Contract newContractAccount = (Contract) testContractFakeInstance.toSObject();
        Contract newAPContractAccount = (Contract) testAPContractFakeInstance.toSObject();

        Account newStoreAccount = (Account) testFakeStoreAccount.toSObject();
        Mx_Onboarding_Link__c newMxOnboardingLink = (Mx_Onboarding_Link__c) testMxOnboardingFakeInstance.toSObject();

        List<Mx_Onboarding_Link__c> newMxOnboardingList = new List<Mx_Onboarding_Link__c>();
        newMxOnboardingList.add(newMxOnboardingLink);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAgreementsService agreementsServiceMock = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ newContractAccount });
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByQuoteIds(new Set<Id>{ quoteId })
            )
            .thenReturn(new List<Contract>{ newAPContractAccount });
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectChildAccounts(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ newStoreAccount });
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ newStoreAccount });
        mocks.when(accountSelectorMock.selectAccountsByMxOnboardingLinkIds(new Set<String>{ uuid }))
            .thenReturn(new List<Account>{ newStoreAccount });
        mocks.when(mxOnboardingLinksSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelector.selectById(new Set<Id>{ mxOnboardingLinkId }))
            .thenReturn(newMxOnboardingList);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Agreement__c>{ testAgreementFakeInstance1 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelector);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(IAgreementsService.class, agreementsServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MxOnboardingLinks.newInstance(newMxOnboardingList)
            .initiateStoreAgreementCreation(new Set<Id>{ mxOnboardingLinkId });
        Test.stopTest();
        ((IAgreementsService) mocks.verify(agreementsServiceMock, 1))
            .createAgreementsfromContractsWithGroup(
                (List<Contract>) fflib_Match.anyObject(),
                (Map<Id, Set<String>>) fflib_Match.anyObject(),
                (Map<Id, Map<Id, String>>) fflib_Match.anyObject()
            );
    }

    /**
     * @description To test No Agreement creation when Record Creation Status of Mx Onboarding Link is Success,
     * Onboarding Scenario is not Product Addition, and Store Agreement already exists
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingLinkSuccessThenNoStoreAgreementCreated() {
        Id coreContractId = Fake.generateId(Contract.class);
        Id apContractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id dupStoreAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId = Fake.generateId(Order.class);
        Id mxOnboardingId = Fake.generateId(Mx_Onboarding_Link__c.class);
        Id agreementId = Fake.generateId(Agreement__c.class);

        Fake testFakeBusinessAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Mx_Onboarding_Link_Id__c, MXONBOARDINGLINKS_UUID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS_PROSPECTIVEPARTNER)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS_UNVETTED)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARYVERTICAL_CONVENIENCE)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID);

        Fake testFakeDupStoreAccount = new Fake(Account.class)
            .setField(Account.Id, dupStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.parentId, businessAccountId)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS_PROSPECTIVEPARTNER)
            .setField(Account.BillingCountry, ACCOUNT_BILLINGCOUNTRY)
            .setField(Account.BillingCity, ACCOUNT_BILLINGCITY)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLINGPOSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLINGSTATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLINGSTREET)
            .setField(Account.Franchise_Parent__c, businessAccountId)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Record_Type_Name__c, STORE_RECORD_TYPE_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID);

        Fake testCoreContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, coreContractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, CORE_TYPE);

        Fake testAPContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, apContractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, A_P_TYPE);

        Fake testMxOnboardingFakeInstance = new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingId)
            .setField(Mx_Onboarding_Link__c.Contract__c, coreContractId)
            .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
            .setField(Mx_Onboarding_Link__c.UUID__c, MXONBOARDINGLINKS_UUID)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NEW_STORE_EXPANSION
            )
            .setField(
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                CREATION_STATUS_WO_CREATION_SUCCESS
            );

        Fake testAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, MXSTORE_ACCOUNT_NAME)
            .setField(Agreement__c.Account__c, dupStoreAccountId)
            .setField(Agreement__c.Contract__c, coreContractId)
            .setField(Agreement__c.Deactivation_Date__c, null)
            .setField(Agreement__c.Type__c, AGREEMENTTYPE_STOREAGREEMENT)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, '')
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, dupStoreAccountId)
                    .setField(Account.Franchise_Parent__c, '')
                    .setField(Account.Marketplace_Nintex_Id__c, '')
            )
            .setParent(
                'Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, coreContractId)
                    .setField(Contract.AccountId, businessAccountId)
                    .setField(Contract.SBQQ__Quote__c, quoteId)
                    .setField(Contract.SBQQ__Order__c, orderId)
                    .setField(Contract.SBQQ__Opportunity__c, opportunityId)
                    .setParent(
                        'SBQQ__Order__r',
                        new Fake(Order.class)
                            .setField(Order.Id, orderId)
                            .setField(Order.AccountId, businessAccountId)
                            .setField(Order.SBQQ__Quote__c, quoteId)
                            .setField(Order.OpportunityId, opportunityId)
                            .setParent(
                                'SBQQ__Quote__r',
                                new Fake(SBQQ__Quote__c.class)
                                    .setField(SBQQ__Quote__c.Id, quoteId)
                                    .setField(SBQQ__Quote__c.Segment__c, 'SMB')
                                    .setParent(
                                        'SBQQ__Opportunity2__r',
                                        new Fake(Opportunity.class)
                                            .setField(Opportunity.Id, opportunityId)
                                            .setField(Opportunity.Owner_Full_Name__c, 'Test User')
                                            .setParent(
                                                'Owner',
                                                new Fake(User.class)
                                                    .setField(User.Email, 'Testuser@test.com')
                                            )
                                    )
                            )
                    )
            );

        Contract newCoreContractAccount = (Contract) testCoreContractFakeInstance.toSObject();
        Contract newAPContractAccount = (Contract) testAPContractFakeInstance.toSObject();

        Account newDupStoreAccount = (Account) testFakeDupStoreAccount.toSObject();
        Account newBusinessAccount = (Account) testFakeBusinessAccount.toSObject();
        List<Account> newBusinessAccountsList = new List<Account>{ newBusinessAccount };
        List<Account> newStoreAccountsList = new List<Account>{ newDupStoreAccount };
        Mx_Onboarding_Link__c newMxOnboardingLink = (Mx_Onboarding_Link__c) testMxOnboardingFakeInstance.toSObject();

        Agreement__c existingAgreement = (Agreement__c) testAgreementFakeInstance.toSObject();

        List<Agreement__c> agreementsList = new List<Agreement__c>();
        agreementsList.add(existingAgreement);

        List<Mx_Onboarding_Link__c> newMxOnboardingList = new List<Mx_Onboarding_Link__c>();
        newMxOnboardingList.add(newMxOnboardingLink);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IAgreementsService agreementsServiceMock = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ coreContractId }))
            .thenReturn(new List<Contract>{ newCoreContractAccount });
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Contract>{ newAPContractAccount });
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ MXONBOARDINGLINKS_UUID }
                )
            )
            .thenReturn(newStoreAccountsList);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(newBusinessAccountsList);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ dupStoreAccountId }))
            .thenReturn(newStoreAccountsList);
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelectorMock.selectById(new Set<Id>{ mxOnboardingId }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ newMxOnboardingLink });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByAccountIds(
                    new Set<Id>{ dupStoreAccountId }
                )
            )
            .thenReturn(agreementsList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(IAgreementsService.class, agreementsServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MxOnboardingLinks.newInstance(newMxOnboardingList)
            .initiateStoreAgreementCreation(new Set<Id>{ mxOnboardingId });
        Test.stopTest();
    }

    /**
     * @description To test No Store Agreement creation when Record Creation Status of Mx Onboarding Link is Success
     * and Onboarding Scenario is Product Addition
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingLinkSuccessThenNoStoreAgreementCreationInitiated() {
        Id contractId = Fake.generateId(Contract.class);
        Id apContractId = Fake.generateId(Contract.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId = Fake.generateId(Order.class);
        Id mxOnboardingId = Fake.generateId(Mx_Onboarding_Link__c.class);
        String onboardingScenarioProductAddition = System.Label.OnboardingScenario_ProductAddition;

        Fake testFakeBusinessAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Mx_Onboarding_Link_Id__c, MXONBOARDINGLINKS_UUID)
            .setField(Account.RecordTypeId, BUSINESS_RECORD_TYPE_ID);

        Fake testFakeStoreAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.parentId, businessAccountId)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID);

        Fake testContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, CORE_TYPE);

        Fake testAPContractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, apContractId)
            .setField(Contract.ContractTerm, 2)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setField(Contract.Contract_Split_Category__c, A_P_TYPE);

        Fake testMxOnboardingFakeInstance = new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingId)
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
            .setField(Mx_Onboarding_Link__c.UUID__c, MXONBOARDINGLINKS_UUID)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                onboardingScenarioProductAddition
            )
            .setField(
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                CREATION_STATUS_WO_CREATION_SUCCESS
            );

        Contract newContractAccount = (Contract) testContractFakeInstance.toSObject();
        Contract newAPContractAccount = (Contract) testAPContractFakeInstance.toSObject();

        Account newStoreAccount = (Account) testFakeStoreAccount.toSObject();
        Account newBusinessAccount = (Account) testFakeBusinessAccount.toSObject();
        List<Account> newBusinessAccountsList = new List<Account>{ newBusinessAccount };
        Mx_Onboarding_Link__c newMxOnboardingLink = (Mx_Onboarding_Link__c) testMxOnboardingFakeInstance.toSObject();

        List<Mx_Onboarding_Link__c> newMxOnboardingList = new List<Mx_Onboarding_Link__c>();
        newMxOnboardingList.add(newMxOnboardingLink);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ newContractAccount });
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByQuoteIds(new Set<Id>{ quoteId })
            )
            .thenReturn(new List<Contract>{ newAPContractAccount });
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(newBusinessAccountsList);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ newStoreAccount });
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelectorMock.selectById(new Set<Id>{ mxOnboardingId }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ newMxOnboardingLink });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        MxOnboardingLinks.newInstance(newMxOnboardingList)
            .initiateStoreAgreementCreation(new Set<Id>{ mxOnboardingId });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description It is used to test if Store Agreement creation is initaited asynchronously
     * when records are updated.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenRecordsUpdatedThenInitateStoreAgreementCreationAsynchronously() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                CREATION_STATUS_WO_CREATION_SUCCESS
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksService mxOnboardingLinksServiceMock = (IMxOnboardingLinksService) mocks.mock(
            IMxOnboardingLinksService.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IMxOnboardingLinksService.class, mxOnboardingLinksServiceMock);
        Test.startTest();
        MxOnboardingLinks.newInstance(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake })
            .initiateStoreAgreementCreationAsync();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}