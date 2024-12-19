/**
 * @description EmailMessage Object Trigger Handler Test
 * @author Deloitte
 * @date 04/30/2024
 */
@isTest(SeeAllData=false)
public class EmailMessagesHandlerTest {
	/**
     * @description This method is used to test EmailMessage TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<EmailMessage> newEmailMessage = new List<EmailMessage>();
        EmailMessagesHandler emailMessageObject = new EmailMessagesHandler(newEmailMessage);
        EmailMessagesHandler.Constructor objConstructor = new EmailMessagesHandler.Constructor();
        objConstructor.construct(newEmailMessage);
        System.assertNotEquals(
            emailMessageObject,
            objConstructor.construct(newEmailMessage),
            'Expected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on EmailMessage insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmailMessageInsertedThenCallupdateEmailCountWhenEmailMessageInserted() {
        List<EmailMessage> newEmailMessages = new List<EmailMessage>{
            new EmailMessage(
               subject = 'This is the Subject!'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEmailMessages emailMessageMock = (IEmailMessages) mocks.mock(IEmailMessages.class);
        mocks.startStubbing();
        mocks.when(emailMessageMock.getType()).thenReturn(Schema.EmailMessage.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(emailMessageMock);
        fflib_SObjectDomain.Test.Database.onInsert(newEmailMessages);
        fflib_SObjectDomain.triggerHandler(EmailMessagesHandler.class);
        ((IEmailMessages) mocks.verify(emailMessageMock, 1)).setLastEmailReceivedDate();
        ((IEmailMessages) mocks.verify(emailMessageMock, 1)).updateEmailCountWhenEmailMessageInserted();
        System.assertEquals(newEmailMessages[0].subject, 'This is the Subject!', 'Subject should be same as before');
        System.assertEquals(newEmailMessages.size(), 1, 'Number of emails shoule be same');
    }

}
