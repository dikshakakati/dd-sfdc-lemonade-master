/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Test class for InboundIngestionLoggerEntry class.
 */

@isTest(SeeAllData=false)
private class InboundIngestionLoggerEntryTest {
    private static final String ASSERT_MESSAGE_SERVICE_NAME_MISMATCH = 'Unexpected Error: Service name should match';
    private static final String ASSERT_MESSAGE_DOMAIN_NAME_MISMATCH = 'Unexpected Error: Domain name should match';
    private static final String ASSERT_MESSAGE_UUID_MISMATCH = 'Unexpected Error: UUID should match';
    private static final String ASSERT_MESSAGE_UUNIQUE_ID_MISMATCH = 'Unexpected Error: Unique Id should match';
    private static final String ASSERT_MESSAGE_LOG_ID_MISMATCH = 'Unexpected Error: Log Id should match';
    private static final String ASSERT_MESSAGE_LOG_STATUS_MISMATCH = 'Unexpected Error: Log Status should match';
    private static final String ASSERT_MESSAGE_STATUS_CODE_MISMATCH = 'Unexpected Error: Status code should match';
    private static final String ASSERT_MESSAGE_CATEGORY_MISMATCH = 'Unexpected Error: Category should match';
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE_MISMATCH = 'Unexpected Error: Exception message should match';
    private static final String ASSERT_MESSAGE_BUSINESS_ERROR_MESSAGE_MISMATCH = 'Unexpected Error: Business error message should match';
    private static final String ASSERT_MESSAGE_FAILED_RECORD_IDS_MISMATCH = 'Unexpected Error: Failed record IDs should match';
    private static final String ASSERT_MESSAGE_FAILED_STEPS_MISMATCH = 'Unexpected Error: Failed steps should match';
    private static final String ASSERT_MESSAGE_CLASS_NAME_MISMATCH = 'Unexpected Error: Class name should match';
    private static final String ASSERT_MESSAGE_METHOD_NAME_MISMATCH = 'Unexpected Error: Method name should match';
    private static final String ASSERT_MESSAGE_SUCCESS_MESSAGE_MISMATCH = 'Unexpected Error: Success message should match';
    private static final String ASSERT_MESSAGE_SEVERITY_MISMATCH = 'Unexpected Error: Severity should be LOW';
    private static final String ASSERT_MESSAGE_PUBLISH_ERROR = 'Error When Log Is Created Then Published';
    private static final String ASSERT_MESSAGE_GOVN_LIMITS_EXCEEDED_ERROR = 'Unexpected Error: Salesforce Governer Limits Exceeded';
    private static final String CPU_LIMIT_EXCEEDED_ERROR = 'Salesforce Governor Limit - Apex CPU time limit exceeded';
    private static final String GOVN_LIMIT_EXCEEDED = 'Governor Limit Exceeded';
    private static final String SALESFORCE_GOVN_LIMITS = 'Salesforce Governor Limits';
    private static final String TEST_SERVICE = 'TestService';
    private static final String TEST_DOMAIN = 'TestDomain';
    private static final String TEST_UUID = 'a192876c-595d-4891-87d8-3d8c931d9f82';
    private static final String TEST_UNIQUEID = 'TestUniqueId';
    private static final String TEST_ERROR_CATEGORY = 'Error Category';
    private static final String TEST_EXCEPTION = 'Text Exception';
    private static final String TEST_BUSINESS_ERROR_MESSAGE = 'Test Business Error Message';
    private static final String TEST_FAILED_STEP = 'Step 1';
    private static final String TEST_CLASS = 'Test Class';
    private static final String TEST_METHOD = 'Test Method';
    private static final String FAILED = 'Failed';
    private static final String SUCCESS = 'Success';
    private static final String TEST_SUCCESS_MESSAGE = 'Test Success Message';
    private static final String ERROR_CODE = '500';
    private static final String SUCCESS_CODE = '200';

    /**
     * @description This method is used to test creation of Log message.
     */
    @IsTest
    static void testWhenCreateInboundIngestionLoggerCalledThenInboundIngestionLogCreated() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry(
            TEST_SERVICE,
            TEST_DOMAIN,
            String.valueOf(inboundIngestionLogId),
            TEST_UUID,
            TEST_UNIQUEID
        );

