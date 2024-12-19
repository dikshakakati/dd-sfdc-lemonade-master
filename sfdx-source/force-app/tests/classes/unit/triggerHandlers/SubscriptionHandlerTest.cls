/**
 * @description Handler Test Class for SubscriptionHandler
 * @date 06/24/2023
 * @author Deloitte
 */
@isTest(seeAllData=false)
public class SubscriptionHandlerTest {
    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     * calls to Domain methods and no updates are directly performed using the
     * handler method.
     * The suppress warning used helps bypass the PMD Rule error for mandatory
     * assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSubscriptionIsInsertedThenCall() {
        //ARRANGE
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);
        Id con2 = Fake.generateId(Contract.class);

        SBQQ__Subscription__c[] subsNew = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(Id = subs1, SBQQ__Contract__c = Con1),
            new SBQQ__Subscription__c(Id = subs2, SBQQ__Contract__c = Con2)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Isubscriptions subscriptionMock = (Isubscriptions) mocks.mock(Isubscriptions.class);
        mocks.startStubbing();
        mocks.when(subscriptionMock.getType()).thenReturn(Schema.SBQQ__Subscription__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(subscriptionMock);

        fflib_SObjectDomain.Test.Database.onInsert(subsNew);
        fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
        ((Isubscriptions) mocks.verify(subscriptionMock, 1))
            .callContractServiceToUpdateContractName();
    }

    /**
     * @description this is used to test if OrderItemsService is called on Subscription Active rates update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSubscriptionIsUpdatedThenCallOrderItemsService() {
        //ARRANGE

        String primaryOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionRateChangeId = Fake.generateId(Subscription_Rate_Change__c.class);

        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.Active_fee__c, '10')
            .setField(OrderItem.Active_Commission__c, '20')
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId1)
            .setField(OrderItem.Quote_Line_Group__c, groupId)
            .setParent(
                'Order',
                new Fake(Order.class)
                    .setField(Order.Id, orderId1)
                    .setField(Order.RecordTypeId, primaryOrderRecordTypeId)
            )
            .toSObject();

        SBQQ__Subscription__c[] subsOld = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subs1,
                SBQQ__OrderProduct__c = orderItemId1,
                SBQQ__TerminatedDate__c = System.Today(),
                Subscription_Rate_Change__c = null,
                Active_fee__c = 13,
                Active_Commission__c = 20,
                Quote_Line_Group__c = groupId
            )
        };
        SBQQ__Subscription__c[] subsNew = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subs1,
                SBQQ__OrderProduct__c = orderItemId1,
                SBQQ__TerminatedDate__c = System.Today(),
                Subscription_Rate_Change__c = subscriptionRateChangeId,
                Active_fee__c = 43,
                Active_Commission__c = 12,
                Quote_Line_Group__c = groupId
            )
        };

        List<OrderItem> orderItems = new List<OrderItem>{ orderItem1 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );

        IOrderItemsService orderItemServiceMock = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );

        mocks.startStubbing();
        mocks.when(orderItemSelectorMock.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(orderItemSelectorMock.selectById(new Set<Id>{ orderItemId1 }))
            .thenReturn(orderItems);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SERVICE.setMock(IOrderItemsService.class, orderItemServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(subsNew, new Map<Id, SObject>(subsOld));

        fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
        ((IOrderItemsService) mocks.verify(orderItemServiceMock, 1))
            .populateActiveRatesOnPrimaryOrderItems(subsNew);
    }

    /**
     * @description To validate when SSMO or SSOB subscription record is inserted then initiate Work Order
     * creation.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSubscriptionIsInsertedWithIntegrationSourceSSMOorSSOBThenInitiateWorkOrderCreation() {
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);
        Id con2 = Fake.generateId(Contract.class);

        SBQQ__Subscription__c[] subsNew = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.Integration_Source__c, 'SSMO')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con2)
                .setField(SBQQ__Subscription__c.Integration_Source__c, 'SSOB')
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Isubscriptions subscriptionMock = (Isubscriptions) mocks.mock(Isubscriptions.class);
        mocks.startStubbing();
        mocks.when(subscriptionMock.getType()).thenReturn(Schema.SBQQ__Subscription__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(subscriptionMock);

        fflib_SObjectDomain.Test.Database.onInsert(subsNew);
        fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
        ((Isubscriptions) mocks.verify(subscriptionMock, 1))
            .evaluateAndInitalizeForWorkOrderCreation();
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
    public static void testWhenSubscriptionIsInsertedThenPopulateGroup() {
        //ARRANGE
        Id sub1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id qli1 = Fake.generateId(SBQQ__QuoteLine__c.class);

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, sub1)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, qli1)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptions subscriptionMock = (ISubscriptions) mocks.mock(ISubscriptions.class);
        mocks.startStubbing();
        mocks.when(subscriptionMock.getType()).thenReturn(Schema.SBQQ__Subscription__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(subscriptionMock);

        fflib_SObjectDomain.Test.Database.onInsert(subList);
        fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
        ((ISubscriptions) mocks.verify(subscriptionMock, 1)).populateQuoteLineGroup();
    }

    /**
     * @description It is used to validate if contract is updated when active subscriptions are passed
     * with product families.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSubscriptionIsInsertedThenCallClass() {
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);
        Id con2 = Fake.generateId(Contract.class);

        SBQQ__Subscription__c[] subsNew = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(Id = subs1, SBQQ__Contract__c = Con1),
            new SBQQ__Subscription__c(Id = subs2, SBQQ__Contract__c = Con2)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Isubscriptions subscriptionMock = (Isubscriptions) mocks.mock(Isubscriptions.class);
        mocks.startStubbing();
        mocks.when(subscriptionMock.getType()).thenReturn(Schema.SBQQ__Subscription__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(subscriptionMock);

        fflib_SObjectDomain.Test.Database.onInsert(subsNew);
        fflib_SObjectDomain.triggerHandler(SubscriptionHandler.class);
        ((Isubscriptions) mocks.verify(subscriptionMock, 1))
            .updateContractWithSubscritionProductFamily();
    }
}