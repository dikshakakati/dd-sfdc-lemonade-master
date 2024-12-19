/**
 * @author Deloitte
 * @date 24/06/2022
 * @description Test class for OrderItemChangeEventsHandler class.
 */
@isTest
private class OrderItemChangeEventsHandlerTest {
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String CONTRACT_ID_FIELD_NAME = 'SBQQ__Contract__c';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';

    /**
     * @description To test OrderItemChangeEvent on insert to Update Orders.
     */
    @isTest
    private static void testWhenInsertThenValidateUpdateOnOrders() {
        Id orderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        List<Id> orderIds = new List<Id>{ orderItemId };
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changetype = CHANGE_TYPE_CREATE;
        mockHeader.recordids = orderIds;
        OrderItemChangeEvent mockOrderItemChangeEvent = new OrderItemChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrdersService ordersServiceMock = (IOrdersService) mocks.mock(IOrdersService.class);
        Application.Service.setMock(IOrdersService.class, ordersServiceMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<OrderItemChangeEvent>{ mockOrderItemChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(OrderItemChangeEventsHandler.class);
        ((IOrdersService) mocks.verify(ordersServiceMock, 1))
            .populateBackEndSystemsFieldOnOrder(new Set<Id>{ orderItemId });
    }

    /**
     * @description To test initiation of Contract association to parent Work Order
     * when Order Items Contract field is changed.
     */
    @isTest
    private static void testWhenContractFieldChangedThenInitiateContractAssociationOnParentWorkOrders() {
        Id orderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        List<Id> orderIds = new List<Id>{ orderItemId };
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changedFields = new List<String>{ CONTRACT_ID_FIELD_NAME };
        mockHeader.changetype = CHANGE_TYPE_UPDATE;
        mockHeader.recordids = orderIds;
        OrderItemChangeEvent mockOrderItemChangeEvent = new OrderItemChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsService orderItemsServiceMock = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        Application.Service.setMock(IOrderItemsService.class, orderItemsServiceMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<OrderItemChangeEvent>{ mockOrderItemChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(OrderItemChangeEventsHandler.class);
        ((IOrderItemsService) mocks.verify(orderItemsServiceMock, 1))
            .invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(new Set<Id>{ orderItemId });
    }
}