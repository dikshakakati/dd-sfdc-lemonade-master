/**
 * @author Deloitte
 * @date 16/03/2022
 * @description This is test class for ContactsSelector class
 */
@isTest
public class ContactsSelectorTest {
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String CONTACT_SSN = '1234';
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected result';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Contact.FieldSets.Encrypted_Fields;
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';

    /**
     * @description This methosd used to test ContactsSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ContactsSelector selector = new ContactsSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Contact.Id,
                Contact.Name,
                Contact.AccountId,
                Contact.Birthdate,
                Contact.Description,
                Contact.SSN_Last_4Digits__c,
                Contact.FirstName,
                Contact.LastName,
                Contact.Email,
                Contact.Count_of_Calls_Outbound_Inbound__c,
                Contact.Count_of_Emails_Sent__c,
                Contact.Event_Type__c,
                Contact.Unique_Identifier__c,
                Contact.Phone,
                Contact.Order_Protocol_Email__c,
                Contact.POS_System__c,
                Contact.SSMO_Matching_Account_Id__c,
                Contact.Menu_URL__c,
                Contact.Business_Id__c,
                Contact.Store_Id__c,
                Contact.Package__c,
                Contact.MailingAddress,
                Contact.Hours_of_Operation__c,
                Contact.Preferred_Language__c,
                Contact.Order_Protocol__c,
                Contact.Primary_Vertical__c,
                Contact.Order_Protocol_Phone__c,
                Contact.Coverage__c,
                Contact.SSMO_Business_Account_Id__c,
                Contact.Integration_Contact_Type__c,
                contact.Submarket__c
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assertEquals(
            Schema.Contact.SObjectType,
            typeOfObj,
            'The object type must be Contacts'
        );
    }

    /**
     * @description This methosd used to test selectById method
     */
    @isTest
    private static void testWhenContactInsertThenCallmethod() {
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'LastName1',
                Description = 'Test 1',
                Email = 'abc1@gmail.com'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'LastName2',
                Description = 'Test 2',
                Email = 'abc2@gmail.com'
            )
        };
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(newContacts);
        uow.commitWork();
        ContactsSelector selector = new ContactsSelector();
        List<Contact> contacts = selector.selectById(
            new Set<Id>{ newContacts[0].Id, newContacts[1].Id }
        );
        ContactsSelector.newInstance();
        System.assertEquals('Test 1', contacts[0].Description, 'Description must be Test 1');
        System.assertEquals('Test 2', contacts[1].Description, 'Description must be Test 2');
    }

    /**
     * @description To test query on Contact when encrypted FieldSet
     * and Contact Ids are passed.
     **/
    @isTest
    private static void testWhenFieldSetAndContactIdsArePassedThenReturnContactFieldsUsingFieldSet() {
        Contact newContact = new Contact(
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Email = CONTACT_EMAIL,
            SSN_Last_4Digits__c = CONTACT_SSN
        );
        insert newContact;
        List<SObject> sObjects = ((IEncryptedDataSelector) Application.Selector.newInstance(
                newContact.Id.getSobjectType()
            ))
            .selectEncryptedData((Schema.FieldSet) FIELDS_TO_QUERY, new Set<Id>{ newContact.Id });
        System.assertEquals(1, sObjects.size(), EMPTY_LIST_ASSERT_MESSAGE);

        List<SObject> contactsFromFieldSet = ContactsSelector.newInstance()
            .selectContactsByIdAndFieldSet(
                SObjectType.Contact.FieldSets.Decision_Maker_Contact_Info,
                new Set<Id>{ newContact.Id }
            );
        System.assertEquals(
            1,
            contactsFromFieldSet.size(),
            'A Contact should be queried and retrieved with values from the field set.'
        );
    }

    /**
     * @description To test query on Contact where Account_Team_Member_Id__c is not populated.
     */
    @isTest
    private static void testWhenAccountTeamMemberIdNotPopulatedThenRelatedContactsNotReturned() {
        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert newContact;
        Test.startTest();
        Database.QueryLocator contactsQueryLocator = ContactsSelector.newInstance()
            .selectByAccountTeamMemberId();
        List<Contact> contactsQueryResult = Database.query(contactsQueryLocator.getQuery());
        Test.stopTest();
        System.assertEquals(0, contactsQueryResult.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To test query on Contact when Email, firstname and lastName passed return contacts
     */
    @isTest
    private static void testWhenEmailFirstNameAndLastNamePassedThenReturnMatchingContacts() {
        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert newContact;
        Test.startTest();
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectContactByEmailFirstNameLastName(
                new Set<String>{ CONTACT_FIRST_NAME },
                new Set<String>{ CONTACT_LAST_NAME },
                new Set<String>{ CONTACT_EMAIL }
            );
        Test.stopTest();
        System.assertEquals(1, contacts.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description test dummy contact selector
     */
    @isTest
    private static void testWhenDummyContactIsCalledThenDummyContactIsReturned() {
        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert newContact;
        Contact returnedCon = ContactsSelector.newInstance().selectDummyContact();
        System.assertNotEquals(null, returnedCon, 'No Dummy Contact Returned');
    }

    /**
     * @description TBD
     */
    @isTest
    private static void testWhenUniqueIdentifiersPassedThenContactsReturned() {
        Account mcDonaldsAccount = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert mcDonaldsAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Account = mcDonaldsAccount,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        insert newContact;
        Test.startTest();
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectContactsByUniqueIdentifier(new Set<String>{ UNIQUE_IDENTIFIER });
        Test.stopTest();

        System.assertEquals(1, contacts.size(), INVALID_ASSERT_MESSAGE);
    }

    @IsTest
    static void testWhenSelectingContactsWithFieldSetThenReturnFields() {
        String testCity = 'Seattle';
        Contact newContact = new Contact();
        newContact.FirstName = CONTACT_FIRST_NAME;
        newContact.LastName = CONTACT_LAST_NAME;
        newContact.Email = CONTACT_EMAIL;
        newContact.MailingCity = testCity;
        insert newContact;

        List<Contact> results = ContactsSelector.newInstance()
            .selectByIdsAndFieldSet(
                SObjectType.Contact.FieldSets.Address_Details,
                new Set<Id>{ newContact.Id }
            );
        System.assertEquals(1, results.size(), 'This test Contact should be returned');
        System.assertEquals(testCity, results[0].MailingCity, 'Address details should be returned');
    }

      /**
     * @description To test on Contacts when accountIds passed return contacts
     */
    @isTest
    private static void testWhenAccountIdsPassedThenContactsReturned() {
        Account mcDonaldsAccount = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = 'Corporate',
            Segment__c='SMB'
        );
        insert mcDonaldsAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            AccountId = mcDonaldsAccount.Id,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        insert newContact;
        Test.startTest();
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectContactsByAccountIds(new Set<Id>{ mcDonaldsAccount.Id });
        Test.stopTest();

        System.assertEquals(1, contacts.size(), INVALID_ASSERT_MESSAGE);
        }

    /**
    * @description duplicate contact tselector method test under same account hirearchy
    */
    @isTest
    private static void testWhenNameEmailAccountIdThenReturnDuplicateContact() {

        Account mcDonaldsAccount = new Account(
            Name = 'McDonalds Canada Business',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = 'Corporate',
            Segment__c = 'SMB'
        );
        insert mcDonaldsAccount;

        Account mcDonaldsStoreAccount = new Account(
            Name = 'McDonalds Canada',
            Type = 'Corporate',
            Segment__c = 'SMB',
            ParentId = mcDonaldsAccount.Id
        );
        insert mcDonaldsStoreAccount;

        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            AccountId = mcDonaldsStoreAccount.Id
        );
        insert newContact;

        Test.startTest();
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectContactByEmailFirstNameLastNameAccountIds(
                new Set<String>{ CONTACT_FIRST_NAME },
                new Set<String>{ CONTACT_LAST_NAME },
                new Set<String>{ CONTACT_EMAIL },
                mcDonaldsStoreAccount.Id,
                mcDonaldsAccount.Id
            );
        Test.stopTest();

        System.assertEquals(1, contacts.size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description To test query for dummy contact.
     */
    @isTest
    private static void testWhenDummyContactAvailableThenReturnContact() {
        Contact newContact = new Contact(
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        insert newContact;
        Set<Id> contactIds = new Set<Id> {newContact.Id};
        Test.startTest();
        List<Contact> contacts = ContactsSelector.newInstance()
            .selectDummyContactByRecordId(contactIds);
        Test.stopTest();
        System.assertEquals(1, contacts.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}