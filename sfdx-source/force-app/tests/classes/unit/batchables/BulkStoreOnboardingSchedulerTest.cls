/**
 * @author BizApps
 * @date 25-September-2023
 * @description Test class for the BulkStoreOnboardingScheduler class..
**/
@IsTest
private class BulkStoreOnboardingSchedulerTest {
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';

    @IsTest
    static void testWhenScheduledClassIsCalledThenCheckIfBatchShouldRun() {
        Id parentAccountId = Fake.generateId(Account.SObjectType);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        List<Account> mockStores = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 1',
                ParentId = parentAccountId,
                Coverage__c = 'In Coverage',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Contract__c = Fake.generateId(Contract.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4),
            OwnerId = UserInfo.getUserId()
        );

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(mockStores[0].Id, null, null)
        };

        mockFlowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
            storeInfos
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(mockStores);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        BulkStoreOnboardingScheduler scheduledJob = new BulkStoreOnboardingScheduler(flowRequestId);
        scheduledJob.execute(null);
        System.assertNotEquals(null, mockFlowRequest, 'The PFR should be populated.');
    }
}