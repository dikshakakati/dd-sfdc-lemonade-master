/**
 * @author Deloitte
 * @date 05/22/2024
 * @description Test class for RegisterEmailHelper class.
 */
@isTest(seeAllData=false)
private class RegisterEmailHelperTest {
    private static final String DO_WORK_ASSERT_MESSAGE = 'Unexpected result: failed to send email using Messaging.sendEmail method';
    private static final String EMAIL_SUBJECT = 'Mock Subject';
    private static final String EMAIL_TO_ADDRESS = 'MockAddress@RegisterEmailHelperTest.com';
    private static final String REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE = 'Unexpected result: failed to register a list of records';
    private static final String REGISTER_NULL_LIST_ASSERT_MESSAGE = 'Unexpected result: null list registered successfully';
    private static final String REGISTER_SINGLE_RECORD_ASSERT_MESSAGE = 'Unexpected result: failed to register a single record';

    /**
     * @description To test registerSingleEmailMessage() method for a single Messaging.SingleEmailMessage record.
     */
    @isTest
    private static void testWhenRegisterSingleEmailMessageWithSingleRecordCalledThenEmailListUpdated() {
        Messaging.SingleEmailMessage mockSingleEmailMessage = new Messaging.SingleEmailMessage();
        mockSingleEmailMessage.setSubject(EMAIL_SUBJECT);
        RegisterEmailHelper registerEmailHelperInstance = new RegisterEmailHelper();
        Test.startTest();
        registerEmailHelperInstance.registerSingleEmailMessage(mockSingleEmailMessage);
        Test.stopTest();
        System.assertEquals(
            1,
            registerEmailHelperInstance.singleEmailMessagesToSend.size(),
            REGISTER_SINGLE_RECORD_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerSingleEmailMessage() method for a list of Messaging.SingleEmailMessage record.
     */
    @isTest
    private static void testWhenRegisterSingleEmailMessageWithMultipleRecordsCalledThenEmailListUpdated() {
        Messaging.SingleEmailMessage mockSingleEmailMessage = new Messaging.SingleEmailMessage();
        mockSingleEmailMessage.setSubject(EMAIL_SUBJECT);
        Messaging.SingleEmailMessage mockMxSingleEmailMessage = new Messaging.SingleEmailMessage();
        mockMxSingleEmailMessage.setSubject(EMAIL_SUBJECT);
        RegisterEmailHelper registerEmailHelperInstance = new RegisterEmailHelper();
        Test.startTest();
        registerEmailHelperInstance.registerSingleEmailMessage(
            new List<Messaging.SingleEmailMessage>{
                mockSingleEmailMessage,
                mockMxSingleEmailMessage
            }
        );
        Test.stopTest();
        System.assertEquals(
            2,
            registerEmailHelperInstance.singleEmailMessagesToSend.size(),
            REGISTER_MULTIPLE_RECORDS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test registerInsert() method passed a null list.
     */
    @isTest
    private static void testWhenRegisterSingleEmailMessageWithNullListCalledThenExceptionThrown() {
        List<Messaging.SingleEmailMessage> singleEmailMessages;
        Boolean hasExceptionOccurred = false;
        RegisterEmailHelper registerEmailHelperInstance = new RegisterEmailHelper();
        Test.startTest();
        try {
            registerEmailHelperInstance.registerSingleEmailMessage(singleEmailMessages);
        } catch (Exception nullListException) {
            hasExceptionOccurred = true;
        }
        Test.stopTest();
        System.assertEquals(true, hasExceptionOccurred, REGISTER_NULL_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test doWork() method performs send email operation
     * using Messaging.sendEmail() method.
     */
    @isTest
    private static void testWhenDoWorkCalledThenSaveResultsUpdated() {
        Messaging.SingleEmailMessage mockSingleEmailMessage = new Messaging.SingleEmailMessage();
        mockSingleEmailMessage.setSubject(EMAIL_SUBJECT);
        mockSingleEmailMessage.setPlainTextBody(EMAIL_SUBJECT);
        mockSingleEmailMessage.setToAddresses(new List<String>{ EMAIL_TO_ADDRESS });
        RegisterEmailHelper registerEmailHelperInstance = new RegisterEmailHelper();
        registerEmailHelperInstance.registerSingleEmailMessage(mockSingleEmailMessage);

        Test.startTest();
        registerEmailHelperInstance.doWork();
        Test.stopTest();
        System.assertEquals(
            false,
            registerEmailHelperInstance.sendEmailResults.isEmpty(),
            DO_WORK_ASSERT_MESSAGE
        );
    }
}