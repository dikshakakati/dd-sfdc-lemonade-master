/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for Contacts class
 */
@isTest(seeAllData=false)
private class ContactsTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'DOBReadinessCheckCountriesStates';
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE = 'US,CA,AU-QLD';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN = 'US';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_AU = 'AU';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_US = 'US';
    private static final String ELIGIBLE_STATE_TO_VALIDATE_QLD = 'QLD';
    private static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String SSN_LAST_FOUR_DIGITS = '1234';
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String VERTICAL = 'Floral';
    private static final String CORPORATE = 'Corporate';
    private static final String UNEXPECTED_ERROR = 'Unexpected Error: Error Message Map were not fetched correctly.';
    private static final String ACCOUNTING_CONTACT = 'Accounting Contact';
    private static final String STATIC_RESOURCE_TEST_CSV = 'LeadConversionMappings';
    private static final String PREFERRED_LANGUAGE_ENGLISH = 'English';
    private static final String ASSERT_ERROR_COUNT_MISMATCH = 'Unexpected result: there is a mismatch in count.';
    private static final String ASSERT_EXCEPTION = 'Unexpected Preferred language post lead conversion.';
    /**
     * @description This is method used to test Contacts class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Contact> contactList = new List<Contact>();
        //Default Constructor Call
        Contacts contactsObject = new Contacts(contactList);
        //IContacts Instance Creation Call
        Contacts.newInstance(contactList);
        System.assertNotEquals(
            Contacts.newInstance(contactList),
            contactsObject,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description To test the format of the phone number when the country code is appended based on the country.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenCountryCodeAppended() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                RecordTypeId = businessRecordTypeId,
                Name = 'Test Account 1',
                BillingCountry = 'United States',
                BillingCountryCode = 'US'
            )
        };
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Id = Fake.generateId(Contact.class),
                FirstName = 'First Name 1',
                LastName = 'Last Name 1',
                Phone = '9897969594',
                AccountId = newAccounts[0].Id
            )
        };
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'United States',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 10,
                Phone_Country_Code__c = '1'
            )
        };
        Set<Id> accountIds = new Set<Id>{ newAccounts[0].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ICountryAttributesMappingSelector selectorMock = (ICountryAttributesMappingSelector) mocks.mock(
            ICountryAttributesMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(acountsSelectorMock.selectById(accountIds)).thenReturn(newAccounts);
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(testData);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        //Act
        Contacts.newInstance(newContacts).validateAndNormalizePhoneNumberFormat();
        //Assert
        System.assertEquals(newContacts[0].phone, '+19897969594', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test validation of Accounting Contact Birthdate when Store Corporate parent subscriptions include
     * alcohol delivery or alcohol pickup with Billing Country as Australia and State as Queensland.
     */
    @isTest
    private static void testWhenContactHavingAccountingContactRoleWithStoreCorporateParentHasAlcoholSubscriptionsWithEligibleBillingCountryAndStateThenValidateBirthdate() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake subscriptionFakeInstance = new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_ALCOHOL_DELIVERY)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId);
        SBQQ__Subscription__c subscriptionAlcohol = (SBQQ__Subscription__c) ServiceMockDataBuilder.convertToSObject(
            subscriptionFakeInstance
        );
        Contact newContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setField(Contact.Id, contactId)
            .toSObject();
        List<AccountContactRelation> newACR = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId,
                AccountId = storeAccount.Id,
                ContactId = newContact.Id,
                Roles = ACCOUNTING_CONTACT
            )
        };
        List<Contact> newContacts = new List<Contact>{ newContact };
        Map<Id, List<Contact>> idToContacts = new Map<Id, List<Contact>>();
        idToContacts.put(storeAccount.id, newContacts);
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector mockAccountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            AccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionSelector mockSubscriptionSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockAccountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                mockAccountContactRelationsSelector.selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
                    new Set<Id>{ contactId }
                )
            )
            .thenReturn(newACR);
        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.selectSubscriptionsWithAlcoholProductsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ subscriptionAlcohol });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockAccountContactRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        //Act
        Contacts.newInstance(newContacts).validateSSNAndBirthdateWithAccountingContactRole();
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            System.Label.Birthdate_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test validation of Accounting Contact SSN when Store Corporate parent subscriptions include
     * alcohol delivery or alcohol pickup with Billing Country as US.
     */
    @isTest
    private static void testWhenContactHavingAccountingContactRoleWithStoreCorporateParentHasAlcoholSubscriptionsWithEligibleBillingCountryAndStateThenValidateSSN() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake subscriptionFakeInstance = new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_ALCOHOL_DELIVERY)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId);
        SBQQ__Subscription__c subscriptionAlcohol = (SBQQ__Subscription__c) ServiceMockDataBuilder.convertToSObject(
            subscriptionFakeInstance
        );
        Contact newContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setField(Contact.Id, contactId)
            .toSObject();
        List<AccountContactRelation> newACR = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId,
                AccountId = storeAccount.Id,
                ContactId = newContact.Id,
                Roles = ACCOUNTING_CONTACT
            )
        };
        List<Contact> newContacts = new List<Contact>{ newContact };
        Map<Id, List<Contact>> idToContacts = new Map<Id, List<Contact>>();
        idToContacts.put(storeAccount.id, newContacts);
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector mockAccountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            AccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionSelector mockSubscriptionSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockAccountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                mockAccountContactRelationsSelector.selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
                    new Set<Id>{ contactId }
                )
            )
            .thenReturn(newACR);
        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.selectSubscriptionsWithAlcoholProductsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ subscriptionAlcohol });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockAccountContactRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        //Act
        Contacts.newInstance(newContacts).validateSSNAndBirthdateWithAccountingContactRole();
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            System.Label.SSN_Last_4Digits_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test processing on contacts post lead conversion.
     */
    @isTest
    private static void testWhenContactHavingPreferredLanguagePopulatedThenPreferredLanguageNotStampedOnLeadConversion() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<SObject> oldContacts = new List<SObject>();
        Contact oldContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccountId)
            .setField(Contact.Id, contactId)
            .setField(Contact.Preferred_Language__c, PREFERRED_LANGUAGE_ENGLISH)
            .toSObject();
        oldContacts.add(oldContact);
        Contact newContact = (Contact) new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccountId)
            .setField(Contact.Id, contactId)
            .setField(Contact.Converted_Lead_Id__c, leadId)
            .setField(Contact.Preferred_Language__c, PREFERRED_LANGUAGE_ENGLISH)
            .toSObject();
        List<StaticResource> staticResources = [
            SELECT body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        Contacts.newInstance(new List<Contact>{ newContact })
            .processContactsOnLeadConversion(new Map<Id, SObject>(oldContacts));
        System.assertEquals(1, staticResources.size(), ASSERT_EXCEPTION);
        System.assertEquals(
            newContact.Preferred_Language__c,
            oldContact.Preferred_Language__c,
            ASSERT_EXCEPTION
        );
    }
}