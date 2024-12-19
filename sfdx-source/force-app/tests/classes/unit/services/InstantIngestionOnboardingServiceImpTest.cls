/**
 * @author  Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionOnboardingServiceImpl  class
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount')
private class InstantIngestionOnboardingServiceImpTest {
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS = 'EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String VERTICAL_RX = 'Restaurant';
    private static final String BUSINESS_ID = '12820285';
    private static final String EXISTING_BUSINESS_ID = '12834285';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final Set<String> OPTION_PRODUCT_NAMES = new Set<String>{
        'Delivery',
        'Dashpass',
        'Pickup',
        'Cx Delivery Fee',
        'Tablet Fee',
        'Printer Fee',
        'Set Up Fee',
        'Subscription Fee',
        'Mx Delivery Fee',
        'Payment Processing Fee',
        'Payment Processing Rate',
        'Pickup',
        'Cx Delivery Fee',
        'Payment Processing Fee'
    };
    private static final Set<String> PACKAGE_PRODUCT_NAMES = new Set<String>{
        'Premier Package',
        'Hardware',
        'Storefront'
    };
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String QUOTE_NUMBER = 'Q-123456';
    private static final String SUBMARKET_ID = '591';
    private static final String SUBMARKET_NAME = 'Kennewick';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String SOURCE_SSMO = 'SSMO';

    private static final String STATIC_RESOURCE_TEST_INVALID_JSON = 'Inbound_Ingestion_Payload_Data_InValid';
    private static final String STATUS_FAILED = 'Failed';

    /**
     * @description It is used to test when inbound ingestion log record is inserted then instant
     * ingestor event for account and associated records creation is published or not.
     * It also checks that after the successful creation of account and associated records, platform
     * event for contact and acr creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithExistingBusinessThenAccountNotCreated() {
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
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
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
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        InstantIngestionOnboardingServiceImpl serviceImpl = new InstantIngestionOnboardingServiceImpl();
        serviceImpl.handleInstantIngestorEvents(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
    }

    /**
     * @description It is used to test when service method for account and associated records creation is called
     * from mx portal NSE event then accounts and xrefs are created or not.
     */
    @isTest
    private static void testWhenAccountXrefAndBizrefMethodCalledFromMxPortalNSEEventThenThenRecordsCreated() {
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
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
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
        InstantIngestionOnboardingService.payloadDistributorForAccountsAndXrefsBizRefs(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => parsedPayload },
            new Map<String, String>{ UNIQUE_IDENTIFER => SOURCE_MX_PORTAL }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
    }

    /**
     * @description It is used to test when account and associated records inserted then instant
     * ingestor event for contact and acr creation is published or not.
     * It also checks that after the successful creation of contact and acr records, platform
     * event for opportunity creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithContactAndACRTopicPublishedThenContactAndACRCreated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
        );
        InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Id contactId = new Map<Id, Contact>(parsedPayload.store.matchedRecords.contact)
            .keySet()
            .iterator()
            .next();
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
            EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        mocks.when(mockcontactSelector.selectById(new Set<Id>{ contactId }))
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
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description It is used to test when service method for contact and acr creation is called
     * from mx portal NSE event then contacts and acrs are created or not.
     */
    @isTest
    private static void testWhenContactAndACRMethodCalledFromMxPortalNSEEventThenContactAndACRCreated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
        );
        Id contactId = new Map<Id, Contact>(parsedPayload.store.matchedRecords.contact)
            .keySet()
            .iterator()
            .next();
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
        mocks.when(mockcontactSelector.selectById(new Set<Id>{ contactId }))
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
        InstantIngestionOnboardingService.payloadDistributorForContactsAndACRs(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => parsedPayload },
            new Map<String, String>{ UNIQUE_IDENTIFER => SOURCE_MX_PORTAL }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description It is used to test when contact and acr is inserted then instant
     * ingestor event for opportunity creation is published or not. It also checks that after
     * the successful creation of opportunity records, platform
     * event for quote and quote lines creation is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithOpportunityCreationTopicPublishedThenOpportunityCreated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = SOURCE_SSMO
        );
        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );

        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .toSObject();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, XrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_BUSINESS)
            .setParent('Salesforce_Account_Name__r', accounts)
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();

        mocks.when(mockBusinessAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockBusinessAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    BUSNINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunity });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });

        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockcontactSelector.selectContactsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test when service method for opportunity creation is called
     * from mx portal NSE event then opportunities are created or not.
     */
    @isTest
    private static void testWhenOpportunityCreationCalledFromMxPortalNSEEventThenOpportunityCreated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
        );
        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Contact contacts = new Contact(
            Id = contactId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            AccountId = businessAccountId
        );

        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .toSObject();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, XrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_BUSINESS)
            .setParent('Salesforce_Account_Name__r', accounts)
            .toSObject();
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
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IContactsSelector mockcontactSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();

        mocks.when(mockBusinessAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockBusinessAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    BUSNINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunity });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });

        mocks.when(mockcontactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockcontactSelector.selectContactsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockcontactSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.payloadDistributorForOpportunities(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => parsedPayload },
            new Map<String, String>{ UNIQUE_IDENTIFER => SOURCE_MX_PORTAL },
            new Map<String, Inbound_Ingestion_Log__c>{ UNIQUE_IDENTIFER => inboundIngestionLogs }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for quote and quote lines creation is published or not.
     * It also checks that after the successful creation of quote and quote lines records, platform
     * event for updating quote to contract signed is published or not.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenInstantIngestorEventWithQuoteAndQuoteLinesCreationTopicPublishedThenQuoteAndQuoteLinesCreated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id priceBookId = Fake.generateId(PriceBook2.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockPriceBookEntryId = Fake.generateId(PricebookEntry.class);
        Id bizRefId = Fake.generateId(PricebookEntry.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = SOURCE_SSMO
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
            .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
            .setField(SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c, false);

        Opportunity testOpportunityByName = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.ContactId, contactId)
            .setParent('Account', accounts)
            .toSObject();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_BUSINESS)
            .setParent('Salesforce_Account_Name__r', accounts)
            .toSObject();
        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) fakeQuote.toSObject();
        SBQQ__Quote__c mockQuoteByUUID = (SBQQ__Quote__c) fakeQuote.toSObject();
        Fake fakeQuoteLineGroup = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, mockQuoteLineGroupId)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Account__c, businessAccountId);
        SBQQ__QuoteLineGroup__c quoteLineGroup = (SBQQ__QuoteLineGroup__c) fakeQuoteLineGroup.toSObject();

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        PricebookEntry pricebookEntries = new PricebookEntry(Id = mockPriceBookEntryId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        IOpportunitiesSelector mockoppSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IQuotesSelector mockquoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IPricebookEntriesSelector mockpricebookEntriesSelector = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        IQuoteLineGroupSelector mockQuoteLineGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockBusinessAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    BUSNINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockoppSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockoppSelector.getOpportunitiesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunity });
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunityByName });
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockquoteSelector.selectByOpportunity(new Set<Id>{ opportunityId }))
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote });
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockquoteSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuoteByUUID });
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
        mocks.when(mockpricebookEntriesSelector.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelector.selectByProductNamesAndCurrency(
                    PACKAGE_PRODUCT_NAMES,
                    CURRENCY_ISO_CODE_USD
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntries });
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockQuoteLineGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuoteLineGroupsSelector.selectQuoteLineGroupsByQuoteIds(new Set<Id>{ quoteId })
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{ quoteLineGroup });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockoppSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockpricebookEntriesSelector);
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockQuoteLineGroupsSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => JSON.serialize(
                        new Map<Id, SBQQ__Quote__c>(new List<SBQQ__Quote__c>{ mockQuote }).keySet()
                    )
                }
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
    }

     /**
     * @description It is used to test when opportunity is inserted then instant
     * ingestor event for quote and quote lines creation is published or not.
     * It also that a primary quote exist on the opportunity, platform
     * event for updating quote's Send Slack Notifications flag.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenInstantIngestorEventWithPrimaryQuoteFoundTopicPublishedThenSendSlackNotifications() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id priceBookId = Fake.generateId(PriceBook2.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockPriceBookEntryId = Fake.generateId(PricebookEntry.class);
        Id bizRefId = Fake.generateId(PricebookEntry.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT,
            Source__c = SOURCE_SSMO
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
            .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId)
            .setField(SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c, false);

        Opportunity testOpportunityByName = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.ContactId, contactId)
            .setParent('Account', accounts)
            .setParent('SBQQ__PrimaryQuote__r', fakeQuote)
            .toSObject();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_BUSINESS)
            .setParent('Salesforce_Account_Name__r', accounts)
            .toSObject();
        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) fakeQuote.toSObject();
        SBQQ__Quote__c mockQuoteByUUID = (SBQQ__Quote__c) fakeQuote.toSObject();
        Fake fakeQuoteLineGroup = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, mockQuoteLineGroupId)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Account__c, businessAccountId);
        SBQQ__QuoteLineGroup__c quoteLineGroup = (SBQQ__QuoteLineGroup__c) fakeQuoteLineGroup.toSObject();

        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        PricebookEntry pricebookEntries = new PricebookEntry(Id = mockPriceBookEntryId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        IOpportunitiesSelector mockoppSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IQuotesSelector mockquoteSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IPricebookEntriesSelector mockpricebookEntriesSelector = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        IQuoteLineGroupSelector mockQuoteLineGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockBusinessAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    BUSNINESS_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockoppSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockoppSelector.getOpportunitiesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunity });
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ testOpportunityByName });
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockquoteSelector.selectByOpportunity(new Set<Id>{ opportunityId }))
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote });
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockquoteSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuoteByUUID });
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
        mocks.when(mockpricebookEntriesSelector.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelector.selectByProductNamesAndCurrency(
                    PACKAGE_PRODUCT_NAMES,
                    CURRENCY_ISO_CODE_USD
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntries });
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockQuoteLineGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuoteLineGroupsSelector.selectQuoteLineGroupsByQuoteIds(new Set<Id>{ quoteId })
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{ quoteLineGroup });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockoppSelector);
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockXrefsSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockpricebookEntriesSelector);
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockQuoteLineGroupsSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTES_TO_SEND_SLACK_NOTIFICATIONS => JSON.serialize(
                        new Map<Id, SBQQ__Quote__c>(new List<SBQQ__Quote__c>{ mockQuote }).keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
    }

    /**
     * @description It is used to test when quote and quote lines are inserted then instant
     * ingestor event for updating quote to contract signed is published or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithContractSignedCreationTopicPublishedThenQuoteUpdatedToContractSigned() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id ingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();

        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            Id = quoteId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            CurrencyIsoCode = CURRENCY_ISO_CODE_USD
        );
        Inbound_ingestion_Log__c ingestionlog = new Inbound_ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFER,
            Source__c = SOURCE_SSMO,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
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
        IInboundIngestionLogsSelector mockIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockquoteSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockquoteSelector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ quotes });
        mocks.when(mockquoteSelector.selectById(new Set<Id>{ quoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ quotes });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockIngestionSelector.sObjectType())
            .thenReturn(Inbound_ingestion_Log__c.SObjectType);

        mocks.when(mockIngestionSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.when(
                mockIngestionSelector.selectInboundIngestionLogsByUUIDs(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockIngestionSelector);

        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description It is used to test when quote and quote lines are present then instant
     * ingestor event will update the flag that fire the custom slack notification.
     */
    @isTest
    private static void testWhenInstantIngestorEventWithExistingPrimaryQuotePresentTopicPublishedThenSendSlackNotifications() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id ingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();

        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            Id = quoteId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            CurrencyIsoCode = CURRENCY_ISO_CODE_USD,
            Slack_Notification_To_Opportunity_Owner__c = false
        );
        Inbound_ingestion_Log__c ingestionlog = new Inbound_ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFER,
            Source__c = SOURCE_SSMO,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
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
        IInboundIngestionLogsSelector mockIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
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
        mocks.when(mockIngestionSelector.sObjectType())
            .thenReturn(Inbound_ingestion_Log__c.SObjectType);
        mocks.when(mockIngestionSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.when(
                mockIngestionSelector.selectInboundIngestionLogsByUUIDs(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockquoteSelector);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.SELECTOR.setMock(mockIngestionSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }
    /**
     * @description It is used to test when inbound ingestion log record is inserted with invalid payload then instant
     * ingestor event for account and associated records creation will process and update the relevent error on inbound ingestion record.
     */
    @isTest
    private static void testWhenInvalidPayloadInsertedThenUpdateErrorMessageToIngestionLog() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id contactId = Fake.generateId(Contact.class);
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_INVALID_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = ONBOARDING_EVENT
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

        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
            ),
            Topic__c = EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD
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
        InstantIngestionOnboardingService.execute(
            new List<Instant_Ingestor__e>{ mockInstantIngestorEvent }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<sObjectField, Object>{
                        Inbound_Ingestion_Log__c.Status__c => STATUS_FAILED
                    }
                )
            );
    }
}