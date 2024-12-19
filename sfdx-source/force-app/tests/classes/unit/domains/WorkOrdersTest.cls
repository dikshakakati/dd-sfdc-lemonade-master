/**
 * @author Deloitte
 * @date 04/19/2022
 * @description Test class for WorkOrders class.
 */
@isTest(SeeAllData=false)
private class WorkOrdersTest {
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String ACTIVATE_CENTRALLY_INCLUDE_VALUES = 'Yes';
    private static final String ASSERT_MESSAGE_ACCOUNT_OWNER_EMAIL_COPY = 'Unexpected result: failed to copy Account Owner Email from calculated field';
    private static final String ASSERT_MESSAGE_DECISION_MAKER_NOT_POPULATED = 'Unexpected result: failed to populate decision maker field on child Work Order';
    private static final String ASSERT_MESSAGE_DECISION_MAKER_POPULATED = 'Unexpected result: decision maker field populated on child Work Order';
    private static final String ASSERT_MESSAGE_NOT_UPDATED = 'Field is not updated with expected value.';
    private static final String ASSERT_MESSAGE_FIELD_UPDATED = 'Field is updated with value.';
    private static final String ASSERT_MESSAGE_NO_VALIDATION_TRIGGERED = 'No validation message was triggered';
    private static final String ASSERT_MESSAGE_SALES_REP_NAME = 'Unexpected result: Sales Rep Name is incorrectly populated.';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record not updated with future date';
    private static final String DEAD_STATUS_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Work Order Status other than Dead';
    private static final String EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS = 'READINESS_CHECK_ON_PARENT_WORK_ORDERS';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final String EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String ERROR_MESSAGE = 'Values do not match';
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final String METADATA_VALUE = '1';
    private static final String MX_TAGS = 'Top Mx,Market Maker';
    private static final String MX_TAG_TOP_MX = 'Top Mx';
    private static final String MX_TAG_MARKET_MAKER = 'Market Maker';
    private static final String MX_TAG_ASSOCIATION_TOP_MX = 'Mx Tag Association Top Mx';
    private static final String MX_TAG_ASSOCIATION_MARKET_MAKER = 'Mx Tag Association Market Maker';
    private static final String MX_TAG_ASSOCIATION_STATUS_ACTIVE = 'Active';
    private static final String MX_TAG_ASSOCIATION_STATUS_INACTIVE = 'Inactive';
    private static final String ORDER_PROTOCOL = 'Email';
    private static final String ORDER_PROTOCOL_FAX = 'Fax';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String CHILD_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Order_Ids_Payload_Chunk_Size';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String PROVISIONING_STATUS_PROVISIONING_FAILED = 'Provisioning Failed';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String PRODUCT_BANNERS = 'Banners';
    private static final String PRODUCT_CNG_COLLECTIONS = 'CnG Collections';
    private static final String PRODUCT_DOORDASH_DEALS = 'DoorDash Deals';
    private static final String PRODUCT_SPONSORED_PRODUCTS = 'Sponsored Products';
    private static final String READINESS_CHECK_PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Readiness_Check_Parent_WO_Ids_Chunk_Size';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String SYSTEM_UPDATE_DEAD_STATUS_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Work Order Status update by system';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_OF_MENU_ADD_CONTENT = 'Add Content';
    private static final String TYPE_OF_MENU_REMOVE_CONTENT = 'Remove Content';
    private static final String SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String SUB_TYPE_COO = 'COO';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL = 'test@WorkOrdersTest.com';
    private static final String WORK_ORDER_ACCOUNT_OWNER_EMAIL_UPDATED = 'newtest@WorkOrdersTest.com';
    private static final String WORKORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_ORDER_MARKETPLACE = 'Marketplace';
    private static final String ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE = 'Unexpected result: mismatch in error message displayed for PDOA update.';
    /**
     * @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<WorkOrder> workOrdersList = new List<WorkOrder>();
        WorkOrders.newInstance(workOrdersList);
        WorkOrders workOrdersObject = new WorkOrders(workOrdersList);
        WorkOrders.Constructor constructorObject = new WorkOrders.Constructor();
        constructorObject.construct(workOrdersList);
        System.assertNotEquals(
            WorkOrders.newInstance(workOrdersList),
            workOrdersObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test PDOA date with future date.
     */
    @isTest
    private static void testWhenWorkOrderIsPastDueThenUpdatePDOAWithFutureDate() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            workOrderId => new WorkOrder(
                Id = workOrderId,
                Proposed_Date_of_Activation__c = System.today() - 3,
                AccountId = parentAccount.Id
            )
        };
        WorkOrder mockNewWorkOrder = new WorkOrder(
            Id = workOrderId,
            Status = 'Past Due',
            Proposed_Date_of_Activation__c = System.today() + 5,
            AccountId = parentAccount.Id
        );
        WorkOrders.newInstance(new List<WorkOrder>{ mockNewWorkOrder })
            .updateStatusOnPDOAOrPDOTChange((Map<Id, SObject>) mockOldWorkOrders);
        System.assertEquals(
            true,
            mockNewWorkOrder.Proposed_Date_of_Activation__c == System.today() + 5,
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test updation of PDOA, PDOM, PDOT Original field value
     * from PDOA, PDOM, PDOT field respectively.
     */
    @isTest
    private static void testWhenWorkOrderIsInsertedThenCopyProposedDateFieldValues() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = System.today().addMonths(5),
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addMonths(2))
            .setField(WorkOrder.Proposed_Date_of_Tablet_Original__c, System.today().addMonths(2))
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrders.newInstance(new List<WorkOrder>{ newMockWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(
            System.today().addMonths(2),
            newMockWorkOrder.Proposed_Date_of_Activation_Original__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
        System.assertEquals(
            System.today().addMonths(2),
            newMockWorkOrder.Proposed_Date_of_Tablet_Original__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
    }

    /**
     * @description To test 'Past Due' Work Order's status update initiated based on Work Order History
     * when PDOA is updated to future date and Work Plans & Work Steps are not associated.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPDOAUpdatedOnPastDueWorkOrderThenUpdateStatusByWorkOrderHistory() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            workOrderId => new WorkOrder(
                Id = workOrderId,
                AccountId = parentAccount.Id,
                HasWorkPlansGenerated__c = false,
                Proposed_Date_of_Activation__c = System.today().addDays(-10),
                Status = STATUS_PAST_DUE
            )
        };
        WorkOrder mockNewWorkOrder = new WorkOrder(
            Id = workOrderId,
            AccountId = parentAccount.Id,
            HasWorkPlansGenerated__c = false,
            Proposed_Date_of_Activation__c = System.today().addDays(5),
            Status = STATUS_PAST_DUE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        WorkOrders.newInstance(new List<WorkOrder>{ mockNewWorkOrder })
            .updateStatusOnPDOAOrPDOTChange((Map<Id, SObject>) mockOldWorkOrders);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .updateWorkOrderStatusByWorkOrderHistory(
                new Map<Id, WorkOrder>{ mockNewWorkOrder.Id => mockNewWorkOrder }
            );
    }

    /**
     * @description To test 'Past Due' Work Order's status calculation is initiated when
     * PDOA is updated to future date and Work Plans & Work Steps exists.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPDOAUpdatedOnWorkOrderWithWorkStepsThenInitiateStatusCalculationByWorkSteps() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            workOrderId => new WorkOrder(
                Id = workOrderId,
                AccountId = parentAccount.Id,
                HasWorkPlansGenerated__c = true,
                Proposed_Date_of_Activation__c = System.today().addDays(-10),
                Status = STATUS_PAST_DUE
            )
        };
        WorkOrder mockNewWorkOrder = new WorkOrder(
            Id = workOrderId,
            AccountId = parentAccount.Id,
            HasWorkPlansGenerated__c = true,
            Proposed_Date_of_Activation__c = System.today().addDays(5),
            Status = STATUS_PAST_DUE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        WorkOrders.newInstance(new List<WorkOrder>{ mockNewWorkOrder })
            .updateStatusOnPDOAOrPDOTChange((Map<Id, SObject>) mockOldWorkOrders);
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 1))
            .runWorkStepStatusCalculationsOnParentRecords(new Set<Id>{ workOrderId });
    }

    /**
     * @description To test update of PDOT Original field values when values of PDOT field is updated.
     */
    @isTest
    private static void testWhenPDOTUpdatedThenUpdatePDOTOriginal() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workOrderId2 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = Date.newInstance(2024, 5, 18),
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Map<Id, WorkOrder> oldWorkOrdersMap = new Map<Id, WorkOrder>();
        List<WorkOrder> oldWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
                Opportunity__c = parentOpportunity.id,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Activation_Original__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Menu_Original__c = Date.newInstance(2022, 6, 7),
                Proposed_Date_of_Tablet__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Tablet_Original__c = Date.newInstance(2022, 6, 11),
                Status = STATUS_CONFIRMED,
                Type__c = TYPE_MARKETPLACE
            ),
            new WorkOrder(
                Id = workOrderId2,
                Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
                Opportunity__c = parentOpportunity.id,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Activation_Original__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Menu_Original__c = Date.newInstance(2022, 6, 7),
                Status = STATUS_CONFIRMED,
                Type__c = TYPE_MARKETPLACE
            )
        };
        oldWorkOrdersMap.put(workOrderId1, oldWorkOrders[0]);
        oldWorkOrdersMap.put(workOrderId2, oldWorkOrders[1]);
        List<WorkOrder> newWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
                Opportunity__c = parentOpportunity.id,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 20),
                Proposed_Date_of_Activation_Original__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Menu_Original__c = Date.newInstance(2022, 6, 7),
                Proposed_Date_of_Tablet__c = Date.newInstance(2022, 6, 20),
                Proposed_Date_of_Tablet_Original__c = Date.newInstance(2022, 6, 11),
                Status = STATUS_CONFIRMED,
                Type__c = TYPE_MARKETPLACE
            ),
            new WorkOrder(
                Id = workOrderId2,
                Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
                Opportunity__c = parentOpportunity.id,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 20),
                Proposed_Date_of_Activation_Original__c = Date.newInstance(2022, 6, 11),
                Proposed_Date_of_Menu_Original__c = Date.newInstance(2022, 6, 7),
                Proposed_Date_of_Tablet__c = Date.newInstance(2022, 6, 20),
                Status = STATUS_CONFIRMED,
                Type__c = TYPE_MARKETPLACE
            )
        };
        WorkOrders.newInstance(newWorkOrders)
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(oldWorkOrdersMap);
        System.assertEquals(
            Date.newInstance(2022, 6, 11),
            newWorkOrders[0].Proposed_Date_of_Activation_Original__c,
            ASSERT_MESSAGE_FIELD_UPDATED
        );
        System.assertEquals(
            Date.newInstance(2022, 6, 7),
            newWorkOrders[0].Proposed_Date_of_Menu_Original__c,
            ASSERT_MESSAGE_FIELD_UPDATED
        );
        System.assertEquals(
            Date.newInstance(2022, 6, 11),
            newWorkOrders[0].Proposed_Date_of_Tablet_Original__c,
            ASSERT_MESSAGE_FIELD_UPDATED
        );
        System.assertEquals(
            Date.newInstance(2022, 6, 11),
            newWorkOrders[1].Proposed_Date_of_Activation_Original__c,
            ASSERT_MESSAGE_FIELD_UPDATED
        );
        System.assertEquals(
            Date.newInstance(2022, 6, 7),
            newWorkOrders[1].Proposed_Date_of_Menu_Original__c,
            ASSERT_MESSAGE_FIELD_UPDATED
        );
        System.assertEquals(
            Date.newInstance(2022, 6, 20),
            newWorkOrders[1].Proposed_Date_of_Tablet_Original__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
    }

    /**
     * @description To test if the validation message is getting fired on PDOA update on Child Work Order.
     */
    @isTest
    private static void testWhenPDOAUpdatedThenRestrictUpdateOnChildWorkOrder() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Map<Id, WorkOrder> oldWorkOrdersMap = new Map<Id, WorkOrder>();
        List<WorkOrder> oldWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Opportunity__c = parentOpportunityId,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 11),
                Status = STATUS_PLANNING,
                Type__c = TYPE_MARKETPLACE,
                ParentWorkOrderId = parentWorkOrderId
            )
        };
        oldWorkOrdersMap.put(workOrderId1, oldWorkOrders[0]);
        List<WorkOrder> newWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Opportunity__c = parentOpportunityId,
                Proposed_Date_of_Activation__c = Date.newInstance(2024, 6, 11),
                Status = STATUS_PLANNING,
                Type__c = TYPE_MARKETPLACE,
                ParentWorkOrderId = parentWorkOrderId
            )
        };
        WorkOrders.newInstance(newWorkOrders)
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(oldWorkOrdersMap);
        System.assertEquals(
            System.Label.PDOA_Error_Message,
            newWorkOrders[0].getErrors()[0].getMessage(),
            ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE
        );
    }

    /**
     * @description To test collection of unique parent Work Order Ids when a list of Work Order records are received.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersReceivedThenCollectUniqueParentWorkOrderIds() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id newAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_INCLUDE_VALUES)
            .setFakeId()
            .toSObject();
        WorkOrder updatedChildWorkOrder = new WorkOrder(
            Id = childWorkOrder.Id,
            AccountId = newAccountId,
            ParentWorkOrderId = parentWorkOrder.Id
        );
        Map<Id, WorkOrder> mockWorkOrders = new Map<Id, WorkOrder>{
            parentWorkOrder.Id => parentWorkOrder,
            childWorkOrder.Id => childWorkOrder
        };
        List<WorkOrder> mockUpdatedWorkOrders = new List<WorkOrder>{
            parentWorkOrder,
            updatedChildWorkOrder
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        WorkOrders.newInstance(mockUpdatedWorkOrders)
            .collectChildWorkOrdersWithUpdatedParentWorkOrderId(mockWorkOrders);
        Test.stopTest();
        List<Id> parentWorkOrderIds = new List<Id>{ parentWorkOrder.Id };
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION => new List<String>{
                        JSON.serialize(parentWorkOrderIds)
                    }
                }
            );
    }

    /**
     * @description To test "Account Owner Email Calculated" (formula field)
     * copies to "Account Owner Email Id" (email field) on WorkOrder insertion.
     */
    @isTest
    private static void testWhenWorkOrderInsertedThenAccountOwnerEmailCopiedFromCalculatedField() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(
            WORK_ORDER_ACCOUNT_OWNER_EMAIL,
            mockWorkOrder.Account_Owner_Email_Id__c,
            ASSERT_MESSAGE_ACCOUNT_OWNER_EMAIL_COPY
        );
    }

    /**
     * @description To test "Account Owner Email Calculated" (formula field)
     * copies to "Account Owner Email Id" (email field) on WorkOrder's Account change.
     */
    @isTest
    private static void testWhenWorkOrderAccountChangedThenAccountOwnerEmailCopiedFromCalculatedField() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id changedAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setFakeId();
        WorkOrder oldWorkOrder = (WorkOrder) workOrderFakeInstance.toSObject();
        WorkOrder newWorkOrder = (WorkOrder) workOrderFakeInstance
            .setField(WorkOrder.AccountId, changedAccountId)
            .setField(
                WorkOrder.Account_Owner_Email_Calculated__c,
                WORK_ORDER_ACCOUNT_OWNER_EMAIL_UPDATED
            )
            .toSObject();
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ newWorkOrder })
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(
                new Map<Id, WorkOrder>{ oldWorkOrder.Id => oldWorkOrder }
            );
        Test.stopTest();
        System.assertEquals(
            WORK_ORDER_ACCOUNT_OWNER_EMAIL_UPDATED,
            newWorkOrder.Account_Owner_Email_Id__c,
            ASSERT_MESSAGE_ACCOUNT_OWNER_EMAIL_COPY
        );
    }

    /**
     * @description To test parent Work Order Ids are collected and published to the NotifierEvent
     * when child Work Order's Provisioning Status is updated to Complete or Failed.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningStatusUpdatedThenPublishNotifierEventsWithParentWorkOrderIds() {
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            businessAccount.Id,
            TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Fake> childWorkOrderFakeInstances = new List<Fake>{
            ServiceMockDataBuilder.createWorkOrderFakeInstance(storeAccount.Id, TYPE_MARKETPLACE)
                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
                .setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_READY_FOR_PROVISIONING
                ),
            ServiceMockDataBuilder.createWorkOrderFakeInstance(storeAccount.Id, TYPE_MARKETPLACE)
                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
                .setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_PROVISIONING_FAILED
                ),
            ServiceMockDataBuilder.createWorkOrderFakeInstance(storeAccount.Id, TYPE_MARKETPLACE)
                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
                .setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_PROVISIONING_FAILED
                ),
            ServiceMockDataBuilder.createWorkOrderFakeInstance(storeAccount.Id, TYPE_MARKETPLACE)
                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
                .setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_PROVISIONING_COMPLETE
                ),
            ServiceMockDataBuilder.createWorkOrderFakeInstance(storeAccount.Id, TYPE_MARKETPLACE)
                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
                .setField(
                    WorkOrder.Provisioning_Status__c,
                    PROVISIONING_STATUS_PROVISIONING_COMPLETE
                )
        };
        List<WorkOrder> newChildWorkOrders = (List<WorkOrder>) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstances
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>(newChildWorkOrders))
            .collectParentWorkOrderIds(
                new List<WorkOrder>(newChildWorkOrders),
                EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
            );
        Test.stopTest();
        List<Id> parentWorkOrderIds = new List<Id>{ parentWorkOrder.Id };
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE => new List<String>{
                        JSON.serialize(parentWorkOrderIds)
                    }
                }
            );
    }

    /**
     * @description To test "Decision Maker" field is populated on "Marketplace" child Work Order insertion.
     */
    @isTest
    private static void testWhenMarketplaceChildWorkOrderInsertedThenRelevantDecisionMakerPopulated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
            IDecisionMakerCalculationService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(decisionMakerService.getDecisionMakers(new List<WorkOrder>{ childWorkOrder }))
            .thenReturn(new Map<Id, List<Id>>{ accountId => new List<Id>{ contactId } });
        mocks.when(
                mockWorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(childWorkOrder)
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IDecisionMakerCalculationService.class, decisionMakerService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrders.newInstance(new List<WorkOrder>{ childWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 1))
            .getDecisionMakers(new List<WorkOrder>{ childWorkOrder });
        ((IWorkOrderSettingsService) mocks.verify(mockWorkOrderSettingsService, 1))
            .isDecisionMakerApplicableOnWorkOrder(childWorkOrder);
        System.assertEquals(
            contactId,
            childWorkOrder.Decision_Maker__c,
            ASSERT_MESSAGE_DECISION_MAKER_NOT_POPULATED
        );
    }

    /**
     * @description To test error message is not displayed when Work Order Status
     * updated to 'Dead' by System.
     */
    @isTest
    private static void testWhenSystemUpdateWorkOrderStatusToDeadThenErrorMessageNotDisplayed() {
        Id mockWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            mockWorkOrderId => new WorkOrder(Id = mockWorkOrderId, Status = STATUS_CONFIRMED)
        };
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = mockWorkOrderId,
            Is_Updated_By_System__c = true,
            HasWorkPlansGenerated__c = true,
            Status = STATUS_DEAD
        );
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(mockOldWorkOrders);
        System.assertEquals(
            0,
            fflib_SObjects.Errors.getAll().size(),
            SYSTEM_UPDATE_DEAD_STATUS_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test "Decision Maker" field is not populated on "Storefront" child Work Order insertion.
     */
    @isTest
    private static void testWhenStorefrontChildWorkOrderInsertedThenRelevantDecisionMakerNotPopulated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
            IDecisionMakerCalculationService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(
                mockWorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(childWorkOrder)
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IDecisionMakerCalculationService.class, decisionMakerService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrders.newInstance(new List<WorkOrder>{ childWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 0))
            .getDecisionMakers(new List<WorkOrder>{});
        ((IWorkOrderSettingsService) mocks.verify(mockWorkOrderSettingsService, 1))
            .isDecisionMakerApplicableOnWorkOrder(childWorkOrder);
        System.assertEquals(
            null,
            childWorkOrder.Decision_Maker__c,
            ASSERT_MESSAGE_DECISION_MAKER_POPULATED
        );
    }

    /**
     * @description
     * @description To test Work Orders when marked as 'Dead' triggers
     * the Child WorkStep Status to Dead
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrderStatusChangedToDeadThenUpdateChildWorkStepsStatusToDead() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_DEAD)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        WorkOrders.newInstance(mockWorkOrders).updateChildWorkStepsStatusToDead(oldMockWorkOrders);

        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .updateChildWorkStepsStatusToDead(new Set<Id>{ parentWorkOrder.Id });
    }

    /**
     * @description To test when any of the fields * Opportunity,Contract,Order Protocol,Activated
     * Centrally (AC),Menu Setup Method,Type of Menu Update,Sales Notes for Menu Team,PDOA,
     * PDOT parent work orders modified, it triggers child work order and store account modification
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrderFieldsChangedThenUpdateChildWorkOrdersAndStoreAccountFields() {
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
        Opportunity opportunity = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .setParent('Account', parentAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
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
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
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
            .setParent('Account', childAccountWithFaxOrderProtocolFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrderForFaxStore = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderForFaxStoreFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        List<Id> childWorkOrderIdsChunk1 = new List<Id>{ childWorkOrder.Id };
        List<Id> childWorkOrderIdsChunk2 = new List<Id>{ childWorkOrderForFaxStore.Id };
        Set<Id> parentWorkOrderId = new Set<Id>{ parentWorkOrder.Id };
        List<WorkOrder> parentWorkOrderRecords = new List<WorkOrder>{ parentWorkOrder };
        List<String> payloads = new List<String>{
            JSON.serialize(childWorkOrderIdsChunk1),
            JSON.serialize(childWorkOrderIdsChunk2)
        };
        List<WorkOrder> childWorkOrderList = new List<WorkOrder>{
            childWorkOrder,
            childWorkOrderForFaxStore
        };
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    CHILD_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByParentWorkOrderIds(parentWorkOrderId))
            .thenReturn(childWorkOrderList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        WorkOrders.newInstance(parentWorkOrderRecords)
            .collectParentWorkOrdersWithUpdatedInformation(parentWorkOrderRecords);
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{ EVENT_TOPIC_WORK_OBJECTS_SYNC => payloads }
            );
    }

    /**
     * @description To test the error if Marketplace Work Order already exists for Store Account when trying
     * to create new Work order other than Drive and POS.
     */
    @isTest
    private static void testWhenWorkOrderCreatedOnStoresThenValidateOpenMarketplaceWorkOrderAlreadyExists() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder oldChildWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        List<WorkOrder> oldChildWorkOrders = new List<WorkOrder>{ oldChildWorkOrder };
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelector.selectOpenMarketPlaceWorkOrdersByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(oldChildWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrders.newInstance(new List<WorkOrder>{ childWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE);
    }

    /**
     * @description To test that an error is thrown when Drive Auto-Activations Work Order
     * already exists for the Account and a new Drive Auto-activation Work Order is manually
     * created on the same Account.
     *
     */
    @isTest
    private static void testWhenDriveAutoActivationsWorkOrderCreatedManauallyThenPreventDuplicateCreation() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder existingWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();
        List<WorkOrder> existingWorkOrders = new List<WorkOrder>{ existingWorkOrder };

        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Work_Order_Source__c, WORKORDER_SOURCE_SALES)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelector.selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(existingWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        WorkOrders.newInstance(new List<WorkOrder>{ newWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE);
    }

    /**
     * @description To test that an error is not thrown when Drive Auto-Activations Work Order
     * already exists for the Account and a new Drive Auto-activation Work Order is automatically
     * created on the same Account.
     *
     */
    @isTest
    private static void testWhenDriveAutoActivationsWorkOrderCreatedAutomaticallyThenAllowDuplicateCreation() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder existingWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();
        List<WorkOrder> existingWorkOrders = new List<WorkOrder>{ existingWorkOrder };

        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelector.selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(existingWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        WorkOrders.newInstance(new List<WorkOrder>{ newWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(0, ApexPages.getMessages().size(), ERROR_MESSAGE);
    }

    /**
     * @description To test that an error is not thrown when Drive COO Work Order exists
     * for the Account and a new Drive Auto-Activation Work Order is manually created
     * on the same Account.
     *
     */
    @isTest
    private static void testWhenDriveAutoActivationsWorkOrderCreatedManauallyWithoutDuplicateNonDeadWorkOrderThenCreationSuccesful() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder existingWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_COO)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();
        List<WorkOrder> existingWorkOrders = new List<WorkOrder>{ existingWorkOrder };

        WorkOrder newWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelector.selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(existingWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        WorkOrders.newInstance(new List<WorkOrder>{ newWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(0, ApexPages.getMessages().size(), ERROR_MESSAGE);
    }

    /**
     * @description It is used to test when child work order of non-marketplace type is inserted then
     * In-progress Marketplace Work Order validation is skipped.
     */
    @isTest
    private static void testWhenNonMarketplaceChildWorkOrderInsertedThenInProgressMarketplaceValidationSkipped() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(
                mockWorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(childWorkOrder)
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkOrders.newInstance(new List<WorkOrder>{ childWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            ASSERT_MESSAGE_NO_VALIDATION_TRIGGERED
        );
    }

    /**
     * @description test populateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrderInsertedThenPopulateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id parentAccountId = fake.generateId(Account.SObjectType);
        Id franchiseAccountId = fake.generateId(Account.SObjectType);

        Fake parentAccountInstance = new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, 'Account1')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Type, 'Corporate')
            .setChildren(
                'AccountTeamMembers',
                new List<Fake>{
                    new Fake(AccountTeamMember.class)
                        .setField(AccountTeamMember.UserId, userId1)
                        .setField(AccountTeamMember.TeamMemberRole, 'Drive Specialist')
                        .setField(AccountTeamMember.AccountId, parentAccountId)
                        .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
                }
            );

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountInstance
        );

        Account franchiseAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, franchiseAccountId)
            .setField(Account.Name, 'AccountFranchise')
            .setField(Account.Type, 'Franchisee')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.ParentId, parentAccount.Id)
            .setFakeId()
            .toSObject();

        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, franchiseAccount.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ franchiseAccount.Id }))
            .thenReturn(new List<Account>{ franchiseAccount });

        mocks.when(selectorMock.selectAccountWithAccTeamMembers(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .populateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders();
    }

    /**
     * @description To test when the parent work orders inserted, it stamps Mx Tag field with
     * 'Active' Mx Tags associated with business account.
     */
    @isTest
    private static void testWhenWorkOrderInsertedThenStampMxTagsOnWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity mxOpportunity = new Opportunity(
            Id = opportunityId,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addDays(5),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL,
            Segment__c = SEGMENT_SMB
        );
        MxTag__c mxTagTopMx = (MxTag__c) new Fake(MxTag__c.class)
            .setField(MxTag__c.Name, MX_TAG_TOP_MX)
            .setFakeId()
            .toSObject();
        MxTag__c mxTagMarketMaker = (MxTag__c) new Fake(MxTag__c.class)
            .setField(MxTag__c.Name, MX_TAG_MARKET_MAKER)
            .setFakeId()
            .toSObject();
        Mx_Tag_Association__c mxTagAssociationTopMx = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Name, MX_TAG_ASSOCIATION_TOP_MX)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTagTopMx.Id)
            .setField(Mx_Tag_Association__c.Account__c, parentAccount.Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_TOP_MX)
            .setField(
                Mx_Tag_Association__c.MxTagAssociation_Status__c,
                MX_TAG_ASSOCIATION_STATUS_ACTIVE
            )
            .setFakeId()
            .toSObject();
        Mx_Tag_Association__c mxTagAssociationMarketMaker = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Name, MX_TAG_ASSOCIATION_MARKET_MAKER)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTagMarketMaker.Id)
            .setField(Mx_Tag_Association__c.Account__c, parentAccount.Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_MARKET_MAKER)
            .setField(
                Mx_Tag_Association__c.MxTagAssociation_Status__c,
                MX_TAG_ASSOCIATION_STATUS_ACTIVE
            )
            .setFakeId()
            .toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(WorkOrder.Opportunity__c, mxOpportunity.id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxTagAssociations mxTagAssociationMock = (IMxTagAssociations) mocks.mock(
            IMxTagAssociations.class
        );
        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(
                new List<Mx_Tag_Association__c>{
                    mxTagAssociationTopMx,
                    mxTagAssociationMarketMaker
                }
            );

        mocks.when(
                mxTagAssociationMock.getActiveMxTagAssociationsByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentAccount.Id => new Set<String>{
                        mxTagAssociationTopMx.MxTagName__c,
                        mxTagAssociationMarketMaker.MxTagName__c
                    }
                }
            );

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Application.DOMAIN.setMock(mxTagAssociationMock);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ parentWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        System.assertEquals(MX_TAGS, parentWorkOrder.Mx_Tags__c, ERROR_MESSAGE);
    }

    /**
     * @description To test when the parent work orders inserted with business account having
     * Mx Tag association status as 'Inactive' then Mx Tags field is not stamped.
     */
    @isTest
    private static void testWhenWorkOrderInsertedWithInactiveMxTagAssociationsThenDoNotStampMxTagsOnWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity mxOpportunity = new Opportunity(
            Id = opportunityId,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addDays(5),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL,
            Segment__c = SEGMENT_SMB
        );
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(WorkOrder.Opportunity__c, mxOpportunity.id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxTagAssociations mxTagAssociationMock = (IMxTagAssociations) mocks.mock(
            IMxTagAssociations.class
        );
        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<Mx_Tag_Association__c>());

        mocks.when(
                mxTagAssociationMock.getActiveMxTagAssociationsByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new Map<Id, Set<String>>());

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Application.DOMAIN.setMock(mxTagAssociationMock);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ parentWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        System.assertEquals(true, String.isBlank(parentWorkOrder.Mx_Tags__c), ERROR_MESSAGE);
    }

    /**
     * @description To test when the parent work orders inserted with Segment as 'Enterprise'
     * then Mx Tags field is not stamped.
     */
    @isTest
    private static void testWhenEnterpriseWorkOrdersInsertedThenDoNotStampMxTagsOnWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity mxOpportunity = new Opportunity(
            Id = opportunityId,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addDays(5),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL,
            Segment__c = SEGMENT_ENTERPRISE
        );
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(WorkOrder.Opportunity__c, mxOpportunity.id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxTagAssociations mxTagAssociationMock = (IMxTagAssociations) mocks.mock(
            IMxTagAssociations.class
        );
        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<Mx_Tag_Association__c>());

        mocks.when(
                mxTagAssociationMock.getActiveMxTagAssociationsByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new Map<Id, Set<String>>());

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Application.DOMAIN.setMock(mxTagAssociationMock);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ parentWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        System.assertEquals(true, String.isBlank(parentWorkOrder.Mx_Tags__c), ERROR_MESSAGE);
    }

    /**
     * @description To test if Ads & Promos fields update before insertion of Work Orders.
     */
    @isTest
    private static void testWhenWorkOrderInsertedThenUpdateWorkPlanCreationFieldsForAdsAndPromos() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.Type__c, TYPE_ADS_AND_PROMOS)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addMonths(2))
            .setField(WorkOrder.Proposed_Date_of_Tablet_Original__c, System.today().addMonths(2))
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .toSObject();
        Fake fakeAdsProductInstance = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_BANNERS);
        Fake fakePromosProductInstance = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_DOORDASH_DEALS);
        List<SBQQ__Subscription__c> fakeSubscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(
                    SBQQ__Subscription__c.Id,
                    fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
                )
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakeAdsProductInstance)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(
                    SBQQ__Subscription__c.Id,
                    fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
                )
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakePromosProductInstance)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(fakeSubscriptions);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        WorkOrders.newInstance(new List<WorkOrder>{ fakeWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(
            true,
            fakeWorkOrder.Is_Eligible_for_Ads_Work_Plan__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
        System.assertEquals(
            true,
            fakeWorkOrder.Is_Eligible_for_Promos_Work_Plan__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
    }

    /**
     * @description To test that Ads & Promos fields do not update for non-eligible Ads & Promos products before
     * insertion of Work Orders.
     */
    @isTest
    private static void testWhenWorkOrderInsertedForNonEligibleAdsAndPromosProductsThenDoNotUpdateAdsPromosWorkPlanCreationCriteriaFields() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_ADS_AND_PROMOS)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addMonths(2))
            .setField(WorkOrder.Proposed_Date_of_Tablet_Original__c, System.today().addMonths(2))
            .toSObject();
        Fake fakeAdsProductInstance = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_CNG_COLLECTIONS);
        Fake fakePromosProductInstance = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_SPONSORED_PRODUCTS);
        List<SBQQ__Subscription__c> fakeSubscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(
                    SBQQ__Subscription__c.Id,
                    fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
                )
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakeAdsProductInstance)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(
                    SBQQ__Subscription__c.Id,
                    fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
                )
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakePromosProductInstance)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(fakeSubscriptions);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        WorkOrders.newInstance(new List<WorkOrder>{ fakeWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        System.assertEquals(
            false,
            fakeWorkOrder.Is_Eligible_for_Ads_Work_Plan__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
        System.assertEquals(
            false,
            fakeWorkOrder.Is_Eligible_for_Promos_Work_Plan__c,
            ASSERT_MESSAGE_NOT_UPDATED
        );
    }

    /**
     * @description To test Notifier event is published for Readiness check when parent Work Order
     * 'Execute_Readiness_Check__c' is updated.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentWorkOrderExecuteReadinessCheckFlagUpdatedThenTriggerReadinessCheck() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake workOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Execute_Readiness_Check__c, false)
            .setFakeId();
        WorkOrder oldWorkOrder = (WorkOrder) workOrderFakeInstance.toSObject();
        WorkOrder newWorkOrder = (WorkOrder) workOrderFakeInstance
            .setField(WorkOrder.Execute_Readiness_Check__c, true)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    READINESS_CHECK_PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = READINESS_CHECK_PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ newWorkOrder.Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(new List<String>{ JSON.serialize(new List<Id>{ newWorkOrder.Id }) });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ newWorkOrder })
            .runReadinessCheckOnParentWorkOrders(
                new Map<Id, WorkOrder>{ oldWorkOrder.Id => oldWorkOrder }
            );
        Test.stopTest();
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_READINESS_CHECK_ON_PARENT_WORK_ORDERS => new List<String>{
                        JSON.serialize(new List<Id>{ newWorkOrder.Id })
                    }
                }
            );
    }

    /**
     * @description To test if the validation message is not getting fired on PDOA update on Child Work Order by Trickle Down.
     */
    @isTest
    private static void testWhenPDOATrickleDownThenDoNotRestrictUpdateOnChildWorkOrder() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Map<Id, WorkOrder> oldWorkOrdersMap = new Map<Id, WorkOrder>();
        List<WorkOrder> oldWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Opportunity__c = parentOpportunityId,
                Proposed_Date_of_Activation__c = Date.newInstance(2022, 6, 11),
                Status = STATUS_PLANNING,
                Type__c = TYPE_MARKETPLACE,
                ParentWorkOrderId = parentWorkOrderId,
                Is_Updated_By_System__c = true
            )
        };
        oldWorkOrdersMap.put(workOrderId1, oldWorkOrders[0]);
        List<WorkOrder> newWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId1,
                Opportunity__c = parentOpportunityId,
                Proposed_Date_of_Activation__c = Date.newInstance(2024, 6, 11),
                Status = STATUS_PLANNING,
                Type__c = TYPE_MARKETPLACE,
                ParentWorkOrderId = parentWorkOrderId,
                Is_Updated_By_System__c = true
            )
        };
        WorkOrders.newInstance(newWorkOrders)
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(oldWorkOrdersMap);
        System.assertEquals(
            0,
            newWorkOrders[0].getErrors().size(),
            ASSERT_MESSAGE_MISMATCHED_ERROR_MESSAGE
        );
    }

    /**
     * @description To test "Sales Rep Name" populated with the current user's Id.
     */
    @isTest
    private static void testWhenWorkOrderInsertedThenCurrentUserIdCopiedToSaleRepName() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        System.assertEquals(
            UserInfo.getUserId(),
            mockWorkOrder.Sales_Rep_Name__c,
            ASSERT_MESSAGE_SALES_REP_NAME
        );
    }

    /**
     * @description To test if "Sales Rep Name" is alread populated then the current user's Id
     * is not updated.
     */
    @isTest
    private static void testWhenWorkOrderInsertedWithSalesRepNameThenCurrentUserIdNotCopiedToSaleRepName() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id salesRepId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Sales_Rep_Name__c, salesRepId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        System.assertNotEquals(
            UserInfo.getUserId(),
            mockWorkOrder.Sales_Rep_Name__c,
            ASSERT_MESSAGE_SALES_REP_NAME
        );
    }

    /**
     * @description To test when 'SMB' Parent Work Order is inserted then invoke function to update
     * "Proposed Date of Implementation".
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBParentWorkOrderInsertedThenInvokeSetProposedDateofImplementationOnSMBStorefrontWorkOrders() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id salesRepId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
            .setField(WorkOrder.Account_Owner_Email_Calculated__c, WORK_ORDER_ACCOUNT_OWNER_EMAIL)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sales_Rep_Name__c, salesRepId)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        Test.startTest();
        WorkOrders.newInstance(new List<WorkOrder>{ mockWorkOrder })
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
        Test.stopTest();
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .setProposedDateofImplementationOnSMBStorefrontWorkOrders(
                new List<WorkOrder>{ mockWorkOrder }
            );
    }
}