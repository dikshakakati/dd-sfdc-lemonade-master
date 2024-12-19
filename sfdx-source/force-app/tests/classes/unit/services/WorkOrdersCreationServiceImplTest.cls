/**
 * @author Deloitte
 * @date 06/21/2022
 * @description Test class for WorkOrdersCreationServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system asssert statements.
 * TODO: Fix NcssTypeCount PMD warning by moving setup data methods to a data factory class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts , PMD.NcssTypeCount, PMD.TooManyFields')
private class WorkOrdersCreationServiceImplTest {
    private static final String ACCOUNT_PDOA_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOA on store Account';
    private static final String ACCOUNT_PDOA_OVERRIDEN_ASSERT_MESSAGE = 'Unexpected result: PDOA is overriden on store Account';
    private static final String ACCOUNT_PDOM_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOM on store Account';
    private static final String ACCOUNT_PDOT_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOT on store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final RecordType ACCOUNT_STORE_RECORD_TYPE = new RecordType(
        Id = ACCOUNT_STORE_RECORD_TYPE_ID,
        Name = ACCOUNT_RECORD_TYPE_NAME_STORE
    );
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS_UNVERIFIED = 'Unverified';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String COMMA_SEPARATOR = ',';
    private static final String DISALLOW_PDOX_OVERRIDE_NO = 'No';
    private static final String DISALLOW_PDOX_OVERRIDE_YES = 'Yes';
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String LOG_ERROR_MESSAGE_FOR_NO_ACTIVE_STORE_ID_ON_STORES = 'The store(s) did not have an Active Store ID associated to it therefore it cannot be associated to a Storefront or Post-Sales Rate Change work order.';
    private static final String LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND = 'There is no parent Work Order in Planning or Confirmed status or within PDOA date range. Product not found for type: ';
    private static final String LOG_RECORD_METHOD_NAME = 'createWorkOrders';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'WorkOrdersCreationServiceImplTestMarketPlaceNintexId';
    private static final String OPPORTUNITY_DRIVE_NINTEX_ID = 'WorkOrdersCreationServiceImplTestDriveNintexId';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String ORDER_ITEM_OBJECT_NAME = 'OrderItem';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SOBJECTS_TO_INSERT_IS_NOT_EMPTY_ASSERT_MESSAGE = 'Unexpected result: sObjectsToInsert is not empty';
    private static final String WORK_ORDER_PDOA_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOA on child Work Order';
    private static final String WORK_ORDER_PDOA_OVERRIDEN_ASSERT_MESSAGE = 'Unexpected result: PDOA is overriden on child Work Order';
    private static final String WORK_ORDER_PDOM_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOM on child Work Order';
    private static final String WORK_ORDER_PDOT_ASSERT_MESSAGE = 'Unexpected result: failed to override PDOT on child Work Order';
    private static final String WORK_ORDER_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to register child Work Order';
    private static final String WORK_ORDER_CONTRACT_ID_NOT_POPULATED_ASSERT_MESSAGE = 'Unexpected result: failed to populate Contract Id on child Work Order';
    private static final String WORK_ORDER_PDOA_DATE_NOT_POPULATED_ASSERT_MESSAGE = 'Unexpected result: failed to populate PDOA on child Work Order from parent Work Order';
    private static final String WORK_ORDER_PDOI_NOT_POPULATED_ASSERT_MESSAGE = 'Unexpected result: failed to populate Proposed Date of Implementation on child Work Order';
    private static final String WORK_ORDER_STOREFRONT_BUNDLED_ASSERT_MESSAGE = 'Unexpected result: failed to enable bundled with marketplace on child Work Order';
    private static final String CLOSEST_PARENT_WORK_ORDER_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to tag closest parent Work Order';
    private static final String PARENT_WORK_ORDER_NOT_MATCHED_BY_NINTEX_ID_ASSERT_MESSAGE = 'Unexpected result: failed to tag parent Work Order by Nintex Id';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String TEST_OWNER_EMAIL = 'test@test.com';
    private static final String TEST_PARENT_OWNER_EMAIL = 'test_owner@test.com';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_POS = 'POS';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_ACCOUNT_ID_FIELD = 'AccountId';
    private static final String WORK_ORDER_MX_ONBOARDING_LINK_FIELD = 'Mx_Onboarding_Link__c';
    private static final String WORK_ORDER_BUNDLED_WITH_MARKETPLACE_FIELD = 'Bundled_with_Marketplace__c';
    private static final String WORK_ORDER_CONTRACT_ID_FIELD = 'Contract__c';
    private static final String WORK_ORDER_ID_FIELD = 'Id';
    private static final String WORK_ORDER_PARENTWORKORDER_ID_FIELD = 'ParentWorkOrderId';
    private static final String WORK_ORDER_PDOA_FIELD = 'Proposed_Date_of_Activation__c';
    private static final String WORK_ORDER_PDOI_FIELD = 'Proposed_Date_of_Implementation__c';
    private static final String WORK_ORDER_PDOM_FIELD = 'Proposed_Date_of_Menu__c';
    private static final String WORK_ORDER_PDOT_FIELD = 'Proposed_Date_of_Tablet__c';
    private static final String WORK_ORDER_SUB_TYPE_FIELD = 'Sub_Type__c';
    private static final String WORK_ORDER_TYPE_FIELD = 'Type__c';
    private static final String UNIQUE_IDENTIFIER = '123';
    private static final String ASSERT_MESSAGE_MX_ONBOARDING_LINK_NOT_MATCHING = 'Unexpected result: Mx Onboarding Id is not matching';
    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        TYPE_MARKETPLACE,
        TYPE_STOREFRONT
    };
    private static final String XREF_EXTERNAL_ID = '1234';
    private static final String XREF_EXTERNAL_ID_SOURCE = 'MDS';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static Fake childWorkOrderFakeInstance;
    private static WorkOrder childWorkOrderSObjectInstance;
    private static Id contractId;
    private static Fake marketplaceProductFakeInstance;
    private static Product2 marketplaceProductSObjectInstance;
    private static Fake orderItemFakeInstance;
    private static OrderItem orderItemSObjectInstance;
    private static Fake parentBusinessAccountFakeInstance;
    private static Account parentBusinessAccountSObjectInstance;
    private static Fake parentOrderFakeInstance;
    private static Order parentOrderSObjectInstance;
    private static Fake parentOpportunityFakeInstance;
    private static Opportunity parentOpportunitySObjectInstance;
    private static Fake parentWorkOrderFakeInstance;
    private static WorkOrder parentWorkOrderSObjectInstance;
    private static Fake pricebookEntryFakeInstance;
    private static PricebookEntry pricebookEntrySObjectInstance;
    private static Fake storeAccountFakeInstance;
    private static Account storeAccountSObjectInstance;
    private static Fake xrefFakeInstance;
    private static Xref__c xrefSObjectInstance;

    /**
     * @description To setup relevant fake test data.
     */
    private static void setupFakeData() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id marketPlaceProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id priceBookEntryId = fflib_IDGenerator.generate(PricebookEntry.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        // business Account fake instance
        parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.OwnerId, businessAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, businessAccountOwnerId)
                    .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
            );
        // store Account fake instance
        storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_IDENTIFIER)
            .setField(Account.User_Sets_PDOM_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.OwnerId, storeAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, storeAccountOwnerId)
                    .setField(User.Email, TEST_OWNER_EMAIL)
            )
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.OwnerId, businessAccountOwnerId)
                    .setParent(
                        'Owner',
                        new Fake(User.class)
                            .setField(User.Id, businessAccountOwnerId)
                            .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
                    )
            );
        // Opportunity fake instance
        parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        // parent Work Order fake instance
        parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        // child Work Order fake instance
        childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setParent('Account', storeAccountFakeInstance);
        // Order fake instance
        parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccountId
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        // marketplace Product fake instance
        marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        // PricebookEntry fake instance
        pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            marketPlaceProductId
        );
        // Contract fake instance
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        // primary OrderItem fake instance
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                marketPlaceProductId
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        // OrderItem fake instance
        orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                marketPlaceProductId
            )
            .setField(OrderItem.PricebookEntryId, priceBookEntryId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        // Xref_c fake instance
        xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Id, xrefId)
            .setFakeId();
    }

    /**
     * @description To setup relevant sObject test data.
     */
    private static void setupSObjectData() {
        // mocked business Account instance
        parentBusinessAccountSObjectInstance = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        // mocked store Account instance
        storeAccountSObjectInstance = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        // mocked Opportunity instance
        parentOpportunitySObjectInstance = (Opportunity) parentOpportunityFakeInstance.toSObject();
        // mocked parent Work Order instance
        parentWorkOrderSObjectInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        // mocked child Work Order instance
        childWorkOrderSObjectInstance = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        // mocked Order instance
        parentOrderSObjectInstance = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        // mocked marketplace Product instance
        marketplaceProductSObjectInstance = (Product2) ServiceMockDataBuilder.convertToSObject(
            marketplaceProductFakeInstance
        );
        // mocked PricebookEntry instance
        pricebookEntrySObjectInstance = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        // mocked OrderItem instance
        orderItemSObjectInstance = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        //mocked Xref__c instance
        xrefSObjectInstance = (Xref__c) xrefFakeInstance.toSObject();
    }

    /**
     * @description To test creation of Work Orders when Order Item Ids are passed.
     */
    @isTest
    private static void testWhenOrderItemIdsAreReceivedThenCreateWorkOrders() {
        setupFakeData();
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test child Work Order gets tagged to closest Parent Work Order.
     */
    @isTest
    private static void testWhenParentWorkOrderWithin30DaysNotFoundThenChildWorkOrderTaggedToClosestParentWorkOrder() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 90
        );
        parentBusinessAccountFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 92
        );
        setupSObjectData();
        WorkOrder parentWorkOrder100Days = parentWorkOrderSObjectInstance;
        parentWorkOrder100Days.Proposed_Date_of_Activation__c = System.today() + 100;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ parentWorkOrderSObjectInstance, parentWorkOrder100Days }
            );
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id, parentWorkOrder100Days.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasClosestParentWorkOrderTagged =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PARENTWORKORDER_ID_FIELD) == parentWorkOrderSObjectInstance.Id;
        System.assertEquals(
            true,
            hasClosestParentWorkOrderTagged,
            CLOSEST_PARENT_WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test WorkOrders are not created when child Work Order
     * exists for the same store under the same parent Work Order.
     */
    @isTest
    private static void testWhenChildWorkOrderExistsForSameStoreThenWorkOrdersAreNotCreated() {
        setupFakeData();
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByPDOA(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        List<sObject> sobjectsToInsert = ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert;
        System.assertEquals(
            true,
            sobjectsToInsert.isEmpty(),
            SOBJECTS_TO_INSERT_IS_NOT_EMPTY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of Storefront Bundled child Work Orders
     * for the passed OrderItems when Marketplace and Storefront are sold in the same Contract.
     * TODO: Replace mocked data with setup data methods.
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenMarketplaceAndStorefrontSoldTogetherThenCreateStorefrontBundledWorkOrders() {
        Id businessAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id marketplaceContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id storeAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id storefrontContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.OwnerId, businessAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, businessAccountOwnerId)
                    .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
            );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOM_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.OwnerId, storeAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, storeAccountOwnerId)
                    .setField(User.Email, TEST_OWNER_EMAIL)
            )
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.OwnerId, businessAccountOwnerId)
                    .setParent(
                        'Owner',
                        new Fake(User.class)
                            .setField(User.Id, businessAccountOwnerId)
                            .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
                    )
            );
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
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake marketplacePrimaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem marketplacePrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplacePrimaryOrderItemFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, marketplaceContractId)
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
            .setParent('Product2', storefrontProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem storefrontPrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontPrimaryOrderItemFakeInstance
        );
        Fake storefrontOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                storefrontProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, storefrontPricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, storefrontContractId)
            .setField(OrderItem.Primary_Order_Product__c, storefrontPrimaryOrderItem.Id)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', storefrontProductFakeInstance)
            .setParent('Primary_Order_Product__r', storefrontPrimaryOrderItemFakeInstance);
        OrderItem storefrontOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontOrderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ storefrontOrderItem.Id, marketplaceOrderItem.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccount.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ marketplaceContractId, storefrontContractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrder.Id },
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccount.Id => true });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ marketplaceOrderItem.Id, storefrontOrderItem.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean isBundledWithMarketplace =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_BUNDLED_WITH_MARKETPLACE_FIELD) == BUNDLED_WITH_MARKETPLACE_YES;
        System.assertEquals(
            true,
            isBundledWithMarketplace,
            WORK_ORDER_STOREFRONT_BUNDLED_ASSERT_MESSAGE
        );
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            parentBusinessAccount.Id,
            LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND +
            marketplaceOrderItem.Product2.Work_Order_Type__c,
            userInfo.getUserId(),
            marketplaceOrderItem.Id,
            storeAccount.Id
        );
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.recipientIdsToNotify = parentBusinessAccount.OwnerId;
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.severityLevel = LogEntry.SeverityLevel.HIGH.name();
        logMessageEntryInstance.storeAccountName = storeAccount.Name;
        // Added check to verify logs creation for business errors.
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => JSON.serialize(
                        new List<LogCreationEntry>{
                            new LogCreationEntry(
                                WorkOrdersCreationServiceImpl.class.getName(),
                                LOG_RECORD_METHOD_NAME,
                                new List<LogMessageEntry>{ logMessageEntryInstance }
                            )
                        }
                    )
                }
            );
    }

    /**
     * @description To test creation of child Work Orders when parent Work Order and
     * selected store Accounts from Add Stores component controller.
     */
    @isTest
    private static void testWhenParentWorkOrderAndStoreAccountsReceivedThenChildWorkOrdersCreated() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_COO);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            parentWorkOrderSObjectInstance,
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test child Work Order population on Order Item
     * by matching associated OrderId and Work Order Type of associated Product.
     */
    @isTest
    private static void testWhenChildWorkOrdersGeneratedThenChildWorkOrderPopulatedOnCorrespondingOrderItems() {
        setupFakeData();
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
                    new Set<Id>{ orderItemSObjectInstance.OrderId }
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Id childWorkOrderId = (Id) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0]
            .get(WORK_ORDER_ID_FIELD);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ OrderItem.Work_Order__c => childWorkOrderId }
                )
            );
    }

    /**
     * @description To test child Work Order gets tagged to parent Work Order by
     * matching Nintex Id of parent Work Order's Opportunity Nintex Id against
     * Nintex Id of Opportunity associated with Order of Order Product.
     */
    @isTest
    private static void testWhenPDOACriteriaNotSatisfiedThenChildWorkOrderGetsTaggedToParentWorkOrderByOpportunityNintexId() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() - 40
        );
        storeAccountFakeInstance.setField(
            Account.Marketplace_Nintex_Id__c,
            OPPORTUNITY_MARKETPLACE_NINTEX_ID
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectByNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByNintexId(
                    orderItemSObjectInstance,
                    new Map<String, List<WorkOrder>>{
                        OPPORTUNITY_MARKETPLACE_NINTEX_ID => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentWorkOrderTaggedByNintexId =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PARENTWORKORDER_ID_FIELD) == parentWorkOrderSObjectInstance.Id;
        System.assertEquals(
            true,
            hasParentWorkOrderTaggedByNintexId,
            PARENT_WORK_ORDER_NOT_MATCHED_BY_NINTEX_ID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Order for Storefront parent Work Order
     * with blank PDOA when Order Item Ids are received.
     */
    @isTest
    private static void testWhenPDOAMatchFailsOnStorefrontTypeThenParentMatchedByWorkOrderTypeToCreateChildWorkOrder() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasStorefrontChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_STOREFRONT;
        System.assertEquals(
            true,
            hasStorefrontChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of Storefront Bundled child Work Order
     * for Storefront parent Work Order with blank PDOA when Order Item Ids are received.
     * TODO: Replace mocked data with setup data methods.
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenPDOAMatchFailsOnStorefrontBundledThenParentMatchedByWorkOrderTypeToCreateChildWorkOrder() {
        Id businessAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id marketplaceContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id storeAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id storefrontContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.OwnerId, businessAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, businessAccountOwnerId)
                    .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
            );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, null)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_UNVERIFIED
            )
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOM_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.OwnerId, storeAccountOwnerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, storeAccountOwnerId)
                    .setField(User.Email, TEST_OWNER_EMAIL)
            )
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.OwnerId, businessAccountOwnerId)
                    .setParent(
                        'Owner',
                        new Fake(User.class)
                            .setField(User.Id, businessAccountOwnerId)
                            .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
                    )
            );
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
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake marketplacePrimaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem marketplacePrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            marketplacePrimaryOrderItemFakeInstance
        );
        Fake marketplaceOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                marketplaceProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, marketplacePricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, marketplaceContractId)
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
            .setParent('Product2', storefrontProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem storefrontPrimaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontPrimaryOrderItemFakeInstance
        );
        Fake storefrontOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                storefrontProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, storefrontPricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, storefrontContractId)
            .setField(OrderItem.Primary_Order_Product__c, storefrontPrimaryOrderItem.Id)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', storefrontProductFakeInstance)
            .setParent('Primary_Order_Product__r', storefrontPrimaryOrderItemFakeInstance);
        OrderItem storefrontOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            storefrontOrderItemFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ storefrontOrderItem.Id, marketplaceOrderItem.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccount.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ marketplaceContractId, storefrontContractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrder.Id },
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ storefrontOrderItem, marketplaceOrderItem }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccount.Id => true });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ marketplaceOrderItem.Id, storefrontOrderItem.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean isBundledWithMarketplace =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_BUNDLED_WITH_MARKETPLACE_FIELD) == BUNDLED_WITH_MARKETPLACE_YES;
        System.assertEquals(
            true,
            isBundledWithMarketplace,
            WORK_ORDER_STOREFRONT_BUNDLED_ASSERT_MESSAGE
        );
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            parentBusinessAccount.Id,
            LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND +
            marketplaceOrderItem.Product2.Work_Order_Type__c,
            userInfo.getUserId(),
            marketplaceOrderItem.Id,
            storeAccount.Id
        );
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.recipientIdsToNotify = parentBusinessAccount.OwnerId;
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.severityLevel = LogEntry.SeverityLevel.HIGH.name();
        logMessageEntryInstance.storeAccountName = storeAccount.Name;
        // Added check to verify logs creation for business errors.
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => JSON.serialize(
                        new List<LogCreationEntry>{
                            new LogCreationEntry(
                                WorkOrdersCreationServiceImpl.class.getName(),
                                LOG_RECORD_METHOD_NAME,
                                new List<LogMessageEntry>{ logMessageEntryInstance }
                            )
                        }
                    )
                }
            );
    }

    /**
     * @description To test child Work Order of Marketplace type is not created
     * when PDOA is null on parent Work Order.
     */
    @isTest
    private static void testWhenPDOANullOnMarketplaceWorkOrderThenChildWorkOrderNotCreated() {
        Id parentaccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        setupFakeData();
        parentBusinessAccountFakeInstance.setField(Account.OwnerId, parentaccountOwnerId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByPDOA(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(null);
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByContractOnRateChange(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        contractId => new List<WorkOrder>{ parentWorkOrderSObjectInstance }
                    }
                )
            )
            .thenReturn(null);
        mocks.when(
                mockWorkOrderSettingsService.isPDOAMatchingEnabled(
                    orderItemSObjectInstance.Product2.Work_Order_Type__c +
                        SEPARATOR +
                        orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
                )
            )
            .thenReturn(false);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        ((IWorkOrderSettingsService) mocks.verify(mockWorkOrderSettingsService, 1))
            .isPDOAMatchingEnabled(
                orderItemSObjectInstance.Product2.Work_Order_Type__c +
                    SEPARATOR +
                    orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
            );
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            parentBusinessAccountSObjectInstance.Id,
            LOG_ERROR_MESSAGE_FOR_NO_PARENT_WORK_ORDER_FOUND +
            orderItemSObjectInstance.Product2.Work_Order_Type__c,
            userInfo.getUserId(),
            orderItemSObjectInstance.Id,
            storeAccountSObjectInstance.Id
        );
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.recipientIdsToNotify =
            storeAccountSObjectInstance.OwnerId +
            COMMA_SEPARATOR +
            parentBusinessAccountSObjectInstance.OwnerId;
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.severityLevel = LogEntry.SeverityLevel.HIGH.name();
        logMessageEntryInstance.storeAccountName = storeAccountSObjectInstance.Name;
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Storefront child Work Order for Storefront parent Work Order
     * with matching Type value when Order Item Ids are received.
     */
    @isTest
    private static void testWhenTypeMatchesOnStorefrontParentWorkOrderThenCreateChildWorkOrder() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        storeAccountFakeInstance.setField(
            Account.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrderSettingsService.isPDOAMatchingEnabled(
                    orderItemSObjectInstance.Product2.Work_Order_Type__c +
                        SEPARATOR +
                        orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
                )
            )
            .thenReturn(false);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasStorefrontChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_STOREFRONT;
        System.assertEquals(
            true,
            hasStorefrontChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test when inactive ‘MDS’ Xrefs are found related to Store Account
     * Ids then Storefront child work order is not created.
     */
    @isTest
    private static void testWhenInactiveXrefsFoundOnStoreAccountThenStorefrontChildWorkOrderNotCreated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        storeAccountFakeInstance.setField(
            Account.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        setupSObjectData();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_INACTIVE)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.Id, xrefId)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrderSettingsService.isPDOAMatchingEnabled(
                    orderItemSObjectInstance.Product2.Work_Order_Type__c +
                        SEPARATOR +
                        orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
                )
            )
            .thenReturn(false);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test creation of Marketplace child Work Order for parent Work Order
     * by matching by PDOA value when Order Item Ids are received.
     */
    @isTest
    private static void testWhenMarketplaceTypeParentWorkOrderThenCreateChildWorkOrderByMatchingPDOA() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_MARKETPLACE);
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_MARKETPLACE);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        storeAccountFakeInstance.setField(
            Account.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByPDOA(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrderSettingsService.isPDOAMatchingEnabled(
                    orderItemSObjectInstance.Product2.Work_Order_Type__c +
                        SEPARATOR +
                        orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
                )
            )
            .thenReturn(true);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasMarketplaceChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_MARKETPLACE;
        System.assertEquals(
            true,
            hasMarketplaceChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasPDOAPopulatedOnChildWorkOrder =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOA_FIELD) == System.today() + 100;
        System.assertEquals(
            true,
            hasPDOAPopulatedOnChildWorkOrder,
            WORK_ORDER_PDOA_DATE_NOT_POPULATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Order with Contract Id
     * when Contract Id is present on primary Order product associated to activation Order Product.
     */
    @isTest
    private static void testWhenContractIdNullOnActivationOrderProductThenContractIdPopulatedByPrimaryOrderProductOnChildWorkOrder() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        storeAccountFakeInstance.setField(
            Account.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        orderItemFakeInstance.setField(OrderItem.SBQQ__Contract__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasContractIdPopulatedByPrimaryOrderProduct =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_CONTRACT_ID_FIELD) ==
            orderItemSObjectInstance.Primary_Order_Product__r.SBQQ__Contract__c;
        System.assertEquals(
            true,
            hasContractIdPopulatedByPrimaryOrderProduct,
            WORK_ORDER_CONTRACT_ID_NOT_POPULATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Order with Contract Id
     * when Contract Id is present on activation Order Product.
     */
    @isTest
    private static void testWhenContractIdNotNullOnActivationOrderProductThenContractIdPopulatedOnChildWorkOrder() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        orderItemFakeInstance.setField(OrderItem.Primary_Order_Product__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasContractIdPopulatedByActivationOrderProduct =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_CONTRACT_ID_FIELD) == orderItemSObjectInstance.SBQQ__Contract__c;
        System.assertEquals(
            true,
            hasContractIdPopulatedByActivationOrderProduct,
            WORK_ORDER_CONTRACT_ID_NOT_POPULATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Order with Nintex Id
     * from matching store Account and parent Work Order's Opportunity Nintex Id.
     */
    @isTest
    private static void testWhenPDOAMatchFailsThenCreateChildWorkOrderByMatchingParentWorkOrderOpportunityNintexId() {
        Id franchiseParentId = fflib_IDGenerator.generate(Account.SObjectType);
        setupFakeData();
        storeAccountFakeInstance.setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID);
        storeAccountFakeInstance.setField(Account.Franchise_Parent__c, franchiseParentId);
        parentOpportunityFakeInstance.setField(
            Opportunity.Drive_Nintex_Id__c,
            OPPORTUNITY_DRIVE_NINTEX_ID
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_DRIVE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_DRIVE);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_DRIVE);
        setupSObjectData();
        parentWorkOrderSObjectInstance.Opportunity__c = parentOpportunitySObjectInstance.Id;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectByNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByNintexId(
                    orderItemSObjectInstance,
                    new Map<String, List<WorkOrder>>{
                        OPPORTUNITY_MARKETPLACE_NINTEX_ID => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate "Proposed Date of Activation", "Proposed Date of Menu"
     * "Proposed Date of Tablet" not overridden from parent Work Order on child Work Order and
     * store Account when "User Sets PDOA Value?", "User Sets PDOA Value?" and
     * "User Sets PDOT Value?" is 'Yes' on store Account.
     */
    @isTest
    private static void testWhenPDOXOverrideDisallowedOnStoreThenPDOXFieldsNotOverriddenOnChildWorkOrderAndStoreAccount() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 7
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Menu__c,
            System.today() + 3
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Tablet__c,
            System.today() + 9
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            parentWorkOrderSObjectInstance,
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        Boolean hasPDOAOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOA_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c;
        Boolean hasPDOMOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOM_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Menu__c;
        Boolean hasPDOTOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOT_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Tablet__c;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(false, hasPDOAOveridden, WORK_ORDER_PDOA_ASSERT_MESSAGE);
        System.assertEquals(false, hasPDOMOveridden, WORK_ORDER_PDOM_ASSERT_MESSAGE);
        System.assertEquals(false, hasPDOTOveridden, WORK_ORDER_PDOT_ASSERT_MESSAGE);
        System.assertEquals(
            false,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Activation__c,
            ACCOUNT_PDOA_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Menu__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Menu__c,
            ACCOUNT_PDOM_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Tablet__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Tablet__c,
            ACCOUNT_PDOT_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate "Proposed Date of Activation" update
     * on store Account based on parent Work Order's "Proposed Date of Activation"
     * when "User Sets PDOA Value?" is 'No' on store Account.
     */
    @isTest
    private static void testWhenPDOAOverrideAllowedOnStoreAccountThenPDOAOverriddenOnStoreAccountByParentWorkOrderPDOAValue() {
        setupFakeData();
        storeAccountFakeInstance.setField(
            Account.Disallow_PDOA_Override__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 7
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Menu__c,
            System.today() + 3
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Tablet__c,
            System.today() + 9
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        // Verify PDOA is overridden on store Account based on parent Work Order.
        storeAccountSObjectInstance.Proposed_Date_of_Activation__c = parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c;
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>{ storeAccountSObjectInstance });
        Boolean hasPDOAOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOA_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c;
        System.assertEquals(true, hasPDOAOveridden, WORK_ORDER_PDOA_ASSERT_MESSAGE);
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate "Proposed Date of Menu" update
     * on store Account based on parent Work Order's "Proposed Date of Menu"
     * when "User Sets PDOM Value?" is 'No' on store Account.
     */
    @isTest
    private static void testWhenPDOMOverrideAllowedOnStoreAccountThenPDOMOverriddenOnStoreAccountByParentWorkOrderPDOMValue() {
        setupFakeData();
        storeAccountFakeInstance.setField(
            Account.User_Sets_PDOM_Value__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 7
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Menu__c,
            System.today() + 3
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Tablet__c,
            System.today() + 9
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        // Verify PDOM is overridden on store Account based on parent Work Order.
        storeAccountSObjectInstance.Proposed_Date_of_Menu__c = parentWorkOrderSObjectInstance.Proposed_Date_of_Menu__c;
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>{ storeAccountSObjectInstance });
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate "Proposed Date of Tablet" update
     * on store Account based on parent Work Order's "Proposed Date of Tablet"
     * when "User Sets PDOT Value?" is 'No' on store Account.
     */
    @isTest
    private static void testWhenPDOTOverrideAllowedOnStoreAccountThenPDOTOverriddenOnStoreAccountByParentWorkOrderPDOTValue() {
        setupFakeData();
        storeAccountFakeInstance.setField(
            Account.User_Sets_PDOT_Value__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 7
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Menu__c,
            System.today() + 3
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Tablet__c,
            System.today() + 9
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        // Verify PDOT is overridden on store Account based on parent Work Order.
        storeAccountSObjectInstance.Proposed_Date_of_Tablet__c = parentWorkOrderSObjectInstance.Proposed_Date_of_Tablet__c;
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>{ storeAccountSObjectInstance });
        Boolean hasPDOTOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOT_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Tablet__c;
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(true, hasPDOTOveridden, WORK_ORDER_PDOT_ASSERT_MESSAGE);
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Orders for the passed store Accounts
     * using the associated franchise Accounts.
     */
    @isTest
    private static void testWhenStoreAccountsWithAssociatedFranchiseParentsReceivedThenCorrespondingChildWorkOrdersCreated() {
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        setupFakeData();
        storeAccountFakeInstance.setField(Account.Franchise_Parent__c, franchiseAccountId);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersByFranchiseParents(
            new Map<Id, WorkOrder>{ franchiseAccountId => parentWorkOrderSObjectInstance },
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        //((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of Post Sales - Rate Change child Work Orders for the
     * passed store Accounts using the associated franchise Accounts with active MDS Xref.
     */
    @isTest
    private static void testWhenStoreAccountsWithFranchiseParentsAndActiveXrefThenCorrespondingChildWorkOrdersCreated() {
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        setupFakeData();
        storeAccountFakeInstance.setField(Account.Franchise_Parent__c, franchiseAccountId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POST_SALES);
        parentWorkOrderFakeInstance.setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersByFranchiseParents(
            new Map<Id, WorkOrder>{ franchiseAccountId => parentWorkOrderSObjectInstance },
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Post Sales - Rate Change child Work Orders are not created when
     * no active MDS Xref is present.
     */
    @isTest
    private static void testWhenStoreAccountsWithFranchiseParentsAndInactiveXrefThenCorrespondingChildWorkOrdersNotCreated() {
        Id businessAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        setupFakeData();
        parentBusinessAccountFakeInstance.setField(Account.OwnerId, businessAccountOwnerId);
        parentBusinessAccountFakeInstance.setParent(
            'Owner',
            new Fake(User.class)
                .setField(User.Id, businessAccountOwnerId)
                .setField(User.Email, TEST_PARENT_OWNER_EMAIL)
        );
        storeAccountFakeInstance.setField(Account.Franchise_Parent__c, franchiseAccountId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POST_SALES);
        parentWorkOrderFakeInstance.setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersByFranchiseParents(
            new Map<Id, WorkOrder>{ franchiseAccountId => parentWorkOrderSObjectInstance },
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        List<sObject> sobjectsToInsert = ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert;
        System.assertEquals(
            true,
            sobjectsToInsert.isEmpty(),
            SOBJECTS_TO_INSERT_IS_NOT_EMPTY_ASSERT_MESSAGE
        );
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            parentBusinessAccountSObjectInstance.Id,
            LOG_ERROR_MESSAGE_FOR_NO_ACTIVE_STORE_ID_ON_STORES,
            userInfo.getUserId(),
            parentWorkOrderSObjectInstance.Id,
            storeAccountSObjectInstance.Id
        );
        logMessageEntryInstance.franchiseAccountId = franchiseAccountId;
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.recipientIdsToNotify = storeAccountSObjectInstance.Parent.OwnerId;
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.severityLevel = LogEntry.SeverityLevel.CRITICAL.name();
        logMessageEntryInstance.storeAccountName = storeAccountSObjectInstance.Name;
        // Added check to verify logs creation for business errors.
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => JSON.serialize(
                        new List<LogCreationEntry>{
                            new LogCreationEntry(
                                WorkOrdersCreationServiceImpl.class.getName(),
                                LOG_RECORD_METHOD_NAME,
                                new List<LogMessageEntry>{ logMessageEntryInstance }
                            )
                        }
                    )
                }
            );
    }

    /**
     * @description To test child Work Order creation on parent Work Order by
     * matching store Account's Nintex Id with parent Work Order's Opportunity Nintex Id
     * when parent Work Orders with matching PDOA and matching Opportunity Nintex Id exists.
     */
    @isTest
    private static void testWhenParentWorkOrdersWithNintexIdAndPDOAFoundThenChildWorkOrderCreatedOnParentWorkOrderByMatchingOpportunityNintexId() {
        setupFakeData();
        Fake parentWorkOrderFakeInstanceWithPDOAMatch = parentWorkOrderFakeInstance;
        parentWorkOrderFakeInstanceWithPDOAMatch.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() - 40
        );
        storeAccountFakeInstance.setField(
            Account.Marketplace_Nintex_Id__c,
            OPPORTUNITY_MARKETPLACE_NINTEX_ID
        );
        storeAccountFakeInstance.setField(
            Account.Proposed_Date_of_Activation__c,
            System.today() + 100
        );
        setupSObjectData();
        WorkOrder parentWorkOrderSObjectInstanceWithPDOAMatch = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstanceWithPDOAMatch
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(
                new List<WorkOrder>{
                    parentWorkOrderSObjectInstance,
                    parentWorkOrderSObjectInstanceWithPDOAMatch
                }
            );
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{
                        parentWorkOrderSObjectInstance.Id,
                        parentWorkOrderSObjectInstanceWithPDOAMatch.Id
                    },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectByNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByNintexId(
                    orderItemSObjectInstance,
                    new Map<String, List<WorkOrder>>{
                        OPPORTUNITY_MARKETPLACE_NINTEX_ID => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentWorkOrderMatchedByNintexId =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PARENTWORKORDER_ID_FIELD) == parentWorkOrderSObjectInstance.Id;
        System.assertEquals(
            true,
            hasParentWorkOrderMatchedByNintexId,
            PARENT_WORK_ORDER_NOT_MATCHED_BY_NINTEX_ID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of child Work Order matched by Contract on parent Work Order
     * when Order Item Ids are received in Post-Sales Rate Change process.
     */
    @isTest
    private static void testWhenOrderItemsRecievedOnPostSalesRateChangeThenChildWorkOrderAssociatedWithParentWorkOrderMatchedByContract() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POST_SALES);
        parentWorkOrderFakeInstance.setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByContractOnRateChange(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        contractId => new List<WorkOrder>{ parentWorkOrderSObjectInstance }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasCOOChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_SUB_TYPE_FIELD) == SUB_TYPE_RATE_CHANGE;
        System.assertEquals(
            true,
            hasCOOChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to validate "Proposed Date of Activation" not updated
     * on store Account and child Work Order when "User Sets PDOA Value?" is 'No' on store Account but
     * parent Work Order's "Proposed Date of Activation" is null.
     */
    @isTest
    private static void testWhenPDOAOverrideAllowedOnStoreAccountWithParentWorkOrderPDOANullThenPDOANotOverriddenOnStoreAccountAndChildWorkOrder() {
        setupFakeData();
        storeAccountFakeInstance.setField(
            Account.Disallow_PDOA_Override__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POST_SALES);
        parentWorkOrderFakeInstance.setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Menu__c, null);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByContractOnRateChange(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        contractId => new List<WorkOrder>{ parentWorkOrderSObjectInstance }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>());
        Boolean hasPDOAOveridden =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOA_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c;
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(false, hasPDOAOveridden, WORK_ORDER_PDOA_OVERRIDEN_ASSERT_MESSAGE);
        System.assertEquals(
            false,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Activation__c,
            ACCOUNT_PDOA_OVERRIDEN_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /*
     * @description It is used to test that when storeAccountId-to-parentWOId map is passed
     * as an argument to overloaded `createChildWorkOrdersOnStoreAccounts` method
     * then child workOrders are created
     **/
    @isTest
    static void testWhenCreateChildWorkOrdersOnStoreAccountsCalledWithMapArgThenChildWorkOrdersCreated() {
        setupFakeData();
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        parentWorkOrderFakeInstance.setField(WorkOrder.Mx_Onboarding_Link__c, mxOnboardingLinkId);
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POS);

        storeAccountFakeInstance.setField(
            Account.Disallow_PDOA_Override__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POST_SALES);
        parentWorkOrderFakeInstance.setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 90
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Menu__c, null);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Tablet__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectById(new Set<String>{ storeAccountSObjectInstance.Id })
            )
            .thenReturn(new List<Account>{ storeAccountSObjectInstance });
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrderSObjectInstance.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            new Map<Id, Set<Id>>{
                storeAccountSObjectInstance.Id => new Set<Id>{ parentWorkOrderSObjectInstance.Id }
            }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());

        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>{ storeAccountSObjectInstance });

        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;

        Boolean isMatchingMxOnboardingId =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_MX_ONBOARDING_LINK_FIELD) == mxOnboardingLinkId;
        System.assertEquals(
            true,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Activation__c,
            ACCOUNT_PDOA_OVERRIDEN_ASSERT_MESSAGE
        );

        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );

        System.assertEquals(
            true,
            parentWorkOrderSObjectInstance.Proposed_Date_of_Activation__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Activation__c,
            ACCOUNT_PDOA_OVERRIDEN_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            isMatchingMxOnboardingId,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK_NOT_MATCHING
        );
    }

    /**
     * @description To test creation of Work Orders when Order Item Ids are passed for Onboarding Inputs.
     */
    @isTest
    private static void testWhenOrderItemIdsReceivedByOnboardingInputsThenCreateWorkOrders() {
        setupFakeData();
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByMxOnboardingLink(
                    orderItemSObjectInstance,
                    new Map<String, List<WorkOrder>>{
                        UNIQUE_IDENTIFIER => new List<WorkOrder>{ parentWorkOrderSObjectInstance }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        Test.startTest();
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test creation of Work Orders when Order Item Ids are passed for Onboarding Inputs where
     * primary Order Id is different for Marketplace and Storefront.
     */
    @isTest
    private static void testWhenOrderItemIdsReceivedByOnboardingInputsAndPrimaryOrderIdsAreDifferentForMarketplaceAndStorefrontThenCreateStorefrontWorkOrders() {
        setupFakeData();
        setupSObjectData();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        WorkOrder parentWorkOrderFakeInstance = (WorkOrder) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccountId,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderFakeInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderFakeInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByMxOnboardingLink(
                    orderItemSObjectInstance,
                    new Map<String, List<WorkOrder>>{
                        UNIQUE_IDENTIFIER => new List<WorkOrder>{ parentWorkOrderFakeInstance }
                    }
                )
            )
            .thenReturn(parentWorkOrderFakeInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        Test.startTest();
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /*
     * @description It is used to test that when storeAccountId-to-parentWOIds map is passed
     * as an argument to overloaded `createChildWorkOrdersOnStoreAccounts` method
     * then child workOrders are created
     **/
    @isTest
    static void testWhenCreateChildWorkOrdersOnStoreAccountsCalledWithStoreAccountIdToMultipleWorkOrdersIdsThenChildWorkOrdersCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        setupFakeData();
        WorkOrder parentWorkOrderFakeInstance2 = (WorkOrder) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccountId,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance)
            .toSObject();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_POS);

        storeAccountFakeInstance.setField(
            Account.Disallow_PDOA_Override__c,
            DISALLOW_PDOX_OVERRIDE_NO
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_MARKETPLACE);
        parentWorkOrderFakeInstance.setField(WorkOrder.Contract__c, contractId);
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Activation__c,
            System.today() + 90
        );
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Menu__c, null);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Tablet__c, null);

        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountsService mockAccountsService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectById(new Set<String>{ storeAccountSObjectInstance.Id })
            )
            .thenReturn(new List<Account>{ storeAccountSObjectInstance });
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectById(
                    new Set<Id>{
                        parentWorkOrderSObjectInstance.Id,
                        parentWorkOrderFakeInstance2.Id
                    }
                )
            )
            .thenReturn(
                new List<WorkOrder>{ parentWorkOrderSObjectInstance, parentWorkOrderFakeInstance2 }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountsService);
        Test.startTest();
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            new Map<Id, Set<Id>>{
                storeAccountSObjectInstance.Id => new Set<Id>{
                    parentWorkOrderSObjectInstance.Id,
                    parentWorkOrderFakeInstance2.Id
                }
            }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());

        ((IAccountsService) mocks.verify(mockAccountsService, 1))
            .populatePDOXOnStoreAccounts(new List<Account>{ storeAccountSObjectInstance });
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        /*
        System.assertEquals(
            true,
            parentWorkOrderFakeInstance2.Proposed_Date_of_Activation__c ==
            storeAccountSObjectInstance.Proposed_Date_of_Activation__c,
            ACCOUNT_PDOA_OVERRIDEN_ASSERT_MESSAGE
        );
        */
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when child Work Order is created through Order Items then stamp "Proposed Date of Implementation"
     * from parent Work Order.
     */
    @isTest
    private static void testWhenChildWorkOrderInsertedThenPopulateProposedDateOfImplementationFromParentWO() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        parentWorkOrderFakeInstance.setField(WorkOrder.Proposed_Date_of_Activation__c, null);
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Implementation__c,
            System.today()
        );
        marketplaceProductFakeInstance.setField(Product2.Name, TYPE_STOREFRONT);
        marketplaceProductFakeInstance.setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        orderItemFakeInstance.setField(OrderItem.Primary_Order_Product__c, null);
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderItemsSelector mockOrderItemsSelector = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IOrderItemsService mockOrderItemsService = (IOrderItemsService) mocks.mock(
            IOrderItemsService.class
        );
        IParentWorkOrderMatcherService parentWorkOrderMatcherServiceMock = (IParentWorkOrderMatcherService) mocks.mock(
            IParentWorkOrderMatcherService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockOrderItemsSelector.SObjectType())
            .thenReturn(Schema.getGlobalDescribe().get(ORDER_ITEM_OBJECT_NAME));
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsById(
                    new Set<Id>{ orderItemSObjectInstance.Id },
                    false
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(
                mockOrderItemsSelector.selectActivatedOrderItemsByAccountIdsAndProductTypes(
                    new Set<Id>{ storeAccountSObjectInstance.Id },
                    WORK_ORDER_TYPES
                )
            )
            .thenReturn(new List<OrderItem>{ orderItemSObjectInstance });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByBusinessAccountIds(
                    new Set<Id>{ parentBusinessAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrderSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderSObjectInstance.Id },
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{},
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(
                mockOrderItemsService
                    .getStoresWithBundledOrderProducts(
                        new List<OrderItem>{ orderItemSObjectInstance }
                    )
            )
            .thenReturn(new Map<Id, Boolean>{ storeAccountSObjectInstance.Id => false });
        mocks.when(
                parentWorkOrderMatcherServiceMock.matchByType(
                    orderItemSObjectInstance,
                    new Map<Id, List<WorkOrder>>{
                        parentBusinessAccountSObjectInstance.Id => new List<WorkOrder>{
                            parentWorkOrderSObjectInstance
                        }
                    }
                )
            )
            .thenReturn(parentWorkOrderSObjectInstance);
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveMDSXrefsByStoreIds(
                    new Set<Id>{ storeAccountSObjectInstance.Id }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefSObjectInstance });
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockOrderItemsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SERVICE.setMock(IOrderItemsService.class, mockOrderItemsService);
        Application.SERVICE.setMock(
            IParentWorkOrderMatcherService.class,
            parentWorkOrderMatcherServiceMock
        );
        WorkOrdersCreationService.createWorkOrders(
            new Set<Id>{ orderItemSObjectInstance.Id },
            false
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasProposedDateOfImplementationPopulated =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOI_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Implementation__c;
        System.assertEquals(
            true,
            hasProposedDateOfImplementationPopulated,
            WORK_ORDER_PDOI_NOT_POPULATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when child Work Order is created through Add Stores then stamp "Proposed Date of Implementation"
     * from parent Work Order.
     */
    @isTest
    private static void testWhenChildWorkOrderCreatedThroughAddStoresThenPopulateProposedDateOfImplementationFromParentWO() {
        setupFakeData();
        parentWorkOrderFakeInstance.setField(WorkOrder.Type__c, TYPE_STOREFRONT);
        parentWorkOrderFakeInstance.setField(
            WorkOrder.Proposed_Date_of_Implementation__c,
            System.today()
        );
        setupSObjectData();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        WorkOrdersCreationService.createChildWorkOrdersOnStoreAccounts(
            parentWorkOrderSObjectInstance,
            new List<Account>{ storeAccountSObjectInstance }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountSObjectInstance.Id;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasProposedDateOfImplementationPopulated =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_PDOI_FIELD) ==
            parentWorkOrderSObjectInstance.Proposed_Date_of_Implementation__c;
        System.assertEquals(
            true,
            hasProposedDateOfImplementationPopulated,
            WORK_ORDER_PDOI_NOT_POPULATED_ASSERT_MESSAGE
        );
    }
}