/**
 * @author Deloitte
 * @date 12/05/2022
 * @description Test class for WorkOrdersServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class WorkOrdersServiceImplTest {
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS = 'childWorkOrderCount';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS = 'posIntergrationType';
    private static final String AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS = 'provisioningStatus';
    private static final String AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS = 'tabletDeliveryMethod';
    private static final String AGGREGATE_UNIQUE_STORE_COUNT_ALIAS = 'uniqueStoreCount';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Order_Ids_Payload_Chunk_Size';
    private static final String CREATION_SOURCE_MANUAL = 'Manual';
    private static final String CREATION_SOURCE_NINTEX = 'Nintex';
    private static final String CREATION_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String DAY_SATURDAY = 'Sat';
    private static final String DAY_SUNDAY = 'Sun';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION = 'INITIATE_POS_CHILD_WORK_ORDERS_CREATION';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS = 'READINESS_CHECK_ON_CHILD_WORK_ORDERS';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE = 'WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS = 'CREATE_WORK_PLANS_ON_WORK_ORDERS';
    private static final String EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER = 'UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER';
    private static final String EXTERNAL_ID_STORE_ID = 'abc123';
    private static final String EXTERNAL_ID_BUSINESS_ID = '123';
    private static final String INCORRECT_OPPORTUNITY_RECORDS_RETUREND_ASSERT_MESSAGE = 'Unexpected result: The number of Opportunity records returned does not match';
    private static final String INCORRECT_PDOI_UPDATED_ASSERT_MESSAGE = 'Unexpected result: The PDOI updated does not match.';
    private static final String INTEGRATED_FRANCHISE_USE_CASE = 'Integrated Franchise';
    private static final String METADATA_VALUE = '1';
    private static final Integer NUMBER_OF_STORES = 2;
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_RECORD_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The Opportunity record does not match';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String ORDER_PROTOCOL_FAX = 'Fax';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READINESS_CHECK = 'Readiness Check';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_FAILED = 'Readiness Check Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE = 'Please ensure Legal Business Name is populated.';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME = 'Legal_Business_Name__c';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME = 'Account';
    private static final String READINESS_CHECK_TRIGGER_SOURCE_MANUAL = 'Manual';
    private static final String STAGENAME_CONTRACTING = 'Contracting';
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STORE_ASSOCIATION_PAYLOAD_SIZE = 'Store_Association_Payload_Size';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POS = 'POS';
    private static final String VERTICAL = 'Rx';
    private static final String WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID = System.Label.FakeWorkOrderIdToGenerateWorkOrderHistoryTestData;
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL = 'test@WorkOrdersTest.com';
    private static final String WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC = 'Automatic';
    private static final String WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME = 'WorkOrderHistoryTestRecords';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUB_TYPE_WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION = 'Partnership creation/update';
    private static final String WORKORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Work_Plans_Creation_Payload_Chunk_Size';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER';
    private static final String EXISTING_READINESS_ROWS_COUNT_CHECK = 'Existing_Readiness_Rows_Count_Check';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String CHURNED_MERCHANT = 'Churned Merchant';

    /**
     * @description To test when creation source is 'Nintex' then set "Proposed Date of Implementation" on
     * 'Storefront' bundled Work Orders.
     */
    @isTest
    private static void testWhenCreationSourceNintexThenSetPDOIOnStorefrontBundledWO() {
        WorkOrder mockNintexWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Creation_Source__c, CREATION_SOURCE_NINTEX)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();

        Test.startTest();
        WorkOrdersService.setProposedDateofImplementationOnSMBStorefrontWorkOrders(
            new List<WorkOrder>{ mockNintexWorkOrder }
        );
        Test.stopTest();
        System.assertEquals(
            WorkOrdersGeneratorService.calculateDateExcludingWeekends(System.today(), 3),
            mockNintexWorkOrder.Proposed_Date_of_Implementation__c,
            INCORRECT_PDOI_UPDATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when creation source is 'Onboarding Inputs' then set "Proposed Date of Implementation" on
     * 'Storefront' bundled Work Orders.
     */
    @isTest
    private static void testWhenCreationSourceOnboardingInputsThenSetPDOIOnStorefrontBundledWO() {
        WorkOrder mockOIWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Creation_Source__c, CREATION_SOURCE_ONBOARDING_INPUTS)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();

        Test.startTest();
        WorkOrdersService.setProposedDateofImplementationOnSMBStorefrontWorkOrders(
            new List<WorkOrder>{ mockOIWorkOrder }
        );
        Test.stopTest();
        System.assertEquals(
            WorkOrdersGeneratorService.calculateDateExcludingWeekends(System.today(), 3),
            mockOIWorkOrder.Proposed_Date_of_Implementation__c,
            INCORRECT_PDOI_UPDATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when creation source is 'Manual' then set "Proposed Date of Implementation" on
     * 'Storefront' Work Orders.
     */
    @isTest
    private static void testWhenCreationSourceManualThenSetPDOIOnStorefrontWO() {
        WorkOrder mockManualWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Creation_Source__c, CREATION_SOURCE_MANUAL)
            .setFakeId()
            .toSObject();

        Test.startTest();
        WorkOrdersService.setProposedDateofImplementationOnSMBStorefrontWorkOrders(
            new List<WorkOrder>{ mockManualWorkOrder }
        );
        Test.stopTest();
        System.assertEquals(
            WorkOrdersGeneratorService.calculateDateExcludingWeekends(System.today(), 10),
            mockManualWorkOrder.Proposed_Date_of_Implementation__c,
            INCORRECT_PDOI_UPDATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Work Order Type is 'Marketplace' the do not set "Proposed Date of Implementation"
     * on Work Order.
     */
    @isTest
    private static void testWhenTypeMarketplaceThenDoNotSetPDOIOnWorkOrder() {
        WorkOrder mockManualWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Creation_Source__c, CREATION_SOURCE_MANUAL)
            .setFakeId()
            .toSObject();

        Test.startTest();
        WorkOrdersService.setProposedDateofImplementationOnSMBStorefrontWorkOrders(
            new List<WorkOrder>{ mockManualWorkOrder }
        );
        Test.stopTest();
        System.assertEquals(
            null,
            mockManualWorkOrder.Proposed_Date_of_Implementation__c,
            INCORRECT_PDOI_UPDATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test update on Actual Number of Stores field in parent WorkOrder
     * based on unique Store Accounts linked to the child Work Orders.
     */
    @isTest
    private static void testWhenWorkOrderIdsAreReceivedThenCalculateAndUpdateActualNumberOfStores() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Aggregate mockAggregateStoresCount = new Aggregate();
        mockAggregateStoresCount.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrderId);
        mockAggregateStoresCount.put(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS, NUMBER_OF_STORES);
        Aggregate mockAggregateStoreLevelWorkPlansIndicators = new Aggregate();
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderId
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS,
            null
        );
        mockAggregateStoreLevelWorkPlansIndicators.put(
            AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS,
            null
        );
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrderId);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoresCount });
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.when(
                mockWorkOrdersSelector.getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoreLevelWorkPlansIndicators });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Actual_Number_Of_Stores__c => NUMBER_OF_STORES
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test update on Account's Owner updates Owner Email on WorkOrder.
     */
    @isTest
    private static void testWhenAccountIdsAreReceivedThenUpdateAccountOwnerEmail() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(new List<WorkOrder>{ mockWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ accountId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_ACCOUNT_OWNER_EMAIL_ON_WORK_ORDER
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Account_Owner_Email_Id__c => WORK_ORDER_ACCOUNT_OWNER_EMAIL
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test update Provisioning Status field on parent Work Orders received
     * via payload of NotifierEvent on basis of child Work Orders Provisioning Status.
     */
    @isTest
    private static void testWhenParentWorkOrderIdsReceivedByNotifierEventThenUpdateProvisioningStatusOnParentWorkOrders() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderWithProvisioningStatusFailedFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrderWithProvisioningStatusFailed = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderWithProvisioningStatusFailedFakeInstance
        );
        Fake parentWorkOrderWithProvisioningStatusCompleteFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrderWithProvisioningStatusComplete = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderWithProvisioningStatusCompleteFakeInstance
        );
        Aggregate mockAggregateForFailedWorkOrder = new Aggregate();
        mockAggregateForFailedWorkOrder.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderWithProvisioningStatusFailed.Id
        );
        mockAggregateForFailedWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_PROVISIONING_FAILED
        );
        mockAggregateForFailedWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        Aggregate mockAggregateForCompletedWorkOrder = new Aggregate();
        mockAggregateForCompletedWorkOrder.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderWithProvisioningStatusComplete.Id
        );
        mockAggregateForCompletedWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_PROVISIONING_COMPLETE
        );
        mockAggregateForCompletedWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 3);
        List<Aggregate> mockAggregateList = new List<Aggregate>{
            mockAggregateForFailedWorkOrder,
            mockAggregateForCompletedWorkOrder
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{
                        parentWorkOrderWithProvisioningStatusFailed.Id,
                        parentWorkOrderWithProvisioningStatusComplete.Id
                    }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(
            new Set<Id>{
                parentWorkOrderWithProvisioningStatusFailed.Id,
                parentWorkOrderWithProvisioningStatusComplete.Id
            }
        );
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_PROVISIONING_FAILED,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test update on WorkOrder Status when PDOM is past due and Status is updated to Escalated.
     */
    @isTest
    private static void testWhenPDOMIsPastDueThenUpdateStatusToInReview() {
        WorkOrder mockWorkOrderPDOMPastDue = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today() - 4)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today() + 4)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setFakeId()
            .toSObject();
        WorkOrder mockWorkOrderPDOTPastDue = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 4)
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today() + 2)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today() - 4)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setFakeId()
            .toSObject();
        WorkOrder mockWorkOrderPDOAPastDue = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() - 2)
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today() - 4)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today() + 4)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setFakeId()
            .toSObject();
        WorkOrder mockWorkOrderAtRiskStatus = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today() - 4)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today() + 4)
            .setField(WorkOrder.Status, STATUS_AT_RISK)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setFakeId()
            .toSObject();
        WorkOrder mockWorkOrderPDOMPastDueInEscalatedStatus = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACCOUNT_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.today() - 4)
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today() + 4)
            .setField(WorkOrder.Status, STATUS_ESCALATED)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateWorkOrderStatus(
            new List<WorkOrder>{
                mockWorkOrderPDOMPastDue,
                mockWorkOrderPDOTPastDue,
                mockWorkOrderPDOAPastDue,
                mockWorkOrderAtRiskStatus,
                mockWorkOrderPDOMPastDueInEscalatedStatus
            }
        );
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>{
            new WorkOrder(Id = mockWorkOrderPDOMPastDue.Id, Status = STATUS_AT_RISK),
            new WorkOrder(Id = mockWorkOrderPDOTPastDue.Id, Status = STATUS_AT_RISK),
            new WorkOrder(Id = mockWorkOrderPDOAPastDue.Id, Status = STATUS_PAST_DUE),
            new WorkOrder(Id = mockWorkOrderAtRiskStatus.Id, Status = STATUS_AT_RISK),
            new WorkOrder(
                Id = mockWorkOrderPDOMPastDueInEscalatedStatus.Id,
                Status = STATUS_AT_RISK
            )
        };
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(workOrdersToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Provisioning Complete"
     * on parent Work Order when Provisioning Status on child Work Order
     * is updated to "Provisioning Complete".
     */
    @isTest
    private static void testWhenChildWorkOrdersInProvisioningCompleteThenRollUpProvisioningCompleteToParentWorkOrders() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderWithProvisioningStatusCompleteFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrderWithProvisioningStatusComplete = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderWithProvisioningStatusCompleteFakeInstance
        );
        Aggregate mockAggregateForCompletedWorkOrder = new Aggregate();
        mockAggregateForCompletedWorkOrder.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderWithProvisioningStatusComplete.Id
        );
        mockAggregateForCompletedWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_PROVISIONING_COMPLETE
        );
        mockAggregateForCompletedWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 3);
        List<Aggregate> mockAggregateList = new List<Aggregate>{
            mockAggregateForCompletedWorkOrder
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderWithProvisioningStatusComplete.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(
            new Set<Id>{ parentWorkOrderWithProvisioningStatusComplete.Id }
        );
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_PROVISIONING_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Provisioning Failed"
     * on parent Work Order when Provisioning Status on child Work Order
     * is updated to "Provisioning Failed".
     */
    @isTest
    private static void testWhenChildWorkOrderInProvisioningFailedThenRollUpProvisioningFailedToParentWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderWithProvisioningStatusFailedFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrderWithProvisioningStatusFailed = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderWithProvisioningStatusFailedFakeInstance
        );
        Aggregate mockAggregateForFailedWorkOrder = new Aggregate();
        mockAggregateForFailedWorkOrder.put(
            AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS,
            parentWorkOrderWithProvisioningStatusFailed.Id
        );
        mockAggregateForFailedWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_PROVISIONING_FAILED
        );
        mockAggregateForFailedWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForFailedWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderWithProvisioningStatusFailed.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(
            new Set<Id>{ parentWorkOrderWithProvisioningStatusFailed.Id }
        );
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_PROVISIONING_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Readiness Check"
     * on parent Work Order when child Work Order is created with "Readiness Check"
     * Provisioning Status.
     */
    @isTest
    private static void testWhenChildWorkOrdersInReadinessCheckThenRollUpReadinessCheckToParentWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Ready for Provisioning"
     * on parent Work Order when Provisioning Status on child Work Order
     * is updated to "Ready for Provisioning".
     */
    @isTest
    private static void testWhenChildWorkOrdersInReadyForProvisioningThenRollUpReadyForProvisioningOnParentWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READY_FOR_PROVISIONING
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READY_FOR_PROVISIONING,
                        WorkOrder.Execute_Readiness_Check__c => false,
                        WorkOrder.HasWorkPlansGenerated__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Readiness Check Failed"
     * on parent Work Order when Provisioning Status on child Work Order
     * is updated to "Readiness Check Failed".
     */
    @isTest
    private static void testWhenChildWorkOrdersInReadinessCheckFailedThenRollUpReadinessCheckFailedOnParentWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK_FAILED
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK_FAILED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status updates to "Readiness Check Complete"
     * on parent Work Order when Provisioning Status on child Work Order
     * is updated to "Readiness Check Complete".
     */
    @isTest
    private static void testWhenChildWorkOrdersInReadinessCheckCompleteThenRollUpReadinessCheckCompletOnParentWorkOrder() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Provisioning Status is changed to "Ready for Provisioning"
     * on child Work Order received in payload from Notifier event.
     */
    @isTest
    private static void testWhenReadyForProvisioningNotificationReceivedThenChildWOMarkedReadyForProvisioning() {
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                fflib_IDGenerator.generate(Account.SObjectType),
                TYPE_MARKETPLACE,
                fflib_IDGenerator.generate(WorkOrder.SObjectType)
            )
            .setField(WorkOrder.HasWorkPlansGenerated__c, false)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ childWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_READY_FOR_PROVISIONING_UPDATE
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READY_FOR_PROVISIONING,
                        WorkOrder.HasWorkPlansGenerated__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test clean-up of business Account related "Readiness Check Failures"
     * and triggering of "Readiness Check" on child Work Order.
     */
    @isTest
    private static void testWhenRunReadinessCheckCalledThenExistingParentWOFailuresDeletedAndReadinessCheckTriggered() {
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                fflib_IDGenerator.generate(Account.SObjectType),
                TYPE_MARKETPLACE,
                fflib_IDGenerator.generate(WorkOrder.SObjectType)
            )
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> existingReadinessCheckFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId,
                Child_Work_Order__c = childWorkOrder.ParentWorkOrderId,
                Account_Name__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        ISobjectDeletionService mockSobjectDeletionService = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IStoreReadinessCheckService mockStoreReadinessCheckService = (IStoreReadinessCheckService) mocks.mock(
            IStoreReadinessCheckService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ childWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);

        mocks.when(
                mockReadinessCheckFailuresSelector.selectByChildWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId, childWorkOrder.Id }
                )
            )
            .thenReturn(existingReadinessCheckFailureRecords);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, mockSobjectDeletionService);
        Application.SERVICE.setMock(
            IStoreReadinessCheckService.class,
            mockStoreReadinessCheckService
        );
        WorkOrdersService.runReadinessCheckOnChildWorkOrders(new Set<Id>{ childWorkOrder.Id });
        ((IStoreReadinessCheckService) mocks.verify(mockStoreReadinessCheckService))
            .runReadinessCheckOnWorkOrders(
                (Set<Id>) fflib_Match.anyObject(),
                (List<Readiness_Check_Failure__c>) fflib_Match.eqList(
                    existingReadinessCheckFailureRecords
                )
            );
    }

    /**
     * @description To test restriction on corporate Opportunity Stage change to Contracting
     * when it has no associated Work Order.
     **/
    @isTest
    private static void testWhenWorkOrderNotAssociatedThenRestrictUpdationOfOpportunityStageToContracting() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            StageName = STAGENAME_CONTRACTING
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ mockOpportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        List<Opportunity> opportunitiesWithoutWorkOrder = WorkOrdersService.collectOpportunitiesWithoutWorkOrder(
            new List<Opportunity>{ mockOpportunity }
        );
        System.assertEquals(
            1,
            opportunitiesWithoutWorkOrder.size(),
            INCORRECT_OPPORTUNITY_RECORDS_RETUREND_ASSERT_MESSAGE
        );
        System.assertEquals(
            mockOpportunity.Id,
            opportunitiesWithoutWorkOrder[0].Id,
            OPPORTUNITY_RECORD_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test clean-up of business Account related "Readiness Check Failures"
     * and triggering of "Readiness Check" on parent Work Order when Type is 'Drive'
     * and sub-type is 'Partnership creation/update'.
     */
    @isTest
    private static void testWhenTypeDriveAndSubTypePartnershipCreationThenReadinessCheckTriggeredOnParentWorkOrder() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Execute_Readiness_Check__c, true)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> existingReadinessCheckFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        ISobjectDeletionService mockSobjectDeletionService = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IStoreReadinessCheckService mockStoreReadinessCheckService = (IStoreReadinessCheckService) mocks.mock(
            IStoreReadinessCheckService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(existingReadinessCheckFailureRecords);
        mocks.when(mockReadinessCheckFailuresSelector.selectByChildWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<Readiness_Check_Failure__c>{});
        mocks.when(
                mockWorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(
                    parentWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, mockSobjectDeletionService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        Application.SERVICE.setMock(
            IStoreReadinessCheckService.class,
            mockStoreReadinessCheckService
        );
        WorkOrdersService.runReadinessCheckOnParentWorkOrders(
            new Set<Id>{ parentWorkOrder.Id },
            READINESS_CHECK_TRIGGER_SOURCE_MANUAL
        );
        ((IStoreReadinessCheckService) mocks.verify(mockStoreReadinessCheckService))
            .runReadinessCheckOnWorkOrders(
                (set<Id>) fflib_Match.anyObject(),
                (List<Readiness_Check_Failure__c>) fflib_match.eqList(
                    existingReadinessCheckFailureRecords
                )
            );
    }

    /**
     * @description To test clean-up of Account related "Readiness Check Failures"
     * and trigger "Readiness Check" on parent Work Order when Type is 'Marketplace'.
     */
    @isTest
    private static void testWhenStoreExpectedOnParentWorkOrderThenReadinessCheckTriggeredOnChildWorkOrders() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Execute_Readiness_Check__c, true)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> existingReadinessCheckFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        ISobjectDeletionService mockSobjectDeletionService = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IStoreReadinessCheckService mockStoreReadinessCheckService = (IStoreReadinessCheckService) mocks.mock(
            IStoreReadinessCheckService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(existingReadinessCheckFailureRecords);
        mocks.when(mockReadinessCheckFailuresSelector.selectByChildWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<Readiness_Check_Failure__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, mockSobjectDeletionService);
        Application.SERVICE.setMock(
            IStoreReadinessCheckService.class,
            mockStoreReadinessCheckService
        );
        WorkOrdersService.runReadinessCheckOnParentWorkOrders(
            new Set<Id>{ parentWorkOrder.Id },
            READINESS_CHECK_TRIGGER_SOURCE_MANUAL
        );
        ((IStoreReadinessCheckService) mocks.verify(mockStoreReadinessCheckService))
            .runReadinessCheckOnWorkOrders(
                (Set<Id>) fflib_Match.anyObject(),
                (List<Readiness_Check_Failure__c>) fflib_Match.eqList(
                    existingReadinessCheckFailureRecords
                )
            );
    }

    /**
     * @description LEM-2703 To test generating provisioning events for work orders for Drive
     */
    @isTest
    private static void testWhenReadyForProvisioningThenGenerateDriveProvisioningEventForWorkOrders() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_DRIVE
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                workOrderSelectorMock.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>());
        mocks.when(
                workOrderSelectorMock.selectDriveAmendedOpportunityWorkOrdersByWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.generateProvisioningEventForDriveWorkOrders(
            new Set<Id>{ parentWorkOrder.Id }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
    /**
     * @description To test generating provisioning events for work orders.
     */
    @isTest
    private static void testWhenProvisioningCompleteThenUpdateStoreFrontWorkOrders() {
        Id storeId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeId2 = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_PROVISIONING_COMPLETE)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder1 = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.AccountId, storeId1)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder2 = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.AccountId, storeId2)
            .setFakeId()
            .toSObject();
        WorkOrder storeFrontParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setFakeId()
            .toSObject();
        WorkOrder storeFrontchildWorkOrder1 = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, storeFrontParentWorkOrder.Id)
            .setField(WorkOrder.AccountId, storeId1)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setFakeId()
            .toSObject();
        WorkOrder storeFrontchildWorkOrder2 = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, storeFrontParentWorkOrder.Id)
            .setField(WorkOrder.AccountId, storeId2)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder1, childWorkOrder2 });
        mocks.when(
                workOrderSelectorMock.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder1, childWorkOrder2 });
        mocks.when(
                workOrderSelectorMock.selectWorkOrdersByAccountIds(
                    new Set<Id>{ storeId1, storeId2 }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ storeFrontchildWorkOrder1, storeFrontchildWorkOrder2 }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.updateChildWorkOrdersStatusToProvisioningComplete(
            new Set<Id>{ parentWorkOrder.Id }
        );
        ((IWorkOrdersSelector) mocks.verify(workOrderSelectorMock, 1))
            .selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });
    }

    /**
     * @description To test ‘Stores Association In Progress’ banner indicator is enabled
     * on parent Work Order when the current status of banner indicator is disabled.
     */
    @isTest
    private static void testWhenToggleBannerOnParentWorkOrdersThenBannerIndicatorEnabled() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, oppId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.SBQQ__AmendedContract__c, contractId);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.IsStoresAssociationInProgress__c, false)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.toggleBannerOnParentWorkOrders(new Set<Id>{ parentWorkOrder.Id });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.IsStoresAssociationInProgress__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test ‘Stores Association In Progress’ banner indicator is disabled
     * on parent Work Order when the current status of banner indicator is enabled.
     */
    @isTest
    private static void testWhenToggleBannerOnParentWorkOrdersThenBannerIndicatorDisabled() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, oppId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.SBQQ__AmendedContract__c, contractId);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.IsStoresAssociationInProgress__c, true)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.toggleBannerOnParentWorkOrders(new Set<Id>{ parentWorkOrder.Id });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.IsStoresAssociationInProgress__c => false
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test 'Account Owner Email' field updates on Work Order
     * when store Account merged/reparented.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersStoreAccountsMergedThenWorkOrdersUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setChildren(
                'WorkSteps',
                new List<Fake>{ new Fake(WorkStep.class).setField(WorkStep.Id, workStepId) }
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Aggregate mockAggregateStoresCount = new Aggregate();
        mockAggregateStoresCount.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateStoresCount.put(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS, NUMBER_OF_STORES);
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrder.Id);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoresCount });
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.processMergedAccountsRelatedRecords(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.Actual_Number_Of_Stores__c => NUMBER_OF_STORES
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => childWorkOrder.Id,
                            WorkOrder.Account_Owner_Email_Id__c => WORK_ORDER_ACCOUNT_OWNER_EMAIL
                        },
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Account_Owner_Email_Id__c => WORK_ORDER_ACCOUNT_OWNER_EMAIL
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when type 'Drive' and sub-type 'Net new business' parent Work Order
     * provisioning status is updated to Readiness Check Complete then Work Plans are created.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDriveNetNewBusinessParentWorkOrderMarkedReadinessCheckCompleteThenWorkPlansCreated() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, INTEGRATED_FRANCHISE_USE_CASE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectParentAndChildrenByIds(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ childWorkOrder.Id },
            CHANGE_TYPE_UPDATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 1))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ childWorkOrder });
    }

    /**
     * @description To test relevant Work Plans not created when provisioning status is
     * updated to 'Readiness Check Complete' on Marketplace child Work Order.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketplaceChildWorkOrderMarkedReadinessCheckCompleteThenRelatedWorkPlansNotCreated() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkOrderFakeInstance(parentAccount.Id, TYPE_MARKETPLACE)
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithParentWorkPlanId(
                parentWorkPlan.Id,
                childWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(
                    new Set<Id>{ childWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkPlan>{ parentWorkPlan });
        mocks.when(mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(new Set<Id>()))
            .thenReturn(new List<WorkPlan>());
        mocks.when(mockWorkPlanTemplatesSelector.SObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ childWorkPlan.Type__c })
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ parentWorkPlan.Type__c }
                }
            );
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ childWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    childWorkOrder.Id => new Set<String>{ childWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ childWorkOrder.Id },
            CHANGE_TYPE_UPDATE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkPlan.Name => TYPE_MARKETPLACE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test no Work Plans are created when provisioning status is updated
     * to 'Readiness Check Complete' on Marketplace parent Work Order without stores.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketplaceParentWorkOrderWithoutStoresMarkedReadinessCheckCompleteThenNoWorkPlansGenerated() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, workOrderId);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ childWorkOrder.Id },
            CHANGE_TYPE_UPDATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 0))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ childWorkOrder });
    }

    /**
     * @description To test when type 'Drive' and sub-type 'Net new business' parent Work Order
     * inserted and auto creation of Work Plans is not enabled then Work Plans are not created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrderWithWorkPlanAutoCreationDisabledInsertedThenWorkPlansNotCreated() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE,
            IsActive = true,
            Work_Plan_Default_Status__c = STATUS_NOT_STARTED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
        );
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder newWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(new Set<Id>{ newWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ newWorkOrder.Id },
            CHANGE_TYPE_CREATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 0))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ newWorkOrder });
    }

    /**
     * @description To test when type 'Drive' and sub-type 'Auto Activation' parent Work Order
     * for Integrated Franchise scenario inserted with Provisioning Status as
     * 'Readiness Check Complete' then create Work Plans.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIntegratedFranchiseParentWorkOrderWithReadinessCheckCompleteInsertedThenCreateWorkPlans() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE,
            IsActive = true,
            Work_Plan_Default_Status__c = STATUS_NOT_STARTED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
        );
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder newWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(new Set<Id>{ newWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ newWorkOrder.Id },
            CHANGE_TYPE_CREATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 1))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ newWorkOrder });
    }

    /**
     * @description To test creation of Work Plans on parent Work Order where Type is Drive and
     * sub-type is 'Partnership creation/update' and stores are not expected through bypassing
     * store eligibility.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoresNotExpectedOnDrivePartnershipCreationWorkOrderThenWorkPlansGeneratedThroughBypassingStoreEligibility() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder newWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(new Set<Id>{ newWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ newWorkOrder });
        mocks.when(mockWorkOrderSettingsService.isWorkPlansAutoCreationEnabled(newWorkOrder))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ newWorkOrder.Id },
            CHANGE_TYPE_CREATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 1))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ newWorkOrder });
    }

    /**
     * @description To test Contract association on parent Work Orders
     * based on the Account and Contract Id mappings received.
     */
    @isTest
    private static void testWhenAccountContractIdMappingsReceivedThenContractsAssociatedOnParentWorkOrders() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Contract__c, null)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrderSelectorMock.selectByAccountIds(new Set<Id>{ parentBusinessAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.associateContractsOnParentWorkOrders(
            new Map<Id, Id>{ parentBusinessAccount.Id => contractId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.Contract__c => contractId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test Contract not re-associated on parent Work Orders when Contract already
     * exists and Account & Contract Id mappings received.
     */
    @isTest
    private static void testWhenContractExistsOnParentWorkOrderThenContractNotReassociated() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id newContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Contract__c, contractId)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrderSelectorMock.selectByAccountIds(new Set<Id>{ parentBusinessAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        WorkOrdersService.associateContractsOnParentWorkOrders(
            new Map<Id, Id>{ parentBusinessAccount.Id => newContractId }
        );
        // parent Work Orders not updated since associated Contract exists.
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDirty(new List<WorkOrder>{});
    }

    /**
     * @description test copy xref external id to work order store id
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateStoreIdsOnChildWorkOrdersCalledThenCopyStoreId() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<WorkOrder> workOrdersList = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, workOrderId)
                .setField(WorkOrder.AccountId, accountId)
                .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
                .toSObject()
        };

        List<Xref__c> xrefsList = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.External_ID__c, EXTERNAL_ID_STORE_ID)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId)
                .toSObject()
        };

        List<WorkOrder> expectedWorkOrdersList = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, workOrderId)
                .setField(WorkOrder.AccountId, accountId)
                .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
                .setField(WorkOrder.Store_ID__c, EXTERNAL_ID_STORE_ID)
                .setField(WorkOrder.Business_Id__c, null)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(workOrdersList);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectBySalesforceAccountName(new Set<Id>{ accountId }))
            .thenReturn(xrefsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrdersService.updateStoreIdsOnChildWorkOrders(new Set<Id>{ accountId });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(expectedWorkOrdersList[0]);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test the population of Store Id and Business Id of the child Ads & Promos Work Order.
     * @JIRA# LEM-18577
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateStoreIdsOnChildWorkOrdersCalledThenCopyBusinessId() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xRefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        List<WorkOrder> workOrders = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, workOrderId)
                .setField(WorkOrder.AccountId, accountId)
                .setField(WorkOrder.Type__c, WORKORDER_TYPE_ADS_AND_PROMOS)
                .toSObject()
        };

        Fake businessReferenceFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.External_Id__c, EXTERNAL_ID_BUSINESS_ID);

        List<Xref__c> xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Id, xRefId)
                .setField(Xref__c.External_ID__c, EXTERNAL_ID_STORE_ID)
                .setField(Xref__c.Salesforce_Account_Name__c, accountId)
                .setParent('Business_Reference__r', businessReferenceFakeInstance)
                .setField(Xref__c.Business_Reference__c, businessReferenceId)
                .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                .toSObject()
        };

        List<WorkOrder> expectedWorkOrders = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, workOrderId)
                .setField(WorkOrder.AccountId, accountId)
                .setField(WorkOrder.Type__c, WORKORDER_TYPE_ADS_AND_PROMOS)
                .setField(WorkOrder.Store_ID__c, EXTERNAL_ID_STORE_ID)
                .setField(WorkOrder.Business_Id__c, EXTERNAL_ID_BUSINESS_ID)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(workOrders);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefsSelector.selectBySalesforceAccountName(new Set<Id>{ accountId }))
            .thenReturn(xrefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrdersService.updateStoreIdsOnChildWorkOrders(new Set<Id>{ accountId });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerDirty(expectedWorkOrders[0]);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test "Readiness Check" triggered on child Work Order in chunks when
     * the number of associated child Work Orders exceeds the configured size.
     */
    @isTest
    private static void testWhenStoreExpectedOnParentWorkOrderThenReadinessCheckTriggeredOnChildWorkOrdersInChunks() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake childAccountWithFaxOrderProtocolFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccountWithFaxOrderProtocol = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountWithFaxOrderProtocolFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Execute_Readiness_Check__c, true)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkOrderForFaxStoreFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountWithFaxOrderProtocol.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', childAccountWithFaxOrderProtocolFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrderForFaxStore = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderForFaxStoreFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<Id> childWorkOrderIdsChunk1 = new List<Id>{ childWorkOrder.Id };
        List<Id> childWorkOrderIdsChunk2 = new List<Id>{ childWorkOrderForFaxStore.Id };
        List<String> payloads = new List<String>{
            JSON.serialize(childWorkOrderIdsChunk1),
            JSON.serialize(childWorkOrderIdsChunk2)
        };
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EXISTING_READINESS_ROWS_COUNT_CHECK))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EXISTING_READINESS_ROWS_COUNT_CHECK,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(STORE_ASSOCIATION_PAYLOAD_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = STORE_ASSOCIATION_PAYLOAD_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder, childWorkOrderForFaxStore });
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ childWorkOrder.Id, childWorkOrderForFaxStore.Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        WorkOrdersService.runReadinessCheckOnParentWorkOrders(
            new Set<Id>{ parentWorkOrder.Id },
            READINESS_CHECK_TRIGGER_SOURCE_MANUAL
        );
        ((INotifierEventsPayloadGenerationService) mocks.verify(
                notifierEventsPayloadGenerationServiceMock,
                1
            ))
            .generateChunkedPayloadsBySobjectIds(
                new Set<Id>{ childWorkOrder.Id, childWorkOrderForFaxStore.Id },
                Integer.valueOf(METADATA_VALUE)
            );
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS => payloads
                }
            );
    }

    /**
     * @description To test readiness check triggered on child Work Orders received
     * in payload from Notifier event.
     */
    @isTest
    private static void testWhenReadinessCheckOnChildWorkOrdersNotificationReceivedThenReadinessCheckTriggeredOnChildWorkOrders() {
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
            fflib_IDGenerator.generate(Account.SObjectType),
            TYPE_MARKETPLACE,
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> existingReadinessCheckFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                Parent_Work_Order__c = childWorkOrder.ParentWorkOrderId,
                Child_Work_Order__c = childWorkOrder.ParentWorkOrderId,
                Account_Name__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        ISobjectDeletionService mockSobjectDeletionService = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IStoreReadinessCheckService mockStoreReadinessCheckService = (IStoreReadinessCheckService) mocks.mock(
            IStoreReadinessCheckService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ childWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.selectByChildWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId, childWorkOrder.Id }
                )
            )
            .thenReturn(existingReadinessCheckFailureRecords);
        mocks.when(mockReadinessCheckFailuresSelector.selectByParentWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<Readiness_Check_Failure__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, mockSobjectDeletionService);
        Application.SERVICE.setMock(
            IStoreReadinessCheckService.class,
            mockStoreReadinessCheckService
        );
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_READINESS_CHECK_ON_CHILD_WORK_ORDERS
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((IStoreReadinessCheckService) mocks.verify(mockStoreReadinessCheckService))
            .runReadinessCheckOnWorkOrders(
                new Set<Id>{ childWorkOrder.Id },
                existingReadinessCheckFailureRecords
            );
    }

    /**
     * @description To test chunking of Work Order Ids to publish bulk notifier events
     * when count of Work Order Ids received exceeds configured chunk size.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBulkWorkOrderIdsReceivedThenPublishBulkNotifierEventsWithChunkedPayload() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake childAccountWithFaxOrderProtocolFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccountWithFaxOrderProtocol = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountWithFaxOrderProtocolFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setParent('Account', childAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkOrderForFaxStoreFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountWithFaxOrderProtocol.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setParent('Account', childAccountWithFaxOrderProtocolFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrderForFaxStore = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderForFaxStoreFakeInstance
        );
        Set<Id> workOrderIds = new Set<Id>{ childWorkOrder.Id, childWorkOrderForFaxStore.Id };
        Integer workOrderIdsChunkSizeToCreateWorkPlans = Integer.valueOf(METADATA_VALUE);
        List<Id> firstSetOfFilteredIds = new List<Id>{ childWorkOrder.Id };
        List<Id> secondSetOfFilteredIds = new List<Id>{ childWorkOrderForFaxStore.Id };
        List<String> mockPayloads = new List<String>{
            JSON.serialize(firstSetOfFilteredIds),
            JSON.serialize(secondSetOfFilteredIds)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(
                    new Set<Id>{ childWorkOrder.Id, childWorkOrderForFaxStore.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder, childWorkOrderForFaxStore });
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(STORE_ASSOCIATION_PAYLOAD_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = STORE_ASSOCIATION_PAYLOAD_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EXISTING_READINESS_ROWS_COUNT_CHECK))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EXISTING_READINESS_ROWS_COUNT_CHECK,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    workOrderIds,
                    workOrderIdsChunkSizeToCreateWorkPlans
                )
            )
            .thenReturn(mockPayloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );
        WorkOrdersService.initiateWorkPlansCreation(workOrderIds, CHANGE_TYPE_UPDATE);
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS => mockPayloads
                }
            );
    }

    /**
     * @description To test initiaion of Work Plans creation without publishing bulk events
     * on Readiness Check complete child Work Orders when count of Work Order Ids received
     * less than configured chunk size.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChildWorkOrdersMarkedReadinessCheckCompleteThenInitiateWorkPlansCreation() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Execute_Readiness_Check__c, true)
            .setField(WorkOrder.Nintex_Use_Case__c, INTEGRATED_FRANCHISE_USE_CASE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        String eventPayload = JSON.serialize(new Set<Id>{ childWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_PLANS_CREATION_ON_WORK_ORDERS
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 1))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(new List<WorkOrder>{ childWorkOrder });
    }

    /**
     * @description To test Work Orders Status is updated based on Work Order History
     * when PDOA, PDOM and PDOT are updated to future dates.
     */
    @isTest
    private static void testWhenWorkOrdersWithPDOxUpdateReceivedThenUpdateStatusByWorkOrderHistory() {
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.now().dateGMT().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.now().dateGMT().addDays(6))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.now().dateGMT().addDays(5));
        WorkOrder workOrderInstance = (WorkOrder) workOrderFakeInstance.toSObject();
        // It is a workaround to overcome limitation with WorkOrderHistory records creation in test class.
        List<WorkOrderHistory> mockWorkOrderHistories = (List<WorkOrderHistory>) Test.loadData(
            WorkOrderHistory.sObjectType,
            WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderHistorySelector mockWorkOrderHistorySelector = (WorkOrderHistorySelector) mocks.mock(
            WorkOrderHistorySelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrderHistorySelector.SObjectType())
            .thenReturn(WorkOrderHistory.SObjectType);
        mocks.when(
                mockWorkOrderHistorySelector.selectStatusHistoryByWorkOrderIds(
                    new Set<Id>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID }
                )
            )
            .thenReturn(mockWorkOrderHistories);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrderHistorySelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateWorkOrderStatusByWorkOrderHistory(
            new Map<Id, WorkOrder>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID => workOrderInstance }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID,
                            WorkOrder.Status => STATUS_IN_PROGRESS
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Orders Status is updated to 'At Risk'
     * when PDOA,PDOT is in future and PDOM is in past.
     */
    @isTest
    private static void testWhenWorkOrdersWithPDOMInPastReceivedThenUpdateStatusToAtRisk() {
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.now().dateGMT().addDays(2))
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.now().dateGMT().addDays(-2))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.now().dateGMT().addDays(5));
        WorkOrder workOrderInstance = (WorkOrder) workOrderFakeInstance.toSObject();
        // It is a workaround to overcome limitation with WorkOrderHistory records creation in test class.
        List<WorkOrderHistory> mockWorkOrderHistories = (List<WorkOrderHistory>) Test.loadData(
            WorkOrderHistory.sObjectType,
            WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderHistorySelector mockWorkOrderHistorySelector = (WorkOrderHistorySelector) mocks.mock(
            WorkOrderHistorySelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrderHistorySelector.SObjectType())
            .thenReturn(WorkOrderHistory.SObjectType);
        mocks.when(
                mockWorkOrderHistorySelector.selectStatusHistoryByWorkOrderIds(
                    new Set<Id>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID }
                )
            )
            .thenReturn(mockWorkOrderHistories);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrderHistorySelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateWorkOrderStatusByWorkOrderHistory(
            new Map<Id, WorkOrder>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID => workOrderInstance }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID,
                            WorkOrder.Status => STATUS_AT_RISK
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Orders Status is updated to 'At Risk'
     * when PDOA,PDOM is in future and PDOT is in past.
     */
    @isTest
    private static void testWhenWorkOrdersWithPDOTInPastReceivedThenUpdateStatusToAtRisk() {
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.now().dateGMT().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.now().dateGMT().addDays(6))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.now().dateGMT().addDays(-7));
        WorkOrder workOrderInstance = (WorkOrder) workOrderFakeInstance.toSObject();
        // It is a workaround to overcome limitation with WorkOrderHistory records creation in test class.
        List<WorkOrderHistory> mockWorkOrderHistories = (List<WorkOrderHistory>) Test.loadData(
            WorkOrderHistory.sObjectType,
            WORK_ORDER_HISTORY_STATIC_RESOURCE_NAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderHistorySelector mockWorkOrderHistorySelector = (WorkOrderHistorySelector) mocks.mock(
            WorkOrderHistorySelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrderHistorySelector.SObjectType())
            .thenReturn(WorkOrderHistory.SObjectType);
        mocks.when(
                mockWorkOrderHistorySelector.selectStatusHistoryByWorkOrderIds(
                    new Set<Id>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID }
                )
            )
            .thenReturn(mockWorkOrderHistories);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrderHistorySelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateWorkOrderStatusByWorkOrderHistory(
            new Map<Id, WorkOrder>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID => workOrderInstance }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID,
                            WorkOrder.Status => STATUS_AT_RISK
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Orders Status is updated to 'Planning' when
     * WorkOrderHistory does not match and PDOA, PDOM and PDOT are in future.
     */
    @isTest
    private static void testWhenWorkOrderHistoryDoesNotMatchThenUpdateStatusToPlanning() {
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.now().dateGMT().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Menu__c, System.now().dateGMT().addDays(6))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.now().dateGMT().addDays(5));
        WorkOrder workOrderInstance = (WorkOrder) workOrderFakeInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkOrderHistorySelector mockWorkOrderHistorySelector = (WorkOrderHistorySelector) mocks.mock(
            WorkOrderHistorySelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrderHistorySelector.SObjectType())
            .thenReturn(WorkOrderHistory.SObjectType);
        mocks.when(
                mockWorkOrderHistorySelector.selectStatusHistoryByWorkOrderIds(
                    new Set<Id>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID }
                )
            )
            .thenReturn(new List<WorkOrderHistory>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrderHistorySelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateWorkOrderStatusByWorkOrderHistory(
            new Map<Id, WorkOrder>{ WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID => workOrderInstance }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => WORK_ORDER_HISTORY_FAKE_WORK_ORDER_ID,
                            WorkOrder.Status => STATUS_PLANNING
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of relevant Work Plans on parent and child
     * Work Orders when provisioning status is updated to 'Readiness Check Complete'
     * on Marketplace parent Work Order.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketplaceParentWorkOrderMarkedReadinessCheckCompleteThenRelevantWorkPlansCreatedOnParentAndChildWorkOrders() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                TYPE_MARKETPLACE,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_STARTED;
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                VERTICAL
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanFakeInstanceWithParentWorkPlanId(
                parentWorkPlan.Id,
                childWorkOrder.Id,
                mockWorkPlanTemplate
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder, parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkPlan>{ parentWorkPlan });
        mocks.when(mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(new Set<Id>()))
            .thenReturn(new List<WorkPlan>());
        mocks.when(mockWorkPlanTemplatesSelector.SObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ childWorkPlan.Type__c })
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkOrderSettingsService.isWorkPlansEligibilityByStoreBypassed(parentWorkOrder)
            )
            .thenReturn(true);
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ parentWorkPlan.Type__c }
                }
            );
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ childWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    childWorkOrder.Id => new Set<String>{ childWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ parentWorkOrder.Id },
            CHANGE_TYPE_UPDATE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkPlan.Name => TYPE_MARKETPLACE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test "Actual Number of Stores" count updated to '0' on parent Work Order
     * when a Notifier Event is received for parent Work Order where all child Work Orders
     * are deleted.
     */
    @isTest
    private static void testWhenNoChildWorkOrdersExistsThenUpdateActualNumberOfStoresToZero() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Actual_Number_Of_Stores__c => 0
                    }
                )
            );
    }

    /**
     * @description To test update on "Actual Number of Stores" field on parent Work Order
     * excludes child Works in 'Dead' Status.
     */
    @isTest
    private static void testWhenWorkOrderIdsReceivedThenActualNumberOfStoresCalculationExcludesDeadWorkOrders() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Aggregate mockAggregateStoresCount = new Aggregate();
        mockAggregateStoresCount.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrderId);
        mockAggregateStoresCount.put(AGGREGATE_UNIQUE_STORE_COUNT_ALIAS, NUMBER_OF_STORES);
        Aggregate mockAggregateForWorkOrder = new Aggregate();
        mockAggregateForWorkOrder.put(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS, parentWorkOrderId);
        mockAggregateForWorkOrder.put(
            AGGREGATE_PROVISIONING_STATUS_FIELD_ALIAS,
            PROVISIONING_STATUS_READINESS_CHECK
        );
        mockAggregateForWorkOrder.put(AGGREGATE_CHILD_WORKORDERS_COUNT_ALIAS, 2);
        List<Aggregate> mockAggregateList = new List<Aggregate>{ mockAggregateForWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateStoresCount });
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockAggregateList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Actual_Number_Of_Stores__c => NUMBER_OF_STORES
                    }
                )
            );
    }

    /**
     * @description To test "Provisioning Status" is updated to 'Not Started' on parent Work Order
     * when a Notifier Event is received for parent Work Order where all child Work Orders
     * are deleted.
     */
    @isTest
    private static void testWhenNoChildWorkOrdersExistsThenUpdateProvisioningStatusToNotStarted() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{}))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(
                mockWorkOrdersSelector.getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_NOT_STARTED
                    }
                )
            );
    }

    /**
     * @description To test child Work Order "Status" updated to 'Dead' when parent Work Order
     * is updated to 'Dead'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrderStatusChangedToDeadThenUpdateChildWorkStepsStatusToDead() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setParent('Account', parentAccountFakeInstance)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, workStepId)
                        .setField(WorkStep.Status__c, 'Not Started')
                }
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.updateChildWorkStepsStatusToDead(new Set<Id>{ parentWorkOrder.Id });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Id => workStepId,
                            WorkStep.Status__c => 'Dead'
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Work Plans when POS child Work Orders created.
     */
    @isTest
    static void testWhenPOSChildWorkOrderCreatedThenWorkPlansAutoCreated() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake accountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            accountFakeInstance
        );
        Fake workOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_POS
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Account', accountFakeInstance);
        WorkOrder newChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkPlanTemplatesService mockWorkPlanTemplatesService = (IWorkPlanTemplatesService) mocks.mock(
            IWorkPlanTemplatesService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ newChildWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ newChildWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(
                    new Set<Id>{ newChildWorkOrder.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{
                    newChildWorkOrder,
                    (WorkOrder) ServiceMockDataBuilder.convertToSObject(workOrderFakeInstance)
                }
            );
        mocks.when(
                mockWorkOrderSettingsService.isReadinessCheckEligibilityByParentBypassed(
                    newChildWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkPlanTemplatesService.class, mockWorkPlanTemplatesService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrdersService.initiateWorkPlansCreation(
            new Set<Id>{ newChildWorkOrder.Id },
            CHANGE_TYPE_CREATE
        );
        ((IWorkPlanTemplatesService) mocks.verify(mockWorkPlanTemplatesService, 1))
            .createWorkPlansOnWorkOrdersByMatchingCriteria(
                new List<WorkOrder>{ newChildWorkOrder }
            );
    }

    /**
     * @description To test update on "Associated Account Ids" field when 'setAssociatedAccounts'
     * is called with Work Order and Account Ids.
     */
    @isTest
    static void testWhenSetAssociatedAccountsCalledThenAssociatedAccountIdsFieldUpdated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<WorkOrder> expectedWorkOrdersList = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, workOrderId)
                .setField(WorkOrder.Associated_Account_Ids__c, accountId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersService.setAssociatedAccounts(new Map<Id, String>{ workOrderId => accountId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(expectedWorkOrdersList[0]);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test auto creation of child Work Orders when
     * "Associated Account Ids" present on parent POS Work Order.
     */
    @isTest
    static void testWhenParentPOSWorkOrderWithAssociatedAccountIdsFieldPopulatedThenChildPOSWorkOrderAutoCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Set<Id> workOrderIds = new Set<Id>{ workORderId };
        Map<Id, Set<Id>> accountIdToWOId = new Map<Id, Set<Id>>{ accountId => workOrderIds };

        WorkOrder parentPOSWO = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ID, workOrderId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Associated_Account_Ids__c, accountId)
            .setField(WorkOrder.Type__c, TYPE_POS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersCreationService mockWorkOrdersCreationService = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ parentPOSWO });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ workOrderId },
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            mockWorkOrdersCreationService
        );
        WorkOrdersService.initiateChildWorkOrderAutoCreation(new Set<Id>{ workOrderId });
        ((IWorkOrdersCreationService) mocks.verify(mockWorkOrdersCreationService, 1))
            .createChildWorkOrdersOnStoreAccounts(accountIdToWOId);
    }

    /**
     * @description To test creation of child POS Work Orders when
     * 'initiateChildWorkOrderAutoCreation' called with store Account Id and parent Work Order Id.
     */
    @isTest
    static void testWhenInitiateChildWorkOrderAutoCreationCalledWithMapArgThenChildPOSWorkOrderAutoCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Set<Id> workOrderIds = new Set<Id>{ workORderId };
        Map<Id, Set<Id>> accountIdToWOId = new Map<Id, Set<Id>>{ accountId => workOrderIds };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersCreationService mockWorkOrdersCreationService = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            mockWorkOrdersCreationService
        );
        (new WorkOrdersServiceImpl()).initiateChildWorkOrderAutoCreation(accountIdToWOId);
        ((IWorkOrdersCreationService) mocks.verify(mockWorkOrdersCreationService, 1))
            .createChildWorkOrdersOnStoreAccounts(accountIdToWOId);
    }

    /**
     * @description To test creation of child POS Work Orders by chunking when number of stores
     * is greater than chunk size.
     */
    @isTest
    static void testWhenParentPOSWorkOrderWithAssociatedAccountIdsFieldPopulatedAndNumOfStoresGreaterThanChunkSizeThenChildWorkOrdersCreatedInChunk() {
        List<Id> accountIds = new List<Id>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentPOSWO = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ID, workOrderId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Associated_Account_Ids__c, String.join(accountIds, ','))
            .setField(WorkOrder.Type__c, TYPE_POS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        List<String> chunckedPayloads = new List<String>{
            JSON.serialize(
                new Set<Object>{
                    new WorkOrdersServiceImpl.AsyncPayloadWrapper(accountIds[0], workOrderId)
                }
            ),
            JSON.serialize(
                new Set<Object>{
                    new WorkOrdersServiceImpl.AsyncPayloadWrapper(accountIds[1], workOrderId)
                }
            )
        };
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ parentPOSWO });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ workOrderId },
                    new Set<Id>(accountIds)
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_ORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_PLANS_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(STORE_ASSOCIATION_PAYLOAD_SIZE)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = STORE_ASSOCIATION_PAYLOAD_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EXISTING_READINESS_ROWS_COUNT_CHECK
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EXISTING_READINESS_ROWS_COUNT_CHECK,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(STORE_ASSOCIATION_PAYLOAD_SIZE)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = STORE_ASSOCIATION_PAYLOAD_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        WorkOrdersService.initiateChildWorkOrderAutoCreation(new Set<Id>{ workOrderId });
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION => chunckedPayloads
                }
            );
    }

    /**
     * @description To test creation of child Work Orders when child Work Order creation
     * notifier event is received.
     */
    @isTest
    private static void testWhenChildWOCreationNotifierEventReceivedThenChildWOCreated() {
        List<Id> accountIds = new List<Id>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Set<Id> workOrderIds = new Set<Id>{ workORderId };
        Map<Id, Set<Id>> accountIdToWOId = new Map<Id, Set<Id>>{
            accountIds[0] => workOrderIds,
            accountIds[1] => workOrderIds
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersCreationService mockWorkOrdersCreationService = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            mockWorkOrdersCreationService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        List<String> notifierPayloads = new List<String>{
            JSON.serialize(
                new Set<Object>{
                    new WorkOrdersServiceImpl.AsyncPayloadWrapper(accountIds[0], workOrderId)
                }
            ),
            JSON.serialize(
                new Set<Object>{
                    new WorkOrdersServiceImpl.AsyncPayloadWrapper(accountIds[1], workOrderId)
                }
            )
        };
        List<Notifier__e> mockNotifiers = new List<Notifier__e>{
            new Notifier__e(
                Payload__c = notifierPayloads[0],
                Topic__c = EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION
            ),
            new Notifier__e(
                Payload__c = notifierPayloads[1],
                Topic__c = EVENT_TOPIC_INITIATE_POS_CHILD_WORK_ORDERS_CREATION
            )
        };
        WorkOrdersService.execute(mockNotifiers);
        ((IWorkOrdersCreationService) mocks.verify(mockWorkOrdersCreationService, 1))
            .createChildWorkOrdersOnStoreAccounts(accountIdToWOId);
    }

    /**
     * @description To test readiness check triggered on parent Work Orders received
     * in payload from Notifier event.
     */
    @isTest
    private static void testWhenParentWorkOrderIdsReceivedThenReadinessCheckTriggeredOnParentWorkOrders() {
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                fflib_IDGenerator.generate(Account.SObjectType),
                TYPE_DRIVE
            )
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_WITHHOLDING);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISobjectDeletionService mockSobjectDeletionService = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        IStoreReadinessCheckService mockStoreReadinessCheckService = (IStoreReadinessCheckService) mocks.mock(
            IStoreReadinessCheckService.class
        );
        IReadinessCheckFailuresSelector mockReadinessCheckFailuresSelector = (IReadinessCheckFailuresSelector) mocks.mock(
            IReadinessCheckFailuresSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockReadinessCheckFailuresSelector.sObjectType())
            .thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(
                mockReadinessCheckFailuresSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(new List<Readiness_Check_Failure__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockReadinessCheckFailuresSelector);
        Application.SERVICE.setMock(ISobjectDeletionService.class, mockSobjectDeletionService);
        Application.SERVICE.setMock(
            IStoreReadinessCheckService.class,
            mockStoreReadinessCheckService
        );
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkOrder.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS
        );
        WorkOrdersService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((IStoreReadinessCheckService) mocks.verify(mockStoreReadinessCheckService))
            .runReadinessCheckOnWorkOrders(
                (set<Id>) fflib_Match.anyObject(),
                (List<Readiness_Check_Failure__c>) fflib_match.eqList(
                    new List<Readiness_Check_Failure__c>{}
                )
            );
    }

    /**
     * @description To test LastUpdatedByMint field updated to current datetime
     * when 'setLastUpdatedByMintToNow' called with Work Order Ids.
     */
    @isTest
    private static void testWhenSetLastUpdatedByMintToNowThenUpdate() {
        Id testWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UnitOfWork.setMock(uowMock);

        Test.startTest();
        WorkOrdersService.setLastUpdatedByMintToNow(new Set<Id>{ testWorkOrderId });
        Test.stopTest();
    }

    /**
     * @description To test updateFranchiseBusinessAndStoreWorkOrder
     */
    @isTest
    private static void testWhenUpdateWOCreationNotifierEventReceivedThenUpdateWorkOrders() {
        Id workOrderOwnerId = fflib_IDGenerator.generate(User.SObjectType);

        List<Id> accountIds = new List<Id>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentPOSWO = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ID, workOrderId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Associated_Account_Ids__c, String.join(accountIds, ','))
            .setField(WorkOrder.Type__c, TYPE_POS)
            .setField(WorkOrder.OwnerId, workOrderOwnerId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);

        String workOrderIdWithOwnerId = parentPOSWO.Id + ':' + parentPOSWO.ownerId;
        List<Notifier__e> mockNotifiers = new List<Notifier__e>{
            new Notifier__e(
                Payload__c = workOrderIdWithOwnerId,
                Topic__c = UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_WORKORDER
            )
        };
        WorkOrdersService.execute(mockNotifiers);
    }
    /**
    * @description - tesh when parent COO work order type is ready for provisioning COOProvisioning Event
                     is created and called
    * @author Soumya Dash | 05-05-2024
    **/
    @isTest
    private static void testWhenParentCooWOrkOrderTypeReadyForProvisioningThenGenerateCOOProvisioningEventForWorkOrders() {
        Id parentAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        Id graveYardId = fflib_IDGenerator.generate(Account.sObjectType);

        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.type__c, WORK_ORDER_TYPE_COO)
            .setField(WorkOrder.COO_Graveyard_Business_Id__c, graveYardId)
            .setFakeId()
            .toSObject();

        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.AccountId, ParentAccountId)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.sObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ ParentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        test.startTest();
        WorkOrdersService.generateProvisioningEventForCOOWorkOrders(
            new Set<Id>{ parentWorkOrder.id }
        );
        test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                (List<Provisioning_Event__e>) fflib_match.eqList(
                    new List<Provisioning_Event__e>{
                        new Provisioning_Event__e(
                            COO_Graveyard_Id__c = graveYardId,
                            WO_Type__c = WORK_ORDER_TYPE_COO,
                            Creation_Method__c = null,
                            Accounts__c = JSON.serialize(new List<Id>{ childWorkOrder.AccountId })
                        )
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
    * @description  - test when a Parent WorkOrder is ready for provisioning , Respective Provisioning event is
                      created using Type,Business to store assignment and AccountIds in its child WorkOrder
    * @author Soumya Dash | 05-05-2024
    **/
    @isTest
    private static void testWhenParentWorkOrderStatusIsReadyForProvisioningThenEventIsCreatedSuccessfullyIncludingChildWorkOrderAccountId() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.sObjectType);

        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setFakeId()
            .toSObject();

        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.sObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        WorkOrdersService.generateProvisioningEventForWorkOrders(new Set<Id>{ parentWorkOrder.Id });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                (List<Provisioning_Event__e>) fflib_Match.eqList(
                    new List<Provisioning_Event__e>{
                        new Provisioning_Event__e(
                            WO_Type__c = WORKORDER_TYPE_STOREFRONT,
                            Creation_Method__c = WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC,
                            Accounts__c = JSON.serialize(new Set<Id>{ childWorkOrder.AccountId })
                        )
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description It is used to test when parent Storefront Bundled Work Orders Provisioning Status is
     * Ready for Provisioning and related Marketplace Work Orders Provisioning Status is Provisioning Complete
     * then update child Work Orders Provsioning Status to Provisioning Complete.
     */
    @isTest
    private static void testWhenParentStorefrontBundledWorkOrderProvisioningStatusReadyForProvisioningAndMarketplaceWorkOrderProvisiongCompleteThenUpdateChildWorkOrderToProvisioningComplete() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.sObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.sObjectType);
        Id parentStorefrontWorkOrderId = fflib_IDGenerator.generate(WorkOrder.sObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.sObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();

        Fake orderInstance = new Fake(Order.class)
            .setField(Order.AccountId, businessAccountId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.OpportunityId, opportunityId)
            .setFakeId();
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setParent('SBQQ__Order__r', orderInstance);
        Fake parentStorefrontWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Id, parentStorefrontWorkOrderId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setParent('Contract__r', contractInstance);
        WorkOrder parentStorefrontWorkOrder = (WorkOrder) parentStorefrontWorkOrderInstance.toSObject();
        WorkOrder parentMarketplaceWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_PROVISIONING_COMPLETE)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setParent('Contract__r', contractInstance)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.ParentWorkOrderId, parentStorefrontWorkOrderId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setParent('ParentWorkOrder', parentStorefrontWorkOrderInstance)
            .setFakeId()
            .toSObject();

        parentWorkOrders.add(parentStorefrontWorkOrder);
        parentWorkOrders.add(parentMarketplaceWorkOrder);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.sObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(parentWorkOrders);
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ parentStorefrontWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrdersService.updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
            new Set<WorkOrder>{ parentStorefrontWorkOrder }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test when parent Storefront Bundled Work Orders Provisioning Status is
     * Ready for Provisioning and related Marketplace Work Orders Provisioning Status is not Provisioning Complete
     * then do not update child Work Orders Provsioning Status.
     */
    @isTest
    private static void testWhenParentStorefrontBundledWorkOrderProvisioningStatusReadyForProvisioningAndMarketplaceWorkOrderNotProvisiongCompleteThenDoNotUpdateChildWorkOrdersProvisioningStaus() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.sObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.sObjectType);
        Id parentStorefrontWorkOrderId = fflib_IDGenerator.generate(WorkOrder.sObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.sObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();

        Fake orderInstance = new Fake(Order.class)
            .setField(Order.AccountId, businessAccountId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.OpportunityId, opportunityId)
            .setFakeId();
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setParent('SBQQ__Order__r', orderInstance);
        Fake parentStorefrontWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Id, parentStorefrontWorkOrderId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setParent('Contract__r', contractInstance);
        WorkOrder parentStorefrontWorkOrder = (WorkOrder) parentStorefrontWorkOrderInstance.toSObject();
        WorkOrder parentMarketplaceWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setParent('Contract__r', contractInstance)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.ParentWorkOrderId, parentStorefrontWorkOrderId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setParent('ParentWorkOrder', parentStorefrontWorkOrderInstance)
            .setFakeId()
            .toSObject();

        parentWorkOrders.add(parentStorefrontWorkOrder);
        parentWorkOrders.add(parentMarketplaceWorkOrder);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.sObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(parentWorkOrders);
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ parentStorefrontWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrdersService.updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
            new Set<WorkOrder>{ parentStorefrontWorkOrder }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_READY_FOR_PROVISIONING
                    }
                )
            );
    }

    /**
     * @description It is used to test weather WorkOrder Records Status is
     * updated to Dead for Churned Merchant Contract Type.
     * @JIRA #LEM-23780
     */
    @isTest
    private static void testWhenChurnedMxWorkOrderByContractIdsThenUpdateWorkOrders() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.sObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.sObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.sObjectType);
        Id parentStorefrontWorkOrderId = fflib_IDGenerator.generate(WorkOrder.sObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.sObjectType);
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>();

        Fake orderInstance = new Fake(Order.class)
            .setField(Order.AccountId, businessAccountId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.OpportunityId, opportunityId)
            .setFakeId();
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setField(Contract.Contract_Split_Category__c, CHURNED_MERCHANT)
            .setParent('SBQQ__Order__r', orderInstance);
        Fake parentStorefrontWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Id, parentStorefrontWorkOrderId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, WORKORDER_TYPE_STOREFRONT)
            .setParent('Contract__r', contractInstance);
        WorkOrder parentStorefrontWorkOrder = (WorkOrder) parentStorefrontWorkOrderInstance.toSObject();
        WorkOrder parentMarketplaceWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setFakeId()
            .toSObject();

        parentWorkOrders.add(parentStorefrontWorkOrder);
        parentWorkOrders.add(parentMarketplaceWorkOrder);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.sObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentAndChildWorkOrdersWithWorkPlansByBusinessAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(parentWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        uow = WorkOrdersService.updateChurnedMxWorkOrderToDead(
            mockUOW,
            new Set<Id>{ businessAccountId }
        );
        Test.stopTest();
        System.assertEquals(mockUOW, uow, INVALID_ASSERT_MESSAGE);
    }
}