/**
 * @author Aethereus
 * @date 05-27-2024
 * @description This is a test class created for ContractsSummaryController class.
 */
@isTest(SeeAllData=false)
private class ContractsSummaryControllerTest {
    private static final String AGREEMENTSCOUNT = 'agreementsCount';

    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String OBJECT_CONTRACT = 'Contract';
    private static final String OBJECT_SUBSCRIPTION = 'Subscription';
    private static final String OBJECT_SERVICES = 'Sevices';
    private static final String SPLITCATEGORY_CORE = 'Core';
    private static final String ACCOUNT_SEGEMENT_SMB = 'SMB';
    private static final String ACCOUNT_SEGEMENT_ENT = 'Enterprise';
    private static final String TYPE_TEXT = 'Text';
    private static final String SPLIT_CATEGORY_A_P = 'A&P';
    private static final String ADS_PROMOS = 'Ads & Promos';
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final String LABEL_NAME = 'Name';
    private static final String LABEL_PRODUCT = 'SBQQ__Product__c';
    private static final String ASSERT_MESSAGE_ERROR = 'Unexpected size of contractDataTableMap';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String UNITED_STATES = 'United States';
    private static final String BILLING_STREET = '123 Test Street';
    private static final String NAME_ACCOUNT_CHILD = 'Test Acc Child';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRODUCT_CODE_10017 = '10017';
    private static final String ASSERT_MESSAGE = 'Number of merchant services returned is as expected';
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';

