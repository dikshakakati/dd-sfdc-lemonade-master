/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Test class for SSMOLeadConversionServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class SSMOLeadConversionServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';

    private static final String ASSERT_MESSAGE_LEAD_CONVERSION_FAILED = 'Unexpected result: Lead auto conversion failed';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String DML_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String LEAD_CONVERSION_TYPE_AUTO = 'Auto';
    private static final String LEAD_FIRSTNAME = 'Mc Donald';
    private static final String LEAD_LASTNAME = 'Australia';
    private static final String VERTICAL = 'Rx';
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String UNEXPECTED_DML_EXCEPTION_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException.';

    /**
     * @description To test whether Lead gets auto converted.
     */
    @isTest
    private static void testWhenIngestionIdsPassedThenMatchingLeadsGetAutoConverted() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Id mcDonaldLeadId = payload.store.MatchedRecords.lead[0].id;
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = payload.store.MatchedRecords.contact[0].id;
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        Lead newLead = new Lead(
            Id = mcDonaldLeadId,
            FirstName = LEAD_FIRSTNAME,
            LastName = LEAD_LASTNAME,
            IsConverted = false,
            Lead_Conversion_Type__c = LEAD_CONVERSION_TYPE_AUTO,
            SSMO_UUID__c = UNIQUE_IDENTIFIER
        );
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId)
            .setField(Contact.Id, contactId);
        Contact newContact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ILeadsSelector mockLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IInboundIngestionLogsSelector mockIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ newContact });
        mocks.when(
                mockContactsSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Contact>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFIER },
                    BUSINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockLeadsSelector.sObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(mockLeadsSelector.selectById(new Set<Id>{ mcDonaldLeadId }))
            .thenReturn(new List<Lead>{ newLead });
        mocks.when(
                mockLeadsSelector.selectByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER })
            )
            .thenReturn(new List<Lead>{});
        mocks.when(mockIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLog });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContactsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockLeadsSelector);
        Application.SELECTOR.setMock(mockIngestionLogsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        SSMOLeadConversionService.autoConvertLeads(
            new Set<Id>{ ingestionLogId },
            new Map<String, InstantIngestionPayloadParser>{ payload.Uuid => payload }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Lead.Id => mcDonaldLeadId,
                        Lead.Lead_Conversion_Type__c => LEAD_CONVERSION_TYPE_AUTO
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test whether Lead gets auto converted.
     */
    @isTest
    private static void testWhenIngestionIdsPassedThenMatchingLeadsDoNotGetAutoConverted() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Id mcDonaldLeadId = payload.store.MatchedRecords.lead[0].id;
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = payload.store.MatchedRecords.contact[0].id;
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLog = new Inbound_Ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        Lead newLead = new Lead(
            Id = mcDonaldLeadId,
            FirstName = LEAD_FIRSTNAME,
            LastName = LEAD_LASTNAME,
            IsConverted = false,
            Lead_Conversion_Type__c = LEAD_CONVERSION_TYPE_AUTO,
            SSMO_UUID__c = UNIQUE_IDENTIFIER
        );
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, accountId)
            .setField(Contact.Id, contactId);
        Contact newContact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ILeadsSelector mockLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IInboundIngestionLogsSelector mockIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(DML_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ newContact });
        mocks.when(
                mockContactsSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Contact>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFIER },
                    BUSINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockLeadsSelector.sObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(mockLeadsSelector.selectById(new Set<Id>{ mcDonaldLeadId }))
            .thenReturn(new List<Lead>{});
        mocks.when(
                mockLeadsSelector.selectByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER })
            )
            .thenReturn(new List<Lead>{ newLead });
        mocks.when(mockIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLog });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContactsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockLeadsSelector);
        Application.SELECTOR.setMock(mockIngestionLogsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            SSMOLeadConversionService.autoConvertLeads(
                new Set<Id>{ ingestionLogId },
                new Map<String, InstantIngestionPayloadParser>{ payload.Uuid => payload }
            );
        } catch (Exception e) {
            System.assertEquals(
                DML_EXCEPTION_MESSAGE,
                e.getMessage(),
                UNEXPECTED_DML_EXCEPTION_MESSAGE
            );
        }
    }

    /**
     * @description To test when passed SSMO UUID on Lead does not match on Lead
     * no auto conversion.
     */
    @isTest
    private static void testWhenIngestionIdsPassedAndNoMatchingIngestionLogsFoundThenNoAutoConversion() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Id ingestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Id leadId = payload.store.MatchedRecords.lead[0].id;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ILeadsSelector mockLeadsSelector = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IInboundIngestionLogsSelector mockIngestionLogsSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockContactsSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Contact>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFIER },
                    BUSINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(mockLeadsSelector.sObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(mockLeadsSelector.selectById(new Set<Id>{ leadId }))
            .thenReturn(new List<Lead>{});
        mocks.when(
                mockLeadsSelector.selectByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER })
            )
            .thenReturn(new List<Lead>{});
        mocks.when(mockIngestionLogsSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockIngestionLogsSelector.selectById(new Set<Id>{ ingestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContactsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockLeadsSelector);
        Application.SELECTOR.setMock(mockIngestionLogsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        SSMOLeadConversionService.autoConvertLeads(
            new Set<Id>{ ingestionLogId },
            new Map<String, InstantIngestionPayloadParser>{ payload.Uuid => payload }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}