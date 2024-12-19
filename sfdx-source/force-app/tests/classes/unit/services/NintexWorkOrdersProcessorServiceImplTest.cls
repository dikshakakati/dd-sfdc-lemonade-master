/**
 * @author Deloitte
 * @date 11/28/2022
 * @description Test class for NintexWorkOrdersProcessorServiceImpl class.
 * Suppressed Warnings since mock verify method is equivalent of system assert statement.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NintexWorkOrdersProcessorServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String OPPORTUNITY_DRIVE_NINTEX_ID = 'OpportunitiesServiceImplTestDriveNintexId';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE = 'Rate Change';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To test creation of child Work Orders for the passed store Accounts by
     * franchise Accounts.
     */
    @isTest
    private static void testWhenStoreAccountsAssociatedWithFranchiseParentsReceivedThenChildWorkOrdersCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Franchise_Parent__c, parentBusinessAccount.Id)
            .setField(Account.ParentId, parentBusinessAccount.Id)
            .setParent('Parent', parentBusinessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE);
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.IsStoresAssociationInProgress__c, false)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersCreationService workOrdersCreationServiceMock = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            workOrdersCreationServiceMock
        );
        Test.startTest();
        NintexWorkOrdersProcessorService.initiateChildWorkOrdersCreation(
            new Map<Id, Id>{ parentBusinessAccount.Id => opportunityId },
            new List<Account>{ storeAccount }
        );
        Test.stopTest();
        ((IWorkOrdersCreationService) mocks.verify(workOrdersCreationServiceMock, 1))
            .createChildWorkOrdersByFranchiseParents(
                new Map<Id, WorkOrder>{ parentBusinessAccount.Id => parentWorkOrder },
                new List<Account>{ storeAccount }
            );
    }

    /**
     * @description To test creation of child Work Orders by franchise Accounts,
     * only for the store Accounts which do not have existing Work Order associated with
     * parent Work Order corresponding with franchise Account.
     */
    @isTest
    private static void testWhenStoreAccountsAssociatedWithFranchiseParentsReceivedThenChildWorkOrdersCreationInitiatedOnNonDuplicateStoreAccounts() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Franchise_Parent__c, parentBusinessAccount.Id)
            .setField(Account.ParentId, parentBusinessAccount.Id)
            .setParent('Parent', parentBusinessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );
        Fake storeAccountWithChildWorkOrderFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Franchise_Parent__c, parentBusinessAccount.Id)
            .setField(Account.ParentId, parentBusinessAccount.Id)
            .setParent('Parent', parentBusinessAccountFakeInstance);
        Account storeAccountWithChildWorkOrder = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithChildWorkOrderFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE);
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.IsStoresAssociationInProgress__c, false)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setFakeId()
            .toSObject();
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccountWithChildWorkOrder.Id,
                WORK_ORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountWithChildWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersCreationService workOrdersCreationServiceMock = (IWorkOrdersCreationService) mocks.mock(
            IWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(
            IWorkOrdersCreationService.class,
            workOrdersCreationServiceMock
        );
        Test.startTest();
        NintexWorkOrdersProcessorService.initiateChildWorkOrdersCreation(
            new Map<Id, Id>{ parentBusinessAccount.Id => opportunityId },
            new List<Account>{ storeAccount, storeAccountWithChildWorkOrder }
        );
        Test.stopTest();
        ((IWorkOrdersCreationService) mocks.verify(workOrdersCreationServiceMock, 1))
            .createChildWorkOrdersByFranchiseParents(
                new Map<Id, WorkOrder>{ parentBusinessAccount.Id => parentWorkOrder },
                new List<Account>{ storeAccount }
            );
    }
}