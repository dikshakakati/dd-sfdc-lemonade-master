/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Test class for Merchant Orders Handler.
 */
@isTest(SeeAllData=false)
private class MerchantOrdersHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DELIVERED = 'Delivered';
    private static final String DENALI = 'Denali';
    private static final String DRAFT = 'Draft';
    private static final String EMAIL_INTEGRATION_CHUNK_SIZE = 'Email_Outbound_Integration_Chunk_Size';
    private static final String INVALID = 'Invalid';
    private static final String METADATA_VALUE = '5';
    private static final String MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG = 'MxOrderTypesToReevaluateMxOrderItems';
    private static final String ORDER_ITEM_NAME_TABLET_US = 'Tablet US';
    private static final String PHOTOSHOOT_TYPE = 'Photoshoot';
    private static final String SHIPMENT_STATUS_DESCRPTION_IN_TRANSIT = 'Shipment is in transit';
    private static final String SHIPMENT_STATUS_DESCRPTION_DELIVERED = 'Shipment is delivered';
    private static final String SHIPPED = 'Shipped';
    private static final String TABLET_TYPE = 'Tablet';
    private static final String VENDOR_SOCIAL_MOBILE = 'Social Mobile';
    /**
     * @description This method is used to test MerchantOrdersHandler TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<MX_Order__c> newMxOrders = new List<MX_Order__c>();
        MerchantOrdersHandler merchantOrdersHandlerObject = new MerchantOrdersHandler(newMxOrders);
        MerchantOrdersHandler.Constructor objConstructor = new MerchantOrdersHandler.Constructor();
        objConstructor.construct(newMxOrders);
        System.assertNotEquals(
            merchantOrdersHandlerObject,
            objConstructor.construct(newMxOrders),
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test method call on Mx Order Insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrderInsertedThenCallProductSelectionService() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        MX_Order__c newMxOrder = new MX_Order__c(Id = mxOrderId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrderItemsService merchantOrderItemsServiceMock = (IMerchantOrderItemsService) mocks.mock(
            IMerchantOrderItemsService.class
        );
        Application.SERVICE.setMock(
            IMerchantOrderItemsService.class,
            merchantOrderItemsServiceMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Mx_Order__c>{ newMxOrder });
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrderItemsService) mocks.verify(merchantOrderItemsServiceMock, 1))
            .createMxOrderItems(new List<Mx_Order__c>{ newMxOrder });
    }

    /**
     * @description To test tablet integration process initiated on Mx Order Insert.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrderInsertedThenInitiateTabletIntegrationProcess() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId, Type__c = TABLET_TYPE, Vendor__c = DENALI)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrderItemsService merchantOrderItemsServiceMock = (IMerchantOrderItemsService) mocks.mock(
            IMerchantOrderItemsService.class
        );
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        Application.SERVICE.setMock(
            IMerchantOrderItemsService.class,
            merchantOrderItemsServiceMock
        );
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);
        fflib_SObjectDomain.Test.Database.onInsert(newMxOrder);
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrderItemsService) mocks.verify(merchantOrderItemsServiceMock, 1))
            .createMxOrderItems(newMxOrder);
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .initiateTabletIntegrationOnOrderCreation(newMxOrder);
    }

    /**
     * @description To test method call on Mx Order Update.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrdersUpdatedThenOrderStatusLastModifiedDateUpdated() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId, Status__c = INVALID)
        };
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId, Status__c = DRAFT)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrder, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .updateStatusModifiedDate(newMxOrder);
    }

    /**
     * @description To test method call on Mx Order Insert.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrdersInsertedThenUpdateMerchantOrderStatusCalled() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId, Status__c = INVALID)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IMerchantOrders mxOrdersMock = (IMerchantOrders) mocks.mock(IMerchantOrders.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(mxOrdersMock);
        mocks.when(mxOrdersMock.getType()).thenReturn(Schema.MX_Order__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(mxOrdersMock);
        MerchantOrders.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onInsert(newMxOrder);
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrders) mocks.verify(mxOrdersMock, 1)).updateMerchantOrderStatus(newMxOrder);
    }

    /**
     * @description To test if the Work Step 'Status' update is initiated on Mx Order 'Status' Change.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrderStatusUpdatedThenInitiateWorkStepStatusUpdate() {
        Id workStepId = Fake.generateId(WorkStep.class);
        Id mxOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = mxOrderId, Work_Step__c = workStepId, Status__c = DRAFT)
        };
        List<MX_Order__c> newMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = mxOrderId, Work_Step__c = workStepId, Status__c = INVALID)
        };
        // Code coverage for trigger
        Product2 tabletProduct = new Product2(Name = TABLET_TYPE);
        insert tabletProduct;
        Mx_Order_Product_Bundle__c mxOrderProductBundle = new Mx_Order_Product_Bundle__c(
            Name = ORDER_ITEM_NAME_TABLET_US
        );
        insert mxOrderProductBundle;
        Mx_Order_Product_Option__c productOptionsForTablet = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = mxOrderProductBundle.Id,
            Product__c = tabletProduct.Id
        );
        insert productOptionsForTablet;
        Mx_Order__c mxOrderToBeInserted = new Mx_Order__c(
            Product_Bundle__c = mxOrderProductBundle.Id
        );
        insert mxOrderToBeInserted;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderToWorkStepStatusUpdateService serviceMock = (IMxOrderToWorkStepStatusUpdateService) mocks.mock(
            IMxOrderToWorkStepStatusUpdateService.class
        );
        Application.SERVICE.setMock(IMxOrderToWorkStepStatusUpdateService.class, serviceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrders, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMxOrderToWorkStepStatusUpdateService) mocks.verify(serviceMock, 1))
            .updateWorkStepStatus(newMxOrders);
    }

    /**
     * @description To test Mx Order field updates initiated when Vendor is changed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrdersVendorChangedThenMxOrderFieldUpdatesInitiated() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = TABLET_TYPE,
                Vendor__c = DENALI
            )
        };
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = TABLET_TYPE,
                Vendor__c = VENDOR_SOCIAL_MOBILE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IMerchantOrders mxOrdersMock = (IMerchantOrders) mocks.mock(IMerchantOrders.class);
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(mxOrdersMock);
        mocks.when(mxOrdersMock.getType()).thenReturn(Schema.MX_Order__c.SObjectType);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG,
                    Configuration_Value__c = TABLET_TYPE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.Domain.setMock(mxOrdersMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        MerchantOrders.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrder, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrders) mocks.verify(mxOrdersMock, 1))
            .resetMerchantOrdersOnVendorChange(newMxOrder);
    }

    /**
     * @description To test Mx Order field updates initiated when Vendor is changed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrdersVendorChangedForPhotoshootTypeThenMxOrderFieldUpdatesNotInitiated() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = PHOTOSHOOT_TYPE,
                Vendor__c = DENALI
            )
        };
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = PHOTOSHOOT_TYPE,
                Vendor__c = VENDOR_SOCIAL_MOBILE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IMerchantOrders mxOrdersMock = (IMerchantOrders) mocks.mock(IMerchantOrders.class);
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(mxOrdersMock);
        mocks.when(mxOrdersMock.getType()).thenReturn(Schema.MX_Order__c.SObjectType);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG,
                    Configuration_Value__c = TABLET_TYPE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.Domain.setMock(mxOrdersMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        MerchantOrders.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrder, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrders) mocks.verify(mxOrdersMock, 0))
            .resetMerchantOrdersOnVendorChange(newMxOrder);
    }

    /**
     * @description To test Mx Order Items reevaluation initiated when Vendor is changed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrdersVendorUpdatedThenReevaluateMxOrderItems() {
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> newMxOrder = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = TABLET_TYPE,
                Vendor__c = DENALI
            )
        };
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(
                Id = merchantOrderId,
                Status__c = DRAFT,
                Type__c = TABLET_TYPE,
                Vendor__c = VENDOR_SOCIAL_MOBILE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersService merchantOrdersServiceMock = (IMerchantOrdersService) mocks.mock(
            IMerchantOrdersService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_ORDER_TYPE_TO_REEVALUATE_STATIC_CONFIG,
                    Configuration_Value__c = TABLET_TYPE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SERVICE.setMock(IMerchantOrdersService.class, merchantOrdersServiceMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrder, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMerchantOrdersService) mocks.verify(merchantOrdersServiceMock, 1))
            .reevaluateMerchantOrderItemsOnVendorChange(newMxOrder);
    }
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMerchantOrderPhotoShootDateAndTimeUpdateThenUpdateWorkOrder(){
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id merchantOrderId = Fake.generateId(MX_Order__c.class);
        List<MX_Order__c> oldMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId,Type__c=PHOTOSHOOT_TYPE, Status__c = DRAFT,Work_Order__c = workOrderId,Vendor_PhotoShoot_Date__c = System.today(),Vendor_PhotoShoot_Time__c = (System.now()).timeGMT())
        };
        List<MX_Order__c> newMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = merchantOrderId,Type__c=PHOTOSHOOT_TYPE, Status__c = DRAFT,Work_Order__c = workOrderId,Vendor_PhotoShoot_Date__c = System.today()+1,Vendor_PhotoShoot_Time__c =(System.now()).timeGMT().addHours(1))
        };
        // Code coverage for trigger
        Product2 tabletProduct = new Product2(Name = TABLET_TYPE);
        insert tabletProduct;
        Mx_Order_Product_Bundle__c mxOrderProductBundle = new Mx_Order_Product_Bundle__c(
            Name = ORDER_ITEM_NAME_TABLET_US
        );
        insert mxOrderProductBundle;
        Mx_Order_Product_Option__c productOptionsForTablet = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = mxOrderProductBundle.Id,
            Product__c = tabletProduct.Id
        );
        insert productOptionsForTablet;
        Mx_Order__c mxOrderToBeInserted = new Mx_Order__c(
            Product_Bundle__c = mxOrderProductBundle.Id
        );
        insert mxOrderToBeInserted;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderToWorkOrderUpdateService serviceMock = (IMxOrderToWorkOrderUpdateService) mocks.mock(
            IMxOrderToWorkOrderUpdateService.class
        );
        Application.SERVICE.setMock(IMxOrderToWorkOrderUpdateService.class, serviceMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newMxOrders, new Map<Id, SObject>(oldMxOrders));
        fflib_SObjectDomain.triggerHandler(MerchantOrdersHandler.class);
        ((IMxOrderToWorkOrderUpdateService) mocks.verify(serviceMock, 1))
            .updateWorkOrderPhotoShootDateAndTime(newMxOrders);

    }
}