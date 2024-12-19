/**
 * @author Deloitte
 * @date 08/07/2022
 * @description Test class for AddStoresOnWorkOrderController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class AddStoresOnWorkOrderControllerTest {
    private static final String DELIMITER = ',';
    private static final String STORE_ACCOUNT_ACTIVATION_STATUS = 'Active';
    private static final String STORE_ACCOUNT_ADDRESS = '71 ST. NICHOLAS DRIVE NORTH POLE FAIRBANKS NORTH STAR AK 99701';
    private static final String STORE_ACCOUNT_EXTERNAL_ID = '12345';
    private static final String STORE_ACCOUNT_NAME = 'Test Account';

    /**
     * @description To test parent Work Order's business Account's related in-coverage and verified
     * store Accounts which doesn't have any child WorkOrder.
     */
    @isTest
    private static void testWhenFetchVerifiedStoresThenReturnVerifiedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id holdingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String addStoresContainerJSON;
        AddStoresContainer addStoresContainerToPass = new AddStoresContainer(
            new List<Id>{ holdingAccountId },
            null
        );
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>{
            new AccountWrapper(
                storeAccountId,
                STORE_ACCOUNT_NAME,
                STORE_ACCOUNT_ACTIVATION_STATUS,
                STORE_ACCOUNT_ADDRESS,
                STORE_ACCOUNT_EXTERNAL_ID
            )
        };
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = holdingAccountId,
            Contract__c = contractId
        );
        addStoresContainerToPass.parentWorkOrder = workOrder;
        AddStoresContainer addStoresContainerReturned = new AddStoresContainer(
            new List<Id>{ businessAccountId, corporateAccountId, holdingAccountId },
            accountWrappers
        );
        addStoresContainerJSON = JSON.serialize(addStoresContainerToPass);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService addStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        mocks.startStubbing();
        mocks.when(addStoreOnWorkOrderService.fetchVerifiedStores(addStoresContainerJSON))
            .thenReturn(addStoresContainerReturned);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, addStoreOnWorkOrderService);
        Test.startTest();
        AddStoresOnWorkOrderController.fetchVerifiedStores(addStoresContainerJSON);
        Test.stopTest();
        ((IAddStoresOnWorkOrderService) mocks.verify(addStoreOnWorkOrderService, 1))
            .fetchVerifiedStores(addStoresContainerJSON);
    }

    /**
     * @description To test child Work Orders creation for the selected stores.
     */
    @isTest
    private static void testWhenCreateChildWorkOrdersCalledThenCreateChildWorkOrders() {
        Id activeStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String accountIds = activeStoreAccountId + DELIMITER + storeAccountId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService addStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, addStoreOnWorkOrderService);
        Test.startTest();
        AddStoresOnWorkOrderController.createChildWorkOrders(parentWorkOrderId, accountIds);
        Test.stopTest();
        ((IAddStoresOnWorkOrderService) mocks.verify(addStoreOnWorkOrderService, 1))
            .createChildWorkOrders(parentWorkOrderId, accountIds);
    }

    /**
     * @description To test validate stores.
     */
    @isTest
    private static void testWhenValidateStoresCalledThenValidateStores() {
        Id activeStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String accountIds = activeStoreAccountId + DELIMITER + storeAccountId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService validateStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );

        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, contractId)
                .setField(Contract.Associated_Account_Ids__c, storeAccountId+','+activeStoreAccountId)
                .toSObject()
        };

        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, storeAccountId)
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, activeStoreAccountId)
                .toSObject()
        };

        List<Merchant_Service__c> services = new List<Merchant_Service__c>{
            (Merchant_Service__c) new Fake(Merchant_Service__c.class)
                .setField(Merchant_Service__c.Account__c, storeAccountId)
                .toSObject(),
            (Merchant_Service__c) new Fake(Merchant_Service__c.class)
                .setField(Merchant_Service__c.Account__c, activeStoreAccountId)
                .toSObject()
        };

        List<Order> orders = new List<Order>{
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, storeAccountId)
                .setField(Order.RecordTypeId, Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                                            .get('Activation_Order')
                                            .getRecordTypeId())
                .toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, activeStoreAccountId)
                .setField(Order.RecordTypeId, Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                                            .get('Activation_Order')
                                            .getRecordTypeId())
                .toSObject()
        };

        List<Account> accounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, activeStoreAccountId)
                .setField(Account.Name, 'Test Account1')
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Id, storeAccountId)
                .setField(Account.Name, 'Test Account2')
                .toSObject()
        };

        List<WorkOrder> workOrders = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, parentWorkOrderId)
                .setField(WorkOrder.Contract__c, contractId)
                .toSObject()
        };

        IContractsSelector contractsSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IAgreementsSelector agreementsSelector = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );

        IMerchantSelector servicesSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(
            IOrdersSelector.class
        );

        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(ContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(ContractsSelector.selectById(new Set<Id>{contractId})).thenReturn(contracts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{parentWorkOrderId})).thenReturn(workOrders);
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{storeAccountId,activeStoreAccountId})).thenReturn(accounts);
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelector.selectAgreementsByAccounts(new Set<Id>{storeAccountId,activeStoreAccountId})).thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(servicesSelector.queryMerchantRecordsWithAccountIds(new Set<Id>{storeAccountId,activeStoreAccountId})).thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(ordersSelector.selectOrdersByAccountIds(new Set<Id>{storeAccountId,activeStoreAccountId})).thenReturn(orders);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(servicesSelector);
        Application.SELECTOR.setMock(ordersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, validateStoreOnWorkOrderService);
        Test.startTest();
            Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(parentWorkOrderId, accountIds);
        Test.stopTest();
        system.assertEquals(returnMap.get('validation'), new List<String>{'Success'},'Validation should be Success');
    }

    /**
     * @description To test stores are returned by matching Account's Name or Address
     * or Xref's External Id on server search.
     */
    @isTest
    private static void testWhenFindVerifiedStoresBySearchKeyCalledThenReturnMatchedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id holdingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String addStoresContainerJSON;
        AddStoresContainer addStoresContainerToPass = new AddStoresContainer(
            new List<Id>{ holdingAccountId },
            null
        );
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = holdingAccountId,
            Contract__c = contractId
        );
        addStoresContainerToPass.parentWorkOrder = workOrder;
        addStoresContainerToPass.searchKey = '123'; // sub string of Xref's External Id
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>{
            new AccountWrapper(
                storeAccountId,
                STORE_ACCOUNT_NAME,
                STORE_ACCOUNT_ACTIVATION_STATUS,
                STORE_ACCOUNT_ADDRESS,
                STORE_ACCOUNT_EXTERNAL_ID
            )
        };
        AddStoresContainer addStoresContainerReturned = new AddStoresContainer(
            new List<Id>{ holdingAccountId, businessAccountId },
            accountWrappers
        );
        addStoresContainerJSON = JSON.serialize(addStoresContainerToPass);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService addStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        mocks.startStubbing();
        mocks.when(addStoreOnWorkOrderService.findVerifiedStoresBySearchKey(addStoresContainerJSON))
            .thenReturn(addStoresContainerReturned);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, addStoreOnWorkOrderService);
        Test.startTest();
        AddStoresOnWorkOrderController.findVerifiedStoresBySearchKey(addStoresContainerJSON);
        Test.stopTest();
        ((IAddStoresOnWorkOrderService) mocks.verify(addStoreOnWorkOrderService, 1))
            .findVerifiedStoresBySearchKey(addStoresContainerJSON);
    }

    /**
     * @description To test parent Work Order's business Account's related
     * store Accounts
     */
    @isTest
    private static void testWhenFetchStoresAddedThenReturnStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id holdingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String addStoresContainerJSON;
        AddStoresContainer addStoresContainerToPass = new AddStoresContainer(
            new List<Id>{ holdingAccountId },
            null
        );
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>{
            new AccountWrapper(
                storeAccountId,
                STORE_ACCOUNT_NAME,
                STORE_ACCOUNT_ACTIVATION_STATUS,
                STORE_ACCOUNT_ADDRESS,
                STORE_ACCOUNT_EXTERNAL_ID
            )
        };
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = holdingAccountId,
            Contract__c = contractId
        );
        addStoresContainerToPass.parentWorkOrder = workOrder;
        AddStoresContainer addStoresContainerReturned = new AddStoresContainer(
            new List<Id>{ businessAccountId, corporateAccountId, holdingAccountId },
            accountWrappers
        );
        addStoresContainerJSON = JSON.serialize(addStoresContainerToPass);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService addStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        mocks.startStubbing();
        mocks.when(addStoreOnWorkOrderService.fetchStoresAdded(addStoresContainerJSON))
            .thenReturn(addStoresContainerReturned);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, addStoreOnWorkOrderService);
        Test.startTest();
        AddStoresOnWorkOrderController.fetchStoresAdded(addStoresContainerJSON);
        Test.stopTest();
        ((IAddStoresOnWorkOrderService) mocks.verify(addStoreOnWorkOrderService, 1))
            .fetchStoresAdded(addStoresContainerJSON);
    }

    /**
     * @description To test stores are returned by matching Account's Name or Address
     * or Xref's External Id on server search.
     */
    @isTest
    private static void testWhenFindStoresAddedBySearchKeyCalledThenReturnMatchedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id holdingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String addStoresContainerJSON;
        AddStoresContainer addStoresContainerToPass = new AddStoresContainer(
            new List<Id>{ holdingAccountId },
            null
        );
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = holdingAccountId,
            Contract__c = contractId
        );
        addStoresContainerToPass.parentWorkOrder = workOrder;
        addStoresContainerToPass.searchKey = '123'; // sub string of Xref's External Id
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>{
            new AccountWrapper(
                storeAccountId,
                STORE_ACCOUNT_NAME,
                STORE_ACCOUNT_ACTIVATION_STATUS,
                STORE_ACCOUNT_ADDRESS,
                STORE_ACCOUNT_EXTERNAL_ID
            )
        };
        AddStoresContainer addStoresContainerReturned = new AddStoresContainer(
            new List<Id>{ holdingAccountId, businessAccountId },
            accountWrappers
        );
        addStoresContainerJSON = JSON.serialize(addStoresContainerToPass);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService addStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        mocks.startStubbing();
        mocks.when(addStoreOnWorkOrderService.findStoresAddedBySearchKey(addStoresContainerJSON))
            .thenReturn(addStoresContainerReturned);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IAddStoresOnWorkOrderService.class, addStoreOnWorkOrderService);
        Test.startTest();
        AddStoresOnWorkOrderController.findStoresAddedBySearchKey(addStoresContainerJSON);
        Test.stopTest();
        ((IAddStoresOnWorkOrderService) mocks.verify(addStoreOnWorkOrderService, 1))
            .findStoresAddedBySearchKey(addStoresContainerJSON);
    }
}