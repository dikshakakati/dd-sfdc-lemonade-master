/**
 * @author Deloitte
 * @date 03/20/2023
 * @description Test class for WorkOrderHistorySelector class.
 */
@isTest(SeeAllData=false)
private class WorkOrderHistorySelectorTest {
    private static final String ASSERT_MESSAGE_RETURN_SIZE_DO_NOT_MATCH = 'Unexpected result: query returned incorrect number of records.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Work Order History';
    private static final String WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID = System.Label.FakeWorkOrderIdToGenerateWorkOrderHistoryTestData;
    private static final String WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME = 'WorkOrderHistoryTestRecords';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        WorkOrderHistorySelector workOrderHistorySelectorInstance = new WorkOrderHistorySelector();
        Schema.SObjectType typeOfObject = workOrderHistorySelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = workOrderHistorySelectorInstance.getSObjectFieldList();
        WorkOrderHistorySelector.newInstance();
        System.assertEquals(
            Schema.WorkOrderHistory.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                WorkOrderHistory.Id,
                WorkOrderHistory.Field,
                WorkOrderHistory.OldValue,
                WorkOrderHistory.WorkOrderId
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on WorkOrderHistory when Work Order Ids are passed
     * then return Work Order Status History.
     */
    @isTest
    private static void testWhenWorkOrderIdsPassedThenWorkOrderStatusHistoryReturned() {
        // It is a workaround to overcome limitation with WorkOrderHistory records creation in test class.
        List<WorkOrderHistory> mockWorkOrderHistories = (List<WorkOrderHistory>) Test.loadData(
            WorkOrderHistory.sObjectType,
            WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME
        );
        Test.startTest();
        List<WorkOrderHistory> workOrderHistoryResult = WorkOrderHistorySelector.newInstance()
            .selectStatusHistoryByWorkOrderIds(
                new Set<Id>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID }
            );
        Test.stopTest();
        System.assertEquals(
            mockWorkOrderHistories.size(),
            workOrderHistoryResult.size(),
            ASSERT_MESSAGE_RETURN_SIZE_DO_NOT_MATCH
        );
    }
}