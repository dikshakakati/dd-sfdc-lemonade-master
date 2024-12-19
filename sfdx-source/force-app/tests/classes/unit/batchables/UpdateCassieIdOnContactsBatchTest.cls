/**
 * @author Deloitte
 * @date 09/09/2024
 * @description Integration Test class for UpdateCassieIdOnLegacyContactsBatch.
 */
@isTest
public class UpdateCassieIdOnContactsBatchTest {
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Account Test';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String SECONDARY_CONTACT_EMAIL = 'test1@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String EMAIL_FIELD = 'Email';
    private static final String SECONDARY_EMAIL_FIELD = 'Secondary_Email__c';
    private static final String EMAIL_CASSIE_ID_FIELD = 'Email_Cassie_ID__c';
	private static final String SECONDARY_EMAIL_CASSIE_ID_FIELD = 'Secondary_Email_Cassie_ID__c';
	private static final String EMAIL_CASSIE_ID_VALUE = 'STN52nGyalQJfQHvw1Rztwax5XKgpzd1ySd0Mo3EZ0hRlcSlisWHYVcZum5JvvKe0BFwFC1x1uN/Yhjha47BzA==';
    private static final String SECONDARY_EMAIL_CASSIE_ID_VALUE = '5XzuHnaM6k2tsSM1zWzH9m34jrgoNKyMZBZlyAB10XXx9fJE+1h5fP6MmLWXz93b/6mhFq1gFwqVp1wnadgwSg==';

    /**
     * @description To test if the service method is called when the batch runs.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactsWithEmailAreProccessedThenUpdateCassieIdFields() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        List<Contact> newContacts  = new List<Contact>{
            new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRST_NAME,
                LastName = CONTACT_LAST_NAME,
                Email = CONTACT_EMAIL,
             	Secondary_Email__c = CONTACT_EMAIL,
             	Email_Cassie_ID__c = null,
            	Secondary_Email_Cassie_ID__c = null)
        };
        Contact updatedContact = new Contact();
        updatedContact.Id = contactId;
        updatedContact.Email_Cassie_ID__c = EMAIL_CASSIE_ID_VALUE;
        updatedContact.Secondary_Email_Cassie_ID__c = SECONDARY_EMAIL_CASSIE_ID_VALUE;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICassieIdEncryptionService mockCassieIdEncryptionService = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockCassieIdEncryptionService.encryptCassieId(
                    newContacts,
                    EMAIL_FIELD,
                    EMAIL_CASSIE_ID_FIELD
                )
            )
            .thenReturn(new List<Contact>{ updatedContact });
        mocks.when(
                mockCassieIdEncryptionService.encryptCassieId(
                    newContacts,
                    SECONDARY_EMAIL_FIELD,
                    SECONDARY_EMAIL_CASSIE_ID_FIELD
                )
            )
            .thenReturn(new List<Contact>{ updatedContact });
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            ICassieIdEncryptionService.class,
            mockCassieIdEncryptionService
        );

        UpdateCassieIdOnLegacyContactsBatch batchInstance = new UpdateCassieIdOnLegacyContactsBatch();
        batchInstance.start(null);
        batchInstance.execute(null, newContacts);
        batchInstance.finish(null);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 1))
            .encryptCassieId(newContacts, EMAIL_FIELD, EMAIL_CASSIE_ID_FIELD);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 1))
            .encryptCassieId(newContacts, SECONDARY_EMAIL_FIELD, SECONDARY_EMAIL_CASSIE_ID_FIELD);
    }

    /**
     * @description To test if the no records returned then service method is not called when the batch runs.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactsWithNoEmailAreProccessedThenDontUpdateCassieIdFields() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);

        List<Contact> newContacts  = new List<Contact>{
            new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRST_NAME,
                LastName = CONTACT_LAST_NAME,
                Email = CONTACT_EMAIL,
             	Secondary_Email__c = CONTACT_EMAIL,
             	Email_Cassie_ID__c = CONTACT_EMAIL,
            	Secondary_Email_Cassie_ID__c = CONTACT_EMAIL)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
		IContactsService mockContactsService = (IContactsService) mocks.mock(
            IContactsService.class
        );
        ContactsSelector mockContactsSelector = (ContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockContactsSelector.SObjectType()).thenReturn(Schema.Contact.SObjectType);
        mocks.when(mockContactsSelector.selectLegacyContactsWithCassieIdsAsNull()).thenReturn(null);

        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IContactsService.class,
            mockContactsService
        );
        Application.SELECTOR.setMock(mockContactsSelector);

        UpdateCassieIdOnLegacyContactsBatch batchInstance = new UpdateCassieIdOnLegacyContactsBatch();
        batchInstance.start(null);
        batchInstance.execute(null, null);
        batchInstance.finish(null);

        ((IContactsService) mocks.verify(mockContactsService, 0))
            .updateEncryptedCassieIdFieldsOnMigratedContacts(newContacts);
    }
}