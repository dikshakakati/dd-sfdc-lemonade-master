/**
 * @author Deloitte
 * @date 12/03/2024
 * @description Test class for ReprocessHaltedSelfServeQuotesBatch class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ReprocessHaltedSelfServeQuotesUnitTest {
    private static final String ASSERTION_FAILED = 'Unexpected Result: Batch did not execute successfully';
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String BATCH_NAME = 'ProcessChurnedMerchantRecordsScheduledBatch';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String NAME_ACCOUNT = 'Test Acc';
    private static final String NAME_OPPORTUNITY = 'Test Opportunity';
    private static final String STAGENAME_NEGOTIATING = 'Negotiating';
    private static final String STAGENAME_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_PROMOS = 'Ads & Promos';
    private static final String QUOTE_UNIQUE_IDENTIFIER = 'Mx Portal A&P 123';
    private static final String QUOTE_SOURCE = 'Mx Portal';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String STATUS_SUCCESS = 'Success';

    /**
     * @description It is used to test that halted self-serve quotes are retrieved in start method.
     */
    @isTest
    private static void testWhenStartMethodCalledThenHaltedSelfServeQuotesRetrieved() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuotesSelector.selectSelfServeHaltedQuotes()).thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockQuotesSelector);
        ReprocessHaltedSelfServeQuotesBatch batchInstance = new ReprocessHaltedSelfServeQuotesBatch();
        Test.startTest();
        batchInstance.start(null);
        Test.stopTest();
        ((IQuotesSelector) mocks.verify(mockQuotesSelector, 1)).selectSelfServeHaltedQuotes();
    }

    /**
     * @description To test quote reprocessing is initiated for the halted quotes
     * in execute method.
     */
    @isTest
    private static void testWhenHaltedSelfServeQuotesPassedToExecuteMethodThenQuoteReprocessingInitiated() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, NAME_OPPORTUNITY)
            .setField(Opportunity.StageName, STAGENAME_NEGOTIATING)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_ADS_PROMOS)
            .setField(Opportunity.Source__c, QUOTE_SOURCE)
            .setField(Opportunity.Ingestion_log_Id__c, ingestionLogId);
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSObject();
        SBQQ__Quote__c selfServeQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.ApprovalStatus__c, QUOTE_STATUS_APPROVED)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_APPROVED)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, false)
            .setField(SBQQ__Quote__c.SBQQ__Ordered__c, false)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, QUOTE_UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.CreatedDate, System.today().addDays(-3))
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, parentOpportunity.Id)
            .setParent('SBQQ__Opportunity2__r', opportunityFakeInstance)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHaltedSelfServeQuotesReprocessorService selfServeQuotesReprocessorServiceMock = (IHaltedSelfServeQuotesReprocessorService) mocks.mock(
            IHaltedSelfServeQuotesReprocessorService.class
        );
        mocks.startStubbing();
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IHaltedSelfServeQuotesReprocessorService.class,
            selfServeQuotesReprocessorServiceMock
        );
        ReprocessHaltedSelfServeQuotesBatch batchInstance = new ReprocessHaltedSelfServeQuotesBatch();
        Test.startTest();
        batchInstance.execute(null, new List<SBQQ__Quote__c>{ selfServeQuote });
        Test.stopTest();
        ((IHaltedSelfServeQuotesReprocessorService) mocks.verify(
                selfServeQuotesReprocessorServiceMock,
                1
            ))
            .initiateHaltedSelfServeQuotesReprocessing(new List<SBQQ__Quote__c>{ selfServeQuote });
    }
}