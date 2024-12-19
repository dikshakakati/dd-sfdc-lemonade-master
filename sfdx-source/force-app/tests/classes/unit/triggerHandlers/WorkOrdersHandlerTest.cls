/**
 * @author Deloitte
 * @date 19/04/2022
 * @description Test class for WorkOrdersHandler class.
 */
@isTest
private class WorkOrdersHandlerTest {
    private static final String ACCOUNT_ACTIVATION_STATUS = 'Active';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Test McDonald Account';
    private static final String ACCOUNT_NAME_CHILD = 'Child Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_PROVISIONING_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String ORDER_PROTOCOL = 'Email';
    private static final String ORDER_PROTOCOL_FAX = 'Fax';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String PROVISIONING_STATUS_READINESS_CHECK = 'Readiness Check';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_OF_MENU_ADD_CONTENT = 'Add Content';
    private static final String TYPE_OF_MENU_REMOVE_CONTENT = 'Remove Content';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_STATUS_PLANNING = 'Planning';
    private static final String WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC = 'Automatic';

    /**
     * @description To test restriction on update of WorkOrder Status to Dead
     * when there are related Work Plans and Work Steps.
     */
    @isTest
    private static void testWhenWorkPlansAreRelatedThenRestrictUpdationOfWorkOrderStatusToDead() {
        Id mockWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            mockWorkOrderId => new WorkOrder(Id = mockWorkOrderId, Status = STATUS_CONFIRMED)
        };
        WorkOrder mockWorkOrder = new WorkOrder(Id = mockWorkOrderId, Status = STATUS_DEAD);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ mockWorkOrder },
            mockOldWorkOrders
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(mockOldWorkOrders);
    }

    /**
     * @description To test when Work Order's PDOA changes to future date
     * then update Work Order status from Past Due.
     */
    @isTest
    private static void testWhenWorkOrderIsPastDueThenUpdatePDOAWithFutureDate() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        WorkOrder workOrderUpdate = new WorkOrder(
            Id = workOrderId,
            Proposed_Date_of_Activation__c = System.today() - 3,
            AccountId = parentAccount.Id
        );
        Map<Id, WorkOrder> mockOldWorkOrders = new Map<Id, WorkOrder>{
            workOrderId => workOrderUpdate
        };
        WorkOrder mockNewWorkOrder = new WorkOrder(
            Id = workOrderId,
            Status = 'Past Due',
            Proposed_Date_of_Activation__c = System.today() + 5,
            AccountId = parentAccount.Id
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ mockNewWorkOrder },
            mockOldWorkOrders
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .updateStatusOnPDOAOrPDOTChange(mockOldWorkOrders);
    }

    /**
     * @description To test update on PDOT Original date field when PDOT date field changes on update.
     */
    @isTest
    private static void testWhenPDOTChangedThenUpdatePDOTOriginal() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = System.today().addDays(5),
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Map<Id, WorkOrder> oldWorkOrders = new Map<Id, WorkOrder>();
        WorkOrder oldWorkOrder = new WorkOrder(
            Id = workOrderId,
            Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
            Opportunity__c = parentOpportunity.id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = STATUS_CONFIRMED,
            Type__c = TYPE_DRIVE
        );
        oldWorkOrders.put(oldWorkOrder.Id, oldWorkOrder);
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = workOrderId,
            Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
            Opportunity__c = parentOpportunity.id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Proposed_Date_of_Tablet__c = System.today().addDays(2),
            Status = STATUS_CONFIRMED,
            Type__c = TYPE_DRIVE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ mockWorkOrder },
            oldWorkOrders
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .onBeforeUpdateValidateAndUpdateWorkOrderFields(oldWorkOrders);
    }

    /**
     * @description To test PDOA, PDOM and PDOT Original date fields are populated based on PDOA, PDOM and PDOT date fields
     * when a new Work Order is created on insert.
     */
    @isTest
    private static void testWhenInsertThenValidateAndUpdateProposedDateFields() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            CloseDate = System.today().addDays(5),
            Name = OPPORTUNITY_NAME,
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        WorkOrder mockWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = ACTIVATE_CENTRALLY,
            Opportunity__c = parentOpportunity.id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Proposed_Date_of_Tablet__c = System.today().addDays(2),
            Status = STATUS_CONFIRMED,
            Type__c = TYPE_DRIVE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<WorkOrder>{ mockWorkOrder });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .onBeforeInsertValidateAndUpdateWorkOrderFields();
    }

    /**
     * @description To test the collection of Parent Work Order Ids when Work Orders are Inserted.
     */
    @isTest
    private static void testWhenWorkOrdersInsertedThenCollectParentWorkOrderIds() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, ACCOUNT_NAME_CHILD)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setFakeId()
            .toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder, childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onInsert(mockWorkOrders);
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 2))
            .collectParentWorkOrderIds(mockWorkOrders, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description To test the collection of Parent Work Order Ids when Work Orders are Updated.
     */
    @isTest
    private static void testWhenWorkOrdersUpdatedThenCollectParentWorkOrderIds() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, ACCOUNT_NAME_CHILD)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setFakeId()
            .toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder newParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder updatedWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, childWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        Map<Id, WorkOrder> mockWorkOrders = new Map<Id, WorkOrder>();
        mockWorkOrders.put(newParentWorkOrder.Id, newParentWorkOrder);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ updatedWorkOrder },
            mockWorkOrders
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectChildWorkOrdersWithUpdatedParentWorkOrderId(mockWorkOrders);
    }

    /**
     * @description To test the collection of Parent Work Order Ids when existing Work Orders are Deleted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersDeletedThenCollectParentWorkOrderIds() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder, childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<Id, WorkOrder>{
                parentWorkOrder.Id => parentWorkOrder,
                childWorkOrder.Id => childWorkOrder
            }
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectParentWorkOrderIds(mockWorkOrders, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description To test the collection of Parent Work Order Ids when deleted Work Orders are Undeleted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersUndeletedThenCollectParentWorkOrderIds() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder, childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUndelete(mockWorkOrders);
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectParentWorkOrderIds(mockWorkOrders, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description To test the collection of Parent Work Order Ids
     * when Provisioning Status is updated on child Work Orders.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningStatusUpdateThenCollectParentWorkOrderIds() {
        Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                fflib_IDGenerator.generate(Account.SObjectType),
                WORK_ORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READINESS_CHECK);
        WorkOrder oldWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance
        );
        WorkOrder newWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            workOrderFakeInstance.setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ newWorkOrder },
            new Map<Id, WorkOrder>{ oldWorkOrder.Id => oldWorkOrder }
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectParentWorkOrderIds(
                new List<WorkOrder>{ newWorkOrder },
                EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
            );
    }

    /**
     * @description To test the collection of Parent Work Orders when Provisioning Status is
     *      Ready for Provisioning
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersProvisioningStatusIsReadyForProvisioningThenGenerateProvisioningEvent() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );

        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();

        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);

        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForWorkOrders(new Set<Id>{ parentWorkOrderId });
    }

    /**
     * @description To test that Storefront Bundled, POS & Tablet Work Plan indicators are enabled
     * on the Work Order when enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder
     * method is called.
     */
    @isTest
    private static void testWhenChildWorkOrdernsertedThenStoreLevelWorkPlansIndicatorsOnParentWorkOrderEnabled() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Name, ACCOUNT_NAME_CHILD)
            .setField(Account.RecordTypeID, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setFakeId()
            .toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .setField(WorkOrder.AccountId, childAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder, childWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(mockWorkOrders);
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IParentWorkOrderSyncService) mocks.verify(parentWorkOrderSyncServiceMock, 2))
            .enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(mockWorkOrders);
    }
    /**
     * @description To test the collection of Parent Work Orders when Provisioning Status is
     *      Ready for Provisioning
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersProvisioningStatusIsReadyForDriveAutomaticThenGenerateProvisioningEvent() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );

        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();

        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);

        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForDriveWorkOrders(new Set<Id>{ parentWorkOrderId });
    }
    /**
     * @description To test the collection of Parent Work Orders when Provisioning Status is
     *     Provisioning Complete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersProvisioningStatusIsProvisioningCompleteThenUpdateStoreFrontWorkOrders() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_PROVISIONING_COMPLETE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .updateChildWorkOrdersStatusToProvisioningComplete(new Set<Id>{ parentWorkOrderId });
    }

    /**
     * @description To test the collection of Storefront type Work Orders that are not bundled with
     * Marketplace and passed to 'generateProvisioningEventForWorkOrders' method in WorkOrderService
     * when Provisioning Status is Ready for Provisioning.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersWithReadyForProvisioningProvisioningStatusThenUpdateStorefrontWorkOrders() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_NO)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForCOOWorkOrders(new Set<Id>{});
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForDriveWorkOrders(new Set<Id>{});
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForWorkOrders(new Set<Id>{ parentWorkOrderId });
    }

    /**
     * @description To test the collection of parent Work Orders of Drive type and passed to
     * 'generateProvisioningEventForDriveWorkOrders' method in WorkOrderService
     * when Provisioning Status is Ready for Provisioning.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersWithReadyForProvisioningProvisioningStatusThenUpdateDriveWorkOrders() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForCOOWorkOrders(new Set<Id>{});
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForDriveWorkOrders(new Set<Id>{ parentWorkOrderId });
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForWorkOrders(new Set<Id>{});
    }

    /**
     * @description To test the collection of parent Work Orders of COO type and passed to
     * 'generateProvisioningEventForCOOWorkOrders' method in WorkOrderService when Provisioning Status
     * is Ready for Provisioning.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrdersWithReadyForProvisioningProvisioningStatusThenUpdateCOOWorkOrders() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, TYPE_COO)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, TYPE_COO)
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForCOOWorkOrders(new Set<Id>{ parentWorkOrderId });
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForDriveWorkOrders(new Set<Id>{});
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .generateProvisioningEventForWorkOrders(new Set<Id>{});
    }

    /**
     * @description To test Work Orders when marked as 'Dead' triggers
     * recalculation of "Actual Number of Stores" and Provisioning Status roll-up.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrderStatusChangedToDeadThenInitiateStoresRecalculation() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id deadWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder deadWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, deadWorkOrderId)
            .setField(WorkOrder.AccountId, storeId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Status, STATUS_DEAD)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .toSObject();
        WorkOrder oldWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, deadWorkOrderId)
            .setField(WorkOrder.AccountId, storeId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ deadWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectParentWorkOrderIds(mockWorkOrders, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
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
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_DEAD)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                WORK_ORDER_BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC
            )
            .toSObject();

        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .updateChildWorkStepsStatusToDead(mockWorkOrders);
    }

    /**
     * @description To test when the fields parent work orders modified, it triggers
     * child work order and store account modification.
     */
    @isTest
    private static void testWhenParentWorkOrderFieldsChangedThenUpdateChildWorkOrdersAndStoreAccountFields() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id oldparentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id oldcontractId = fflib_IDGenerator.generate(Contract.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Contract__c, oldcontractId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(WorkOrder.Opportunity__c, oldparentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(14))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(14))
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .collectParentWorkOrdersWithUpdatedInformation(mockWorkOrders);
    }

    /**
     * @description It is used to test when Storefront bundled Work Order is Ready for Provisioning then update
     * child Work Orders based on related Marketplace Work Order's Provsioning Status.
     */
    @isTest
    private static void testWhenParentWorkOrderIsReadyForProvisioningThenUpdateChildWorkOrdersForBundledStorefrontWorkOrder() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id oldparentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id oldcontractId = fflib_IDGenerator.generate(Contract.SObjectType);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Opportunity__c, parentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.parentWorkOrderId, null)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(10))
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_READY_FOR_PROVISIONING)
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_ADD_CONTENT)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .toSObject();
        WorkOrder oldParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Contract__c, oldcontractId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_NO)
            .setField(WorkOrder.Opportunity__c, oldparentOpportunityId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_FAX)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(14))
            .setField(WorkOrder.Proposed_Date_of_Tablet__c, System.today().addDays(14))
            .setField(
                WorkOrder.Provisioning_Status__c,
                PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            )
            .setField(WorkOrder.Sales_Notes_for_Menu_Team__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Type_of_Menu_Update__c, TYPE_OF_MENU_REMOVE_CONTENT)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_STOREFRONT)
            .toSObject();
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        List<WorkOrder> oldMockWorkOrders = new List<WorkOrder>{ oldParentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            mockWorkOrders,
            new Map<Id, WorkOrder>(oldMockWorkOrders)
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
                new Set<WorkOrder>{ parentWorkOrder }
            );
    }

    /**
     * @description To test Readiness check process is initiated when Work Orders are updated.
     */
    @isTest
    private static void testWhenWorkOrdersUpdatedThenInitiateReadinessCheck() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            Id = parentOpportunityId,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate = System.today().addDays(5),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setFakeId()
            .toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today().addDays(10))
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setFakeId()
            .toSObject();
        Map<Id, WorkOrder> mockWorkOrders = new Map<Id, WorkOrder>();
        mockWorkOrders.put(parentWorkOrder.Id, parentWorkOrder);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrders workOrdersMock = (IWorkOrders) mocks.mock(IWorkOrders.class);
        mocks.startStubbing();
        mocks.when(workOrdersMock.getType()).thenReturn(Schema.WorkOrder.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(workOrdersMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<WorkOrder>{ parentWorkOrder },
            mockWorkOrders
        );
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(WorkOrdersHandler.class);
        ((IWorkOrders) mocks.verify(workOrdersMock, 1))
            .runReadinessCheckOnParentWorkOrders(mockWorkOrders);
    }
}