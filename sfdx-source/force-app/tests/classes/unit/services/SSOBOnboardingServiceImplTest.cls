/**
 * @author Deloitte
 * @date 07/28/2024
 * @description Test class for SSOBOnboardingServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount')
public with sharing class SSOBOnboardingServiceImplTest {
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS = 'EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS';
    private static final String EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY = 'EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY';
    private static final String EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE';
    private static final String EVENT_TOPIC_PRIMARY_QUOTE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_PRIMARY_QUOTE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String VERTICAL_RX = 'Restaurant';
    private static final String BUSINESS_ID = '11556308';
    private static final String STORE_ID = '3884328';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String SSOB_ONBOARDING_EVENT = 'SSOB Onboarding Event';
    private static final Set<String> OPTION_PRODUCT_NAMES = new Set<String>{
        'Delivery',
        'Dashpass',
        'Pickup',
        'Cx Delivery Fee',
        'Service Rate',
        'Tablet Fee',
        'Printer Fee',
        'Set Up Fee',
        'Subscription Fee',
        'Mx Delivery Fee',
        'Payment Processing Fee',
        'Payment Processing Rate',
        'Pickup',
        'Cx Delivery Fee',
        'Service Rate',
        'Payment Processing Fee'
    };
    private static final Set<String> PACKAGE_PRODUCT_NAMES = new Set<String>{
        'Premier Package',
        'Hardware',
        'Storefront'
    };
    private static final String UNIQUE_IDENTIFER = '07a5e956-9d35-4738-b48c-94e3209d756b';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String QUOTE_NUMBER = 'Q-123456';
    private static final String SUBMARKET_ID = '591';
    private static final String SUBMARKET_NAME = 'Kennewick';

    /**
     * @description It is used to test when inbound ingestion log record is inserted then instant
     * ingestor event for account and associated records creation is published or not.
     * It also checks that after the successful creation of account and associated records, platform
     * event for contact and acr creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedThenAccountWithBizRefAndXrefCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id contactId = Fake.generateId(Contact.class);
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );
        Brand__c mockBrand = new Brand__c(
            Id = mockBrandId,
            Brand_Owner__c = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER
        );
        Submarket__c submarkets = new Submarket__c(
            Id = mockSubmarketId,
            Submarket_ID__c = SUBMARKET_ID,
            Name = SUBMARKET_NAME
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            Brand__c = mockBrandId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Business_Vertical__c = mockBusinessVerticalId,
            External_Id__c = BUSINESS_ID
        );
        Fake testAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, 'Store')
            .setParent('Salesforce_Account_Name__r', testAccount)
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        ISubmarketsSelector mockSubmarketsSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );

        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        IBrandsSelector mockBrandSelectorForUUID = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelectorByBusinessIds = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockSubmarketsSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(mockSubmarketsSelector.getSubmarketsByIds(new Set<String>{ SUBMARKET_ID }))
            .thenReturn(new List<Submarket__c>{ submarkets });
        mocks.when(mockBusinessReferenceSelectorByBusinessIds.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelectorByBusinessIds.selectBusRefByExternalId(
                    new Set<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ bizref });

        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockcontactSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBusinessReferenceByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ bizref });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(mockBrandSelector.selectBrandsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockBrandSelectorForUUID.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(
                mockBrandSelectorForUUID.selectBrandsByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockBrandSelector);
        Application.SELECTOR.setMock(mockBrandSelectorForUUID);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockBusinessReferenceSelectorByBusinessIds);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockSubmarketsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork(); //15
    }

    /**
     * @description It is used to test when account and associated records inserted then instant
     * ingestor event for contact and acr creation is published or not.
     * It also checks that after the successful creation of contact and acr records, platform
     * event for opportunity creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithContactAndACRTopicPublishedThenContactAndACRCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id contactId = Fake.generateId(Contact.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );
        Account accounts = new Account(
            Id = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = BUSNINESS_RECORD_TYPE_ID
        );
        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Account storeAccounts = new Account(
            Id = storeAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            parentId = businessAccountId
        );

        Fake testAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            );

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, 'Store')
            .setParent('Salesforce_Account_Name__r', testAccount)
            .toSObject();

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IAccountsSelector mockBusinessAccountSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IAccountsSelector mockStoreAccountSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );

        IContactsSelector mockcontactSelectorFoUUID = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBusinessAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockBusinessAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    BUSNINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ accounts });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });

        mocks.when(mockStoreAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockStoreAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    STORE_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ storeAccounts });
        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockcontactSelector.selectContactsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockcontactSelectorFoUUID.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockcontactSelectorFoUUID.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockStoreAccountSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockcontactSelectorFoUUID);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork(); //6
    }

    /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for quote and quote lines creation is published or not.
     * It also checks that after the successful creation of quote and quote lines records, platform
     * event for updating quote to contract signed is published or not.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenInstantIngestorEventWithQuoteAndQuoteLinesCreationTopicPublishedThenQuoteAndQuoteLinesCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id mockContractId = Fake.generateId(Contract.class);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .toSObject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, QUOTE_NUMBER)
            .setField(SBQQ__Quote__c.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c, false);

        Opportunity existingTypeOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_UPGRADE)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setParent('Account', accounts)
            .setParent('SBQQ__PrimaryQuote__r', fakeQuote)
            .toSObject();

        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, mockContractId)
            .setField(Contract.Business_Account_Name__c, BUSINESS_ACCOUNT_NAME)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.CurrencyIsoCode, CURRENCY_ISO_CODE_USD);

        Contract newContract = (Contract) fakeContract.toSObject();

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInstantIngestionCheckRecordsService mockInstantIngestionCheckRecordsService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );
        IInstantIngestionRecordsGetterService mockInstantIngestionRecordsGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IAmendmentService mockAmendmentService = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(
                mockInstantIngestionCheckRecordsService.getExistingBusinessAccounts(
                    (Map<String, InstantIngestionPayloadParser>) fflib_Match.anyObject(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => businessAccount });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => testOpportunity });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => existingTypeOpportunity });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Contract>{ businessAccountId => newContract });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getOpportunitiesByUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.isNull(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(
                new Map<String, Opportunity>{ UNIQUE_IDENTIFER => existingTypeOpportunity }
            );

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockInstantIngestionRecordsGetterService
        );
        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockInstantIngestionCheckRecordsService
        );
        Application.SERVICE.setMock(IAmendmentService.class, mockAmendmentService);
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => (List<String>) fflib_Match.anyObject()
                }
            );
    }

    /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for quote and quote lines creation is published or not.
     * It also checks that after the successful creation of quote and quote lines records, platform
     * event for updating quote to contract signed is published or not.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenInstantIngestorEventWithQuoteAndQuoteLinesCreationTopicPublishedThenNewQuoteAndQuoteLinesCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Id priceBookId = Fake.generateId(PriceBook2.class);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .toSObject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, QUOTE_NUMBER)
            .setField(SBQQ__Quote__c.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c, false);

        Opportunity existingTypeOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_UPGRADE)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setParent('Account', accounts)
            .setParent('SBQQ__PrimaryQuote__r', fakeQuote)
            .toSObject();

        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) fakeQuote.toSObject();

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInstantIngestionCheckRecordsService mockInstantIngestionCheckRecordsService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );
        IInstantIngestionRecordsGetterService mockInstantIngestionRecordsGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IAmendmentService mockAmendmentService = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(
                mockInstantIngestionCheckRecordsService.getExistingBusinessAccounts(
                    (Map<String, InstantIngestionPayloadParser>) fflib_Match.anyObject(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => businessAccount });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => testOpportunity });
        mocks.when(
                mockInstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, SBQQ__Quote__c>{ businessAccountId => mockQuote });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => existingTypeOpportunity });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Contract>{});
        mocks.when(
                mockInstantIngestionRecordsGetterService.getOpportunitiesByUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.isNull(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(
                new Map<String, Opportunity>{ UNIQUE_IDENTIFER => existingTypeOpportunity }
            );

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockInstantIngestionRecordsGetterService
        );
        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockInstantIngestionCheckRecordsService
        );
        Application.SERVICE.setMock(IAmendmentService.class, mockAmendmentService);
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => (List<String>) fflib_Match.anyObject()
                }
            );
    }
    //

    /**
     * @description It is used to test when quote and quote lines are inserted then instant
     * ingestor event for updating quote to contract signed is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithContractSignedCreationTopicPublishedThenQuoteUpdatedToContractSignedForSSOB() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            Id = quoteId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            CurrencyIsoCode = CURRENCY_ISO_CODE_USD
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED => JSON.serialize(
                new Map<Id, SBQQ__Quote__c>(new List<SBQQ__Quote__c>{ quotes }).keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED),
            Topic__c = EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IQuotesSelector mockquoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockquoteSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ quotes });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description It is used to test when quote and quote lines are present then instant
     * ingestor event will update the flag that fire the custom slack notification.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithExistingPrimaryQuotePresentTopicPublishedThenSendSlackNotifications() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            Id = quoteId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            CurrencyIsoCode = CURRENCY_ISO_CODE_USD,
            Slack_Notification_To_Opportunity_Owner__c = false
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS => JSON.serialize(
                new Map<Id, SBQQ__Quote__c>(new List<SBQQ__Quote__c>{ quotes }).keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS),
            Topic__c = EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IQuotesSelector mockquoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockquoteSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ quotes });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    @isTest
    private static void testWhenInstantIngestorEventPublishedWithSSOBQuoteLineCreationThenEventInvokedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockAgreementId = Fake.generateId(Agreement__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );
        Fake storeAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, businessAccountId)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            );
        Account newStoreAccount = (Account) storeAccount.toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, mockOpportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.AccountId, businessAccountId)
            .toSObject();
        SBQQ__Quote__c fakeQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .toSObject();
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, mockContractId)
            .setField(Contract.Business_Account_Name__c, BUSINESS_ACCOUNT_NAME)
            .setField(Contract.AccountId, businessAccountId)
            .setField(Contract.CurrencyIsoCode, CURRENCY_ISO_CODE_USD);
        Agreement__c fakeAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, mockAgreementId)
            .setField(Agreement__c.Account__c, storeAccountId)
            .setField(Agreement__c.Contract__c, mockContractId)
            .setParent('Contract__r', fakeContract)
            .toSObject();
        Contract newContract = (Contract) fakeContract.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );

        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAgreementsSelector mockAgreementsSelector = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IInstantIngestionCheckRecordsService mockCheckRecordService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );
        IInstantIngestionRecordsGetterService mockInstantIngestionRecordsGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(mockContractsSelector.selectByParentAccountId(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contract>{ newContract });
        mocks.when(mockAgreementsSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(mockAgreementsSelector.selectAgreementsByAccounts(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Agreement__c>{ fakeAgreement });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Contract>{ businessAccountId => newContract });
        mocks.when(
                mockCheckRecordService.getExistingBusinessAccounts(
                    (Map<String, InstantIngestionPayloadParser>) fflib_Match.isNull(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => newStoreAccount });
        mocks.when(
                mockCheckRecordService.fetchRelatedOpportunitiesAndQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => testOpportunity });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getQuotesByUUID(
                    (Map<String, InstantIngestionPayloadParser>) fflib_Match.isNull(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, SBQQ__Quote__c>{ UNIQUE_IDENTIFER => fakeQuote });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockContractsSelector);
        Application.SELECTOR.setMock(mockAgreementsSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockCheckRecordService
        );
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockInstantIngestionRecordsGetterService
        );
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PRIMARY_QUOTE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => (List<String>) fflib_Match.anyObject()
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    @isTest
    private static void testWhenInstantIngestorEventPublishedWithSSOBInitiateAmendmentEventThenContractAmendmentInvoked() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        String mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        String amendmentResponse =
            '{"quoteId":' +
            '"' +
            mockQuoteId +
            '",' +
            '"isSuccessful":' +
            true +
            '}';
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Set<Object> payLoads = new Set<Object>();
        SSOBOnboardingServiceImpl.SSOBPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new SSOBOnboardingServiceImpl.SSOBPortalAmendmentPayloadWrapper();
        amendmentPayloadWrapper.opportunityId = mockOpportunityId;
        amendmentPayloadWrapper.contractId = mockContractId;
        amendmentPayloadWrapper.inboundIngestionLogId = mockInboundingestionlogId;
        payLoads.add(amendmentPayloadWrapper);
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(payLoads),
            Topic__c = EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IAmendmentService mockAmendmentService = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(
                mockAmendmentService.createAmendmentFromOpportunity(
                    (Id) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(amendmentResponse);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SERVICE.setMock(IAmendmentService.class, mockAmendmentService);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE => (List<String>) fflib_Match.anyObject()
                }
            );
    }

    /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for amendment quote and quote lines creation for Drive is published or not.
     * It also checks that after the successful creation of quote and quote lines records, platform
     * event for updating quote to primary and contract signed is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithDriveQuoteLineCreationThenEventInvokedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockDiscountId = Fake.generateId(SBQQ__DiscountTier__c.class);
        String mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);

        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id priceBookId = Fake.generateId(PriceBook2.class);
        Id mockQuoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT,
            Source__c = 'SSOB'
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(Id = mockQuoteId);
        SBQQ__DiscountTier__c discountTier = new SBQQ__DiscountTier__c(
            Id = mockDiscountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER
        );
        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        Fake fakeQuoteLineGroup = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, mockQuoteLineGroupId);
        SBQQ__QuoteLineGroup__c quoteLineGroup = (SBQQ__QuoteLineGroup__c) fakeQuoteLineGroup.toSObject();

        Set<Object> payLoads = new Set<Object>();
        SSOBOnboardingServiceImpl.SSOBPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new SSOBOnboardingServiceImpl.SSOBPortalAmendmentPayloadWrapper();
        amendmentPayloadWrapper.inboundIngestionLogId = mockInboundingestionlogId;
        amendmentPayloadWrapper.amendmentQuoteId = mockQuoteId;
        payLoads.add(amendmentPayloadWrapper);
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(payLoads),
            Topic__c = EVENT_TOPIC_ADD_DRIVE_QUOTE_LINES_ON_AMENDMENT_QUOTE
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IDiscountTiersSelector mockDiscountSelector = (IDiscountTiersSelector) mocks.mock(
            IDiscountTiersSelector.class
        );

        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IQuoteLineGroupSelector mockQuoteLineGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });

        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(mockQuoteLineGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuoteLineGroupsSelector.selectQuoteLineGroupsByQuoteIds(
                    new Set<Id>{ mockQuoteId }
                )
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{ quoteLineGroup });
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuotesSelector.selectById(new Set<Id>{ mockQuoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.when(mockDiscountSelector.sObjectType())
            .thenReturn(SBQQ__DiscountTier__c.SObjectType);
        mocks.when(mockDiscountSelector.selectByUUID((Set<String>) fflib_Match.anyObject()))
            .thenReturn(new List<SBQQ__DiscountTier__c>{ discountTier });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockQuoteLineGroupsSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SELECTOR.setMock(mockDiscountSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PRIMARY_QUOTE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => (List<String>) fflib_Match.anyObject()
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description It is used to test when contact and acr is inserted then instant
     * ingestor event for opportunity creation is published or not. It also checks that after the
     * successful creation of opportunity records, platform
     * event for quote and quote lines creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithOpportunityCreationTopicPublishedThenOpportunityCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);

        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_OPPORTUNITY_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );

        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork(); //3
    }

    /**
     * @description It is used to test when inbound ingestion log record is inserted then instant
     * ingestor event for account and associated records creation is published or not.
     * It also checks that after the successful creation of account and associated records, platform
     * event for contact and acr creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithDifferentBusinessIdThenAccountWithBizRefAndXrefCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);

        Id contactId = Fake.generateId(Contact.class);
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );
        Brand__c mockBrand = new Brand__c(
            Id = mockBrandId,
            Brand_Owner__c = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER
        );
        Submarket__c submarkets = new Submarket__c(
            Id = mockSubmarketId,
            Submarket_ID__c = SUBMARKET_ID,
            Name = SUBMARKET_NAME
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        ISubmarketsSelector mockSubmarketsSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );

        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        IBrandsSelector mockBrandSelectorForUUID = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelectorByBusinessIds = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestionAccountService mockAccountService = (IInstantIngestionAccountService) mocks.mock(
            IInstantIngestionAccountService.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockSubmarketsSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(mockSubmarketsSelector.getSubmarketsByIds(new Set<String>{ SUBMARKET_ID }))
            .thenReturn(new List<Submarket__c>{ submarkets });

        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockcontactSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Contact>{ contacts });

        mocks.when(mockBrandSelector.selectBrandsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockBrandSelectorForUUID.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(
                mockBrandSelectorForUUID.selectBrandsByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });

        mocks.when(mockAccountService.createBrand((Account) fflib_Match.anySObject()))
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockBrandSelector);
        Application.SELECTOR.setMock(mockBrandSelectorForUUID);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockBusinessReferenceSelectorByBusinessIds);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockSubmarketsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Application.SERVICE.setMock(IInstantIngestionAccountService.class, mockAccountService);
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork(); //15
    }

    /**
     * @description It is used to test when inbound ingestion log record is inserted then instant
     * ingestor event for account and associated records creation is published or not.
     * It also checks that after the successful creation of account and associated records, platform
     * event for contact and acr creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithDifferentBusinessIdThenNewAccountWithBizRefAndXrefCreatedForSSOB() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);

        Id contactId = Fake.generateId(Contact.class);
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );
        Brand__c mockBrand = new Brand__c(
            Id = mockBrandId,
            Brand_Owner__c = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER
        );
        Submarket__c submarkets = new Submarket__c(
            Id = mockSubmarketId,
            Submarket_ID__c = SUBMARKET_ID,
            Name = SUBMARKET_NAME
        );
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_SSOB_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        ISubmarketsSelector mockSubmarketsSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );

        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        IBrandsSelector mockBrandSelectorForUUID = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessReferencesSelector mockBusinessReferenceSelectorByBusinessIds = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockSubmarketsSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(mockSubmarketsSelector.getSubmarketsByIds(new Set<String>{ SUBMARKET_ID }))
            .thenReturn(new List<Submarket__c>{ submarkets });

        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockcontactSelector.selectContactsByUniqueIdentifier(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Contact>{ contacts });

        mocks.when(mockBrandSelector.selectBrandsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockBrandSelectorForUUID.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(
                mockBrandSelectorForUUID.selectBrandsByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Brand__c>{ mockBrand });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockBrandSelector);
        Application.SELECTOR.setMock(mockBrandSelectorForUUID);
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Application.SELECTOR.setMock(mockBusinessReferenceSelectorByBusinessIds);
        Application.SELECTOR.setMock(mockSubmarketsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork(); //15
    }

    /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for quote and quote lines creation is published or not.
     * It also checks that after the successful creation of quote and quote lines records when no existing primary quote is found, platform
     * event for updating quote to contract signed is published or not.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenInstantIngestorEventWithQuoteAndQuoteLinesCreationTopicPublishedThenQuoteAndQuoteLinesCreatedForSSOBWhenExistingPrimaryQuoteNotFound() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Id priceBookId = Fake.generateId(PriceBook2.class);

        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = SSOB_ONBOARDING_EVENT
        );

        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .toSObject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, QUOTE_NUMBER)
            .setField(SBQQ__Quote__c.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, false)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c, false);

        Opportunity existingTypeOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, 'Closed Won')
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_UPGRADE)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setParent('Account', accounts)
            .toSObject();

        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) fakeQuote.toSObject();

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_SSOB_INGESTION_ONBOARDING_PAYLOAD
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInstantIngestionCheckRecordsService mockInstantIngestionCheckRecordsService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );
        IInstantIngestionRecordsGetterService mockInstantIngestionRecordsGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IAmendmentService mockAmendmentService = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(
                mockInstantIngestionCheckRecordsService.getExistingBusinessAccounts(
                    (Map<String, InstantIngestionPayloadParser>) fflib_Match.anyObject(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, Account>{ BUSINESS_ID => businessAccount });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedOpportunitiesAndQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => testOpportunity });
        mocks.when(
                mockInstantIngestionCheckRecordsService.getExistingQuotesByAccountIds(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, SBQQ__Quote__c>{ businessAccountId => mockQuote });
        mocks.when(
                mockInstantIngestionCheckRecordsService.fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Opportunity>{ businessAccountId => existingTypeOpportunity });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, Contract>{});
        mocks.when(
                mockInstantIngestionRecordsGetterService.getOpportunitiesByUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.isNull(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(
                new Map<String, Opportunity>{ UNIQUE_IDENTIFER => existingTypeOpportunity }
            );

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockInstantIngestionRecordsGetterService
        );
        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockInstantIngestionCheckRecordsService
        );
        Application.SERVICE.setMock(IAmendmentService.class, mockAmendmentService);
        SSOBOnboardingService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_SSOB_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => (List<String>) fflib_Match.anyObject()
                }
            );
    }
}