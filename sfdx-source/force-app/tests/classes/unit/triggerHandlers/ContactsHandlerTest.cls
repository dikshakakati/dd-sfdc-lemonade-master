/**
 * @author Deloitte
 * @date 16/03/2022
 * @description This is test class for Contacts Trigger Handler class
 */
@isTest
private class ContactsHandlerTest {
    /**
     * @description This method is used to test Contacts TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Contact> contactList = new List<Contact>();
        ContactsHandler contactHandlerObject = new ContactsHandler(contactList);
        ContactsHandler.Constructor objConstructor = new ContactsHandler.Constructor();
        objConstructor.construct(contactList);
        System.assertNotEquals(
            contactHandlerObject,
            objConstructor.construct(contactList),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test if the Cassie Id is encryption and DoNotCall field update
     * is triggered on contact update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsUpdatedThenCassieIdEncryptionAndDoNotCallUpdated() {
        Id contactId = Fake.generateId(Contact.class);
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Id = contactId,
                LastName = 'Test 1',
                Email = 'abc@gmail.com',
                Secondary_Email__c = 'xyz@gmail.com',
                Phone = '123456',
                SMS_Opted_Out__c = false
            )
        };
        Contact[] oldContacts = new List<Contact>{
            new Contact(
                Id = contactId,
                LastName = 'Test 1',
                Email = 'abcde@gmail.com',
                Secondary_Email__c = 'xyzab@gmail.com',
                Phone = '123456789',
                SMS_Opted_Out__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Contacts contactsMock = (Contacts) mocks.mock(Contacts.class);
        mocks.startStubbing();
        mocks.when(contactsMock.getType()).thenReturn(Schema.Contact.SObjectType);
        mocks.stopStubbing();
        ICassieIdEncryptionService serviceMock = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );
        IOptOutOfCommunicationsService optOutOfCommunicationsServiceMock = (IOptOutOfCommunicationsService) mocks.mock(
            IOptOutOfCommunicationsService.class
        );

        Application.SERVICE.setMock(ICassieIdEncryptionService.class, serviceMock);
        Application.SERVICE.setMock(
            IOptOutOfCommunicationsService.class,
            optOutOfCommunicationsServiceMock
        );
        Application.Domain.setMock(contactsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newContacts, new Map<Id, Contact>(oldContacts));
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newContacts, 'Email', 'Email_Cassie_ID__c');
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newContacts, 'Secondary_Email__c', 'Secondary_Email_Cassie_ID__c');
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 1))
            .updateDoNotCallAndSMSOptedOut(newContacts);
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 1))
            .updateDateSMSOptedOutOrIn(newContacts);
    }

    /**
     * @description To test if the Cassie Id is encryption and DoNotCall field update
     * is triggered on contact update.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactIsUpdatedThenDateSMSOptedOutNotUpdated() {
        Id contactId = Fake.generateId(Contact.class);
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Id = contactId,
                LastName = 'Test 1',
                Email = 'abc@gmail.com',
                Secondary_Email__c = 'xyz@gmail.com',
                Phone = '123456',
                SMS_Opted_Out__c = false
            )
        };
        Contact[] oldContacts = new List<Contact>{
            new Contact(
                Id = contactId,
                LastName = 'Test 1',
                Email = 'abcde@gmail.com',
                Secondary_Email__c = 'xyzab@gmail.com',
                Phone = '123456789',
                SMS_Opted_Out__c = false
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Contacts contactsMock = (Contacts) mocks.mock(Contacts.class);
        mocks.startStubbing();
        mocks.when(contactsMock.getType()).thenReturn(Schema.Contact.SObjectType);
        mocks.stopStubbing();
        IOptOutOfCommunicationsService optOutOfCommunicationsServiceMock = (IOptOutOfCommunicationsService) mocks.mock(
            IOptOutOfCommunicationsService.class
        );
        Application.SERVICE.setMock(
            IOptOutOfCommunicationsService.class,
            optOutOfCommunicationsServiceMock
        );
        Application.Domain.setMock(contactsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newContacts, new Map<Id, Contact>(oldContacts));
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        ((IOptOutOfCommunicationsService) mocks.verify(optOutOfCommunicationsServiceMock, 0))
            .updateDateSMSOptedOutOrIn(newContacts);
    }

    /**
     * @description To test method call on contact update
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactUpdatedThenCall() {
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 1',
                Phone = '7745678',
                Inbound_Ingestion_Log__c = null
            ),
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 2',
                Phone = '9745678',
                Inbound_Ingestion_Log__c = ingestionLogId
            )
        };

        Contact[] oldContacts = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 1',
                Phone = '8745678',
                Birthdate = Date.newInstance(1990, 3, 17),
                Inbound_Ingestion_Log__c = ingestionLogId
            ),
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 2',
                Phone = '9745678',
                Birthdate = null,
                Inbound_Ingestion_Log__c = null
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContacts contactsMock = (IContacts) mocks.mock(IContacts.class);
        mocks.startStubbing();
        mocks.when(contactsMock.getType()).thenReturn(Schema.Contact.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contactsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(newContacts, new Map<Id, SObject>(oldContacts));
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);

        ((IContacts) mocks.verify(contactsMock, 1)).validateAndNormalizePhoneNumberFormat();
        ((IContacts) mocks.verify(contactsMock, 1))
            .validateSSNAndBirthdateWithAccountingContactRole();
    }

    /**
     * @description To test method call on contact insert
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContactInsertedThenCall() {
        Contact[] newContacts = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 1',
                Phone = '8745678',
                Email = 'abc@gmail.com',
                Secondary_Email__c = 'xyz@gmail.com'
            ),
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.SObjectType),
                LastName = 'Test 2',
                Phone = '9795678',
                Email = 'abc@gmail.com',
                Secondary_Email__c = 'xyz@gmail.com'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContacts contactsMock = (IContacts) mocks.mock(IContacts.class);
        ICassieIdEncryptionService serviceMock = (ICassieIdEncryptionService) mocks.mock(
            ICassieIdEncryptionService.class
        );
        mocks.startStubbing();
        mocks.when(contactsMock.getType()).thenReturn(Schema.Contact.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(contactsMock);
        Application.SERVICE.setMock(ICassieIdEncryptionService.class, serviceMock);

        fflib_SObjectDomain.Test.Database.onInsert(newContacts);
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);

        ((IContacts) mocks.verify(contactsMock, 1)).validateAndNormalizePhoneNumberFormat();
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newContacts, 'Email', 'Email_Cassie_ID__c');
        ((ICassieIdEncryptionService) mocks.verify(serviceMock, 1))
            .encryptCassieId(newContacts, 'Secondary_Email__c', 'Secondary_Email_Cassie_ID__c');
    }

    /**
     * @description This method is used to test bypassing before insert trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableBeforeInsertTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_INSERT;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.BEFORE_INSERT))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing after insert trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableAfterInsertTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_INSERT;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.AFTER_INSERT))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing before update trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableBeforeUpdateTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_UPDATE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.BEFORE_UPDATE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing after update trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableAfterUpdateTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_UPDATE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.AFTER_UPDATE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing before delete trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableBeforeDeleteTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_DELETE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.BEFORE_DELETE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing after delete trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableAfterDeleteTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_DELETE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.AFTER_DELETE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description This method is used to test bypassing after undelete trigger context.
     */
    @isTest
    private static void testWhenBypassReturnsTrueThenItShouldDisableAfterUnDeleteTriggerContext() {
        Id contact1Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contact2Id = fflib_IDGenerator.generate(Contact.SObjectType);
        // Arrange
        Contact[] newContacts = new List<Contact>{
            new Contact(Id = contact1Id, LastName = 'Test 1'),
            new Contact(Id = contact2Id, LastName = 'Test 2')
        };
        fflib_SObjectDomain.Test.Database.onInsert(newContacts);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        SystemFacade.triggerContext = System.TriggerOperation.AFTER_UNDELETE;
        mocks.startStubbing();
        mocks.when(bypassMock.isTriggerBypassed('Contact', System.TriggerOperation.AFTER_UNDELETE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        // Act
        fflib_SObjectDomain.triggerHandler(ContactsHandler.class);
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUnDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(ContactsHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description To test Contacts Trigger
     */
    @isTest
    private static void testWhenContactsTriggerIsCalledThenContactIsInserted() {
        Account acc = new Account(Name = 'Test 1',Segment__c='SMB');
        insert acc;
        Contact contact = new Contact(
            LastName = 'Test',
            FirstName = '1',
            Phone = '908329',
            Email = 'test@email.com',
            AccountId = acc.Id
        );
        insert contact;
        System.assertNotEquals(null, contact.Id, 'Id is null');
    }
}