/**
 * @author ATG
 * @date 2022-04-05
 * @description This is test class for Orders class
 */
@isTest(seeAllData=false)
public class OrdersTest {
    static final String ASSERT_ERROR_EFFECTIVE_DATE_NOT_CHANGED = 'Unexpected result: Effective date was not changed.';
    public static final String ORDER_TYPE_CORE = 'Core';

    /**
     * @description To test SetReadyForActivation call
     */
    @IsTest
    private static void testWhenOrdersInsertedThenSetReadyForActivation() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();
        Id activationRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Activation_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> ordersList = new List<Order>{
            new Order(Id = orderId1, Name = 'Primary Order', SBQQ__Quote__c = quoteId),
            new Order(Id = orderId2, Name = 'Activation Order', SBQQ__Quote__c = null)
        };

        IOrders ordersInstance = Orders.newInstance(ordersList);
        ordersInstance.setReadyForActivation();

        System.assertEquals(
            primaryRecordType,
            ordersList[0].recordTypeId,
            'The RecordType should be Primary'
        );
        System.assertEquals(
            true,
            ordersList[0].Ready_for_Activation__c,
            'The Ready_for_Activation__c field should be true'
        );
        System.assertEquals(
            activationRecordType,
            ordersList[1].recordTypeId,
            'The RecordType should be Primary'
        );
        System.assertEquals(
            false,
            ordersList[1].Ready_for_Activation__c,
            'The Ready_for_Activation__c field should be false'
        );
    }

    /**
     * @description To test SetActive call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrdersUpdatedThenSetActive() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> primaryOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                Status = 'Draft',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = Orders.PRIMARY_RECORD_TYPE_ID
            ),
            new Order(
                Id = orderId2,
                Name = 'Primary Order2',
                Status = 'Draft',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = Orders.PRIMARY_RECORD_TYPE_ID
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersInstance = Orders.newInstance(primaryOrderList);

        ordersInstance.setActive();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => orderId1,
                        Order.Status => Orders.ACTIVATED
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(new List<SObjectField>{ Order.Status })
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => orderId2,
                        Order.Status => Orders.ACTIVATED
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(new List<SObjectField>{ Order.Status })
            );
    }

    /**
     * @description To validate if Order Status is updated to 'Activated' for 'Activation Orders'
     * for Order Type as 'A&P'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderTypeAPThenUpdateStatusToActivated() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOrderId = Fake.generateId(Order.class);

        Order mockOldOrder = (Order) new Fake(Order.class)
            .setField(Order.Id, mockOrderId)
            .setField(Order.Name, 'Activation Order')
            .setField(Order.Type, Orders.ORDER_TYPE_A_P)
            .setField(Order.SBQQ__Quote__c, mockQuoteId)
            .setField(Order.recordTypeId, Orders.ACTIVATION_RECORD_TYPE_ID)
            .setField(Order.Account_Segment__c, Orders.ACCOUNT_SEGMENT_SMB)
            .setField(Order.Status, Orders.ORDER_STATUS_DRAFT)
            .toSObject();
        List<Order> mockOldOrders = new List<Order>();
        mockOldOrders.add(mockOldOrder);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        IOrders ordersInstance = Orders.newInstance(mockOldOrders);

        Test.startTest();
        ordersInstance.setStatusForActivationOrder();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To validate if Order Status is not updated to 'Activated' for
     * 'Activation Orders' for Order Type as 'A&P'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderTypeCoreThenNotUpdateStatusToActivated() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOrderId = Fake.generateId(Order.class);

        Order mockOldOrder = (Order) new Fake(Order.class)
            .setField(Order.Id, mockOrderId)
            .setField(Order.Name, 'Activation Order')
            .setField(Order.Type, ORDER_TYPE_CORE)
            .setField(Order.SBQQ__Quote__c, mockQuoteId)
            .setField(Order.recordTypeId, Orders.ACTIVATION_RECORD_TYPE_ID)
            .setField(Order.Account_Segment__c, Orders.ACCOUNT_SEGMENT_SMB)
            .setField(Order.Status, Orders.ORDER_STATUS_DRAFT)
            .toSObject();
        List<Order> mockOldOrders = new List<Order>();
        mockOldOrders.add(mockOldOrder);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        IOrders ordersInstance = Orders.newInstance(mockOldOrders);

        Test.startTest();
        ordersInstance.setStatusForActivationOrder();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => mockOrderId,
                        Order.Status => Orders.ACTIVATED
                    }
                )
            );
    }

    /**
     * @description To test SetActive call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNegativeConditionOrdersUpdatedThenDoNotSetActive() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();
        Id activationRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Activation_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);
        Id orderId3 = Fake.generateId(Order.class);

        //update orders that are Already Actiavted, Not primary record type, and not Ready_for_Activation__c
        List<Order> primaryOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Order',
                Status = Orders.ACTIVATED,
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType
            ),
            new Order(
                Id = orderId2,
                Name = 'Order2',
                Status = Orders.ACTIVATED,
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = activationRecordType
            ),
            new Order(
                Id = orderId3,
                Name = 'Order3',
                Status = 'Draft',
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = false,
                recordTypeId = primaryRecordType
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersInstance = Orders.newInstance(primaryOrderList);

        ordersInstance.setActive();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
    }

    /**
     * @description To test SetContracted call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrdersUpdatedThenSetContracted() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> primaryOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Contracted__c = false,
                Status = Orders.ACTIVATED,
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType
            ),
            new Order(
                Id = orderId2,
                Name = 'Primary Order',
                SBQQ__Contracted__c = false,
                Status = Orders.ACTIVATED,
                SBQQ__Quote__c = quoteId,
                Ready_for_Activation__c = true,
                recordTypeId = primaryRecordType
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersInstance = Orders.newInstance(primaryOrderList);
        ordersInstance.SetContracted();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => orderId1,
                        Order.SBQQ__Contracted__c => true
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Order.SBQQ__Contracted__c }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => orderId2,
                        Order.SBQQ__Contracted__c => true
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Order.SBQQ__Contracted__c }
                )
            );
    }

    /**
     * @description To test SetContracted call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNegativeConditionOrdersUpdatedThenDoNotSetContracted() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();
        Id activationRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Activation_Order')
            .getRecordTypeId();

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);
        Id orderId3 = Fake.generateId(Order.class);

        //update orders that are Already Contracted, Not primary record type, and Status = Draft
        List<Order> primaryOrderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Order1',
                SBQQ__Contracted__c = true,
                SBQQ__Quote__c = quoteId,
                Status = Orders.ACTIVATED,
                recordTypeId = primaryRecordType
            ),
            new Order(
                Id = orderId2,
                Name = 'Order2',
                SBQQ__Contracted__c = false,
                SBQQ__Quote__c = quoteId,
                Status = 'Draft',
                recordTypeId = primaryRecordType
            ),
            new Order(
                Id = orderId3,
                Name = 'Order3',
                SBQQ__Contracted__c = false,
                SBQQ__Quote__c = quoteId,
                Status = Orders.ACTIVATED,
                recordTypeId = activationRecordType
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IOrders ordersInstance = Orders.newInstance(primaryOrderList);

        ordersInstance.SetContracted();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
    }

    /**
     * @description To test Order Trigger
     */
    @isTest
    private static void testWhenOrderInsertedThenRun() {
        Account acc = new Account(Name = 'Test 1', Segment__c='SMB');
        insert acc;

        Order order = new Order(
            Name = 'Test 1',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert order;
        System.assertNotEquals(null, order.Id, 'Id is null');
    }

    /**
     * @description To test Order Trigger
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderInsertedThenUpdateMigratedOrdersStartDate() {
        Id primaryRecordType = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Date startDate = System.today().addMonths(1);

        Id quoteId1 = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        Set<Id> quoteIds = new Set<Id>{ quoteId1, quoteId2 };

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId1,
                Migrated_Record__c = true,
                Quote_Migration_External_ID__c = '12345',
                SBQQ__StartDate__c = startDate
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                Migrated_Record__c = false,
                Quote_Migration_External_ID__c = '23456',
                SBQQ__StartDate__c = System.today().addMonths(2)
            )
        };

        Id orderId1 = Fake.generateId(Order.class);
        Id orderId2 = Fake.generateId(Order.class);

        List<Order> orderList = new List<Order>{
            new Order(
                Id = orderId1,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId1,
                Ready_for_Activation__c = true,
                EffectiveDate = System.today().addDays(1),
                recordTypeId = primaryRecordType,
                status = 'Draft'
            ),
            new Order(
                Id = orderId2,
                Name = 'Primary Order',
                SBQQ__Quote__c = quoteId2,
                Ready_for_Activation__c = true,
                EffectiveDate = System.today().addDays(2),
                recordTypeId = primaryRecordType,
                status = 'Draft'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectById(quoteIds)).thenReturn(quoteList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(quotesSelectorMock);

        Orders.newInstance(orderList).updateEffectiveDateForMigratedOrders();

        System.assertEquals(
            orderList[0].EffectiveDate,
            startDate,
            ASSERT_ERROR_EFFECTIVE_DATE_NOT_CHANGED
        );
    }
}