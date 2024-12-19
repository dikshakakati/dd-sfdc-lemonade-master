/**
 * @author Deloitte
 * @date 28/11/2022
 * @description Test class for ContactsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ContactsServiceImplTest {
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
    private static final Integer SSN_LAST_FOUR_DIGITS = 1234;
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String VERTICAL = 'Floral';
    private static final String CORPORATE = 'Corporate';
    private static final String UNEXPECTED_ERROR = 'Unexpected Error: Error Message Map were not fetched correctly.';
    private static final String EMAIL_FIELD = 'Email';
    private static final String SECONDARY_EMAIL_FIELD = 'Secondary_Email__c';
    private static final String EMAIL_CASSIE_ID_FIELD = 'Email_Cassie_ID__c';
	private static final String SECONDARY_EMAIL_CASSIE_ID_FIELD = 'Secondary_Email_Cassie_ID__c';
	private static final String EMAIL_CASSIE_ID_VALUE = 'STN52nGyalQJfQHvw1Rztwax5XKgpzd1ySd0Mo3EZ0hRlcSlisWHYVcZum5JvvKe0BFwFC1x1uN/Yhjha47BzA==';
    private static final String SECONDARY_EMAIL_CASSIE_ID_VALUE = '5XzuHnaM6k2tsSM1zWzH9m34jrgoNKyMZBZlyAB10XXx9fJE+1h5fP6MmLWXz93b/6mhFq1gFwqVp1wnadgwSg==';

    /**
     * @description To test validation of Contact Birthdate when Store Corporate parent subscriptions include
     * alcohol delivery or alcohol pickup with Billing Country as Australia and State as Queensland.
     */
    @isTest
    private static void testWhenStoreCorporateParentSubscriptionsIncludeAlcoholWithEligibleBillingCountryAndStateThenValidateBirthdate() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);

        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake subscriptionFakeInstance = new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_ALCOHOL_DELIVERY)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId);
        SBQQ__Subscription__c subscriptionAlcohol = (SBQQ__Subscription__c) ServiceMockDataBuilder.convertToSObject(
            subscriptionFakeInstance
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

        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setFakeId();
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        List<Contact> newContacts = new List<Contact>{ contact };
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
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.selectSubscriptionsWithAlcoholProductsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ subscriptionAlcohol });
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

        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        Map<Id, String> contactIdToErrorMessage = ContactsService.validateSSNAndBirthdate(
            idToContacts
        );
        System.assertEquals(
            contactIdToErrorMessage.get(contact.Id),
            System.Label.Birthdate_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test validation of Contact Birthdate when Store Corporate parent subscriptions include
     * alcohol delivery or alcohol pickup with Billing Country as US.
     */
    @isTest
    private static void testWhenStoreCorporateParentSubscriptionsIncludeAlcoholWithEligibleBillingCountryAndStateThenValidateSSN() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake subscriptionFakeInstance = new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_ALCOHOL_DELIVERY)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId);
        SBQQ__Subscription__c subscriptionAlcohol = (SBQQ__Subscription__c) ServiceMockDataBuilder.convertToSObject(
            subscriptionFakeInstance
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

        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        List<Contact> newContacts = new List<Contact>{ contact };
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
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.selectSubscriptionsWithAlcoholProductsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ subscriptionAlcohol });
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

        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<Id, String> contactIdToErrorMessage = ContactsService.validateSSNAndBirthdate(
            idToContacts
        );
        System.assertEquals(
            contactIdToErrorMessage.get(contact.Id),
            System.Label.SSN_Last_4Digits_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test updation of encrypted Cassie Id fields on Legacy Contacts.
     */
    @isTest
    private static void testWhenCassieIdsNullOnLegacyContactsThenUpdateCassieIdFields() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Secondary_Email__c, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.Email_Cassie_ID__c, null)
            .setField(Contact.Secondary_Email_Cassie_ID__c, null)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        List<Contact> newContacts = new List<Contact>{ contact };
        Contact updatedContact = new Contact();
        updatedContact.Id = contact.Id;
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
        ContactsService.updateEncryptedCassieIdFieldsOnMigratedContacts(newContacts);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 1))
            .encryptCassieId(newContacts, EMAIL_FIELD, EMAIL_CASSIE_ID_FIELD);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 1))
            .encryptCassieId(newContacts, SECONDARY_EMAIL_FIELD, SECONDARY_EMAIL_CASSIE_ID_FIELD);
    }
    /**
     * @description To test updation of encrypted Cassie Id fields on Legacy Contacts.
     */
    @isTest
    private static void testWhenEmailIsNullOnLegacyContactsThenDontUpdateCassieIdFields() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Type, CORPORATE);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        List<Contact> newContacts = new List<Contact>{ contact };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICassieIdEncryptionService mockCassieIdEncryptionService = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );
        Application.SERVICE.setMock(
            ICassieIdEncryptionService.class,
            mockCassieIdEncryptionService
        );
        ContactsService.updateEncryptedCassieIdFieldsOnMigratedContacts(newContacts);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 0))
            .encryptCassieId(newContacts, EMAIL_FIELD, EMAIL_CASSIE_ID_FIELD);
        ((ICassieIdEncryptionService) mocks.verify(mockCassieIdEncryptionService, 0))
            .encryptCassieId(newContacts, SECONDARY_EMAIL_FIELD, SECONDARY_EMAIL_CASSIE_ID_FIELD);
    }
}