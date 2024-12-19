/**
 * @author DoorDash
 * @date 04/18/2023
 * @description Test COOXrefsProcessingBatch class.
 */
@isTest
public class COOXrefsProcessingBatchTest {
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = COOXrefsProcessingBatch.class.getName();
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';

    /**
     * @description : test the batch execution
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefsProcessedViaBatchModeOrFailedThenReprocess() {
        //ARRANGE
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_Id__c, 'some Store')
            .setField(Xref__c.Coo_Process__c, 'Failed')
            .setFakeId()
            .toSObject();

        List<Xref__c> xrefRecords = new List<Xref__c>{ xref };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(
            IXrefsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectXrefsByCooProcess()).thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        IChangeOfOwnershipService cooMock = (IChangeOfOwnershipService) mocks.mock(
            IChangeOfOwnershipService.class
        );
        Application.SERVICE.setMock(IChangeOfOwnershipService.class, cooMock);

        //ACT
        COOXrefsProcessingBatch batch = new COOXrefsProcessingBatch();
        batch.start(null);
        batch.execute(null, xrefRecords);
        batch.finish(null);

        //ASSERT
        ((IXrefsSelector) mocks.verify(xrefsSelectorMock, 1)).selectXrefsByCooProcess();
        ((IChangeOfOwnershipService) mocks.verify(cooMock, 1))
            .getDriveStoreIdsForStores(xrefRecords);
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
            new COOXrefsProcessingBatch()
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