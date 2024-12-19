/**
 * @author DoorDash QTC
 * @date 07/31/2022
 * @description This is test class for OrdersSelector class
 */
@isTest
public with sharing class OrdersSelectorTest {
    private static final Id ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    private static final Id PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE = 'Business';
    private static final String ACCOUNT_STORE_RECORD_TYPE = 'Store';
    private static final String ACCOUNT_NAME = 'Test KFC';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String ASSERT_MESSAGE_ORDERS_NOT_RETURNED = 'Unexpected Result: Orders are not retrieved.';
    private static final String MARKETPLACE_PRODUCT_NAME = 'Marketplace';
    private static final String ORDERSTATUSDRAFT = 'Draft';
    private static final String PRODUCT_NAME = 'Cx Delivery Fee';
    private static final String SPLIT_CATEGORY_CORE = 'Core';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Order order1 = new Order();
        Order order2 = new Order();
        OrdersSelector ordersInstance = new OrdersSelector();
        List<Order> orders = ordersInstance.selectById(new Set<Id>{ order1.Id, order2.Id });
        Schema.SObjectType typeOfObj = ordersInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = ordersInstance.getSObjectFieldList();
        OrdersSelector.newInstance();
        System.assertEquals(Schema.Order.SObjectType, typeOfObj, 'The object type must be Order');
        System.assertEquals(
            new List<Schema.SObjectField>{
                Order.Id,
                Order.Backend_Systems__c,
                Order.SBQQ__Quote__c,
                Order.EffectiveDate,
                Order.Type
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assert(orders.size() != null, 'The list does not contain any Orders');
    }

    @isTest
    private static void testWhenAccountIdsPassedThenReturnActivationOrders() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = businessAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;

        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Order parentOrder2 = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder2;

        List<Order> orders = OrdersSelector.newInstance()
            .selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id });

        System.assert(orders != null, 'The list was null');
        System.assert(!orders.isEmpty(), 'The list was not empty');
    }

    @isTest
    private static void testWhenOpportunityIdsPassedThenReturnPrimaryOrders() {
        List<Account> accountList = new List<Account>{
            new Account(
                Name = 'Parent 1',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL,
                Segment__c = 'Enterprise'
            ),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Opportunity testOpp = CPQTestDataFactory.createOpportunity(accountList[0].Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, accountList[0], null, true);
        quote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        quote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        quote.Opt_In_Opt_Out_Decision__c = 'FSA';
        quote.Opt_Out_Save_Period_days__c = 3;
        update quote;

        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            accountList[0].Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;

        List<Order> orders = OrdersSelector.newInstance()
            .selectOrdersByOpportunityIds(new Set<Id>{ testOpp.Id });

        System.assert(orders != null, 'The list was null');
        System.assert(!orders.isEmpty(), 'The list was not empty');
    }

    /**
     * @description To test Draft Activation Orders With Cx Delivery Fee Product
     * when Account Ids are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnDraftActivationOrdersWithCxDeliveryFeeProduct() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORD_TYPE)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = businessAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Order parentOrder = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder;
        Order parentOrder2 = ServiceIntegrationDataBuilder.createActivationOrderInstance(
            storeAccount.Id
        );
        insert parentOrder2;
        Product2 cxDeliveryFeeProduct = ServiceIntegrationDataBuilder.createProductInstance(
            PRODUCT_NAME
        );
        cxDeliveryFeeProduct.Family = MARKETPLACE_PRODUCT_NAME;
        insert cxDeliveryFeeProduct;
        PricebookEntry cxDeliveryFeeProductEntry = ServiceIntegrationDataBuilder.createPricebookEntryInstance(
            cxDeliveryFeeProduct.Id
        );
        insert cxDeliveryFeeProductEntry;
        OrderItem orderItem = ServiceIntegrationDataBuilder.createActivationOrderItemInstance(
            parentOrder.Id,
            cxDeliveryFeeProduct.Id
        );
        orderItem.SBQQ__Status__c = ORDERSTATUSDRAFT;
        orderItem.Split_Category__c = SPLIT_CATEGORY_CORE;
        orderItem.PricebookEntryId = cxDeliveryFeeProductEntry.Id;
        insert orderItem;
        Test.startTest();
        List<Order> orders = OrdersSelector.newInstance()
            .selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
                new Set<Id>{ storeAccount.Id }
            );
        Test.stopTest();
        system.assertEquals(orders.size(), 1, ASSERT_MESSAGE_ORDERS_NOT_RETURNED);
    }
}