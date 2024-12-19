/**
 * @description : Test class used to cover Logger and LoggerImpl classes.
 * @author CriticalRiver
 * @date 10/2023
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class LoggerImplTest {

    /**
     * @description This method is used to test logging a single Exception.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSingleExceptionLogThenPublishLog() {
        Exception ex;
        ex = new DmlException('Something bad happened');
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(ex);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'System.DmlException',
                        Log__c.Detailed_Message__c => 'Something bad happened',
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test that the severity defaults to LOW
     * if severity level is null
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenExceptionLogProvidedSeverityLevelIsNullThenDefaultSeverityLevelToLow() {
        Exception ex;
        ex = new DmlException('Something bad happened');
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(ex, null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'System.DmlException',
                        Log__c.Detailed_Message__c => 'Something bad happened',
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging multiple Exceptions
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleExceptionLogsThenPublishLog() {
        Exception ex1 = new DmlException('Something bad happened');
        Exception ex2 = new DmlException('Something else bad happened');
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.add(ex1).add(ex2).publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'System.DmlException',
                        Log__c.Detailed_Message__c => 'Something bad happened',
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'System.DmlException',
                        Log__c.Detailed_Message__c => 'Something else bad happened',
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging a single Exception with a specific severity level
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleExceptionLogThenPublishLogs() {
        Exception ex;
        ex = new DmlException('Something bad happened');
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(ex, LogEntry.SeverityLevel.HIGH);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'System.DmlException',
                        Log__c.Detailed_Message__c => 'Something bad happened',
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging multiple ExceptionS with a specific severity levelS
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleExceptionLogsWithIndividualSeverityLevelsThenPublishLog() {
        Exception ex1 = new DmlException('Something bad happened');
        Exception ex2 = new DmlException('Something else bad happened');
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.add(ex1, LogEntry.SeverityLevel.MEDIUM)
            .add(ex2, LogEntry.SeverityLevel.CRITICAL)
            .publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => ex1.getTypeName(),
                        Log__c.Detailed_Message__c => ex1.getMessage(),
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.MEDIUM.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => ex2.getTypeName(),
                        Log__c.Detailed_Message__c => ex2.getMessage(),
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.CRITICAL.name(),
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging a single message
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSingleMessageLogThenPublishLog() {
        String message = 'Message passing to log record';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(message);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test that the Severity Level defaults to LOW when
     * the provided level is null
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvidedSeverityLevelIsNullThenDefaultSeverityLevelToLow() {
        String message = 'Message passing to log record';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(message, null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging multiple messages
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleMessageLogsThenPublishLog() {
        String message1 = 'Message passing to log record';
        String message2 = 'Second message to log record';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.add(message1).add(message2).publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message1,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message2,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging a single message
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSingleMessageLogWithSeverityLevelThenPublishLog() {
        String message = 'Message passing to log record';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish(message, LogEntry.SeverityLevel.MEDIUM);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.MEDIUM.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test logging multiple messages
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIndividualSeverityLevelsThenItShouldPublishMultipleMessageLogs() {
        String message1 = 'Message passing to log record';
        String message2 = 'Second message to log record';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.add(message1, LogEntry.SeverityLevel.HIGH)
            .add(message2, LogEntry.SeverityLevel.CRITICAL)
            .publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message1,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Detailed_Message__c => message2,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.CRITICAL.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test publishing a log when log entry is injected into Logger
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSingleLogEntryThenPublishLog() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String trace = 'Line 0: print "hello world"';
        LogEntry entry = new LogEntry(trace);
        Logger.publish(entry);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Stack_Trace__c => trace,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test publishing logs when multiple log entries are injected into Logger
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleLogEntriesThenPublishLog() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String trace1 = 'Line 0: print "hello world"';
        String trace2 = 'Line 1: print "hello kitty"';
        Logger.add(new LogEntry(trace1)).add(new LogEntry(trace2)).publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Stack_Trace__c => trace1,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Stack_Trace__c => trace2,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description This method is used to test publish method without any commit .
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBufferIsEmptyThenShouldNotPublishLogs() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Logger.publish();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never())).commitWork();
    }

    /**
     * @description Tests create work orders errors out and logged
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLoggedInCreateWorkOrdersErrorsThenLogGenericLog(){

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        String trace = 'WorkOrdersCreationServiceImpl.createWorkOrders:line 1';
        String message = 'Test trace for mock';
        LogEntry entry = new LogEntry(message,trace,LogEntry.SeverityLevel.LOW);
        Logger.publish(entry);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Stack_Trace__c => trace,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.LOW.name()
                    }
                )
            );


    }
}