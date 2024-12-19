/**
 * @author DoorDash
 * @date 08/19/2022
 * @description Test class used to cover NintexSubmissionServiceImpl and
 * NintexSubmissionService classes
 */
@isTest
public with sharing class NintexSubmissionServiceImplTest {
    private static Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();

    public static final String PRODUCT_WITH_PACKAGES = '{"packageDetails":[{"packageName":"Marketplace","products":"Delivery"},{"packageName":"Storefront","products":""}]}';

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'New additional stores' then process to created Agreements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexAddtionalStoresOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            Marketplace_Nintex_Id__c = '12345678',
            RecordTypeId = storeAccRecordType
        );
        Account storeAccount2 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2 Store',
            Marketplace_Nintex_Id__c = '12345678',
            RecordTypeId = storeAccRecordType
        );
        Account storeAccount3 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 3 Store',
            Marketplace_Nintex_Id__c = '12345678',
            RecordTypeId = storeAccRecordType
        );
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'New additional stores')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Marketplace_Nintex_Id__c, '12345678')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today())
            .setField(Opportunity.Packages_with_Products__c, PRODUCT_WITH_PACKAGES)
            .setFakeId()
            .toSObject();

        Agreement__c agreement1 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today() - 20)
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12345678')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() + 10)
            )
            .setParent(
                'Opportunity__r',
                new Fake(Opportunity.class)
                    .setField(Opportunity.Packages_with_Products__c, PRODUCT_WITH_PACKAGES)
            )
            .toSObject();

        Agreement__c agreement2 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount2.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today() - 20)
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount2.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12345678')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() + 10)
            )
            .setParent(
                'Opportunity__r',
                new Fake(Opportunity.class)
                    .setField(Opportunity.Packages_with_Products__c, PRODUCT_WITH_PACKAGES)
            )
            .toSObject();

        List<Agreement__c> agreementsList = new List<Agreement__c>{ agreement1, agreement2 };

        List<Account> accountsList = new List<Account>{
            storeAccount,
            storeAccount2,
            storeAccount3
        };
        List<Account> accountsList1 = new List<Account>{ storeAccount3 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        Set<String> nintexIds = opportunitiesMock.getMarketplaceNintexIds();
        Set<Id> marketplaceAccountIds = new Set<Id>{ storeAccount3.Id };

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectStoreAccountsByMarketplaceNintextIds(nintexIds))
            .thenReturn(accountsList);
        mocks.when(accountsSelectorMock.selectById(marketplaceAccountIds))
            .thenReturn(accountsList1);
        mocks.when(agreementsSelectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectStoreAgreementsByAccountIds(
                    new Set<Id>{ storeAccount.Id, storeAccount2.Id, storeAccount3.Id }
                )
            )
            .thenReturn(agreementsList);
        mocks.when(
                agreementsSelectorMock.selectOpportunityInfoByIds(
                    new Set<Id>{ agreement1.Id, agreement2.Id }
                )
            )
            .thenReturn(agreementsList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => businessAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Franchise Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(mockOpp.Nintex_Signed_Date__c)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount3.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(mockOpp.Nintex_Signed_Date__c)
                    }
                )
            );
    }

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Change of Ownership' then process to created Agreements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexCOOOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType,
            Change_of_Ownership_Effective_Date__c = System.today() + 10
        );
        Account storeAccount2 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2 Store',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType,
            Change_of_Ownership_Effective_Date__c = System.today() + 10
        );
        Account storeAccount3 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 3 Store',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType
        );
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Change of Ownership')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Marketplace_Nintex_Id__c, '12121212')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, System.today() - 10)
            .setFakeId()
            .toSObject();

        Agreement__c agreement1 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today() - 20)
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12121212')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() + 10)
            )
            .toSObject();

        Agreement__c agreement2 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount2.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today() - 20)
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount2.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12121212')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() + 10)
            )
            .toSObject();

        List<Agreement__c> agreementsList = new List<Agreement__c>{ agreement1, agreement2 };
        List<Account> accountsList = new List<Account>{
            storeAccount,
            storeAccount2,
            storeAccount3
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        //IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );
        Set<String> nintextIds = opportunitiesMock.getMarketplaceNintexIds();

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectStoreAccountsByMarketplaceNintextIds(nintextIds))
            .thenReturn(accountsList);
        mocks.when(agreementsSelectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectAgreementsByMarketplaceNintexIds(nintextIds))
            .thenReturn(agreementsList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUOW);

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => businessAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Franchise Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(mockOpp.Nintex_Signed_Date__c)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() + 10)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount2.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() + 10)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() - 20),
                        Agreement__c.Deactivation_Date__c => Date.valueOf(System.today() + 9)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount2.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() - 20),
                        Agreement__c.Deactivation_Date__c => Date.valueOf(System.today() + 9)
                    }
                )
            );
    }

    /**
     * @description It tests when Opportunity is marked as Closed/Won and Nintex use-case is set to
     * 'Change of Ownership' where Change of Ownership Effective Date on the Store Account is set as
     * less than Start Date of the Store Agreement then existing Agreement deactivates and new
     * Agreement gets created successfully.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenStoreCOOEDLessThanAgreementStartDateThenDeactivateAndCreateAgreement() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType,
            Change_of_Ownership_Effective_Date__c = System.today() + 10
        );
        Account storeAccount2 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2 Store',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType,
            Change_of_Ownership_Effective_Date__c = System.today() + 10
        );
        Account storeAccount3 = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 3 Store',
            Marketplace_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType
        );
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Change of Ownership')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Marketplace_Nintex_Id__c, '12121212')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, System.today() - 10)
            .setFakeId()
            .toSObject();

        Agreement__c agreement1 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today())
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12121212')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() - 10)
            )
            .toSObject();

        Agreement__c agreement2 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccount2.Id)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Status__c, 'Active')
            .setField(Agreement__c.Type__c, 'Store Agreement')
            .setField(Agreement__c.Start_Date__c, System.today() - 20)
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccount2.Id)
                    .setField(Account.Marketplace_Nintex_Id__c, '12121212')
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Change_of_Ownership_Effective_Date__c, System.today() + 10)
            )
            .toSObject();

        List<Agreement__c> agreementsList = new List<Agreement__c>{ agreement1, agreement2 };
        List<Account> accountsList = new List<Account>{
            storeAccount,
            storeAccount2,
            storeAccount3
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        //IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );
        Set<String> nintextIds = opportunitiesMock.getMarketplaceNintexIds();

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectStoreAccountsByMarketplaceNintextIds(nintextIds))
            .thenReturn(accountsList);
        mocks.when(agreementsSelectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectAgreementsByMarketplaceNintexIds(nintextIds))
            .thenReturn(agreementsList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUOW);

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => businessAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Franchise Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(mockOpp.Nintex_Signed_Date__c)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() + 10)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount2.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() + 10)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() - 12),
                        Agreement__c.Deactivation_Date__c => Date.valueOf(System.today() - 11)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount2.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(System.today() - 20),
                        Agreement__c.Deactivation_Date__c => Date.valueOf(System.today() + 9)
                    }
                )
            );
    }
    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Change of OwnerShip' then process to created Agreements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexNewFranchiseThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'New Franchise - Unknown')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.MarketPlace_Nintex_Id__c, '12131415')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today() - 10)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );

        Application.UNITOFWORK.setMock(mockUOW);

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) fflib_Match.anyList());
    }

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Rate Change' then process to created Agreements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexMarketplaceAmendmentOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Rate Change')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.MarketPlace_Nintex_Id__c, '12345678')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today())
            .setFakeId()
            .toSObject();
        Merchant_Service__c merchantServiceRecordDrive = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        mocks.startStubbing();
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithFranchiseParentAccountIds(
                    new Set<Id>{ businessAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceRecordDrive });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) fflib_Match.anyList());
    }

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Drive - Amendment' then process to created Agreements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexDriveAmendmentOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Drive - Amendment')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Drive_Nintex_Id__c, '12345678')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today())
            .setFakeId()
            .toSObject();
        Merchant_Service__c merchantServiceRecordDrive = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Product__r', new Fake(Product2.class).setField(Product2.Family, 'Drive'))
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        mocks.startStubbing();
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithFranchiseParentAccountIds(
                    new Set<Id>{ businessAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceRecordDrive });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        //Only MerchantServices is updated by List.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) fflib_Match.anyList());
    }

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Integrated Franchise' then process to created Activation Order and Items.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexIntegratedFranchiseOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Integrated Franchise')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Drive_Nintex_Id__c, '12345678')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today())
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IActivationOrdersService activationOrdersService = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );
        Map<String, Id> accountIdContractIdMap = new Map<String, Id>();
        accountIdContractIdMap.put(
            String.valueof(businessAccount.Id) + '-' + String.valueof(mockOpp.Id),
            mockContract.Id
        );

        mocks.startStubbing();
        mocks.when(
                activationOrdersService.createActivationOrdersAndProductsForIntegratedFranchise(
                    accountIdContractIdMap,
                    mockUOW
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersService);
        Application.UNITOFWORK.setMock(mockUOW);

        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        //Make sure Franchise Agreement created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => businessAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Type__c => 'Franchise Agreement'
                    }
                )
            );
    }

    /**
     * @description Tests if Opportunities are marked as ClosedWon and Nintex Usecase is set to
     *  'Drive Form - Franchise' then process to created Activation Order and Items.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenNintexDriveFormFranchiseFranchiseOpportunityThenProcessOpportunity() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            Drive_Nintex_Id__c = '12121212',
            RecordTypeId = storeAccRecordType
        );
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Associated_Account_Ids__c, '')
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Opportunity mockOpp = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContractId, mockContract.Id)
            .setField(Opportunity.CurrencyIsoCode, 'USD')
            .setField(Opportunity.Nintex_Use_Case__c, 'Drive Form - Franchise')
            .setField(Opportunity.Nintex_Signed_Date__c, system.today())
            .setField(Opportunity.Drive_Nintex_Id__c, '12121212')
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.CloseDate, system.today())
            .setFakeId()
            .toSObject();

        List<Account> accountsList = new List<Account>{ storeAccount };
        //Empty Agreement list so we create new Store Agreements for storeAccount
        List<Agreement__c> agreementsList = new List<Agreement__c>();
        Map<String, Id> accountIdContractIdMap = new Map<String, Id>();
        accountIdContractIdMap.put(
            String.valueof(businessAccount.Id) + '-' + String.valueof(mockOpp.Id),
            mockContract.Id
        );
        Set<String> nintextIds = new Set<String>{ '12121212' };
        Set<Id> contractIds = new Set<Id>{ mockContract.Id };
        Set<Id> driveAccountIds = new Set<Id>{ storeAccount.Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IActivationOrdersService activationOrdersService = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectStoreAccountsByDriveNintextIds(nintextIds))
            .thenReturn(accountsList);
        mocks.when(accountsSelectorMock.selectStoreAccountsByMarketplaceNintextIds(nintextIds))
            .thenReturn(new List<Account>());
        mocks.when(accountsSelectorMock.selectById(driveAccountIds)).thenReturn(accountsList);
        mocks.when(agreementsSelectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectActiveAgreementsByContractIds(contractIds))
            .thenReturn(agreementsList);
        mocks.when(agreementsSelectorMock.selectStoreAgreementsByAccountIds(driveAccountIds))
            .thenReturn(agreementsList);
        mocks.when(
                activationOrdersService.createActivationOrdersAndProductsForIntegratedFranchise(
                    accountIdContractIdMap,
                    mockUOW
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersService);
        Application.UNITOFWORK.setMock(mockUOW);

        IOpportunities opportunitiesMock = Opportunities.newInstance(
            new List<Opportunity>{ mockOpp }
        );

        NintexSubmissionService.submitOpportunities(opportunitiesMock);

        //Make sure Franchise Agreement created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => businessAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Type__c => 'Franchise Agreement'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Account__c => storeAccount.Id,
                        Agreement__c.Contract__c => mockContract.Id,
                        Agreement__c.Opportunity__c => mockOpp.Id,
                        Agreement__c.CurrencyIsoCode => mockOpp.CurrencyIsoCode,
                        Agreement__c.Status__c => 'Active',
                        Agreement__c.Type__c => 'Store Agreement',
                        Agreement__c.Start_Date__c => Date.valueOf(mockOpp.Nintex_Signed_Date__c)
                    }
                )
            );
    }
}