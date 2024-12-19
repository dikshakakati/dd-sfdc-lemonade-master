/**
 * @author Deloitte
 * @date 09/09/2024
 * @description Integration Test class for UpdateCassieIdOnLegacyContactsBatch.
 */
@isTest
public class UpdateCassieIdOnLegacyContactsIntTest {
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Account Test';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String SECONDARY_CONTACT_EMAIL = 'test1@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String ASSERT_MESSAGE_MISMATCH_FIELD_VALUES = 'Unexpected Result: Actual and expected values does not match.';

    /**
     * @description To test if the service method is called when the batch runs.
     */
    @isTest
    private static void testWhenContactsWithEmailAreProccessedThenUpdateCassieIdFields() {
        Account mcDonaldsAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = ACCOUNT_TYPE_CORPORATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldsAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Secondary_Email__c = SECONDARY_CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            AccountId = mcDonaldsAccount.Id
        );
        insert newContact;
        newContact.Email_Cassie_ID__c = null;
        newContact.Secondary_Email_Cassie_ID__c = null;
		update newContact;
        Test.startTest();
        UpdateCassieIdOnLegacyContactsBatch batchObject = new UpdateCassieIdOnLegacyContactsBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id, Email,Email_Cassie_ID__c,Secondary_Email_Cassie_ID__c,Secondary_Email__c FROM Contact];
        System.assertNotEquals(updatedContacts[0].Email_Cassie_ID__c, null, ASSERT_MESSAGE_MISMATCH_FIELD_VALUES);
        System.assertNotEquals(updatedContacts[0].Secondary_Email_Cassie_ID__c, null, ASSERT_MESSAGE_MISMATCH_FIELD_VALUES);
    }
    /**
     * @description To test if the no records returned then service method is not called when the batch runs.
     */
    @isTest
    private static void testWhenContactsWithNoEmailAreProccessedThenDontUpdateCassieIdFields() {
        Account mcDonaldsAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = ACCOUNT_TYPE_CORPORATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldsAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Account = mcDonaldsAccount
        );
        insert newContact;
        newContact.Secondary_Email_Cassie_ID__c = null;
		update newContact;
        Test.startTest();
        UpdateCassieIdOnLegacyContactsBatch batchObject = new UpdateCassieIdOnLegacyContactsBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id, Email_Cassie_ID__c,Secondary_Email_Cassie_ID__c FROM Contact where Id =: newContact.Id];

        System.assertNotEquals(updatedContacts[0].Email_Cassie_ID__c, null, ASSERT_MESSAGE_MISMATCH_FIELD_VALUES);
        System.assertEquals(updatedContacts[0].Secondary_Email_Cassie_ID__c, null, ASSERT_MESSAGE_MISMATCH_FIELD_VALUES);
    }
}