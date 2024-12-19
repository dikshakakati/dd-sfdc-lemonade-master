/**
 * @author Deloitte
 * @date 11/28/2022
 * @description Test class for NintexWorkOrdersProcessorBatch class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NintexWorkOrdersProcessorBatchTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To test store Accounts are retrieved by franchise Accounts in start method.
     */
    @isTest
    private static void testWhenStartMethodCalledThenStoreAccountsRetrievedByFranchiseParent() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectStoreAccountsByFranchiseParentIds(
                    new Set<Id>{ businessAccount.Id }
                )
            )
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        NintexWorkOrdersProcessorBatch batchInstance = new NintexWorkOrdersProcessorBatch(
            new Map<Id, Id>{ businessAccount.Id => parentOpportunity.Id }
        );
        Test.startTest();
        batchInstance.start(null);
        Test.stopTest();
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1))
            .selectStoreAccountsByFranchiseParentIds(new Set<Id>{ businessAccount.Id });
    }

    /**
     * @description To test child Work Order creation is initiated for the store Accounts
     * in execute method.
     */
    @isTest
    private static void testWhenStoreAccountsPassedToExecuteMethodThenChilWorkOrdersCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Franchise_Parent__c, businessAccount.Id)
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_MARKETPLACE
            )
            .setParent('Account', businessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrdersCreationService workOrdersCreationServiceMock = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                workOrdersSelectorMock.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            workOrdersCreationServiceMock
        );
        NintexWorkOrdersProcessorBatch batchInstance = new NintexWorkOrdersProcessorBatch(
            new Map<Id, Id>{ businessAccount.Id => parentOpportunity.Id }
        );
        Test.startTest();
        batchInstance.execute(null, new List<Account>{ storeAccount });
        Test.stopTest();
        ((IWorkOrdersCreationService) mocks.verify(workOrdersCreationServiceMock, 1))
            .createChildWorkOrdersByFranchiseParents(
                new Map<Id, WorkOrder>{ businessAccount.Id => parentWorkOrder },
                new List<Account>{ storeAccount }
            );
    }

    /**
     * @description To test ‘Stores Association In Progress’ banner indicator is toggled
     * on parent Work Order in finish method.
     */
    @isTest
    private static void testWhenFinishMethodCalledThenBannerIndicatorToggled() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_MARKETPLACE
            )
            .setParent('Account', businessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkOrdersCreationService workOrdersCreationServiceMock = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectStoreAccountsByFranchiseParentIds(
                    new Set<Id>{ businessAccount.Id }
                )
            )
            .thenReturn(null);
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            workOrdersCreationServiceMock
        );
        NintexWorkOrdersProcessorBatch batchInstance = new NintexWorkOrdersProcessorBatch(
            new Map<Id, Id>{ businessAccount.Id => parentOpportunity.Id }
        );
        batchInstance.parentWorkOrderIds = new Set<Id>{ parentWorkOrder.Id };
        Test.startTest();
        batchInstance.finish(null);
        Test.stopTest();
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .toggleBannerOnParentWorkOrders(new Set<Id>{ parentWorkOrder.Id });
    }
}