/**
 * @author Deloitte
 * @date 10/15/2023
 * @description This is a test class created for DisplayBlockedWorkStepsController.
 */
@isTest(SeeAllData=false)
private class DisplayBlockedWorkStepsControllerTest {
    private static final String ERROR_MESSAGE = 'Unexpected Error: Values do not match.';
    private static final String MARKETPLACE = 'Marketplace';
    private static final String DRIVE = 'Drive';
    private static final String WORK_ORDER_STATUS = 'Pending';
    private static final String WORK_STEP_STATUS = 'Blocked';
    private static final String WORK_STEP_STATUS_ESCALATED= 'Escalated';
    private static final String TYPE_STRING = 'string';
    private static final String TYPE_URL = 'url';
    private static final String WORKPLAN_XREF_HYPERLINK = 'xrefHyperlink';//Added xref
    private static final String WORKPLAN_XREF_API = 'WorkPlan.Xref__c';//Added xref
    private static final String STORE_ACCOUNT_HYPERLINK = 'storeAccountHyperlink';
    private static final String STORE_ACCOUNT_API = 'Store_Account__c';
    private static final String WORK_PLAN_HYPERLINK = 'workPlanHyperlink';
    private static final String WORK_PLAN_ID = 'WorkPlanId';
    private static final String WORK_STEP_HYPERLINK = 'workStepHyperLink';
    private static final String NAME = 'Name';
    private static final String STATUS_REASON = 'Status Reason';
    private static final String STATUS_REASON_API = 'Status_Reason__c';
    private static final String STATUS_REASON_DETAILS_API = 'Status_Reason_Details__c';
    private static final String STATUS_REASON_DETAILS = 'Status Reason Details';

    //private static final String ULTIMATE_WORK_STEP_AGGREGATE_QUERY_COUNT_ALIAS = 'workStepsCount';
    //private static final String ULTIMATE_WORK_STEP_AGGREGATE_QUERY_STATUS_ALIAS = 'workStepStatus';

    /**
     * @description To test if fields are retrieved correctly when get fields method is called.
     */
    @isTest
    private static void testWhenGetFieldsMethodCalledThenReturnColumnsWithCorrectFieldsAndAtrributes() {
        String jsonData = DisplayBlockedWorkStepsController.getFields();
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(STORE_ACCOUNT_HYPERLINK, dynamicColumn[0].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_URL, dynamicColumn[0].type, ERROR_MESSAGE);
        System.assertEquals(
            STORE_ACCOUNT_API,
            dynamicColumn[0].typeAttributes.label.fieldName,
            ERROR_MESSAGE
        );
        System.assertEquals(WORK_PLAN_HYPERLINK, dynamicColumn[1].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_URL, dynamicColumn[1].type, ERROR_MESSAGE);
        System.assertEquals(
            WORK_PLAN_ID,
            dynamicColumn[1].typeAttributes.label.fieldName,
            ERROR_MESSAGE
        );
        System.assertEquals(WORK_STEP_HYPERLINK, dynamicColumn[2].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_URL, dynamicColumn[2].type, ERROR_MESSAGE);
        System.assertEquals(NAME, dynamicColumn[2].typeAttributes.label.fieldName, ERROR_MESSAGE);
        //added xref
        System.assertEquals(WORKPLAN_XREF_HYPERLINK, dynamicColumn[3].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_URL, dynamicColumn[3].type, ERROR_MESSAGE);
        System.assertEquals(WORKPLAN_XREF_API, dynamicColumn[3].typeAttributes.label.fieldName, ERROR_MESSAGE);
        //added xref
        System.assertEquals(STATUS_REASON_API, dynamicColumn[4].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_STRING, dynamicColumn[4].type, ERROR_MESSAGE);
        System.assertEquals(STATUS_REASON, dynamicColumn[4].label, ERROR_MESSAGE);
        System.assertEquals(STATUS_REASON_DETAILS_API, dynamicColumn[5].fieldName, ERROR_MESSAGE);
        System.assertEquals(TYPE_STRING, dynamicColumn[5].type, ERROR_MESSAGE);
        System.assertEquals(STATUS_REASON_DETAILS, dynamicColumn[5].label, ERROR_MESSAGE);
    }

