/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for BulkOrderCreationBatch
 */
@isTest
private class BulkOrderCreationBatchTest {
    private static final String TYPE_TABLET = 'Tablet';
    private static final String SUB_TYPE_NET_NEW = 'Net-New';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String WORK_ORDER_PRODUCT_BUNDLE = 'US Tablet';
    private static final String DEFECTIVE_PRINTER_IMEI = 'ABC00000';
    /**
     * @description It is to test that parent and child work orders are not created when
     * the batch is executed from Trigger handler
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPlatformEventReceivedThenDoNotCreateBulkParentAndChilOrders() {
        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Product_Bundle__c, WORK_ORDER_PRODUCT_BUNDLE)
            .setField(Staging_Bulk_Upload_Request__c.Defective_Printer_IMEI__c, DEFECTIVE_PRINTER_IMEI)
            .setField(Staging_Bulk_Upload_Request__c.Order_Protocol__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStagingBulkUploadRequestSelector bulkRequestSelectorMock = (IStagingBulkUploadRequestSelector) mocks.mock(IStagingBulkUploadRequestSelector.class);
        IBulkOrdersCreationService serviceMock = (IBulkOrdersCreationService) mocks.mock(
            IBulkOrdersCreationService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(bulkRequestSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(bulkRequestSelectorMock.selectStagingRequestsByReferenceIds(new Set<String>{stagingBulkReferenceId})).thenReturn(stagingRequestRec);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IBulkOrdersCreationService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        BulkOrderCreationBatch batch = new BulkOrderCreationBatch(new Set<String>{stagingBulkReferenceId});
        batch.start(null);
        batch.execute(null, null);
        batch.finish(null);

        ((IBulkOrdersCreationService) mocks.verify(serviceMock, 0))
            .createBulkParentAndChilOrders(new List<Staging_Bulk_Upload_Request__c>{ stagingRequestRec });
    }

    /**
     * @description It is to test the creation of parent and child work orders when
     * the batch is executed from Trigger handler
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPlatformEventReceivedThenCreateBulkParentAndChilOrders() {
        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_NET_NEW)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Product_Bundle__c, WORK_ORDER_PRODUCT_BUNDLE)
            .setField(Staging_Bulk_Upload_Request__c.Defective_Printer_IMEI__c, DEFECTIVE_PRINTER_IMEI)
            .setField(Staging_Bulk_Upload_Request__c.Order_Protocol__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStagingBulkUploadRequestSelector bulkRequestSelectorMock = (IStagingBulkUploadRequestSelector) mocks.mock(IStagingBulkUploadRequestSelector.class);
        IBulkOrdersCreationService serviceMock = (IBulkOrdersCreationService) mocks.mock(
            IBulkOrdersCreationService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(bulkRequestSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(bulkRequestSelectorMock.selectStagingRequestsByReferenceIds(new Set<String>{stagingBulkReferenceId})).thenReturn(stagingRequestRec);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IBulkOrdersCreationService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        BulkOrderCreationBatch batch = new BulkOrderCreationBatch(new Set<String>{stagingBulkReferenceId});
        batch.start(null);
        batch.execute(null, new List<Staging_Bulk_Upload_Request__c>{ stagingRequestRec });
        batch.finish(null);

        ((IBulkOrdersCreationService) mocks.verify(serviceMock, 1))
            .createBulkParentAndChilOrders(new List<Staging_Bulk_Upload_Request__c>{ stagingRequestRec });
    }
}