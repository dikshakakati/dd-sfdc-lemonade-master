/**
 * @description       :
 * @author            : Aethereus
 * @group             :
 * @last modified on  : 05-06-2024
 * @last modified by  : Aethereus
**/
@isTest
public class ReadinessCheckFailureCleanupBatchTest {
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected result: Failed to trigger the batch.';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE = 'Please ensure Legal Business Name is populated.';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME = 'Legal_Business_Name__c';
    private static final String READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME = 'Account';

    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = ReadinessCheckFailureCleanupBatch.class
        .getName();

     /**
     * @description It is used to get the Readiness Check Failure Record.
     * Status is equal to Resolved and createddate less than week.
     * @JIRA# LEM-13963
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReadinessCheckFailureExistsThenDeleteOnBatchExecution() {

        List<Readiness_Check_Failure__c> readinessCheckFailuresList = new List<Readiness_Check_Failure__c>{
                new Readiness_Check_Failure__c(
                    Error_Message__c = READINESS_CHECK_BUSINESS_ACCOUNT_ERROR_MESSAGE,
                    Field_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_FIELD_NAME,
                    Object_Name__c = READINESS_CHECK_BUSINESS_ACCOUNT_OBJECT_NAME,
                    Status__c = 'Resolved'
                )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ReadinessCheckFailuresSelector readinessCheckFailuresSelectorSelectorMock = (ReadinessCheckFailuresSelector) mocks.mock(
            ReadinessCheckFailuresSelector.class
        );
        ISobjectDeletionService sObjectDeletionServiceMock = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        mocks.startStubbing();
        mocks.when(readinessCheckFailuresSelectorSelectorMock.sObjectType()).thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(readinessCheckFailuresSelectorSelectorMock.selectByReadinessCheckFailureId()).thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(readinessCheckFailuresSelectorSelectorMock);
        Application.SERVICE.setMock(ISobjectDeletionService.class, sObjectDeletionServiceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        ReadinessCheckFailureCleanupBatch internalReadinessCheckFailureCleanupBatch = new ReadinessCheckFailureCleanupBatch();
        internalReadinessCheckFailureCleanupBatch.start(null);
        internalReadinessCheckFailureCleanupBatch.execute(null, readinessCheckFailuresList);
        internalReadinessCheckFailureCleanupBatch.finish(null);
        ((ISobjectDeletionService) mocks.verify(sObjectDeletionServiceMock, 1))
            .fireRecordsDeletion(readinessCheckFailuresList);
    }

    /**
     * @description To validate that schedulable context schedules the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchScheduledThenBatchExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new ReadinessCheckFailureCleanupBatch()
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