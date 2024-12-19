/**
 * @author Deloitte
 * @date 21/08/2023
 * @description This is test class for OrderItems class
 */
@isTest(seeAllData=false)
public class OrderItemsTest {
    private static final String ASSERTION_FAILURE_MESSAGE = 'Default values not applied';
    public static final String ORDER_TYPE = 'Core';
    public static final String ORDER_RECORD_TYPE = 'Primary Order';
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();

    /**
     * @description This is method used to test OrderItems class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItems orderItemObject = new OrderItems(orderItemList);
        OrderItems.newInstance(orderItemList);
        System.assertNotEquals(
            OrderItems.newInstance(orderItemList),
            orderItemObject,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description To validate if OrderItem is inserted then orderItemsService
     * Should be called to Group
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemIsInsertedThenCallOrderItemServiceToUpdateGroup() {
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id qli1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id order1 = Fake.generateId(Order.class);

        List<OrderItem> orderItemList = new List<OrderItem>{
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, orderItem1)
                .setField(OrderItem.SBQQ__QuoteLine__c, qli1)
                .setField(OrderItem.OrderId, order1)
                .setParent(
                    'Order',
                    new Fake(Order.class)
                        .setField(Order.Id, order1)
                        .setField(Order.RecordTypeId, PRIMARY_ORDER_RECORD_TYPE_ID)
                )
                .toSobject()
        };

        Set<Id> orderItemIds = new Set<Id>{ orderItem1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IOrderItemsService mockOrderItemService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );

        mocks.startStubbing();
        mocks.when(orderItemSelectorMock.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(orderItemSelectorMock.selectOrderItemsWithPrimaryOrderFields(orderItemIds))
            .thenReturn(orderItemList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemService);
        //Act
        OrderItems.newInstance(orderItemList).populateQuoteLineGroup();
        //Assert
        ((IOrderItemsService) mocks.verify(mockOrderItemService, 1))
            .populateQuoteLineGroup(orderItemList);
    }

    /**
     * @description To test Order Type update to ‘Core’ for given ‘Split_Category__c’ on OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInsertedThenUpdateOrderTypeByOrderItemSplitCategory() {
        Id mockOrderItem = Fake.generateId(OrderItem.class);
        Id mockQuoteLine = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockQuote = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOrder = fflib_IDGenerator.generate(Order.SObjectType);
        List<Order> orderForDrive = new List<Order>{
            new Order(Id = mockOrder, SBQQ__Quote__c = mockQuote)
        };

        List<OrderItem> orderItemList = new List<OrderItem>{
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, mockOrderItem)
                .setField(OrderItem.SBQQ__QuoteLine__c, mockQuoteLine)
                .setField(OrderItem.OrderId, orderForDrive[0].Id)
                .setField(OrderItem.Split_Category__c, ORDER_TYPE)
                .setField(OrderItem.Order_Record_Type__c, ORDER_RECORD_TYPE)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrdersService mockOrderServices = (IOrdersService) mocks.mock(IOrdersService.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOrdersService.class, mockOrderServices);
        IOrderItems orderItemsInstance = new OrderItems(orderItemList);
        orderItemsInstance.updateOrderByOrderItemSplitCategory();
        ((IOrdersService) mocks.verify(mockOrderServices, 1))
            .updateOrderByOrderItemSplitCategory(new Map<Id, String>{ mockOrder => ORDER_TYPE });
    }

    /**
     * @description To test no updates to Order Type for blank ‘Split_Category__c’ on OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBlankOrderItemSplitCategoryThenDoNotUpdateOrderType() {
        Id mockOrderItem = Fake.generateId(OrderItem.class);
        Id mockQuoteLine = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockQuote = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOrder = fflib_IDGenerator.generate(Order.SObjectType);
        List<Order> orderForDrive = new List<Order>{
            new Order(Id = mockOrder, SBQQ__Quote__c = mockQuote)
        };

        List<OrderItem> orderItemList = new List<OrderItem>{
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, mockOrderItem)
                .setField(OrderItem.SBQQ__QuoteLine__c, mockQuoteLine)
                .setField(OrderItem.OrderId, orderForDrive[0].Id)
                .setField(OrderItem.Split_Category__c, '')
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrdersService mockOrderServices = (IOrdersService) mocks.mock(IOrdersService.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOrdersService.class, mockOrderServices);
        IOrderItems orderItemsInstance = new OrderItems(orderItemList);
        orderItemsInstance.updateOrderByOrderItemSplitCategory();
        ((IOrdersService) mocks.verify(mockOrderServices, 0))
            .updateOrderByOrderItemSplitCategory(new Map<Id, String>{ mockOrder => '' });
    }

    /**
     * @description It is used to test whether the default values are applied to OrderItem.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemInsertedThenFieldDefaultsApplied() {
        Id mockOrderItem = Fake.generateId(OrderItem.class);
        List<OrderItem> orderItemsForTiers = new List<OrderItem>{
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, mockOrderItem)
                .setField(OrderItem.SMB_Pricing_Tier__c, 2)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OrderItems.newInstance(orderItemsForTiers).defaultOrderItemFields();
        system.assertEquals(
            2,
            orderItemsForTiers[0].SMB_Pricing_Tier_Clone__c,
            ASSERTION_FAILURE_MESSAGE
        );
    }
}