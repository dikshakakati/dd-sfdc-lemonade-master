/**
 * @author Deloitte
 * @date 05/12/2022
 * @description This is test class for AccountContactRelations class.
 */
@isTest(seeAllData=false)
private class AccountContactRelationsTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'DOBReadinessCheckCountriesStates';
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_EVENT_TYPE_FALLOUT = 'Fallout Event';
    private static final String CONTACT_EVENT_TYPE_ONBOARDING = 'Onboarding Event';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String DECISION_MAKER_ROLE = 'Decision Maker';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE = 'US,CA,AU-QLD';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN = 'US';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_AU = 'AU';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_US = 'US';
    private static final String ELIGIBLE_STATE_TO_VALIDATE_QLD = 'QLD';
    private static final String INFLUENCER_ROLE = 'Influencer';
    private static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String ROLES_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in Roles on Account Contact Relation.';
    private static final String SSN_LAST_FOUR_DIGITS = '1234';
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String VERTICAL = 'Floral';
    private static final String CORPORATE = 'Corporate';
    private static final String UNEXPECTED_ERROR = 'Unexpected Error: Error Message Map were not fetched correctly.';
    private static final String UNIQUE_IDENTIFIER1 = '12345a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String UNIQUE_IDENTIFIER2 = '92108a53-e8d9-4a0c-3982-9152aeb86fe4';
    private static final String UNIQUE_IDENTIFIER3 = '01832a53-e8d9-4a0c-3812-9234aeb86fe4';
    private static final String ACCOUNTING_CONTACT = 'Accounting Contact';

    /**
     * @description This is method used to test Contacts class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<AccountContactRelation> accountContactRelationsRecords = new List<AccountContactRelation>();
        //Default Constructor Call
        AccountContactRelations accountContactRelationsObject = new AccountContactRelations(
            accountContactRelationsRecords
        );
        //IAccountContactRelations Instance Creation Call
        AccountContactRelations.newInstance(accountContactRelationsRecords);
        System.assertNotEquals(
            AccountContactRelations.newInstance(accountContactRelationsRecords),
            accountContactRelationsObject,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description To test validation of AccountContactRelation with Accounting Contact Role
     * when contact associated is attached to store account and has blank birthdate, the store account
     * has Billing Country as Australia and State as Queensland and
     * it's corporate parent has subscriptions which include
     * alcohol delivery or alcohol pickup with
     */
    @isTest
    private static void testWhenACRHavingAccountingContactRoleWithContactHavingBlankBirthdateWithStoreCorporateParentHasAlcoholSubscriptionsWithEligibleBillingCountryAndStateThenValidateBirthdate() {
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

        Account mcDonaldCorporate = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                mcDonaldCorporate.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setParent('Parent', businessAccountFakeInstance);
        Account mcDonaldStore = (Account) ServiceMockDataBuilder.convertToSObject(
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
            .setField(Contact.AccountId, mcDonaldStore.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setField(Contact.Id, contactId)
            .toSObject();
        List<AccountContactRelation> newACR = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId,
                AccountId = mcDonaldStore.Id,
                ContactId = newContact.Id,
                Roles = ACCOUNTING_CONTACT
            )
        };
        List<Contact> newContacts = new List<Contact>{ newContact };
        Map<Id, List<Contact>> idToContacts = new Map<Id, List<Contact>>();
        idToContacts.put(mcDonaldStore.id, newContacts);

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
        Set<Id> contactIds = new Set<Id>{ newContact.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelectorSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
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
        mocks.when(mockContactsSelectorSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelectorSelector.selectById(contactIds)).thenReturn(newContacts);
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ mcDonaldStore.Id }
                )
            )
            .thenReturn(new List<Account>{ mcDonaldStore });
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

        Application.SELECTOR.setMock(mockContactsSelectorSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        //Act
        AccountContactRelations.newInstance(newACR).validateSSNAndBirthdate();
        //Assert
        System.assertEquals(
            newACR[0].getErrors()[0].getMessage(),
            System.Label.Birthdate_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test validation of AccountContactRelation with Accounting Contact Role
     * when contact associated is attached to store account and has blank SSN, the store account
     * has Billing Country as Australia and State as Queensland and
     * it's corporate parent has subscriptions which include
     * alcohol delivery or alcohol pickup with
     */
    @isTest
    private static void testWhenACRHavingAccountingContactRoleWithContactHavingBlankSSNWithStoreCorporateParentHasAlcoholSubscriptionsWithEligibleBillingCountryAndStateThenValidateSSN() {
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

        Account mcDonaldCorporate = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                mcDonaldCorporate.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setParent('Parent', businessAccountFakeInstance);
        Account mcDonaldStore = (Account) ServiceMockDataBuilder.convertToSObject(
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
            .setField(Contact.AccountId, mcDonaldStore.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setField(Contact.Id, contactId)
            .toSObject();
        List<AccountContactRelation> newACR = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId,
                AccountId = mcDonaldStore.Id,
                ContactId = newContact.Id,
                Roles = ACCOUNTING_CONTACT
            )
        };
        List<Contact> newContacts = new List<Contact>{ newContact };
        Map<Id, List<Contact>> idToContacts = new Map<Id, List<Contact>>();
        idToContacts.put(mcDonaldStore.id, newContacts);

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
        Set<Id> contactIds = new Set<Id>{ newContact.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelectorSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
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
        mocks.when(mockContactsSelectorSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelectorSelector.selectById(contactIds)).thenReturn(newContacts);
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.getStoreAccountsWithParentCorporate(
                    new Set<Id>{ mcDonaldStore.Id }
                )
            )
            .thenReturn(new List<Account>{ mcDonaldStore });
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

        Application.SELECTOR.setMock(mockContactsSelectorSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        //Act
        AccountContactRelations.newInstance(newACR).validateSSNAndBirthdate();
        //Assert
        System.assertEquals(
            newACR[0].getErrors()[0].getMessage(),
            System.Label.SSN_Last_4Digits_Error_Message,
            UNEXPECTED_ERROR
        );
    }

    /**
     * @description To test validation of creation of OCR when AccountContactRelation with
     * Decision Maker Role is inserted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenACRHavingDecisionMakerRoleInsertedThenValidateOCRCreation() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accountContactRelationId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake accountFakeInstance = new Fake(Account.class).setField(Account.Id, accountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId)
            .setField(Contact.Id, contactId);
        Fake accountContactRelationFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.Id, accountContactRelationId)
            .setField(AccountContactRelation.AccountId, accountId)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(AccountContactRelation.Roles, 'Decision Maker')
            .setParent('Account', accountFakeInstance)
            .setParent('Contact', contactFakeInstance);
        AccountContactRelation acrRecord = (AccountContactRelation) ServiceMockDataBuilder.convertToSObject(
            accountContactRelationFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Type, 'New');
        Opportunity opportunityRecord = (Opportunity) opportunityFakeInstance.toSObject();
        Map<Id, Id> opportunityToContactIdMap = new Map<Id, Id>();
        opportunityToContactIdMap.put(opportunityId, contactId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunityContactRoleService serviceMock = (IOpportunityContactRoleService) mocks.mock(
            IOpportunityContactRoleService.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.selectOpportunitiesAndQuotesByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Opportunity>{ opportunityRecord });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SERVICE.setMock(IOpportunityContactRoleService.class, serviceMock);
        //Act
        AccountContactRelations.newInstance(new List<AccountContactRelation>{ acrRecord })
            .validateOCRCreation();
        //Assert
        ((IOpportunityContactRoleService) mocks.verify(serviceMock, 0))
            .createOCR(opportunityToContactIdMap, true);
    }

    /**
     * @description To test updateRolesByEventType method call on
     * insert of AccountContactRelation records.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountContactRelationInsertedThenCallUpdateRolesByEventType() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id falloutContactId = Fake.generateId(Contact.class);
        Id newContactId = Fake.generateId(Contact.class);
        Id onboardingContactId = Fake.generateId(Contact.class);
        Id falloutACRId = Fake.generateId(AccountContactRelation.class);
        Id newACRId = Fake.generateId(AccountContactRelation.class);
        Id onboardingACRId = Fake.generateId(AccountContactRelation.class);
        Fake account1FakeInstance = new Fake(Account.class).setField(Account.Id, accountId1);
        Fake account2FakeInstance = new Fake(Account.class).setField(Account.Id, accountId2);
        Fake falloutContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId1)
            .setField(Contact.Event_Type__c, CONTACT_EVENT_TYPE_FALLOUT)
            .setField(Contact.Unique_Identifier__c, UNIQUE_IDENTIFIER1)
            .setField(Contact.Id, falloutContactId);
        Contact falloutContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            falloutContactFakeInstance
        );
        Fake onboardingContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId2)
            .setField(Contact.Event_Type__c, CONTACT_EVENT_TYPE_ONBOARDING)
            .setField(Contact.Unique_Identifier__c, UNIQUE_IDENTIFIER2)
            .setField(Contact.Id, onboardingContactId);
        Contact onboardingContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            onboardingContactFakeInstance
        );
        Fake newContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId1)
            .setField(Contact.Unique_Identifier__c, UNIQUE_IDENTIFIER3)
            .setField(Contact.Id, newContactId);
        Contact newContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            newContactFakeInstance
        );
        Fake falloutACRFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.Id, falloutACRId)
            .setField(AccountContactRelation.AccountId, accountId1)
            .setField(AccountContactRelation.ContactId, falloutContact.Id)
            .setParent('Account', account1FakeInstance)
            .setParent('Contact', falloutContactFakeInstance);
        Fake onboardingACRFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.Id, onboardingACRId)
            .setField(AccountContactRelation.AccountId, accountId2)
            .setField(AccountContactRelation.ContactId, onboardingContact.Id)
            .setParent('Account', account2FakeInstance)
            .setParent('Contact', onboardingContactFakeInstance);
        Fake newACRFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.Id, newACRId)
            .setField(AccountContactRelation.AccountId, accountId1)
            .setField(AccountContactRelation.ContactId, newContact.Id)
            .setParent('Account', account1FakeInstance)
            .setParent('Contact', onboardingContactFakeInstance);
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>{
            (AccountContactRelation) ServiceMockDataBuilder.convertToSObject(
                falloutACRFakeInstance
            ),
            (AccountContactRelation) ServiceMockDataBuilder.convertToSObject(
                onboardingACRFakeInstance
            ),
            (AccountContactRelation) ServiceMockDataBuilder.convertToSObject(newACRFakeInstance)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelectorSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockContactsSelectorSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockContactsSelectorSelector.selectById(
                    new Set<Id>{ falloutContactId, newContactId, onboardingContactId }
                )
            )
            .thenReturn(new List<Contact>{ falloutContact, newContact, onboardingContact });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContactsSelectorSelector);
        AccountContactRelations.newInstance(newAccountContactRelations).updateRolesByEventType();
        System.assertEquals(
            INFLUENCER_ROLE,
            newAccountContactRelations[0].Roles,
            ROLES_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            DECISION_MAKER_ROLE,
            newAccountContactRelations[1].Roles,
            ROLES_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newAccountContactRelations[2].Roles,
            ROLES_MISMATCH_ASSERT_MESSAGE
        );
    }
}