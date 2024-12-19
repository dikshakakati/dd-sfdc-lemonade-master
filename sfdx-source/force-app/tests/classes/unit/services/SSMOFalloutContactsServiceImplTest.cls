/**
 * @author Deloitte
 * @date 16/03/2022
 * @description This is test class for Contacts Trigger Handler class
 */
@isTest
public class SSMOFalloutContactsServiceImplTest {
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String FORMER_PARTNER = 'Former Partner';
    private static final String EXISTING_PARTNER = 'Existing Partner';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String STATUS_PENDING = 'Pending';
    private static final String SSMO = 'SSMO';
    private static final String UUID = 'a436236c-595d-4891-99d8-3d8c931d9f82';
    private static final String CONTACT_FIRSTNAME = 'Matched';
    private static final String CONTACT_LASTNAME = 'Contact';
    private static final String CONTACT_EMAIL = 'test@testemail.com';
    private static final String ASSERT_MESSAGE_MISMATCH = 'Unexpected result: There is a mismatch in Result.';
    private static final Date AFTERTHIRTYDAYS = System.today().addDays(30);
    private static final String DECISION_MAKER_CONTACT = 'Decision Maker';
    private static final String COMPLETED = 'Completed';
    private static final String OPPORTUNITY_SOURCE_FIELD ='Source__c';
    private static final String SOURCE_NOT_MATCHING_ERROR = 'Unexpected result: There is a mismatch in Opportunity Source value.';

