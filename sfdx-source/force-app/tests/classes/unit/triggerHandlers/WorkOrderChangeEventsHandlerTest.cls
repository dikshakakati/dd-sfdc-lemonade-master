/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Test class for WorkOrderChangeEventsHandler class.
 */
@isTest(SeeAllData=false)
private class WorkOrderChangeEventsHandlerTest {
    private static final String ASSOCIATED_ACCOUNT_IDS = 'Associated_Account_Ids__c';
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Records are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Records are not present in database';
    private static final String EXECUTE_READINESS_CHECK_FIELD = 'Execute_Readiness_Check__c';
    private static final String PARENT_WORK_ORDER_ID_FIELD = 'ParentWorkOrderId';
    private static final String PROVISIONING_STATUS_FIELD = 'Provisioning_Status__c';
    private static final String READINESS_CHECK_TRIGGER_SOURCE_CHANGE_EVENT = 'Change_Event';

    /**
     * @description To test that when WorkOrderChangeEvent is fired then readiness check is
     * tirggered on child Work Order and Work Plans creation is initiated on parent Work Order.
     */
    @isTest
    private static void testWhenWorkOrderCreateChangeEventFiredThenReadinessCheckAndWorkPlansCreationTriggered() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changetype = CHANGE_TYPE_CREATE;
        mockHeader.recordids = new List<Id>{ workOrderId };
        WorkOrderChangeEvent mockWorkOrderChangeEvent = new WorkOrderChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.Service.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<WorkOrderChangeEvent>{ mockWorkOrderChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrderChangeEventsHandler.class);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .runReadinessCheckOnChildWorkOrders(new Set<Id>{ workOrderId });
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .initiateWorkPlansCreation(new Set<Id>{ workOrderId }, CHANGE_TYPE_CREATE);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .initiateChildWorkOrderAutoCreation(new Set<Id>{ workOrderId });
    }

    /**
     * @description To test that when WorkOrderChangeEvent is fired with change type as Update
     * having Provioning Status as changed field then initiate Work Plans creation on
     * child Work Order.
     */
    @isTest
    private static void testWhenWorkOrderUpdateChangeEventFiredWithProvisioningStatusFieldChangeThenInitiateWorkPlansCreation() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changetype = CHANGE_TYPE_UPDATE;
        mockHeader.changedFields = new List<String>{ PROVISIONING_STATUS_FIELD };
        mockHeader.recordids = new List<Id>{ workOrderId };
        WorkOrderChangeEvent mockWorkOrderChangeEvent = new WorkOrderChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.Service.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<WorkOrderChangeEvent>{ mockWorkOrderChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrderChangeEventsHandler.class);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .initiateWorkPlansCreation(new Set<Id>{ workOrderId }, CHANGE_TYPE_UPDATE);
    }

    @isTest
    static void testWhenWorkOrderUpdateChangeEventFiredWithAssociatedAccountsFieldChangeThenInitiateChildWorkOrderCreation() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changetype = CHANGE_TYPE_UPDATE;
        mockHeader.changedFields = new List<String>{ ASSOCIATED_ACCOUNT_IDS };
        mockHeader.recordids = new List<Id>{ workOrderId };
        WorkOrderChangeEvent mockWorkOrderChangeEvent = new WorkOrderChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.Service.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<WorkOrderChangeEvent>{ mockWorkOrderChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrderChangeEventsHandler.class);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .initiateChildWorkOrderAutoCreation(new Set<Id>{ workOrderId });
    }

    /**
     * @description To test that when WorkOrderChangeEvent for ‘ParentWorkOrderId’ field change is
     * fired then readiness check is triggered on child Work Orders.
     */
    @isTest
    private static void testWhenWorkOrderUpdateChangeEventFiredWithParentWorkOrderUpdateThenReadinessCheckTriggeredForFlaggedChildWorkOrders() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EventBus.ChangeEventHeader mockHeader = new EventBus.ChangeEventHeader();
        mockHeader.changetype = CHANGE_TYPE_UPDATE;
        mockHeader.changedFields = new List<String>{ PARENT_WORK_ORDER_ID_FIELD };
        mockHeader.recordids = new List<Id>{ workOrderId };
        WorkOrderChangeEvent mockWorkOrderChangeEvent = new WorkOrderChangeEvent(
            ChangeEventHeader = mockHeader
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.Service.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<WorkOrderChangeEvent>{ mockWorkOrderChangeEvent }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrderChangeEventsHandler.class);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .runReadinessCheckOnChildWorkOrders(new Set<Id>{ workOrderId });
    }
}