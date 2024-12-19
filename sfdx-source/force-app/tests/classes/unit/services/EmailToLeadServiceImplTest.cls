/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Test class for EmailToLeadServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class EmailToLeadServiceImplTest {
    private static final String EMAIL_MESSAGE_METHOD_NAME = 'initiateLeadCreationFromInboundEmail';
    private static final String EMAIL_MESSAGE_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to register expected email message';
    private static final String EMAIL_MESSAGE_FROM_NAME_NOT_FORMATTED_ASSERT_MESSAGE = 'Unexpected result: failed to format From Name in email message';
    private static final String EMAIL_MESSAGE_RELATED_TO_ID = 'RelatedToId';
    private static final String EMAIL_MESSAGE_FROM_NAME_FIELD = 'FromName';
    private static final String INBOUND_EMAIL_CC_ADDRESS = 'InboundLeadEmailHandler_cc@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_ADDRESS = 'InboundLeadEmailHandler@ext.doordash.com';
    private static final String INBOUND_EMAIL_FROM_NAME = 'InboundLeadEmailHandler_From_Name';
    private static final String INBOUND_EMAIL_FROM_NAME_VIA_GROUP = '\'InboundLeadEmailHandler_From_Name\' via Email Group';
    private static final String INBOUND_EMAIL_HTML_BODY = '<p data-renderer-start-pos="71" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, &quot;system-ui&quot;, &quot;Segoe UI&quot;, Roboto, Oxygen, Ubuntu, &quot;Fira Sans&quot;, &quot;Droid Sans&quot;, &quot;Helvetica Neue&quot;, sans-serif; white-space-collapse: preserve; background-color: rgb(255, 255, 255);">Please find below the Mx information as they would like to sign up thank you.</p><p data-renderer-start-pos="150" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, &quot;system-ui&quot;, &quot;Segoe UI&quot;, Roboto, Oxygen, Ubuntu, &quot;Fira Sans&quot;, &quot;Droid Sans&quot;, &quot;Helvetica Neue&quot;, sans-serif; white-space-collapse: preserve; background-color: rgb(255, 255, 255);">Store name : Mamalitha   Restaurant Address : 14949 Kutztown Rd Kutztown, PA 19530, USA</p><p data-renderer-start-pos="237" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, &quot;system-ui&quot;, &quot;Segoe UI&quot;, Roboto, Oxygen, Ubuntu, &quot;Fira Sans&quot;, &quot;Droid Sans&quot;, &quot;Helvetica Neue&quot;, sans-serif; white-space-collapse: preserve; background-color: rgb(255, 255, 255);">Email Address : <a data-testid="link-with-safety" href="mailto:mamalitharestaurant@gmail.com" title="mailto:mamalitharestaurant@gmail.com" data-renderer-mark="true" class="css-tgpl01" style="text-decoration-line: none;">mamalitharestaurant@gmail.com</a>Phone Number : +1 484-280-1975  Manager / Owner Name : Lucy</p>';
    private static final String INBOUND_EMAIL_INVALID_HTML_BODY = '<p data-renderer-start-pos="71" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, " system-ui",="" "segoe="" ui",="" roboto,="" oxygen,="" ubuntu,="" "fira="" sans",="" "droid="" "helvetica="" neue",="" sans-serif;="" white-space-collapse:="" preserve;="" background-color:="" rgb(255,="" 255,="" 255);"="">Please find below the Mx information as they would like to sign up thank you.</p><p data-renderer-start-pos="150" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, " system-ui",="" "segoe="" ui",="" roboto,="" oxygen,="" ubuntu,="" "fira="" sans",="" "droid="" "helvetica="" neue",="" sans-serif;="" white-space-collapse:="" preserve;="" background-color:="" rgb(255,="" 255,="" 255);"="">Store name : Mamalitha  Restaurant Address : 14949 Kutztown Rd Kutztown, PA 19530, USA</p><p data-renderer-start-pos="237" style="margin-top: 0.75rem; margin-bottom: 0px; padding: 0px; font-size: 14px; line-height: 1.714; letter-spacing: -0.005em; color: rgb(23, 43, 77); font-family: -apple-system, " system-ui",="" "segoe="" ui",="" roboto,="" oxygen,="" ubuntu,="" "fira="" sans",="" "droid="" "helvetica="" neue",="" sans-serif;="" white-space-collapse:="" preserve;="" background-color:="" rgb(255,="" 255,="" 255);"=""> Manager / Owner Name : Lucy</p>';
    private static final String INBOUND_EMAIL_MESSAGE_ID = '<InboundLeadEmailHandler-Message_Id-Message_Id@sfdc.net>';
    private static final String INBOUND_EMAIL_PLAIN_TEXT_BODY = 'Please find below the Mx information as they would like to sign up thank you. \n Store name : Mamalitha \n  Restaurant Address : 14949 Kutztown Rd Kutztown, PA 19530, USA \n  Email Address : mamalitharestaurant@gmail.com \n Phone Number : +1 484-280-1975 \n Manager / Owner Name : Lucy';
    private static final String INBOUND_EMAIL_INVALID_PLAIN_TEXT_BODY = 'Please find below the Mx information as they would like to sign up thank you. \n Store name : Mamalitha \n  Restaurant Address :  \n Email Address : mamalitharestaurant@gmail.com \n Phone Number : +1 484-280-1975 \n Manager / Owner Name : Lucy';
    private static final String INBOUND_EMAIL_SUBJECT = 'MerchantSupportInboundEmailSrvcImplTest-Subject ref:00D30kOo.0WO30QvdP:ref';
    private static final String INBOUND_EMAIL_SUBJECT_INVALID_REFERENCE_ID = 'MerchantSupportInboundEmailSrvcImpl-Invalid_Subject';
    private static final String INBOUND_EMAIL_TO_ADDRESS = 'MerchantSupportInboundEmailSrvcImplTest_to@ext.doordash.com';
    private static final String INVALID_REFERENCE_ID_ERROR = 'Inbound Email is received with invalid Reference Id in subject: ';

    /**
     * @description To test Email Message creation when inbound email is received with valid
     * reference Id in email subject.
     */
    @isTest
    private static void testWhenInboundEmailReceivedThenCreateLeadAndEmailMessage() {
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_PLAIN_TEXT_BODY;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailToLeadServiceImpl mockEmailToLeadServiceImpl = new EmailToLeadServiceImpl();
        mockEmailToLeadServiceImpl.initiateLeadCreationFromInboundEmail(inboundEmailInstance);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
    }

    /**
     * @description To test Log (Log__c) creation when inbound email is received with invalid
     * reference Id in email subject.
     */
    @isTest
    private static void testWhenInvalidInboundEmailReceivedThenCreateExceptionLog() {
        List<Messaging.InboundEmail> inboundEmails = new List<Messaging.InboundEmail>();
        Messaging.InboundEmail inboundEmailInstance = new Messaging.InboundEmail();
        inboundEmailInstance.ccAddresses = new List<String>{ INBOUND_EMAIL_CC_ADDRESS };
        inboundEmailInstance.replyTo = INBOUND_EMAIL_FROM_ADDRESS;
        inboundEmailInstance.fromName = INBOUND_EMAIL_FROM_NAME;
        inboundEmailInstance.htmlBody = INBOUND_EMAIL_INVALID_HTML_BODY;
        inboundEmailInstance.messageId = INBOUND_EMAIL_MESSAGE_ID;
        inboundEmailInstance.plainTextBody = INBOUND_EMAIL_INVALID_PLAIN_TEXT_BODY;
        inboundEmailInstance.subject = INBOUND_EMAIL_SUBJECT;
        inboundEmailInstance.toAddresses = new List<String>{ INBOUND_EMAIL_TO_ADDRESS };
        inboundEmails.add(inboundEmailInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        EmailToLeadServiceImpl mockEmailToLeadServiceImpl = new EmailToLeadServiceImpl();
        mockEmailToLeadServiceImpl.initiateLeadCreationFromInboundEmail(inboundEmailInstance);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Class_Name__c => EmailToLeadServiceImpl.class.getName(),
                        Log__c.Class_Method_Name__c => EMAIL_MESSAGE_METHOD_NAME
                    }
                )
            );
    }
}