    /**
     * @description  It is used verify when matched account and matched contact is found from the payload and
     * the account has an opportunity, ACR, OCR.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMatchedAccountContactOpportunityACROCRIsFoundThenCreateTask() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Account businessParentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, 'Test Parent')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .toSObject();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .setChildren(
                'Opportunities',
                new List<Fake>{
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId)
                        .setField(
                            Opportunity.Name,
                            BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1'
                        )
                        .setField(Opportunity.CloseDate, AFTERTHIRTYDAYS)
                        .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
                        .setField(Opportunity.AccountId, businessAccountId)
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();

        List<Account> accounts = new List<Account>{ businessAccount };

        String testPayload =
            '[{"matchedrecords":{"lead":[{"id":"abc123"}],"contact":[{"id":"' +
            contactId +
            '"}],"account":[{"id":"' +
            businessAccountId +
            '"}]}}]';
        Inbound_Ingestion_Log__c log = new Inbound_Ingestion_Log__c(
            Id = inboundInjestionLogId,
            Payload__c = testPayload,
            Status__c = STATUS_PENDING,
            UUID__c = UUID,
            Integration_Type__c = SSMO,
            Created_Date_Time__c = system.now()
        );
        List<Contact> contacts = new List<Contact>();
            Contact contactRecord = (Contact) new Fake(Contact.class)
                .setField(Contact.Id, contactId)
                .setField(Contact.AccountID, businessAccountId)
                .setField(Contact.FirstName, CONTACT_FIRSTNAME)
                .setField(Contact.LastName, CONTACT_LASTNAME)
                .setField(Contact.Email, CONTACT_EMAIL)
                .setField(Contact.SSMO_Business_Account_Id__c, businessAccountId)
                .setField(Contact.Email, CONTACT_EMAIL)
                .setField(Contact.Last_Inbound_Date_Time__c, system.now())
                .setField(Contact.Inbound_Ingestion_Log__c,inboundInjestionLogId )
                .setParent('Account', new Fake(Account.class)
                           .setField(Account.Id, businessAccountId))
            .toSObject();
        contacts.add(contactRecord);

        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1')
            .setField(Opportunity.CloseDate, AFTERTHIRTYDAYS)
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, contactId)
                    .setField(Contact.Phone, null)
            )
            .setParent('Account', new Fake(Account.class).setField(Account.Id, businessAccountId))
            .setChildren(
                'OpportunityContactRoles',
                new List<Fake>{
                    new Fake(OpportunityContactRole.class)
                        .setField(OpportunityContactRole.ContactId, contactId)
                        .setField(OpportunityContactRole.Role, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                }
            )
            .toSObject();
        List<Opportunity> opportunities = new List<Opportunity>{ opportunityRecord };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(accounts);
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountsByUltimateParentAccountIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(new List<Account>{ businessParentAccount });
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(accounts);
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);

        mocks.when(
                opportunitiesSelectorMock.selectOpportunitiesAndOpportunityContactRolesByIds(
                    new Set<Id>{ opportunityId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(opportunities);
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);

        mocks.when(
                inboundIngestionLogsSelectorMock.selectById(new Set<Id>{ inboundInjestionLogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ log });
        mocks.when(inboundIngestionLogsSelectorMock.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(contacts);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Task.WhatId => opportunityId,
                        Task.Subject => 'SSMO Drop Off',
                        Task.Type => 'SSMO Drop Off',
                        Task.ActivityDate => System.today().addDays(1)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunityId,
                        Opportunity.Last_Inbound_Date_Time__c  => log.Created_Date_Time__c
                    }
                )
            );
    }
    /**
     * @description It is used verify when matched account and matched contact is found from the payload
     * got exception on opportunity creation.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMatchedAccountContactIsFoundThenCreateOpportunityException() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id userFakeId1 = fflib_IDGenerator.generate(User.SObjectType);

        List<User> users = new List<user>{
            new User(
                Id = userFakeId1,
                FirstName = 'Holding',
                LastName = 'User',
                Email = 'test1@user.com'
            )
        };

        Account businessParentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();

        List<Account> accounts = new List<Account>{ businessParentAccount };

        String testPayload =
            '[{"matchedrecords":{"lead":[{"id":"abc123"}],"contact":[{"id":"' +
            contactId +
            '"}],"account":[{"id":"' +
            businessAccountId +
            '"}]}}]';
        Inbound_Ingestion_Log__c log = new Inbound_Ingestion_Log__c(
            Id = inboundInjestionLogId,
            Payload__c = testPayload,
            Status__c = STATUS_PENDING,
            UUID__c = UUID,
            Integration_Type__c = SSMO
        );
        List<Contact> contacts = new List<Contact>{
            new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME,
                Email = CONTACT_EMAIL,
                SSMO_Business_Account_Id__c = businessAccountId,
                Inbound_Ingestion_Log__c = inboundInjestionLogId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IUsersSelector usersSelectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
		IInboundIngestionLogs inboundIngestionMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        inboundIngestionMock.updateIngestionLogsWithSucessOrFailureStatus(
            new Set<Id>{ inboundInjestionLogId },
            COMPLETED,
            '',
            '',
            ''
        );
        mocks.startStubbing();

        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(usersSelectorMock.sObjectType()).thenReturn(User.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(accounts);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(accounts);

        mocks.when(
                inboundIngestionLogsSelectorMock.selectById(new Set<Id>{ inboundInjestionLogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ log });

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(accounts);

        mocks.when(usersSelectorMock.selectUserByName('Holding User')).thenReturn(users);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.SELECTOR.setMock(usersSelectorMock);
        Application.DOMAIN.setMock(inboundIngestionMock);

        SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(contacts);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionMock, 1))
            .updateIngestionLogsWithSucessOrFailureStatus(
                new Set<Id>{ inboundInjestionLogId },
                COMPLETED,
                '',
                '',
                ''
            );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
    	Boolean hasOpportunitySourceAsSSMO = ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(OPPORTUNITY_SOURCE_FIELD) == SSMO;
        System.assertEquals(
            true,
            hasOpportunitySourceAsSSMO,
            SOURCE_NOT_MATCHING_ERROR
        );
	}

    /**
     * @description  It is used verify when matched account and matched contact is found from the payload and
     * the account has an opportunity.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMatchedAccountContactOpportunityIsFoundThenCreateTaskACROCR() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id businessParentAccountId = Fake.generateId(Account.class);
        Id businessAssociatedAccountId = Fake.generateId(Account.class);

        Id contactId = Fake.generateId(Contact.class);
        Id contactId1 = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Account businessAssociatedAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAssociatedAccountId)
            .setField(Account.Name, 'Test Parent')
            .setField(Account.Ultimate_Parent_Account__c, businessParentAccountId)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAssociatedAccountId)
                        .setField(AccountContactRelation.ContactId, contactId1)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId1)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class)
                                .setField(Account.Id, businessAssociatedAccountId)
                        )
                }
            )
            .toSObject();

        Account businessParentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessParentAccountId)
            .setField(Account.Name, 'Test Parent')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId1)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId1)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessParentAccountId)
                        )
                }
            )
            .toSObject();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Ultimate_Parent_Account__c, businessParentAccountId)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId1)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId1)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .setChildren(
                'Opportunities',
                new List<Fake>{
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId)
                        .setField(
                            Opportunity.Name,
                            BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1'
                        )
                        .setField(Opportunity.CloseDate, AFTERTHIRTYDAYS)
                        .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
                        .setField(Opportunity.AccountId, businessAccountId)
                        .setField(Opportunity.StageName, 'Prospecting')
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();

        List<Account> accounts = new List<Account>{ businessAccount };

        String testPayload =
            '[{"matchedrecords":{"lead":[{"id":"abc123"}],"contact":[{"id":"' +
            contactId +
            '"}],"account":[{"id":"' +
            businessAccountId +
            '"}]}}]';
        Inbound_Ingestion_Log__c log = new Inbound_Ingestion_Log__c(
            Id = inboundInjestionLogId,
            Payload__c = testPayload,
            Status__c = STATUS_PENDING,
            UUID__c = UUID,
            Integration_Type__c = 'Fallout event'
        );
        List<Contact> contacts = new List<Contact>{
            new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME,
                Email = CONTACT_EMAIL,
                SSMO_Business_Account_Id__c = businessAccountId,
                Inbound_Ingestion_Log__c = inboundInjestionLogId
            )
        };

        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1')
            .setField(Opportunity.CloseDate, System.today().addDays(30))
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setParent('Account', new Fake(Account.class).setField(Account.Id, businessAccountId))
            .toSObject();
        List<Opportunity> opportunities = new List<Opportunity>{ opportunityRecord };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                opportunitiesSelectorMock.selectOpportunitiesAndOpportunityContactRolesByIds(
                    new Set<Id>{ opportunityId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(opportunities);
        mocks.when(inboundIngestionLogsSelectorMock.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(accounts);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessParentAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(new List<Account>{ businessParentAccount });

        mocks.when(
                acountsSelectorMock.selectAccountsByUltimateParentAccountIds(
                    new Set<Id>{ businessParentAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(new List<Account>{ businessAssociatedAccount });

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(accounts);

        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);

        mocks.when(
                inboundIngestionLogsSelectorMock.selectById(new Set<Id>{ inboundInjestionLogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ log });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(contacts);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Task.WhatId => opportunityId,
                        Task.Subject => 'SSMO Drop Off',
                        Task.Type => 'SSMO Drop Off',
                        Task.ActivityDate => System.today().addDays(1)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        opportunityContactRole.ContactId => contactId,
                        opportunityContactRole.OpportunityId => opportunityId,
                        opportunityContactRole.Role => 'Influencer',
                        opportunityContactRole.IsPrimary => false
                    }
                )
            );
    }
    /**
     * @description  It is used verify when matched account and matched contact is found from the payload and
     * the account has an opportunity, ACR.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMatchedAccountContactOpportunityACRIsFoundThenCreateTasKOCR() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id businessChildAccountId = Fake.generateId(Account.class);

        Id contactId = Fake.generateId(Contact.class);
        Id contactId1 = Fake.generateId(Contact.class);
        Id inboundInjestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessChildAccountId)
            .setField(Account.Name, 'Test Parent')
            .setField(Account.Ultimate_Parent_Account__c, businessAccountId)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessChildAccountId)
                        )
                }
            )
            .toSObject();

        Account businessParentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Partnership_Status__c, EXISTING_PARTNER)
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, businessAccountId)
                        .setField(AccountContactRelation.ContactId, contactId1)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId1)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .setChildren(
                'Opportunities',
                new List<Fake>{
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId)
                        .setField(
                            Opportunity.Name,
                            BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1'
                        )
                        .setField(Opportunity.CloseDate, AFTERTHIRTYDAYS)
                        .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
                        .setField(Opportunity.AccountId, businessAccountId)
                        .setField(Opportunity.StageName, 'Prospecting')
                        .setParent(
                            'Account',
                            new Fake(Account.class).setField(Account.Id, businessAccountId)
                        )
                }
            )
            .toSObject();

        List<Account> accounts = new List<Account>{ businessParentAccount };

        String testPayload =
            '[{"matchedrecords":{"lead":[{"id":"abc123"}],"contact":[{"id":"' +
            contactId +
            '"}],"account":[{"id":"' +
            businessAccountId +
            '"}]}}]';
        Inbound_Ingestion_Log__c log = new Inbound_Ingestion_Log__c(
            Id = inboundInjestionLogId,
            Payload__c = testPayload,
            Status__c = STATUS_PENDING,
            UUID__c = UUID,
            Integration_Type__c = SSMO
        );
        List<Contact> contacts = new List<Contact>{
            new Contact(
                Id = contactId,
                AccountID = businessAccountId,
                FirstName = CONTACT_FIRSTNAME,
                LastName = CONTACT_LASTNAME,
                Email = CONTACT_EMAIL,
                SSMO_Business_Account_Id__c = businessAccountId,
                Inbound_Ingestion_Log__c = inboundInjestionLogId
            )
        };

        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME + ' - Q2 28  - Upgrade: Test1')
            .setField(Opportunity.CloseDate, System.today().addDays(30))
            .setField(Opportunity.Opportunity_Sub_Type__c, 'Upgrade')
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setParent('Account', new Fake(Account.class).setField(Account.Id, businessAccountId))
            .toSObject();
        List<Opportunity> opportunities = new List<Opportunity>{ opportunityRecord };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector acountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();

        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(acountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(accounts);

        mocks.when(
                acountsSelectorMock.selectAccountsByUltimateParentAccountIds(
                    new Set<Id>{ businessAccountId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(new List<Account>{ businessAccount });

        mocks.when(
                acountsSelectorMock.selectAccountAndRelatedOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(accounts);

        mocks.when(
                opportunitiesSelectorMock.selectOpportunitiesAndOpportunityContactRolesByIds(
                    new Set<Id>{ opportunityId },
                    new List<Id>{ contactId }
                )
            )
            .thenReturn(opportunities);

        mocks.when(
                inboundIngestionLogsSelectorMock.selectById(new Set<Id>{ inboundInjestionLogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ log });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        Application.SELECTOR.setMock(acountsSelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        SSMOFalloutContactsService.createRelatedRecordsBasedOnSSMOPayload(contacts);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Task.WhatId => opportunityId,
                        Task.Subject => 'SSMO Drop Off',
                        Task.Type => 'SSMO Drop Off',
                        Task.ActivityDate => System.today().addDays(1)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        opportunityContactRole.ContactId => contactId,
                        opportunityContactRole.OpportunityId => opportunityId,
                        opportunityContactRole.Role => 'Influencer',
                        opportunityContactRole.IsPrimary => false
                    }
                )
            );
    }
}