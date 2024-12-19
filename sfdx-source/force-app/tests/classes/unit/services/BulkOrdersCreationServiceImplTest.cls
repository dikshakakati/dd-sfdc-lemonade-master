/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for BulkOrdersCreationServiceImpl class.
 */
@isTest
private class BulkOrdersCreationServiceImplTest {
    private static final String VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String SUB_TYPE_NET_NEW = 'Net-New';
    private static final String SUB_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String STATUS_SUCCESS = 'Success';

    /**
     * @description To test creation of Parent and Child work orders when Type is Tablet
     * and Request Type is Net-New and no Work order is present with the incoming key.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTypeTabletAndRequestTypeNetNewWithNoWorkOrderPresentThenCreateParentChildWorkOrder() {

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake storeAccountFakeInstance1 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount1 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance1
        );

        Fake storeAccountFakeInstance2 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount2 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance2
        );

        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId1 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec1 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount1.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId1)
            .toSObject();

        Id stagingBulkRequestId2 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec2 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount2.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId2)
            .toSObject();

        List<Staging_Bulk_Upload_Request__c> stagingRequests = new List<Staging_Bulk_Upload_Request__c>{stagingRequestRec1,stagingRequestRec2};
        String keySet = stagingBulkReferenceId + SUB_TYPE_NET_NEW + businessAccount.id;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.selectWorkOrdersByBulkParentOrderKeys(new Set<String>{keySet})).thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Test.startTest();
        BulkOrdersCreationService.createBulkParentAndChilOrders(stagingRequests);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    /**
     * @description To test creation of Parent and Child work orders when Type is Photoshoot
     * and no Work order is present with the incoming key.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTypePhotoshootWithNoWorkOrderPresentThenCreateParentChildWorkOrder() {

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake storeAccountFakeInstance1 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount1 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance1
        );

        Fake storeAccountFakeInstance2 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount2 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance2
        );

        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId1 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec1 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount1.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId1)
            .toSObject();

        Id stagingBulkRequestId2 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec2 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_PHOTOSHOOT)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount2.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId2)
            .toSObject();

        List<Staging_Bulk_Upload_Request__c> stagingRequests = new List<Staging_Bulk_Upload_Request__c>{stagingRequestRec1,stagingRequestRec2};
        String keySet = stagingBulkReferenceId + SUB_TYPE_PHOTOSHOOT + businessAccount.id;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);

        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.selectWorkOrdersByBulkParentOrderKeys(new Set<String>{keySet})).thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Test.startTest();
        BulkOrdersCreationService.createBulkParentAndChilOrders(stagingRequests);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    /**
     * @description To test creation of Parent and Child work orders when Type is Tablet
     * and Work order is present with the incoming key.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTypeTabletAndRequestTypeNetNewWithWorkOrderPresentforTheKeyThenCreateParentChildWorkOrder() {

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake storeAccountFakeInstance1 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount1 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance1
        );

        Fake storeAccountFakeInstance2 = ServiceMockDataBuilder.createAccountFakeInstance(
            VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.ParentId, businessAccount.Id);
        Account storeAccount2 = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance2
        );

        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId1 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec1 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount1.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId1)
            .toSObject();

        Id stagingBulkRequestId2 = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec2 = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Request__c.Business_ID__c, businessAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount2.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId2)
            .toSObject();

        String keySet = stagingBulkReferenceId + SUB_TYPE_NET_NEW + businessAccount.id;

        Id workOrderId = Fake.generateId(WorkOrder.class);
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Bulk_Parent_Order_Key__c, keySet)
            .toSObject();

        List<Staging_Bulk_Upload_Request__c> stagingRequests = new List<Staging_Bulk_Upload_Request__c>{stagingRequestRec1,stagingRequestRec2};
        List<WorkOrder> workOrders = new List<WorkOrder>{ parentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector workOrderSelectorMock = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.selectWorkOrdersByBulkParentOrderKeys(new Set<String>{keySet})).thenReturn(workOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Test.startTest();
        BulkOrdersCreationService.createBulkParentAndChilOrders(stagingRequests);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }
}