    @IsTest
    static void testWhenGetAllContractPassedWithOpportunityIdThenMapWrapper() {
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

        Contract childContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        String customerSegment = 'Enterprise';
        String initiatedFromSobject = 'Opportunity';

        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = 'BUSINESS ACCOUNT',
                DeveloperName = 'Account_Name',
                Order__c = 2,
                API_Name__c = 'AccountId',
                Segment__c = customerSegment,
                Hyper_Link_Display_Field__c = 'Account.Name',
                Type__c = 'Hyperlink',
                Available_On__c = 'Opportunity'
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = 'NO OF STORES',
                DeveloperName = 'Account_Name',
                Order__c = 3,
                API_Name__c = 'AccountId',
                Segment__c = customerSegment,
                Hyper_Link_Display_Field__c = 'storeCount',
                Type__c = 'Report',
                Available_On__c = 'Opportunity'
            )
        };

        List<Aggregate> results = new List<Aggregate>{
            new Aggregate().put('Contract__c', childContract.Id).put('agreementsCount', 1)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IAgreementsSelector agreementsMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        Aggregate mockResult = new Aggregate();
        mockResult.put('Contract__c', childContract.Id);
        mockResult.put('agreementsCount', 1);
        results.add(mockResult);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(agreementsMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsMock.selectCountOfStoresAccountsByStoreAgreements(parentAccount.Id))
            .thenReturn(results);

        mocks.when(contractsMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsMock.selectContractsWithDynamicFields(
                    new Set<String>{ 'Account.Name', 'AccountId' },
                    parentAccount.Id
                )
            )
            .thenReturn(new List<Contract>{ childContract });

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectContractTableMappingSortedByOrder(
                    initiatedFromSobject,
                    customerSegment
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractTableMock);
        Application.SELECTOR.setMock(agreementsMock);
        Application.SELECTOR.setMock(contractsMock);

        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllContracts(
            opportunityRecords[0].Id
        );
        Test.StopTest();
        System.assertEquals(
            2,
            wrapper.contractDataTableMap.size(),
            'Unexpected size of contractDataTableMap'
        );
        System.assertEquals(1, wrapper.recordDetails.size(), 'Unexpected size of recordDetails');
    }

    @IsTest
    static void testWhenGetAllContractPassedWithAccountIdThenMapWrapper() {
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

        Contract childContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = 'Draft'
        );

        String customerSegment = 'Enterprise';
        String initiatedFromSobject = 'Account';

        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = 'BUSINESS ACCOUNT',
                DeveloperName = 'Account_Name',
                Order__c = 2,
                API_Name__c = 'AccountId',
                Segment__c = customerSegment,
                Hyper_Link_Display_Field__c = 'Account.Name',
                Type__c = 'Hyperlink'
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = 'NO OF STORES',
                DeveloperName = 'Account_Name',
                Order__c = 3,
                API_Name__c = 'AccountId',
                Segment__c = customerSegment,
                Hyper_Link_Display_Field__c = 'storeCount',
                Type__c = 'Report'
            )
        };

        List<Aggregate> results = new List<Aggregate>{
            new Aggregate().put('Contract__c', childContract.Id).put('agreementsCount', 1)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IAgreementsSelector agreementsMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        Aggregate mockResult = new Aggregate();
        mockResult.put('Contract__c', childContract.Id);
        mockResult.put('agreementsCount', 1);
        results.add(mockResult);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityRecords[0].Id }))
            .thenReturn(opportunityRecords);

        mocks.when(agreementsMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsMock.selectCountOfStoresAccountsByStoreAgreements(parentAccount.Id))
            .thenReturn(results);

        mocks.when(contractsMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsMock.selectContractsWithDynamicFields(
                    new Set<String>{ 'Account.Name', 'AccountId' },
                    parentAccount.Id
                )
            )
            .thenReturn(new List<Contract>{ childContract });

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectContractTableMappingSortedByOrder(
                    initiatedFromSobject,
                    customerSegment
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(opportunityMock);
        Application.SELECTOR.setMock(contractTableMock);
        Application.SELECTOR.setMock(agreementsMock);
        Application.SELECTOR.setMock(contractsMock);

        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllContracts(
            parentAccount.Id
        );
        Test.StopTest();
        System.assertEquals(
            2,
            wrapper.contractDataTableMap.size(),
            'Unexpected size of contractDataTableMap'
        );
        System.assertEquals(1, wrapper.recordDetails.size(), 'Unexpected size of recordDetails');
    }
    /**
     * @description To validate if Subscription Columns are fetched and added to the wrapper.
     */
    @isTest
    private static void testWhenGetAllSubscriptionsColumnsPassedWithContractIdThenReturnWrapper() {
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );

        Contract mockContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = STATUS_ACTIVATED
        );

        String customerSegment = ACCOUNT_SEGEMENT_SMB;
        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_NAME,
                DeveloperName = LABEL_NAME,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SUBSCRIPTION,
                Applicable_for_Product__c = SPLIT_CATEGORY_A_P
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_PRODUCT,
                DeveloperName = LABEL_PRODUCT,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SUBSCRIPTION,
                Applicable_for_Product__c = SPLIT_CATEGORY_A_P
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        mocks.startStubbing();

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
                    customerSegment,
                    ADS_PROMOS
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();

        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllSubscriptionColumns(
            mockContract.Id,
            ADS_PROMOS
        );
        Test.StopTest();
        System.assertEquals(7, wrapper.contractDataTableMap.size(), ASSERT_MESSAGE_ERROR);
    }
    /**
     * @description To validate if Subscription Columns are not fetched.
     */
    @isTest
    private static void testWhenGetAllSubscriptionsPassedWithENTThenDoNotReturnWrapper() {
        Id contractId = Fake.generateId(Contract.class);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );

        Contract mockContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = STATUS_ACTIVATED
        );

        String customerSegment = ACCOUNT_SEGEMENT_ENT;
        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_NAME,
                DeveloperName = LABEL_NAME,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_ENT,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_CONTRACT
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_PRODUCT,
                DeveloperName = LABEL_PRODUCT,
                Order__c = 2,
                Segment__c = ACCOUNT_SEGEMENT_ENT,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_CONTRACT
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        mocks.startStubbing();

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
                    customerSegment,
                    SPLIT_CATEGORY_A_P
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();
        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllSubscriptionColumns(
            mockContract.Id,
            ADS_PROMOS
        );
        Test.StopTest();
        System.assertEquals(0, wrapper.recordDetails.size(), ASSERT_MESSAGE_ERROR);
    }

    @IsTest
    static void testWhenFetchAllSubscriptionsPassedWithContractIdThenMapWrapper() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id contractWithSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = 'Enterprise'
        );

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
                .setField(SBQQ__Subscription__c.Package__c, 'Marketplace')
                .setField(SBQQ__Subscription__c.Package__c, 'Marketplace')
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccount.Id)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractWithSubscriptions)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionMock.selectByContractId(contractWithSubscriptions))
            .thenReturn(subscriptions);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionMock);

        Test.StartTest();
        List<ContractsSummaryController.Packages> wrapper = ContractsSummaryController.fetchAllSubscriptions(
            contractWithSubscriptions
        );
        Test.StopTest();

        System.assertEquals(
            1,
            wrapper[0].activeSubscriptions.size(),
            'Unexpected size of activeSubscriptions'
        );
    }
    /**
     * @description To validate if merchant services Columns are fetched and added to the wrapper.
     */
    @isTest
    private static void testWhenGetAllMerchantServicesColumnsPassedWithContractIdThenGetRecords() {
        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );

        String customerSegment = ACCOUNT_SEGEMENT_SMB;
        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_NAME,
                DeveloperName = LABEL_NAME,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SERVICES
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_PRODUCT,
                DeveloperName = LABEL_PRODUCT,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SERVICES
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        mocks.startStubbing();

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
                    customerSegment
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();

        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllMerchantServicesColumns(
            parentAccount.Id
        );
        Test.StopTest();
        System.assertEquals(9, wrapper.contractDataTableMap.size(), ASSERT_MESSAGE);
    }
    /**
     * @description To validate if merchant services Columns are fetched without SMB then do not
     * get records.
     */

    @isTest
    private static void testWhenGetAllMerchantServicesColumnsPassedWithContractIdThenDoNotGetRecords() {
        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );

        String customerSegment = ACCOUNT_SEGEMENT_SMB;
        List<Contract_Table_Mapping__mdt> tableMappings = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_NAME,
                DeveloperName = LABEL_NAME,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SERVICES
            ),
            new Contract_Table_Mapping__mdt(
                MasterLabel = LABEL_PRODUCT,
                DeveloperName = LABEL_PRODUCT,
                Order__c = 1,
                Segment__c = ACCOUNT_SEGEMENT_SMB,
                Type__c = TYPE_TEXT,
                Object__c = OBJECT_SERVICES
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContractTableMappingSelector contractTableMock = (IContractTableMappingSelector) mocks.mock(
            IContractTableMappingSelector.class
        );

        mocks.startStubbing();

        mocks.when(contractTableMock.SobjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SobjectType);
        mocks.when(
                contractTableMock.selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
                    customerSegment
                )
            )
            .thenReturn(tableMappings);
        mocks.stopStubbing();

        Test.StartTest();
        ContractsSummaryController.ContractDataWrapper wrapper = ContractsSummaryController.getAllMerchantServicesColumns(
            parentAccount.Id
        );
        Test.StopTest();
        System.assertEquals(0, wrapper.recordDetails.size(), ASSERT_MESSAGE_ERROR);
    }
    /**
     * @description To validate if report id is returned.
     */
    @IsTest
    private static void testWhenReportIdIsPassedThenReturnId() {
        String expectedReportId = System.Label.ReportIDMXAgreed;

        String actualReportId = ContractsSummaryController.getReportId();
        System.assertEquals(expectedReportId, actualReportId, ASSERT_MESSAGE);
    }
    /**
     * @description To validate if services records are returned if business id and contract id
     * are passed.
     */
    @isTest
    private static void testWhenBusinessIdAndContractIdIsPassedThenGetServicesRecords() {
        Id contractId = Fake.generateId(Contract.class);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );
        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = parentAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET
        );

        Contract mockContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = STATUS_ACTIVATED
        );
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = mockContract.Id,
            SBQQ__Account__c = parentAccount.Id,
            SBQQ__Quantity__c = 200
        );
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        List<Id> mockServices = new List<Id>{ marketplaceMerchantService.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMerchantSelector merchantSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();

        mocks.when(merchantSelectorMock.SobjectType()).thenReturn(Merchant_Service__c.SobjectType);
        mocks.when(
                merchantSelectorMock.selectMerchantServiceToShowUnderContractsAmendment(
                    parentAccount.Id,
                    mockContract.Id
                )
            )
            .thenReturn(marketplaceMerchantService);
        mocks.stopStubbing();

        Test.StartTest();
        List<Merchant_Service__c> merchantServicesDetails = ContractsSummaryController.getAllMerchantServicesDetails(
            parentAccount.Id,
            mockContract.Id
        );
        Test.StopTest();
        System.assertEquals(
            merchantServicesDetails.size() + 1,
            mockServices.size(),
            ASSERT_MESSAGE
        );
    }
    /**
     * @description To validate if services records are not returned if business id and contract id
     * are not passed.
     */
    @isTest
    private static void testWhenBusinessIdAndContractIdIsNotPassedThenDoNotGetServicesRecords() {
        Id contractId = Fake.generateId(Contract.class);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();

        Account ultimateParentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Ultimate_Parent_Account__c = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGEMENT_SMB
        );
        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = parentAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET
        );

        Contract mockContract = new Contract(
            Id = contractId,
            StartDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Status = STATUS_ACTIVATED
        );
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = mockContract.Id,
            SBQQ__Account__c = parentAccount.Id,
            SBQQ__Quantity__c = 200
        );
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMerchantSelector merchantSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();

        mocks.when(merchantSelectorMock.SobjectType()).thenReturn(Merchant_Service__c.SobjectType);
        mocks.when(
                merchantSelectorMock.selectMerchantServiceToShowUnderContractsAmendment(
                    parentAccount.Id,
                    mockContract.Id
                )
            )
            .thenReturn(marketplaceMerchantService);
        mocks.stopStubbing();

        Test.StartTest();
        List<Merchant_Service__c> merchantServicesDetails = ContractsSummaryController.getAllMerchantServicesDetails(
            parentAccount.Id,
            mockContract.Id
        );
        Test.StopTest();
        System.assertEquals(0, merchantServicesDetails.size(), ASSERT_MESSAGE_ERROR);
    }
}