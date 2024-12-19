/**
 * @description Test class for OrderProtocolUpdatesServiceImpl.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class OrderProtocolUpdatesServiceImplTest {
    private static final string OP_PHONE = 'Phone';
    private static final string OP_EMAIL = 'Email';
    private static final string OP_POS = 'POS';
    private static final string OP_TABLET = 'Tablet';
    private static final String DEAD_STATUS = 'Dead';

    @isTest
    public static void testWhenOrderProtocolChangedToPhoneThenUpdateWoAndWp() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId)
            .setField(Account.Order_Protocol__c,OP_PHONE)
            .toSObject();
        WorkOrder mockChildWo = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWoId)
            .setField(WorkOrder.Status, 'At Risk')
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Order_Protocol__c, OP_EMAIL)
            .setField(WorkOrder.ParentWorkOrderId, parentWoId)
            .setParent(
                'ParentWorkOrder',
                 new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWoId)
                    .setField(WorkOrder.Status, 'At Risk')
                    .setField(WorkOrder.Actual_Number_Of_Stores__c, 1)
            )
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Order_Protocol__c, OP_EMAIL)
            )
            .toSObject();
        Map<Id, Account> accountMap = new Map<Id, Account>{accountId => newAccount};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IWorkOrdersSelector woSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.when(woSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            woSelectorMock.selectInProgressWorkOrdersWithParentDetailsByAccountIds(accountMap.keyset())
            )
            .thenReturn(new List<WorkOrder>{mockChildWo});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(woSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IReevaluateWorkPlansOnWorkOrderService wpReEvaluateSvc = (IReevaluateWorkPlansOnWorkOrderService) mocks.mock(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IReevaluateWorkPlansOnWorkOrderService.class, wpReEvaluateSvc);

        Test.startTest();
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => childWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => parentWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );

        ((IReevaluateWorkPlansOnWorkOrderService) mocks.verify(wpReEvaluateSvc, 1))
            .reevaluateWorkPlans(parentWoId);
    }

    @isTest
    public static void testWhenOrderProtocolChangedOnMorethanOneWoToPhoneThenUpdateWoAndWp() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWoId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWoId2 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId)
            .setField(Account.Order_Protocol__c,OP_PHONE)
            .toSObject();
        WorkOrder mockChildWo = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWoId1)
            .setField(WorkOrder.Status, 'At Risk')
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Order_Protocol__c, OP_EMAIL)
            .setField(WorkOrder.ParentWorkOrderId, parentWoId)
            .setParent(
                'ParentWorkOrder',
                 new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWoId)
                    .setField(WorkOrder.Status, 'At Risk')
                    .setField(WorkOrder.Actual_Number_Of_Stores__c, 2)
            )
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Order_Protocol__c, OP_EMAIL)
            )
            .toSObject();
        WorkOrder childWo2 = new WorkOrder(Id = childWoId2);
        Map<Id, Account> accountMap = new Map<Id, Account>{accountId => newAccount};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IWorkOrdersSelector woSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.when(woSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            woSelectorMock.selectInProgressWorkOrdersWithParentDetailsByAccountIds(accountMap.keyset())
            )
            .thenReturn(new List<WorkOrder>{mockChildWo});
        mocks.when(
            woSelectorMock.selectAllChildWosByOrderProtocol(parentWoId, OP_PHONE)
            )
            .thenReturn(new List<WorkOrder>{childWo2});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(woSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IReevaluateWorkPlansOnWorkOrderService wpReEvaluateSvc = (IReevaluateWorkPlansOnWorkOrderService) mocks.mock(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IReevaluateWorkPlansOnWorkOrderService.class, wpReEvaluateSvc);

        Test.startTest();
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => childWoId1,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => parentWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );

        ((IReevaluateWorkPlansOnWorkOrderService) mocks.verify(wpReEvaluateSvc, 1))
            .reevaluateWorkPlans(parentWoId);
    }

    @isTest
    public static void testWhenOrderProtocolChangedOnMorethanOneWoToPhoneThenNoParentWoUpdate() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWoId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId)
            .setField(Account.Order_Protocol__c,OP_PHONE)
            .toSObject();
        WorkOrder mockChildWo = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWoId1)
            .setField(WorkOrder.Status, 'At Risk')
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Order_Protocol__c, OP_EMAIL)
            .setField(WorkOrder.ParentWorkOrderId, parentWoId)
            .setParent(
                'ParentWorkOrder',
                 new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWoId)
                    .setField(WorkOrder.Status, 'At Risk')
                    .setField(WorkOrder.Actual_Number_Of_Stores__c, 2)
            )
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Order_Protocol__c, OP_EMAIL)
            )
            .toSObject();

        Map<Id, Account> accountMap = new Map<Id, Account>{accountId => newAccount};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IWorkOrdersSelector woSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.when(woSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            woSelectorMock.selectInProgressWorkOrdersWithParentDetailsByAccountIds(accountMap.keyset())
            )
            .thenReturn(new List<WorkOrder>{mockChildWo});
        mocks.when(
            woSelectorMock.selectAllChildWosByOrderProtocol(parentWoId, OP_PHONE)
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(woSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IReevaluateWorkPlansOnWorkOrderService wpReEvaluateSvc = (IReevaluateWorkPlansOnWorkOrderService) mocks.mock(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IReevaluateWorkPlansOnWorkOrderService.class, wpReEvaluateSvc);

        Test.startTest();
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => childWoId1,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        //Reevaluate WP service shouldn't be invoked
        ((IReevaluateWorkPlansOnWorkOrderService) mocks.verify(wpReEvaluateSvc, 0))
            .reevaluateWorkPlans(parentWoId);
    }

    @isTest
    public static void testWhenOrderProtocolChangedToPhoneThenUpdateWoAndWpByInvokingSvc() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId)
            .setField(Account.Order_Protocol__c,OP_PHONE)
            .toSObject();
        WorkOrder mockChildWo = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWoId)
            .setField(WorkOrder.Status, 'At Risk')
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Order_Protocol__c, OP_EMAIL)
            .setField(WorkOrder.ParentWorkOrderId, parentWoId)
            .setParent(
                'ParentWorkOrder',
                 new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWoId)
                    .setField(WorkOrder.Status, 'At Risk')
                    .setField(WorkOrder.Actual_Number_Of_Stores__c, 1)
            )
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Order_Protocol__c, OP_EMAIL)
            )
            .toSObject();
        Map<Id, Account> accountMap = new Map<Id, Account>{accountId => newAccount};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IWorkOrdersSelector woSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.when(woSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            woSelectorMock.selectInProgressWorkOrdersWithParentDetailsByAccountIds(accountMap.keyset())
            )
            .thenReturn(new List<WorkOrder>{mockChildWo});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(woSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);



        Test.startTest();
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
        Test.stopTest();

        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => childWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => parentWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
    }

    @isTest
    public static void testWhenOrderProtocolChangedFromPosAndTabletToPhoneThenUpdateWoAndWs() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWoId1 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWoId2 = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId)
            .setField(Account.Order_Protocol__c,OP_PHONE)
            .toSObject();
        WorkOrder mockChildWo = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWoId1)
            .setField(WorkOrder.Status, 'At Risk')
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Order_Protocol__c, OP_POS+' And'+OP_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWoId)
            .setParent(
                'ParentWorkOrder',
                 new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWoId)
                    .setField(WorkOrder.Status, 'At Risk')
                    .setField(WorkOrder.Actual_Number_Of_Stores__c, 2)
            )
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, accountId)
            )
            .toSObject();
        WorkOrder childWo2 = new WorkOrder(Id = childWoId2);

        Id workStepPosId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepTabletId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        WorkStep posWs = new WorkStep(Id = workStepPosId);
        WorkStep tabletWs = new WorkStep(Id = workStepTabletId);

        Map<Id, Account> accountMap = new Map<Id, Account>{accountId => newAccount};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();

        IWorkOrdersSelector woSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsSelector wsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.when(woSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
            woSelectorMock.selectInProgressWorkOrdersWithParentDetailsByAccountIds(accountMap.keyset())
            )
            .thenReturn(new List<WorkOrder>{mockChildWo});
        mocks.when(
            woSelectorMock.selectAllChildWosByOrderProtocol(parentWoId, OP_PHONE)
            )
            .thenReturn(new List<WorkOrder>{childWo2});

        mocks.when(wsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
            wsSelectorMock.selectWorkStepsByParentWorkOrderAndPlanName(parentWoId, new List<String>{OP_POS, OP_TABLET})
            )
            .thenReturn(new List<WorkStep>{posWs, tabletWs});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(woSelectorMock);
        Application.SELECTOR.setMock(wsSelectorMock);

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IReevaluateWorkPlansOnWorkOrderService wpReEvaluateSvc = (IReevaluateWorkPlansOnWorkOrderService) mocks.mock(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IReevaluateWorkPlansOnWorkOrderService.class, wpReEvaluateSvc);

        Test.startTest();
        OrderProtocolUpdatesService.processOrderProtocolUpdatesOnStoreAccounts(accountMap);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => childWoId1,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkOrder.Id => parentWoId,
                WorkOrder.Order_Protocol__c => OP_PHONE
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkStep.Id => workStepPosId,
                WorkStep.Status__c => DEAD_STATUS
            }
        ) );
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerDirty( fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
                WorkStep.Id => workStepTabletId,
                WorkStep.Status__c => DEAD_STATUS
            }
        ) );

        ((IReevaluateWorkPlansOnWorkOrderService) mocks.verify(wpReEvaluateSvc, 1))
            .reevaluateWorkPlans(parentWoId);
    }
}