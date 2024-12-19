/**
 * @author Deloitte
 * @date 06/23/2024
 * @description Test class for InstantIngestionRecordsGetterService class.
 */
@isTest(SeeAllData=false)
private class InstantIngestionRecordsGetterServImpTest {
    private static final String BUSINESS = 'Business';
    private static final String USD_CURRENCY = 'USD';
    private static final String STORE = 'Store';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    private static final String BUSINESS_ID = '12820285';
    private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
    private static final String BUSINESS_VERTICAL_RX = System.label.RestaurantMenuUIType;
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String MX_PORTAL_UNIQUE_IDENTIFIER = 'MxPAddStorefront66-53-6y6hdd9-4a0c-9193-9152aeb86fe4';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String QUOTE_NUMBER = 'Q-123456';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final String ONBOARDING_EVENT = 'Onboarding Event';

    /**
     * @description It is used to check whether a business vertical exist in the system with the
     * same name as the one passed in the method argument.
     */
    @isTest
    private static void testWhenBusinessVerticalNamePassedThenBusinessVerticalReturned() {
        Id businessVerticalId = Fake.generateId(Business_Vertical__c.class);

        Business_Vertical__c rxBusinessVertical = new Business_Vertical__c(
            Id = businessVerticalId,
            Name = BUSINESS_VERTICAL_RX
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessVerticalsSelector mockbusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockbusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockbusinessVerticalsSelector.selectBusinessVerticalByName(BUSINESS_VERTICAL_RX))
            .thenReturn(new List<Business_Vertical__c>{ rxBusinessVertical });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockbusinessVerticalsSelector);

