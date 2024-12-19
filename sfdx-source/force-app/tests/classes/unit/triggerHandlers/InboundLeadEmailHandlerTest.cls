/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Test class for InboundLeadEmailHandler class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InboundLeadEmailHandlerTest {
    private static final String INBOUND_EMAIL_CC_ADDRESS = 'InboundLeadEmailHandler_cc@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_ADDRESS = 'InboundLeadEmailHandler_from@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_NAME = 'InboundLeadEmailHandler_From_Name';
    private static final String INBOUND_EMAIL_HTML_BODY = '<html><head></head><body></body></html>';
    private static final String INBOUND_EMAIL_MESSAGE_ID = '<InboundLeadEmailHandler-Message_Id@sfdc.net>';
    private static final String INBOUND_EMAIL_PLAIN_TEXT_BODY = 'InboundLeadEmailHandler-Plain_Text_Body.';
    private static final String INBOUND_EMAIL_SUBJECT = 'InboundLeadEmailHandler-Subject Onboarding onto Doordash';
    private static final String INBOUND_EMAIL_TO_ADDRESS = 'InboundLeadEmailHandler@ext.doordash.com';

    /**
     * @description To test Email Message and Lead creation process is initiated
     * when inbound email is received.
     */
    @isTest
    private static void testWhenInboundEmailReceivedThenInitiateEmailMessageAndLeadCreation() {
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
        IEmailToLeadService mockEmailToLeadService = (IEmailToLeadService) mocks.mock(
            IEmailToLeadService.class
        );
        Application.SERVICE.setMock(IEmailToLeadService.class, mockEmailToLeadService);
        InboundLeadEmailHandler inboundLeadEmailHandlerInstance = new InboundLeadEmailHandler();
        inboundLeadEmailHandlerInstance.handleInboundEmail(
            inboundEmailInstance,
            new Messaging.InboundEnvelope()
        );
        ((IEmailToLeadService) mocks.verify(mockEmailToLeadService, 1))
            .initiateLeadCreationFromInboundEmail(inboundEmailInstance);
    }
}