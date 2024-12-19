/**
 * @description This is the test class for ActivationOrderCreationServiceImpl.
 * @author atg
 * @date 08/09/2022
 */
@isTest
@SuppressWarnings('PMD.NcssTypeCount,PMD.NcssMethodCount')
public with sharing class ActivationOrderCreationServiceImplTest {
    private static final String PRODUCTCODE_MARKETPLACE = '10017';
    private static final String PRODUCTCODE_CAVIAR = '100521';
    private static final String PRODUCTCODE_DELIVERY = '10033';
    private static final String PRODUCTCODE_PICKUP = '10036';
    private static final String PRODUCTCODE_ADWT = '10059';
    private static final String PRODUCTCODE_SOF = '10012';
    private static final String PRODUCTCODE_LOF = '10044';
    private static final String SERVICE_CREATION_ASSERTION_FAILURE = 'Issues encountered in service creations.';
    private static final String NINTEX_USE_CASE_DRIVE_FORM_FRANCHISE = 'Drive Form - Franchise';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String STORE_ACCOUNT_NAME = 'Los Pinchos de mi Abuela Store';
    private static final String PRODUCTCODE_MARKETPLACE_DELIVERY =
        PRODUCTCODE_MARKETPLACE +
        '-' +
        PRODUCTCODE_DELIVERY;
    private static final String PRODUCTCODE_CAVIAR_DELIVERY =
        PRODUCTCODE_CAVIAR +
        '-' +
        PRODUCTCODE_DELIVERY;

    public static final String ACTIVE = 'Active';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String CONTRACTING_METHOD = 'By Subscription End Date';
    public static final String ACTIVATION_ORDER_TYPE = 'Activation_Order';
    public static final Schema.Fieldset ORDER_ITEM_FIELD_SET = SObjectType.OrderItem.FieldSets.Activation_Order_Item_List;
    public static final String MX_AGREED_YES = 'Yes';
    public static final String MX_AGREED_NO = 'No';
    public static final String MARKETPLACE = 'Marketplace';
    public static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    public static final String CURRENCY_CODE_USD = 'USD';
    public static final String UNEXPECTED_RESULT_EXISTING_SERVICE_RETURNED = 'Unexpected Result: existing service was returned.';
    public static final String UNEXPECTED_RESULT_NEW_SERVICE_RETURNED = 'Unexpected Result: new service was returned.';
    private static final String AGREED_TO_SERVICES_ALL = 'All';
    private static final String AGREED_TO_SERVICES_MARKETPLACE = 'Marketplace';
    private static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    public static final String PRODUCT_WITH_PACKAGES = '{"packageDetails":[{"Package":"Marketplace","Products":["Delivery"]},{"Package":"Storefront","Products":[]}]}';

    /**
     * @description Tests when Agreement is activated then Activation Orders, OrderItems, and Merchact Services are created.
     */
    @IsTest
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void testWhenActivateOrdersCallThenOrdersAndItemsAndServicesCreated() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .toSObject();

        OrderItem orderItem2 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId2)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId2)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .toSObject();

        OrderItem orderItem3 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId3)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId3)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP)
            .toSObject();

        Map<String, Id> accountAgreementStringContractIdMap = new Map<String, Id>();
        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = new Map<Id, Map<String, String>>();
        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();
        accountIdToAgreedToServicesMap.put(accountId, AGREED_TO_SERVICES_ALL);
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
        Map<Id, Map<String, List<String>>> accountIdToSelectedPckgToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        String accountAgreementKey = String.valueOf(accountId) + '-' + PRODUCTCODE_MARKETPLACE;
        accountAgreementStringContractIdMap.put(accountAgreementKey, contractId);

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Primary_Order_Product__c, orderItemId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
                    .setParent(
                        'SBQQ__OrderProduct__r',
                        new Fake(OrderItem.class)
                            .setField(OrderItem.Id, orderItemId1)
                            .setField(OrderItem.OrderId, orderId1)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Primary_Order_Product__c, orderItemId2)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
                    .setParent(
                        'SBQQ__OrderProduct__r',
                        new Fake(OrderItem.class)
                            .setField(OrderItem.Id, orderItemId2)
                            .setField(OrderItem.OrderId, orderId1)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Primary_Order_Product__c, orderItemId3)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
                    .setParent(
                        'SBQQ__OrderProduct__r',
                        new Fake(OrderItem.class)
                            .setField(OrderItem.Id, orderItemId3)
                            .setField(OrderItem.OrderId, orderId1)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringContractIdMap,
            accountIdToFranchiseParentIdMap,
            accountIdToDeselectedServicesMap,
            accountIdToAgreedToServicesMap,
            amendedAccountIdToAutoProvisionValueMap,
            accountIdToSelectedPckgToDeselectedProdListMap,
            mockUOW
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId
                    }
                )
            );

        //verify OrderItems are created.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId1
                    }
                ),
                fflib_Match.eqSObjectField(OrderItem.OrderId),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Order.Primary_Order__c => orderId1 }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId2
                    }
                ),
                fflib_Match.eqSObjectField(OrderItem.OrderId),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Order.Primary_Order__c => orderId1 }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId3
                    }
                ),
                fflib_Match.eqSObjectField(OrderItem.OrderId),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Order.Primary_Order__c => orderId1 }
                )
            );
        //Verify the Merchant Services are created or updated.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Merchant_Service__c.Id => merchantServiceId }
                ),
                fflib_Match.eqSObjectField(Merchant_Service__c.Order_Product__c),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId1
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Service__c.Subscription__c => subscriptionId2
                    }
                ),
                fflib_Match.eqSObjectField(Merchant_Service__c.Order_Product__c),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Service__c.Subscription__c => subscriptionId3
                    }
                ),
                fflib_Match.eqSObjectField(Merchant_Service__c.Order_Product__c),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Primary_Order_Product__c => orderItemId3
                    }
                )
            );
        //Relationship verification will have to be done in an integration test, because we have to use a second Unit Of Work.

        //This field set should have fields in it, or the copying or OrderItems will be incomplete.
        List<Schema.FieldSetMember> fieldSetMemberList = ORDER_ITEM_FIELD_SET.getFields();
        system.assertNotEquals(
            fieldSetMemberList.size(),
            0,
            'Make sure field set has fields in it.'
        );
    }

    /**
     * @description Tests that getAgreedToProduct private function returns No when this is a Franchise Account.
     */
    @IsTest
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void testWhenGetAgreedToProductThenCorrectStringReturned() {
        Id contractId = Fake.generateId(Contract.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        String expectedReturn = 'No';
        Id orderId1 = Fake.generateId(Order.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Id accountId = Fake.generateId(Account.class);

        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = new Map<Id, Map<String, String>>();
        Map<String, String> deselectedServices = new Map<String, String>();
        deselectedServices.put('Marketplace', 'Pickup');
        accountIdToDeselectedServicesMap.put(accountId, deselectedServices);

        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();

        accountIdToAgreedToServicesMap.put(accountId, AGREED_TO_SERVICES_MARKETPLACE);

        Fake productFakeMarketPlaceInstance = ServiceMockDataBuilder.createProductFakeInstance(
            'MarketPlace'
        );
        productFakeMarketPlaceInstance.setField(
            Product2.Package_Eligible_For_Nintex_Options__c,
            true
        );

        Fake productFakePickupInstance = ServiceMockDataBuilder.createProductFakeInstance('Pickup');
        Fake productFakeAlcoholPickupInstance = ServiceMockDataBuilder.createProductFakeInstance(
            'Alcohol Pickup'
        );
        Product2 productMarketplace = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeMarketPlaceInstance
        );
        Product2 productPickup = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakePickupInstance
        );
        Product2 productAlcoholPickup = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeAlcoholPickupInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
            accountId
        );
        Order order = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Fake orderItemMarketplaceFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productMarketplace.Id
        );
        orderItemMarketplaceFakeInstance.setParent('Product2', productFakeMarketPlaceInstance);

        Fake orderItemPickupFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productPickup.Id
        );
        orderItemPickupFakeInstance.setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP);
        orderItemPickupFakeInstance.setParent('Product2', productFakePickupInstance);
        orderItemPickupFakeInstance.setParent(
            'SBQQ__BundleRoot__r',
            orderItemMarketplaceFakeInstance
        );
        OrderItem pickupItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemPickupFakeInstance
        );

        Fake orderItemAlcoholPickupFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productAlcoholPickup.Id
        );
        orderItemAlcoholPickupFakeInstance.setField(
            OrderItem.Product_Code__c,
            PRODUCTCODE_MARKETPLACE_DELIVERY
        );
        orderItemAlcoholPickupFakeInstance.setParent('Product2', productFakeAlcoholPickupInstance);
        orderItemAlcoholPickupFakeInstance.setParent(
            'SBQQ__BundleRoot__r',
            orderItemMarketplaceFakeInstance
        );
        OrderItem alcoholPickupItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemAlcoholPickupFakeInstance
        );

        Map<String, Id> accountAgreementStringContractIdMap = new Map<String, Id>();
        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId
        );
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>{
            accountId => false
        };
        Map<Id, Map<String, List<String>>> accountIdToSelectedPckgToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = order.Id);

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productPickup.Id)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_PICKUP)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, alcoholPickupItem.Id)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
                    .setParent(
                        'SBQQ__OrderProduct__r',
                        new Fake(OrderItem.class)
                            .setField(OrderItem.Id, pickupItem.Id)
                            .setField(OrderItem.OrderId, order.Id)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productAlcoholPickup.Id)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, pickupItem.Id)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
                    .setParent(
                        'SBQQ__OrderProduct__r',
                        new Fake(OrderItem.class)
                            .setField(OrderItem.Id, alcoholPickupItem.Id)
                            .setField(OrderItem.OrderId, order.Id)
                    )
            )
            .toSObject();

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, pickupItem.Id)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, pickupItem.Id)
                    .setField(OrderItem.OrderId, order.Id)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, alcoholPickupItem.Id)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, alcoholPickupItem.Id)
                    .setField(OrderItem.OrderId, order.Id)
            )
            .toSObject();

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2
        };
        List<OrderItem> orderItemList = new List<OrderItem>{ pickupItem, alcoholPickupItem };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(new List<Merchant_Service__c>{ existingService, existingService2 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringContractIdMap,
            accountIdToFranchiseParentIdMap,
            accountIdToDeselectedServicesMap,
            accountIdToAgreedToServicesMap,
            amendedAccountIdToAutoProvisionValueMap,
            accountIdToSelectedPckgToDeselectedProdListMap,
            mockUOW
        );

        System.assertEquals(
            expectedReturn,
            existingService.Mx_Agreed_to_Product__c,
            'Result should be No'
        );
        System.assertEquals(
            expectedReturn,
            existingService2.Mx_Agreed_to_Product__c,
            'Result should be No'
        );
    }

    /**
     * @description Tests when Agreement is activated then Activation Orders, OrderItems, and Merchact Services are created
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSetRelationshipsCalledThenOrderItemsUpdated() {
        Id accountId = Fake.generateId(Account.class);
        Id newOrderId = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id newOrderItemId1 = Fake.generateId(OrderItem.class);
        Id newOrderItemId2 = Fake.generateId(OrderItem.class);
        Id newOrderItemId3 = Fake.generateId(OrderItem.class);

        //When new OrderItems are created, they have the RequiredBy and BundleRoot fields set to the OLD orderItemIds.
        OrderItem newOrderItem1 = new OrderItem(Id = newOrderItemId1, OrderId = newOrderId);
        OrderItem newOrderItem2 = new OrderItem(
            Id = newOrderItemId2,
            OrderId = newOrderId,
            SBQQ__BundleRoot__c = orderItemId1
        );
        OrderItem newOrderItem3 = new OrderItem(
            Id = newOrderItemId3,
            OrderId = newOrderId,
            SBQQ__RequiredBy__c = orderItemId1
        );

        Map<String, List<OrderItem>> accountToNewOrderItemsListMap = new Map<String, List<OrderItem>>();
        accountToNewOrderItemsListMap.put(
            String.valueOf(accountId),
            new List<OrderItem>{ newOrderItem1, newOrderItem2, newOrderItem3 }
        );

        Map<String, Map<Id, OrderItem>> accountToOldOrderItemIdNewObjectMap = new Map<String, Map<Id, OrderItem>>();
        Map<Id, OrderItem> oldOrderItemIdNewObjectMap = new Map<Id, OrderItem>();
        oldOrderItemIdNewObjectMap.put(orderItemId1, newOrderItem1);
        oldOrderItemIdNewObjectMap.put(orderItemId2, newOrderItem2);
        oldOrderItemIdNewObjectMap.put(orderItemId3, newOrderItem3);
        accountToOldOrderItemIdNewObjectMap.put(
            String.valueOf(accountId),
            oldOrderItemIdNewObjectMap
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrderCreationServiceImpl.setOrderItemRelationships(
            accountToNewOrderItemsListMap,
            accountToOldOrderItemIdNewObjectMap
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Id => newOrderItemId2 }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Id => newOrderItemId3 }
                )
            );
    }

    @IsTest
    public static void testWhenOrderItemsOfWrongTypeThenDeliveryCommissionNull() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false,
            Group__c = groupId
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = 1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Final_Commission__c = 22,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => '10032' // one digit off
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => null
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    @IsTest
    public static void testWhenOrderItemsWithZeroQuantityThenDeliveryCommissionNull() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);

        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false,
            Group__c = groupId
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = 1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Final_Commission__c = 22,
            Quantity = 0,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE_DELIVERY
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = 1,
            Product2Id = productId3,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, true);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => null
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    @IsTest
    public static void testWhenOrderItemsWithNullFinalCommissionThenDeliveryCommissionNull() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false,
            Group__c = groupId
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = 1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        // Final_Commission not set, should default to null
        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE_DELIVERY
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => null
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    @isTest
    public static void testWhenOrderItemsWithNegativeQuantitySumThenDeliveryCommissionNull() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false,
            Group__c = groupId
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = -1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Final_Commission__c = 22,
            Quantity = -1,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE_DELIVERY
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = -1,
            Product2Id = productId2,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => null
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    @isTest
    public static void testWhenOrderItemsWithZeroQuantitySumThenDeliveryCommissionNull() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = -1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Final_Commission__c = 22,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE_DELIVERY
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = 0,
            Product2Id = productId2,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => null
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    /*
     * @description Tests that a valid Marketplace OrderItem will pass its Final_Commission to
     *  the new Order object's Delivery_Commission
     */
    @IsTest
    public static void testWhenValidOrderItemsThenDeliveryCommissionSet() {
        Decimal expectedFinalCommission = 22;

        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id merchantServiceId1 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false,
            Group__c = groupId
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:
        //  mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId1,
            Quantity = 1
        );
        orderItem1 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem1,
            OrderItem.class,
            new Map<SObjectField, Object>{ OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE }
        );

        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            Final_Commission__c = expectedFinalCommission,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );
        orderItem2 = (OrderItem) fflib_ApexMocksUtils.setReadOnlyFields(
            orderItem2,
            OrderItem.class,
            new Map<SObjectField, Object>{
                OrderItem.Product_Code__c => PRODUCTCODE_MARKETPLACE_DELIVERY
            }
        );

        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            Quantity = 1,
            Product2Id = productId2,
            SBQQ__RequiredBy__c = orderItemId1,
            SBQQ__BundleRoot__c = orderItemId1,
            SBQQ__BundleRoot__r = orderItem1
        );

        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId1)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAccountsService accountsServiceServiceMock = (IAccountsService) mocks.mock(
            IAccountsService.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ new Account(Id = accountId) });
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(
                new List<Merchant_Service__c>{ existingService, existingService1, existingService2 }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountsServiceServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        //Verify the Orders and OrderItems were created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registernew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Primary_Order__c => orderId1,
                        Order.AccountId => accountId,
                        Order.Delivery_Commission__c => expectedFinalCommission
                    }
                )
            );
        ((IAccountsService) mocks.verify(accountsServiceServiceMock, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    @isTest
    public static void testWhenMatchingProductIdAndStateThenReturnRelatedRatecard() {
        Id accountId = Fake.generateId(Account.class);
        Id productId = Fake.generateId(Product2.class);
        Id orderId = Fake.generateId(Order.class);
        Id orderItemId = Fake.generateId(OrderItem.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id rateCardId = Fake.generateId(Rate_Card__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);

        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(accountId, new Account(Id = accountId, BillingStateCode = 'AL'));

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            Id = quoteLineId,
            SBQQ__Product__c = productId
        );

        OrderItem orderItem = new OrderItem(
            Id = orderItemId,
            OrderId = orderId,
            Product2Id = productId,
            Quantity = 1,
            SBQQ__QuoteLine__c = quoteLineId
        );

        Merchant_Service__c existingService = new Merchant_Service__c(
            Id = merchantServiceId,
            Account__c = accountId,
            Product__c = productId,
            Product_Code__c = PRODUCTCODE_MARKETPLACE
        );

        Rate_Card__c rateCard = new Rate_Card__c(
            Id = rateCardId,
            State__c = 'Alabama - AL',
            Quote_Line__c = quoteLineId,
            Quote_Line__r = quoteLine
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IRateCardsSelector ratecardsSelectorMock = (IRateCardsSelector) mocks.mock(
            IRateCardsSelector.class
        );

        mocks.startStubbing();
        mocks.when(ratecardsSelectorMock.SObjectType()).thenReturn(Rate_Card__c.SObjectType);
        mocks.when(ratecardsSelectorMock.selectByQuoteLineIds(new Set<Id>{ quoteLineId }))
            .thenReturn(new List<Rate_Card__c>{ rateCard });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(ratecardsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Map<String, Rate_Card__c> rateCardMap = ActivationOrderCreationServiceImpl.getRateCards(
            new List<OrderItem>{ orderItem }
        );
        Id returnedRateCardId = ActivationOrderCreationServiceImpl.getRateCard(
            accountId,
            orderItem,
            accountMap,
            rateCardMap,
            existingService
        );

        System.assertEquals(rateCard.Id, returnedRateCardId, 'Incorrect Ratecard');
    }

    /**
     * @description Tests correct value of mx agreed to product is updated when new store flow
     */
    @IsTest
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void testWhenNewStoreFlowThenServicesAreCreatedOrUpdatedWithCorrectMxAgreedToProd() {
        Id accountId = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id accountId3 = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id contractId2 = Fake.generateId(Contract.class);
        Id contractId3 = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);
        Id orderId3 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id orderItemId4 = Fake.generateId(OrderItem.class);
        Id orderItemId5 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId5 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId3 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId4 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId5 = Fake.generateId(Merchant_Service__c.class);
        Id productId = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId4 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId5 = Fake.generateId(OrderItem.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);
        Contract contract2 = new Contract(Id = contractId2, SBQQ__Order__c = orderId2);
        Contract contract3 = new Contract(Id = contractId3, SBQQ__Order__c = orderId3);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .toSObject();

        OrderItem orderItem2 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId2)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId2)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .toSObject();

        OrderItem orderItem3 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId3)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId3)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP)
            .toSObject();

        OrderItem orderItem4 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId4)
            .setField(OrderItem.OrderId, orderId2)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .toSObject();

        OrderItem orderItem5 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId5)
            .setField(OrderItem.OrderId, orderId3)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .toSObject();

        Map<String, Id> accountAgreementStringContractIdMap = new Map<String, Id>();
        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = new Map<Id, Map<String, String>>();
        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();
        accountIdToAgreedToServicesMap.put(accountId, AGREED_TO_SERVICES_ALL);
        accountIdToAgreedToServicesMap.put(accountId2, AGREED_TO_SERVICES_MARKETPLACE);
        accountIdToAgreedToServicesMap.put(accountId3, AGREED_TO_SERVICES_DRIVE);
        //Set<Id> amendedAccountIdSet = new Set<Id>();
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>();
        Map<Id, Map<String, List<String>>> accountIdToSelectedPckgToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription4 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId4)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId2)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId4)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId4)
                    .setField(OrderItem.OrderId, orderId2)
            )
            .toSObject();
        SBQQ__Subscription__c subscription5 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId5)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId3)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId5)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId5)
                    .setField(OrderItem.OrderId, orderId3)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4,
            subscription5
        };

        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId
        );
        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId2) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId2
        );
        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId3) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId3
        );

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService3 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId3)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_PICKUP)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService4 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId4)
            .setField(Merchant_Service__c.Account__c, accountId2)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId4)
            .setfield(Merchant_Service__c.Product__c, productId)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId4)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId4)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId2)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId4)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId4)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService5 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId5)
            .setField(Merchant_Service__c.Account__c, accountId3)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId5)
            .setfield(Merchant_Service__c.Product__c, productId)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId5)
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId5)
                    .setField(OrderItem.OrderId, orderId3)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId3)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId5)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId5)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{
            orderItem1,
            orderItem2,
            orderItem3,
            orderItem4,
            orderItem5
        };
        List<String> deselectedProdList = new List<String>{ String.valueOf(subscriptionId3) };
        Map<String, List<String>> selectedPckgToDeselectedProdListMap = new Map<String, List<String>>{
            String.valueOf(subscriptionId1) => deselectedProdList
        };
        accountIdToSelectedPckgToDeselectedProdListMap.put(
            accountId,
            selectedPckgToDeselectedProdListMap
        );
        //ANSO FLOW
        accountIdToSelectedPckgToDeselectedProdListMap.put(
            accountId2,
            new Map<String, List<String>>()
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ accountId, accountId2, accountId3 }))
            .thenReturn(
                new List<Account>{ new Account(Id = accountId), new Account(Id = accountId2),new Account(Id = accountId3) }
            );
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId, contractId2,  contractId3 }))
            .thenReturn(new List<Contract>{ contract1, contract2, contract3});
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId, contractId2, contractId3 },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ accountId, accountId2, accountId3 }
                )
            )
            .thenReturn(
                new List<Merchant_Service__c>{
                    existingService,
                    existingService2,
                    existingService3,
                    existingService4,
					existingService5
                }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringContractIdMap,
            accountIdToFranchiseParentIdMap,
            accountIdToDeselectedServicesMap,
            accountIdToAgreedToServicesMap,
            amendedAccountIdToAutoProvisionValueMap,
            accountIdToSelectedPckgToDeselectedProdListMap,
            mockUOW
        );
        //Selected Packages should return 'Yes'
        system.assertEquals(
            existingService.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //Selected Products should return 'Yes' if package/ bundle is 'Yes'
        system.assertEquals(
            existingService2.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //Deselected Product/ package should return 'No'
        system.assertEquals(
            existingService3.Mx_Agreed_to_Product__c,
            'No',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //ANSO FLOW Mx agreed to doesn't depend on selection- deselection
        system.assertEquals(
            existingService4.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //Existing Service shouldn't be deactivated
        system.assertEquals(
            existingService5.Mx_Agreed_to_Product__c,
            'Yes',
			'Mx_Agreed_to_Product__c Field not updated Correctly'
		);

    }

    /**
     * @description Tests correct value of mx agreed to product is updated amendment flow.
     */
    @IsTest
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void testWhenAmendmentThenServicesAreCreatedOrUpdatedWithCorrectMxAgreedToProd() {
        Id accountId = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id contractId2 = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id orderItemId4 = Fake.generateId(OrderItem.class);
        Id orderItemId5 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId5 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId2 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId3 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId4 = Fake.generateId(Merchant_Service__c.class);
        Id merchantServiceId5 = Fake.generateId(Merchant_Service__c.class);
        Id productId = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);
        Id productId5 = Fake.generateId(Product2.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__C.class);
        Id activationOrderItemId1 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId2 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId3 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId4 = Fake.generateId(OrderItem.class);
        Id activationOrderItemId5 = Fake.generateId(OrderItem.class);
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);
        Contract contract2 = new Contract(Id = contractId2, SBQQ__Order__c = orderId2);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setField(OrderItem.OrderItem_Type__c, 'New Package')
            .toSObject();

        OrderItem orderItem2 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId2)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId2)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setField(OrderItem.SBQQ__RequiredBy__c, orderItemId1)
            .setField(OrderItem.SBQQ__BundleRoot__c, orderItemId1)
            .setField(OrderItem.OrderItem_Type__c, 'New')
            .setParent(
                'SBQQ__BundleRoot__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            )
            .toSObject();
        OrderItem orderItem5 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId5)
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId5)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_ADWT)
            .setField(OrderItem.SBQQ__RequiredBy__c, orderItemId2)
            .setField(OrderItem.SBQQ__BundleRoot__c, orderItemId1)
            .setField(OrderItem.OrderItem_Type__c, 'New')
            .setParent(
                'SBQQ__BundleRoot__r',
                new Fake(OrderItem.class).setField(OrderItem.Id, orderItemId1)
            )
            .setParent(
                'SBQQ__RequiredBy__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId2)
                    .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            )
            .toSObject();

        OrderItem orderItem3 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId3)
            .setField(OrderItem.OrderId, orderId2)
            .setField(OrderItem.Product2Id, productId3)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP)
            .setField(OrderItem.OrderItem_Type__c, 'New')
            .toSObject();
        OrderItem orderItem4 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId4)
            .setField(OrderItem.OrderId, orderId2)
            .setField(OrderItem.Product2Id, productId2)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setField(OrderItem.OrderItem_Type__c, 'Existing')
            .toSObject();

        Map<String, Id> accountAgreementStringContractIdMap = new Map<String, Id>();
        Map<Id, Id> accountIdToFranchiseParentIdMap = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap = new Map<Id, Map<String, String>>();
        Map<Id, String> accountIdToAgreedToServicesMap = new Map<Id, String>();
        accountIdToAgreedToServicesMap.put(accountId, AGREED_TO_SERVICES_ALL);
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap = new Map<Id, Boolean>{
            accountId => true,
            accountId2 => false
        };
        Map<Id, Map<String, List<String>>> accountIdToSelectedPckgToDeselectedProdListMap = new Map<Id, Map<String, List<String>>>();

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, subscriptionId1)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription5 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId5)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId5)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId5)
                    .setField(OrderItem.OrderId, orderId1)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId2)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId3)
                    .setField(OrderItem.OrderId, orderId2)
            )
            .toSObject();
        SBQQ__Subscription__c subscription4 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId4)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId2)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId4)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
            )
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId4)
                    .setField(OrderItem.OrderId, orderId2)
            )
            .toSObject();

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4,
            subscription5
        };

        //String accountAgreementKey = String.valueOf(accountId) + '-' + PRODUCTCODE_MARKETPLACE;
        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId
        );
        accountAgreementStringContractIdMap.put(
            String.valueOf(accountId2) + '-' + PRODUCTCODE_MARKETPLACE,
            contractId2
        );

        Merchant_Service__c existingService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId1)
            .setfield(Merchant_Service__c.Product__c, productId)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_MARKETPLACE)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId1)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId2)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId2)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId2)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService3 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId3)
            .setField(Merchant_Service__c.Account__c, accountId2)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId3)
            .setfield(Merchant_Service__c.Product__c, productId3)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId3)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_PICKUP)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId3)
                    .setField(OrderItem.OrderId, orderId2)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId2)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService4 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId4)
            .setField(Merchant_Service__c.Account__c, accountId2)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId4)
            .setfield(Merchant_Service__c.Product__c, productId2)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId4)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_DELIVERY)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId4)
                    .setField(OrderItem.OrderId, orderId2)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId2)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId4)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId4)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        Merchant_Service__c existingService5 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, merchantServiceId5)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setfield(Merchant_Service__c.Order_Product__c, activationOrderItemId5)
            .setfield(Merchant_Service__c.Product__c, productId5)
            .setfield(Merchant_Service__c.Subscription__c, subscriptionId5)
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Product_Code__c, PRODUCTCODE_ADWT)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, activationOrderItemId5)
                    .setField(OrderItem.OrderId, orderId1)
                    .setField(OrderItem.Original_Provisioned_Date__c, System.today() - 3)
                    .setField(OrderItem.ServiceDate, System.today() - 2)
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
                    .setField(Account.RecordTypeId, storeAccRecordType)
                    .setField(Account.Rate_Change_Request__c, rcrId)
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId5)
                    .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId5)
                    .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
                    .setParent(
                        'SBQQ__Contract__r',
                        new Fake(Contract.class).setField(Contract.Integration_Source__c, null)
                    )
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{
            orderItem1,
            orderItem2,
            orderItem3,
            orderItem4,
            orderItem5
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId, contractId2 }))
            .thenReturn(new List<Contract>{ contract1, contract2 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId, contractId2 },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ accountId, accountId2 }
                )
            )
            .thenReturn(
                new List<Merchant_Service__c>{
                    existingService,
                    existingService2,
                    existingService3,
                    existingService4,
                    existingService5
                }
            );
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringContractIdMap,
            accountIdToFranchiseParentIdMap,
            accountIdToDeselectedServicesMap,
            accountIdToAgreedToServicesMap,
            amendedAccountIdToAutoProvisionValueMap,
            accountIdToSelectedPckgToDeselectedProdListMap,
            mockUOW
        );
        //New Package should return 'Yes' if Auto Provision is true
        system.assertEquals(
            existingService.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //New Product should be activated, if bundle service is 'yes' if Auto Provision is true
        system.assertEquals(
            existingService2.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //New sub product should be only activated if both root and immediate parent are actvated
        system.assertEquals(
            existingService5.Mx_Agreed_to_Product__c,
            'Yes',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //New Products or Packages should always return 'No' if auto provision is false
        system.assertEquals(
            existingService3.Mx_Agreed_to_Product__c,
            'No',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
        //Existing should always return same status as before for both auto provision true and false
        system.assertEquals(
            existingService4.Mx_Agreed_to_Product__c,
            'No',
            'Mx_Agreed_to_Product__c Field not updated Correctly'
        );
    }

    /**
     * @description It is used to test whether the drive products are skipped for service creation on
     * smb stores where 'Most Recent Nintex Use Case' is not "Drive Form - Franchise".
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenDriveProductsFoundOnNonDriveFranchiseNintexUseCaseThenServicesCreationSkippedOnSMBStores() {
        Id pizzaHutStoreAccountId = Fake.generateId(Account.class);
        Id dunkinsStoreId = Fake.generateId(Account.class);
        Id pizzaHutContractId = Fake.generateId(Contract.class);
        Id dunkinsContractId = Fake.generateId(Contract.class);
        Id pizzaHutOrderId = Fake.generateId(Order.class);
        Id dunkinsOrderId = Fake.generateId(Order.class);
        Id driveSOFOrderItemId = Fake.generateId(OrderItem.class);
        Id deliveryOrderItemId = Fake.generateId(OrderItem.class);
        Id pickupOrderItemId = Fake.generateId(OrderItem.class);
        Id driveLOFOrderItemId = Fake.generateId(OrderItem.class);
        Id driveSOFSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id deliverySubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id pickupSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id driveLOFSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id driveSOFMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id deliveryMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id pickupMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id driveLOFMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id driveLOFProductId = Fake.generateId(Product2.class);
        Id deliveryProductId = Fake.generateId(Product2.class);
        Id pickupProductId = Fake.generateId(Product2.class);

        Account pizzaHutStore = (Account) new Fake(Account.class)
            .setField(Account.Id, pizzaHutStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_STORE)
            .setField(Account.Most_Recent_Nintex_Use_Case__c, null)
            .toSObject();
        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract pizzaHutContract = new Contract(
            Id = pizzaHutContractId,
            SBQQ__Order__c = pizzaHutOrderId
        );
        Contract dunkinsContract = new Contract(
            Id = dunkinsContractId,
            SBQQ__Order__c = dunkinsOrderId
        );
        OrderItem driveSOFOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, driveSOFOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, driveLOFProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_SOF)
            .toSObject();
        OrderItem deliveryOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, deliveryOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, deliveryProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .toSObject();
        OrderItem pickupOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, pickupOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, pickupProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP)
            .toSObject();
        OrderItem driveLOFOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, driveLOFOrderItemId)
            .setField(OrderItem.OrderId, dunkinsOrderId)
            .setField(OrderItem.Product2Id, driveLOFProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_LOF)
            .toSObject();
        Map<String, Id> accountAgreementStringByContractIds = new Map<String, Id>();
        Map<Id, Id> accountIdsByFranchiseParentIds = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdByDeselectedServices = new Map<Id, Map<String, String>>();
        Map<Id, String> agreedToServicesMapByaccountId = new Map<Id, String>();
        agreedToServicesMapByaccountId.put(pizzaHutStoreAccountId, AGREED_TO_SERVICES_ALL);
        agreedToServicesMapByaccountId.put(dunkinsStoreId, AGREED_TO_SERVICES_MARKETPLACE);
        //Set<Id> amendedAccountIdSet = new Set<Id>();
        Map<Id, Boolean> autoProvisionValueMapByAmendedAccountId = new Map<Id, Boolean>();
        Map<Id, Map<String, List<String>>> accountIdToSelectedPackageToDeselectedProducts = new Map<Id, Map<String, List<String>>>();
        SBQQ__Subscription__c driveSOFSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, driveSOFOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveSOFOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c deliverySubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, deliverySubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, deliveryOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, deliveryOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c pickupSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, pickupSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, pickupOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, pickupOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c driveLOFSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, driveLOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, dunkinsContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, driveLOFOrderItemId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveLOFOrderItemId)
                    .setField(OrderItem.OrderId, dunkinsOrderId)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            drivesofsubscription,
            deliverySubscription,
            pickupSubscription,
            driveLOFSubscription
        };
        accountAgreementStringByContractIds.put(
            String.valueOf(pizzaHutStoreAccountId) + '-' + PRODUCTCODE_MARKETPLACE,
            pizzaHutContractId
        );
        accountAgreementStringByContractIds.put(
            String.valueOf(dunkinsStoreId) + '-' + PRODUCTCODE_MARKETPLACE,
            dunkinsContractId
        );
        Merchant_Service__c driveSOFService = new Merchant_Service__c(
            Id = driveSOFMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = driveLOFProductId,
            Product_Code__c = PRODUCTCODE_MARKETPLACE
        );
        Merchant_Service__c deliveryService = new Merchant_Service__c(
            Id = deliveryMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = deliveryProductId,
            Product_Code__c = PRODUCTCODE_DELIVERY
        );
        Merchant_Service__c pickupService = new Merchant_Service__c(
            Id = pickupMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = pickupProductId,
            Product_Code__c = PRODUCTCODE_PICKUP
        );
        Merchant_Service__c driveLOFService4 = new Merchant_Service__c(
            Id = driveLOFMerchantServiceId,
            Account__c = dunkinsStoreId,
            Product__c = driveLOFProductId,
            Product_Code__c = PRODUCTCODE_MARKETPLACE
        );
        List<OrderItem> orderItems = new List<OrderItem>{
            driveSOFOrderItem,
            deliveryOrderItem,
            pickupOrderItem,
            driveLOFOrderItem
        };
        List<String> deselectedProducts = new List<String>{ String.valueOf(pickupSubscriptionId) };
        Map<String, List<String>> deselectedProductsBySelectedPackages = new Map<String, List<String>>{
            String.valueOf(driveSOFSubscriptionId) => deselectedProducts
        };
        accountIdToSelectedPackageToDeselectedProducts.put(
            pizzaHutStoreAccountId,
            deselectedProductsBySelectedPackages
        );
        //ANSO FLOW
        accountIdToSelectedPackageToDeselectedProducts.put(
            dunkinsStoreId,
            new Map<String, List<String>>()
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractSelectorMock.selectById(
                    new Set<Id>{ pizzaHutContractId, dunkinsContractId }
                )
            )
            .thenReturn(new List<Contract>{ pizzaHutContract, dunkinsContract });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ pizzaHutContractId, dunkinsContractId },
                    false
                )
            )
            .thenReturn(subscriptions);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItems);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ pizzaHutStoreAccountId, dunkinsStoreId }
                )
            )
            .thenReturn(
                new List<Merchant_Service__c>{
                    driveSOFService,
                    deliveryService,
                    pickupService,
                    driveLOFService4
                }
            );
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectById(
                    new Set<Id>{ pizzaHutStoreAccountId, dunkinsStoreId }
                )
            )
            .thenReturn(new List<Account>{ pizzaHutStore });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringByContractIds,
            accountIdsByFranchiseParentIds,
            accountIdByDeselectedServices,
            agreedToServicesMapByaccountId,
            autoProvisionValueMapByAmendedAccountId,
            accountIdToSelectedPackageToDeselectedProducts,
            mockUOW
        );
        Test.stopTest();
        //Drive product skipped for service creation
        System.assertEquals(
            driveSOFService.Mx_Agreed_to_Product__c,
            null,
            SERVICE_CREATION_ASSERTION_FAILURE
        );
        //Selected Products should return 'Yes' if package/ bundle is 'Yes'
        System.assertEquals(
            deliveryService.Mx_Agreed_to_Product__c,
            MX_AGREED_YES,
            SERVICE_CREATION_ASSERTION_FAILURE
        );
    }

    /**
     * @description It is used to test whether the drive products are created as services on
     * smb stores where 'Most Recent Nintex Use Case' is "Drive Form - Franchise".
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenDriveProductsFoundOnDriveFranchiseNintexUseCaseThenServicesCreatedOnSMBStores() {
        Id pizzaHutStoreAccountId = Fake.generateId(Account.class);
        Id dunkinsStoreId = Fake.generateId(Account.class);
        Id pizzaHutContractId = Fake.generateId(Contract.class);
        Id dunkinsContractId = Fake.generateId(Contract.class);
        Id pizzaHutOrderId = Fake.generateId(Order.class);
        Id dunkinsOrderId = Fake.generateId(Order.class);
        Id driveSOFOrderItemId = Fake.generateId(OrderItem.class);
        Id deliveryOrderItemId = Fake.generateId(OrderItem.class);
        Id pickupOrderItemId = Fake.generateId(OrderItem.class);
        Id driveLOFOrderItemId = Fake.generateId(OrderItem.class);
        Id driveSOFSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id deliverySubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id pickupSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id driveLOFSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id driveSOFMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id deliveryMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id pickupMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id driveLOFMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id driveLOFProductId = Fake.generateId(Product2.class);
        Id deliveryProductId = Fake.generateId(Product2.class);
        Id pickupProductId = Fake.generateId(Product2.class);

        Account pizzaHutStore = (Account) new Fake(Account.class)
            .setField(Account.Id, pizzaHutStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_STORE)
            .setField(Account.Most_Recent_Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_FORM_FRANCHISE)
            .toSObject();
        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract pizzaHutContract = new Contract(
            Id = pizzaHutContractId,
            SBQQ__Order__c = pizzaHutOrderId
        );
        Contract dunkinsContract = new Contract(
            Id = dunkinsContractId,
            SBQQ__Order__c = dunkinsOrderId
        );
        OrderItem driveSOFOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, driveSOFOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, driveLOFProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_SOF)
            .toSObject();
        OrderItem deliveryOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, deliveryOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, deliveryProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_DELIVERY)
            .toSObject();
        OrderItem pickupOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, pickupOrderItemId)
            .setField(OrderItem.OrderId, pizzaHutOrderId)
            .setField(OrderItem.Product2Id, pickupProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_PICKUP)
            .toSObject();
        OrderItem driveLOFOrderItem = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, driveLOFOrderItemId)
            .setField(OrderItem.OrderId, dunkinsOrderId)
            .setField(OrderItem.Product2Id, driveLOFProductId)
            .setField(OrderItem.Product_Code__c, PRODUCTCODE_LOF)
            .toSObject();
        Map<String, Id> accountAgreementStringByContractIds = new Map<String, Id>();
        Map<Id, Id> accountIdsByFranchiseParentIds = new Map<Id, Id>();
        Map<Id, Map<String, String>> accountIdByDeselectedServices = new Map<Id, Map<String, String>>();
        Map<Id, String> agreedToServicesMapByaccountId = new Map<Id, String>();
        agreedToServicesMapByaccountId.put(pizzaHutStoreAccountId, AGREED_TO_SERVICES_ALL);
        agreedToServicesMapByaccountId.put(dunkinsStoreId, AGREED_TO_SERVICES_MARKETPLACE);
        //Set<Id> amendedAccountIdSet = new Set<Id>();
        Map<Id, Boolean> autoProvisionValueMapByAmendedAccountId = new Map<Id, Boolean>();
        Map<Id, Map<String, List<String>>> accountIdToSelectedPackageToDeselectedProducts = new Map<Id, Map<String, List<String>>>();
        SBQQ__Subscription__c drivesofsubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, driveSOFOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveSOFOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c deliverySubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, deliverySubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, deliveryOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, deliveryOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c pickupSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, pickupSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, pizzaHutContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, pickupOrderItemId)
            .setfield(SBQQ__Subscription__c.SBQQ__RootId__c, driveSOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, driveSOFSubscriptionId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, pickupOrderItemId)
                    .setField(OrderItem.OrderId, pizzaHutOrderId)
            )
            .toSObject();
        SBQQ__Subscription__c driveLOFSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, driveLOFSubscriptionId)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, dunkinsContractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, driveLOFOrderItemId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveLOFOrderItemId)
                    .setField(OrderItem.OrderId, dunkinsOrderId)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            drivesofsubscription,
            deliverySubscription,
            pickupSubscription,
            driveLOFSubscription
        };
        accountAgreementStringByContractIds.put(
            String.valueOf(pizzaHutStoreAccountId) + '-' + PRODUCTCODE_SOF,
            pizzaHutContractId
        );
        accountAgreementStringByContractIds.put(
            String.valueOf(dunkinsStoreId) + '-' + PRODUCTCODE_SOF,
            dunkinsContractId
        );
        Merchant_Service__c driveSOFService = new Merchant_Service__c(
            Id = driveSOFMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = driveLOFProductId,
            Product_Code__c = PRODUCTCODE_SOF
        );
        Merchant_Service__c deliveryService = new Merchant_Service__c(
            Id = deliveryMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = deliveryProductId,
            Product_Code__c = PRODUCTCODE_DELIVERY
        );
        Merchant_Service__c pickupService = new Merchant_Service__c(
            Id = pickupMerchantServiceId,
            Account__c = pizzaHutStoreAccountId,
            Product__c = pickupProductId,
            Product_Code__c = PRODUCTCODE_PICKUP
        );
        Merchant_Service__c driveLOFService4 = new Merchant_Service__c(
            Id = driveLOFMerchantServiceId,
            Account__c = dunkinsStoreId,
            Product__c = driveLOFProductId,
            Product_Code__c = PRODUCTCODE_LOF
        );
        List<OrderItem> orderItems = new List<OrderItem>{
            driveSOFOrderItem,
            deliveryOrderItem,
            pickupOrderItem,
            driveLOFOrderItem
        };
        List<String> deselectedProducts = new List<String>{ String.valueOf(pickupSubscriptionId) };
        Map<String, List<String>> deselectedProductsBySelectedPackages = new Map<String, List<String>>{
            String.valueOf(driveSOFSubscriptionId) => deselectedProducts
        };
        accountIdToSelectedPackageToDeselectedProducts.put(
            pizzaHutStoreAccountId,
            deselectedProductsBySelectedPackages
        );
        //ANSO FLOW
        accountIdToSelectedPackageToDeselectedProducts.put(
            dunkinsStoreId,
            new Map<String, List<String>>()
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractSelectorMock.selectById(
                    new Set<Id>{ pizzaHutContractId, dunkinsContractId }
                )
            )
            .thenReturn(new List<Contract>{ pizzaHutContract, dunkinsContract });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ pizzaHutContractId, dunkinsContractId },
                    false
                )
            )
            .thenReturn(subscriptions);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItems);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ pizzaHutStoreAccountId, dunkinsStoreId }
                )
            )
            .thenReturn(
                new List<Merchant_Service__c>{
                    driveSOFService,
                    deliveryService,
                    pickupService,
                    driveLOFService4
                }
            );
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectById(
                    new Set<Id>{ pizzaHutStoreAccountId, dunkinsStoreId }
                )
            )
            .thenReturn(new List<Account>{ pizzaHutStore });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ActivationOrderCreationService.createActivationOrdersForAccountContractMap(
            accountAgreementStringByContractIds,
            accountIdsByFranchiseParentIds,
            accountIdByDeselectedServices,
            agreedToServicesMapByaccountId,
            autoProvisionValueMapByAmendedAccountId,
            accountIdToSelectedPackageToDeselectedProducts,
            mockUOW
        );
        Test.stopTest();
        //Selected Products should return 'Yes' if package/ bundle is 'Yes'
        System.assertEquals(
            driveSOFService.Product_Code__c,
            PRODUCTCODE_SOF,
            SERVICE_CREATION_ASSERTION_FAILURE
        );
        //Selected Products should return 'Yes' if package/ bundle is 'Yes'
        System.assertEquals(
            driveLOFService4.Product_Code__c,
            PRODUCTCODE_LOF,
            SERVICE_CREATION_ASSERTION_FAILURE
        );
    }
}