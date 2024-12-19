/**
 * @author Deloitte
 * @date 12/09/2023
 * @description This is the test class for AccountUpdateForActiveRatesBatch class
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ActiveRatesProvisioningBatchTest {
    private static final String APPROVED = 'Approved';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String SCHEDULED_JOB_NAME = ActiveRatesProvisioningBatchTest.class
        .getName();
    private static final Date TODAY_DATE = System.today();
    @IsTest
    static void testWhenEffectiveRateChangesArePassedThenUpdateSubscriptionBatchIsCalled() {
        //ARRANGE
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);

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

        List<Rate_Change_Request__c> retrievedRateChanges = new List<Rate_Change_Request__c>{
            rateChangeRequest
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IRateChangeRequestSelector selectorMock = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );

        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.when(selectorMock.selectByEffectiveDateToday()).thenReturn(null);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        ActiveRatesProvisioningBatch batch = new ActiveRatesProvisioningBatch();
        batch.start(null);
        batch.execute(null, retrievedRateChanges);
        batch.finish(null);

        //ASSERT
        ((IRateChangeRequestSelector) mocks.verify(selectorMock, 1)).selectByEffectiveDateToday();
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
            new ActiveRatesProvisioningBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}