/**
 * @description : Test class used to cover Generic Logger Entry class.
 * @author CriticalRiver
 * @date 10/20/2023
 */
@isTest
private class GenericLogEntryTest {
    /**
     * @description This method is used to test Exception log creation.
     */
    @isTest
    private static void testWhenLogEntryFromAnExceptionObjectThenCreateLog() {
        String serviceName = 'serviceName';
        String domainName = 'domainName';
        GenericLogEntry logEntry = new GenericLogEntry(serviceName,domainName,GenericLogEntry.SeverityLevel.LOW);

        Exception e = new DmlException('something went wrong!');
        logEntry.logException(e);
        logEntry.convertToJSON();

        // Assert
        System.assertEquals(
            'System.DmlException',
            logEntry.logType,
            'Method not return as expected log type'
        );
        System.assert(
            logEntry.stackTrace.containsIgnoreCase(
                'Class.GenericLogEntryTest.testWhenLogEntryFromAnExceptionObjectThenCreateLog'
            ),
            'Did not receive the expected value in the stack trace'
        );
    }
    /**
     * @description This method is used to test DML Exception log creation
     */
    @isTest
    private static void testWhenLogEntryFromAnDMLExceptionThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
		// positive Test
        SObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        Database.SaveResult sr = (Database.SaveResult) JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
        logEntry.logDmlException( new List<Database.SaveResult>{ sr }, new List<SObject>{ sObj } );

        // Assert
        System.assertEquals(
            'DML_EXCEPTION',
            logEntry.logType,
            'Method not return as expected log type'
        );
		// Negative Test
        Database.SaveResult sr2 = (Database.SaveResult)
            JSON.deserialize('{"success":false,"id":"0013000000abcde","errors":[{"message":"You cannot do this","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);

        logEntry.logDmlException( new List<Database.SaveResult>{ sr2 }, new List<SObject>{ sObj } );
        logEntry.convertToJSON();

        // Assert
        System.assertNotEquals(
            NULL,
            logEntry.message,
            'Method not return as expected error message'
        );
    }
    /**
     * @description This method is used to test Batch log creation
     */
    @isTest
    private static void testWhenLogEntryFromABatchThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
        logEntry.logBatch( 'This message used for testing log record', 'Qwerty123' );

        // Assert
        System.assertEquals(
            'GENERIC_LOG',
            logEntry.logType,
            'Method not return as expected log type'
        );
    }
    /**
     * @description This method is used to test Log a message.
     */
    @isTest
    private static void testWhenLogEntryFromAMessageThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
        logEntry.logMessage(
            'This message used for testing log record'
        );

        // Assert
        System.assertEquals(
            logEntry.logType,
            'GENERIC_LOG',
            'Method not return as expected log type'
        );
    }
    
    /**
     * @description This method is used to test Log a message.
     */
    @isTest
    private static void testWhenLogEntryFromGovLimitsThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
        logEntry.logGovLimits(
            'This message used for testing log record', 'GenericLogEntry', 'logGovLimits'
        );

        // Assert
        System.assertEquals(
            logEntry.logType,
            'GENERIC_LOG',
            'Method not return as expected log type'
        );
    }
    /**
     * @description This method is used to test Log a message and failed Record Ids
     */
    @isTest
    private static void testWhenLogEntryFromAFailedRecordIdsThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
        logEntry.logSFRecordId( new Set<string>{ 'FakeStringTest1', 'FakeStringTest2', 'FakeStringTest3' } );

        // Assert
        System.assertEquals(
            logEntry.recordId.length(),
            52,
            'Method not return as expected recordId size'
        );
    }
    /**
     * @description This method is used to test Callout Log creation.
     */
    @isTest
    private static void testWhenLogEntryFromACallOutThenCreateLog() {
        GenericLogEntry logEntry = new GenericLogEntry('serviceName','domainName',NULL);
        logEntry.logCallout(
            'This message used for testing log record',
            '404',
            'Error',
            'https://test.endpoint.com' );

        // Assert
        System.assertEquals(
            logEntry.logType,
            'API_CALLOUT_EXCEPTION',
            'Method not return as expected log type'
        );
    }
}