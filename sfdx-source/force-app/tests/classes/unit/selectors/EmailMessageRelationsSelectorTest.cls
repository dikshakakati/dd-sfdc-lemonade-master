/**
 * @author Deloitte
 * @date 30/04/2024
 * @description This is test class for EmailMessageRelationSelector class
 */
@isTest(seeAllData=false)
public class EmailMessageRelationsSelectorTest {
	/**
     * @description This test method to query related EmailMessageRelation of EmailMessage.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPassingEmailMessageIdsThenGettingEmailMessageRelations() {
        Lead objLead = new Lead( LastName = 'Test', Company = 'Example', Email = 'abc@abc.com',Phone = '1234567890' );        
        insert objLead;               
        String[] toIds = new String[]{ objLead.Id}; 

        EmailMessage emailMessage = new EmailMessage();  
        emailMessage.subject = 'This is the Subject!'; 
        emailMessage.toIds = toIds;  
        List<EmailMessage> emailMessages = New List<EmailMessage>();
        emailMessages.add(emailMessage);
      
        insert emailMessages; 
        
        Set<Id> emailMessageIds = new Set<Id>();
        emailMessageIds.add(emailMessage.Id);
        
        // Add Email Message Relation for id of the sender 
        
        EmailMessageRelation emailMessageRelationWithLead = new EmailMessageRelation(); 
        emailMessageRelationWithLead.emailMessageId = emailMessage.Id; 
        emailMessageRelationWithLead.relationId = objLead.Id; 
        emailMessageRelationWithLead.relationType = 'ToAddress'; 
        insert emailMessageRelationWithLead;
   
        EmailMessageRelationsSelector emailMessageRelationsInstance = new EmailMessageRelationsSelector();
        
        List<EmailMessageRelation> emailMessageRelatedEmailMessageRelations = emailMessageRelationsInstance.selectByEmailMessageIds(
           emailMessageIds
        );
        
        System.assertEquals(1, emailMessageRelatedEmailMessageRelations.size(), 'The list size will match');
    }
}
