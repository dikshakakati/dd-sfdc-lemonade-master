/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test Class for BulkOrderCreation Trigger
 */
@isTest
private class BulkOrderCreationTriggerTest {
    private static final String REFERENCE_ID_MISMATCH_ERROR = 'Bulk Order Creation Reference Id does not match';
    private static final String BULK_ORDER_REFERENCE_ID = '001555666777888';
    @isTest
    private static void testWhenBulkOrderCreationPlatformEventReceivedThenTriggerFires() {
        Bulk_Order_Creation__e bulkOrderPlatformEvent = new Bulk_Order_Creation__e();
        bulkOrderPlatformEvent.Bulk_Order_Reference_Id__c = BULK_ORDER_REFERENCE_ID;

        Test.startTest();
        EventBus.publish(bulkOrderPlatformEvent);
        Test.stopTest();

        System.assertEquals(
            BULK_ORDER_REFERENCE_ID,
            bulkOrderPlatformEvent.Bulk_Order_Reference_Id__c,
            REFERENCE_ID_MISMATCH_ERROR
        );
    }
}