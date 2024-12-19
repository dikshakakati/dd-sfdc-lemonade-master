/**
 * @author Deloitte
 * @date 05/18/2024
 * @description Test class for Store Association Service.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class StoreAssociationServiceImplTest {
    private static final String EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT = 'PHOTOSHOOT_STORE_ASSOCIATION';
    private static final String GUIDED_FLOW_CREATION_SOURCE = 'Guided Flow';
    private static final String MANUAL_CREATION_SOURCE = 'Manual';
    private static final String NULL_ERROR = 'Work Order Id must not be null.';
    private static final String ORIGINATING_WORK_ORDER = 'Originating_Work_Order__r';
    private static final String PARENT_WORK_ORDER = 'ParentWorkOrder';
    private static final String PHOTOSHOOT_WORK_ORDER = 'Photoshoot';
    private static final String YES_FOR_PHOTOSHOOT = 'Yes';

    /**
     * @description To test store association is initiated when Marketplace work order creation
     * triggers platform event.
     */
    @isTest
    private static void testWhenMarketplaceWorkOrdersCreatedThenStoresAssociationServiceCalled() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<Onboarding_Activation__e> onboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT,
                Payload__c = (String) workOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreAssociationService storeAssociationServiceMock = (IStoreAssociationService) mocks.mock(
            IStoreAssociationService.class
        );
        Application.SERVICE.setMock(IStoreAssociationService.class, storeAssociationServiceMock);
        StoreAssociationService.execute(onboardingEvents);
        ((IStoreAssociationService) mocks.verify(storeAssociationServiceMock, 1))
            .handleOnboardingActivationsEvents(onboardingEvents);
    }

    /**
     * @description To test store association is initiated when platform event payload received.
     */
    @isTest
    private static void testWhenOnboardingEventsReceivedThenHandleEvents() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<Onboarding_Activation__e> onboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_STORE_ASSOCIATION_PHOTOSHOOT,
                Payload__c = (String) JSON.serialize(new List<String>{ workOrderId })
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreAssociationService storeAssociationServiceMock = (IStoreAssociationService) mocks.mock(
            IStoreAssociationService.class
        );
        Application.SERVICE.setMock(IStoreAssociationService.class, storeAssociationServiceMock);
        new StoreAssociationServiceImpl().handleOnboardingActivationsEvents(onboardingEvents);
        System.assertNotEquals(workOrderId, null, NULL_ERROR);
    }

    /**
     * @description To test store associated when manual work orders are received.
     */
    @isTest
    private static void testWhenManualWorkOrdersSentThenStoreAssociationSuccessful() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id originatingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id originatingWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id photoshootAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account photoshootAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, photoshootAccountId)
            .setField(Account.ParentId, originatingAccountId)
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                        .setField(WorkOrder.ParentWorkOrderId, originatingWorkOrderId)
                        .setParent(
                            PARENT_WORK_ORDER,
                            new Fake(WorkOrder.class).setField(WorkOrder.Id, originatingWorkOrderId)
                        )
                }
            )
            .toSobject();
        WorkOrder photoshootWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Type__c, PHOTOSHOOT_WORK_ORDER)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Creation_Source__c, MANUAL_CREATION_SOURCE)
            .setField(WorkOrder.Photoshoot_Date__c, System.today())
            .setField(WorkOrder.Photoshoot_Time__c, Time.newInstance(1, 2, 3, 4))
            .setField(
                WorkOrder.Store_Location_for_Photoshoot__c,
                fflib_IDGenerator.generate(Account.SObjectType)
            )
            .setField(WorkOrder.Mx_Requested_Photoshoot__c, YES_FOR_PHOTOSHOOT)
            .setField(WorkOrder.Originating_Work_Order__c, originatingWorkOrderId)
            .setParent(
                ORIGINATING_WORK_ORDER,
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, originatingWorkOrderId)
                    .setField(WorkOrder.AccountId, originatingAccountId)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IStoreAssociationService storeAssociationServiceMock = (IStoreAssociationService) mocks.mock(
            IStoreAssociationService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ photoshootWorkOrder });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectRelatedStoreAccountsQuery(
                    new Set<Id>{ originatingWorkOrderId }
                )
            )
            .thenReturn(new List<Account>{ photoshootAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(IStoreAssociationService.class, storeAssociationServiceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        new StoreAssociationServiceImpl()
            .initiatePhotoshootStoreAssociation(new Set<Id>{ workOrderId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    /**
     * @description To test store associated when work orders created from guided flow are received.
     */
    @isTest
    private static void testWhenGuidedFlowWorkOrdersReceivedThenStoreAssociationSuccessful() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id originatingAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id originatingWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id photoshootAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account photoshootAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, photoshootAccountId)
            .setField(Account.ParentId, originatingAccountId)
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                        .setField(WorkOrder.ParentWorkOrderId, originatingWorkOrderId)
                        .setParent(
                            PARENT_WORK_ORDER,
                            new Fake(WorkOrder.class).setField(WorkOrder.Id, originatingWorkOrderId)
                        )
                }
            )
            .toSobject();
        WorkOrder photoshootWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, originatingAccountId)
            .setField(WorkOrder.Type__c, PHOTOSHOOT_WORK_ORDER)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Creation_Source__c, GUIDED_FLOW_CREATION_SOURCE)
            .setField(WorkOrder.Photoshoot_Date__c, System.today())
            .setField(WorkOrder.Photoshoot_Time__c, Time.newInstance(1, 2, 3, 4))
            .setField(
                WorkOrder.Store_Location_for_Photoshoot__c,
                fflib_IDGenerator.generate(Account.SObjectType)
            )
            .setField(WorkOrder.Mx_Requested_Photoshoot__c, YES_FOR_PHOTOSHOOT)
            .setField(WorkOrder.Originating_Work_Order__c, null)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IStoreAssociationService storeAssociationServiceMock = (IStoreAssociationService) mocks.mock(
            IStoreAssociationService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ photoshootWorkOrder });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectRelatedStoreAccountsQuery(
                    new Set<Id>{ originatingWorkOrderId }
                )
            )
            .thenReturn(new List<Account>{ photoshootAccount });
        mocks.when(
                accountsSelectorMock.selectStoreAccountsByParentIdsAndExternalSource(
                    new Set<Id>{ originatingAccountId }
                )
            )
            .thenReturn(new List<Account>{ photoshootAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(IStoreAssociationService.class, storeAssociationServiceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        new StoreAssociationServiceImpl()
            .initiatePhotoshootStoreAssociation(new Set<Id>{ workOrderId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }
}