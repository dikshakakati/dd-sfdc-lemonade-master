/**
 * @author Deloitte
 * @date 10/05/2022
 * @description This is test class for MerchantSelector class
 */
@isTest(SeeAllData=false)
public class MerchantSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String CURRENCY_CODE_USD = 'USD';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of Records returned does not match the expected outcome';
    private static final String INCORRECT_ID_ASSERT_MESSAGE = 'Unexpected Result: Record Id returned does not match the expected outcome';
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final String PRODUCT_NAME = 'Alcohol Delivery';
    private static final String PRODUCT_NAME_BASIC_PACKAGE = 'Basic Package';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRODUCT_CODE_10017 = '10017';
    private static final String PRODUCT_CODE_10033 = '10033';
    private static final String PRODUCT_CODE_10012 = '10012';
    private static final String RATE_CHANGE_ACTIVATION_STATUS = 'New';
    private static final String RATE_CHANGE_STATUS = 'Approved';
    private static final String STATUS_DRAFT = 'Draft';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String UNITED_STATES = 'United States';
    private static final String BILLING_STREET = '123 Test Street';
    private static final String NAME_ACCOUNT = 'Test Acc';
    private static final String NAME_ACCOUNT_CHILD = 'Test Acc Child';
    private static final String BILLING_CITY = 'Missoula';
    private static final String BILLING_CITY2 = 'New York';
    private static final String BILLING_STATE = 'Montana';
    private static final String BILLING_CODE = '59801';
    private static final String BILLING_CODE2 = '59802';
    private static final String ASSERT_MESSAGE = 'Number of merchant services returned is as expected';
    private static final String ASSERT_MESSAGE_ERROR = 'Number of merchant services returned is not as expected';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String PACKAGE_EXCLUSION = 'Basic Package,Plus Package,Premier Package,Marketplace,Self Delivery,Self Delivery - Basic,Self Delivery - Premier';
    private static final String DELIMITER_COMMA = ',';
    private static final String ASSERTION_MESSAGE = 'Zero Records should be retuned';
    private static final String QUOTE_SEGMENT = 'SMB';
    private static final String PRIMARY_VERTICAL = 'Hot & Prepared';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE_NAME = 'Prospective';
    private static final String OPPORTUNITY_DEAL_TYPE = 'Standard';
    private static final String OPPORTUNITY_SUB_TYPE = 'Former Partner';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();

    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.Type = 'Holding Group';
        acc.Partnership_Status__c = 'Prospective Partner';
        acc.Account_Lifecycle_Status__c = 'Unvetted';
        acc.Primary_Vertical__c = 'Convenience';
        acc.Name = 'Test Business Acc';
        acc.Segment__c = QUOTE_SEGMENT;
        acc.Legal_Business_Name__c = 'Test';
        acc.BillingCountry = 'United States';
        insert acc;
        Account accStore = new Account();
        accStore.ParentId = acc.Id;
        accStore.Name = 'Test Store Acc';
        accStore.type = 'Holding Group';
        accStore.Partnership_Status__c = 'Prospective Partner';
        accStore.BillingCountry = 'United States';
        accStore.BillingCity = 'new york';
        accStore.BillingPostalCode = 'lem990';
        accStore.BillingState = 'New York';
        accStore.BillingStreet = 'Test Street';
        accStore.Franchise_Parent__c = acc.Id;
        accStore.Segment__c = QUOTE_SEGMENT;
        accStore.Legal_Business_Name__c = 'Test';
        accStore.Primary_Vertical__c = 'Rx';
        insert accStore;
        Product2 product = new Product2();
        Product.name = 'Test product';
        insert product;
        Contract contract = new Contract();
        contract.AccountId = accStore.Id;
        contract.StartDate = system.today();
        contract.ContractTerm = 12;
        insert contract;
        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contract.Id;
        subRec.SBQQ__Account__c = accStore.Id;
        subRec.SBQQ__Quantity__c = 200;
        insert subRec;
        Merchant_Service__c merchSer = new Merchant_Service__c();
        merchSer.Product__c = product.Id;
        MerchSer.Account__c = accStore.Id;
        MerchSer.Subscription__c = subRec.Id;
        insert merchSer;
    }
    @isTest
    private static void testWhenMerchantInsertThenSelectorCallqueryMerchantRecord() {
        List<Merchant_Service__c> merchantQueryTestData = [
            SELECT id
            FROM Merchant_Service__c
            LIMIT 1
        ];
        Set<Id> merchantQueryTestDataId = new Set<Id>();
        for (Merchant_Service__c merId : merchantQueryTestData) {
            merchantQueryTestDataId.Add(merId.Id);
        }
        Test.startTest();
        List<Merchant_Service__c> merchantQueryData = MerchantSelector.newInstance()
            .queryMerchantRecords(merchantQueryTestDataId);
        Test.stopTest();
        System.assertEquals(
            1,
            merchantQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    @isTest
    private static void testWhenMerchantServiceInsertedWithAccountThenSelectorCallquerySubscriptionRecord() {
        List<Account> accountData = [SELECT id FROM Account WHERE name = 'Test Store Acc' LIMIT 1];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accountData) {
            accountIds.add(acc.Id);
        }
        Test.startTest();
        List<Merchant_Service__c> merchantQueryData = MerchantSelector.newInstance()
            .queryMerchantRecordsWithAccountIds(accountIds);
        Test.stopTest();
        System.assertEquals(
            1,
            merchantQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test queryMerchantRecordsWithFranchiseParentAccountIds.
     */
    @isTest
    private static void testWhenQueryByFranciseParentThenReturnRecords() {
        List<Account> accountData = [
            SELECT Id, Franchise_Parent__c
            FROM Account
            WHERE name = 'Test Store Acc'
            LIMIT 1
        ];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accountData) {
            accountIds.add(acc.Franchise_Parent__c);
        }
        Test.startTest();

        List<Merchant_Service__c> merchantQueryData = MerchantSelector.newInstance()
            .queryMerchantRecordsWithFranchiseParentAccountIds(accountIds);
        Test.stopTest();
        System.assertEquals(
            1,
            merchantQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to test queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId.
     */
    @isTest
    private static void testWhenQueryActiveMarketPlaceThenReturnRecords() {
        Test.startTest();

        SBQQ.TriggerControl.disable();

        Product2 bundleProductMarketplace = CPQTestDataFactory.createProduct(false);
        bundleProductMarketplace.ProductCode = PRODUCT_CODE_10017;
        insert bundleProductMarketplace;
        Product2 productMarketPlace = CPQTestDataFactory.createProduct(false);
        productMarketPlace.ProductCode = PRODUCT_CODE_10033;
        insert productMarketPlace;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(
            bundleProductMarketplace,
            'USD',
            true
        );
        Account testAccount = TestDataFactory.createAccount(false);
        testAccount.BillingCountry = UNITED_STATES;
        testAccount.BillingStreet = BILLING_STREET;
        testAccount.BillingCity = BILLING_CITY;
        testAccount.BillingState = BILLING_STATE;
        testAccount.BillingPostalCode = BILLING_CODE;
        testAccount.Legal_Business_Name__c = BUSINESS_ACCOUNT;
        testAccount.Primary_Vertical__c = PRIMARY_VERTICAL;
        insert testAccount;
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLineBundleMarketplace = CPQTestDataFactory.createQuoteLine(
            bundleProductMarketplace,
            quote,
            true
        );
        SBQQ__QuoteLine__c quoteLineMarketplace = CPQTestDataFactory.createQuoteLine(
            productMarketPlace,
            quote,
            true
        );

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //We need an Actiavtion Order.
        insert order;
        OrderItem orderItemBundleMarketplace = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineBundleMarketplace,
            pbe.Id,
            true
        );
        OrderItem orderItemMarketplace = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineMarketplace,
            pbe.Id,
            false
        );
        orderItemMarketplace.SBQQ__RequiredBy__c = orderItemBundleMarketplace.Id;
        insert orderItemMarketplace;

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = bundleProductMarketplace.Id;
        subRec.SBQQ__Contract__c = null;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        insert subRec;

        Merchant_Service__c merchSerBundleMarketplace = new Merchant_Service__c();
        merchSerBundleMarketplace.Account__c = testAccount.Id;
        merchSerBundleMarketplace.Order_Product__c = orderItemBundleMarketplace.Id;
        merchSerBundleMarketplace.Mx_Agreed_to_Product__c = 'Yes';
        merchSerBundleMarketplace.Subscription__c = subRec.Id;
        insert merchSerBundleMarketplace;
        Merchant_Service__c merchSerMarketplace = new Merchant_Service__c();
        merchSerMarketplace.Account__c = testAccount.Id;
        merchSerMarketplace.Order_Product__c = orderItemMarketplace.Id;
        merchSerMarketplace.Mx_Agreed_to_Product__c = 'Yes';
        merchSerMarketplace.Subscription__c = subRec.Id;
        insert merchSerMarketplace;

        SBQQ.TriggerControl.enable();

        List<Merchant_Service__c> returnedListMarketPlace = MerchantSelector.newInstance()
            .queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(
                new Set<Id>{ testAccount.Id }
            );

        List<Merchant_Service__c> returnedListDrive = MerchantSelector.newInstance()
            .queryActiveDriveServicesWithDraftOrderProductsByAccountId(
                new Set<Id>{ testAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(2, returnedListMarketPlace.size(), 'Two Records should be retuned');
        System.assertEquals(0, returnedListDrive.size(), 'Zero Records should be retuned');
    }

    /**
     * @description This is test method to test queryActiveDriveServicesWithDraftOrderProductsByAccountId.
     */
    @isTest
    private static void testWhenQueryActiveDriveThenReturnRecords() {
        Test.startTest();

        SBQQ.TriggerControl.disable();

        Product2 bundleProductDrive = CPQTestDataFactory.createProduct(false);
        bundleProductDrive.ProductCode = PRODUCT_CODE_10012;
        insert bundleProductDrive;
        Product2 productDrive = CPQTestDataFactory.createProduct(false);
        productDrive.ProductCode = PRODUCT_CODE_10033;
        insert productDrive;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(
            bundleProductDrive,
            'USD',
            true
        );
        Account testAccount = TestDataFactory.createAccount(false);
        testAccount.BillingCountry = UNITED_STATES;
        testAccount.BillingStreet = BILLING_STREET;
        testAccount.BillingCity = BILLING_CITY;
        testAccount.BillingState = BILLING_STATE;
        testAccount.BillingPostalCode = BILLING_CODE;
        testAccount.Legal_Business_Name__c = BUSINESS_ACCOUNT;
        testAccount.Primary_Vertical__c = PRIMARY_VERTICAL;

        insert testAccount;
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);

        SBQQ__QuoteLine__c quoteLineBundleDrive = CPQTestDataFactory.createQuoteLine(
            bundleProductDrive,
            quote,
            true
        );
        SBQQ__QuoteLine__c quoteLineDrive = CPQTestDataFactory.createQuoteLine(
            productDrive,
            quote,
            true
        );

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //We need an Actiavtion Order.
        insert order;

        OrderItem orderItemBundleDrive = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineBundleDrive,
            pbe.Id,
            true
        );
        OrderItem orderItemDrive = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineDrive,
            pbe.Id,
            false
        );
        orderItemDrive.SBQQ__RequiredBy__c = orderItemBundleDrive.Id;
        orderItemDrive.SBQQ__Status__c = STATUS_DRAFT;
        insert orderItemDrive;

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = bundleProductDrive.Id;
        subRec.SBQQ__Contract__c = null;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        insert subRec;

        Merchant_Service__c merchSerBundleDrive = new Merchant_Service__c();
        merchSerBundleDrive.Account__c = testAccount.Id;
        merchSerBundleDrive.Order_Product__c = orderItemBundleDrive.Id;
        merchSerBundleDrive.Mx_Agreed_to_Product__c = 'Yes';
        merchSerBundleDrive.Subscription__c = subRec.Id;
        insert merchSerBundleDrive;
        Merchant_Service__c merchSerDrive = new Merchant_Service__c();
        merchSerDrive.Account__c = testAccount.Id;
        merchSerDrive.Order_Product__c = orderItemDrive.Id;
        merchSerDrive.Mx_Agreed_to_Product__c = 'Yes';
        merchSerDrive.Subscription__c = subRec.Id;
        insert merchSerDrive;

        SBQQ.TriggerControl.enable();

        List<Merchant_Service__c> returnedListMarketPlace = MerchantSelector.newInstance()
            .queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(
                new Set<Id>{ testAccount.Id }
            );

        List<Merchant_Service__c> returnedListDrive = MerchantSelector.newInstance()
            .queryActiveDriveServicesWithDraftOrderProductsByAccountId(
                new Set<Id>{ testAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(0, returnedListMarketPlace.size(), 'Two Records should be retuned');
        System.assertEquals(2, returnedListDrive.size(), 'Zero Records should be retuned');
    }

    /**
     * @description This is test method to test getSObjectType and getSObjectFieldList values.
     */
    @isTest
    private static void testWhenObjectTypeAndFieldListThenReturnCorrect() {
        MerchantSelector merchantSelectorInstance = new MerchantSelector();
        Schema.SObjectType typeOfObj = merchantSelectorInstance.getSObjectType();
        System.assertEquals(
            Schema.Merchant_Service__c.SObjectType,
            typeOfObj,
            'The object type must be Merchant_Service__c'
        );

        List<Schema.SObjectField> fieldList = merchantSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Merchant_Service__c.Id,
                Merchant_Service__c.Account__c,
                Merchant_Service__c.Business_Account_Id__c,
                Merchant_Service__c.Service_Product_Name__c,
                Merchant_Service__c.Trial_Commission__c,
                Merchant_Service__c.Trial_Fee__c,
                Merchant_Service__c.Account__r.Name,
                Merchant_Service__c.Start_Date__c,
                Merchant_Service__c.Product__c,
                Merchant_Service__c.Product_Code__c,
                Merchant_Service__c.Order_Product__c,
                Merchant_Service__c.Subscription__c,
                Merchant_Service__c.Active__c,
                Merchant_Service__c.Mx_Agreed_to_Product__c,
                Merchant_Service__c.Name,
                Merchant_Service__c.Final_Fee__c,
                Merchant_Service__c.Final_Commission__c,
                Merchant_Service__c.Bundle__c,
                Merchant_Service__c.Account__r.CreatedDate
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description To test the query on Merchant Service object having associated Product
     * with name as Alcohol Delivery or Alcohol Pickup when Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenMerchantServicesWithAlcoholProductsReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = 'Enterprise';
        insert businessAccount;
        Opportunity opportunity = CPQTestDataFactory.createOpportunity(businessAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunity,
            businessAccount,
            null,
            true
        );
        Product2 alcoholProduct = new Product2();
        alcoholProduct.name = PRODUCT_NAME;
        alcoholProduct.ProductCode = PRODUCT_CODE_10033;
        alcoholProduct.Work_Order_Type__c = WORKORDER_TYPE_DRIVE;
        insert alcoholProduct;
        Product2 marketplaceProduct = new Product2();
        marketplaceProduct.name = PRODUCT_NAME_MARKETPLACE;
        marketplaceProduct.ProductCode = PRODUCT_CODE_10033;
        marketplaceProduct.Work_Order_Type__c = WORKORDER_TYPE_MARKETPLACE;
        insert marketplaceProduct;
        SBQQ__QuoteLine__c quoteLineItem = CPQTestDataFactory.createQuoteLine(
            alcoholProduct,
            quote,
            true
        );
        PricebookEntry priceBookEntry = CPQTestDataFactory.createPriceBookEntry(
            alcoholProduct,
            CURRENCY_CODE_USD,
            true
        );
        Contract contractInstance = new Contract(AccountId = businessAccount.Id);
        insert contractInstance;
        contractInstance.Status = CONTRACT_STATUS_ACTIVATED;
        update contractInstance;
        Order order = CPQTestDataFactory.createOrder(businessAccount, opportunity, quote, false);
        order.SBQQ__Quote__c = null;
        insert order;
        OrderItem marketplaceOrderItem = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineItem,
            priceBookEntry.Id,
            false
        );
        marketplaceOrderItem.Product2Id = marketplaceProduct.Id;
        marketplaceOrderItem.SBQQ__Contract__c = contractInstance.Id;
        OrderItem alcoholOrderItem = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineItem,
            priceBookEntry.Id,
            false
        );
        alcoholOrderItem.Product2Id = alcoholProduct.Id;
        alcoholOrderItem.SBQQ__Contract__c = contractInstance.Id;
        alcoholOrderItem.SBQQ__RequiredBy__c = marketplaceOrderItem.Id;
        insert alcoholOrderItem;
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        subscription.SBQQ__Product__c = alcoholProduct.Id;
        subscription.SBQQ__Contract__c = contractInstance.Id;
        subscription.SBQQ__Account__c = businessAccount.Id;
        subscription.SBQQ__Quantity__c = 200;
        insert subscription;
        Merchant_Service__c alcolholProductMerchantService = new Merchant_Service__c();
        alcolholProductMerchantService.Account__c = businessAccount.Id;
        alcolholProductMerchantService.Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES;
        alcolholProductMerchantService.Order_Product__c = alcoholOrderItem.Id;
        alcolholProductMerchantService.Product__c = alcoholProduct.Id;
        alcolholProductMerchantService.Subscription__c = subscription.Id;
        insert alcolholProductMerchantService;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c();
        marketplaceMerchantService.Account__c = businessAccount.Id;
        marketplaceMerchantService.Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES;
        marketplaceMerchantService.Order_Product__c = marketplaceOrderItem.Id;
        marketplaceMerchantService.Product__c = marketplaceProduct.Id;
        marketplaceMerchantService.Subscription__c = subscription.Id;
        insert marketplaceMerchantService;
        Test.startTest();
        List<Merchant_Service__c> merchantServices = MerchantSelector.newInstance()
            .selectServicesWithAlcoholProductsByAccountIds(new Set<Id>{ businessAccount.Id });
        Test.stopTest();
        System.assertEquals(1, merchantServices.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            alcolholProductMerchantService.Id,
            merchantServices[0].Id,
            INCORRECT_ID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate when business Id and contract id is passed then Merchant Service are returned.
     */
    @isTest
    static void testWhenBusinessIdAndContractIdIsPassedToServicesThenReturnRecords() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();

        SBQQ.TriggerControl.disable();

        Account businessAccount = new Account(
            Name = NAME_ACCOUNT,
            RecordTypeId = businessRecordTypeId,
            BillingCountry = UNITED_STATES,
            Segment__c = ACCOUNT_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );

        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = 'Rx',
            Type = 'Holding Group'
        );
        insert businessAccount;
        insert childAccount;
        Contract contractInstance = new Contract(AccountId = businessAccount.Id);
        insert contractInstance;

        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        insert marketplaceProduct;

        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = contractInstance.Id,
            SBQQ__Account__c = businessAccount.Id,
            SBQQ__Quantity__c = 200
        );
        insert subscription;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        insert marketplaceMerchantService;

        SBQQ.TriggerControl.enable();

        Test.startTest();
        List<Id> services = new List<Id>{ marketplaceMerchantService.Id };
        List<Merchant_Service__c> merchantServices = MerchantSelector.newInstance()
            .selectMerchantServiceToShowUnderContractsAmendment(
                businessAccount.Id,
                contractInstance.Id
            );
        Test.stopTest();

        System.assertEquals(merchantServices.size() + 1, services.size(), ASSERT_MESSAGE);
    }
    /**
     * @description To validate when business Id and contract id are not passed then Merchant
     * Service are not returned.
     */
    @isTest
    private static void testWhenBusinessIdAndSubscriptionIdIsPassedToServicesThenDoNotReturnRecords() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();

        SBQQ.TriggerControl.disable();

        Account businessAccount = new Account(
            Name = NAME_ACCOUNT,
            RecordTypeId = businessRecordTypeId,
            BillingCountry = UNITED_STATES,
            Segment__c = ACCOUNT_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );

        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY2,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE2,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Type = 'Holding Group'
        );
        insert businessAccount;
        insert childAccount;

        Contract contractInstance = new Contract(AccountId = businessAccount.Id);
        insert contractInstance;
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        insert marketplaceProduct;

        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = contractInstance.Id,
            SBQQ__Account__c = businessAccount.Id,
            SBQQ__Quantity__c = 200
        );
        insert subscription;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        insert marketplaceMerchantService;

        SBQQ.TriggerControl.enable();

        Test.startTest();
        List<Merchant_Service__c> merchantServices = MerchantSelector.newInstance()
            .selectMerchantServiceToShowUnderContractsAmendment(
                businessAccount.Id,
                subscription.Id
            );
        Test.stopTest();

        System.assertEquals(0, merchantServices.size(), ASSERT_MESSAGE_ERROR);
    }

    /**
     * @description This is test method to test queryMerchantRecordsFromStore.
     */
    @isTest
    private static void testWhenQueryMerchantRecordsThenRetrieveFromStore() {
        Account testBusinessAccount = new Account(
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Name = BUSINESS_ACCOUNT,
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = QUOTE_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            BillingCountry = UNITED_STATES
        );
        insert testBusinessAccount;

        Account testStoreAccount = new Account(
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Name = STORE_ACCOUNT,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            Segment__c = QUOTE_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE,
            Type = 'Holding Group'
        );
        insert testStoreAccount;

        Opportunity testOppRec = new Opportunity(
            AccountId = testBusinessAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today(),
            StageName = OPPORTUNITY_STAGE_NAME,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE,
            Estimated_Number_of_Stores__c = 2
        );

        insert testOppRec;

        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testBusinessAccount,
            null,
            true
        );

        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Name = PRODUCT_NAME_BASIC_PACKAGE;
        insert product;

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = 1;
        quoteLine.SBQQ__Number__c = 1;
        quoteLine.SBQQ__Product__c = product.Id;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__Quote__c = newQuote.Id;
        quoteLine.SBQQ__NetPrice__c = 100;

        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        subscription.SBQQ__Product__c = product.Id;
        subscription.SBQQ__Quantity__c = 200;
        insert subscription;

        Merchant_Service__c existingMxService = new Merchant_Service__c();
        existingMxService.Product__c = product.Id;
        existingMxService.Account__c = testStoreAccount.Id;
        existingMxService.Subscription__c = subscription.Id;
        insert existingMxService;

        Merchant_Service__c newMxService = new Merchant_Service__c();
        newMxService.Product__c = product.Id;
        newMxService.Account__c = testStoreAccount.Id;
        newMxService.Subscription__c = subscription.Id;
        insert newMxService;
        Set<String> packagesToExclude = new Set<String>();
        for (String serviceName : Package_Exclusion.split(DELIMITER_COMMA)) {
            packagesToExclude.add(serviceName.trim());
        }

        Test.startTest();
        List<Merchant_Service__c> merchantServices = MerchantSelector.newInstance()
            .selectExistingMerchantServiceToExcludeByStoreIdsAndPackage(
                new Set<Id>{ testStoreAccount.Id },
                new Set<Id>{ newMxService.Id },
                packagesToExclude
            );
        Test.stopTest();
        System.assertEquals(0, merchantServices.size(), ASSERTION_MESSAGE);
    }
     /**
     * @description This is test method to test selectActiveServicesByAccountIds.
     * @JIRA #LEM-15980
     */
    @isTest
    private static void testWhenSelectActiveServicesByAccountIdsThenReturnMerchantServices() {
        Test.startTest();

        SBQQ.TriggerControl.disable();

        Product2 bundleProductMarketplace = CPQTestDataFactory.createProduct(false);
        bundleProductMarketplace.ProductCode = PRODUCT_CODE_10017;
        insert bundleProductMarketplace;
        Product2 productMarketPlace = CPQTestDataFactory.createProduct(false);
        productMarketPlace.ProductCode = PRODUCT_CODE_10033;
        insert productMarketPlace;

        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(
            bundleProductMarketplace,
            'USD',
            true
        );
        Account testAccount = TestDataFactory.createAccount(true);
        Contract testContract1 = CPQTestDataFactory.createContract(testAccount.Id, true);
        Contract testContract2 = CPQTestDataFactory.createContract(testAccount.Id, true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLineBundleMarketplace = CPQTestDataFactory.createQuoteLine(
            bundleProductMarketplace,
            quote,
            true
        );
        SBQQ__QuoteLine__c quoteLineMarketplace = CPQTestDataFactory.createQuoteLine(
            productMarketPlace,
            quote,
            true
        );

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //We need an Actiavtion Order.
        insert order;
        OrderItem orderItemBundleMarketplace = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineBundleMarketplace,
            pbe.Id,
            true
        );
        OrderItem orderItemMarketplace = CPQTestDataFactory.createOrderItem(
            order,
            quoteLineMarketplace,
            pbe.Id,
            false
        );
        orderItemMarketplace.SBQQ__RequiredBy__c = orderItemBundleMarketplace.Id;
        insert orderItemMarketplace;

        SBQQ__Subscription__c subRec1 = new SBQQ__Subscription__c();
        subRec1.SBQQ__Product__c = bundleProductMarketplace.Id;
        subRec1.SBQQ__Contract__c = testContract1.Id;
        subRec1.SBQQ__Account__c = testAccount.Id;
        subRec1.SBQQ__Quantity__c = 200;
        insert subRec1;

        SBQQ__Subscription__c subRec2 = new SBQQ__Subscription__c();
        subRec2.SBQQ__Product__c = bundleProductMarketplace.Id;
        subRec2.SBQQ__Contract__c = testContract2.Id;
        subRec2.SBQQ__Account__c = testAccount.Id;
        subRec2.SBQQ__Quantity__c = 200;
        insert subRec2;

        Merchant_Service__c merchSerBundleMarketplace = new Merchant_Service__c();
        merchSerBundleMarketplace.Account__c = testAccount.Id;
        merchSerBundleMarketplace.Order_Product__c = orderItemBundleMarketplace.Id;
        merchSerBundleMarketplace.Mx_Agreed_to_Product__c = 'Yes';
        merchSerBundleMarketplace.Subscription__c = subRec1.Id;
        insert merchSerBundleMarketplace;
        Merchant_Service__c merchSerMarketplace = new Merchant_Service__c();
        merchSerMarketplace.Account__c = testAccount.Id;
        merchSerMarketplace.Order_Product__c = orderItemMarketplace.Id;
        merchSerMarketplace.Mx_Agreed_to_Product__c = 'Yes';
        merchSerMarketplace.Subscription__c = subRec2.Id;
        insert merchSerMarketplace;

        SBQQ.TriggerControl.enable();

        List<Merchant_Service__c> returnedListMarketPlace = MerchantSelector.newInstance()
            .selectActiveServicesByAccountIds(
                new Set<Id>{ testAccount.Id },
                new Set<Id>{ testContract1.Id }
            );

        Test.stopTest();
        System.assertEquals(1, returnedListMarketPlace.size(), 'One Record should be retuned');
    }

    /**
     * @description It is used to validate when Churned Merchant contract ids are passed
     * then Merchant Services are returned.
     * @JIRA #LEM-23780
     */
    @isTest
    private static void testWhenSelectChurnedMxServicesByContractIdsThenReturnMerchantServices() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_ACCOUNT)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_ACCOUNT)
            .getRecordTypeId();

        SBQQ.TriggerControl.disable();

        Account businessAccount = new Account(
            Name = NAME_ACCOUNT,
            RecordTypeId = businessRecordTypeId,
            BillingCountry = UNITED_STATES,
            Segment__c = ACCOUNT_SEGMENT,
            Legal_Business_Name__c = BUSINESS_ACCOUNT,
            Primary_Vertical__c = PRIMARY_VERTICAL
        );

        Account childAccount = new Account(
            Name = NAME_ACCOUNT_CHILD,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccount.Id,
            BillingCountry = UNITED_STATES,
            BillingStreet = BILLING_STREET,
            BillingCity = BILLING_CITY2,
            BillingState = BILLING_STATE,
            BillingPostalCode = BILLING_CODE2,
            Segment__c = ACCOUNT_SEGMENT,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Type = 'Holding Group'
        );
        insert businessAccount;
        insert childAccount;

        Contract contractInstance = new Contract(AccountId = businessAccount.Id);
        insert contractInstance;
        Product2 marketplaceProduct = new Product2(
            Name = PRODUCT_NAME_MARKETPLACE,
            ProductCode = PRODUCT_CODE_10017
        );
        insert marketplaceProduct;

        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
            SBQQ__Product__c = marketplaceProduct.Id,
            SBQQ__Contract__c = contractInstance.Id,
            SBQQ__Account__c = businessAccount.Id,
            SBQQ__Quantity__c = 200
        );
        insert subscription;
        Merchant_Service__c marketplaceMerchantService = new Merchant_Service__c(
            Account__c = childAccount.Id,
            Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_YES,
            Product__c = marketplaceProduct.Id,
            Subscription__c = subscription.Id
        );
        insert marketplaceMerchantService;

        SBQQ.TriggerControl.enable();
        Test.startTest();
        List<Merchant_Service__c> merchantServices = MerchantSelector.newInstance()
            .selectChurnedMxServicesByContractIds( new Set<Id>{ contractInstance.Id});
        Test.stopTest();

        System.assertEquals(1, merchantServices.size(), ASSERT_MESSAGE_ERROR);
    }
}