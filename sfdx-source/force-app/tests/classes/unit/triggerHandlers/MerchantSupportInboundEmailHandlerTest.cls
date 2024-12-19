/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Test class for MerchantSupportInboundEmailHandler class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MerchantSupportInboundEmailHandlerTest {
    private static final String INBOUND_EMAIL_CC_ADDRESS = 'MerchantSupportInboundEmailHandlerTest_cc@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_ADDRESS = 'MerchantSupportInboundEmailHandlerTest_from@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_NAME = 'MerchantSupportInboundEmailHandlerTest_From_Name';
    private static final String INBOUND_EMAIL_HTML_BODY = '<html><head></head><body></body></html>';
    private static final String INBOUND_EMAIL_MESSAGE_ID = '<MerchantSupportInboundEmailHandlerTest-Message_Id@sfdc.net>';
    private static final String INBOUND_EMAIL_PLAIN_TEXT_BODY = 'MerchantSupportInboundEmailHandlerTest-Plain_Text_Body.';
    private static final String INBOUND_EMAIL_SUBJECT = 'MerchantSupportInboundEmailHandlerTest-Subject ref:00D30kOo.0WO30QvdP:ref';
    private static final String INBOUND_EMAIL_TO_ADDRESS = 'MerchantSupportInboundEmailHandlerTest_to@ext.doordash.com';

    /**
     * @description To test Email Message creation process is initiated
     * when inbound email is received.
     */
    @isTest
    private static void testWhenInboundEmailReceivedThenInitiateEmailMessageCreation() {
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.fromAddress = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantSupportInboundEmailService mockMerchantSupportInboundEmailService = (IMerchantSupportInboundEmailService) mocks.mock(
            IMerchantSupportInboundEmailService.class
        );
        Application.SERVICE.setMock(
            IMerchantSupportInboundEmailService.class,
            mockMerchantSupportInboundEmailService
        );
        MerchantSupportInboundEmailHandler merchantSupportInboundEmailHandlerInstance = new MerchantSupportInboundEmailHandler();
        merchantSupportInboundEmailHandlerInstance.handleInboundEmail(
            inboundEmailInstance,
            new Messaging.InboundEnvelope()
        );
        ((IMerchantSupportInboundEmailService) mocks.verify(
                mockMerchantSupportInboundEmailService,
                1
            ))
            .createEmailMessagesOnWorkOrders(
                new List<Messaging.InboundEmail>{ inboundEmailInstance }
            );
    }
}