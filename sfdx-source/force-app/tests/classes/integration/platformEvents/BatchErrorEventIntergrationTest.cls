/**
 * @author Deloitte
 * @date 26/05/2022
 * @description Test class used to cover BatchApexErrorEvents trigger class.
 */
@isTest
public class BatchErrorEventIntergrationTest {
    @isTest
    private static void testWhenBatchApexErrorEventPublishThenBatchApexErrorEventTriggerIsCalled() {
        BatchApexErrorEvent batchApex = new BatchApexErrorEvent(
            StackTrace = 'Class.BatchApexErrorEventTest.execute: line 35',
            Message = 'Test'
        );
        Test.startTest();
        EventBus.publish(batchApex);
        Test.stopTest();
        List<Log__c> logs = [SELECT Id, Detailed_Message__c FROM Log__c LIMIT 1];
        System.assertEquals(
            batchApex.StackTrace,
            logs[0].Detailed_Message__c,
            'Publish event failed'
        );
    }
}