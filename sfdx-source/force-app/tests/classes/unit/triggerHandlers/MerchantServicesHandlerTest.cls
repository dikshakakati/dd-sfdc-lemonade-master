/**
 * @description Handler Test Class for MerchantServices
 * @date 09/19/2022
 * @author DoorDash QTC
 */
@isTest
private class MerchantServicesHandlerTest {
    private static final String PRODUCT_NAME = 'Marketplace';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     * calls to Domain methods and no updates are directly performed using the
     * handler method.
     * The suppress warning used helps bypass the PMD Rule error for mandatory
     * assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenServicesAreInsertedThenCallWorkOrders() {
        Id service1 = Fake.generateId(Merchant_Service__c.class);
        Id service2 = Fake.generateId(Merchant_Service__c.class);
        Id orderitem1 = Fake.generateId(OrderItem.class);
        Id orderitem2 = Fake.generateId(OrderItem.class);
        Merchant_Service__c[] newServices = new List<Merchant_Service__c>{
            new Merchant_Service__c(
                Id = service1,
                Order_Product__c = orderitem1,
                Mx_Agreed_to_Product__c = 'Yes'
            ),
            new Merchant_Service__c(
                Id = service2,
                Order_Product__c = orderitem2,
                Mx_Agreed_to_Product__c = 'Yes'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsService orderItemsServiceMock = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        Application.Service.setMock(IOrderItemsService.class, orderItemsServiceMock);
        //ACT
        fflib_SObjectDomain.Test.Database.onInsert(newServices);
        fflib_SObjectDomain.triggerHandler(MerchantServicesHandler.class);
        //ASSERT
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            'Unexpected result: Record are not present in database'
        );
        ((IOrderItemsService) mocks.verify(orderItemsServiceMock, 1))
            .initiateChildWorkOrdersCreation(new Set<Id>{ orderitem1, orderitem2 }, false);
    }

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     * calls to Domain methods and no updates are directly performed using the
     * handler method.
     * The suppress warning used helps bypass the PMD Rule error for mandatory
     * assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenServicesAreUpdatedThenCallWorkOrders() {
        //ARRANGE
        Id service1 = Fake.generateId(Merchant_Service__c.class);
        Id service2 = Fake.generateId(Merchant_Service__c.class);
        Id service3 = Fake.generateId(Merchant_Service__c.class);
        Id orderitem1 = Fake.generateId(OrderItem.class);
        Id orderitem2 = Fake.generateId(OrderItem.class);
        Id orderitem3 = Fake.generateId(OrderItem.class);
        Id orderitem4 = Fake.generateId(OrderItem.class);
        Merchant_Service__c[] oldServices = new List<Merchant_Service__c>{
            new Merchant_Service__c(
                Id = service1,
                Order_Product__c = orderitem1,
                Mx_Agreed_to_Product__c = 'No'
            ),
            new Merchant_Service__c(
                Id = service2,
                Order_Product__c = orderitem2,
                Mx_Agreed_to_Product__c = 'No'
            ),
            new Merchant_Service__c(
                Id = service3,
                Order_Product__c = orderitem3,
                Mx_Agreed_to_Product__c = 'Yes'
            )
        };
        Merchant_Service__c[] newServices = new List<Merchant_Service__c>{
            new Merchant_Service__c(
                Id = service1,
                Order_Product__c = orderitem1,
                Mx_Agreed_to_Product__c = 'Yes'
            ),
            new Merchant_Service__c(
                Id = service2,
                Order_Product__c = orderitem2,
                Mx_Agreed_to_Product__c = 'Yes'
            ),
            new Merchant_Service__c(
                Id = service3,
                Order_Product__c = orderitem4,
                Mx_Agreed_to_Product__c = 'Yes'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsService orderItemsServiceMock = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        Application.Service.setMock(IOrderItemsService.class, orderItemsServiceMock);
        //ACT
        fflib_SObjectDomain.Test.Database.onUpdate(newServices, new Map<Id, SObject>(oldServices));
        fflib_SObjectDomain.triggerHandler(MerchantServicesHandler.class);
        ((IOrderItemsService) mocks.verify(orderItemsServiceMock, 1))
            .initiateChildWorkOrdersCreation(
                new Set<Id>{ orderitem1, orderitem2, orderitem4 },
                false
            );
    }

    /**
     * @description To test MerchantServices Trigger
     */
    @isTest
    private static void testWhenServicesInsertedThenRun() {
        Account parentAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert parentAccount;
        Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
            parentAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Product2 activeProduct = ServiceIntegrationDataBuilder.createProductInstance(PRODUCT_NAME);
        insert activeProduct;
        Contract mockContract = ServiceIntegrationDataBuilder.createContractsInstance(
            storeAccount.Id
        );
        insert mockContract;
        SBQQ__Subscription__c mockSubscription = ServiceIntegrationDataBuilder.createSubscriptionInstance(
            storeAccount.Id,
            mockContract.Id,
            activeProduct.Id
        );
        insert mockSubscription;
        Merchant_Service__c merchSer = ServiceIntegrationDataBuilder.createMerchantServiceInstance(
            storeAccount,
            mockSubscription
        );
        insert merchSer;
        System.assertNotEquals(null, merchSer.Id, 'Id is null');
    }
    
    /**
     * @description To test Merchant Services When the Service Records are Inserted,
     * Then invoke the method to deactivate the existing Merchant Services for 
     * Core Products in SMB which is part of package exlusion.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenServicesInsertedThenInvokeInactivationOfExistingServicesForCoreProducts() {
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id accountId = Fake.generateId(Account.class);
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id productId = Fake.generateId(Product2.class);
        Id orderItemId = Fake.generateId(OrderItem.class);
        List<Merchant_Service__c> newMerchantServices = new List<Merchant_Service__c>{
            new Merchant_Service__c(Id = merchantServiceId, Account__c = accountId, Subscription__c = subscriptionId, Order_Product__c = orderItemId, Product__c = productId)
         };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantServices merchantServicesMock = (IMerchantServices) mocks.mock(IMerchantServices.class);
        mocks.startStubbing();
        mocks.when(merchantServicesMock.getType()).thenReturn(Schema.Merchant_Service__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(merchantServicesMock);
		Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(newMerchantServices);
        fflib_SObjectDomain.triggerHandler(MerchantServicesHandler.class);
		Test.stopTest();
        ((IMerchantServices) mocks.verify(merchantServicesMock, 1)).inactivateExistingMxServicesOnCoreProducts();
    }
}