    /**
     * @description To test if blocked Work Step records are retrieved for Marketplace Work Order
     * when getWorkStepDetails method is called.
     */
    @isTest
    private static void testWhenMarketplaceWorkOrderIdsPassedThenReturnBlockedWorkStepRecords() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, MARKETPLACE)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Opportunity__c, opportunityId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = MARKETPLACE,
                Status = WORK_ORDER_STATUS,
                AccountId = storeAccountId,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = opportunityId,
                ParentWorkOrderId = parentWorkOrder.Id
            )
        };
        WorkStep[] workSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.WorkOrderId, childWorkOrders[0].Id)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                .setFakeId()
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector workStepSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(childWorkOrders);
        mocks.when(workStepSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepSelectorMock.selectWorkStepsByWorkOrderIdsAndStatuses(
                    new Set<Id>{ childWorkOrders[0].Id },
                    new Set<String>{ WORK_STEP_STATUS }
                )
            )
            .thenReturn(workSteps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(workStepSelectorMock);
        List<WorkStep> blockedWorkSteps = DisplayBlockedWorkStepsController.getWorkStepDetails(
            parentWorkOrder.Id,WORK_STEP_STATUS
        );
        System.assertEquals(1, blockedWorkSteps.size(), ERROR_MESSAGE);
    }

    /**
     * @description To test if blocked Work Step records are retrieved for Drive WO
     * when getWorkStepDetails method is called.
     */
    @isTest
    private static void testWhenDriveWorkOrderIdsPassedThenReturnBlockedWorkStepRecords() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, DRIVE)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Opportunity__c, opportunityId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        WorkStep[] workSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.WorkOrderId, parentWorkOrder.Id)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                .setFakeId()
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector workStepSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(workStepSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepSelectorMock.selectWorkStepsByWorkOrderIdsAndStatuses(
                    new Set<Id>{ parentWorkOrder.Id },
                    new Set<String>{ WORK_STEP_STATUS }
                )
            )
            .thenReturn(workSteps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(workStepSelectorMock);
        List<WorkStep> blockedWorkSteps = DisplayBlockedWorkStepsController.getWorkStepDetails(
            parentWorkOrder.Id,WORK_STEP_STATUS
        );
        System.assertEquals(1, blockedWorkSteps.size(), ERROR_MESSAGE);
    }

    /**
     * @description To test if the click n pop mapping configuration meta data records are returned.
     */
    @isTest
    private static void testWhenGetResolutionStepIsInvokedThenReturnMappings() {
        Map<String, String> returnMappingRecords = new Map<String, String>();
        returnMappingRecords.putAll(DisplayBlockedWorkStepsController.getResolutionMap());
        System.assert(returnMappingRecords.size() > 0, ERROR_MESSAGE);
    }

    /**
     * @description To test if only store-level blocked Work Step records are retrieved
     * for Drive Work Order with stores when getWorkStepDetails method is called.
     */
    @isTest
    private static void testWhenDriveWorkOrderIdsWithStoresPassedThenReturnChildBlockedWorkStepRecords() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        List<WorkOrder> workOrdersToQuery = new List<WorkOrder>();
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, DRIVE)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Opportunity__c, opportunityId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = DRIVE,
                Status = WORK_ORDER_STATUS,
                AccountId = storeAccountId,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = opportunityId,
                ParentWorkOrderId = parentWorkOrder.Id
            )
        };
        List<WorkStep> childWorkSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.WorkOrderId, childWorkOrders[0].Id)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                .setFakeId()
                .toSObject()
        };
        workOrdersToQuery.add(parentWorkOrder);
        workOrdersToQuery.addAll(childWorkOrders);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector workStepSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(workOrdersToQuery);
        mocks.when(workStepSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepSelectorMock.selectWorkStepsByWorkOrderIdsAndStatuses(
                    new Set<Id>{ childWorkOrders[0].Id },
                    new Set<String>{ WORK_STEP_STATUS }
                )
            )
            .thenReturn(childWorkSteps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(workStepSelectorMock);
        Test.startTest();
        List<WorkStep> blockedWorkSteps = DisplayBlockedWorkStepsController.getWorkStepDetails(
            parentWorkOrder.Id,WORK_STEP_STATUS
        );
        Test.stopTest();
        System.assertEquals(1, blockedWorkSteps.size(), ERROR_MESSAGE);
        ((IWorkStepsSelector) mocks.verify(workStepSelectorMock, 0))
            .selectWorkStepsByWorkOrderIdsAndStatuses(
                new Map<Id, WorkOrder>(workOrdersToQuery).keySet(),
                new Set<String>{ WORK_STEP_STATUS }
            );
    }

    /**
* @description Test getWorkStepCountFilteredByConditionGroupedByWorkOrderIds method
* when getWorkStepCountFilteredByConditionGroupedByWorkOrderIds method is called.
*/
    @isTest
    private static void testWhenGetWorkStepCountFilteredByConditionThenGroupedByWorkOrderIds() {

        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, MARKETPLACE)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Opportunity__c, opportunityId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = MARKETPLACE,
                Status = WORK_ORDER_STATUS,
                AccountId = storeAccountId,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = opportunityId,
                ParentWorkOrderId = parentWorkOrder.Id
            )
                };
          WorkStep[] childWorkSteps = new List<WorkStep>{
              (WorkStep) new Fake(WorkStep.class)
                    .setField(WorkStep.WorkOrderId, childWorkOrders[0].Id)
                    .setField(WorkStep.Store_Account__c, storeAccountId)
                    .setField(WorkStep.Status__c, WORK_STEP_STATUS)
                    .setFakeId()
                    .toSObject()
               };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector workStepSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(childWorkOrders);
        mocks.when(workStepSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
            workStepSelectorMock.selectWorkStepsByWorkOrderIdsAndStatuses(
                new Set<Id>{ childWorkOrders[0].Id },
                new Set<String>{ WORK_STEP_STATUS }
            )
        )
            .thenReturn(childWorkSteps);

        List<Aggregate> agg = new List<Aggregate>();
        agg.add((new Aggregate()).put('Blocked',1));

        mocks.when(
            workStepSelectorMock.getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus( childWorkOrders[0].Id )
        )
            .thenReturn(agg);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(workStepSelectorMock);
        List<WorkStep> blockedWorkSteps = DisplayBlockedWorkStepsController.getWorkStepDetails(
            parentWorkOrder.Id,WORK_STEP_STATUS
        );

        Test.startTest();

        DisplayBlockedWorkStepsController.getWorkStepCountFilteredByConditionGroupedByWorkOrderIds(
            childWorkOrders[0].Id
        );
        Test.stopTest();

        System.assertEquals(1, blockedWorkSteps.size(), ERROR_MESSAGE);
    }


}