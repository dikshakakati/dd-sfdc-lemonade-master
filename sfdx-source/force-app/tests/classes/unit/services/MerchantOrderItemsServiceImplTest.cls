/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Service Implementation Class for Merchant Order Items Service.
 */

@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MerchantOrderItemsServiceImplTest {
    private static final String TYPE_RETURN = 'Return';
    private static final String TABLET_PRODUCT_FAMILY = 'Tablet';
    private static final String PRINTER_PRODUCT_FAMILY = 'Printer';
    private static final String RETURN_LABEL_BUNDLE = 'Return Label';
    private static final String TYPE_REPLACEMENT = 'Replacement';
    private static final String TYPE_NET_NEW = 'Net-New';


    @isTest
    private static void testWhenMxOrderAreSentThenOrderItemsAreCreated() {
        Id tabletBundleUSId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Bundle__c.SObjectType);
        Id tabletOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id tabletOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);
        Id chargerOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);

        Mx_Order_Product_Option__c tabletProductOption = new Mx_Order_Product_Option__c(
            Id = tabletOptionId,
            Mx_Order_Product_Bundle__c = tabletBundleUSId
        );
        Mx_Order_Product_Option__c chargerProductOption = new Mx_Order_Product_Option__c(
            Id = chargerOptionId,
            Mx_Order_Product_Bundle__c = tabletBundleUSId
        );
        List<Mx_Order_Product_Option__c> tabletBundleProductOptions = new List<Mx_Order_Product_Option__c>{
            tabletProductOption,
            chargerProductOption
        };

        MX_Order__c tabletBundleMerchantOrder = new MX_Order__c(
            Id = tabletOrderId,
            Product_Bundle__c = tabletBundleUSId
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IProductOptionsSelector mockProductOptionsSelector = (IProductOptionsSelector) mocks.mock(
            IProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProductOptionsSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Option__c.SObjectType);

        mocks.when(
                mockProductOptionsSelector.selectProductOptionsByProductBundle(
                    new Set<Id>{ tabletBundleUSId }
                )
            )
            .thenReturn(tabletBundleProductOptions);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        MerchantOrderItemsService.createMxOrderItems(
            new List<MX_Order__c>{ tabletBundleMerchantOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenMxOrderAreSentThenMarketingKitOrderItemsAreCreated() {
        Id tabletBundleUSId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Bundle__c.SObjectType);
        Id tabletOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id tabletProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id chargerProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id tabletOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);
        Id chargerOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);

        Fake productTabletFakeInstance = new Fake(Product2.class)
            .setField(Product2.Id, tabletProductId)
            .setField(Product2.Name, 'Tablet SM Rhino 8')
            .setField(Product2.StockKeepingUnit, 'TB-0000001-000001')
            .setField(Product2.Family, 'Marketing Kit')
            .setField(Product2.Language__c, 'English')
            .setField(Product2.Country__c, 'US');
        Fake productChargerFakeInstance = new Fake(Product2.class)
            .setField(Product2.Id, chargerProductId)
            .setField(Product2.Name, 'Charger')
            .setField(Product2.StockKeepingUnit, 'CB-0001-001')
            .setField(Product2.Country__c, 'US');

        Fake tabletProductOptionInstance = new Fake(Mx_Order_Product_Option__c.class)
            .setField(Mx_Order_Product_Option__c.Id, tabletOptionId)
            .setField(Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c, tabletBundleUSId)
            .setParent('Product__r', productTabletFakeInstance);
        Fake chargerProductOptionInstance = new Fake(Mx_Order_Product_Option__c.class)
            .setField(Mx_Order_Product_Option__c.Id, chargerOptionId)
            .setField(Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c, tabletBundleUSId)
            .setParent('Product__r', productChargerFakeInstance);

        Mx_Order_Product_Option__c tabletProductOption = (Mx_Order_Product_Option__c) ServiceMockDataBuilder.convertToSObject(
            tabletProductOptionInstance
        );
        Mx_Order_Product_Option__c chargerProductOption = (Mx_Order_Product_Option__c) ServiceMockDataBuilder.convertToSObject(
            chargerProductOptionInstance
        );
        List<Mx_Order_Product_Option__c> tabletBundleProductOptions = new List<Mx_Order_Product_Option__c>{
            tabletProductOption,
            chargerProductOption
        };

        MX_Order__c tabletBundleMerchantOrder = new MX_Order__c(
            Id = tabletOrderId,
            Product_Bundle__c = tabletBundleUSId
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IProductOptionsSelector mockProductOptionsSelector = (IProductOptionsSelector) mocks.mock(
            IProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProductOptionsSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Option__c.SObjectType);

        mocks.when(
                mockProductOptionsSelector.selectProductOptionsByProductBundle(
                    new Set<Id>{ tabletBundleUSId }
                )
            )
            .thenReturn(tabletBundleProductOptions);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        MerchantOrderItemsService.createMxOrderItems(
            new List<MX_Order__c>{ tabletBundleMerchantOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenMxOrderAreSentThenReturnOrderItemsAreCreated() {
        Id tabletBundleUSId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Bundle__c.SObjectType);
        Id tabletOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id tabletProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id chargerProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id tabletOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);
        Id chargerOptionId = fflib_IDGenerator.generate(Mx_OrdeR_Product_Option__c.SObjectType);
        Id mxOrderItemId = fflib_IDGenerator.generate(Mx_Order_Item__c.SObjectType);

        Fake productTabletFakeInstance = new Fake(Product2.class)
            .setField(Product2.Id, tabletProductId)
            .setField(Product2.Name, 'Tablet SM Rhino 8')
            .setField(Product2.StockKeepingUnit, 'TB-0000001-000001')
            .setField(Product2.Family, TABLET_PRODUCT_FAMILY)
            .setField(Product2.Language__c, 'English')
            .setField(Product2.Country__c, 'US');
        Fake productPrinterFakeInstance = new Fake(Product2.class)
            .setField(Product2.Id, chargerProductId)
            .setField(Product2.Name, 'printer')
            .setField(Product2.Family, PRINTER_PRODUCT_FAMILY)
            .setField(Product2.StockKeepingUnit, 'CB-0001-001')
            .setField(Product2.Country__c, 'US');

        Fake tabletProductOptionInstance = new Fake(Mx_Order_Product_Option__c.class)
            .setField(Mx_Order_Product_Option__c.Id, tabletOptionId)
            .setField(Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c, tabletBundleUSId)
            .setParent('Product__r', productTabletFakeInstance);
        Fake printerProductOptionInstance = new Fake(Mx_Order_Product_Option__c.class)
            .setField(Mx_Order_Product_Option__c.Id, chargerOptionId)
            .setField(Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c, tabletBundleUSId)
            .setParent('Product__r', productPrinterFakeInstance);
        Fake returnBundleMerchantOrder = new Fake(Mx_Order__c.class)
            .setField(Mx_Order__c.Id, tabletOrderId)
            .setField(Mx_Order__c.Product_Bundle__c, tabletBundleUSId)
            .setField(Mx_Order__c.Tablet_IMEI__c, '12345')
            .setField(Mx_Order__c.Printer_IMEI__c, '2345');

        Fake newTabletOrderItem = new Fake(Mx_Order_Item__c.class)
            .setField(Mx_Order_Item__c.Id, mxOrderItemId)
            .setField(Mx_Order_Item__c.Identifier__c, '12345')
            .setParent('Product__r', productTabletFakeInstance);

        Fake newPrinterOrderItem = new Fake(Mx_Order_Item__c.class)
            .setField(Mx_Order_Item__c.Id, mxOrderItemId)
            .setField(Mx_Order_Item__c.Identifier__c, '2345')
            .setParent('Product__r', productTabletFakeInstance);

        Set<String> identifers = new Set<String> {'12345', '2345'};
        Mx_Order_Product_Option__c tabletProductOption = (Mx_Order_Product_Option__c) ServiceMockDataBuilder.convertToSObject(
            tabletProductOptionInstance
        );
        Mx_Order_Product_Option__c printerProductOption = (Mx_Order_Product_Option__c) ServiceMockDataBuilder.convertToSObject(
            printerProductOptionInstance
        );
        Mx_Order_Item__c tabletMxOrderItem = (Mx_Order_Item__c) ServiceMockDataBuilder.convertToSObject(
            newTabletOrderItem
        );
        Mx_Order_Item__c printerMxOrderItem = (Mx_Order_Item__c) ServiceMockDataBuilder.convertToSObject(
            newPrinterOrderItem
        );
        Mx_Order__c returnMxOrder = (Mx_Order__c) ServiceMockDataBuilder.convertToSObject(
            returnBundleMerchantOrder
        );
        List<Mx_Order_Product_Option__c> tabletBundleProductOptions = new List<Mx_Order_Product_Option__c>{
            tabletProductOption,
            printerProductOption
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMerchantOrderItemsSelector mockMerchantOrderItemsSelector = (IMerchantOrderItemsSelector) mocks.mock(
            IMerchantOrderItemsSelector.class
               );
        IProductOptionsSelector mockProductOptionsSelector = (IProductOptionsSelector) mocks.mock(
            IProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockProductOptionsSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Option__c.SObjectType);

        mocks.when(
                mockProductOptionsSelector.selectProductOptionsByProductBundle(
                    new Set<Id>{ tabletBundleUSId }
                )
            )
            .thenReturn(tabletBundleProductOptions);
            mocks.when(
                mockMerchantOrderItemsSelector.selectMxOrderItemWithIdentifiersAndTypes(
                identifers , new Set<String> { TYPE_REPLACEMENT, TYPE_NET_NEW }
                )
            ).thenReturn(new List<MX_Order_Item__c>{ tabletMxOrderItem , printerMxOrderItem });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Application.SELECTOR.setMock(mockMerchantOrderItemsSelector);
        MerchantOrderItemsService.createMxOrderItems(
            new List<MX_Order__c>{ returnMxOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}