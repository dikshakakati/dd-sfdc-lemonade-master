/**
 * @author DoorDash
 * @date 04/05/2024
 * @description Test MDSSyncEventsReProcessingBatch class.
 */
@isTest
public class MDSSyncEventsReProcessingBatchTest {
    private static final String CRON_EXPRESSION = '0 0 3 * * ?';
    private static final String SCHEDULED_JOB_NAME = MDSSyncEventsReProcessingBatch.class.getName();
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';

    /**
     * @description : test the batch execution
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIntegrationRequestsTriggeredViaBatchModeThenProcesses() {
        //ARRANGE
        Id intReqId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c intReq = (Integration_Request__c) new Fake(Integration_Request__c.class)
            .setField(Integration_Request__c.Id, intReqId)
            .toSObject();

        List<Integration_Request__c> intRecs = new List<Integration_Request__c>{ intReq };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IIntegrationRequestsSelector intRequestSelectorMock = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(intRequestSelectorMock.sObjectType()).thenReturn(Integration_Request__c.SObjectType);
        mocks.when(intRequestSelectorMock.selectFailedIntegrationRequestsForMdsStoreSync()).thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(intRequestSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        IMDSSyncEventsService mdsServiceMock = (IMDSSyncEventsService) mocks.mock(
            IMDSSyncEventsService.class
        );
        Application.SERVICE.setMock(IMDSSyncEventsService.class, mdsServiceMock);

        //ACT
        MDSSyncEventsReProcessingBatch batch = new MDSSyncEventsReProcessingBatch();
        batch.start(null);
        batch.execute(null, intRecs);
        batch.finish(null);

        //ASSERT
        ((IIntegrationRequestsSelector) mocks.verify(intRequestSelectorMock, 1)).selectFailedIntegrationRequestsForMdsStoreSync();
        ((IMDSSyncEventsService) mocks.verify(mdsServiceMock, 1))
            .processMDSUpdates(new Set<Id>{intReqId});
    }

    /**
     * @description To validate that schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchIsExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME+'_TEST',
            CRON_EXPRESSION,
            new MDSSyncEventsReProcessingBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(3, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}