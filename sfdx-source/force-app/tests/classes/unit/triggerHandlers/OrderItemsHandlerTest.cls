/**
 * @description This is test class for Order Item Trigger handler class
 * @author Deloitte
 * @date 13-09-2023
 */
@isTest(seeAllData=false)
public class OrderItemsHandlerTest {
    /**
     * @description This method is used to test Order Item Trigger handler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItemsHandler orderItemHandlerObject = new OrderItemsHandler(orderItemList);
        OrderItemsHandler.Constructor objConstructor = new OrderItemsHandler.Constructor();
        objConstructor.construct(orderItemList);
        System.assertNotEquals(
            orderItemHandlerObject,
            objConstructor.construct(orderItemList),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on Order Item update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateOrderItemsThenCallSetSubscriptionRateChangeComplete() {
        Id orderId = Fake.generateId(Order.class);
        Id orderItemId = Fake.generateId(OrderItem.class);

        OrderItem[] oldOrderItem = new List<OrderItem>{
            new OrderItem(
                Id = orderItemId,
                OrderId = orderId,
                Active_fee__c = 10,
                Active_commission__c = 11
            )
        };

        OrderItem[] newOrderItem = new List<OrderItem>{
            new OrderItem(
                Id = orderItemId,
                OrderId = orderId,
                Active_fee__c = 20,
                Active_commission__c = 21
            )
        };

        Set<Id> orderItemIds = new Set<Id>();
        orderItemIds.add(orderItemId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector orderItemsSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        ISubscriptionRateChangeService subscriptionRateChangeRequestsMock = (ISubscriptionRateChangeService) mocks.mock(
            ISubscriptionRateChangeService.class
        );

        mocks.startStubbing();
        mocks.when(orderItemsSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(orderItemsSelectorMock.selectPrimaryOrderItemsByIds(orderItemIds))
            .thenReturn(newOrderItem);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(orderItemsSelectorMock);
        Application.SERVICE.setMock(
            ISubscriptionRateChangeService.class,
            subscriptionRateChangeRequestsMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(
            newOrderItem,
            new Map<Id, SObject>(oldOrderItem)
        );
        fflib_SObjectDomain.triggerHandler(OrderItemsHandler.class);

        ((ISubscriptionRateChangeService) mocks.verify(subscriptionRateChangeRequestsMock, 1))
            .setSubscriptionRateChangeComplete(newOrderItem);
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
    private static void testWhenOrderItemIsInsertedThenPopulateGroup() {
        //ARRANGE
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        Id qli1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id qli2 = Fake.generateId(SBQQ__QuoteLine__c.class);

        OrderItem[] orderItemNew = new List<OrderItem>{
            new OrderItem(
                Id = orderItem1,
                SBQQ__QuoteLine__c = qli1
            ),
            new OrderItem(
                Id = orderItem2,
                SBQQ__QuoteLine__c = qli2
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItems orderItemMock = (IOrderItems) mocks.mock(IOrderItems.class);
        mocks.startStubbing();
        mocks.when(orderItemMock.getType()).thenReturn(Schema.OrderItem.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(orderItemMock);

        fflib_SObjectDomain.Test.Database.onInsert(orderItemNew);
        fflib_SObjectDomain.triggerHandler(OrderItemsHandler.class);
        ((IOrderItems) mocks.verify(orderItemMock, 1)).populateQuoteLineGroup();
    }

    /**
     * @description To test OrderItems class if it updates Type on Order to 'Core' or 'A&P' for given ‘Split_Category__c’ on OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInsertedThenInvokeOrderTypeUpdate() {
        Id mockquoteId1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockquoteId2 = Fake.generateId(SBQQ__QuoteLine__c.class);

        OrderItem[] newOrderItems = new List<OrderItem>{
            new OrderItem(
                Id = Fake.generateId(OrderItem.class),
                SBQQ__QuoteLine__c = mockquoteId1
            ),
            new OrderItem(
                Id = Fake.generateId(OrderItem.class),
                SBQQ__QuoteLine__c = mockquoteId2
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItems orderItemMock = (IOrderItems) mocks.mock(IOrderItems.class);
        mocks.startStubbing();
        mocks.when(orderItemMock.getType()).thenReturn(Schema.OrderItem.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(orderItemMock);
		Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(newOrderItems);
        Test.stopTest();
        fflib_SObjectDomain.triggerHandler(OrderItemsHandler.class);
        ((IOrderItems) mocks.verify(orderItemMock, 1)).updateOrderByOrderItemSplitCategory();
    }

}