/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for IngestionErrorHandlingServiceImpl class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class IngestionErrorHandlingServiceImplTest {
    private static final String SUCESS_STATUS = 'Mx Portal amendment is successful';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final string SOURCE_SSMO = 'SSMO';
    private static final String STATUS_FAILED = 'Failed';
    /*
     * @description It is used to test a ingestion log is update with success details.
     */
    @isTest
    private static void testWhenOnboardingCompletesThenUpdatesIngestionLogToSuccess() {
        Id mockIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = mockIngestionLogId,
            Source__c = 'Mx Portal'
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        IngestionErrorHandlingService.updateInboundIngestionLogForSuccess(
            ingestionLog,
            ' is successful'
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }
    /*
     * @description It is used to test a ingestion record is failed and send details to scaler.
     */
    @isTest
    private static void testWhenIngestionLogFailsThenSendDataToScalar() {
        Id mockIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = mockIngestionLogId,
            Source__c = 'Mx Portal',
            UUID__c = UNIQUE_IDENTIFER
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        IngestionErrorHandlingService.catchExceptionsOnGovernerLimits(
            'payloadDistributorForQuoteAndQuoteLine',
            new Map<String, String>{ 'testMethod' => '1' },
            ingestionLog,
            'MxPortalAmendmentServiceImpl'
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /*
     * @description It is used to test a ingestion log is updated with failure details incase of dml errors.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIngestionLogFailsThenUpdateFailureDetails() {
        Database.SaveResult inboundingestionlogerrors = (Database.SaveResult) JSON.deserialize(
            '{"success":false,"id":"0013000000abcde","errors":[{"message":"You cannot do this","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
            Database.SaveResult.class
        );

        Id mockIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = mockIngestionLogId,
            Source__c = 'Mx Portal',
            UUID__c = UNIQUE_IDENTIFER
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        APPLICATION.UNITOFWORK.setMOck(mockUOW);

        Test.startTest();
        IngestionErrorHandlingService.logSaveResultIngestionExceptionToInboundIngestionRecord(
            inboundingestionlogerrors,
            ingestionLog,
            'payloadDistributorForQuoteAndQuoteLine',
            new Map<String, String>{ 'payloadDistributorForQuoteAndQuoteLine' => '1' }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<sObjectField, Object>{
                        Inbound_Ingestion_Log__c.Status__c => STATUS_FAILED
                    }
                )
            );
    }
    /*
     * @description It is used to test a ingestion log is updated with failure details incase of uncaught exceptions.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIngestionLogFailsWithUncaughtExceptionThenUpdateFailureDetails() {
        Id mockIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = mockIngestionLogId,
            Source__c = 'Mx Portal',
            UUID__c = UNIQUE_IDENTIFER
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        APPLICATION.UNITOFWORK.setMOck(mockUOW);
        Test.startTest();
        IngestionErrorHandlingService.logUncaughtIngestionExceptionToInboundIngestionRecord(
            new dmlexception('Error in commitwork'),
            'payloadDistributorForQuoteAndQuoteLine',
            new Map<String, String>{ 'payloadDistributorForQuoteAndQuoteLine' => '1' },
            ingestionLog
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<sObjectField, Object>{
                        Inbound_Ingestion_Log__c.Status__c => STATUS_FAILED
                    }
                )
            );
    }
}