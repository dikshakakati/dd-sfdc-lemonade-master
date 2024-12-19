@isTest(seeAlldata=false)
public class MerchantServicesTest {
    private static final String UPDATE_BUSINESS_ID_MERCHANT_SERVICE = 'UPDATE_BUSINESS_ID_MERCHANT_SERVICE';
    static final Set<String> PRODUCT_FAMILY_DRIVE_SET = new Set<String>{
        'Drive',
        'Drive Promotion',
        'Voice Ordering'
    };
    private static final String PRODUCT_NAME_DASHPASS = 'DashPass';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String AGREED_TO_YES = 'Yes';
    private static final String AGREED_TO_NO = 'No';
    public static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    public static final String PRODUCT_NAME_PICKUP = 'Pickup';
    public static final String PRODUCT_NAME_BASIC_PACKAGE = 'Basic Package';
    public static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    public static final String PRODUCT_NAME_ALCOHOL_PICKUP = 'Alcohol Pickup';
    public static final String PACKAGE_EXCLUSION = System.Label.PackageExclusion;
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();

    /**
     * @description To test calculate total number of stores
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountStoreCountUpdatedThenCalculateTotalStoreCount() {
        Merchant_Service__c[] merchantList = new List<Merchant_Service__c>();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Merchant_Service__c merchantServiceRecord = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setParent(
                'Account__r',
                new Fake(Account.class).setField(Account.ParentId, businessAccountId)
            )
            .setFakeId()
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .toSObject();
        merchantList.add(merchantServiceRecord);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Set<Id> merchantServiceRecordIds = new Set<Id>{ merchantServiceRecord.Id };
        MerchantServices.newInstance(merchantList).publishNotifierEvent();
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishEvents(
                new Map<String, String>{
                    UPDATE_BUSINESS_ID_MERCHANT_SERVICE => JSON.serialize(merchantServiceRecordIds)
                }
            );
    }

    /**
     * @description To test calculate total number of stores
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFiltersCalledThenCorrectCountReturned() {
        Merchant_Service__c[] merchantList = new List<Merchant_Service__c>();

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake productFakeMarketPlaceInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_DASHPASS
        );
        productFakeMarketPlaceInstance.setField(Product2.Family, 'Marketplace')
            .setField(Product2.CurrencyISOCode, 'USD');
        Fake productFakeDriveInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_DASHPASS
        );
        productFakeDriveInstance.setField(Product2.Family, 'Drive')
            .setField(Product2.CurrencyISOCode, 'USD');

        Product2 productMarketplace = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeMarketPlaceInstance
        );
        Product2 productDrive = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeDriveInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
            storeAccountId
        );
        Order order = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Fake orderItemMarketplaceFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productMarketplace.Id
        );
        orderItemMarketplaceFakeInstance.setParent('Product2', productFakeMarketPlaceInstance);
        Fake orderItemDriveFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productDrive.Id
        );
        orderItemDriveFakeInstance.setParent('Product2', productFakeDriveInstance);

        Merchant_Service__c merchantServiceRecordMarketplace = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemMarketplaceFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplace);
        Merchant_Service__c merchantServiceRecordDrive = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemDriveFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordDrive);

        Merchant_Service__c merchantServiceRecordMarketplaceBundle = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setParent('SBQQ__BundleRoot__r', orderItemMarketplaceFakeInstance)
            )
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplaceBundle);
        Merchant_Service__c merchantServiceRecordDriveBundle = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setParent('SBQQ__BundleRoot__r', orderItemDriveFakeInstance)
            )
            .toSObject();
        merchantList.add(merchantServiceRecordDriveBundle);

        List<Merchant_Service__c> returnedListNotDrive = MerchantServices.newInstance(merchantList)
            .filterByProductFamilyNotInSet(PRODUCT_FAMILY_DRIVE_SET)
            .setMxAgreedToProductValue(AGREED_TO_YES)
            .getRecords();
        List<Merchant_Service__c> returnedListDrive = MerchantServices.newInstance(merchantList)
            .filterByProductFamilyInSet(PRODUCT_FAMILY_DRIVE_SET)
            .setMxAgreedToProductValue(AGREED_TO_NO)
            .getRecords();
        System.assertEquals(
            2,
            returnedListNotDrive.size(),
            'Filter returned incorrect number of items'
        );
        System.assertEquals(
            2,
            returnedListDrive.size(),
            'Filter returned incorrect number of items'
        );
        System.assertEquals(
            'Yes',
            returnedListNotDrive[0].Mx_Agreed_to_Product__c,
            'Setter did not work correctly'
        );
        System.assertEquals(
            'No',
            returnedListDrive[0].Mx_Agreed_to_Product__c,
            'Setter did not work correctly'
        );
    }

    /**
     * @description To test filterDeselectedServices call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeselectedAccountsFilterCalledThenCorrectCountReturned() {
        Merchant_Service__c[] merchantList = new List<Merchant_Service__c>();

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake productFakeDashpassInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        productFakeDashpassInstance.setField(Product2.Family, 'Marketplace')
            .setField(Product2.CurrencyISOCode, 'USD');

        Fake productFakeMarketPlaceInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_MARKETPLACE
        );
        productFakeMarketPlaceInstance.setField(Product2.Family, 'Marketplace')
            .setField(Product2.CurrencyISOCode, 'USD');

        Product2 productDashpass = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeDashpassInstance
        );
        Product2 productMarketplace = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeMarketPlaceInstance
        );

        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
            storeAccountId
        );
        Order order = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);

        Fake orderItemMarketplaceFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productMarketplace.Id
        );
        orderItemMarketplaceFakeInstance.setParent('Product2', productFakeMarketPlaceInstance);

        Fake orderItemDashpassFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productDashpass.Id
        );
        orderItemDashpassFakeInstance.setParent('Product2', productFakeDashpassInstance)
            .setParent('SBQQ__BundleRoot__r', orderItemMarketplaceFakeInstance);

        Merchant_Service__c merchantServiceRecordMarketplace = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setField(Merchant_Service__c.Account__c, storeAccountId)
            .setParent('Account__r', new Fake(Account.class).setField(Account.Id, storeAccountId))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemDashpassFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplace);
        Merchant_Service__c merchantServiceRecordMarketplaceBundle = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Account__c, storeAccountId)
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent('Account__r', new Fake(Account.class).setField(Account.Id, storeAccountId))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemMarketplaceFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplaceBundle);
        Map<String, String> productwithpackage = new Map<String, String>();
        productwithpackage.put(PRODUCT_NAME_MARKETPLACE, PRODUCT_NAME_DELIVERY);

        Map<Id, Map<String, String>> accountIdDeselectedServicesMap = new Map<Id, Map<String, String>>();
        accountIdDeselectedServicesMap.put(storeAccountId, productwithpackage);

        List<Merchant_Service__c> filteredOutByAccount = MerchantServices.newInstance(merchantList)
            .filterDeselectedServices(accountIdDeselectedServicesMap, false)
            .getRecords();

        System.assertEquals(
            2,
            filteredOutByAccount.size(),
            'Filter returned incorrect number of items'
        );

        List<Merchant_Service__c> filteredInByAccount = MerchantServices.newInstance(merchantList)
            .filterDeselectedServices(accountIdDeselectedServicesMap, false)
            .getRecords();

        System.assertEquals(
            2,
            filteredInByAccount.size(),
            'Filter returned incorrect number of items'
        );
    }

    /**
     * @description To test filterDeselectedServices call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeselectedFranchiseParentFilterCalledThenCorrectCountReturned() {
        Merchant_Service__c[] merchantList = new List<Merchant_Service__c>();

        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseParentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake productFakeDashpassInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_DASHPASS
        );
        productFakeDashpassInstance.setField(Product2.Family, 'Marketplace')
            .setField(Product2.CurrencyISOCode, 'USD');

        Fake productFakeMarketPlaceInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_MARKETPLACE
        );
        productFakeMarketPlaceInstance.setField(Product2.Family, 'Marketplace')
            .setField(Product2.CurrencyISOCode, 'USD');

        Product2 productDashpass = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeDashpassInstance
        );
        Product2 productMarketplace = (Product2) ServiceMockDataBuilder.convertToSObject(
            productFakeMarketPlaceInstance
        );

        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
            storeAccountId
        );
        Order order = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);

        Fake orderItemMarketplaceFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productMarketplace.Id
        );
        orderItemMarketplaceFakeInstance.setParent('Product2', productFakeMarketPlaceInstance);

        Fake orderItemDashpassFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
            order.Id,
            productDashpass.Id
        );
        orderItemDashpassFakeInstance.setParent('Product2', productFakeDashpassInstance)
            .setParent('SBQQ__BundleRoot__r', orderItemMarketplaceFakeInstance);

        Merchant_Service__c merchantServiceRecordMarketplace = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Account__c, storeAccountId)
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccountId)
                    .setField(Account.Franchise_Parent__c, franchiseParentAccountId)
            )
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemDashpassFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplace);
        Merchant_Service__c merchantServiceRecordMarketplaceBundle = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setField(Merchant_Service__c.Account__c, storeAccountId)
            .setField(Merchant_Service__c.Bundle__c, 'Marketplace')
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, storeAccountId)
                    .setField(Account.Franchise_Parent__c, franchiseParentAccountId)
            )
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent('Order_Product__r', orderItemMarketplaceFakeInstance)
            .toSObject();
        merchantList.add(merchantServiceRecordMarketplaceBundle);
        Map<String, String> productwithpackage = new Map<String, String>();
        productwithpackage.put(PRODUCT_NAME_MARKETPLACE, PRODUCT_NAME_DASHPASS);

        Map<Id, Map<String, String>> accountIdDeselectedServicesMap = new Map<Id, Map<String, String>>();
        accountIdDeselectedServicesMap.put(franchiseParentAccountId, productwithpackage);

        List<Merchant_Service__c> filteredOutByFranchiseParentAccount = MerchantServices.newInstance(
                merchantList
            )
            .filterDeselectedServices(accountIdDeselectedServicesMap, true)
            .getRecords();

        System.assertEquals(
            2,
            filteredOutByFranchiseParentAccount.size(),
            'Filter returned incorrect number of items'
        );

        List<Merchant_Service__c> filteredInByFranchiseParentAccount = MerchantServices.newInstance(
                merchantList
            )
            .filterDeselectedServices(accountIdDeselectedServicesMap, true)
            .getRecords();

        System.assertEquals(
            2,
            filteredInByFranchiseParentAccount.size(),
            'Filter returned incorrect number of items'
        );
    }
    /**
     * @description To test inactivateExistingMxServicesForCoreProds
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNewMxRecordsInsertedForExistingStoresThenInactivateExistingServicesForSameStore() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id existingProductId = Fake.generateId(Product2.class);
        Id existingMerchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id newMerchantServiceId = Fake.generateId(Merchant_Service__c.class);

        Fake existingMerchantServiceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Id, existingMerchantServiceId)
            .setField(Merchant_Service__c.Name, PRODUCT_NAME_BASIC_PACKAGE)
            .setField(Merchant_Service__c.Product__c ,existingProductId)
            .setField(Merchant_Service__c.Account__c ,storeAccountId);

        Fake newMerchantServiceInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Id, newMerchantServiceId)
            .setField(Merchant_Service__c.Name, PRODUCT_NAME_BASIC_PACKAGE)
            .setField(Merchant_Service__c.Product__c ,existingProductId)
            .setField(Merchant_Service__c.Account__c ,storeAccountId);

        Merchant_Service__c existingMerchantService = (Merchant_Service__c) existingMerchantServiceInstance.toSObject();
        Merchant_Service__c newMerchantService = (Merchant_Service__c) newMerchantServiceInstance.toSObject();

        List<Merchant_Service__c> mxServices = new List<Merchant_Service__c>();
        mxServices.add(newMerchantService);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        mocks.startStubbing();
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(merchantSelector.selectExistingMerchantServiceToExcludeByStoreIdsAndPackage((Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject()))
            .thenReturn(new List<Merchant_Service__c> { existingMerchantService });
        mocks.stopStubbing();

		Application.SELECTOR.setMock(merchantSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        MerchantServices.newInstance(mxServices).inactivateExistingMxServicesOnCoreProducts();

        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}