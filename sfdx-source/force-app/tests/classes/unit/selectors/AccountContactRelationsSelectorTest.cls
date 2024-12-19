/**
 * @author Deloitte
 * @date 04/05/2022
 * @description Test class for AccountContactRelationsSelector class.
 */
@isTest(seeAllData=false)
private class AccountContactRelationsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be AccountContactRelation';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_LIST = 'Unexpected result: The AccountContactRelation is empty';
    private static final string ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final string ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final string ACCOUNT_BILLING_CITY = 'Missoula';
    private static final string ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final string ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final string ACCOUNT_BILLING_STATE = 'California';
    private static final string ACCOUNT_BUSINESS_RECORDTYPE_NAME = 'Business';
    private static final string ACCOUNT_STORE_RECORDTYPE_NAME = 'Store';
    private static final string BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final string CONTACT_FIRSTNAME = 'Test';
    private static final string CONTACT_LASTNAME = 'Contact';
    private static final string CONTACT_EMAIL = 'test@test.com';
    private static final string CONTACT_EMAIL_FIELD_REFERENCE = 'Contact.Email';
    private static final String CONTRACT_SIGNATORY_ROLE = 'Contract Signatory';
    private static final String DECISION_MAKER_ROLE = 'Decision Maker';
    private static final string STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String ACCOUNTING_CONTACT_ROLE = 'Accounting Contact';
    private static final String PHOTOSHOOT_ROLE = 'Photoshoot Contact';
    private static final String SEGMENT_SMB = 'SMB';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        AccountContactRelationsSelector accountContactRelationsInstance = new AccountContactRelationsSelector();
        Schema.SObjectType typeOfObject = accountContactRelationsInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = accountContactRelationsInstance.getSObjectFieldList();
        AccountContactRelationsSelector.newInstance();
        System.assertEquals(
            Schema.AccountContactRelation.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                AccountContactRelation.Id,
                AccountContactRelation.ContactId,
                AccountContactRelation.AccountId,
                AccountContactRelation.Roles,
                AccountContactRelation.isActive
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test AccountContactRelation query when AccountIds are passed.
     */
    @isTest
    private static void testWhenAccountIdIsSentThenCorresponsingContactRelationshipsAreRetrieved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        AccountContactRelation mockAccountContactRelation = new AccountContactRelation(
            AccountId = storeAccount.Id,
            ContactId = contact.Id,
            Roles = DECISION_MAKER_ROLE
        );
        insert mockAccountContactRelation;
        AccountContactRelationsSelector accountContactRelationsInstance = new AccountContactRelationsSelector();
        List<AccountContactRelation> accountContactRelation = accountContactRelationsInstance.selectByAccountIds(
            new Set<Id>{ storeAccount.Id }
        );
        System.assertEquals(
            true,
            accountContactRelation.size() != null,
            ASSERT_MESSAGE_MISMATCH_IN_LIST
        );
        List<AccountContactRelation> activeAccountContactRelation = accountContactRelationsInstance.selectActiveAcrByAccountIds(
            new Set<Id>{ storeAccount.Id }
        );
        System.assertEquals(
            true,
            activeAccountContactRelation.size() != null,
            ASSERT_MESSAGE_MISMATCH_IN_LIST
        );

        List<AccountContactRelation> relationsByAccountIdAndContactId = accountContactRelationsInstance.selectByAccountIdsAndContactIds(
            new Set<Id>{ storeAccount.Id },
            new Set<Id>{ contact.Id }
        );
        System.assertEquals(
            1,
            relationsByAccountIdAndContactId.size(),
            'One ACR should be returned'
        );
    }

    /**
     * @description To test AccountContactRelation query when ContactIds are passed then retrive Accounting Contact ACR.
     */
    @isTest
    private static void testWhenContactIdIsSentThenCorresponsingAccountingContactACRAreRetrieved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        AccountContactRelation accountContactRelationRecord = new AccountContactRelation(
            AccountId = storeAccount.Id,
            ContactId = contact.Id,
            Roles = ACCOUNTING_CONTACT_ROLE
        );
        insert accountContactRelationRecord;
        List<AccountContactRelation> queryResult = AccountContactRelationsSelector.newInstance()
            .selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
                new Set<Id>{ contact.Id }
            );
        System.assertEquals(1, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_LIST);
    }
    /**
     * @description To test AccountContactRelation query when ContactIds are passed then retrive Accounting Contact ACR.
     */
    @isTest
    private static void testWhenContactIdsPassedThenRetrieveMatchingAcrs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        AccountContactRelation accountContactRelationRecord = new AccountContactRelation(
            AccountId = storeAccount.Id,
            ContactId = contact.Id,
            Roles = ACCOUNTING_CONTACT_ROLE
        );
        insert accountContactRelationRecord;
        List<AccountContactRelation> queryResult = AccountContactRelationsSelector.newInstance()
            .selectAccountContactRelationsByContactIds(new Set<Id>{ contact.Id });
        System.assertEquals(2, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_LIST);
    }

    /**
     * @description To test Decision Maker contacts are returned
     * when Account Ids and fields are passed.
     */
    @isTest
    private static void testWhenAccountIdsAndFieldsReceivedThenReturnDecisionMakerDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORDTYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORDTYPE_NAME)
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = SEGMENT_SMB

        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        AccountContactRelation mockAccountContactRelation = new AccountContactRelation(
            AccountId = storeAccount.Id,
            ContactId = contact.Id,
            IsActive = true,
            Roles = DECISION_MAKER_ROLE
        );
        insert mockAccountContactRelation;
        AccountContactRelationsSelector accountContactRelationsInstance = new AccountContactRelationsSelector();
        List<AccountContactRelation> accountContactRelation = accountContactRelationsInstance.selectDecisionMakerContactsByAccountIds(
            new Set<Id>{ storeAccount.Id },
            new Set<String>{ CONTACT_EMAIL_FIELD_REFERENCE }
        );
        System.assertEquals(
            true,
            accountContactRelation.size() != null,
            ASSERT_MESSAGE_MISMATCH_IN_LIST
        );
    }

    /**
     * @description To test if Account Contact Relations with  Photoshoot Role are retrieved when
     * AccountIds are passed.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnPhotoShootContactDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORDTYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORDTYPE_NAME)
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE
        );
        insert storeAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        AccountContactRelation mockAccountContactRelation = new AccountContactRelation(
            AccountId = storeAccount.Id,
            ContactId = contact.Id,
            IsActive = true,
            Roles = PHOTOSHOOT_ROLE
        );
        insert mockAccountContactRelation;
        AccountContactRelationsSelector accountContactRelationsInstance = new AccountContactRelationsSelector();
        List<AccountContactRelation> accountContactRelation = accountContactRelationsInstance.selectPhotoshootContactRolesByAccountIds(
            new Set<Id>{ storeAccount.Id }
        );
        System.assertEquals(
            true,
            accountContactRelation.size() != null,
            ASSERT_MESSAGE_MISMATCH_IN_LIST
        );
    }

    /**
     * @description It is used to test if the Accounts and the Account Contact Relation records are returned
     * hierarchy.
     */
    @isTest(SeeAllData=false)
    private static void testWhenACRRecordsAreSelectedThenReturnAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = SEGMENT_SMB)
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME + '1',
                Email = 'contact1@gmail.com',
                AccountId = accounts[1].Id
            ),
            new Contact(
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME + '2',
                Email = 'contact2@gmail.com',
                AccountId = accounts[1].Id
            ),
            new Contact(
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME + '3',
                Email = 'contact3@gmail.com',
                AccountId = accounts[0].Id
            )
        };
        insert contacts;
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(
                AccountId = accounts[0].Id,
                ContactId = contacts[0].Id,
                IsActive = true,
                Roles = DECISION_MAKER_ROLE
            ),
            new AccountContactRelation(
                AccountId = accounts[0].Id,
                ContactId = contacts[1].Id,
                IsActive = true,
                Roles = CONTRACT_SIGNATORY_ROLE
            ),
            new AccountContactRelation(
                AccountId = accounts[1].Id,
                ContactId = contacts[2].Id,
                IsActive = true,
                Roles = ACCOUNTING_CONTACT_ROLE
            )
        };
        insert accountContactRelations;
        Test.startTest();
        List<AccountContactRelation> retrievedACR = AccountContactRelationsSelector.newInstance()
            .selectActiveACRByAccountIdsAndRoles(new Set<Id>{ accounts[0].Id, accounts[1].Id });
        Test.stopTest();
        System.assertEquals(2, retrievedACR.size(), ASSERT_MESSAGE_MISMATCH_IN_LIST);
    }
}