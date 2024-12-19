/**
 * @author Deloitte
 * @date 08/07/2022
 * @description Test class for AddStoresOnWorkOrderServiceImpl class.
 */
@isTest(seeAllData=false)
private class AddStoresOnWorkOrderServiceImplTest {
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACTIVATE_CONTRALLY = 'Yes';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String ASSERT_MESSAGE_ERROR_MESSAGE_DO_NOT_MATCH = 'Unexpected result: the expected error message is not returned';
    private static final String ASSERT_MESSAGE_PAYLOAD = 'Unexpected result: payload size is not matching';
    private static final String ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT = 'Unexpected result: verified store account is not matching';
    private static final String ASSERT_MESSAGE_PLATFORM_EVENT_TOPIC = 'Unexpected result: topic name is not matching';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DELIMITER = ',';
    private static final String EVENT_TOPIC_CREATE_CHILD_WORK_ORDERS_ON_VERIFIED_STORES = 'CREATE_CHILD_WORK_ORDERS_ON_VERIFIED_STORES';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final string STORE_ACCOUNT_NAME = 'Test Account';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VALIDATION = 'validation';
    private static final String VALIDATION_FAILURE = 'Failure';
    private static final String VALIDATION_MESSAGE = 'Validation should be Failure';
    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        TYPE_MARKETPLACE,
        TYPE_STOREFRONT
    };
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'Drive';
    private static final String XREF_STATUS_ACTIVE = 'Active';

    /**
     * @description To test in-coverage verified store Accounts and associated Xrefs related to
     * parent Work Order's business Account and matching the criteria are correctly fetched.
     */
    @isTest
    private static void testWhenFetchVerifiedStoresThenReturnVerifiedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = businessAccountId,
            Contract__c = contractId
        );
        Schema.SObjectField parentField = Account.ParentId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.selectVerifiedStoreAccountsByBusinessId(
                    new Set<Id>{ businessAccountId },
                    parentWorkOrderId,
                    parentField
                )
            )
            .thenReturn(new List<Account>{ verifiedStoreAccount });
        mocks.when(
                accountsSelector.selectBusinessAccountsByParentIds(
                    Account.ParentId,
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>{ businessAccountId },
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresOnWorkOrderService.fetchVerifiedStores(addStoresContainerJSON);
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            verifiedStoreAccount.Name,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
    }

    /**
     * @description To test child Work Order process is triggered for stores
     * when selected store Ids are received from the Add Stores component controller.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedThenChildWorkOrdersCreationTriggered() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_COO
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, selectedStoreId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersCreationService workOrderCreationService = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsWithParentDetailsById(
                    new Set<Id>{ selectedStoreId }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkOrdersCreationService.class, workOrderCreationService);
        AddStoresOnWorkOrderService.createChildWorkOrders(parentWorkOrderId, selectedStoreId);
        ((IWorkOrdersCreationService) mocks.verify(workOrderCreationService, 1))
            .createChildWorkOrdersOnStoreAccounts(
                parentWorkOrder,
                new List<Account>{ storeAccount }
            );
    }

    /**
     * @description To test when selected store Account does not have active Contract
     * with Marketplace and Storefront products bundled together then an error message is thrown.
     */
    @isTest
    private static void testWhenStoreAccountWithoutBundledProductsAddedThenValidationMessageThrown() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountWithoutBundledProductsFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE);
        Account storeAccountWithoutBundledProducts = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithoutBundledProductsFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsWithParentDetailsById(
                    new Set<Id>{ storeAccountWithoutBundledProducts.Id }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithoutBundledProducts });
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountWithoutBundledProducts.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>());
        mocks.when(mockOrderItemsService.getStoresWithBundledOrderProducts(new List<OrderItem>()))
            .thenReturn(new Map<Id, Boolean>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        String storeAccountIds = storeAccountWithoutBundledProducts.Id;
        String errorMessage = AddStoresOnWorkOrderService.createChildWorkOrders(
            parentWorkOrder.Id,
            storeAccountIds
        );
        System.assertEquals(
            System.Label.StoreWithoutBundledProductsErrorMessage,
            errorMessage,
            ASSERT_MESSAGE_ERROR_MESSAGE_DO_NOT_MATCH
        );
    }

    /**
     * @description To test in-coverage verified store Accounts and associated Xrefs related to
     * parent Work Order's business Account and matching the criteria are correctly fetched when
     * lastReturnedId is not blank.
     */
    @isTest
    private static void testWhenFetchVerifiedStoresCalledWithLastReturnedIdThenReturnVerifiedStores() {
        Id parentBusinessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childBusinessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id grandChildBusinessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id verifiedChildStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id verifiedGrandChildStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, parentBusinessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        Account verifiedChildStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedChildStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, childBusinessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedChildStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        Account verifiedGrandChildStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedGrandChildStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, grandChildBusinessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(
                            Xref__c.Salesforce_Account_Name__c,
                            verifiedGrandChildStoreAccountId
                        )
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = parentBusinessAccountId,
            Contract__c = contractId
        );
        Schema.SObjectField parentField = Account.ParentId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.selectVerifiedStoreAccountsById(
                    new Set<Id>{
                        parentBusinessAccountId,
                        childBusinessAccountId,
                        grandChildBusinessAccountId
                    },
                    parentWorkOrderId,
                    parentField,
                    verifiedChildStoreAccountId
                )
            )
            .thenReturn(
                new List<Account>{
                    verifiedStoreAccount,
                    verifiedChildStoreAccount,
                    verifiedGrandChildStoreAccount
                }
            );
        mocks.when(
                accountsSelector.selectBusinessAccountsByParentIds(
                    Account.ParentId,
                    new Set<Id>{ parentBusinessAccountId }
                )
            )
            .thenReturn(new List<Account>{ new Account(Id = childBusinessAccountId) });
        mocks.when(
                accountsSelector.selectBusinessAccountsByParentIds(
                    Account.ParentId,
                    new Set<Id>{ childBusinessAccountId }
                )
            )
            .thenReturn(new List<Account>{ new Account(Id = grandChildBusinessAccountId) });
        mocks.when(
                accountsSelector.selectBusinessAccountsByParentIds(
                    Account.ParentId,
                    new Set<Id>{ grandChildBusinessAccountId }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>(
                new Set<Id>{
                    parentBusinessAccountId,
                    childBusinessAccountId,
                    grandChildBusinessAccountId
                }
            ),
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        addStoresContainer.lastReturnedStoreAccountId = verifiedChildStoreAccountId;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresOnWorkOrderService.fetchVerifiedStores(addStoresContainerJSON);
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            verifiedStoreAccount.Name,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
    }

    /**
     * @description To test in-coverage verified store Accounts and associated Xrefs related to
     * parent Work Order's business Account and matching the criteria are correctly fetched
     * by matching Xref's External Id with the passed searchKey.
     */
    @isTest
    private static void testWhenFindVerifiedStoresBySearchKeyMatchesWithXrefExternalIdThenReturnMatchedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        String searchKey = '123'; // Sub string of Xref's External Id
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = businessAccountId,
            Contract__c = contractId
        );
        Schema.SObjectField parentField = Account.ParentId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefsSelector xrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
                    new Set<Id>{ businessAccountId },
                    parentWorkOrderId,
                    parentField,
                    searchKey,
                    new Set<Id>{ verifiedStoreAccountId }
                )
            )
            .thenReturn(new List<Account>{ verifiedStoreAccount });
        mocks.when(xrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelector.selectBySearchKey(searchKey))
            .thenReturn(new List<Xref__c>{ verifiedStoreAccount.Xrefs__r[0] });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelector);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>{ businessAccountId },
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        addStoresContainer.searchKey = searchKey;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresContainer addStoresContainerResult = AddStoresOnWorkOrderService.findVerifiedStoresBySearchKey(
            addStoresContainerJSON
        );
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            addStoresContainerResult.storeAccountWrappers[0].accountName,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
    }

    /**
     * @description To test in-coverage verified store Accounts and associated Xrefs related to
     * parent Work Order's business Account and matching the criteria are correctly fetched
     * by matching Account's Name or Address with the passed searchKey.
     */
    @isTest
    private static void testWhenFindVerifiedStoresBySearchKeyMatchesWithAccountNameThenReturnMatchedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        String searchKey = 'Test';
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = businessAccountId,
            Contract__c = contractId
        );
        Schema.SObjectField parentField = Account.ParentId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefsSelector xrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
                    new Set<Id>{ businessAccountId },
                    parentWorkOrderId,
                    parentField,
                    searchKey,
                    new Set<Id>()
                )
            )
            .thenReturn(new List<Account>{ verifiedStoreAccount });
        mocks.when(xrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelector.selectBySearchKey(searchKey)).thenReturn(new List<Xref__c>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelector);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>{ businessAccountId },
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        addStoresContainer.searchKey = searchKey;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresContainer addStoresContainerResult = AddStoresOnWorkOrderService.findVerifiedStoresBySearchKey(
            addStoresContainerJSON
        );
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            addStoresContainerResult.storeAccountWrappers[0].accountName,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
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
                .setField(
                    Contract.Associated_Account_Ids__c,
                    storeAccountId + ',' + activeStoreAccountId
                )
                .toSObject()
        };

        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, storeAccountId)
                .setField(Agreement__c.Contract__c, contractId)
                .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, activeStoreAccountId)
                .setField(Agreement__c.Contract__c, contractId)
                .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
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
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
                .toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, activeStoreAccountId)
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
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

        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);

        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(ContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(ContractsSelector.selectById(new Set<Id>{ contractId })).thenReturn(contracts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccountId, activeStoreAccountId }))
            .thenReturn(accounts);
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelector.selectAgreementsByAccounts(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelector.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                ordersSelector.selectOrdersByAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(orders);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(servicesSelector);
        Application.SELECTOR.setMock(ordersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            accountIds
        );
        Test.stopTest();
        system.assertEquals(
            returnMap.get('validation'),
            new List<String>{ 'Success' },
            'Validation should be Success'
        );
    }

    /**
     * @description To test validate stores.
     */
    @isTest
    private static void testWhenValidateStoresCalledThenValidateError() {
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
                .setField(
                    Contract.Associated_Account_Ids__c,
                    storeAccountId + ',' + activeStoreAccountId
                )
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
            (Order) new Fake(Order.class).setField(Order.AccountId, storeAccountId).toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, activeStoreAccountId)
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

        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);

        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(ContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(ContractsSelector.selectById(new Set<Id>{ contractId })).thenReturn(contracts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccountId, activeStoreAccountId }))
            .thenReturn(accounts);
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelector.selectAgreementsByAccounts(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelector.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                ordersSelector.selectOrdersByAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(orders);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(ordersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            accountIds
        );
        Test.stopTest();
        system.assertEquals(
            returnMap.get('validation'),
            new List<String>{ 'Failure' },
            'Validation should be Failure'
        );
    }

    /**
     * @description To test validate if there is Marketplace Work Order for Store Account when trying
     * to create new Work order other than Drive and POS.
     */
    @isTest
    private static void testWhenValidateOpenMarketplaceWorkOrderOnStoresThenValidateStores() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
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
        List<Account> accounts = new List<Account>{ storeAccount };
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, 'Account Owner');
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>{ parentWorkOrder };
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{ childWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService validateStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );

        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accounts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(parentWorkOrders);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelector.selectOpenMarketPlaceWorkOrdersByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(childWorkOrders);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            storeAccount.Id
        );
        Test.stopTest();
        system.assertEquals(
            returnMap.get('validation'),
            new List<String>{ 'Failure' },
            'Validation should be Failure'
        );
    }

    /**
     * @description To validate if there is no Active ‘MDS’ Xref on the Store Account then return validation error message
     * when “Add Stores” happens on a Storefront parent work order.
     */
    @isTest
    private static void testWhenStoreWithoutActiveMDSXrefsAddedOnStorefrontWorkOrderThenReturnValidationErrorMessage() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
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
        List<Account> accounts = new List<Account>{ storeAccount };
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Activated_Centrally_AC__c, null)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, 'Account Owner');
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> parentWorkOrders = new List<WorkOrder>{ parentWorkOrder };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService validateStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );

        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accounts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(parentWorkOrders);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            storeAccount.Id
        );
        Test.stopTest();
        system.assertEquals(
            returnMap.get('validation'),
            new List<String>{ 'Failure' },
            'Validation should be Failure'
        );
    }

    /**
     * @description To test in-coverage store Accounts and associated Xrefs related to
     * parent Work Order's business Account
     */
    @isTest
    private static void testWhenFetchStoresAddedThenReturnStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = businessAccountId,
            Contract__c = contractId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectRelatedStoreAccounts(parentWorkOrderId))
            .thenReturn(new List<Account>{ verifiedStoreAccount });

        mocks.when(accountsSelector.selectRelatedStoreAccountsChunk(parentWorkOrderId, null))
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>{ businessAccountId },
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresOnWorkOrderService.fetchStoresAdded(addStoresContainerJSON);
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            verifiedStoreAccount.Name,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
    }

    /**
     * @description To test in-coverage verified store Accounts and associated Xrefs related to
     * parent Work Order's business Account and matching the criteria are correctly fetched
     * by matching Account's Name
     */
    @isTest
    private static void testWhenFindStoresAddedBySearchKeyMatchesWithAccountNameThenReturnMatchedStores() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id verifiedStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        String searchKey = 'Test';
        Account verifiedStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, verifiedStoreAccountId)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, verifiedStoreAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .toSObject();
        WorkOrder workOrder = new WorkOrder(
            Id = parentWorkOrderId,
            AccountId = businessAccountId,
            Contract__c = contractId
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefsSelector xrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelector.selectRelatedStoreAccountsBySearchKey(
                    parentWorkOrderId,
                    searchKey,
                    new Set<Id>()
                )
            )
            .thenReturn(new List<Account>{ verifiedStoreAccount });
        mocks.when(xrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelector.selectBySearchKey(searchKey)).thenReturn(new List<Xref__c>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelector);
        Application.SELECTOR.setMock(accountsSelector);
        AddStoresContainer addStoresContainer = new AddStoresContainer(
            new List<Id>{ businessAccountId },
            null
        );
        addStoresContainer.parentWorkOrder = workOrder;
        addStoresContainer.searchKey = searchKey;
        String addStoresContainerJSON = JSON.serialize(addStoresContainer);
        Test.startTest();
        AddStoresContainer addStoresContainerResult = AddStoresOnWorkOrderService.findStoresAddedBySearchKey(
            addStoresContainerJSON
        );
        Test.stopTest();
        System.assertEquals(
            STORE_ACCOUNT_NAME,
            addStoresContainerResult.storeAccountWrappers[0].accountName,
            ASSERT_MESSAGE_VERIFIED_STORE_ACCOUNT
        );
    }

    /**
     * @description It is used to test when store account is selected on parent work order of
     * non-marketplace type then In-progress Marketplace Work Order validation is skipped.
     */
    @isTest
    private static void testWhenStoreAccountIsSelectedOnNonMarketplaceParentWOThenInProgressMarketplaceValidationSkipped() {
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
                .setField(
                    Contract.Associated_Account_Ids__c,
                    storeAccountId + ',' + activeStoreAccountId
                )
                .toSObject()
        };
        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, storeAccountId)
                .setField(Agreement__c.Contract__c, contractId)
                .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, activeStoreAccountId)
                .setField(Agreement__c.Contract__c, contractId)
                .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
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
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
                .toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, activeStoreAccountId)
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
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
                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
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
        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(ContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(ContractsSelector.selectById(new Set<Id>{ contractId })).thenReturn(contracts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccountId, activeStoreAccountId }))
            .thenReturn(accounts);
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelector.selectAgreementsByAccounts(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelector.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                ordersSelector.selectOrdersByAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(orders);
        mocks.when(mockOrderItemsSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountId, activeStoreAccountId },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>());
        mocks.when(mockOrderItemsService.getStoresWithBundledOrderProducts(new List<OrderItem>()))
            .thenReturn(
                new Map<Id, Boolean>{ storeAccountId => true, activeStoreAccountId => true }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(servicesSelector);
        Application.SELECTOR.setMock(ordersSelector);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.UNITOFWORK.setMock(mockUOW);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            accountIds
        );
        Test.stopTest();
        system.assertEquals(
            returnMap.get('validation'),
            new List<String>{ 'Success' },
            'Validation should be Success'
        );
    }

    /**
     * @description To test validation error message is returned when Store's Agreement Contract
     * does not match with Parent Work Order's Contract.
     */
    @isTest
    private static void testWhenStoreContractDoesNotMatchThenReturnError() {
        Id activeStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id mismatchedContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String accountIds = activeStoreAccountId + DELIMITER + storeAccountId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAddStoresOnWorkOrderService validateStoreOnWorkOrderService = (IAddStoresOnWorkOrderService) mocks.mock(
            IAddStoresOnWorkOrderService.class
        );
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, contractId)
                .setField(
                    Contract.Associated_Account_Ids__c,
                    storeAccountId + ',' + activeStoreAccountId
                )
                .toSObject()
        };
        List<Agreement__c> agreements = new List<Agreement__c>{
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, storeAccountId)
                .setField(Agreement__c.Contract__c, mismatchedContractId)
                .toSObject(),
            (Agreement__c) new Fake(Agreement__c.class)
                .setField(Agreement__c.Account__c, activeStoreAccountId)
                .setField(Agreement__c.Contract__c, mismatchedContractId)
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
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
                .toSObject(),
            (Order) new Fake(Order.class)
                .setField(Order.AccountId, activeStoreAccountId)
                .setField(
                    Order.RecordTypeId,
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
                        .get('Activation_Order')
                        .getRecordTypeId()
                )
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
        IOrdersSelector ordersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IWorkOrdersSelector workOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(ContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(ContractsSelector.selectById(new Set<Id>{ contractId })).thenReturn(contracts);
        mocks.when(workOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelector.selectById(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(workOrders);
        mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelector.selectById(new Set<Id>{ storeAccountId, activeStoreAccountId }))
            .thenReturn(accounts);
        mocks.when(agreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelector.selectAgreementsByAccounts(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(agreements);
        mocks.when(servicesSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelector.queryMerchantRecordsWithAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(services);
        mocks.when(ordersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                ordersSelector.selectOrdersByAccountIds(
                    new Set<Id>{ storeAccountId, activeStoreAccountId }
                )
            )
            .thenReturn(orders);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelector);
        Application.SELECTOR.setMock(workOrdersSelector);
        Application.SELECTOR.setMock(accountsSelector);
        Application.SELECTOR.setMock(agreementsSelector);
        Application.SELECTOR.setMock(servicesSelector);
        Application.SELECTOR.setMock(ordersSelector);
        Application.UNITOFWORK.setMock(mockUOW);

        Application.SERVICE.setMock(
            IAddStoresOnWorkOrderService.class,
            validateStoreOnWorkOrderService
        );
        Test.startTest();
        Map<String, List<String>> returnMap = AddStoresOnWorkOrderController.validateStores(
            parentWorkOrderId,
            accountIds
        );
        Test.stopTest();
        System.assertEquals(
            new List<String>{ VALIDATION_FAILURE },
            returnMap.get(VALIDATION),
            VALIDATION_MESSAGE
        );
    }
}