        System.assertEquals(
            TEST_SERVICE,
            loggerEntry.serviceName,
            ASSERT_MESSAGE_SERVICE_NAME_MISMATCH
        );
        System.assertEquals(
            TEST_DOMAIN,
            loggerEntry.domainName,
            ASSERT_MESSAGE_DOMAIN_NAME_MISMATCH
        );
        System.assertEquals(
            String.valueOf(inboundIngestionLogId),
            loggerEntry.inboundIngestionLogId,
            ASSERT_MESSAGE_LOG_ID_MISMATCH
        );
        System.assertEquals(TEST_UUID, loggerEntry.uuid, ASSERT_MESSAGE_UUID_MISMATCH);
        System.assertEquals(
            TEST_UNIQUEID,
            loggerEntry.uniqueId,
            ASSERT_MESSAGE_UUNIQUE_ID_MISMATCH
        );
    }

    /**
     * @description This method is used to test logging of exception message.
     */
    @IsTest
    static void testWhenLogExceptionThenExceptionLogged() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry();
        Set<String> sfRecordIds = new Set<String>{ inboundIngestionLogId };
        loggerEntry.logException(
            new DmlException(TEST_EXCEPTION),
            TEST_BUSINESS_ERROR_MESSAGE,
            TEST_FAILED_STEP,
            sfRecordIds,
            TEST_ERROR_CATEGORY
        );
        GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
        System.assertEquals(
            ERROR_CODE,
            loggerEntry.statusCode,
            ASSERT_MESSAGE_STATUS_CODE_MISMATCH
        );
        System.assertEquals(
            TEST_ERROR_CATEGORY,
            loggerEntry.category,
            ASSERT_MESSAGE_CATEGORY_MISMATCH
        );
        System.assertEquals(FAILED, loggerEntry.log.Status__c, ASSERT_MESSAGE_LOG_STATUS_MISMATCH);
        System.assertEquals(
            TEST_EXCEPTION,
            loggerEntry.log.Exception_Message__c,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE_MISMATCH
        );
        System.assertEquals(
            TEST_BUSINESS_ERROR_MESSAGE,
            loggerEntry.log.Business_Error_Message__c,
            ASSERT_MESSAGE_BUSINESS_ERROR_MESSAGE_MISMATCH
        );
        System.assertEquals(
            inboundIngestionLogId,
            loggerEntry.log.Failed_Record_Id__c,
            ASSERT_MESSAGE_FAILED_RECORD_IDS_MISMATCH
        );
        System.assertEquals(
            TEST_FAILED_STEP,
            loggerEntry.log.Failed_Steps__c,
            ASSERT_MESSAGE_FAILED_STEPS_MISMATCH
        );
    }

    /**
     * @description This method is used to test logging of governer limits.
     */
    @IsTest
    static void testWhenLogGovtLimitExceptionCalledThenGovLimitsExceptionLogged() {
        InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry();
        loggerEntry.logGovtLimitException(
            GOVN_LIMIT_EXCEEDED,
            TEST_FAILED_STEP,
            TEST_CLASS,
            TEST_METHOD
        );
        GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
        System.assertEquals(
            ERROR_CODE,
            loggerEntry.statusCode,
            ASSERT_MESSAGE_STATUS_CODE_MISMATCH
        );
        System.assertEquals(
            SALESFORCE_GOVN_LIMITS,
            loggerEntry.category,
            ASSERT_MESSAGE_CATEGORY_MISMATCH
        );
        System.assertEquals(FAILED, loggerEntry.log.Status__c, ASSERT_MESSAGE_LOG_STATUS_MISMATCH);
        System.assertEquals(
            GOVN_LIMIT_EXCEEDED,
            loggerEntry.log.Exception_Message__c,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE_MISMATCH
        );
        System.assertEquals(TEST_CLASS, loggerEntry.className, ASSERT_MESSAGE_CLASS_NAME_MISMATCH);
        System.assertEquals(
            TEST_METHOD,
            loggerEntry.methodName,
            ASSERT_MESSAGE_METHOD_NAME_MISMATCH
        );
    }

    /**
     * @description This method is used to test logging of success message.
     */
    @IsTest
    static void testWhenLogSuccessCalledThenSuccessMessageLogged() {
        InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry();
        loggerEntry.logSuccess(TEST_SUCCESS_MESSAGE);
        GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
        System.assertEquals(
            SUCCESS_CODE,
            loggerEntry.statusCode,
            ASSERT_MESSAGE_STATUS_CODE_MISMATCH
        );
        System.assertEquals(
            GenericLogEntry.SeverityLevel.LOW,
            loggerEntry.severity,
            ASSERT_MESSAGE_SEVERITY_MISMATCH
        );
        System.assertEquals(SUCCESS, loggerEntry.log.Status__c, ASSERT_MESSAGE_LOG_STATUS_MISMATCH);
        System.assertEquals(
            TEST_SUCCESS_MESSAGE,
            loggerEntry.log.Success_Message__c,
            ASSERT_MESSAGE_SUCCESS_MESSAGE_MISMATCH
        );
    }

    /**
     * @description This method is used to test if any error occured due to governer limits.
     */
    @IsTest
    static void testWhenErrorOnGovtLimitsExceededThenReturnError() {
        Test.startTest();
        // Exceed CPU time limit
        try {
            Integer sum = 0;
            while (Limits.getCpuTime() < Limits.getLimitCpuTime()) {
                sum += 1;
            }
        } catch (Exception e) {
            String errorMessage = InboundIngestionLoggerEntry.errorOnGovtLimitsExceeded();
            System.assertEquals(
                CPU_LIMIT_EXCEEDED_ERROR,
                errorMessage,
                ASSERT_MESSAGE_GOVN_LIMITS_EXCEEDED_ERROR
            );
        }

        Test.stopTest();
    }

    /**
     * @description This method is used to test when any error occured then the Log is Published or not.
     */
    @IsTest
    static void testWhenPublishCalledAndErrorOccuredThenLogPublished() {
        fflib_ApexMocks.ApexMocksException mockException;
        try {
            Id inboundIngestionLogId = fflib_IDGenerator.generate(
                Inbound_Ingestion_Log__c.SObjectType
            );
            Set<String> sfRecordIds = new Set<String>{ inboundIngestionLogId };
            InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry(
                TEST_SERVICE,
                TEST_DOMAIN,
                String.valueOf(inboundIngestionLogId),
                TEST_UUID,
                TEST_UNIQUEID
            );
            loggerEntry.logException(
                new DmlException(TEST_EXCEPTION),
                TEST_BUSINESS_ERROR_MESSAGE,
                TEST_FAILED_STEP,
                sfRecordIds,
                TEST_ERROR_CATEGORY
            );
            Test.startTest();
            GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
            Test.stopTest();
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, ASSERT_MESSAGE_PUBLISH_ERROR);
    }

    /**
     * @description This method is used to test when any error related to Governer limits
     * occured then the Log is Published or not.
     */
    @IsTest
    static void testWhenPublishCalledAndGovLimitsErrorOccurredThenLogPublished() {
        fflib_ApexMocks.ApexMocksException mockException;
        try {
            Id inboundIngestionLogId = fflib_IDGenerator.generate(
                Inbound_Ingestion_Log__c.SObjectType
            );
            Set<String> sfRecordIds = new Set<String>{ inboundIngestionLogId };
            InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry(
                TEST_SERVICE,
                TEST_DOMAIN,
                String.valueOf(inboundIngestionLogId),
                TEST_UUID,
                TEST_UNIQUEID
            );
            loggerEntry.logException(
                new DmlException(TEST_EXCEPTION),
                TEST_BUSINESS_ERROR_MESSAGE,
                TEST_FAILED_STEP,
                sfRecordIds,
                SALESFORCE_GOVN_LIMITS
            );
            Test.startTest();
            GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
            Test.stopTest();
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, ASSERT_MESSAGE_PUBLISH_ERROR);
    }

    /**
     * @description This method is used to test when success then the Log is Published or not.
     */
    @IsTest
    static void testWhenPublishCalledAndSuccessThenLogPublished() {
        fflib_ApexMocks.ApexMocksException mockException;
        try {
            Id inboundIngestionLogId = fflib_IDGenerator.generate(
                Inbound_Ingestion_Log__c.SObjectType
            );
            InboundIngestionLoggerEntry loggerEntry = new InboundIngestionLoggerEntry(
                TEST_SERVICE,
                TEST_DOMAIN,
                String.valueOf(inboundIngestionLogId),
                TEST_UUID,
                TEST_UNIQUEID
            );
            loggerEntry.logSuccess(TEST_SUCCESS_MESSAGE);
            Test.startTest();
            GenericLoggerService.publish(loggerEntry.createGenericLogEntry());
            Test.stopTest();
        } catch (fflib_ApexMocks.ApexMocksException ex) {
            mockException = ex;
        }
        System.assertEquals(null, mockException, ASSERT_MESSAGE_PUBLISH_ERROR);
    }
}