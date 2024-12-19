/**
 * @author Deloitte
 * @date 04/03/2022
 * @description Test class used to cover LoggerEntry class.
 */
@isTest
private class LogEntryTest {
    /**
     * @description This method is used to test newLog method.
     */
    @isTest
    private static void testWhenLogEntryFromStringMessageThenCreateLog() {
        String message = 'This message used for testing log record';
        LogEntry entry = LogEntry.newLog(message);
        System.assertEquals(entry.message, message, 'Method not return expected message');
        System.assertEquals(
            LogEntry.SeverityLevel.LOW,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromStringMessageThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromStringMessageThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromStringMessageThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
    }

    /**
     * @description This method is used to test newLog method with severity.
     */
    @isTest
    private static void testWhenLogEntryFromStringMessageWithSeverityThenCreateLog() {
        String message = 'This message used for testing log record';
        LogEntry entry = LogEntry.newLog(message, LogEntry.SeverityLevel.HIGH);
        System.assertEquals(entry.message, message, 'Method not return expected message');
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromStringMessageWithSeverityThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromStringMessageWithSeverityThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromStringMessageWithSeverityThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
    }

    /**
     * @description This method is used to test newLog method with class name, method name, and message
     */
    @isTest
    private static void testWhenLogEntryFromClassNameMethodNameAndStringMessageThenCreateLog() {
        String message = 'This message used for testing log record';
        LogEntry entry = LogEntry.newLog('RandomClassName', 'RandomMethodName', message);
        System.assertEquals(entry.message, message, 'Method not return expected message');
        System.assertEquals(
            LogEntry.SeverityLevel.LOW,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'RandomClassName',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'RandomMethodName',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            String.isBlank(entry.stackTrace),
            'Did not receive the expected value in the stack trace. Received: ' + entry.stackTrace
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            String.isBlank(log.Stack_Trace__c),
            'Did not receive the expected value in the stack trace. Received: ' + entry.stackTrace
        );
    }

    /**
     * @description This method is used to test newLog method with class name, method name, message
     *              and service
     */
    @isTest
    private static void testWhenLogEntryFromClassNameMethodNameStringMessageAndServiceThenCreateLog() {
        String message = 'This is a sample message used for testing log record when providing a service';
        String serviceString = 'COO';
        String recordId = fflib_IDGenerator.generate(Account.SObjectType);
        LogEntry entry = LogEntry.newLog(
            'ClassNameTest',
            'MethodNameTest',
            message,
            serviceString,
            recordId
        );
        System.assertEquals(entry.message, message, 'Method not return expected message');
        System.assertEquals(
            LogEntry.SeverityLevel.LOW,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'ClassNameTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'MethodNameTest',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            serviceString,
            entry.service,
            'Method not return as expected service name'
        );
        System.assertEquals(recordId, entry.recordId, 'Method not return as expected record Id');
        System.assert(
            String.isBlank(entry.stackTrace),
            'Did not receive the expected value in the stack trace. Received: ' + entry.stackTrace
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assertEquals(
            entry.service,
            log.Service__c,
            'Method not return as expected service name'
        );
        System.assertEquals(
            entry.recordId,
            log.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assert(
            String.isBlank(log.Stack_Trace__c),
            'Did not receive the expected value in the stack trace. Received: ' + entry.stackTrace
        );
    }

    /**
     * @description This method is used to test newExceptionLog method.
     */
    @isTest
    static void testWhenLogEntryFromAnExceptionObjectThenCreateLog() {
        // Arrange
        Exception e = new DmlException('something went wrong!');
        // Act
        LogEntry entry = LogEntry.newExceptionLog(e);
        // Assert
        System.assertEquals(
            'System.DmlException',
            entry.logType,
            'Method not return as expected log type'
        );
        System.assertEquals(
            'something went wrong!',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromAnExceptionObjectThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            0,
            entry.failedRecordCount,
            'Method not return as expected failed record count'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromAnExceptionObjectThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromAnExceptionObjectThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            0,
            log.Failed_Record_Count__c,
            'Method not return as expected failed record count'
        );
    }

    /**
     * @description This method is used to test newExceptionLog method with severity.
     */
    @isTest
    static void testWhenLogEntryFromAnExceptionObjectWithSeverityLevelThenCreateLog() {
        // Arrange
        Exception e = new DmlException('something went wrong!');
        // Act
        LogEntry entry = LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.CRITICAL);
        // Assert
        System.assertEquals(
            'System.DmlException',
            entry.logType,
            'Method not return as expected log type'
        );
        System.assertEquals(
            'something went wrong!',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromAnExceptionObjectWithSeverityLevelThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            0,
            entry.failedRecordCount,
            'Method not return as expected failed record count'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromAnExceptionObjectWithSeverityLevelThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromAnExceptionObjectWithSeverityLevelThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            0,
            log.Failed_Record_Count__c,
            'Method not return as expected failed record count'
        );
    }

    /**
     * @description This method is used to test newExceptionLog method with severity and service
     */
    @isTest
    static void testWhenLogEntryFromAnExceptionObjectWithSeverityLevelAndServiceThenCreateLog() {
        String serviceString = 'COO';
        String recordId = fflib_IDGenerator.generate(Account.SObjectType);
        // Arrange
        Exception e = new DmlException('something went wrong!');
        // Act
        LogEntry entry = LogEntry.newExceptionLog(
            e,
            LogEntry.SeverityLevel.CRITICAL,
            serviceString,
            recordId
        );
        // Assert
        System.assertEquals(
            'System.DmlException',
            entry.logType,
            'Method not return as expected log type'
        );
        System.assertEquals(
            'something went wrong!',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(serviceString, entry.service, 'Method not return as expected service');
        System.assertEquals(recordId, entry.recordId, 'Method not return as expected record Id');
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromAnExceptionObjectWithSeverityLevelAndServiceThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            0,
            entry.failedRecordCount,
            'Method not return as expected failed record count'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogEntryFromAnExceptionObjectWithSeverityLevelAndServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(entry.service, log.Service__c, 'Method not return as expected service');
        System.assertEquals(
            entry.recordId,
            log.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogEntryFromAnExceptionObjectWithSeverityLevelAndServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            0,
            log.Failed_Record_Count__c,
            'Method not return as expected failed record count'
        );
    }

    /**
     * @description This method is used to test newBatchLog method with message.
     */
    @isTest
    private static void testWhenLogFromBatchApexThenCreateLog() {
        String message = 'This message used for testing log record';
        String batchJobId = 'Qwerty123';
        LogEntry entry = LogEntry.newBatchLog(message, batchJobId, LogEntry.SeverityLevel.HIGH);
        System.assertEquals('GENERIC_LOG', entry.logType, 'Method not return as expected log type');
        System.assertEquals(
            'This message used for testing log record',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogFromBatchApexThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            batchJobId,
            entry.batchJobId,
            'Method not return as expected batch job id'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogFromBatchApexThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogFromBatchApexThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            entry.batchJobId,
            log.Batch_Job_Id__c,
            'Method not return as expected batch job id'
        );
    }

    /**
     * @description This method is used to test newBatchLog method with message and service.
     */
    @isTest
    private static void testWhenLogFromBatchApexWithMessageAndServiceThenCreateLog() {
        String message = 'This message used for testing log record';
        String batchJobId = 'Qwerty123';
        String serviceString = 'COO';
        String recordId = fflib_IDGenerator.generate(Account.SObjectType);
        LogEntry entry = LogEntry.newBatchLog(
            message,
            batchJobId,
            LogEntry.SeverityLevel.HIGH,
            serviceString,
            recordId
        );
        System.assertEquals('GENERIC_LOG', entry.logType, 'Method not return as expected log type');
        System.assertEquals(
            'This message used for testing log record',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(serviceString, entry.service, 'Method not return as expected service');
        System.assertEquals(recordId, entry.recordId, 'Method not return as expected record Id');
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogFromBatchApexWithMessageAndServiceThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            batchJobId,
            entry.batchJobId,
            'Method not return as expected batch job id'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogFromBatchApexWithMessageAndServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(entry.service, log.Service__c, 'Method not return as expected service');
        System.assertEquals(
            entry.recordId,
            log.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogFromBatchApexWithMessageAndServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            entry.batchJobId,
            log.Batch_Job_Id__c,
            'Method not return as expected batch job id'
        );
    }

    /**
     * @description This method is used to test newBatchLog method with exception object.
     */
    @isTest
    private static void testWhenLogFromExceptionInBatchApexThenCreateLog() {
        Exception e = new DmlException('it stopped working :(');
        String batchJobId = 'Qwerty123';
        LogEntry entry = LogEntry.newBatchLog(e, batchJobId, LogEntry.SeverityLevel.CRITICAL);
        System.assertEquals(
            'System.DmlException',
            entry.logType,
            'Method not return as expected log type'
        );
        System.assertEquals(
            'it stopped working :(',
            entry.message,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL,
            entry.severity,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogFromExceptionInBatchApexThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assertEquals(
            batchJobId,
            entry.batchJobId,
            'Method not return as expected batch job id'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogFromExceptionInBatchApexThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogFromExceptionInBatchApexThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            entry.batchJobId,
            log.Batch_Job_Id__c,
            'Method not return as expected batch job id'
        );
    }

    /**
     * @description This method is used to test newCalloutLog method.
     */
    @isTest
    private static void testWhenLogEntryFromApexCalloutThenCreateLog() {
        String message = 'This message used for testing log record';
        String responseStatusCode = '404';
        String responseStatus = 'Error';
        String requestEndpoint = 'https://test.endpoint.com';
        LogEntry entry = LogEntry.newCalloutLog(
            message,
            responseStatus,
            responseStatusCode,
            requestEndpoint
        );
        System.assertEquals(
            entry.calloutResponseStatusCode,
            responseStatusCode,
            'Method not return expected  message'
        );
        System.assertEquals(
            entry.calloutResponseStatus,
            responseStatus,
            'Method not return expected  message'
        );
        System.assertEquals(
            entry.calloutRequestEndpoint,
            requestEndpoint,
            'Method not return expected  message'
        );
        System.assertEquals(entry.message, message, 'Method not return expected  message');
        System.assertEquals(
            entry.logType,
            'API_CALLOUT_EXCEPTION',
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.severity,
            LogEntry.SeverityLevel.LOW,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromApexCalloutThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromApexCalloutThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenlogEntryFromApexCalloutThencreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            entry.calloutResponseStatusCode,
            log.Callout_Status_Code__c,
            'Method not return as expected status code'
        );
        System.assertEquals(
            entry.calloutResponseStatus,
            log.Status__c,
            'Method not return as expected status'
        );
        System.assertEquals(
            entry.calloutRequestEndpoint,
            log.Callout_Request_Endpoint__c,
            'Method not return as expected request endpoint'
        );
    }

    /**
     * @description This method is used to test newCalloutLog method with service.
     */
    @isTest
    private static void testWhenLogEntryFromApexCalloutWithServiceThenCreateLog() {
        String message = 'This message used for testing log record with a service';
        String responseStatusCode = '404';
        String responseStatus = 'Error';
        String requestEndpoint = 'https://test.endpoint.com';
        String serviceString = 'COO';
        String recordId = fflib_IDGenerator.generate(Account.SObjectType);
        LogEntry entry = LogEntry.newCalloutLog(
            message,
            responseStatus,
            responseStatusCode,
            requestEndpoint,
            serviceString,
            recordId
        );
        System.assertEquals(
            responseStatusCode,
            entry.calloutResponseStatusCode,
            'Method not return expected response status code'
        );
        System.assertEquals(
            responseStatus,
            entry.calloutResponseStatus,
            'Method not return expected response status'
        );
        System.assertEquals(
            requestEndpoint,
            entry.calloutRequestEndpoint,
            'Method not return expected request endpoint'
        );
        System.assertEquals(serviceString, entry.service, 'Method not return expected  service');
        System.assertEquals(recordId, entry.recordId, 'Method not return as expected record Id');
        System.assertEquals(entry.message, message, 'Method not return expected  message');
        System.assertEquals(
            entry.logType,
            'API_CALLOUT_EXCEPTION',
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.severity,
            LogEntry.SeverityLevel.LOW,
            'Method not return as expected severity'
        );
        System.assertEquals(
            'LogEntryTest',
            entry.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogEntryFromApexCalloutWithServiceThenCreateLog',
            entry.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            entry.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogEntryFromApexCalloutWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c log = entry.toRecord();
        System.assertEquals(
            entry.logType,
            log.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            entry.message,
            log.Detailed_Message__c,
            'Method not return as expected message'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            log.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            entry.className,
            log.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            entry.methodName,
            log.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            log.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogEntryFromApexCalloutWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
        System.assertEquals(
            entry.calloutResponseStatusCode,
            log.Callout_Status_Code__c,
            'Method not return as expected status code'
        );
        System.assertEquals(
            entry.calloutResponseStatus,
            log.Status__c,
            'Method not return as expected status'
        );
        System.assertEquals(
            entry.calloutRequestEndpoint,
            log.Callout_Request_Endpoint__c,
            'Method not return as expected request endpoint'
        );
        System.assertEquals(entry.service, log.Service__c, 'Method not return as expected service');
        System.assertEquals(
            entry.recordId,
            log.Record_Id__c,
            'Method not return as expected record Id'
        );
    }

    /**
     * @description This method is used to test newDmlLog method.
     * This needs to have the Database.SaveResults, Database.UpdateResults, and Database.Delete results configured
     * to throw errors so the creation of the error log detail can be tested.  At the moment, all the DML completes
     * without errors.
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenLogsFromDmlResultsThenCreateLog() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestName1', Segment__c = 'SMB'));
        accounts.add(new Account(Name = ''));

        //insert
        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        LogEntry logEntryInsert = LogEntry.newDmlLog(
            saveResults,
            accounts,
            LogEntry.SeverityLevel.HIGH
        );
        System.assertEquals(
            logEntryInsert.severity,
            LogEntry.SeverityLevel.HIGH,
            'Method not return expected severity'
        );
        System.assertEquals(
            logEntryInsert.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryInsert.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsThenCreateLog',
            logEntryInsert.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryInsert.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c insertLog = logEntryInsert.toRecord();
        System.assertEquals(
            logEntryInsert.logType,
            insertLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH.name(),
            insertLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryInsert.className,
            insertLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryInsert.methodName,
            insertLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            insertLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //update
        accounts[0].Name = '';
        List<Database.SaveResult> updateResults = Database.update(accounts, false);
        LogEntry logEntryUpdate = LogEntry.newDmlLog(
            updateResults,
            accounts,
            LogEntry.SeverityLevel.CRITICAL
        );
        System.assertEquals(
            logEntryUpdate.severity,
            LogEntry.SeverityLevel.CRITICAL,
            'Method not return expected severity'
        );
        System.assertEquals(
            logEntryUpdate.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryUpdate.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsThenCreateLog',
            logEntryUpdate.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryUpdate.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c updateLog = logEntryUpdate.toRecord();
        System.assertEquals(
            logEntryUpdate.logType,
            updateLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL.name(),
            updateLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryUpdate.className,
            updateLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryUpdate.methodName,
            updateLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            updateLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //upsert
        accounts[0].Name = '';
        accounts.add(new Account(Name = 'TestName3'));
        List<Database.UpsertResult> upsertResults = Database.upsert(accounts, false);
        LogEntry logEntryUpsert = LogEntry.newDmlLog(
            upsertResults,
            accounts,
            LogEntry.SeverityLevel.LOW
        );
        System.assertEquals(
            logEntryUpsert.severity,
            LogEntry.SeverityLevel.LOW,
            'Method not return expected severity'
        );
        System.assertEquals(
            logEntryUpsert.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryUpsert.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsThenCreateLog',
            logEntryUpsert.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryUpsert.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c upsertLog = logEntryUpsert.toRecord();
        System.assertEquals(
            logEntryUpsert.logType,
            upsertLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            upsertLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryUpsert.className,
            upsertLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryUpsert.methodName,
            upsertLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            upsertLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //delete
        accounts.clear();
        accounts.add(new Account(Name = 'TestName1', Segment__c = 'SMB'));
        accounts.add(new Account(Name = 'TestName2', Segment__c = 'SMB'));
        Database.insert(accounts, false);
        List<Database.DeleteResult> deleteResults = Database.delete(accounts, false);
        LogEntry logEntryDelete = LogEntry.newDmlLog(
            deleteResults,
            accounts,
            LogEntry.SeverityLevel.MEDIUM
        );
        System.assertEquals(
            logEntryDelete.severity,
            LogEntry.SeverityLevel.MEDIUM,
            'Method not return expected severity'
        );
        System.assertEquals(
            logEntryDelete.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryDelete.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsThenCreateLog',
            logEntryDelete.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryDelete.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c deleteLog = logEntryDelete.toRecord();
        System.assertEquals(
            logEntryDelete.logType,
            deleteLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.MEDIUM.name(),
            deleteLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryDelete.className,
            deleteLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryDelete.methodName,
            deleteLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            deleteLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
    }

    /**
     * @description This method is used to test newDmlLog method with service
     * This needs to have the Database.SaveResults, Database.UpdateResults, and Database.Delete results configured
     * to throw errors so the creation of the error log detail can be tested.  At the moment, all the DML completes
     * without errors.
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenLogsFromDmlResultsWithServiceThenCreateLog() {
        String serviceString = 'COO';
        String accountId;
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestName1', Segment__c = 'SMB'));
        accounts.add(new Account(Name = ''));

        //insert
        List<Database.SaveResult> saveResults = Database.insert(accounts, false);
        accountId = saveResults.get(0).getId();
        LogEntry logEntryInsert = LogEntry.newDmlLog(
            saveResults,
            accounts,
            LogEntry.SeverityLevel.HIGH,
            serviceString
        );
        System.assertEquals(
            logEntryInsert.severity,
            LogEntry.SeverityLevel.HIGH,
            'Method not return expected severity'
        );
        System.assertEquals(
            serviceString,
            logEntryInsert.service,
            'Method not return expected service'
        );
        System.assertEquals(
            true,
            logEntryInsert.recordId?.startsWith(accountId),
            'Method not return an expected record Id'
        );
        System.assertEquals(
            logEntryInsert.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryInsert.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsWithServiceThenCreateLog',
            logEntryInsert.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryInsert.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c insertLog = logEntryInsert.toRecord();
        System.assertEquals(
            logEntryInsert.logType,
            insertLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.HIGH.name(),
            insertLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryInsert.service,
            insertLog.Service__c,
            'Method not return as expected service'
        );
        System.assertEquals(
            logEntryInsert.recordId,
            insertLog.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assertEquals(
            logEntryInsert.className,
            insertLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryInsert.methodName,
            insertLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            insertLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //update
        accounts[0].Name = '';
        List<Database.SaveResult> updateResults = Database.update(accounts, false);
        accountId = updateResults.get(0).getId();
        LogEntry logEntryUpdate = LogEntry.newDmlLog(
            updateResults,
            accounts,
            LogEntry.SeverityLevel.CRITICAL,
            serviceString
        );
        System.assertEquals(
            logEntryUpdate.severity,
            LogEntry.SeverityLevel.CRITICAL,
            'Method not return expected severity'
        );
        System.assertEquals(
            serviceString,
            logEntryUpdate.service,
            'Method not return expected service'
        );
        System.assertEquals(
            true,
            logEntryUpdate.recordId?.startsWith(accountId),
            'Method not return an expected record Id'
        );
        System.assertEquals(
            logEntryUpdate.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryUpdate.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsWithServiceThenCreateLog',
            logEntryUpdate.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryUpdate.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c updateLog = logEntryUpdate.toRecord();
        System.assertEquals(
            logEntryUpdate.logType,
            updateLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.CRITICAL.name(),
            updateLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryUpdate.service,
            updateLog.Service__c,
            'Method not return as expected service'
        );
        System.assertEquals(
            logEntryUpdate.recordId,
            updateLog.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assertEquals(
            logEntryUpdate.className,
            updateLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryUpdate.methodName,
            updateLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            updateLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //upsert
        accounts[0].Name = '';
        accounts.add(new Account(Name = 'TestName3'));
        List<Database.UpsertResult> upsertResults = Database.upsert(accounts, false);
        accountId = upsertResults.get(0).getId();
        LogEntry logEntryUpsert = LogEntry.newDmlLog(
            upsertResults,
            accounts,
            LogEntry.SeverityLevel.LOW,
            serviceString
        );
        System.assertEquals(
            logEntryUpsert.severity,
            LogEntry.SeverityLevel.LOW,
            'Method not return expected severity'
        );
        System.assertEquals(
            serviceString,
            logEntryUpsert.service,
            'Method not return expected service'
        );
        System.assertEquals(
            true,
            logEntryUpsert.recordId?.startsWith(accountId),
            'Method not return an expected record Id'
        );
        System.assertEquals(
            logEntryUpsert.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryUpsert.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsWithServiceThenCreateLog',
            logEntryUpsert.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryUpsert.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c upsertLog = logEntryUpsert.toRecord();
        System.assertEquals(
            logEntryUpsert.logType,
            upsertLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.LOW.name(),
            upsertLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryUpsert.service,
            upsertLog.Service__c,
            'Method not return as expected service'
        );
        System.assertEquals(
            logEntryUpsert.recordId,
            upsertLog.Record_Id__c,
            'Method not return as expected record Id'
        );
        System.assertEquals(
            logEntryUpsert.className,
            upsertLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryUpsert.methodName,
            upsertLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            upsertLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        //delete
        accounts.clear();
        accounts.add(new Account(Name = 'TestName1', Segment__c = 'SMB'));
        accounts.add(new Account(Name = 'TestName2', Segment__c = 'SMB'));
        Database.insert(accounts, false);
        List<Database.DeleteResult> deleteResults = Database.delete(accounts, false);
        LogEntry logEntryDelete = LogEntry.newDmlLog(
            deleteResults,
            accounts,
            LogEntry.SeverityLevel.MEDIUM,
            serviceString
        );
        System.assertEquals(
            logEntryDelete.severity,
            LogEntry.SeverityLevel.MEDIUM,
            'Method not return expected severity'
        );
        System.assertEquals(
            serviceString,
            logEntryDelete.service,
            'Method not return expected service'
        );
        System.assertEquals(
            logEntryDelete.logType,
            'DML_EXCEPTION',
            'Method not return expected log type'
        );
        System.assertEquals(
            'LogEntryTest',
            logEntryDelete.className,
            'Method not return as expected class name'
        );
        System.assertEquals(
            'testWhenLogsFromDmlResultsWithServiceThenCreateLog',
            logEntryDelete.methodName,
            'Method not return as expected method name'
        );
        System.assert(
            logEntryDelete.stackTrace.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );

        Log__c deleteLog = logEntryDelete.toRecord();
        System.assertEquals(
            logEntryDelete.logType,
            deleteLog.Log_Type__c,
            'Method not return as expected log type'
        );
        System.assertEquals(
            LogEntry.SeverityLevel.MEDIUM.name(),
            deleteLog.Severity_Level__c,
            'Method not return as expected severity'
        );
        System.assertEquals(
            logEntryDelete.service,
            deleteLog.Service__c,
            'Method not return as expected service'
        );
        System.assertEquals(
            logEntryDelete.className,
            deleteLog.Class_Name__c,
            'Method not return as expected class name'
        );
        System.assertEquals(
            logEntryDelete.methodName,
            deleteLog.Class_Method_Name__c,
            'Method not return as expected method name'
        );
        System.assert(
            deleteLog.Stack_Trace__c.containsIgnoreCase(
                'Class.LogEntryTest.testWhenLogsFromDmlResultsWithServiceThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
    }
}