/**
 * @author Deloitte
 * @date 12/03/2024
 * @description Test class for NintexWorkOrdersProcessorServiceImpl class.
 * Suppressed Warnings since mock verify method is equivalent of system assert statement.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class HaltedSelfServeQuotesReprocessorServTest {
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
    private static final String STATUS_PENDING = 'Pending';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';

    /**
     * @description It is used to test whether the quotes are updated to Primary and Contract Signed
     * by the passed self-serve halted quotes.
     */
    @isTest
    private static void testWhenHaltedSelfServeQuotesPassedThenQuotesUpdatedToPrimaryAndContractSigned() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLog = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Id, ingestionLogId)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_SUCCESS)
            .toSObject();
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
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLog });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInboundIngestionLogsSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        HaltedSelfServeQuotesReprocessorService.initiateHaltedSelfServeQuotesReprocessing(
            new List<SBQQ__Quote__c>{ selfServeQuote }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test that quotes are not updated
     * by the passed non self-serve halted quotes.
     */
    @isTest
    private static void testWhenNonSelfServeQuotesPassedThenQuotesNotUpdated() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLog = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Id, ingestionLogId)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_PENDING)
            .toSObject();
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
            .setField(SBQQ__Quote__c.Unique_Identifier__c, null)
            .setField(SBQQ__Quote__c.CreatedDate, System.today().addDays(-3))
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, parentOpportunity.Id)
            .setParent('SBQQ__Opportunity2__r', opportunityFakeInstance)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLog });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInboundIngestionLogsSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        HaltedSelfServeQuotesReprocessorService.initiateHaltedSelfServeQuotesReprocessing(
            new List<SBQQ__Quote__c>{ selfServeQuote }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description It is used to test that exceptions are thrown or not when error occurs.
     */
    @isTest
    private static void testWhenErrorOccuredThenExceptionThrown() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        String exceptionMessage;
        Inbound_Ingestion_Log__c ingestionLog = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Id, ingestionLogId)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_SUCCESS)
            .toSObject();
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
            .setField(SBQQ__Quote__c.Unique_Identifier__c, null)
            .setField(SBQQ__Quote__c.CreatedDate, System.today().addDays(-3))
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, parentOpportunity.Id)
            .setParent('SBQQ__Opportunity2__r', opportunityFakeInstance)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLog });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockInboundIngestionLogsSelector);
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        try {
            HaltedSelfServeQuotesReprocessorService.initiateHaltedSelfServeQuotesReprocessing(
                new List<SBQQ__Quote__c>{ selfServeQuote }
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        Test.stopTest();
        System.assertEquals(MOCK_EXCEPTION_MESSAGE, exceptionMessage, ASSERTION_FAILED);
    }
}