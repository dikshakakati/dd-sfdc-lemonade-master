/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Test class for MxPortalAmendmentServiceImpl class
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class MxPortalAmendmentServiceImplTest {
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    private static final String STATIC_RESOURCE_JSON_PAYLOAD_WITHOUT_DASHPASS = 'Mx_Portal_NSE_Payload_Data_Without_Dashpass';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_CONTACT_AND_ACR_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_OPPORTUNITY_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_QUOTE_QUOTELINE_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION = 'EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION';
    private static final String EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT = 'EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT';
    private static final String EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT = 'EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT';
    private static final String EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY = 'EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY';
    private static final String EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE = 'EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY = 'EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY';
    private static final String EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS = 'EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS';
    private static final String VERTICAL_RX = 'Restaurant';
    private static final String BUSINESS_ID = '12820285';
    private static final String EXISTING_BUSINESS_ID = '12834285';
    private static final String STORE_ID = '3884328';
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String ACTIVATED_CONTRACT_STATUS = 'Activated';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final Set<String> OPTION_PRODUCT_NAMES = new Set<String>{ 'Delivery' };
    private static final Set<String> PACKAGE_PRODUCT_NAMES = new Set<String>{ 'Premier Package' };
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String MX_PORTAL_UNIQUE_IDENTIFER = 'MxPAddStorefront66-53-6y6hdd9-4a0c-9193-9152aeb86fe4';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String PACKAGE_PRODUCT_BASIC_DASHPASS = 'Basic Package: Dashpass';
    private static final String PACKAGE_PRODUCT_BASIC_DELIVERY = 'Basic Package: Delivery';
    private static final String PRODUCT_NAME_BASIC_PACKAGE = 'Basic Package';
    private static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    private static final String PRODUCT_NAME_DASHPASS = 'Dashpass';
    private static final String QUOTE_NUMBER = 'Q-123456';
    private static final String SUBMARKET_ID = '591';
    private static final String SUBMARKET_NAME = 'Kennewick';
    private static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String MX_PORTAL_NSE_EVENT = 'Mx Portal New Store Expansion';
    private static final String MX_PORTAL_ADD_STOREFRONT_EVENT = 'Mx Portal Add Storefront';
    private static final String MX_PORTAL_PACKAGE_SWITCH_EVENT = 'Mx Portal Package Switch';
    private static final String MX_PORTAL_ADD_ADS_PROMOS = 'Mx Portal Ads And Promos';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';

    /**
     * @description It is used to test whether new store expansion process is initiated or not when instant
     * ingestor event for Mx Portal new store expansion event in published.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithMxPortalNSEEventThenNewStoreExpansionProcessInitiated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
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
            Integration_Type__c = MX_PORTAL_NSE_EVENT,
            Source__c = SOURCE_MX_PORTAL
        );

        Fake businessAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);

        Fake storeAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, businessAccountId)
            .setParent('Parent', businessAccount);

        Fake fakeQuoteLine = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, mockQuoteLineId)
            .setField(SBQQ__QuoteLine__c.Package_Product__c, 'Premier Package: Delivery');

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, mockSubscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, mockContractId)
                .setField(SBQQ__Subscription__c.Final_Fee__c, 2)
                .setField(SBQQ__Subscription__c.Final_Commission__c, 1)
                .setField(SBQQ__Subscription__c.Trial_Commission__c, 1)
                .setField(SBQQ__Subscription__c.Trial_Fee__c, 0)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Delivery')
                .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
                .setField(SBQQ__Subscription__c.Package__c, 'Premier Package')
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, mockQuoteLineId)
                .setParent('SBQQ__QuoteLine__r', fakeQuoteLine)
                .setParent('SBQQ__Account__r', businessAccount)
                .toSobject()
        };
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, 'Store')
            .setParent('Salesforce_Account_Name__r', storeAccount)
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION),
            Topic__c = EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION
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
        ISubscriptionSelector mockSubscriptionSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);

        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.querySubscriptionRecordsWithAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(mockSubscription);

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
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(
                                new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                            )
                            .keySet()
                    )
                }
            );
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(new List<Inbound_Ingestion_Log__c>{})
                            .keySet()
                    )
                }
            );
    }

    /**
     * @description It is used to test when non matching products and pricing are found in the system
     * then new store expansion process is initiated for new contracts creation
     */
    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    private static void testWhenInstantIngestorEventPublishedWithMxPortalNonMatchingNSEEventThenNewDataCreationProcessInitiated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
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
            Integration_Type__c = MX_PORTAL_NSE_EVENT,
            Source__c = SOURCE_MX_PORTAL
        );
        InstantIngestionPayloadParser parsedPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Id contactId = new Map<Id, Contact>(parsedPayload.store.matchedRecords.contact)
            .keySet()
            .iterator()
            .next();
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
        Fake storeAccount = new Fake(Account.class)
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
            .setParent('Salesforce_Account_Name__r', storeAccount)
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Contract fakeContract = new Contract(
            Id = mockContractId,
            Status = ACTIVATED_CONTRACT_STATUS
        );
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(
                EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT
            ),
            Topic__c = EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT
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
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
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
        mocks.when(mockcontactSelector.selectContactsByAccountIds(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contact>{ contacts });
        mocks.when(mockcontactSelector.selectById(new Set<Id>{ contactId }))
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
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(mockContractsSelector.selectByParentAccountId(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Contract>{ fakeContract });
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
        Application.SELECTOR.setMock(mockContractsSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 11)).commitWork();
    }

    /**
     * @description It is used to test when mx portal add storefront event is published then
     * storefront package addition process is initiated.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithMxPortalAddStoreFrontEventThenStorefrontAdditionInvoked() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        Id mockAgreementId = Fake.generateId(Agreement__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = MX_PORTAL_UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = MX_PORTAL_ADD_STOREFRONT_EVENT,
            Source__c = SOURCE_MX_PORTAL
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
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING)
            .setField(Opportunity.Unique_Identifier__c, MX_PORTAL_UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.Source__c, SOURCE_MX_PORTAL)
            .toSObject();
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.External_Id__c, STORE_ID)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.Account_Record_Type__c, 'Store')
            .setParent('Salesforce_Account_Name__r', storeAccount)
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Id, BUSINESS_ID)
                    .setField(Business_Reference__c.Business_Name__c, BUSINESS_ACCOUNT_NAME)
            )
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
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
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT),
            Topic__c = EVENT_TOPIC_INITIATE_MX_PORTAL_AMENDMENT
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
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
        mocks.when(mockXrefsSelector.selectXrefByExternalIdOnly(new List<String>{ STORE_ID }))
            .thenReturn(new List<Xref__c>{ xref });
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
                mockCheckRecordService.checkAndFetchExistingStoreAccountsByStoreId(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, Account>{ STORE_ID => newStoreAccount });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new Map<Id, Contract>{ businessAccountId => newContract });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getOpportunitiesByUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.anyObject(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.isNull()
                )
            )
            .thenReturn(
                new Map<String, Opportunity>{ MX_PORTAL_UNIQUE_IDENTIFER => testOpportunity }
            );
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
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });

        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY => (List<String>) fflib_Match.anyObject()
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description It is used to test when mx portal add storefront event is published then
     * contract amendment process is invoked or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithMxPortalInitiateAmendmentEventThenContractAmendmentInvoked() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockContractId = Fake.generateId(Contract.class);
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
        Set<Object> payLoads = new Set<Object>();
        MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper();
        amendmentPayloadWrapper.opportunityId = mockOpportunityId;
        amendmentPayloadWrapper.contractId = mockContractId;
        amendmentPayloadWrapper.eventType = MX_PORTAL_ADD_STOREFRONT_EVENT;
        amendmentPayloadWrapper.inboundIngestionLogId = mockInboundingestionlogId;
        payLoads.add(amendmentPayloadWrapper);
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(payLoads),
            Topic__c = EVENT_TOPIC_INITIATE_CONTRACT_AMENDMENT_ON_EXISTING_OPPORTUNITY
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IAmendmentService mockAmendmentService = (IAmendmentService) mocks.mock(
            IAmendmentService.class
        );
        mocks.startStubbing();
        mocks.when(
                mockAmendmentService.createAmendmentFromOpportunity(
                    (Id) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject()
                )
            )
            .thenReturn(amendmentResponse);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAmendmentService.class, mockAmendmentService);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 2))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE => (String) fflib_Match.anyObject()
                }
            );
    }

    /**
     * @description It is used to test when mx portal add storefront event is published then storefront
     * package is added on amendment quote after contract amendment process.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithMxPortalAddStorefrontEventThenStorefrontPackageAdded() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        String mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        String mockQuoteLineParentId = Fake.generateId(SBQQ__QuoteLine__c.class);
        String mockQuoteLineOptionId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id priceBookId = Fake.generateId(PriceBook2.class);
        Id mockQuoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = MX_PORTAL_UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = MX_PORTAL_PACKAGE_SWITCH_EVENT,
            Source__c = SOURCE_MX_PORTAL
        );
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(Id = mockQuoteId);
        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        Fake fakeQuoteLineGroup = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, mockQuoteLineGroupId);
        SBQQ__QuoteLineGroup__c quoteLineGroup = (SBQQ__QuoteLineGroup__c) fakeQuoteLineGroup.toSObject();
        SBQQ__QuoteLine__c newParentQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineParentId);
        SBQQ__QuoteLine__c newOptionQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineOptionId);
        Set<Object> payLoads = new Set<Object>();
        MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper();
        amendmentPayloadWrapper.opportunityId = mockOpportunityId;
        amendmentPayloadWrapper.amendmentQuoteId = mockQuoteId;
        amendmentPayloadWrapper.eventType = MX_PORTAL_PACKAGE_SWITCH_EVENT;
        amendmentPayloadWrapper.inboundIngestionLogId = mockInboundingestionlogId;
        payLoads.add(amendmentPayloadWrapper);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(payLoads),
            Topic__c = EVENT_TOPIC_ADD_QUOTE_LINES_ON_AMENDMENT_QUOTE
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestionQuoteAndQLIService mockQuoteAndQuoteLineService = (IInstantIngestionQuoteAndQLIService) mocks.mock(
            IInstantIngestionQuoteAndQLIService.class
        );
        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IQuoteLineGroupSelector mockQuoteLineGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuotesSelector.selectById(new Set<Id>{ mockQuoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.when(
                mockQuoteAndQuoteLineService.createBundleAndStandaloneQuoteLinesForMxPortalPayload(
                    (MxPortalPayloadParser) fflib_Match.anyObject(),
                    (SBQQ__Quote__c) fflib_Match.anyObject(),
                    (PriceBook2) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__QuoteLine__c>{ newParentQuoteLine });
        mocks.when(
                mockQuoteAndQuoteLineService.createQuoteLineOptionsByParentForMxPortalPayload(
                    (MxPortalPayloadParser) fflib_Match.anyObject(),
                    (Map<String, SBQQ__QuoteLine__c>) fflib_Match.anyObject(),
                    (SBQQ__Quote__c) fflib_Match.anyObject(),
                    (PriceBook2) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__QuoteLine__c>{ newOptionQuoteLine });
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockQuoteLineGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuoteLineGroupsSelector.selectQuoteLineGroupsByQuoteIds(
                    new Set<Id>{ mockQuoteId }
                )
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{ quoteLineGroup });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SELECTOR.setMock(mockQuoteLineGroupsSelector);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SERVICE.setMock(
            IInstantIngestionQuoteAndQLIService.class,
            mockQuoteAndQuoteLineService
        );
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED => (String) fflib_Match.anyObject()
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
    }

    /**
     * @description It is used to test when mx portal ads and promos event is published then
     * new quote and quote lines creation process process is invoked or not.
     */
    @isTest
    private static void testWhenInstantIngestorEventPublishedWithMxPortalAdsAndPromosEventThenNewQuoteAndQLICreationInvoked() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        String mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        String mockQuoteLineParentId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id priceBookId = Fake.generateId(PriceBook2.class);
        Id mockQuoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = MX_PORTAL_UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = MX_PORTAL_ADD_ADS_PROMOS,
            Source__c = SOURCE_MX_PORTAL
        );
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            SBQQ__Account__c = mockAccountId
        );
        PriceBook2 pricebooks = new PriceBook2(Id = priceBookId);
        Fake fakeQuoteLineGroup = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, mockQuoteLineGroupId)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Account__c, mockAccountId)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Quote__c, mockQuoteId);
        Opportunity testOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, mockOpportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING)
            .setField(Opportunity.Unique_Identifier__c, MX_PORTAL_UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, mockAccountId)
            .setField(Opportunity.Source__c, SOURCE_MX_PORTAL)
            .toSObject();
        SBQQ__QuoteLineGroup__c quoteLineGroup = (SBQQ__QuoteLineGroup__c) fakeQuoteLineGroup.toSObject();
        SBQQ__QuoteLine__c newParentQuoteLine = new SBQQ__QuoteLine__c(
            Id = mockQuoteLineParentId,
            SBQQ__Group__c = mockQuoteLineGroupId
        );
        Set<Object> payLoads = new Set<Object>();
        MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper amendmentPayloadWrapper = new MxPortalAmendmentServiceImpl.MxPortalAmendmentPayloadWrapper();
        amendmentPayloadWrapper.opportunityId = mockOpportunityId;
        amendmentPayloadWrapper.amendmentQuoteId = mockQuoteId;
        amendmentPayloadWrapper.eventType = MX_PORTAL_ADD_ADS_PROMOS;
        amendmentPayloadWrapper.inboundIngestionLogId = mockInboundingestionlogId;
        payLoads.add(amendmentPayloadWrapper);

        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = JSON.serialize(new Set<Id>{ mockInboundingestionlogId }),
            Topic__c = EVENT_TOPIC_CREATE_NEW_QUOTE_FOR_ADS_AND_PROMOS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInstantIngestorEventsService mockInstantIngestorEventsService = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IInstantIngestionCheckRecordsService mockCheckRecordService = (IInstantIngestionCheckRecordsService) mocks.mock(
            IInstantIngestionCheckRecordsService.class
        );
        IInstantIngestionRecordsGetterService mockInstantIngestionRecordsGetterService = (IInstantIngestionRecordsGetterService) mocks.mock(
            IInstantIngestionRecordsGetterService.class
        );
        IInstantIngestionQuoteAndQLIService mockQuoteAndQuoteLineService = (IInstantIngestionQuoteAndQLIService) mocks.mock(
            IInstantIngestionQuoteAndQLIService.class
        );
        IPricebookSelector mockpricebookSelector = (IPricebookSelector) mocks.mock(
            IPricebookSelector.class
        );
        IQuoteLineGroupSelector mockQuoteLineGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IQuoteLineItemsSelector mockQuoteLineItemsSelector = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInboundIngestionSelector.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(mockInboundIngestionSelector.selectById(new Set<Id>{ inboundIngestionLogs.Id }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs });
        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuotesSelector.selectById(new Set<Id>{ mockQuoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ newQuote });
        mocks.when(
                mockQuoteAndQuoteLineService.createAdsAndPromosQuoteForMxPortal(
                    (MxPortalPayloadParser) fflib_Match.anyObject(),
                    (Opportunity) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(newQuote);
        mocks.when(
                mockQuoteAndQuoteLineService.createQuoteLineGroup(
                    (Opportunity) fflib_Match.anyObject(),
                    (SBQQ__Quote__c) fflib_Match.anyObject()
                )
            )
            .thenReturn(quoteLineGroup);
        mocks.when(
                mockQuoteAndQuoteLineService.createBundleAndStandaloneQuoteLinesForMxPortalPayload(
                    (MxPortalPayloadParser) fflib_Match.anyObject(),
                    (SBQQ__Quote__c) fflib_Match.anyObject(),
                    (PriceBook2) fflib_Match.anyObject(),
                    (Id) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__QuoteLine__c>{ newParentQuoteLine });
        mocks.when(mockpricebookSelector.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(mockpricebookSelector.selectStandardPricebook()).thenReturn(pricebooks);
        mocks.when(mockQuoteLineGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuoteLineGroupsSelector.selectQuoteLineGroupsByQuoteIds(
                    new Set<Id>{ mockQuoteId }
                )
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{ quoteLineGroup });
        mocks.when(mockQuoteLineItemsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(
                mockQuoteLineItemsSelector.selectQuoteLineItemsFromQuoteIds(
                    new Set<Id>{ mockQuoteId }
                )
            )
            .thenReturn(new List<SBQQ__QuoteLine__c>{ newParentQuoteLine });
        mocks.when(
                mockCheckRecordService.getQuoteLineGroupsByAccountIds(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<Id, SBQQ__QuoteLineGroup__c>{ mockAccountId => quoteLineGroup });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getQuotesByMxPortalUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new Map<String, SBQQ__Quote__c>{ MX_PORTAL_UNIQUE_IDENTIFER => newQuote });
        mocks.when(
                mockInstantIngestionRecordsGetterService.getOpportunitiesByUUID(
                    (Map<String, MxPortalPayloadParser>) fflib_Match.anyObject(),
                    (Map<String, SSOBOnboardingPayloadParser>) fflib_Match.isNull()
                )
            )
            .thenReturn(
                new Map<String, Opportunity>{ MX_PORTAL_UNIQUE_IDENTIFER => testOpportunity }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInboundIngestionSelector);
        Application.SELECTOR.setMock(mockpricebookSelector);
        Application.SELECTOR.setMock(mockQuoteLineGroupsSelector);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SELECTOR.setMock(mockQuoteLineItemsSelector);
        Application.SERVICE.setMock(
            IInstantIngestionQuoteAndQLIService.class,
            mockQuoteAndQuoteLineService
        );
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Application.SERVICE.setMock(
            IInstantIngestionCheckRecordsService.class,
            mockCheckRecordService
        );
        Application.SERVICE.setMock(
            IInstantIngestionRecordsGetterService.class,
            mockInstantIngestionRecordsGetterService
        );
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_UPDATE_QUOTE_TO_PRIMARY => JSON.serialize(
                        new Map<Id, SBQQ__Quote__c>(new List<SBQQ__Quote__c>{ newQuote }).keySet()
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
    }

    /**
     * @description It is used to test whether new store expansion process is initiated or not when
     * event for Mx Portal new store expansion event is published with Dashpass pricing as null.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @isTest
    private static void testWhenNSEEventPublishedWithNullDashpassPricingThenAlsoNewStoreExpansionProcessInitiated() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id mockSubscriptionId = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockContractId = Fake.generateId(Contract.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockDeliveryQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_JSON_PAYLOAD_WITHOUT_DASHPASS
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogs = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            UUID__c = UNIQUE_IDENTIFER,
            Payload__c = payloadString,
            Integration_Type__c = MX_PORTAL_NSE_EVENT,
            Source__c = SOURCE_MX_PORTAL
        );
        Fake businessAccount = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Fake storeAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.ParentId, businessAccountId)
            .setParent('Parent', businessAccount);
        Fake fakeQuoteLineForDashpass = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, mockQuoteLineId)
            .setField(SBQQ__QuoteLine__c.Package_Product__c, PACKAGE_PRODUCT_BASIC_DASHPASS);
        Fake fakeQuoteLineForDelivery = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, mockDeliveryQuoteLineId)
            .setField(SBQQ__QuoteLine__c.Package_Product__c, PACKAGE_PRODUCT_BASIC_DELIVERY);
        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, mockSubscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, mockContractId)
                .setField(SBQQ__Subscription__c.Final_Fee__c, null)
                .setField(SBQQ__Subscription__c.Final_Commission__c, null)
                .setField(SBQQ__Subscription__c.Trial_Commission__c, 1)
                .setField(SBQQ__Subscription__c.Trial_Fee__c, 0)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_DASHPASS)
                .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
                .setField(SBQQ__Subscription__c.Package__c, PRODUCT_NAME_BASIC_PACKAGE)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, mockQuoteLineId)
                .setParent('SBQQ__QuoteLine__r', fakeQuoteLineForDashpass)
                .setParent('SBQQ__Account__r', businessAccount)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, mockSubscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, mockContractId)
                .setField(SBQQ__Subscription__c.Final_Fee__c, 2)
                .setField(SBQQ__Subscription__c.Final_Commission__c, 1)
                .setField(SBQQ__Subscription__c.Trial_Commission__c, 1)
                .setField(SBQQ__Subscription__c.Trial_Fee__c, 0)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, PRODUCT_NAME_DELIVERY)
                .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
                .setField(SBQQ__Subscription__c.Package__c, PRODUCT_NAME_BASIC_PACKAGE)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, mockDeliveryQuoteLineId)
                .setParent('SBQQ__QuoteLine__r', fakeQuoteLineForDelivery)
                .setParent('SBQQ__Account__r', businessAccount)
                .toSobject()
        };
        Business_Vertical__c businessVerticalRx = new Business_Vertical__c(
            Id = mockBusinessVerticalId,
            Name = VERTICAL_RX
        );
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, 'Store')
            .setParent('Salesforce_Account_Name__r', storeAccount)
            .toSObject();
        Map<String, String> chunkedPayloads = new Map<String, String>{
            EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION => JSON.serialize(
                new Map<Id, Inbound_Ingestion_Log__c>(
                        new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogs }
                    )
                    .keySet()
            )
        };
        Instant_Ingestor__e mockInstantIngestorEvent = new Instant_Ingestor__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION),
            Topic__c = EVENT_TOPIC_INITIATE_NEW_STORE_EXPANSION
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
        ISubscriptionSelector mockSubscriptionSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector mockInboundIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalByName(VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRx });
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectXrefByBusinessReferenceExternalId(
                    new List<String>{ BUSINESS_ID }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);

        mocks.when(mockSubscriptionSelector.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionSelector.querySubscriptionRecordsWithAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(mockSubscription);

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
        Application.SELECTOR.setMock(mockSubscriptionSelector);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            mockInstantIngestorEventsService
        );
        Test.startTest();
        MxPortalAmendmentService.execute(new List<Instant_Ingestor__e>{ mockInstantIngestorEvent });
        Test.stopTest();
        ((IInstantIngestorEventsService) mocks.verify(mockInstantIngestorEventsService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_INITIATE_NEW_STORE_ADDITIONS_ON_EXISTING_CONTRACT => JSON.serialize(
                        new Map<Id, Inbound_Ingestion_Log__c>(new List<Inbound_Ingestion_Log__c>{})
                            .keySet()
                    )
                }
            );
    }
}