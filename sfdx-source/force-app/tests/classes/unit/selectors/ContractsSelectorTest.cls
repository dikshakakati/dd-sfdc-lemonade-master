/**
 * @author atg
 * @date 05/09/2022
 * @description This is test class for Contracts Selector  class
 */
@isTest(seeAllData=false)
public class ContractsSelectorTest {
    private static final String A_AND_P_ORDER = 'A&P';
    private static final String CONTACT_EMAIL = 'test@AgreementsSelectorTest.com';
    private static final String CONTACT_NAME = 'Test Contact';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String SIZE_MISMATCH_ASSERTION = 'Unexpected Error: The expected Contracts were not fetched';
    private static final String WHERE_CLAUSE_MISMATCH = 'Unexpected Error: The Contracts of the expected Accounts were not fetched';
    private static final String SUB_MISMATCH = 'Unexpected Error: The Contracts with expected Subscriptions were not fetched';
    private static final String CORE_ORDER = 'Core';
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final String ADS_PROMOS = 'A&P';
    private static final String RECORD_FOUND = 'Record Found';
    private static final String MX_ONBOARDING_SOURCE_RESSMO = 'RESSMO';
    private static final String MIDDLEWARE_PROVIDER = ' Middleware Provider';
    private static final String CONTRACT_SPLIT_CATEGORY_MIDDLEWARE_PROVIDER = 'Middleware Provider';
    private static final String CHURNED_MERCHANT = 'Churned Merchant';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final string DECK_RANK_JOKER = 'Joker';
    private static final string ACCOUNTSEGEMENT_SMB = 'SMB';
    private static final string ORDER_TYPE_DRAFT = 'Draft';

    @testSetup
    static void setupData() {
        Account parentAccount = new Account(
            Name = 'Test Parent Account',
            Segment__c = 'Enterprise'
        );
        insert parentAccount;

        SBQQ.TriggerControl.disable();

        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Family = 'Drive';
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.Family = 'Drive Promotion';
        Product2 product3 = CPQTestDataFactory.createProduct(false);
        product3.Family = 'Advertisement';
        List<Product2> prodList = new List<Product2>{ product, product2, product3 };
        insert prodList;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', false);
        PricebookEntry pbe2 = CPQTestDataFactory.createPriceBookEntry(product2, 'USD', false);
        PricebookEntry pbe3 = CPQTestDataFactory.createPriceBookEntry(product3, 'USD', false);
        List<PricebookEntry> pbeList = new List<PricebookEntry>{ pbe, pbe2, pbe3 };
        insert pbeList;

        Opportunity testOpp = CPQTestDataFactory.createOpportunity(parentAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, parentAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, false);
        SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(product2, quote, false);
        SBQQ__QuoteLine__c quoteLine3 = CPQTestDataFactory.createQuoteLine(product3, quote, false);
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>{
            quoteLine,
            quoteLine2,
            quoteLine3
        };
        insert qLineList;

        Order order = CPQTestDataFactory.createOrder(parentAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;

        OrderItem orderItem = CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, false);
        OrderItem orderItem2 = CPQTestDataFactory.createOrderItem(
            order,
            quoteLine2,
            pbe2.Id,
            false
        );
        OrderItem orderItem3 = CPQTestDataFactory.createOrderItem(
            order,
            quoteLine3,
            pbe3.Id,
            false
        );
        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem, orderItem2, orderItem3 };
        insert orderItemList;

