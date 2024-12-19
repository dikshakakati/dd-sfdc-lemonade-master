/**
 * @author Deloitte
 * @date 07/08/2024
 * @description This is the test class for CreateRenewalOpportunityBatch class
 */
@isTest
public class CreateRenewalOpportunityBatchTest {
    private static final String RELATIONSHIP_STATUS_ACTIVE = 'Active';
    private static final String CRON_EXPRESSION = '0 0 0 ? * * *';
    private static final String SCHEDULED_JOB_NAME = AgreementsCreationBatch.class.getName();
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    /**
     * @description To test when account with partnership expiration date less than 90 days from today
     * recieved then run batch to create renewal opportunities.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenAccountWithPartnershipExpirationDateExistsThenRenewalOpportunityCreated() {
        Id ownerId = Fake.generateId(User.class);
        //ARRANGE DATA
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.Partnership_Expiration_Date__c, '2024-08-14')
            .setField(Account.CurrencyIsoCode, 'USD')
            .setField(Account.Total_Number_Of_Stores__c, 1)
            .setField(Account.OwnerId, ownerId)
            .setField(Account.Partnership_Level__c, 'Exclusive')
            .setField(Account.Renewal_Opportunity__c, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunitiesService serviceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.getAccountsForRunningRenewalBatch()).thenReturn(account1);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOpportunitiesService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        //ACT
        CreateRenewalOpportunityBatch batch = new CreateRenewalOpportunityBatch();
        batch.start(null);
        batch.execute(null, new List<Account>{ account1 });
        batch.finish(null);
        //ASSERT
        ((IOpportunitiesService) mocks.verify(serviceMock, 1))
            .createRenewalOpportunityFromBatch(new List<Account>{ account1 });
    }

    /**
     * @description To test when account with partnership expiration date less than 90 days from today
     * not recieved then renewal opportunities are not created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenAccountWithPartnershipExpirationDateNotPassedThenRenewalOpportunityNotCreated() {
        Id ownerId = Fake.generateId(User.class);
        //ARRANGE DATA
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.Partnership_Expiration_Date__c, '2024-08-14')
            .setField(Account.CurrencyIsoCode, 'USD')
            .setField(Account.Total_Number_Of_Stores__c, 1)
            .setField(Account.OwnerId, ownerId)
            .setField(Account.Partnership_Level__c, 'Exclusive')
            .setField(Account.Renewal_Opportunity__c, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunitiesService serviceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.getAccountsForRunningRenewalBatch()).thenReturn(account1);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IOpportunitiesService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        //ACT
        CreateRenewalOpportunityBatch batch = new CreateRenewalOpportunityBatch();
        batch.start(null);
        batch.execute(null, null);
        batch.finish(null);
        //ASSERT
        ((IOpportunitiesService) mocks.verify(serviceMock, 0))
            .createRenewalOpportunityFromBatch(new List<Account>{ account1 });
    }

    /**
     * @description To validate that schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchIsExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new CreateRenewalOpportunityBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(0, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}