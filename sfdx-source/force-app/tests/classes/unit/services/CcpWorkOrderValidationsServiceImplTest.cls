/**
 * @author Deloitte
 * @date 12/02/2024
 * @description Test class for CcpWorkOrderValidationsServiceImpl class.
 */
@isTest
private class CcpWorkOrderValidationsServiceImplTest {
    @isTest
    static void testWhenNewStoreAccountsStorefrontWOAreNotProvidedThenReturnStorefront() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', '');

        Boolean isBusinessAccount = false;
        Boolean isProcessingExistingAccounts = false;

        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );
        booleanWrapper.isProcessingExistingAccounts = false;
        booleanWrapper.isProcessingNewAndCoo = false;
        booleanWrapper.isProcessingOnlyCoo = false;
        booleanWrapper.isProcessingOnlyNew = true;

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Storefront', result, 'All workorders are not present');
    }

    @isTest
    static void testWhenNewStoreAccountsMarketplaceWOAreNotProvidedThenReturnMarketplace() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Marketplace', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenNewBusinessAccountsDriveWOAreNotProvidedThenReturnDrive() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', '');
        workOrderTypeAndSubTypesMap.put('Storefront', '');
        //existing
        workOrderTypeAndSubTypesMap.put('Drive', 'Partnership creation/update');
        Boolean isBusinessAccount = true;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Drive', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenExistingStoreAccountsStorefrontWOAreNotProvidedThenReturnStorefront() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', '');

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            true,
            false,
            false,
            false
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Post-Sales, Storefront', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenExistingStoreAccountsMarketplaceWOAreNotProvidedThenReturnMarketplace() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Storefront', '');

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Marketplace', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenExistingBusinessAccountsDriveWOAreNotProvidedThenReturnDrive() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', '');
        workOrderTypeAndSubTypesMap.put('Storefront', '');
        //existing
        //workOrderTypeAndSubTypesMap.put('Drive', 'Partnership creation/update');
        //new
        workOrderTypeAndSubTypesMap.put('Drive', 'Net-new business');

        Boolean isBusinessAccount = true;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            true,
            false,
            false,
            false
        );
        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('Drive', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenNewStoreAccountsWOAreNotProvidedThenReturnNull() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', '');
        workOrderTypeAndSubTypesMap.put('Storefront', '');

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenExistingStoreAccountsMarketplaceWOAreNotProvidedThenReturnCooOnly() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Storefront', '');

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            true,
            false
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals('COO', result, 'Al workorders are not present');
    }

    @isTest
    static void testWhenExistingStoreAccountsMarketplaceWOAreNotProvidedThenReturnCooAndNewStores() {
        // Create mock data
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(
                    SBQQ__Subscription__c.SBQQ__ProductName__c,
                    'Large Order Fulfillment (LOF)'
                )
                .toSobject()
        };
        // Populate workOrderTypeAndSubTypesMap with mock data
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Storefront', '');

        Boolean isBusinessAccount = false;
        // Create mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Create mock selector
        ICcpWorkOrderValidationsSelector mockCcpWorkOrderValidationsSelector = (ICcpWorkOrderValidationsSelector) mocks.mock(
            ICcpWorkOrderValidationsSelector.class
        );

        CcpWorkOrderValidationsServiceImpl service = new CcpWorkOrderValidationsServiceImpl();
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            true,
            false,
            false
        );

        // Call the method to be tested
        mocks.startStubbing();
        String result = service.validateWorkOrders(
            subscriptionList,
            workOrderTypeAndSubTypesMap,
            isBusinessAccount,
            booleanWrapper
        );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCcpWorkOrderValidationsSelector);

        // Assert the results
        System.assertEquals(true, result != null, 'Al workorders are not present');
    }
}