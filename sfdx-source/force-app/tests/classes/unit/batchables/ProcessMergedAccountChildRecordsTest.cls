/**
 * @author Deloitte
 * @date 28/11/2022
 * @description This is the test class for ProcessMergedAccountChildRecords class
 */
@isTest(SeeAllData=false)
private class ProcessMergedAccountChildRecordsTest {
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String SCHEDULABLE_JOB_ASSERT_MESSAGE = 'Unexpected result: Failed to scheduled batch job';
    private static final String WORK_ORDER_OBJECT_NAME = 'WorkOrder';
    private static final String WORK_STEP_OBJECT_NAME = 'WorkStep';
    private static final String STORE_RECORD_TYPE = 'Store';

    /**
     * @description This test method is used to test if respective service class methods are invoked for all child records.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountMergedThenProcessMergedAccountsRelatedRecords() {
        Id childAccountId = Fake.generateId(Account.class);
        List<Account> childAccounts = new List<Account>{ new Account(Id = childAccountId) };
        Id initiativeId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        List<Initiative__c> childInitiatives = new List<Initiative__c>{
            new Initiative__c(Id = initiativeId)
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> childOpportunities = new List<Opportunity>{
            new Opportunity(Id = opportunityId)
        };
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Payment_Account__c> childPaymentAccount = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId)
        };
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{ new WorkOrder(Id = workOrderId) };
        Id parentId = Fake.generateId(Account.class);
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, parentId)
            .setChildren(
                'ChildAccounts',
                new List<Fake>{ new Fake(Account.class).setField(Account.Id, childAccountId) }
            )
            .setChildren(
                'Initiatives__r',
                new List<Fake>{
                    new Fake(Initiative__c.class).setField(Initiative__c.Id, initiativeId)
                }
            )
            .setChildren(
                'Opportunities',
                new List<Fake>{
                    new Fake(Opportunity.class).setField(Opportunity.Id, opportunityId)
                }
            )
            .setChildren(
                'Payment_Accounts__r',
                new List<Fake>{
                    new Fake(Payment_Account__c.class)
                        .setField(Payment_Account__c.Id, paymentAccountId)
                }
            )
            .setChildren(
                'WorkOrders',
                new List<Fake>{ new Fake(WorkOrder.class).setField(WorkOrder.Id, workOrderId) }
            )
            .toSObject();
        List<Account> accountRecords = new List<Account>{ account1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountsService accountServiceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        IOpportunitiesService opportunityServiceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        IInitiativesService initiativeServiceMock = (IInitiativesService) mocks.mock(
            IInitiativesService.class
        );
        IPaymentAccountsService paymentAccountServiceMock = (IPaymentAccountsService) mocks.mock(
            IPaymentAccountsService.class
        );
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectRelatedChildRecordsByAccountsWithIsMergedEnabled())
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountServiceMock);
        Application.SERVICE.setMock(IOpportunitiesService.class, opportunityServiceMock);
        Application.SERVICE.setMock(IInitiativesService.class, initiativeServiceMock);
        Application.SERVICE.setMock(IPaymentAccountsService.class, paymentAccountServiceMock);
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        //ACT
        ProcessMergedAccountChildRecords batch = new ProcessMergedAccountChildRecords();
        batch.start(null);
        batch.execute(null, accountRecords);
        batch.finish(null);
        //ASSERT
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1))
            .selectRelatedChildRecordsByAccountsWithIsMergedEnabled();
        ((IAccountsService) mocks.verify(accountServiceMock, 1))
            .processMergedAccountsRelatedRecords(childAccounts);
        ((IAccountsService) mocks.verify(accountServiceMock, 1))
            .processMergedParentAccounts(new Set<Id>{ parentId });
        ((IOpportunitiesService) mocks.verify(opportunityServiceMock, 1))
            .processMergedAccountsRelatedRecords(childOpportunities);
        ((IInitiativesService) mocks.verify(initiativeServiceMock, 1))
            .processMergedAccountsRelatedRecords(childInitiatives);
        ((IPaymentAccountsService) mocks.verify(paymentAccountServiceMock, 1))
            .processMergedAccountsRelatedRecords(childPaymentAccount);
        ((IParentWorkOrderSyncService) mocks.verify(parentWorkOrderSyncServiceMock, 1))
            .processMergedAccountsRelatedRecords(childWorkOrders);
        ((IWorkOrdersService) mocks.verify(workOrdersServiceMock, 1))
            .processMergedAccountsRelatedRecords(childWorkOrders);
    }

    /**
     * @description To execute method with SchedulableContext.
     */
    @isTest
    private static void testWhenProcessMergedAccountChildRecordsExecutedInSchedulableContextThenBatchScheduled() {
        String cronExpression = '0 30 3 * * ?';
        Test.startTest();
        String scheduledJobId = System.schedule(
            ProcessMergedAccountChildRecordsTest.class.getName(),
            cronExpression,
            new ProcessMergedAccountChildRecords()
        );
        Test.stopTest();
        CronTrigger cronTriggerInstance = [
            SELECT Id, NextFireTime
            FROM CronTrigger
            WHERE Id = :scheduledJobId
        ];
        System.assertEquals(
            Time.newInstance(3, 30, 0, 0),
            cronTriggerInstance.NextFireTime.time(),
            SCHEDULABLE_JOB_ASSERT_MESSAGE
        );
    }

