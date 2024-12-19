/**
 * @author Aetherus
 * @date 17/06/2022
 * @description Test class for AmendmentServiceImpl class.
 */
@isTest
public with sharing class AmendmentServiceImplTest {
    private static final String UNSUCCESSFUL_MESSAGE =
        'There was problem while creating the quote. Therefore' +
        ' it is not successful. Kindly try after sometime.';
    private static final String UNEXPECTED_WRAPPER_RESULT = 'Unexpected result in AmendmentResponseWrapper';
    private static final String UNEXPECTED_RESULT = 'Unexpected result found';
    private static final String FAIL_CREATION_MESSAGE = 'Error to Create Record';

    @IsTest
    static void testWhenCreateAmendmentFromOpportunityThenReturnAmendmentQuoteId() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, 'Q-123456')
            .setField(SBQQ__Quote__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__Quote__c.Unique_Identifier__c, '92108a53-e8d9-4a0c-9193-9152aeb86fe4')
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Account__c, parentAccount.Id)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, oppId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Draft');

        SBQQ__Quote__c testQuote = (SBQQ__Quote__c) fakeQuote.toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IAmendmentService amendmentServiceMock = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        IQuotesSelector quoteSelctorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);

        mocks.when(amendmentServiceMock.createAmendmentQuote(opportunityRecords[0], contractRecord))
            .thenReturn(testQuote);

        mocks.when(amendmentServiceMock.insertAmendedQuoteLines(testQuote, contractRecord))
            .thenReturn(true);
        mocks.when(quoteSelctorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelctorMock.selectById(new Set<Id>{ testQuote.Id }))
            .thenReturn(new List<SBQQ__Quote__c>{ testQuote });

        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(quoteSelctorMock);

        Application.SERVICE.setMock(IAmendmentService.class, amendmentServiceMock);

        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(
            opportunityRecords[0].Id,
            contractRecord.Id
        );
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, true, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }

    @IsTest
    static void testWhenCreateAmendmentFromOpportunityQuoteLineFailedThenRollback() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                CurrencyIsoCode = 'CAD',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, 'Q-123456')
            .setField(SBQQ__Quote__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__Quote__c.Unique_Identifier__c, '92108a53-e8d9-4a0c-9193-9152aeb86fe4')
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Account__c, parentAccount.Id)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, oppId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Draft');

        SBQQ__Quote__c testQuote = (SBQQ__Quote__c) fakeQuote.toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IAmendmentService amendmentServiceMock = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        IQuotesSelector quoteSelctorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);

        mocks.when(amendmentServiceMock.createAmendmentQuote(opportunityRecords[0], contractRecord))
            .thenReturn(testQuote);

        mocks.when(amendmentServiceMock.insertAmendedQuoteLines(testQuote, contractRecord))
            .thenReturn(false);
        mocks.when(quoteSelctorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelctorMock.selectById(new Set<Id>{ testQuote.Id }))
            .thenReturn(new List<SBQQ__Quote__c>{ testQuote });

        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(quoteSelctorMock);

        Application.SERVICE.setMock(IAmendmentService.class, amendmentServiceMock);

        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(
            opportunityRecords[0].Id,
            contractRecord.Id
        );
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }

    @IsTest
    static void testWhenCreateAmendmentFromOpportunityQuoteLineFailedThenRollbackFireException() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IAmendmentService amendmentServiceMock = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);

        mocks.when(amendmentServiceMock.createAmendmentQuote(opportunityRecords[0], contractRecord))
            .thenReturn(testQuote);

        mocks.when(amendmentServiceMock.insertAmendedQuoteLines(testQuote, contractRecord))
            .thenReturn(false);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(IAmendmentService.class, amendmentServiceMock);

        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(
            null,
            contractRecord.Id
        );
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }

    @IsTest
    static void testWhenCreateAmendmentQuoteThenReturnQuoteId() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.StartTest();
        AmendmentService amendmentService = new AmendmentService();

        amendmentService.prepareMapforCustomAmendmentFields();
        SBQQ__Quote__c quotes = amendmentService.createAmendmentQuote(
            opportunityRecords[0],
            contractRecord
        );
        System.assertEquals(quotes != null, true, UNEXPECTED_RESULT);

        Test.StopTest();
    }

    @IsTest
    static void testWhenInsertAmendedQuoteLinesWithNoSubscriptionThenReturnFalse() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);
        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.StartTest();
        AmendmentService amendmentService = new AmendmentService();
        amendmentService.prepareMapforCustomAmendmentFields();
        Boolean flag = amendmentService.insertAmendedQuoteLines(testQuote, contractRecord);
        System.assertEquals(flag, false, UNEXPECTED_RESULT);
        Test.StopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.NcssMethodCount')
    static void testWhenInsertAmendedQuoteLinesWithSubscriptionThenReturnTrue() {
        //NOPMD
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        Contract contractRecord = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        List<Contract> contractList = new List<Contract>{ contractRecord };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);
        Id prod4 = Fake.generateId(Product2.class);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Thanksgiving Offers')
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__QuoteLine__r', parentQuoteLineInstane)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Storefront')
            )
            .toSObject();
        SBQQ__Subscription__c subscription4 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId4)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod3)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod4)
                    .setField(Product2.Name, 'Dashpass')
            )
            .toSObject();

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(contractsSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);

        List<Custom_Amendment_Field_Mapping__mdt> customAmendmentFieldMappings = CustomAmendmentFieldMappingSelector.newInstance()
            .selectAllCustomAmendmentFieldsMapping();
        Set<String> subscriptionsFields = new Set<String>();
        Set<String> quotelineGroupFields = new Set<String>();
        for (
            Custom_Amendment_Field_Mapping__mdt amendedCustomMetadata : customAmendmentFieldMappings
        ) {
            if (amendedCustomMetadata.Source_Object__c == 'SBQQ__Subscription__c') {
                subscriptionsFields.add(amendedCustomMetadata.Source_Field__c);
            }
            if (amendedCustomMetadata.Source_Object__c == 'SBQQ__QuoteLineGroup__c') {
                quotelineGroupFields.add(amendedCustomMetadata.Source_Field__c);
            }
        }

        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsByContractIdwithDynamicFields(
                    new Set<Id>{ contractId },
                    subscriptionsFields
                )
            )
            .thenReturn(subList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);

        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.StartTest();
        AmendmentService amendmentService = new AmendmentService();
        amendmentService.prepareMapforCustomAmendmentFields();
        Boolean flag = amendmentService.insertAmendedQuoteLines(testQuote, contractRecord);
        amendmentService.updateOpportunityWithAmendedContract(
            opportunityRecords[0].Id,
            contractId,
            false
        );
        System.assertEquals(flag, true, UNEXPECTED_RESULT);
        Test.StopTest();
    }

    @IsTest
    static void testWhenCreateOpportunityAndWorkOrderThenReturnOpportunityAndWorkOrder() {
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );

        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Name = 'Post Sale Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1),
                Type = 'Existing',
                Opportunity_Sub_Type__c = 'Cancel',
                Deal_Type__c = 'Standard',
                AccountId = parentAccount.Id
            )
        };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Test.StartTest();
        Map<String, String> response = AmendmentServiceImpl.createOpportunityAndWorkOrder(
            'Cancel',
            parentAccount.Id,
            contractId
        );
        System.assertEquals(response.size() > 0, true, FAIL_CREATION_MESSAGE);
        Test.StopTest();
    }

    @IsTest
    static void testWhenInsertWorkOrderAndOpportunityWithSubscriptionThenReturnTrue() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = oppId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };

        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            opportunityRecords[0],
            parentAccount,
            null,
            false
        );
        testQuote.Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);
        Id prod4 = Fake.generateId(Product2.class);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Thanksgiving Offers')
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__QuoteLine__r', parentQuoteLineInstane)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Storefront')
            )
            .toSObject();
        SBQQ__Subscription__c subscription4 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId4)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod3)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod4)
                    .setField(Product2.Name, 'Dashpass')
            )
            .toSObject();

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        List<Custom_Amendment_Field_Mapping__mdt> customAmendmentFieldMappings = CustomAmendmentFieldMappingSelector.newInstance()
            .selectAllCustomAmendmentFieldsMapping();
        Set<String> subscriptionsFields = new Set<String>();
        Set<String> quotelineGroupFields = new Set<String>();
        for (
            Custom_Amendment_Field_Mapping__mdt amendedCustomMetadata : customAmendmentFieldMappings
        ) {
            if (amendedCustomMetadata.Source_Object__c == 'SBQQ__Subscription__c') {
                subscriptionsFields.add(amendedCustomMetadata.Source_Field__c);
            }
            if (amendedCustomMetadata.Source_Object__c == 'SBQQ__QuoteLineGroup__c') {
                quotelineGroupFields.add(amendedCustomMetadata.Source_Field__c);
            }
        }
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsByContractIdwithDynamicFields(
                    new Set<Id>{ contractId },
                    subscriptionsFields
                )
            )
            .thenReturn(subList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        Test.StartTest();
        AmendmentService amendmentService = new AmendmentService();
        amendmentService.prepareMapforCustomAmendmentFields();
        Map<String, String> response = AmendmentServiceImpl.createOpportunityAndWorkOrder(
            'Cancel',
            ultimateParentAccount.Id,
            contractId
        );
        System.assertEquals(response.size() > 0, true, FAIL_CREATION_MESSAGE);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithCloseDateInPastQuoteFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(-1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutDataVerficationFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, null)
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutPreferedLanguageFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, 'Verified')
                        .setField(Account.Address_Verification_Status__c, 'Verified')
                        .setField(Account.Preferred_Language__c, null)
                        .setField(Account.Primary_Vertical__c, 'Rx')
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutLegalEntityFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, 'Verified')
                        .setField(Account.Address_Verification_Status__c, 'Verified')
                        .setField(Account.Preferred_Language__c, 'English')
                        .setField(Account.Legal_Business_Name__c, 'English')
                        .setField(Account.Primary_Vertical__c, 'Rx')
                        .setField(
                            Account.RecordTypeId,
                            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                .get('Business')
                                .getRecordTypeId()
                        )
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(
                                    RecordType.Id,
                                    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                        .get('Business')
                                        .getRecordTypeId()
                                )
                                .setField(RecordType.DeveloperName, 'Business')
                        )
                        .setField(Account.DoorDash_Legal_Entity__c, null)
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutLegalBusinessNameFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, 'Verified')
                        .setField(Account.Address_Verification_Status__c, 'Verified')
                        .setField(Account.Primary_Vertical__c, 'Rx')
                        .setField(Account.Preferred_Language__c, 'English')
                        .setField(Account.Legal_Business_Name__c, null)
                        .setField(Account.DoorDash_Legal_Entity__c, 'Doordash')
                        .setField(
                            Account.RecordTypeId,
                            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                .get('Business')
                                .getRecordTypeId()
                        )
                        .setParent(
                            'RecordType',
                            new Fake(RecordType.class)
                                .setField(
                                    RecordType.Id,
                                    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                        .get('Business')
                                        .getRecordTypeId()
                                )
                                .setField(RecordType.DeveloperName, 'Business')
                        )
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutBrandsFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, 'Verified')
                        .setField(Account.Address_Verification_Status__c, 'Verified')
                        .setField(Account.Primary_Vertical__c, 'Rx')
                        .setField(Account.Preferred_Language__c, 'English')
                        .setField(Account.Legal_Business_Name__c, null)
                        .setField(Account.DoorDash_Legal_Entity__c, 'Doordash')
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunityBrandRelationshipsSelector opportunityBrandRelation = (IOpportunityBrandRelationshipsSelector) mocks.mock(
            IOpportunityBrandRelationshipsSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.when(opportunityBrandRelation.sObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(opportunityBrandRelation.selectByOpportunity(new Set<Id>{ oppId }))
            .thenReturn(new List<Opportunity_Brand_Relationship__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(opportunityBrandRelation);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
    @IsTest
    static void testWhenCreateAmendmentFromOpportunityWithoutOCRFailedThenRollback() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = Fake.generateId(Account.class);
        List<Opportunity> existingOpportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.id, oppId)
                .setField(Opportunity.Type, 'Existing')
                .setField(Opportunity.StageName, 'Prospecting')
                .setField(Opportunity.CloseDate, Date.today().addDays(1))
                .setField(Opportunity.AccountId, accountId)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.id, accountId)
                        .setField(Account.Segment__c, 'SMB')
                        .setField(Account.Data_Verification_Status__c, 'Verified')
                        .setField(Account.Address_Verification_Status__c, 'Verified')
                        .setField(Account.Primary_Vertical__c, 'Rx')
                        .setField(Account.Preferred_Language__c, 'English')
                        .setField(Account.Legal_Business_Name__c, 'Doordash')
                        .setField(Account.DoorDash_Legal_Entity__c, 'Doordash')
                )
                .toSobject()
        };
        List<Opportunity_Brand_Relationship__c> brandsRelations = new List<Opportunity_Brand_Relationship__c>{
            (Opportunity_Brand_Relationship__c) new Fake(Opportunity_Brand_Relationship__c.class)
                .setField(
                    Opportunity_Brand_Relationship__c.id,
                    fflib_IDGenerator.generate(Opportunity_Brand_Relationship__c.SObjectType)
                )
                .setField(Opportunity_Brand_Relationship__c.Opportunity__c, oppId)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunityBrandRelationshipsSelector opportunityBrandRelation = (IOpportunityBrandRelationshipsSelector) mocks.mock(
            IOpportunityBrandRelationshipsSelector.class
        );
        IOpportunityContactRoleSelector contactRoles = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ oppId }))
            .thenReturn(existingOpportunities);
        mocks.when(opportunityBrandRelation.sObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(opportunityBrandRelation.selectByOpportunity(new Set<Id>{ oppId }))
            .thenReturn(brandsRelations);
        mocks.when(contactRoles.sObjectType()).thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(contactRoles.selectByOpportunity(new Set<Id>{ oppId }))
            .thenReturn(new List<OpportunityContactRole>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(opportunityBrandRelation);
        Test.StartTest();
        String response = AmendmentServiceImpl.createAmendmentFromOpportunity(oppId, contractId);
        AmendmentServiceImpl.AmendmentResponseWrapper amendmentWrapper = (AmendmentServiceImpl.AmendmentResponseWrapper) JSON.deserialize(
            response,
            AmendmentServiceImpl.AmendmentResponseWrapper.class
        );
        System.assertEquals(amendmentWrapper.isSuccessful, false, UNEXPECTED_WRAPPER_RESULT);
        Test.StopTest();
    }
}