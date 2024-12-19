/**
 * @description This is test class for Orders Trigger handler class
 * @author ATG
 * @date 2022-04-05
 */
@isTest(seeAllData=false)
public class OrdersHandlerTest {
    public static final String ORDER_STATUS_DRAFT = 'Draft';

    /**
     * @description To test method call on Order insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderInsertedThenCall() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();
        Id activationRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Activation_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> orderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType
            ),
            new Order(
                Id = orderId2,
                Name = 'Activation Order',
                SBQQ__Quote__c = null,
                Ready_for_Activation__c = false,
                recordTypeId = activationRecordType
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrders ordersMock = (IOrders) mocks.mock(IOrders.class);
        mocks.startStubbing();
        mocks.when(ordersMock.getType()).thenReturn(Schema.Order.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(ordersMock);

        fflib_SObjectDomain.Test.Database.onInsert(orderList);
        fflib_SObjectDomain.triggerHandler(OrdersHandler.class);

        ((IOrders) mocks.verify(ordersMock, 1)).setReadyForActivation();
    }

    /**
     * @description To test method call on Order update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderUpdatedThenCallSetActiveSetContracted() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);

        List<Order> orderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Draft'
            )
        };

        List<Order> oldOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Draft'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersMock = (IOrders) mocks.mock(IOrders.class);
        mocks.startStubbing();
        mocks.when(ordersMock.getType()).thenReturn(Schema.Order.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(ordersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(orderList, new Map<Id, SObject>(oldOrderList));
        fflib_SObjectDomain.triggerHandler(OrdersHandler.class);

        ((IOrders) mocks.verify(ordersMock, 1)).setActive();
        ((IOrders) mocks.verify(ordersMock, 1)).setContracted();
    }
    /**
     * @description To validate if Order Status is updated to 'Activated' for 'Activation Orders' for Order Type as 'A&P'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderTypeAPThenUpdateStatusToActivated() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOrderId = Fake.generateId(Order.class);
        Id mockNewOrderId = Fake.generateId(Order.class);

        Order mockOldOrder = (Order) new Fake(Order.class)
            .setField(Order.Id, mockOrderId)
            .setField(Order.Name, 'Activation Order')
            .setField(Order.Type, Orders.ORDER_TYPE_A_P)
            .setField(Order.SBQQ__Quote__c, mockQuoteId)
            .setField(Order.recordTypeId, Orders.ACTIVATION_RECORD_TYPE_ID)
            .setField(Order.Account_Segment__c, Orders.ACCOUNT_SEGMENT_SMB)
            .setField(Order.Status, Orders.ORDER_STATUS_DRAFT)
            .toSObject();

        Order mockNewOrder = (Order) new Fake(Order.class)
            .setField(Order.Id, mockNewOrderId)
            .setField(Order.Name, 'Activation Order')
            .setField(Order.Type, Orders.ORDER_TYPE_A_P)
            .setField(Order.SBQQ__Quote__c, mockQuoteId)
            .setField(Order.recordTypeId, Orders.ACTIVATION_RECORD_TYPE_ID)
            .setField(Order.Account_Segment__c, Orders.ACCOUNT_SEGMENT_SMB)
            .setField(Order.Status, Orders.ACTIVATED)
            .toSObject();

        List<Order> mockOldOrders = new List<Order>();
        mockOldOrders.add(mockOldOrder);
        List<Order> mockNewOrders = new List<Order>();
        mockOldOrders.add(mockNewOrder);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersMock = (IOrders) mocks.mock(IOrders.class);
        mocks.startStubbing();
        mocks.when(ordersMock.getType()).thenReturn(Schema.Order.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(ordersMock);

        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(
            mockNewOrders,
            new Map<Id, SObject>(mockOldOrders)
        );
        fflib_SObjectDomain.triggerHandler(OrdersHandler.class);
        Test.stopTest();

        ((IOrders) mocks.verify(ordersMock, 1)).setStatusForActivationOrder();
    }

    /**
     * @description To test method call to quotes selector before migrated quotes are inserted
     *
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMigratedOrdersAreInsertedThenStartDateUpdatedWithQuoteStartDate() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id quoteId1 = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> orderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId1,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Activated'
            ),
            new Order(
                Id = orderId2,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId2,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Activated'
            )
        };

        List<Order> oldOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId1,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Draft'
            ),
            new Order(
                Id = orderId2,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId2,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType,
                status = 'Draft'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOrders ordersMock = (IOrders) mocks.mock(IOrders.class);

        mocks.startStubbing();
        mocks.when(ordersMock.getType()).thenReturn(Schema.Order.SObjectType);
        mocks.stopStubbing();

        Application.DOMAIN.setMock(ordersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(orderList, new Map<Id, SObject>(oldOrderList));
        fflib_SObjectDomain.triggerHandler(OrdersHandler.class);

        ((IOrders) mocks.verify(ordersMock, 1)).updateEffectiveDateForMigratedOrders();
    }
}