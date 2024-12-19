/**
 * @author Deloitte
 * @date 09/02/2022
 * @description Test class for OrderItemsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class OrderItemsServiceImplTest {
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String AGGREGATE_ACCOUNT_ID_FIELD_ALIAS = 'parentAccountId';
    private static final String AGGREGATE_CONTRACT_ID_FIELD_ALIAS = 'contractId';
    private static final String EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION = 'INITIATE_CHILD_WORK_ORDERS_CREATION';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String METADATA_INSTANCE_NAME = 'OrderItem_Ids_Payload_Chunk_Size';
    private static final String METADATA_VALUE = '3';
    private static final String METHOD_RETURNED_INCORRECT_HAS_BUNDLED_CHECK_ASSERT_MESSAGE = 'Unexpected result: Store Account Id did not return has bundled check.';
    private static final String ORDER_ITEM_IDS_CHUNK_SIZE_STATIC_CONFIG = 'OrderItem_Ids_Payload_Chunk_Size';
    private static final String PARENT_WORK_ORDER = 'ParentWorkOrder';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SUB_TYPE_SELF_DELIVERY = 'Self Delivery';
    private static final String DRIVE_SUB_TYPE_SAAS_FEE_SETUP = 'SaaS Fee Setup';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_SUB_TYPE_ADS_AND_PROMOS_ACTIVATE = 'Ads and Promo - Activate';

    /**
     * @description To test whether Storefront Product is sold together with Markteplace Product
     */
    @isTest
    private static void testWhenStorefrontAndMarketplaceSoldTogetherThenStoreAccountWithHasBundledProductsCheckReturned() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 marketplaceProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            marketplaceProductFakeInstance
        );
        Fake storefrontProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        Product2 storefrontProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            storefrontProductFakeInstance
        );
        Fake marketplacePricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            marketplaceProduct.Id
        );
        PricebookEntry marketplacePricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            marketplacePricebookEntryFakeInstance
        );
        Fake storefrontPricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            storefrontProduct.Id
        );
        PricebookEntry storefrontPricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            storefrontPricebookEntryFakeInstance
        );
        Fake marketplacePrimaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        OrderItem marketplacePrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplacePrimaryOrderItemFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(OrderItem.Primary_Order_Product__c, marketplacePrimaryOrderItem.Id)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance)
            .setParent('Primary_Order_Product__r', marketplacePrimaryOrderItemFakeInstance);
        OrderItem marketplaceOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplaceOrderItemFakeInstance
        );
        Fake storefrontPrimaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                storefrontProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, storefrontPricebookEntry.Id)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', storefrontProductFakeInstance);
        OrderItem storefrontPrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontPrimaryOrderItemFakeInstance
        );
        Fake storefrontOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                storefrontProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, storefrontPricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(OrderItem.Primary_Order_Product__c, storefrontPrimaryOrderItem.Id)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', storefrontProductFakeInstance)
            .setParent('Primary_Order_Product__r', storefrontPrimaryOrderItemFakeInstance);
        OrderItem storefrontOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontOrderItemFakeInstance
        );
        Map<Id, Boolean> storeAccountIdToHasBundledProducts = OrderItemsService.getStoresWithBundledOrderProducts(
            new List<OrderItem>{ marketplaceOrderItem, storefrontOrderItem }
        );
        System.assertEquals(
            true,
            storeAccountIdToHasBundledProducts.get(storeAccount.Id),
            METHOD_RETURNED_INCORRECT_HAS_BUNDLED_CHECK_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test association of child Work Order to passed Order Product
     * by matching associated OrderId and "Marketplace" Work Order Type of associated Product.
     */
    @isTest
    private static void testWhenMarketplaceOrderItemReceivedThenAssociateChildWorkOrder() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(Product2.Work_Order_Sub_Type__c, null);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        OrderItem orderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ orderProduct.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ orderProduct });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String orderItemIdentifier =
            parentOrder.Id +
            SEPARATOR +
            TYPE_MARKETPLACE +
            SEPARATOR +
            null;
        OrderItemsService.populateWorkOrderOnOrderItems(
            new Map<String, WorkOrder>{ orderItemIdentifier => childWorkOrder },
            new List<OrderItem>{ orderProduct }
        );
        orderProduct.Work_Order__c = childWorkOrder.Id;
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(orderProduct);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test association of child Work Order to passed Order Product by matching associated
     * OrderId and "Post Sales" Work Order Type & "Self Delivery" Sub-Type of associated Product.
     */
    @isTest
    private static void testWhenOrderItemWithPostSalesWorkOrderTypeReceivedThenAssociateChildWorkOrder() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_POST_SALES
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_POST_SALES,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_POST_SALES
            )
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Product2.Work_Order_Sub_Type__c, SUB_TYPE_SELF_DELIVERY);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        OrderItem orderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ orderProduct.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ orderProduct });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String orderItemIdentifier =
            parentOrder.Id +
            SEPARATOR +
            TYPE_POST_SALES +
            SEPARATOR +
            SUB_TYPE_SELF_DELIVERY;
        OrderItemsService.populateWorkOrderOnOrderItems(
            new Map<String, WorkOrder>{ orderItemIdentifier => childWorkOrder },
            new List<OrderItem>{ orderProduct }
        );
        orderProduct.Work_Order__c = childWorkOrder.Id;
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(orderProduct);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test association of child Work Order to the passed Order Products
     * by matching associated OrderId and "COO" Work Order Type
     * irrespective of work order type & sub-type mapping on associated product.
     */
    @isTest
    private static void testWhenOrderItemWithCOOWorkOrderTypeReceivedThenAssociateChildWorkOrder() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_COO
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_COO,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(Product2.Work_Order_Sub_Type__c, null);
        Product2 marketplaceProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            marketplaceProductFakeInstance
        );
        Fake marketplacePricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            marketplaceProduct.Id
        );
        PricebookEntry marketplacePricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            marketplacePricebookEntryFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        OrderItem marketplaceOrderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplaceOrderItemFakeInstance
        );
        Fake driveProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_DRIVE)
            .setField(Product2.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Product2.Work_Order_Sub_Type__c, DRIVE_SUB_TYPE_SAAS_FEE_SETUP);
        Product2 driveProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            driveProductFakeInstance
        );
        Fake drivePricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            driveProduct.Id
        );
        PricebookEntry drivePricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            drivePricebookEntryFakeInstance
        );
        Fake driveOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                driveProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, drivePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', driveProductFakeInstance);
        OrderItem driveOrderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            driveOrderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ marketplaceOrderProduct.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ marketplaceOrderProduct, driveOrderProduct });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String orderItemIdentifier = parentOrder.Id + SEPARATOR + TYPE_COO + SEPARATOR + null;
        OrderItemsService.populateWorkOrderOnOrderItems(
            new Map<String, WorkOrder>{ orderItemIdentifier => childWorkOrder },
            new List<OrderItem>{ marketplaceOrderProduct, driveOrderProduct }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Work_Order__c => childWorkOrder.Id }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test the association of Child Work Order to the passed Order Product
     * by matching associated OrderId and "Ads & Promos" Work Order Type with the Order Product's
     * associated Product2's "Post-Sales" Work Order Type and "Ads and Promo - Activate" Work Order Sub Type.
     * @jira #LEM-18577
     */
    @isTest
    private static void testWhenOrderItemProduct2WithAdsAndPromosActivateWorkOrderSubTypeReceivedThenAssociateChildWorkOrder() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_ADS_AND_PROMOS
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_ADS_AND_PROMOS,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent(PARENT_WORK_ORDER, parentWorkOrderInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake adsAndPromosProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_POST_SALES
            )
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Product2.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE_ADS_AND_PROMOS_ACTIVATE);
        Product2 adsAndPromosProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            adsAndPromosProductFakeInstance
        );
        Fake adsAndPromosPricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            adsAndPromosProduct.Id
        );
        PricebookEntry adsAndPromosPricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            adsAndPromosPricebookEntryFakeInstance
        );
        Fake adsAndPromosOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                adsAndPromosProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, adsAndPromosPricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', adsAndPromosProductFakeInstance);
        OrderItem adsAndPromosOrderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            adsAndPromosOrderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ adsAndPromosOrderProduct.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ adsAndPromosOrderProduct });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String orderItemIdentifier =
            parentOrder.Id +
            SEPARATOR +
            TYPE_ADS_AND_PROMOS +
            SEPARATOR +
            null;
        Test.startTest();
        OrderItemsService.populateWorkOrderOnOrderItems(
            new Map<String, WorkOrder>{ orderItemIdentifier => childWorkOrder },
            new List<OrderItem>{ adsAndPromosOrderProduct }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Work_Order__c => childWorkOrder.Id }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test no association of Child Work Order to the passed Order Product
     * by matching associated OrderId and "Ads & Promos" Work Order Type with the Order Product's
     * associated Product2's "Marketplace" Work Order Type and null Work Order Sub Type.
     * @jira #LEM-18577
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOrderItemProduct2WithMarketplaceWorkOrderTypeReceivedThenAssociateNoAdsAndPromosChildWorkOrder() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            parentBusinessAccount.Id,
            ACCOUNT_PRIMARY_VERTICAL
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_ADS_AND_PROMOS
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_ADS_AND_PROMOS,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent(PARENT_WORK_ORDER, parentWorkOrderInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(Product2.Work_Order_Sub_Type__c, null);
        Product2 marketplaceProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            marketplaceProductFakeInstance
        );
        Fake marketplacePricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            marketplaceProduct.Id
        );
        PricebookEntry marketplacePricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            marketplacePricebookEntryFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        OrderItem marketplaceOrderProduct = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplaceOrderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ marketplaceOrderProduct.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ marketplaceOrderProduct });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String orderItemIdentifier =
            parentOrder.Id +
            SEPARATOR +
            TYPE_ADS_AND_PROMOS +
            SEPARATOR +
            null;
        Test.startTest();
        OrderItemsService.populateWorkOrderOnOrderItems(
            new Map<String, WorkOrder>{ orderItemIdentifier => childWorkOrder },
            new List<OrderItem>{ marketplaceOrderProduct }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Work_Order__c => null }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test multiple notifier events published on passing OrderIds.
     */
    @isTest
    private static void testWhenOrderItemIdsReceivedThenMultipleNotifierEventPublished() {
        Id caviarOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id dashpassOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id deliveryOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id marketplaceOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id pickupOrderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        List<Id> orderItemIdsChunk1 = new List<Id>{
            caviarOrderItemId,
            dashpassOrderItemId,
            deliveryOrderItemId
        };
        List<Id> orderItemIdsChunk2 = new List<Id>{ marketplaceOrderItemId, pickupOrderItemId };
        List<String> payloads = new List<String>{
            JSON.serialize(orderItemIdsChunk1),
            JSON.serialize(orderItemIdsChunk2)
        };
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(METADATA_INSTANCE_NAME))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = METADATA_INSTANCE_NAME,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{
                        caviarOrderItemId,
                        dashpassOrderItemId,
                        deliveryOrderItemId,
                        marketplaceOrderItemId,
                        pickupOrderItemId
                    },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        Test.startTest();
        OrderItemsService.initiateChildWorkOrdersCreation(
            new Set<Id>{
                caviarOrderItemId,
                dashpassOrderItemId,
                deliveryOrderItemId,
                marketplaceOrderItemId,
                pickupOrderItemId
            },
            false
        );
        Test.stopTest();
        ((INotifierEventsPayloadGenerationService) mocks.verify(
                notifierEventsPayloadGenerationServiceMock,
                1
            ))
            .generateChunkedPayloadsBySobjectIds(
                new Set<Id>{
                    caviarOrderItemId,
                    dashpassOrderItemId,
                    deliveryOrderItemId,
                    marketplaceOrderItemId,
                    pickupOrderItemId
                },
                Integer.valueOf(METADATA_VALUE)
            );
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION => payloads
                }
            );
    }

    /**
     * @description To test child Work Orders creation initiated when Order Item Ids are received
     * via platform event payload.
     */
    @isTest
    private static void testWhenOrderItemIdsReceivedViaPayloadThenChildWorkOrdersCreationInitiated() {
        Id orderItemId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersCreationService workOrdersCreationServiceMock = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            workOrdersCreationServiceMock
        );
        String eventPayload = JSON.serialize(new Set<Id>{ orderItemId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_INITIATE_WORK_ORDERS_CREATION
        );
        OrderItemsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((IWorkOrdersCreationService) mocks.verify(workOrdersCreationServiceMock, 1))
            .createWorkOrders(new Set<Id>{ orderItemId }, false);
    }

    /**
     * @description To test initiation of Contracts association on parent Work Orders
     * when Primary Order Products are created.
     */
    @isTest
    private static void testWhenPrimaryOrderItemsCreatedThenInitiateContractsAssociationOnParentWorkOrders() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 marketplaceProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            marketplaceProductFakeInstance
        );
        Fake marketplacePricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            marketplaceProduct.Id
        );
        PricebookEntry marketplacePricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            marketplacePricebookEntryFakeInstance
        );
        Fake marketplacePrimaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        OrderItem marketplacePrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplacePrimaryOrderItemFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(OrderItem.Primary_Order_Product__c, marketplacePrimaryOrderItem.Id)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance)
            .setParent('Primary_Order_Product__r', marketplacePrimaryOrderItemFakeInstance);
        OrderItem marketplaceOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplaceOrderItemFakeInstance
        );
        List<Aggregate> mockOrderItemAggregates = new List<Aggregate>{
            new Aggregate()
                .put(AGGREGATE_ACCOUNT_ID_FIELD_ALIAS, parentBusinessAccount.Id)
                .put(AGGREGATE_CONTRACT_ID_FIELD_ALIAS, contractId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderItemsSelector mockOrderItemsSelector = (OrderItemsSelector) mocks.mock(
            OrderItemsSelector.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectByIdsGroupedByAccountContractIds(
                    new Set<Id>{ marketplaceOrderItem.Id }
                )
            )
            .thenReturn(mockOrderItemAggregates);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        OrderItemsService.invokeContractAssociationOnParentWorkOrdersByPrimaryOrders(
            new Set<Id>{ marketplaceOrderItem.Id }
        );
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .associateContractsOnParentWorkOrders(
                new Map<Id, Id>{ parentBusinessAccount.Id => contractId }
            );
    }

    /**
     * @description To test when Subscription Active rates are updated, primary order products
     * active rates are updaetd with same.
     */
    @isTest
    private static void testWhenSubscriptionsAreUpdatedThenPopulateActiveRatesOnPrimaryOrderItems() {
        String primaryOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id productId1 = Fake.generateId(Product2.class);
        Id groupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.Active_fee__c, '10')
            .setField(OrderItem.Active_Commission__c, '20')
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId1)
            .setField(OrderItem.Quote_Line_Group__c, groupId)
            .setParent(
                'Order',
                new Fake(Order.class)
                    .setField(Order.Id, orderId1)
                    .setField(Order.RecordTypeId, primaryOrderRecordTypeId)
            )
            .toSObject();

        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        SBQQ__Subscription__c subscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Delivery')
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountAssociatedWithSubscription.Id)
            .setField(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.Active_fee__c, '15')
            .setField(SBQQ__Subscription__c.Active_Commission__c, '64')
            .setField(SBQQ__Subscription__c.Subscription_Rate_Change__c, subRateChangeReqId)
            .setField(SBQQ__Subscription__c.Quote_Line_Group__c, groupId)
            .toSObject();

        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem1);

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(subscription);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderItemsSelector mockOrderItemsSelector = (OrderItemsSelector) mocks.mock(
            OrderItemsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(mockOrderItemsSelector.selectById(new Set<Id>{ orderItemId1 }))
            .thenReturn(orderItems);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        OrderItemsService.populateActiveRatesOnPrimaryOrderItems(subscriptions);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            OrderItem.Id => orderItemId1,
                            OrderItem.Active_fee__c => 15,
                            OrderItem.Active_Commission__c => 64
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test logic for Updating Group on OrderItems
     */
    @isTest
    private static void testWhenMethodCallThenUpdateGroup() {
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id qli1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id group1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id group2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        String strId = Id.valueOf(group2);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        Id qli2 = Fake.generateId(SBQQ__QuoteLine__c.class);

        List<OrderItem> orderItemList = new List<OrderItem>{
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, orderItem1)
                .setField(OrderItem.SBQQ__QuoteLine__c, qli1)
                .setParent(
                    'SBQQ__QuoteLine__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, qli1)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, group1)
                        .setParent(
                            'SBQQ__Group__r',
                            new Fake(SBQQ__QuoteLineGroup__c.class)
                                .setField(SBQQ__QuoteLineGroup__c.Id, group1)
                                .setField(SBQQ__QuoteLineGroup__c.CCP_Unique_Group_Id__c, strId)
                        )
                )
                .toSobject(),
            (OrderItem) new Fake(OrderItem.class)
                .setField(OrderItem.id, orderItem2)
                .setField(OrderItem.SBQQ__QuoteLine__c, qli2)
                .setParent(
                    'SBQQ__QuoteLine__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, qli2)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, group2)
                        .setParent(
                            'SBQQ__Group__r',
                            new Fake(SBQQ__QuoteLineGroup__c.class)
                                .setField(SBQQ__QuoteLineGroup__c.Id, group2)
                        )
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(uowMock);
        OrderItemsService.populateQuoteLineGroup(orderItemList);
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        system.assertEquals(group2, orderItemList[0].Quote_Line_Group__c, 'Group missmatch');
        system.assertEquals(group2, orderItemList[1].Quote_Line_Group__c, 'Group missmatch');
    }
}