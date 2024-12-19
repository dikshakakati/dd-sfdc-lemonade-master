/**
 * @author Deloitte
 * @date 12/03/2024
 * @description This is the test class for ReprocessHaltedSelfServeQuotesBatch class
 */
@isTest(SeeAllData=false)
private class ReprocessHaltedSelfServeQuotesBatchTest {
    private static final String ASSERTION_FAILED = 'Unexpected Result: Batch did not execute successfully';
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String BATCH_NAME = 'ProcessChurnedMerchantRecordsScheduledBatch';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String NAME_ACCOUNT = 'Test Acc';
    private static final String NAME_OPPORTUNITY = 'Test Opportunity';
    private static final String NAME_ACCOUNT_CHILD = 'Test Acc Child';
    private static final String UNITED_STATES = 'United States';
    private static final String BILLING_STREET = '123 Test Street';
    private static final String BILLING_CITY = 'Missoula';
    private static final String BILLING_CITY2 = 'New York';
    private static final String BILLING_STATE = 'Montana';
    private static final String BILLING_CODE = '59801';
    private static final String BILLING_CODE2 = '59802';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRIMARY_VERTICAL = 'Rx';
    private static final String PRODUCT_CODE_10017 = '10017';
    private static final String STAGENAME_NEGOTIATING = 'Negotiating';
    private static final String STAGENAME_CLOSED_WON = 'Closed Won';
    private static final String DEAL_TYPE = 'Standard';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_PROMOS = 'Ads & Promos';
    private static final String QUOTE_UNIQUE_IDENTIFIER = 'Mx Portal A&P 123';
    private static final String QUOTE_SOURCE = 'Mx Portal';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String USERNAME_PROCESS_AUTOMATION = 'Process Automation User';

    /**
     * @description It is used to test whether the batch is scheduled or not for the given cron
     * expression.
     */
    @isTest
    private static void testWhenBatchIsScheduledThenAsyncJobCreated() {
        Test.startTest();
        String jobId = System.schedule(
            BATCH_NAME,
            CRON_EXPRESSION,
            new ReprocessHaltedSelfServeQuotesBatch()
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
            ASSERTION_FAILED
        );
    }
}