    /**
     * @description This test method is used to test if respective service class methods are invoked for all child records.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountMergedThenProcessMergedAccountsRelatedRecords() {
        Id childAccountId = Fake.generateId(Account.class);

        Id initiativeId = fflib_IDGenerator.generate(Initiative__c.SObjectType);
        List<Initiative__c> childInitiatives = new List<Initiative__c>{
            new Initiative__c(Id = initiativeId)
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> childOpportunities = new List<Opportunity>{
            new Opportunity(Id = opportunityId)
        };
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Payment_Account__c> childPaymentAccount = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId)
        };
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{ new WorkOrder(Id = workOrderId) };

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, childAccountId)
            .setField(Account.Record_Type_Name__c, STORE_RECORD_TYPE)
            .setChildren(
                'Initiatives__r',
                new List<Fake>{
                    new Fake(Initiative__c.class).setField(Initiative__c.Id, initiativeId)
                }
            )
            .setChildren(
                'Opportunities',
                new List<Fake>{
                    new Fake(Opportunity.class).setField(Opportunity.Id, opportunityId)
                }
            )
            .setChildren(
                'Payment_Accounts__r',
                new List<Fake>{
                    new Fake(Payment_Account__c.class)
                        .setField(Payment_Account__c.Id, paymentAccountId)
                }
            )
            .setChildren(
                'WorkOrders',
                new List<Fake>{ new Fake(WorkOrder.class).setField(WorkOrder.Id, workOrderId) }
            )
            .toSObject();
        List<Account> accountRecords = new List<Account>{ account1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountsService accountServiceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        IOpportunitiesService opportunityServiceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        IInitiativesService initiativeServiceMock = (IInitiativesService) mocks.mock(
            IInitiativesService.class
        );
        IPaymentAccountsService paymentAccountServiceMock = (IPaymentAccountsService) mocks.mock(
            IPaymentAccountsService.class
        );
        IParentWorkOrderSyncService parentWorkOrderSyncServiceMock = (IParentWorkOrderSyncService) mocks.mock(
            IParentWorkOrderSyncService.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectRelatedChildRecordsByAccountsWithIsMergedEnabled())
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, accountServiceMock);
        Application.SERVICE.setMock(IOpportunitiesService.class, opportunityServiceMock);
        Application.SERVICE.setMock(IInitiativesService.class, initiativeServiceMock);
        Application.SERVICE.setMock(IPaymentAccountsService.class, paymentAccountServiceMock);
        Application.SERVICE.setMock(
            IParentWorkOrderSyncService.class,
            parentWorkOrderSyncServiceMock
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        //ACT
        ProcessMergedAccountChildRecords batch = new ProcessMergedAccountChildRecords();
        batch.start(null);
        batch.execute(null, accountRecords);
        batch.finish(null);
        //ASSERT
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1))
            .selectRelatedChildRecordsByAccountsWithIsMergedEnabled();
    }
}