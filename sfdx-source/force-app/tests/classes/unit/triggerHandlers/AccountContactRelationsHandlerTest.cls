/**
 * @author Deloitte
 * @date 05/12/2022
 * @description This is test class for AccountContactRelation Trigger Handler class
 */
@isTest
private class AccountContactRelationsHandlerTest {
    private static final String ACCOUNTING_CONTACT = 'Accounting Contact';
    private static final String CONTACT_EMAIL = 'testEmail@sampleContact.com';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String CONTACT_EVENT_TYPE_FALLOUT = 'Fallout Event';
    private static final String CONTACT_EVENT_TYPE_ONBOARDING = 'Onboarding Event';
    /**
     * @description To test method call on AccountContactRelation update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountContactRelationUpdatedWithAccountingRoleThenCall() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id accountContactRelationId1 = Fake.generateId(AccountContactRelation.class);
        Id accountContactRelationId2 = Fake.generateId(AccountContactRelation.class);
        List<AccountContactRelation> oldAccountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId1,
                AccountId = accountId1,
                ContactId = contactId
            ),
            new AccountContactRelation(
                Id = accountContactRelationId2,
                AccountId = accountId2,
                ContactId = contactId
            )
        };
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(Id = accountContactRelationId1, Roles = ACCOUNTING_CONTACT),
            new AccountContactRelation(Id = accountContactRelationId2, AccountId = accountId1)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelations accountContactRelationMock = (IAccountContactRelations) mocks.mock(
            IAccountContactRelations.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationMock.getType())
            .thenReturn(Schema.AccountContactRelation.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountContactRelationMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newAccountContactRelations,
            new Map<Id, AccountContactRelation>(oldAccountContactRelations)
        );
        fflib_SObjectDomain.triggerHandler(AccountContactRelationsHandler.class);

        ((IAccountContactRelations) mocks.verify(accountContactRelationMock, 1))
            .validateSSNAndBirthdate();
    }

    /**
     * @description To test method call on AccountContactRelation insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountContactRelationInsertedWithAccountingRoleThenCall() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id accountContactRelationId1 = Fake.generateId(AccountContactRelation.class);
        Id accountContactRelationId2 = Fake.generateId(AccountContactRelation.class);
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId1,
                AccountId = accountId1,
                ContactId = contactId,
                Roles = ACCOUNTING_CONTACT
            ),
            new AccountContactRelation(
                Id = accountContactRelationId2,
                AccountId = accountId2,
                ContactId = contactId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelations accountContactRelationMock = (IAccountContactRelations) mocks.mock(
            IAccountContactRelations.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationMock.getType())
            .thenReturn(Schema.AccountContactRelation.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountContactRelationMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccountContactRelations);
        fflib_SObjectDomain.triggerHandler(AccountContactRelationsHandler.class);

        ((IAccountContactRelations) mocks.verify(accountContactRelationMock, 1))
            .validateSSNAndBirthdate();
    }

    /**
     * @description To test method call on Decision Maker AccountContactRelation insert
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountContactRelationInsertedWithDecisionMakerRoleThenCall() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id accountContactRelationId1 = Fake.generateId(AccountContactRelation.class);
        Id accountContactRelationId2 = Fake.generateId(AccountContactRelation.class);
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId1,
                AccountId = accountId1,
                ContactId = contactId,
                Roles = 'Decision Maker'
            ),
            new AccountContactRelation(
                Id = accountContactRelationId2,
                AccountId = accountId2,
                ContactId = contactId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelations accountContactRelationMock = (IAccountContactRelations) mocks.mock(
            IAccountContactRelations.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationMock.getType())
            .thenReturn(Schema.AccountContactRelation.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountContactRelationMock);

        fflib_SObjectDomain.Test.Database.onInsert(newAccountContactRelations);
        fflib_SObjectDomain.triggerHandler(AccountContactRelationsHandler.class);

        ((IAccountContactRelations) mocks.verify(accountContactRelationMock, 1))
            .validateOCRCreation();
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
        Id onboardingContactId = Fake.generateId(Contact.class);
        Id accountContactRelationId1 = Fake.generateId(AccountContactRelation.class);
        Id accountContactRelationId2 = Fake.generateId(AccountContactRelation.class);
        Fake falloutContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId1)
            .setField(Contact.Event_Type__c, CONTACT_EVENT_TYPE_FALLOUT)
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
            .setField(Contact.Id, onboardingContactId);
        Contact onboardingContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            onboardingContactFakeInstance
        );
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = accountContactRelationId1,
                AccountId = accountId1,
                ContactId = falloutContact.Id
            ),
            new AccountContactRelation(
                Id = accountContactRelationId2,
                AccountId = accountId2,
                ContactId = onboardingContact.Id
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelations accountContactRelationMock = (IAccountContactRelations) mocks.mock(
            IAccountContactRelations.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationMock.getType())
            .thenReturn(Schema.AccountContactRelation.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(accountContactRelationMock);
        fflib_SObjectDomain.Test.Database.onInsert(newAccountContactRelations);
        fflib_SObjectDomain.triggerHandler(AccountContactRelationsHandler.class);
        ((IAccountContactRelations) mocks.verify(accountContactRelationMock, 1))
            .updateRolesByEventType();
    }
}