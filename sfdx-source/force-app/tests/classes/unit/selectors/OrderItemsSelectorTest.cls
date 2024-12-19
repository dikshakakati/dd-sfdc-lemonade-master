/**
 * @author atg
 * @date 05/25/2022
 * @description Test class for OrderItemsSelector class.
 */
@isTest(seeAllData=false)
public class OrderItemsSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String ADDRESS_VERIFICATION_STATUS_UNVERIFIED = 'Unverified';
    private static final String AGGREGATE_ACCOUNT_ID_FIELD_ALIAS = 'parentAccountId';
    private static final String AGGREGATE_CONTRACT_ID_FIELD_ALIAS = 'contractId';
    private static final String ASSERT_MESSAGE_INCORRECT_ACCOUNT_ID = 'Unexpected result: Account Id does not match';
    private static final String ASSERT_MESSAGE_INCORRECT_CONTRACT_ID = 'Unexpected result: Contract Id does not match';
    private static final String CONTRACT_STATUS_DRAFT = 'Draft';
    private static final String INCORRECT_MARKETPLACE_ORDER_ITEMS_ASSERT_MESSAGE = 'Unexpected result: the query returned incorrect marketplace order item record';
    private static final String INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE = 'Unexpected result: The query returns incorrect number of records';
    private static final String INCORRECT_NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING_ASSERT_MESSAGE = 'Unexpected result: the query returned incorrect number of Order Items with product work order type mapping';
    private static final String INTEGRATION_SOURCE_SSMO = 'SSMO';
    private static final String INTEGRATION_SOURCE_SSOB = 'SSOB';
    private static final String INTEGRATION_SOURCE_NINTEX = 'Nintex';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String MARKETPLACE_PRODUCT_NAME = 'Marketplace';
    private static final String NOT_IN_COVERAGE = 'Not in Coverage';
    private static final Integer NUMBER_OF_ACTIVATED_ORDER_ITEMS = 1;
    private static final Integer NUMBER_OF_ORDER_ITEMS = 2;
    private static final Integer NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING = 1;
    private static final Integer NUMBER_OF_PRIMARY_ORDER_ITEMS = 1;
    private static final Integer NUMBER_OF_ACTIVATED_ORDER_ITEMS_ZERO = 0;
    private static final String OPPORTUNITY_NAME_TEST = 'Test';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW_PARTNER = 'Net New Partner';
    private static final String PRODUCT_BACK_END_SYSTEMS_MDS = 'MDS';
    private static final String PRODUCT_NAME = 'Test Product';
    private static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final Set<String> PRODUCT_TYPES = new Set<String>{ 'Marketplace', 'Storefront' };
    private static final String STOREFRONT_PRODUCT_NAME = 'Storefront';
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    public static final Schema.Fieldset ORDER_ITEM_FIELD_SET = SObjectType.OrderItem.FieldSets.Activation_Order_Item_List;

    @testSetup
    static void setupData() {
        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, true);
        OrderItem orderItem = CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, false);
        insert orderItem;
        SBQQ__QuoteLineGroup__c qlGroup = CPQTestDataFactory.createGroup(quote.Id, true);
        quoteLine.SBQQ__Group__c = qlGroup.Id;
        update quoteLine;
    }

    /**
     * @description This is test method to test getSObjectType and getSObjectFieldList values.
     */
    @isTest
    private static void testWhenObjectTypeAndFieldListThenReturnCorrect() {
        OrderItemsSelector orderItemsInstance = new OrderItemsSelector();
        Schema.SObjectType typeOfObj = orderItemsInstance.getSObjectType();
        System.assertEquals(
            Schema.OrderItem.SObjectType,
            typeOfObj,
            'The object type must be OrderItem'
        );

        List<Schema.SObjectField> fieldList = orderItemsInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                OrderItem.Id,
                OrderItem.OrderId,
                OrderItem.Product2Id,
                OrderItem.SBQQ__Contract__c,
                OrderItem.Quote_Line_Group__c,
                OrderItem.Split_Category__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is test method to test selectOrderItemFieldSetById method.
     */
    @isTest
    private static void testWhenSelectFieldSetFieldsByIdThenAssertFieldsReturned() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        OrderItem orderItem = [SELECT Id, OrderId FROM OrderItem LIMIT 1];
        //Create two OrderItems to make sure only the correct one is selected.
        Opportunity testOpp2 = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote2 = CPQTestDataFactory.createQuote(testOpp2, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(product, quote2, true);
        Order order2 = CPQTestDataFactory.createOrder(testAccount, testOpp2, quote2, true);
        OrderItem orderItem2 = CPQTestDataFactory.createOrderItem(order2, quoteLine2, pbe.Id, true);
        List<OrderItem> orderItemsList = OrderItemsSelector.newInstance()
            .selectOrderItemFieldSetById(ORDER_ITEM_FIELD_SET, new Set<Id>{ orderItem.Id });
        Test.stopTest();
        System.assertNotEquals(
            orderItem.Id,
            orderItem2.Id,
            'Make sure there are 2 different OrderItems'
        );
        System.assertEquals(
            orderItemsList.size(),
            1,
            'List was returned with all fields in the field set'
        );
        System.assertEquals(orderItemsList[0].OrderId, orderItem.OrderId, 'OrderId should be set');
    }

    /**
     * @description To validate the selection of activated Order Items based on recordIds.
     **/
    @isTest
    private static void testWhenRecordIdsArePassedThenReturnActivatedOrderItems() {
        Id activationOrderRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Order' AND DeveloperName = 'Activation_Order'
            LIMIT 1
        ]
        .Id;
        Id storeAccountRecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'Store'
            LIMIT 1
        ]
        .Id;
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;

        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        storeAccount.RecordTypeId = storeAccountRecordTypeId;
        storeAccount.Activated_Centrally_AC__c = 'Yes';
        insert storeAccount;

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quote.Integration_Source__c = INTEGRATION_SOURCE_NINTEX;
        quote.SBQQ__Primary__c = true;
        update quote;

        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        parentOrder.SBQQ__Quote__c = quote.Id;
        parentOrder.RecordTypeId = activationOrderRecordTypeId;
        parentOrder.AccountId = storeAccount.Id;
        insert parentOrder;

        Opportunity testOpp = CPQTestDataFactory.createOpportunity(parentBusinessAccount.Id, true);

        parentOrder.OpportunityId = testOpp.Id;
        update parentOrder;

        Product2 activeProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        activeProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert activeProduct;

        // SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(
        //     activeProduct,
        //     quote,
        //     true
        // );

        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            activeProduct.Id
        );

        Test.startTest();
        insert pricebookEntry;

        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        insert contract;

        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            activeProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        orderItem.OrderId = parentOrder.Id;
        insert orderItem;

        List<OrderItem> activatedOrderItems = OrderItemsSelector.newInstance()
            .selectActivatedOrderItemsById(new Set<Id>{ orderItem.Id }, false);

        Test.stopTest();
        System.assertEquals(
            NUMBER_OF_ACTIVATED_ORDER_ITEMS,
            activatedOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the selection of primary Order Items based on recordIds.
     **/
    @isTest
    private static void testWhenRecordIdsArePassedThenReturnPrimaryOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c];
        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            parentBusinessAccount.Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;
        Product2 alcoholDeliveryProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        insert alcoholDeliveryProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            alcoholDeliveryProduct.Id
        );
        insert pricebookEntry;
        Contract contract = new Contract(
            AccountId = parentBusinessAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        insert contract;
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            primaryOrder.Id,
            alcoholDeliveryProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        insert orderItem;
        List<OrderItem> primaryOrderItems = OrderItemsSelector.newInstance()
            .selectAlcoholDeliveryOrPickupOrderItemsByAccountIds(
                new Set<Id>{ parentBusinessAccount.Id }
            );
        System.assertEquals(
            NUMBER_OF_PRIMARY_ORDER_ITEMS,
            primaryOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the selection of activated Order Items along with Product details
     * based on the passed recordIds.
     **/
    @isTest
    private static void testWhenRecordIdsPassedThenOrderItemsWithProductDetailsReturned() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 activeProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        activeProduct.Backend_System__c = PRODUCT_BACK_END_SYSTEMS_MDS;
        insert activeProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            activeProduct.Id
        );
        insert pricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            activeProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        insert orderItem;
        List<OrderItem> orderItemsWithOrders = OrderItemsSelector.newInstance()
            .selectById(new Set<Id>{ orderItem.Id });
        Set<Id> orderIdSet = new Set<Id>();
        for (OrderItem oi : orderItemsWithOrders) {
            orderIdSet.add(oi.OrderId);
        }
        List<OrderItem> orderItemsWithProductDetails = OrderItemsSelector.newInstance()
            .selectProductBackEndByOrderItemIds(orderIdSet);
        System.assertEquals(
            NUMBER_OF_ACTIVATED_ORDER_ITEMS,
            orderItemsWithProductDetails.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the selection of activation Order Items based on Account Ids
     * and Product types.
     **/
    @isTest
    private static void testWhenAccountIdsAndProductTypesArePassedThenReturnActivatedOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 marketplaceProduct = ServiceIntegrationDataBuilder.createProductInstance(
            MARKETPLACE_PRODUCT_NAME
        );
        marketplaceProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert marketplaceProduct;
        PricebookEntry marketplacePricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            marketplaceProduct.Id
        );
        insert marketplacePricebookEntry;
        Product2 storefrontProduct = ServiceIntegrationDataBuilder.createProductInstance(
            STOREFRONT_PRODUCT_NAME
        );
        storefrontProduct.Work_Order_Type__c = STOREFRONT_PRODUCT_NAME;
        insert storefrontProduct;
        PricebookEntry storefrontPricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            storefrontProduct.Id
        );
        insert storefrontPricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem marketplaceOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            marketplaceProduct.Id
        );
        marketplaceOrderItem.PricebookEntryId = marketplacePricebookEntry.Id;
        marketplaceOrderItem.SBQQ__Contract__c = contract.Id;
        insert marketplaceOrderItem;
        OrderItem storefrontOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            storefrontProduct.Id
        );
        storefrontOrderItem.PricebookEntryId = storefrontPricebookEntry.Id;
        storefrontOrderItem.SBQQ__Contract__c = contract.Id;
        insert storefrontOrderItem;
        List<OrderItem> activatedOrderItems = OrderItemsSelector.newInstance()
            .selectActivatedOrderItemsByAccountIdsAndProductTypes(
                new Set<Id>{ storeAccount.Id },
                new Set<String>{ MARKETPLACE_PRODUCT_NAME, STOREFRONT_PRODUCT_NAME }
            );
        System.assertEquals(
            NUMBER_OF_ORDER_ITEMS,
            activatedOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the selection of Order Items with product work order type mapping
     * based on the passed Order Ids.
     **/
    @isTest
    private static void testWhenOrderIdsPassedThenReturnOrderItemsWithProductWorkOrderTypeMapping() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 marketplaceProduct = ServiceIntegrationDataBuilder.createProductInstance(
            MARKETPLACE_PRODUCT_NAME
        );
        marketplaceProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert marketplaceProduct;
        PricebookEntry marketplacePricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            marketplaceProduct.Id
        );
        insert marketplacePricebookEntry;
        Product2 alcoholDeliveryProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        insert alcoholDeliveryProduct;
        PricebookEntry alcoholDeliveryPricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            alcoholDeliveryProduct.Id
        );
        insert alcoholDeliveryPricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem marketplaceOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            marketplaceProduct.Id
        );
        marketplaceOrderItem.PricebookEntryId = marketplacePricebookEntry.Id;
        marketplaceOrderItem.SBQQ__Contract__c = contract.Id;
        insert marketplaceOrderItem;
        OrderItem alcoholDeliveryOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            alcoholDeliveryProduct.Id
        );
        alcoholDeliveryOrderItem.PricebookEntryId = alcoholDeliveryPricebookEntry.Id;
        alcoholDeliveryOrderItem.SBQQ__Contract__c = contract.Id;
        insert alcoholDeliveryOrderItem;
        List<OrderItem> orderItems = OrderItemsSelector.newInstance()
            .selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                new Set<Id>{ marketplaceOrderItem.OrderId, alcoholDeliveryOrderItem.OrderId }
            );
        System.assertEquals(
            NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING,
            orderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING_ASSERT_MESSAGE
        );
        System.assertNotEquals(
            NUMBER_OF_ORDER_ITEMS,
            NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING,
            INCORRECT_NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the aggregate selection of Order Items
     * grouped by Account and Contract Ids.
     **/
    @isTest
    private static void testWhenOrderItemIdsPassedThenReturnAggregateCountGroupedByAccountAndContractIds() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c];
        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            parentBusinessAccount.Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;
        Product2 alcoholDeliveryProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        insert alcoholDeliveryProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            alcoholDeliveryProduct.Id
        );
        insert pricebookEntry;
        Contract contract = new Contract(
            AccountId = parentBusinessAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        insert contract;
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            primaryOrder.Id,
            alcoholDeliveryProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        insert orderItem;
        List<Aggregate> orderItemsAggregate = OrderItemsSelector.newInstance()
            .selectByIdsGroupedByAccountContractIds(new Set<Id>{ orderItem.Id });
        System.assertEquals(
            parentBusinessAccount.Id,
            (Id) orderItemsAggregate[0].get(AGGREGATE_ACCOUNT_ID_FIELD_ALIAS),
            ASSERT_MESSAGE_INCORRECT_ACCOUNT_ID
        );
        System.assertEquals(
            contract.Id,
            (Id) orderItemsAggregate[0].get(AGGREGATE_CONTRACT_ID_FIELD_ALIAS),
            ASSERT_MESSAGE_INCORRECT_CONTRACT_ID
        );
    }

    /**
     * @description To validate the selection of primary Order Items based on recordIds.
     **/
    @isTest
    private static void testWhenOrderItemIdsArePassedThenReturnPrimaryOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c];
        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            parentBusinessAccount.Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;
        Product2 alcoholDeliveryProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        insert alcoholDeliveryProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            alcoholDeliveryProduct.Id
        );
        insert pricebookEntry;
        Contract contract = new Contract(
            AccountId = parentBusinessAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        insert contract;
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            primaryOrder.Id,
            alcoholDeliveryProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        insert orderItem;
        List<OrderItem> primaryOrderItems = OrderItemsSelector.newInstance()
            .selectPrimaryOrderItemsByIds(new Set<Id>{ orderItem.Id });
        System.assertEquals(
            NUMBER_OF_PRIMARY_ORDER_ITEMS,
            primaryOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description This is test method to test selectOrderItemsWithPrimaryOrderFields method
     */
    @isTest
    private static void testWhenOrderItemIdsArePassedThenReturnsOrderItemsWithPrimaryOrderFields() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        OrderItem orderItem = [SELECT Id, OrderId FROM OrderItem LIMIT 1];
        //Create two OrderItems to make sure only the correct one is selected
        Opportunity testOpp2 = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote2 = CPQTestDataFactory.createQuote(testOpp2, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(product, quote2, true);
        Order order2 = CPQTestDataFactory.createOrder(testAccount, testOpp2, quote2, true);
        OrderItem orderItem2 = CPQTestDataFactory.createOrderItem(order2, quoteLine2, pbe.Id, true);
        List<OrderItem> orderItemsList = OrderItemsSelector.newInstance()
            .selectOrderItemsWithPrimaryOrderFields(new Set<Id>{ orderItem.Id });
        Test.stopTest();
        System.assertNotEquals(
            orderItem.Id,
            orderItem2.Id,
            'Make sure there are 2 different OrderItems'
        );
        System.assertEquals(
            orderItemsList.size(),
            1,
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
        System.assertEquals(orderItemsList[0].OrderId, orderItem.OrderId, 'OrderId should be set');
    }

    /**
     * @description To validate the selection of activation Order Items based on Account Ids.
     **/
    @isTest
    private static void testWhenAccountIdsArePassedThenReturnActivatedOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 marketplaceProduct = ServiceIntegrationDataBuilder.createProductInstance(
            MARKETPLACE_PRODUCT_NAME
        );
        marketplaceProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert marketplaceProduct;
        PricebookEntry marketplacePricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            marketplaceProduct.Id
        );
        insert marketplacePricebookEntry;
        Product2 storefrontProduct = ServiceIntegrationDataBuilder.createProductInstance(
            STOREFRONT_PRODUCT_NAME
        );
        storefrontProduct.Work_Order_Type__c = STOREFRONT_PRODUCT_NAME;
        insert storefrontProduct;
        PricebookEntry storefrontPricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            storefrontProduct.Id
        );
        insert storefrontPricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem marketplaceOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            marketplaceProduct.Id
        );
        marketplaceOrderItem.PricebookEntryId = marketplacePricebookEntry.Id;
        marketplaceOrderItem.SBQQ__Contract__c = contract.Id;
        insert marketplaceOrderItem;
        OrderItem storefrontOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            storefrontProduct.Id
        );
        storefrontOrderItem.PricebookEntryId = storefrontPricebookEntry.Id;
        storefrontOrderItem.SBQQ__Contract__c = contract.Id;
        insert storefrontOrderItem;
        List<OrderItem> activatedOrderItems = OrderItemsSelector.newInstance()
            .selectActivatedOrderItemsByAccountIds(new Set<Id>{ storeAccount.Id });
        System.assertEquals(
            NUMBER_OF_ORDER_ITEMS,
            activatedOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Order Item Ids are passed and Integration Source on Quote is SSOB then
     * do not return Order Items.
     **/
    @isTest
    private static void testWhenRecordIdsPassedForIntegrationSourceSSMOThenDoNotReturnActivatedOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME_TEST,
            StageName = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate = Date.newInstance(2024, 5, 17),
            AccountId = parentBusinessAccount.Id,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_NET_NEW_PARTNER
        );
        insert opportunity;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opportunity.Id,
            Integration_Source__c = INTEGRATION_SOURCE_SSMO,
            SBQQ__Account__c = parentBusinessAccount.Id,
            SBQQ__Primary__c = true
        );
        insert quote;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        parentOrder.SBQQ__Quote__c = quote.Id;
        insert parentOrder;
        Product2 activeProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        activeProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert activeProduct;
        PricebookEntry pricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            activeProduct.Id
        );
        insert pricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            activeProduct.Id
        );
        orderItem.PricebookEntryId = pricebookEntry.Id;
        orderItem.SBQQ__Contract__c = contract.Id;
        insert orderItem;
        Test.startTest();
        List<OrderItem> activatedOrderItems = OrderItemsSelector.newInstance()
            .selectActivatedOrderItemsById(new Set<Id>{ orderItem.Id }, false);
        Test.stopTest();
        System.assertEquals(
            NUMBER_OF_ACTIVATED_ORDER_ITEMS_ZERO,
            activatedOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Order Item Ids are passed and Quote is null on Order and Integration Source on
     * Quote Line's Quote is SSOB then do not return Order Items.
     **/
    @isTest
    private static void testWhenRecordIdsPassedAndQuoteIsNullAndIntegrationSourceSSMOOnQuoteLinesQuoteThenDoNotReturnActivatedOrderItems() {
        Test.startTest();
        setupData();
        OrderItem orderItem = [SELECT Id, OrderId FROM OrderItem LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quote.Integration_Source__c = INTEGRATION_SOURCE_SSMO;
        update quote;
        orderItem.SBQQ__QuoteLine__c = quoteLine.Id;
        update orderItem;
        List<OrderItem> activatedOrderItems = OrderItemsSelector.newInstance()
            .selectActivatedOrderItemsById(new Set<Id>{ orderItem.Id }, false);
        Test.stopTest();
        System.assertEquals(
            NUMBER_OF_ACTIVATED_ORDER_ITEMS_ZERO,
            activatedOrderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate the selection of Order Items
     * based on the passed Order Ids.
     **/
    @isTest
    private static void testWhenOrderIdsPassedThenReturnOrderItems() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Product2 marketplaceProduct = ServiceIntegrationDataBuilder.createProductInstance(
            MARKETPLACE_PRODUCT_NAME
        );
        marketplaceProduct.Work_Order_Type__c = MARKETPLACE_PRODUCT_NAME;
        insert marketplaceProduct;
        PricebookEntry marketplacePricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            marketplaceProduct.Id
        );
        insert marketplacePricebookEntry;
        Product2 alcoholDeliveryProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        insert alcoholDeliveryProduct;
        PricebookEntry alcoholDeliveryPricebookEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            alcoholDeliveryProduct.Id
        );
        insert alcoholDeliveryPricebookEntry;
        Contract contract = new Contract(
            AccountId = storeAccount.Id,
            StartDate = System.today() + 10,
            Status = CONTRACT_STATUS_DRAFT
        );
        OrderItem marketplaceOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            marketplaceProduct.Id
        );
        marketplaceOrderItem.PricebookEntryId = marketplacePricebookEntry.Id;
        marketplaceOrderItem.SBQQ__Contract__c = contract.Id;
        insert marketplaceOrderItem;
        OrderItem alcoholDeliveryOrderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            alcoholDeliveryProduct.Id
        );
        alcoholDeliveryOrderItem.PricebookEntryId = alcoholDeliveryPricebookEntry.Id;
        alcoholDeliveryOrderItem.SBQQ__Contract__c = contract.Id;
        insert alcoholDeliveryOrderItem;
        List<OrderItem> orderItems = OrderItemsSelector.newInstance()
            .selectOrderItemsByOrderIds(
                new Set<Id>{ marketplaceOrderItem.OrderId }
            );
        System.assertEquals(
            2,
            orderItems.size(),
            INCORRECT_NUMBER_OF_ORDER_ITEMS_WITH_PRODUCT_MAPPING_ASSERT_MESSAGE
        );
    }
}
