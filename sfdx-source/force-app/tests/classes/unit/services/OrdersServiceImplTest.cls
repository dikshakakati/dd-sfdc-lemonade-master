/**
 * @author DoorDash QTC
 * @date 07/31/2022
 * @description Test class for OrdersServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public with sharing class OrdersServiceImplTest {
    public static final String ORDER_TYPE_CORE = 'Core';
    public static final String ORDER_TYPE_AP = 'A&P';
    public static final String ORDER_TYPE_NEW = 'New';
    /**
     * @description To test validation of Updating Orders with BackEnd Systems when
     * Order Items are created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInserThenUpdateOrders() {
        Id orderId1 = Fake.generateId(Order.class);

        Id productId1 = Fake.generateId(Product2.class);
        Id productId2 = Fake.generateId(Product2.class);
        Id productId3 = Fake.generateId(Product2.class);

        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);

        Order order1 = (Order) new Fake(Order.class)
            .setField(Order.Id, orderId1)
            .setField(Order.Backend_Systems__c, '')
            .toSObject();

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.OrderId, order1.Id)
            .setParent(
                'Product2',
                new Fake(Product2.class)
                    .setField(Product2.Name, 'Marketplace Catering')
                    .setField(Product2.Id, productId1)
                    .setField(Product2.IsActive, true)
                    .setField(Product2.Backend_System__c, 'MDS - Catering')
            )
            .toSObject();

        OrderItem orderItem2 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId2)
            .setField(OrderItem.OrderId, orderId1)
            .setParent(
                'Product2',
                new Fake(Product2.class)
                    .setField(Product2.Name, 'Marketplace')
                    .setField(Product2.Id, productId2)
                    .setField(Product2.IsActive, true)
                    .setField(Product2.Backend_System__c, 'MDS')
            )
            .toSObject();

        OrderItem orderItem3 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId3)
            .setField(OrderItem.OrderId, orderId1)
            .setParent(
                'Product2',
                new Fake(Product2.class)
                    .setField(Product2.Name, 'Drive')
                    .setField(Product2.Id, productId3)
                    .setField(Product2.IsActive, true)
                    .setField(Product2.Backend_System__c, 'DriveDb')
            )
            .toSObject();

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(orderItemSelectorMock.selectById(new Set<Id>{ orderItemId1, orderItemId2 }))
            .thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectProductBackEndByOrderItemIds(new Set<Id>{ orderId1 })
            )
            .thenReturn(orderItemList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        OrdersService.populateBackEndSystemsFieldOnOrder(new Set<Id>{ orderItemId1, orderItemId2 });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => orderId1,
                        Order.Backend_Systems__c => 'MDS - Catering;MDS;DriveDb'
                    }
                )
            );
    }

    /**
     * @description To test Order Type update to ‘Core’ for given ‘Split_Category__c’ on OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInsertedThenUpdateOrderTypeToCoreByOrderItemSplitCategory() {
        Id mockOrderId = fflib_IDGenerator.generate(Order.SObjectType);

        Map<Id, String> mockOrderIdToType = new Map<Id, String>{ mockOrderId => ORDER_TYPE_CORE };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OrdersService.updateOrderByOrderItemSplitCategory(mockOrderIdToType);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => mockOrderId,
                        Order.Type => ORDER_TYPE_CORE
                    }
                )
            );
    }

    /**
     * @description To test Order Type update to ‘A&P’ for given ‘Split_Category__c’ on OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInsertedThenUpdateOrderTypeToAandPByOrderItemSplitCategory() {
        Id orderId1 = Fake.generateId(Order.class);
        Id quoteId1 = Fake.generateId(SBQQ__Quote__c.class);

        Map<Id, String> mockOrderIdToType = new Map<Id, String>{ orderId1 => ORDER_TYPE_CORE };

        Fake testFakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId1)
            .setField(SBQQ__Quote__c.Nintex_Use_Case__c, 'Middleware Provider');

        Fake testFakeOrder = new Fake(Order.class)
            .setField(Order.Id, orderId1)
            .setField(Order.Backend_Systems__c, '')
            .setField(Order.SBQQ__Quote__c, quoteId1);

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) testFakeQuote.toSObject();
        Order newOrder = (Order) testFakeOrder.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOrdersSelector ordersSelectorMock = (IOrdersSelector) mocks.mock(IOrdersSelector.class);

        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(ordersSelectorMock.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(ordersSelectorMock.selectById(new Set<Id>{ orderId1 }))
            .thenReturn(new List<Order>{ newOrder });
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectById(new Set<Id>{ quoteId1 }))
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(ordersSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OrdersService.updateOrderByOrderItemSplitCategory(mockOrderIdToType);
        Test.stopTest();
    }
}