        Test.startTest();
        Business_Vertical__c businessVerticalRx = InstantIngestionRecordsGetterService.getRxBusinessVertical();
        Test.stopTest();
        System.assertEquals(businessVerticalRx.Id, businessVerticalId, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to check whether a business account exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenBusinessAccountsReturned() {
        Id businessAccountId = Fake.generateId(Account.class);
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
        Account accounts = new Account(
            Id = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = BUSNINESS_RECORD_TYPE_ID
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockBusinessAccountSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
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
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBusinessAccountSelector);
        Test.startTest();
        Map<String, Account> businessAccountbyRecordType = InstantIngestionRecordsGetterService.getBusinessAccountByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(
            businessAccountbyRecordType.get(UNIQUE_IDENTIFER),
            accounts,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a Contact exist in the system with the Contact
     * Id passed in the payload.
     */
    @isTest
    private static void testWhenPayloadWithMatchedRecordsPassedThenContactsReturned() {
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
        Id contactId = new Map<Id, Contact>(payload.store.matchedRecords.contact)
            .keySet()
            .iterator()
            .next();

        Contact newContact = new Contact(
            Id = contactId,
            Email = CONTACT_EMAIL,
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(mockContactsSelector.selectById(new Set<Id>{ contactId }))
            .thenReturn(new List<Contact>{ newContact });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContactsSelector);
        Test.startTest();
        Map<String, Contact> contactFromPayload = InstantIngestionRecordsGetterService.getContactsByMatchedRecord(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload }
        );
        Test.stopTest();
        System.assertEquals(
            contactFromPayload.get(UNIQUE_IDENTIFER),
            newContact,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a business reference exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenBusinessReferencesReturned() {
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
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
        Business_Reference__c bizref = new Business_Reference__c(
            Id = bizRefId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            Brand__c = mockBrandId,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Business_Vertical__c = mockBusinessVerticalId,
            External_Id__c = BUSINESS_ID
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector mockBusinessReferenceSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockBusinessReferenceSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessReferenceSelector.selectBusinessReferenceByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ bizref });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBusinessReferenceSelector);
        Test.startTest();
        Map<String, Business_Reference__c> bizRefsbyRecordType = InstantIngestionRecordsGetterService.getBizRefByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(
            bizRefsbyRecordType.get(UNIQUE_IDENTIFER),
            bizref,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a store account exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenStoreAccountsReturned() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
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
        Account accounts = new Account(
            Id = businessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = BUSNINESS_RECORD_TYPE_ID
        );
        Account storeAccounts = new Account(
            Id = storeAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            parentId = accounts.Id
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockStoreAccountSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockStoreAccountSelector.selectAccountsByUniqueIdentifiersAndRecordType(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    STORE_RECORD_TYPE_ID
                )
            )
            .thenReturn(new List<Account>{ storeAccounts });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreAccountSelector);
        Test.startTest();
        Map<String, Account> storeAccountbyRecordType = InstantIngestionRecordsGetterService.getStoreAccountByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload }
        );
        Test.stopTest();
        System.assertEquals(
            storeAccountbyRecordType.get(UNIQUE_IDENTIFER),
            storeAccounts,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a brand exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenBrandsReturned() {
        Id mockBrandId = Fake.generateId(Brand__c.class);
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
        Brand__c brand = new Brand__c(Id = mockBrandId, Unique_Identifier__c = UNIQUE_IDENTIFER);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandsSelector mockBrandSelector = (IBrandsSelector) mocks.mock(IBrandsSelector.class);
        mocks.startStubbing();
        mocks.when(mockBrandSelector.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(
                mockBrandSelector.selectBrandsByUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<Brand__c>{ brand });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBrandSelector);
        Test.startTest();
        Map<String, Brand__c> brandByUUID = InstantIngestionRecordsGetterService.getBrandByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(brandByUUID.get(UNIQUE_IDENTIFER), brand, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to check whether a quote exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenQuotesReturned() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
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
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            CurrencyIsoCode = USD_CURRENCY
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuoteselector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockQuoteselector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockQuoteselector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ quote });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockQuoteselector);
        Test.startTest();
        Map<String, SBQQ__Quote__c> quotesByUUID = InstantIngestionRecordsGetterService.getQuotesByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(quotesByUUID.get(UNIQUE_IDENTIFER), quote, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to check whether a quote exist in the system with the passed
     * mx portal unique identifier.
     */
    @isTest
    private static void testWhenMxPortalPayloadPassedThenQuotesReturned() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            Unique_Identifier__c = MX_PORTAL_UNIQUE_IDENTIFIER,
            CurrencyIsoCode = USD_CURRENCY
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuoteselector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(mockQuoteselector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                mockQuoteselector.selectQuotesbyUniqueIdentifiers(
                    new Set<String>{ MX_PORTAL_UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<SBQQ__Quote__c>{ quote });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockQuoteselector);
        Test.startTest();
        Map<String, SBQQ__Quote__c> quotesByUUID = InstantIngestionRecordsGetterService.getQuotesByMxPortalUUID(
            new Map<String, MxPortalPayloadParser>{ MX_PORTAL_UNIQUE_IDENTIFIER => payload }
        );
        Test.stopTest();
        System.assertEquals(
            quotesByUUID.get(MX_PORTAL_UNIQUE_IDENTIFIER),
            quote,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether a quote lines exist in the system with the same
     * unique identifier as the one passed in the method argument.
     */
    @isTest
    private static void testWhenPayloadPassedThenQuoteLinesReturned() {
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
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
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, mockQuoteLineId)
                .setField(SBQQ__QuoteLine__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
                .setField(SBQQ__QuoteLine__c.SBQQ__Number__c, 1)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, mockGroupId)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, mockQuoteId)
                .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, PRODUCT_NAME_MARKETPLACE)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector mockQuoteLinesSelector = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockQuoteLinesSelector.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(
                mockQuoteLinesSelector.selectQuoteLinesbyUniqueIdentifiers(
                    new Set<String>{ UNIQUE_IDENTIFER }
                )
            )
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockQuoteLinesSelector);
        Test.startTest();
        Map<String, SBQQ__QuoteLine__c> quotesLinesByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByUUID(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(
            quotesLinesByUUID.get(PRODUCT_NAME_MARKETPLACE),
            quoteLineItems[0],
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether quote lines exist in the system with the same passed
     * mx portal unique identifier.
     */
    @isTest
    private static void testWhenMxPortalPayloadPassedThenQuoteLinesReturned() {
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, mockQuoteLineId)
                .setField(SBQQ__QuoteLine__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
                .setField(SBQQ__QuoteLine__c.SBQQ__Number__c, 1)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, mockGroupId)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, mockQuoteId)
                .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, PRODUCT_NAME_MARKETPLACE)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector mockQuoteLinesSelector = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockQuoteLinesSelector.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(
                mockQuoteLinesSelector.selectQuoteLinesbyUniqueIdentifiers(
                    new Set<String>{ MX_PORTAL_UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockQuoteLinesSelector);
        Test.startTest();
        Map<String, SBQQ__QuoteLine__c> quotesLinesByUUID = InstantIngestionRecordsGetterService.getQuoteLinesByMxPortalUUID(
            new Map<String, MxPortalPayloadParser>{ MX_PORTAL_UNIQUE_IDENTIFIER => payload }
        );
        Test.stopTest();
        System.assertEquals(
            quotesLinesByUUID.get(PRODUCT_NAME_MARKETPLACE),
            quoteLineItems[0],
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether opportunities exist in the system with the same passed
     * mx portal unique identifier.
     */
    @isTest
    private static void testWhenMxPortalPayloadPassedThenOpportunitiesReturned() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        Fake accounts = new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID);
        Account businessAccount = (Account) accounts.toSObject();

        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Name, QUOTE_NUMBER)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
            .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityId);

        Opportunity fakeOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_NEW)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_NET_NEW)
            .setField(Opportunity.CloseDate, Date.today() + 1)
            .setField(Opportunity.Deal_Type__c, OPPORTUNITY_DEAL_TYPE_STANDARD)
            .setField(Opportunity.SBQQ__PrimaryQuote__c, quoteId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFER)
            .setField(Opportunity.AccountId, businessAccount.Id)
            .setField(Opportunity.ContactId, contactId)
            .setParent('Account', accounts)
            .setParent('SBQQ__PrimaryQuote__r', fakeQuote)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockOpportunitySelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitySelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitySelector.getOpportunitiesbyUniqueIdentifiers(
                    new Set<String>{ MX_PORTAL_UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Opportunity>{ fakeOpportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitySelector);
        Test.startTest();
        Map<String, Opportunity> opportunitiesByUUID = InstantIngestionRecordsGetterService.getOpportunitiesByUUID(
            new Map<String, MxPortalPayloadParser>{ MX_PORTAL_UNIQUE_IDENTIFIER => payload },
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Test.stopTest();
        System.assertEquals(
            opportunitiesByUUID.get(UNIQUE_IDENTIFER),
            fakeOpportunity,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to check whether existing contract is present or not under the business
     * account.
     */
    @isTest
    private static void testWhenMxPortalPayloadPassedThenExistingContractsByBusinessAccountReturned() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);

        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, businessAccountId);
        Contract contract = (Contract) fakeContract.toSObject();

        Fake fakeAgreement = new Fake(Agreement__c.class)
            .setField(Agreement__c.Account__c, storeAccountId)
            .setParent('Contract__r', fakeContract);
        Agreement__c agreements = (Agreement__c) fakeAgreement.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector mockAgreementSelector = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAgreementSelector.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(mockAgreementSelector.selectAgreementsByAccounts(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Agreement__c>{ agreements });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAgreementSelector);
        Test.startTest();
        Map<Id, Contract> contractByBusinessAccount = InstantIngestionRecordsGetterService.getExistingContractByBusinessAccount(
            new Set<Id>{ storeAccountId }
        );
        Test.stopTest();
        System.assertEquals(
            contractByBusinessAccount.get(businessAccountId),
            contract,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description This is a unit test method that tests the behavior of the getStoreAccountWithXref method in the InstantIngestionRecordsGetterService class.
     * It verifies that when the getStoreAccountWithXref method is called with a payload map containing a unique identifier, it returns a list of store accounts.
     * The test sets up the necessary data and mocks the dependencies using fflib_ApexMocks.
     * It then calls the getStoreAccountWithXref method and asserts that the returned list contains one account with the expected ID.
     */
    @isTest
    private static void testWhenGetStoreAccountWithXrefThenReturnStoreAccount() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id storeAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
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
        payload.uuid = UNIQUE_IDENTIFER;
        Account storeAccount = new Account(
            Id = storeAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFER,
            RecordTypeId = storeAccountRecordTypeId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockStoreAccountSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStoreAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockStoreAccountSelector.selectStoreAccountByUUIDWithXrefs(
                    new Set<String>{ UNIQUE_IDENTIFER },
                    new Set<String>{ payload.business.businessId }
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStoreAccountSelector);
        Test.startTest();
        List<Account> accResult = InstantIngestionRecordsGetterService.getStoreAccountWithXref(
            new Map<String, InstantIngestionPayloadParser>{ UNIQUE_IDENTIFER => payload }
        );
        Test.stopTest();
        Assert.areEqual(accResult.size(), 1, 'size should be 1');
        Assert.areEqual(accResult[0].Id, storeAccountId, 'Id should be equal');
    }
}