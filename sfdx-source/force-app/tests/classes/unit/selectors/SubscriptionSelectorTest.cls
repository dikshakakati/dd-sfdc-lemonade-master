/**
 * @author Deloitte
 * @date 10/05/2022
 * @description This is test class for SubscriptionSelector class.
 */
@isTest(seeAllData=false)
public class SubscriptionSelectorTest {
    private static final String APPROVED = 'Approved';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final String STOREFRONT_PRODUCT_TYPE = 'Storefront';
    private static final String DRAFT_STATUS = 'Draft';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String SSMO_CREATION_SOURCE = 'SSMO';
    private static final String SMB_SEGMENT_TYPE = 'SMB';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String TYPE_CORPORATE = 'Corporate';

    @testSetup
    static void setupData() {
        SBQQ.TriggerControl.disable();

        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Product2 cashOnDeliveryProduct = CPQTestDataFactory.createCoDProduct(false);
        cashOnDeliveryProduct.Family = 'Drive';
        insert cashOnDeliveryProduct;
        PricebookEntry pbeCoD = CPQTestDataFactory.createPriceBookEntry(
            cashOnDeliveryProduct,
            'USD',
            true
        );
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.Family = 'Drive Promotion';
        product2.Name = 'Corporate Subsidy';
        product2.Package_Eligible_For_Entitlement__c = true;
        insert product2;

        PricebookEntry pbe2 = CPQTestDataFactory.createPriceBookEntry(product2, 'USD', true);

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLineGroup__c quoteLineGroup = CPQTestDataFactory.createGroup(quote.Id, true);
        quoteLineGroup.Name = 'Test';
        quoteLineGroup.SBQQ__Number__c = 12345;
        quoteLineGroup.SBQQ__CustomerTotal__c = 200;
        quoteLineGroup.SBQQ__ListTotal__c = 200;
        quoteLineGroup.SBQQ__NetTotal__c = 200;
        update quoteLineGroup;
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        SBQQ__QuoteLine__c quoteLineCoD = CPQTestDataFactory.createQuoteLine(
            cashOnDeliveryProduct,
            quote,
            true
        );
        SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(product2, quote, true);

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;

        OrderItem orderItem = CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);
        OrderItem orderItem2 = CPQTestDataFactory.createOrderItem(order, quoteLine2, pbe2.Id, true);
        OrderItem orderItemCoD = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineCoD,
            pbeCoD.Id,
            true
        );

        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contract.Id;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        subRec.SBQQ__OrderProduct__c = orderItem.Id;
        subRec.Quote_Line_Group__c = quoteLineGroup.id;
        insert subRec;

        SBQQ__Subscription__c subRec2 = new SBQQ__Subscription__c();
        subRec2.SBQQ__Product__c = product2.Id;
        subRec2.SBQQ__Contract__c = contract.Id;
        subRec2.SBQQ__Account__c = testAccount.Id;
        subRec2.SBQQ__Quantity__c = 200;
        subRec2.SBQQ__OrderProduct__c = orderItem2.Id;
        subRec2.Quote_Line_Group__c = quoteLineGroup.id;
        subRec2.SBQQ__RequiredById__c = subRec.Id;
        insert subRec2;

        SBQQ__Subscription__c subRecCoD = new SBQQ__Subscription__c();
        subRecCoD.SBQQ__Product__c = cashOnDeliveryProduct.Id;
        subRecCoD.SBQQ__Contract__c = contract.Id;
        subRecCoD.SBQQ__Account__c = testAccount.Id;
        subRecCoD.SBQQ__Quantity__c = 200;
        subRecCoD.SBQQ__OrderProduct__c = orderItemCoD.Id;
        subRecCoD.Quote_Line_Group__c = quoteLineGroup.id;
        subRecCoD.SBQQ__RequiredById__c = subRec.Id;
        insert subRecCoD;

        SBQQ.TriggerControl.enable();
    }

    @isTest
    private static void testWhenSubscriptionInsertedThenSelectorCallquerySubscriptionRecord() {
        List<SBQQ__Subscription__c> subscriptionQueryTestData = [
            SELECT id
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];
        Set<Id> subscriptionQueryTestDataId = new Set<Id>();
        for (SBQQ__Subscription__c subId : subscriptionQueryTestData) {
            subscriptionQueryTestDataId.add(subId.Id);
        }
        Test.startTest();
        List<SBQQ__Subscription__c> subscriptionQueryData = SubscriptionSelector.newInstance()
            .querySubscriptionRecords(subscriptionQueryTestDataId);
        Test.stopTest();
        System.assertEquals(
            1,
            subscriptionQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    @isTest
    private static void testWhenSubscriptionInsertedWithAccountThenSelectorCallquerySubscriptionRecord() {
        List<Account> accountData = [SELECT id FROM Account LIMIT 1];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accountData) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        List<SBQQ__Subscription__c> subscriptionQueryData = SubscriptionSelector.newInstance()
            .querySubscriptionRecordsWithAccountIds(accountIds);
        Test.stopTest();
        System.assertEquals(
            3,
            subscriptionQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test getSObjectType and getSObjectFieldList values.
     */
    @isTest
    private static void testWhenObjectTypeAndFieldListThenReturnCorrect() {
        SubscriptionSelector subscriptionInstance = new SubscriptionSelector();
        Schema.SObjectType typeOfObj = subscriptionInstance.getSObjectType();
        System.assertEquals(
            Schema.SBQQ__Subscription__c.SObjectType,
            typeOfObj,
            'The object type must be SBQQ__Subscription__c'
        );

        List<Schema.SObjectField> fieldList = subscriptionInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                SBQQ__Subscription__c.Id,
                SBQQ__Subscription__c.SBQQ__Account__c,
                SBQQ__Subscription__c.Business_Account_Id__c,
                SBQQ__Subscription__c.SBQQ__Contract__c,
                SBQQ__Subscription__c.SBQQ__OrderProduct__c,
                SBQQ__Subscription__c.SBQQ__TerminatedDate__c,
                SBQQ__Subscription__c.SBQQ__SubscriptionEndDate__c,
                SBQQ__Subscription__c.Affinity_Target_Audience__c,
                SBQQ__Subscription__c.Banner_Dates__c,
                SBQQ__Subscription__c.Banner_Type__c,
                SBQQ__Subscription__c.Bid__c,
                SBQQ__Subscription__c.Brands__c,
                SBQQ__Subscription__c.Campaign_Name__c,
                SBQQ__Subscription__c.Day_Time_of_Week__c,
                SBQQ__Subscription__c.Discount_Percentage_for_Consumer__c,
                SBQQ__Subscription__c.End_Date__c,
                SBQQ__Subscription__c.Flat_Discount_Amount_for_Consumer__c,
                SBQQ__Subscription__c.Keywords__c,
                SBQQ__Subscription__c.Max_Discount_Amount_for_Consumer__c,
                SBQQ__Subscription__c.Max_Number_of_Redemptions__c,
                SBQQ__Subscription__c.Order_Cart_Minimum__c,
                SBQQ__Subscription__c.Payment_Method__c,
                SBQQ__Subscription__c.Pricing_Type__c,
                SBQQ__Subscription__c.Start_Date__c,
                SBQQ__Subscription__c.Auto_Bidding__c,
                SBQQ__Subscription__c.Offer_detailed_description__c,
                SBQQ__Subscription__c.Term_Specific_Bidding__c,
                SBQQ__Subscription__c.Priority_UPCs__c,
                SBQQ__Subscription__c.User_Communication_Type__c,
                SBQQ__Subscription__c.Discounted_Delivery_Fee__c,
                SBQQ__Subscription__c.Menu_Item_Minimum_Quantity__c,
                SBQQ__Subscription__c.SBQQ__QuoteLine__c,
                SBQQ__Subscription__c.Quote_Line_Group__c,
                SBQQ__Subscription__c.SBQQ__RequiredById__c,
                SBQQ__Subscription__c.Integration_Source__c,
                SBQQ__Subscription__c.Package__c,
                SBQQ__Subscription__c.SBQQ__ProductName__c,
                SBQQ__Subscription__c.Unique_Identifier__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenContractIdsAreSentThenSubscriptionsWithCoDProductsAreRetrieved() {
        List<SBQQ__Subscription__c> fetchedSubscription = SubscriptionSelector.newInstance()
            .selectByContractAndCoDProduct(new Set<String>{ [SELECT Id FROM Contract LIMIT 1].Id });
        System.assertEquals(
            1,
            fetchedSubscription.size(),
            'The expected Subscription record was not fetched.'
        );
    }

    @isTest
    private static void testWhenSelectActiveSubscriptionsForContractsThenReturnCorrectRecords() {
        Test.startTest();
        List<SBQQ__Subscription__c> setupDataSubscriptionList = [
            SELECT
                Id,
                SBQQ__Product__c,
                SBQQ__Contract__c,
                SBQQ__Account__c,
                SBQQ__OrderProduct__c,
                Quote_Line_Group__c
            FROM SBQQ__Subscription__c
            LIMIT 2
        ];

        SBQQ__Subscription__c subNullDates = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        subNullDates.SBQQ__TerminatedDate__c = null;
        subNullDates.SBQQ__SubscriptionEndDate__c = null;
        subNullDates.SBQQ__Quantity__c = 200;
        insert subNullDates;

        SBQQ__Subscription__c subActiveDates = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );

        subActiveDates.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subActiveDates.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subActiveDates.SBQQ__Quantity__c = 200;
        insert subActiveDates;

        SBQQ__Subscription__c subTerminated = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        subTerminated.SBQQ__TerminatedDate__c = System.today().addDays(-1);
        subTerminated.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subTerminated.SBQQ__Quantity__c = 200;
        insert subTerminated;

        SBQQ__Subscription__c subEnded = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );

        subEnded.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subEnded.SBQQ__SubscriptionEndDate__c = System.today().addDays(-1);
        subEnded.SBQQ__Quantity__c = 200;
        insert subEnded;

        SBQQ__Subscription__c subNoContract = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );
        subNoContract.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subNoContract.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subNoContract.SBQQ__Quantity__c = 200;
        subNoContract.SBQQ__Contract__c = null;
        insert subNoContract;

        Map<Id, Id> orderItemIdSubscriptionIdMapData = SubscriptionSelector.newInstance()
            .selectOrderItemActiveSubscriptionMap(
                new Set<Id>{ setupDataSubscriptionList[0].SBQQ__Contract__c },
                false
            );

        Map<Id, Id> orderItemIdSubscriptionIdMapDriveData = SubscriptionSelector.newInstance()
            .selectOrderItemActiveSubscriptionMap(
                new Set<Id>{ setupDataSubscriptionList[0].SBQQ__Contract__c },
                true
            );

        Test.stopTest();

        //Will only return the OrderItem Ids from setupData.
        //subNullDates, and subActiveDates use the same OrderItem Ids
        System.assertEquals(
            3,
            orderItemIdSubscriptionIdMapData.keyset().size(),
            'The correct Map not returned'
        );
        System.assertEquals(
            2,
            orderItemIdSubscriptionIdMapDriveData.keyset().size(),
            'The correct Map not returned'
        );
    }

    @isTest
    private static void testWhenSelectActiveSubscriptionListBasedOnProductCodeThenReturnCorrectRecords() {
        Product2 product = new Product2();
        product.Name = 'Test Product1';
        product.Description = 'Product1';
        product.IsActive = true;
        product.ProductCode = '10017';
        insert product;

        List<SBQQ__Subscription__c> setupDataSubscriptionList = [
            SELECT
                Id,
                SBQQ__Product__c,
                SBQQ__Contract__c,
                SBQQ__Account__c,
                SBQQ__OrderProduct__c,
                Quote_Line_Group__c
            FROM SBQQ__Subscription__c
            LIMIT 2
        ];

        SBQQ__Subscription__c sub1 = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        sub1.SBQQ__TerminatedDate__c = null;
        sub1.SBQQ__SubscriptionEndDate__c = null;
        sub1.SBQQ__Quantity__c = 200;
        sub1.SBQQ__Product__c = product.Id;
        insert sub1;

        Test.startTest();

        List<SBQQ__Subscription__c> subscriptionList = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionListBasedOnProductCode(
                setupDataSubscriptionList[0].SBQQ__Contract__c,
                new Set<String>{ '10017' }
            );

        Test.stopTest();
        System.assertEquals(1, subscriptionList.size(), 'The correct List not returned');
    }

    @isTest
    private static void testWhenSelectActiveSubsForContractsThenReturnCorrectRecords() {
        Test.startTest();
        List<SBQQ__Subscription__c> setupDataSubscriptionList = [
            SELECT
                Id,
                SBQQ__Product__c,
                SBQQ__Contract__c,
                SBQQ__Account__c,
                SBQQ__OrderProduct__c,
                Quote_Line_Group__c
            FROM SBQQ__Subscription__c
            LIMIT 2
        ];

        SBQQ__Subscription__c subNullDates = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        subNullDates.SBQQ__TerminatedDate__c = null;
        subNullDates.SBQQ__SubscriptionEndDate__c = null;
        subNullDates.SBQQ__Quantity__c = 200;
        insert subNullDates;

        SBQQ__Subscription__c subActiveDates = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );

        subActiveDates.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subActiveDates.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subActiveDates.SBQQ__Quantity__c = 200;
        insert subActiveDates;

        SBQQ__Subscription__c subTerminated = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        subTerminated.SBQQ__TerminatedDate__c = System.today().addDays(-1);
        subTerminated.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subTerminated.SBQQ__Quantity__c = 200;
        insert subTerminated;

        SBQQ__Subscription__c subEnded = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );

        subEnded.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subEnded.SBQQ__SubscriptionEndDate__c = System.today().addDays(-1);
        subEnded.SBQQ__Quantity__c = 200;
        insert subEnded;

        SBQQ__Subscription__c subNoContract = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[1]
        );
        subNoContract.SBQQ__TerminatedDate__c = System.today().addDays(5);
        subNoContract.SBQQ__SubscriptionEndDate__c = System.today().addDays(5);
        subNoContract.SBQQ__Quantity__c = 200;
        subNoContract.SBQQ__Contract__c = null;
        insert subNoContract;

        List<SBQQ__Subscription__c> subscriptionListDataNotDrive = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionsList(
                new Set<Id>{ setupDataSubscriptionList[0].SBQQ__Contract__c },
                false
            );

        List<SBQQ__Subscription__c> subscriptionListDataDrive = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionsList(
                new Set<Id>{ setupDataSubscriptionList[0].SBQQ__Contract__c },
                true
            );

        Test.stopTest();
        System.assertEquals(
            5,
            subscriptionListDataNotDrive.size(),
            'The correct List not returned'
        );
        System.assertEquals(3, subscriptionListDataDrive.size(), 'The correct List not returned');
    }

    private static SBQQ__Subscription__c createSubsciptionFromExistingTestSub(
        SBQQ__Subscription__c sub
    ) {
        SBQQ__Subscription__c returnSub = new SBQQ__Subscription__c();
        returnSub.SBQQ__Product__c = sub.SBQQ__Product__c;
        returnSub.SBQQ__Contract__c = sub.SBQQ__Contract__c;
        returnSub.SBQQ__Account__c = sub.SBQQ__Account__c;
        returnSub.SBQQ__OrderProduct__c = sub.SBQQ__OrderProduct__c;
        return returnSub;
    }

    @isTest
    private static void testWhenSubscriptionWithSelectedProductThenQuerySubscriptionRecord() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account storeAccount = new Account(
            Name = 'Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345'
        );
        insert storeAccount;
        Account franchiseeAccount = new Account(
            Name = 'TestAccount1',
            Type = 'Corporate',
            Segment__c = SMB_SEGMENT_TYPE
        );
        insert franchiseeAccount;
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'DashPass'),
            new Product2(Name = 'Pickup'),
            new Product2(Name = 'Test')
        };
        insert products;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        SBQQ__QuoteLineGroup__c quoteLineGroup = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[0].Id,
                SBQQ__Contract__c = contract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            ),
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[1].Id,
                SBQQ__Contract__c = contract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            ),
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[2].Id,
                SBQQ__Contract__c = contract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            )
        };
        insert subscriptions;

        SubscriptionSelector subscriptionInstance = new SubscriptionSelector();
        List<SBQQ__Subscription__c> retrievedSubscription = subscriptionInstance.selectByContractAndProducts(
            new Set<String>{ contract.Id }
        );

        Test.stopTest();
        System.assertEquals(
            2,
            retrievedSubscription.size(),
            'The number of return records is not matching with expected records.'
        );
    }

    @isTest
    private static void testWhenSubscriptionWithSelectedPackageThenQuerySubscriptionRecord() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account storeAccount = new Account(
            Name = 'Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345'
        );
        insert storeAccount;
        Account franchiseeAccount = new Account(
            Name = 'TestAccount1',
            Type = 'Corporate',
            Segment__c = SMB_SEGMENT_TYPE
        );
        insert franchiseeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        SBQQ__QuoteLineGroup__c quoteLineGroup = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Package__c = 'Storefront',
                SBQQ__Contract__c = contract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            )
        };
        insert subscriptions;

        SubscriptionSelector subscriptionInstance = new SubscriptionSelector();
        List<SBQQ__Subscription__c> retrievedSubscription = subscriptionInstance.selectByContractAndPackages(
            new Set<String>{ contract.Id }
        );

        Test.stopTest();
        System.assertEquals(
            1,
            retrievedSubscription.size(),
            'The number of return records is not matching with expected records.'
        );
    }

    /**
     * @description This is test method to test when contract has subscriptions with alcohol products.
     */

    @isTest
    private static void testWhenThePassedContractIdHasSubscriptionsWithAlcoholProductsThenReturnSubscriptions() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account storeAccount = new Account(
            Name = 'Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345'
        );
        insert storeAccount;
        Account franchiseeAccount = new Account(
            Name = 'TestAccount1',
            Type = 'Corporate',
            Segment__c = SMB_SEGMENT_TYPE
        );
        insert franchiseeAccount;
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Service Rate'),
            new Product2(Name = 'Alcohol Delivery'),
            new Product2(Name = 'Alcohol Pickup')
        };
        insert products;
        Contract dominosContract = new Contract(AccountId = franchiseeAccount.Id);
        insert dominosContract;
        Contract starBucksContract = new Contract(AccountId = franchiseeAccount.Id);
        insert starBucksContract;
        Contract mcDonaldsContract = new Contract(AccountId = franchiseeAccount.Id);
        insert mcDonaldsContract;

        SBQQ__QuoteLineGroup__c quoteLineGroup = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[0].Id,
                SBQQ__Contract__c = dominosContract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            ),
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[1].Id,
                SBQQ__Contract__c = starBucksContract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            ),
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[2].Id,
                SBQQ__Contract__c = mcDonaldsContract.Id,
                SBQQ__Account__c = franchiseeAccount.Id,
                Quote_Line_Group__c = quoteLineGroup.Id,
                SBQQ__Quantity__c = 200
            )
        };
        insert subscriptions;

        SubscriptionSelector subscriptionInstance = new SubscriptionSelector();
        List<SBQQ__Subscription__c> retrievedSubscription1 = subscriptionInstance.selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
            new Set<String>{ mcDonaldsContract.Id }
        );
        List<SBQQ__Subscription__c> retrievedSubscription2 = subscriptionInstance.selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
            new Set<String>{ starBucksContract.Id }
        );

        Test.stopTest();
        System.assertEquals(
            retrievedSubscription1[0].Id,
            subscriptions[2].Id,
            'The return records is not matching with expected records.'
        );
        System.assertEquals(
            retrievedSubscription2[0].Id,
            subscriptions[1].Id,
            'The return records is not matching with expected records.'
        );

        System.assertEquals(
            1,
            retrievedSubscription1.size(),
            'The number of return records is not matching with expected records.'
        );
        System.assertEquals(
            1,
            retrievedSubscription2.size(),
            'The number of return records is not matching with expected records.'
        );
    }

    /**
     * @description This is test method to test when account has subscriptions with alcohol products.
     */

    @isTest
    private static void testWhenPassedAccountIdHasSubscriptionsWithAlcoholProductsThenReturnSubscriptions() {
        Test.startTest();
        Account mcDonaldAccount = new Account(
            Name = 'McdonaldCorp',
            Type = 'Corporate',
            Segment__c = SMB_SEGMENT_TYPE
        );
        insert mcDonaldAccount;

        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Alcohol Delivery'),
            new Product2(Name = 'Alcohol Pickup')
        };
        insert products;
        Contract dominosContract = new Contract(AccountId = mcDonaldAccount.Id);
        insert dominosContract;
        Contract starBucksContract = new Contract(AccountId = mcDonaldAccount.Id);
        insert starBucksContract;
        Contract mcDonaldsContract = new Contract(AccountId = mcDonaldAccount.Id);
        insert mcDonaldsContract;

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[0].Id,
                SBQQ__Contract__c = dominosContract.Id,
                SBQQ__Account__c = mcDonaldAccount.Id,
                SBQQ__Quantity__c = 200
            ),
            new SBQQ__Subscription__c(
                SBQQ__Product__c = products[1].Id,
                SBQQ__Contract__c = starBucksContract.Id,
                SBQQ__Account__c = mcDonaldAccount.Id,
                SBQQ__Quantity__c = 200
            )
        };
        insert subscriptions;

        SubscriptionSelector subscriptionInstance = new SubscriptionSelector();
        List<SBQQ__Subscription__c> retrievedSubscription = subscriptionInstance.selectSubscriptionsWithAlcoholProductsByAccountIds(
            new Set<Id>{ mcDonaldAccount.Id }
        );

        Test.stopTest();
        System.assertEquals(
            retrievedSubscription[0].Id,
            subscriptions[0].Id,
            'The return records is not matching with expected records.'
        );
        System.assertEquals(
            retrievedSubscription[1].Id,
            subscriptions[1].Id,
            'The return records is not matching with expected records.'
        );
        System.assertEquals(
            2,
            retrievedSubscription.size(),
            'The number of return records is not matching with expected records.'
        );
    }

    /**
     * @description This is test method to select Subsriptions With Services
     */
    @isTest
    private static void testWhenPassedSubscriptionIdHasSubscriptionsWithServicesThenReturnSubscriptions() {
        Test.startTest();
        List<Account> accList = [
            SELECT id
            FROM Account
            LIMIT 1
        ];

        List<SBQQ__Subscription__c> subsList = [
            SELECT id, SBQQ__OrderProduct__c
            FROM SBQQ__Subscription__c
        ];

        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            Name = 'Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345',
            ParentId = accList[0].id
        );
        insert storeAccount;

        Merchant_Service__c ms1 = new Merchant_Service__c();
        ms1.Account__c = storeAccount.Id;
        ms1.Order_Product__c = subsList[0].SBQQ__OrderProduct__c;
        ms1.Mx_Agreed_to_Product__c = 'Yes';
        ms1.Subscription__c = subsList[0].Id;
        insert ms1;

        Merchant_Service__c ms2 = new Merchant_Service__c();
        ms2.Account__c = storeAccount.Id;
        ms2.Order_Product__c = subsList[1].SBQQ__OrderProduct__c;
        ms2.Mx_Agreed_to_Product__c = 'Yes';
        ms2.Subscription__c = subsList[1].Id;
        insert ms2;

        List<SBQQ__Subscription__c> returnedSubsList = SubscriptionSelector.newInstance()
            .selectSubsriptionsWithServices(new Set<Id>{ subsList[0].Id, subsList[1].Id });
        Test.stopTest();
        System.assertEquals(2, returnedSubsList.size(), 'Two Records should be retuned');
        System.assertEquals(
            1,
            returnedSubsList[0].Merchant_Services__r.size(),
            'One Record should be retuned'
        );
        System.assertEquals(
            1,
            returnedSubsList[1].Merchant_Services__r.size(),
            'One Record should be retuned'
        );
    }

    @isTest
    private static void testWhenSubscriptionInsertedWithGroupThenSelectorCallquerySubscriptionRecord() {
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupData = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        List<Id> quoteLineGroupIds = new List<Id>();
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupData) {
            quoteLineGroupIds.add(qlg.Id);
        }
        Test.startTest();
        List<SBQQ__Subscription__c> quoteLineGroupQueryData = SubscriptionSelector.newInstance()
            .selectSubscriptionRecordsByGroup(quoteLineGroupIds);
        Test.stopTest();
        System.assertEquals(
            3,
            quoteLineGroupQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test when ids are passed then return subscriptions.
     */
    @isTest
    private static void testWhenIdsArePassedThenReturnSubscriptions() {
        Test.startTest();
        List<SBQQ__Subscription__c> subsList = [
            SELECT id, SBQQ__OrderProduct__c, SBQQ__QuoteLine__c
            FROM SBQQ__Subscription__c
        ];

        List<SBQQ__Subscription__c> returnedSubsList = SubscriptionSelector.newInstance()
            .selectBySubscriptionIds(new Set<Id>{ subsList[0].Id, subsList[1].Id });
        Test.stopTest();
        System.assertEquals(2, returnedSubsList.size(), 'Two Records should be retuned');
    }

    @isTest
    private static void testWhenOrderItemPassedThenSelectorCallquerySubscriptionRecordsByPrimaryOrderProduct() {
        List<OrderItem> orderItemData = [SELECT id FROM OrderItem LIMIT 1];
        Set<Id> orderItemIds = new Set<Id>();
        for (OrderItem oi : orderItemData) {
            orderItemIds.add(oi.Id);
        }

        Test.startTest();
        List<SBQQ__Subscription__c> queriedSubscriptionData = SubscriptionSelector.newInstance()
            .selectSubscriptionRecordsByPrimaryOrderProduct(orderItemIds);
        Test.stopTest();
        System.assertEquals(
            1,
            queriedSubscriptionData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test when ids are passed then return groupId.
     */
    @isTest
    private static void testWhenContractIdPassedThenReturnGroupId() {
        List<Contract> contractData = [SELECT id FROM Contract LIMIT 1];
        List<SBQQ__Subscription__c> setupDataSubscriptionList = [
            SELECT
                Id,
                SBQQ__TerminatedDate__c,
                SBQQ__SubscriptionEndDate__c,
                SBQQ__Quantity__c,
                SBQQ__Product__c,
                SBQQ__Contract__c,
                SBQQ__Account__c,
                SBQQ__OrderProduct__c
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];

        SBQQ__Subscription__c terminatedSubscription = createSubsciptionFromExistingTestSub(
            setupDataSubscriptionList[0]
        );

        terminatedSubscription.SBQQ__TerminatedDate__c = System.today().addDays(-5);
        terminatedSubscription.SBQQ__SubscriptionEndDate__c = System.today().addDays(-5);
        terminatedSubscription.SBQQ__Quantity__c = 200;
        insert terminatedSubscription;

        Test.startTest();

        Id groupId = SubscriptionSelector.newInstance()
            .selectQuoteLineGroupOnSubscription(contractData[0].id);
        Test.stopTest();
        System.assertNotEquals(null, groupId, 'Id should not be null');
    }

    /**
     * @description This is test method to test when parent subscription Ids are passed then return subscriptions.
     */
    @isTest
    private static void testWhenSubscriptionWithSelectedParentThenQuerySubscriptionRecord() {
        List<SBQQ__Subscription__c> subsList = [
            SELECT Id, SBQQ__OrderProduct__c, SBQQ__QuoteLine__c, SBQQ__RequiredById__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__RequiredById__c != NULL
        ];
        Set<String> parentSubscriptionIds = new Set<String>();
        for (SBQQ__Subscription__c sub : subsList) {
            parentSubscriptionIds.add(sub.SBQQ__RequiredById__c);
        }

        Test.startTest();
        List<SBQQ__Subscription__c> subscriptionQueryData = SubscriptionSelector.newInstance()
            .selectChildSubscriptions(parentSubscriptionIds);
        Test.stopTest();
        System.assertEquals(
            2,
            subscriptionQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test when contract Ids is passed then return subscriptions.
     */
    @isTest
    private static void testWhenPassedContractIdThenReturnSubscriptions() {
        Test.startTest();
        List<Account> accList = [
            SELECT id
            FROM Account
            LIMIT 1
        ];

        List<SBQQ__Subscription__c> subsList = [
            SELECT
                id,
                Package__c,
                SBQQ__Product__r.Name,
                Final_Commission__c,
                Final_Fee__c,
                SBQQ__TerminatedDate__c,
                SBQQ__StartDate__c,
                SBQQ__EndDate__c,
                SBQQ__Contract__c,
                SBQQ__OrderProduct__c
            FROM SBQQ__Subscription__c
        ];

        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            Name = 'Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345',
            ParentId = accList[0].id
        );
        insert storeAccount;

        List<SBQQ__Subscription__c> returnedSubsList = SubscriptionSelector.newInstance()
            .selectByContractId(subsList[0].SBQQ__Contract__c);
        Test.stopTest();
        System.assertEquals(
            3,
            returnedSubsList.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test when contract Ids are passed then return subscriptions.
     */
    @isTest
    private static void testWhenContractIdsArePassedThenSelectorCallselectSubscriptionRecordsByContract() {
        List<Product2> prodData = [SELECT id FROM Product2 LIMIT 2];

        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 55,
            SBQQ__ConfiguredSKU__c = prodData[0].Id,
            SBQQ__OptionalSKU__c = prodData[1].Id,
            Active_Rate_Eligible__c = true
        );
        insert productOption;
        List<SBQQ__QuoteLineGroup__c> groupData = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];

        List<Contract> contractData = [SELECT id FROM Contract LIMIT 1];
        List<SBQQ__Subscription__c> subscriptionData = [
            SELECT id
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];
        subscriptionData[0].SBQQ__ProductOption__c = productOption.Id;
        subscriptionData[0].SBQQ__Contract__c = contractData[0].Id;
        subscriptionData[0].SBQQ__TerminatedDate__c = null;
        subscriptionData[0].SBQQ__SubscriptionEndDate__c = null;
        subscriptionData[0].Quote_Line_Group__c = groupData[0].Id;
        update subscriptionData[0];
        Test.startTest();

        List<SBQQ__Subscription__c> queriedSubscriptionData = SubscriptionSelector.newInstance()
            .selectSubscriptionRecordsByContract(new Set<Id>{ contractData[0].Id });
        Test.stopTest();

        System.assertEquals(
            1,
            queriedSubscriptionData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test when subscription Ids
     * are passed then return subscription.
     */
    @isTest
    private static void testWhenSubscriptionIdsPassedForWorkOrderCreationThenReturnSubscriptions() {
        Account account = new Account(
            Name = 'Test',
            Creation_Source__c = SSMO_CREATION_SOURCE,
            Order_Protocol__c = POS_ORDER_PROTOCOL,
            Segment__c = SMB_SEGMENT_TYPE
        );
        insert account;
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Unique_Identifier__c = '123455677',
            Integration_Source__c = SOURCE_SSOB
        );
        insert quote;
        Contract contract = new Contract(
            AccountId = account.Id,
            Status = DRAFT_STATUS,
            SBQQ__Quote__c = quote.Id
        );
        insert contract;
        Product2 product = new Product2(
            Name = STOREFRONT_PRODUCT_TYPE,
            Platform__c = STOREFRONT_PRODUCT_TYPE
        );
        insert product;
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Contract__c = contract.Id,
            SBQQ__Product__c = product.Id,
            SBQQ__Quantity__c = 1
        );
        insert subscription;

        List<SBQQ__Subscription__c> subscriptionQueryData = SubscriptionSelector.newInstance()
            .getSubscriptionsForWorkOrderCreation(new Set<Id>{ subscription.Id });
        Test.stopTest();
        System.assertEquals(1, subscriptionQueryData.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description This is test method  with to check for Subscription.
     */
    @isTest
    private static void testWhenContractIdsWithParametersPassedThenReturnSubscriptions() {
        List<Contract> contract = [SELECT Id, AccountId FROM Contract LIMIT 1];
        Set<Id> contractIds = new Set<Id>{ contract[0].Id };

        Set<String> subscriptionsFields = new Set<String>();
        subscriptionsFields.add('SBQQ__Product__c');
        subscriptionsFields.add('SBQQ__Contract__c');
        subscriptionsFields.add('Quote_Line_Group__c');

        Test.startTest();
        List<SBQQ__Subscription__c> subscriptionQueryData = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionsByContractIdwithDynamicFields(
                contractIds,
                subscriptionsFields
            );
        Test.stopTest();
        System.assertEquals(
            3,
            subscriptionQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }
    /**
     * @description It is used to validate when contract Ids are passed then return active subscriptions.
     */
    @isTest
    private static void testWhenContractIdsArePassedThenActiveSubscriptionsAreReturned() {
        Test.startTest();
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        testAccountRec.Segment__c = SMB_SEGMENT_TYPE;
        testAccountRec.Deck_Rank__c = null;
        update testAccountRec;

        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            true
        );
        List<SBQQ__QuoteLineGroup__c> groupData = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        List<Product2> prodData = [SELECT id FROM Product2 LIMIT 2];
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 55,
            SBQQ__ConfiguredSKU__c = prodData[0].Id,
            SBQQ__OptionalSKU__c = prodData[1].Id
        );
        insert productOption;
        SBQQ__QuoteLine__c newQuoteLine1 = CPQTestDataFactory.createQuoteLine(
            prodData[0],
            newQuote,
            true
        );
        List<Contract> contractData = [SELECT id FROM Contract LIMIT 1];
        List<SBQQ__Subscription__c> subscriptionData = [
            SELECT id
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];

        subscriptionData[0].SBQQ__ProductOption__c = productOption.Id;
        subscriptionData[0].SBQQ__Contract__c = contractData[0].Id;
        subscriptionData[0].SBQQ__TerminatedDate__c = null;
        subscriptionData[0].SBQQ__SubscriptionEndDate__c = null;
        subscriptionData[0].Quote_Line_Group__c = groupData[0].Id;
        subscriptionData[0].SBQQ__QuoteLine__c = newQuoteLine1.Id;
        update subscriptionData[0];

        List<SBQQ__Subscription__c> queriedSubscriptionData = SubscriptionSelector.newInstance()
            .getSubscriptionsByContractIds(new Set<Id>{ contractData[0].Id });
        Test.stopTest();

        System.assertEquals(1, queriedSubscriptionData.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate when contract Ids and inactive subscriptions are
     * are passed then do not return subscriptions.
     */
    @isTest
    private static void testWhenContractIdsAndInactiveSubscriptionsArePassedThenNoSubscriptionsAreReturned() {
        Test.startTest();
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        testAccountRec.Segment__c = SMB_SEGMENT_TYPE;
        testAccountRec.Deck_Rank__c = null;
        update testAccountRec;

        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            true
        );
        List<SBQQ__QuoteLineGroup__c> groupData = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        List<Product2> prodData = [SELECT id FROM Product2 LIMIT 2];
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 55,
            SBQQ__ConfiguredSKU__c = prodData[0].Id,
            SBQQ__OptionalSKU__c = prodData[1].Id
        );
        insert productOption;
        SBQQ__QuoteLine__c newQuoteLine1 = CPQTestDataFactory.createQuoteLine(
            prodData[0],
            newQuote,
            true
        );

        List<Contract> contractData = [SELECT id FROM Contract LIMIT 1];
        List<SBQQ__Subscription__c> subscriptionData = [
            SELECT id
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];

        subscriptionData[0].SBQQ__ProductOption__c = productOption.Id;
        subscriptionData[0].SBQQ__Contract__c = contractData[0].Id;
        subscriptionData[0].SBQQ__TerminatedDate__c = System.today().addDays(-1);
        subscriptionData[0].SBQQ__SubscriptionEndDate__c = null;
        subscriptionData[0].Quote_Line_Group__c = groupData[0].Id;
        subscriptionData[0].SBQQ__QuoteLine__c = newQuoteLine1.Id;
        update subscriptionData[0];

        List<SBQQ__Subscription__c> queriedSubscriptionData = SubscriptionSelector.newInstance()
            .getSubscriptionsByContractIds(new Set<Id>{ contractData[0].Id });
        Test.stopTest();

        System.assertEquals(0, queriedSubscriptionData.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}