        List<Contract> contracts = new List<Contract>{
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            ),
            new Contract(
                StartDate = Date.today() + 1,
                Status = 'Draft',
                AccountId = parentAccount.Id
            )
        };
        insert contracts;

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contracts[0].Id;
        subRec.SBQQ__Account__c = parentAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        subRec.SBQQ__OrderProduct__c = orderItem.Id;

        SBQQ__Subscription__c subRec2 = new SBQQ__Subscription__c();
        subRec2.SBQQ__Product__c = product2.Id;
        subRec2.SBQQ__Contract__c = contracts[0].Id;
        subRec2.SBQQ__Account__c = parentAccount.Id;
        subRec2.SBQQ__Quantity__c = 200;
        subRec2.SBQQ__OrderProduct__c = orderItem2.Id;

        SBQQ__Subscription__c subRec3 = new SBQQ__Subscription__c();
        subRec3.SBQQ__Product__c = product3.Id;
        subRec3.SBQQ__Contract__c = contracts[1].Id;
        subRec3.SBQQ__Account__c = parentAccount.Id;
        subRec3.SBQQ__Quantity__c = 200;
        subRec3.SBQQ__OrderProduct__c = orderItem3.Id;

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subrec,
            subRec2,
            subrec3
        };
        insert subList;
        SBQQ.TriggerControl.enable();
    }

    /**
     * @description This is test class to test selectById and fieldList values.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Account acc = new Account(Name = 'Test 1', Segment__c = 'SMB');
        insert acc;

        Contract testContract1 = new Contract(Name = 'Test Contract1', AccountId = acc.Id);
        insert testContract1;
        Contract testContract2 = new Contract(Name = 'Test Contract2', AccountId = acc.Id);
        insert testContract2;
        Contract testContract3 = new Contract(Name = 'Test Contract3', AccountId = acc.Id);
        insert testContract3;

        List<Contract> contracts = ContractsSelector.newInstance()
            .selectById(new Set<Id>{ testContract1.Id, testContract2.Id });
        System.assertEquals(contracts.size(), 2, 'The list should Contain 2 Contracts');

        ContractsSelector contractsInstance = new ContractsSelector();
        Schema.SObjectType typeOfObj = contractsInstance.getSObjectType();
        System.assertEquals(
            Schema.Contract.SObjectType,
            typeOfObj,
            'The object type must be Contract'
        );

        List<Schema.SObjectField> fieldList = contractsInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Contract.Id,
                Contract.Name,
                Contract.Associated_Account_Ids__c,
                Contract.CurrencyIsoCode,
                Contract.SBQQ__Opportunity__c,
                Contract.SBQQ__Order__c,
                Contract.AccountId,
                Contract.MP_Bz_Id__c,
                Contract.Payment_Method__c,
                Contract.Is_This_Ads_Or_Promo__c,
                Contract.SBQQ__Quote__c,
                Contract.Contract_Split_Category__c,
                Contract.Integration_Source__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenParentAccountIdsAreProvidedThenChildContractsAreFetched() {
        Test.startTest();
        Id parentAccountId = [SELECT Id FROM Account][0].Id;
        List<Contract> contractsFetchedBySelector = new List<Contract>();

        contractsFetchedBySelector = ContractsSelector.newInstance()
            .selectByParentAccountId(new Set<Id>{ parentAccountId });
        Test.stopTest();

        System.assertEquals(2, contractsFetchedBySelector.size(), SIZE_MISMATCH_ASSERTION);
        System.assertEquals(
            parentAccountId,
            contractsFetchedBySelector[0].AccountId,
            WHERE_CLAUSE_MISMATCH
        );
    }

    /**
     * @description This is test method to test that Contracts are returned with
     * Ads or Promotion Subscriptions
     */
    @isTest
    private static void testWhenContractsAreQueriedThenContractsReturnedWithAdsPromoSubscriptions() {
        Test.startTest();
        List<Contract> contracts = [
            SELECT Id, (SELECT SBQQ__Product__r.family FROM SBQQ__Subscriptions__r)
            FROM Contract
        ];
        List<Contract> returnedContracts = new List<Contract>();

        returnedContracts = ContractsSelector.newInstance()
            .selectContractsWithAdsAndPromoSubscriptions(
                new Set<Id>{ contracts[0].Id, contracts[1].Id }
            );
        Test.stopTest();

        System.assertEquals(2, returnedContracts.size(), SIZE_MISMATCH_ASSERTION);
        System.assertEquals(1, returnedContracts[0].SBQQ__Subscriptions__r.size(), SUB_MISMATCH);
        System.assertEquals(1, returnedContracts[1].SBQQ__Subscriptions__r.size(), SUB_MISMATCH);
    }

    /**
     * @description To test activated Withholding Contracts are fetched
     * when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenActivatedWithholdingContractsReturned() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectActivatedWithholdingContractsByAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description To test no activated Withholding Contracts are fetched
     * when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenNoActivatedWithholdingContractsReturned() {
        Test.startTest();
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectActivatedWithholdingContractsByAccountIds(new Set<Id>{ account.Id });
        Test.stopTest();
        System.assertEquals(0, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description To test Core Products being fetched
     * when Account Ids with fields to fetch are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenCoreProductsReturned() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id,
            Is_This_Ads_Or_Promo__c = false
        );
        insert testContract;
        Set<String> fieldSets = new Set<String>{ 'AccountId' };
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectContractsWithDynamicFields(fieldSets, testAccount.Id);
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
        System.assertEquals(false, contracts[0].Is_This_Ads_Or_Promo__c, SIZE_MISMATCH_ASSERTION);
    }
    /**
     * @description To test Ads & promos will fetched
     * when Account Ids with fields to fetch are passed for nintex usecase.
     */
    @isTest
    private static void testWhenAccountIdsPassedWithNintexUseCaseThenAdsAndPromosReturned() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c testQuote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            false
        );
        testQuote.Nintex_Use_Case__c = MIDDLEWARE_PROVIDER;
        insert testQuote;
        Order testOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            testQuote,
            false
        );
        testOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        testOrder.Type = ADS_PROMOS;
        insert testOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = testOrder.Id,
            SBQQ__Quote__c = testQuote.Id,
            Is_This_Ads_Or_Promo__c = true
        );
        insert testContract;
        Set<String> fieldSets = new Set<String>{ 'AccountId' };
        Test.startTest();
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectContractsWithDynamicFields(fieldSets, testAccount.Id);
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }
    /**
     * @description It checks if the Ads and Promo Contract linked to an Opportunity (neither new nor existing) is activated. If it is, then stores are not automatically associated.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnRelatedCoreContract() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        sbqqOrder.Type = CORE_ORDER;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectCoreContractsByAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description To test no activated Withholding Contracts are fetched
     * when corporate Account Ids are passed.
     */
    @isTest
    private static void testWhenContractIdsPassedThenListOfContractReturned() {
        List<Contract> contracts = [SELECT Id, Name FROM Contract LIMIT 1];
        Set<Id> contractIds = new Set<Id>{ contracts[0].Id };

        Test.startTest();
        List<Contract> contractsList = ContractsSelector.newInstance().selectById(contractIds);
        Test.stopTest();
        System.assertEquals(1, contractsList.size(), 'Matched');
    }

    /**
     * @description To test when accountIds are passed then return Ads and Promos Contracts associated with
     * the passed accountIds.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnAdsAndPromosContracts() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        sbqqOrder.Type = A_AND_P_ORDER;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectAdsAndPromosContractsByAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description To test when accountIds are passed then then do not return Ads and Promos Contracts associated with
     * the passed accountIds.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDoNotReturnAdsAndPromosContracts() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        sbqqOrder.Type = CORE_ORDER;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectAdsAndPromosContractsByAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();
        System.assertEquals(0, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }
    /**
     * @description It tests whether there are any contracts of the split category core for the given Quote IDs and returns them.
     */
    @isTest
    private static void testWhenQuoteIdsArePassedThenReturnRelatedAdsAndPromosContracts() {
        Test.startTest();
        Order adsAndPromosOrder = [SELECT Id, SBQQ__Quote__c, AccountId FROM Order];
        adsAndPromosOrder.Type = ADS_PROMOS;
        update adsAndPromosOrder;
        Contract adsAndPromosContracts = new Contract(
            StartDate = Date.today() + 1,
            Status = 'Draft',
            AccountId = adsAndPromosOrder.AccountId,
            SBQQ__Order__c = adsAndPromosOrder.Id
        );
        insert adsAndPromosContracts;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectAdsAndPromosContractsByQuoteIds(new Set<Id>{ adsAndPromosOrder.SBQQ__Quote__c });
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }
    /**
     * @description The test verifies that no contracts are returned for the provided Quote IDs that contain only Core Products.
     */
    @isTest
    private static void testWhenQuoteIdsWithOnlyCoreProductsArePassedThenReturnNoRelatedAdsAndPromosContracts() {
        Test.startTest();
        Order adsAndPromosOrder = [SELECT Id, SBQQ__Quote__c, AccountId FROM Order];
        adsAndPromosOrder.Type = CORE_ORDER;
        update adsAndPromosOrder;
        Contract adsAndPromosContracts = new Contract(
            StartDate = Date.today() + 1,
            Status = 'Draft',
            AccountId = adsAndPromosOrder.AccountId,
            SBQQ__Order__c = adsAndPromosOrder.Id
        );
        insert adsAndPromosContracts;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectAdsAndPromosContractsByQuoteIds(new Set<Id>{ adsAndPromosOrder.SBQQ__Quote__c });
        Test.stopTest();
        System.assertEquals(0, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }
    /**
     * @description To test contract are being fetched when opportunity id is being passed.
     */
    /*@isTest
    private static void testWhenOpportunityIdIsProvidedThenContractsAreFetched() {
        Test.startTest();
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id,
            SBQQ__Opportunity__c = testOpportunity.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectContractsByOpportunityId(testOpportunity.Id);
        Test.stopTest();
        System.assertEquals(1, contracts.size(), SIZE_MISMATCH_ASSERTION);
    }*/

    /**
     * @description - select fields related to ontract to for ressmo pre condition check.
     * @author Soumya Dash | 07-26-2024
     **/
    @isTest
    private static void testWhenContractThenSelectRESSMOElligibleRelatedFields() {
        Account testAccount = TestDataFactory.createAccount(false);
        Test.startTest();
        insert testAccount;

        Account storeAccount = TestDataFactory.createAccount(false);
        storeAccount.ParentId = testAccount.Id;
        storeAccount.Segment__c = 'SMB';
        insert storeAccount;

        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL,
            AccountId = testAccount.Id
        );
        insert testContact;

        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            false
        );
        quote.RESSMO_Eligible__c = true;
        insert quote;

        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Family = 'Marketplace';
        product.Name = 'Plus Package';
        product.SSMO_Eligible__c = true;
        product.IsActive = true;
        insert product;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);

        SBQQ__QuoteLine__c quoteLineItems = CPQTestDataFactory.createQuoteLine(
            product,
            quote,
            false
        );

        quoteLineItems.SBQQ__Bundle__c = true;
        quoteLineItems.Brands__c = 'Brand';
        quoteLineItems.SBQQ__RequiredBy__c = null;
        quoteLineItems.SBQQ__Bundle__c = true;
        quoteLineItems.SBQQ__Quantity__c = 1;
        insert quoteLineItems;

        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        insert sbqqOrder;

        OrderItem orderItem1 = CPQTestDataFactory.createOrderItem(
            sbqqOrder,
            quoteLineItems,
            pbe.Id,
            true
        );

        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id,
            SBQQ__Quote__c = quote.Id
        );
        insert testContract;

        SBQQ__Subscription__c subRec1 = new SBQQ__Subscription__c(
            SBQQ__Product__c = product.Id,
            SBQQ__Contract__c = testContract.Id,
            SBQQ__Account__c = testAccount.Id,
            SBQQ__OrderProduct__c = orderItem1.Id,
            SBQQ__QuoteLine__c = quoteLineItems.Id,
            SBQQ__Quantity__c = quoteLineItems.SBQQ__Quantity__c,
            SBQQ__TerminatedDate__c = Date.today().addDays(15)
        );
        insert new List<SBQQ__Subscription__c>{ subRec1 };

        Mx_Onboarding_Link__c mxLink = new Mx_Onboarding_Link__c(
            contract__c = testContract.Id,
            Status__c = 'Active',
            Source__c = MX_ONBOARDING_SOURCE_RESSMO,
            Record_Creation_Status__c = ''
        );
        insert mxLink;

        IContractsSelector contractSelector = ContractsSelector.newInstance();
        Contract contract = contractSelector.selectByIdWithMxActiveOnboarding(testContract.Id);
        Test.stopTest();

        Assert.areNotEqual(null, contract, 'No contract fetched');
        Assert.areNotEqual(0, contract.SBQQ__Subscriptions__r.size(), 'No subscription fetched');
        Assert.areNotEqual(
            null,
            contract.SBQQ__Subscriptions__r[0].SBQQ__Product__r,
            'No Product fetched'
        );
        Assert.areNotEqual(
            0,
            contract.Mx_Onboarding_Links__r.size(),
            'No Mx Onboarding Link Fetched'
        );
    }

    /**
     * @description Selecting the contract account subscription product.
     * @author Pankaj | 07-18-2024
     **/
    @isTest
    private static void testWhenContractThenSelectContractAccountSubscriptionProducts() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        Test.startTest();
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectContractsWithActiveSubscriptionsProducts(new Set<Id>{ testContract.Id });
        Test.stopTest();
        System.assertEquals(1, contracts.size(), 'Record Not found');
    }

    /**
     * @description Selecting the contract related Records.
     * @jira LEM-17697
     **/
    @isTest
    private static void testWhenContractThenSelectContractRelatedRecords() {
        Account testAccount = TestDataFactory.createAccount(true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        Test.startTest();
        insert testContact;
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Payment_Method__c = PAYMENT_METHOD_WITHHOLDING;
        insert sbqqOrder;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert testContract;

        Set<Id> contractIds = new Set<Id>{ testContract.Id };
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>();
        sobjectToSetOfField.put('Account', new Set<String>{ 'Id' });
        sobjectToSetOfField.put('SBQQ__Opportunity__r', new Set<String>{ 'Id' });
        sobjectToSetOfField.put('Contract', new Set<String>{ 'Id' });
        sobjectToSetOfField.put('Owner', new Set<String>{ 'Id' });
        sobjectToSetOfField.put(
            'SBQQ__Subscription__c',
            new Set<String>{
                'SBQQ__Product__r.Name',
                'SBQQ__Product__r.SSMO_Eligible__c',
                'SBQQ__Product__r.ProductCode'
            }
        );

        // Call the method
        ContractsSelector selector = new ContractsSelector();
        List<Contract> result = selector.selectContractsandRelatedRecords(
            contractIds,
            sobjectToSetOfField
        );

        // Verify the result
        Assert.areEqual(1, result.size(), RECORD_FOUND);
    }

    /**
     * @description - test When ContractId Then Select Its MxOnboardingLInk And Related Fields.
     * @author Soumya Dash | 08-08-2024
     **/
    @isTest
    private static void testWhenContractIdThenSelectItsMxOnboardingLInkAndRelatedFields() {
        Account testAccount = TestDataFactory.createAccount(true);

        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);

        Contract contract = new Contract(
            AccountId = testAccount.Id,
            SBQQ__Opportunity__c = testOpportunity.Id
        );
        insert contract;

        Mx_Onboarding_Link__c mxLink = new Mx_Onboarding_Link__c(
            status__c = 'Inactive',
            Source__c = 'RESSMO',
            Inactive_Reason__c = '',
            Contract__c = contract.Id
        );
        insert mxLink;

        Brand__c brand = new Brand__c(
            Name = 'test brand',
            Price_Range__c = '$$',
            Brand_Owner__c = testAccount.Id
        );
        insert brand;

        Contract_Brand_Association__c cba = new Contract_Brand_Association__c(
            Contract__c = contract.Id,
            Brand__c = brand.Id,
            Status__c = 'Active'
        );
        insert cba;

        Test.startTest();
        Contract resContract = ContractsSelector.newInstance()
            .selectByIdWithRESSMOSourceMxOnboarding(contract.Id);
        Test.stoptest();

        Assert.areNotEqual(
            0,
            resContract.Mx_Onboarding_Links__r.size(),
            'Mx onboarding link has not been retireved'
        );
        Assert.areEqual(
            1,
            resContract.Contract_Brand_Associations__r.size(),
            'Contract brand was not retrieved'
        );
    }

    /**
     * @description - test When ContractId Then Select It field
     * @jira LEM-18297
     **/
    @isTest
    private static void testWhenContractIdThenSelectFields() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        Contract contract = new Contract(
            AccountId = testAccount.Id,
            SBQQ__Opportunity__c = testOpportunity.Id
        );
        insert contract;
        Mx_Onboarding_Link__c mxLink = new Mx_Onboarding_Link__c(
            status__c = 'Active',
            Source__c = 'RESSMO',
            Contract__c = contract.Id
        );
        insert mxLink;
        Set<String> setOfString = new Set<String>();
        setOfString.add('Id');
        setOfString.add('RESSMO_Store_Account_Id__c');

        Test.startTest();
        List<Contract> resContract = ContractsSelector.newInstance()
            .selectContractByIdWithGivenFields(new Set<Id>{ contract.Id }, setOfString);
        Test.stoptest();

        Assert.areEqual(1, resContract.size(), 'Contract Found');
    }

    /**
     * @description test method for selectByContractNumber
     * @author VenkateshDD | 08-20-2024
     **/
    @isTest
    private static void testWhenContractNumbersThenReturnContracts() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        Contract contract = new Contract(
            AccountId = testAccount.Id,
            SBQQ__Opportunity__c = testOpportunity.Id
        );
        insert contract;

        Set<String> contractNumbers = new Set<String>();

        Contract expectedContract = [
            SELECT Id, ContractNumber
            FROM Contract
            WHERE Id = :contract.Id
        ];
        contractNumbers.add(expectedContract.ContractNumber);

        Test.startTest();
        List<Contract> resContract = ContractsSelector.newInstance()
            .selectByContractNumber(contractNumbers);
        Test.stoptest();

        Assert.areEqual(
            expectedContract.ContractNumber,
            resContract[0].ContractNumber,
            'Expected Contract Mismatch'
        );
    }

    /**
     * @description To test if Contracts with 'Middleware Provider' "Split Category" are returned
     * when Parent Account Ids are passed
     **/
    @isTest
    private static void testWhenParentAccountIdsPassedThenMiddlewareProviderContractsFetched() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Type = CONTRACT_SPLIT_CATEGORY_MIDDLEWARE_PROVIDER;
        insert sbqqOrder;
        Contract contract = new Contract(
            AccountId = testAccount.Id,
            SBQQ__Opportunity__c = testOpportunity.Id,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert contract;

        List<Contract> contractsFetchedBySelector = new List<Contract>();
        Test.startTest();
        contractsFetchedBySelector = ContractsSelector.newInstance()
            .selectContractSplitCategoryByParentAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();

        System.assertEquals(1, contractsFetchedBySelector.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description To test if Contracts with 'Middleware Provider' "Split Category" are not returned
     * when Parent Account Ids are passed
     **/
    @isTest
    private static void testWhenParentAccountIdsArePassedThenMiddlewareProviderContractsAreNotFetched() {
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpportunity = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        Contact testContact = new Contact(
            FirstName = CONTACT_NAME,
            LastName = CONTACT_NAME,
            Email = CONTACT_EMAIL
        );
        insert testContact;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            testOpportunity,
            testAccount,
            testContact,
            true
        );
        Order sbqqOrder = CPQTestDataFactory.createOrder(
            testAccount,
            testOpportunity,
            quote,
            false
        );
        sbqqOrder.Type = CORE_ORDER;
        insert sbqqOrder;
        Contract contract = new Contract(
            AccountId = testAccount.Id,
            SBQQ__Opportunity__c = testOpportunity.Id,
            SBQQ__Order__c = sbqqOrder.Id
        );
        insert contract;

        List<Contract> contractsFetchedBySelector = new List<Contract>();
        Test.startTest();
        contractsFetchedBySelector = ContractsSelector.newInstance()
            .selectContractSplitCategoryByParentAccountIds(new Set<Id>{ testAccount.Id });
        Test.stopTest();

        System.assertEquals(0, contractsFetchedBySelector.size(), SIZE_MISMATCH_ASSERTION);
    }

    /**
     * @description It is used to test whether the Contracts of type "Churned Merchant" are
     * returned or not by the passed contract ids.
     **/
    @isTest
    private static void testWhenChurnedMxContractIdsPassedThenCorrespondingContractsReturned() {
        Account account = [SELECT Id, Segment__c FROM Account];
        account.Segment__c = ACCOUNTSEGEMENT_SMB;
        account.Deck_Rank__c = DECK_RANK_JOKER;
        update account;
        Order churnedMxOrder = [SELECT Id, SBQQ__Quote__c, AccountId FROM Order];
        churnedMxOrder.Type = CHURNED_MERCHANT;
        update churnedMxOrder;
        Contract churnedMxContracts = new Contract(
            StartDate = Date.today() + 1,
            Status = ORDER_TYPE_DRAFT,
            AccountId = churnedMxOrder.AccountId,
            SBQQ__Order__c = churnedMxOrder.Id,
            Is_Churned_Mx_Contract_Processed__c = false
        );
        insert churnedMxContracts;
        Test.startTest();
        Database.QueryLocator contractsQuery = ContractsSelector.newInstance()
            .selectChurnedMxContracts();
        Test.stopTest();
        List<Contract> contractRecordsFetched = Database.query(contractsQuery.getQuery());
        System.assertEquals(1, contractRecordsFetched.size(), INVALID_ASSERT_MESSAGE);
    }
}