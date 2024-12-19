/**
 * @author Deloitte
 * @date 12/09/2023
 * @description This is the test class for AccountUpdateForActiveRatesBatch class
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class UpdateSubscriptionActiveRatesBatchTest {
    private static final String APPROVED = 'Approved';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String SCHEDULED_JOB_NAME = UpdateSubscriptionActiveRatesBatchTest.class
        .getName();
    private static final Date TODAY_DATE = System.today();
    @IsTest
    static void testWhenPassedListOfAccountsThenRateChangeRequestIdIsStamped() {
        //ARRANGE
        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);

        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        Rate_Change_Request__c rateChangeRequest = (Rate_Change_Request__c) new Fake(
                Rate_Change_Request__c.class
            )
            .setField(Rate_Change_Request__c.Contract__c, contractId)
            .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
            .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
            .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
            .setField(Rate_Change_Request__c.Status__c, APPROVED)
            .setFakeId()
            .toSObject();

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Delivery')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .toSObject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Pickup')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .toSObject()
        };

        Subscription_Rate_Change__c src1 = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeRequest.Id)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '53')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '43')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptions[0].Id)
            .setField(Subscription_Rate_Change__c.Update_complete__c, false)
            .setFakeId()
            .toSObject();

        Subscription_Rate_Change__c src2 = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeRequest.Id)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '34')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '54')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptions[1].Id)
            .setField(Subscription_Rate_Change__c.Update_complete__c, false)
            .setFakeId()
            .toSObject();

        List<Subscription_Rate_Change__c> retrievedSubscriptionRateChanges = new List<Subscription_Rate_Change__c>{
            src1,
            src2
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionRateChangeSelector selectorMock = (ISubscriptionRateChangeSelector) mocks.mock(
            ISubscriptionRateChangeSelector.class
        );

        ISubscriptionService serviceMock = (ISubscriptionService) mocks.mock(
            ISubscriptionService.class
        );

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscription_Rate_Change__c.SObjectType);
        mocks.when(selectorMock.selectByRateChangeIds(new Set<Id>{ rateChangeRequest.Id }))
            .thenReturn(null);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(ISubscriptionService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        UpdateSubscriptionActiveRatesBatch batch = new UpdateSubscriptionActiveRatesBatch(
            new Set<Id>{ rateChangeRequest.Id }
        );
        batch.start(null);
        batch.execute(null, retrievedSubscriptionRateChanges);
        batch.finish(null);

        //ASSERT
        ((ISubscriptionService) mocks.verify(serviceMock, 1))
            .updateSubscriptionActiveRatesFromSRC(retrievedSubscriptionRateChanges);
        ((ISubscriptionRateChangeSelector) mocks.verify(selectorMock, 1))
            .selectByRateChangeIds(new Set<Id>{ rateChangeRequest.Id });
    }
}