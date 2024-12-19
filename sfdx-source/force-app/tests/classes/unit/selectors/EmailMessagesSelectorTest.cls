/**
 * @author Atherus
 * @date 18/07/2024
 * @description Test class for EmailReferenceMappingSelector class.
 */

@isTest(seeAllData=false)
private class EmailMessagesSelectorTest {
        
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Email Message count does not match';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

	
     /**
     * @description To test query on WorkPlan when set of Ids and status.
     */
    @isTest
    private static void testWhenSelectEmailMessagesByRelatedIdThenReturnedEmailMessage() {
        Account parentAccount = new Account(
            Name = 'Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        
        EmailMessage emailMsg = new EmailMessage(
        	Subject = 'Test subject',
            RelatedToId = parentAccount.Id,
            FromAddress = 'testFrom@doordash.com.invalid',
            ToAddress = 'testTo@doordash.com.invalid',
            CcAddress = 'testCd@doordash.com.invalid',
            BccAddress = 'testBcc@doordash.com.invalid',
            TextBody = 'Test mail body',
            HtmlBody = 'Test html mail body'
        );
        insert emailMsg;
        
        Test.startTest();
        List<EmailMessage> emailMessagesResult = EmailMessagesSelector.newInstance()
            .selectEmailMessagesByRelatedId(new Set<Id>{ parentAccount.Id });
        Test.stopTest();
        System.assertEquals(1, emailMessagesResult.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
    }
}