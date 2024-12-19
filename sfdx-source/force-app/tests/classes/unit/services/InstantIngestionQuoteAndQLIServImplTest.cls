/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionQuoteAndQLIServiceImpl.
 */
@isTest(SeeAllData=false)
private class InstantIngestionQuoteAndQLIServImplTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String STATIC_RESOURCE_TEST_JSON_WITHOUT_DASHPASS = 'Inbound_Ingestion_Payload_Data_Without_Dashpass';
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    private static final String STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String CURRENCY_ISO_CODE_USD = 'USD';
    private static final String SOURCE = 'SSOB';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String PRODUCT_NAME_PREMIER_PACKAGE = 'Premier Package';
    private static final String PRODUCT_NAME_BASIC_PACKAGE = 'Basic Package';
    private static final String PRODUCT_NAME_STOREFRONT_PACKAGE = 'Storefront';
    private static final String PRODUCT_NAME_SOF_PACKAGE = 'Small Order Fulfillment (SOF)';
    private static final String PRODUCT_NAME_DELIVERY = 'Delivery';
    private static final String PRODUCT_NAME_DASHPASS = 'Dashpass';
    private static final String PRODUCT_NAME_REGULATORY_DASHER_FEE = 'Regulatory Dasher Fee - CA';
    private static final String PRODUCT_NAME_CX_DELIVERY = 'Cx Delivery Fee';
    private static final String PRODUCT_DESCRIPTION_DELIVERY = 'Delivery Product';
    private static final String PRODUCT_DESCRIPTION_DASHPASS = 'Dashpass Product';
    private static final String UNIQUE_IDENTIFIER = 'testMxp-53-6y6hdd9-4a0c-9193-9152-b86fe4';
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
    private static final Set<String> MX_PORTAL_OPTION_PRODUCT_NAMES = new Set<String>{
        'Service Rate',
        'Set Up Fee',
        'Subscription Fee',
        'Mx Delivery Fee',
        'Payment Processing Fee',
        'Payment Processing Rate',
        'Pickup',
        'Cx Delivery Fee',
        'Service Rate'
    };
    private static final Set<String> PACKAGE_PRODUCT_NAMES = new Set<String>{
        'Premier Package',
        'Hardware',
        'Storefront'
    };
    private static final Set<String> MX_PORTAL_PACKAGES_NAMES = new Set<String>{ 'Storefront' };

    //Inbound_Ingestion_Payload_Data_SSOB
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSSOBPayloadPassedThenCreateQuotes() {
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Opportunity mockOpportunity = new Opportunity(Id = mockOpportunityId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        Test.startTest();
        SBQQ__Quote__c quote = InstantIngestionQuoteAndQLIService.createSSOBQuotes(
            payload,
            mockOpportunity,
            mockPricebook.Id,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            mockOpportunity.Id,
            quote.SBQQ__Opportunity2__c,
            INVALID_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to test whether a Quote is created or not when the payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateQuotes() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Account mockAccount = new Account(Id = mockAccountId);
        Opportunity mockOpportunity = new Opportunity(Id = mockOpportunityId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Test.startTest();
        SBQQ__Quote__c quote = InstantIngestionQuoteAndQLIService.createQuote(
            payload,
            mockOpportunity,
            mockAccount,
            mockPricebook.Id,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            mockOpportunity.Id,
            quote.SBQQ__Opportunity2__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether a Quote is created or not when the ads and promos mx portal
     * payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxPortalPayloadForAdsPromosPassedThenNewQuoteCreated() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockcontactId = Fake.generateId(Contact.class);
        Id mockOpportunityId = Fake.generateId(Opportunity.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            AccountId = mockAccountId,
            ContactId = mockcontactId,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        Test.startTest();
        SBQQ__Quote__c quote = InstantIngestionQuoteAndQLIService.createAdsAndPromosQuoteForMxPortal(
            payload,
            mockOpportunity,
            mockPricebook.Id,
            SOURCE_MX_PORTAL
        );
        Test.stopTest();
        System.assertEquals(
            mockOpportunity.Id,
            quote.SBQQ__Opportunity2__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateQuoteLinesForSSOB() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryId = Fake.generateId(PricebookEntry.class);
        Id quoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        // Create a mock Pricebook2 instance
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);

        // Create a Fake Product2 instance for Small Order Fulfillment (SOF)
        Fake productSOFInstance = new Fake(Product2.class)
            .setField(Product2.Id, mockProductId)
            .setField(Product2.Name, PRODUCT_NAME_SOF_PACKAGE);

        // Create the first PricebookEntry
        PricebookEntry priceBookEntryFirst = (PricebookEntry) new Fake(PricebookEntry.class)
            .setField(PricebookEntry.Id, mockPriceBookEntryId)
            .setField(PricebookEntry.Pricebook2Id, mockPricebookId)
            .setField(PricebookEntry.Product2Id, mockProductId)
            .setField(PricebookEntry.CurrencyIsoCode, CURRENCY_ISO_CODE_USD)
            .setParent('Product2__r', productSOFInstance)
            .toSObject();

        // Add all PricebookEntries to a list
        List<PricebookEntry> entries = new List<PricebookEntry>{ priceBookEntryFirst };

        //PricebookEntry pricebookEntries = new PricebookEntry(Id = mockPriceBookEntryId,CurrencyIsoCode=CURRENCY_ISO_CODE_USD);
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelector = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelector.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelector.selectByProductNamesAndCurrency(
                    new Set<String>{ 'Small Order Fulfillment (SOF)' },
                    CURRENCY_ISO_CODE_USD
                )
            )
            .thenReturn(entries);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForSSOBPayload(
            payload,
            mockQuote,
            mockPricebook,
            quoteLineGroupId,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLines[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether a Quote Line are created or not when the payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateQuoteLines() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryId = Fake.generateId(PricebookEntry.class);
        Id quoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntries = new PricebookEntry(Id = mockPriceBookEntryId);
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelector = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelector.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelector.selectByProductNamesAndCurrency(
                    PACKAGE_PRODUCT_NAMES,
                    CURRENCY_ISO_CODE_USD
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntries });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
            payload,
            mockQuote,
            mockPricebook,
            quoteLineGroupId,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLines[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether Trial_Period on Quote Line are created or not when the payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTrialsReceivedInSSMOPayloadThenQuoteLinesWithTrialDetailsCreated() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        Id mockProductOptionId = Fake.generateId(SBQQ__ProductOption__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockOptionProductId = Fake.generateId(Product2.class);
        Id mockOptionProductFeatureId = Fake.generateId(SBQQ__ProductFeature__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        SBQQ__QuoteLine__c mockQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );
        SBQQ__ProductOption__c productOption = (SBQQ__ProductOption__c) new Fake(
                SBQQ__ProductOption__c.class
            )
            .setField(SBQQ__ProductOption__c.Id, mockProductOptionId)
            .setParent(
                'SBQQ__ConfiguredSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockProductId)
                    .setField(Product2.Name, PRODUCT_NAME_PREMIER_PACKAGE)
            )
            .setParent(
                'SBQQ__OptionalSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockOptionProductId)
                    .setField(Product2.Name, PRODUCT_NAME_DELIVERY)
                    .setField(Product2.Description, PRODUCT_DESCRIPTION_DELIVERY)
            )
            .setParent(
                'SBQQ__Feature__r',
                new Fake(SBQQ__ProductFeature__c.class)
                    .setField(SBQQ__ProductFeature__c.Id, mockOptionProductFeatureId)
            )
            .toSObject();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        ICPQProductOptionsSelector mockProductOptionsSelector = (ICPQProductOptionsSelector) mocks.mock(
            ICPQProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockProductOptionsSelector.sObjectType())
            .thenReturn(SBQQ__ProductOption__c.SObjectType);
        mocks.when(
                mockProductOptionsSelector.selectByProductNames(
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__ProductOption__c>{ productOption });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineOptions = InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForInstantIngestionPayload(
            payload,
            new Map<String, SBQQ__QuoteLine__c>{ PRODUCT_NAME_PREMIER_PACKAGE => mockQuoteLine },
            mockQuote,
            mockPricebook
        );
        Test.stopTest();
        System.assertEquals(
        payload.store.orderProducts[0].productOptions[0].trialDuration,
        quoteLineOptions[0].Trial_Period__c,
        INVALID_ASSERT_MESSAGE
       );
    }
    /**
     * @description It is used to test whether a Quote Line are created or not when the mx portal
     * payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxPortalPayloadPassedThenCreateQuoteLines() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryId = Fake.generateId(PricebookEntry.class);
        Id quoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntries = new PricebookEntry(Id = mockPriceBookEntryId);
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelector = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelector.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelector.selectByProductNamesAndCurrency(
                    MX_PORTAL_PACKAGES_NAMES,
                    CURRENCY_ISO_CODE_USD
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntries });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = InstantIngestionQuoteAndQLIService.createBundleAndStandaloneQuoteLinesForMxPortalPayload(
            payload,
            mockQuote,
            mockPricebook,
            quoteLineGroupId,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLines[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether a Quote Line options are created or not when the payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateQuoteLineOptions() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        Id mockProductOptionId = Fake.generateId(SBQQ__ProductOption__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockOptionProductId = Fake.generateId(Product2.class);
        Id mockOptionProductFeatureId = Fake.generateId(SBQQ__ProductFeature__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        SBQQ__QuoteLine__c mockQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );
        SBQQ__ProductOption__c productOption = (SBQQ__ProductOption__c) new Fake(
                SBQQ__ProductOption__c.class
            )
            .setField(SBQQ__ProductOption__c.Id, mockProductOptionId)
            .setParent(
                'SBQQ__ConfiguredSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockProductId)
                    .setField(Product2.Name, PRODUCT_NAME_PREMIER_PACKAGE)
            )
            .setParent(
                'SBQQ__OptionalSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockOptionProductId)
                    .setField(Product2.Name, PRODUCT_NAME_DELIVERY)
                    .setField(Product2.Description, PRODUCT_DESCRIPTION_DELIVERY)
            )
            .setParent(
                'SBQQ__Feature__r',
                new Fake(SBQQ__ProductFeature__c.class)
                    .setField(SBQQ__ProductFeature__c.Id, mockOptionProductFeatureId)
            )
            .toSObject();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        ICPQProductOptionsSelector mockProductOptionsSelector = (ICPQProductOptionsSelector) mocks.mock(
            ICPQProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockProductOptionsSelector.sObjectType())
            .thenReturn(SBQQ__ProductOption__c.SObjectType);
        mocks.when(
                mockProductOptionsSelector.selectByProductNames(
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__ProductOption__c>{ productOption });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineOptions = InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForInstantIngestionPayload(
            payload,
            new Map<String, SBQQ__QuoteLine__c>{ PRODUCT_NAME_PREMIER_PACKAGE => mockQuoteLine },
            mockQuote,
            mockPricebook
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLineOptions[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether a Quote Line options are created or not when the payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateQuoteLineOptionsWithoutDashpass() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        Id mockProductOptionId = Fake.generateId(SBQQ__ProductOption__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockOptionProductId = Fake.generateId(Product2.class);
        Id mockOptionProductFeatureId = Fake.generateId(SBQQ__ProductFeature__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON_WITHOUT_DASHPASS
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        SBQQ__QuoteLine__c mockQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );
        SBQQ__ProductOption__c productOptionForDelivery = (SBQQ__ProductOption__c) new Fake(
                SBQQ__ProductOption__c.class
            )
            .setField(SBQQ__ProductOption__c.Id, mockProductOptionId)
            .setParent(
                'SBQQ__ConfiguredSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockProductId)
                    .setField(Product2.Name, PRODUCT_NAME_BASIC_PACKAGE)
            )
            .setParent(
                'SBQQ__OptionalSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockOptionProductId)
                    .setField(Product2.Name, PRODUCT_NAME_DELIVERY)
                    .setField(Product2.Description, PRODUCT_DESCRIPTION_DELIVERY)
            )
            .setParent(
                'SBQQ__Feature__r',
                new Fake(SBQQ__ProductFeature__c.class)
                    .setField(SBQQ__ProductFeature__c.Id, mockOptionProductFeatureId)
            )
            .toSObject();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        ICPQProductOptionsSelector mockProductOptionsSelector = (ICPQProductOptionsSelector) mocks.mock(
            ICPQProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockProductOptionsSelector.sObjectType())
            .thenReturn(SBQQ__ProductOption__c.SObjectType);
        mocks.when(
                mockProductOptionsSelector.selectByProductNames(
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__ProductOption__c>{ productOptionForDelivery });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineOptions = InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForInstantIngestionPayload(
            payload,
            new Map<String, SBQQ__QuoteLine__c>{ PRODUCT_NAME_BASIC_PACKAGE => mockQuoteLine },
            mockQuote,
            mockPricebook
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLineOptions[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
        //Payload includes Delivery and Dashpass for Basic Package, but Dashpass is skipped for creation.
        System.assertEquals(1, quoteLineOptions.size(), quoteLineOptions);
    }

    /**
     * @description It is used to test whether a Quote Line options are created or not when the
     * mx portal payload is passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxPortalPayloadPassedThenCreateQuoteLineOptions() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        Id mockProductOptionId = Fake.generateId(SBQQ__ProductOption__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockOptionProductId = Fake.generateId(Product2.class);
        Id mockOptionProductFeatureId = Fake.generateId(SBQQ__ProductFeature__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        SBQQ__QuoteLine__c mockQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );
        SBQQ__ProductOption__c productOption = (SBQQ__ProductOption__c) new Fake(
                SBQQ__ProductOption__c.class
            )
            .setField(SBQQ__ProductOption__c.Id, mockProductOptionId)
            .setParent(
                'SBQQ__ConfiguredSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockProductId)
                    .setField(Product2.Name, PRODUCT_NAME_STOREFRONT_PACKAGE)
            )
            .setParent(
                'SBQQ__OptionalSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockOptionProductId)
                    .setField(Product2.Name, PRODUCT_NAME_CX_DELIVERY)
                    .setField(Product2.Description, PRODUCT_DESCRIPTION_DELIVERY)
            )
            .setParent(
                'SBQQ__Feature__r',
                new Fake(SBQQ__ProductFeature__c.class)
                    .setField(SBQQ__ProductFeature__c.Id, mockOptionProductFeatureId)
            )
            .toSObject();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        ICPQProductOptionsSelector mockProductOptionsSelector = (ICPQProductOptionsSelector) mocks.mock(
            ICPQProductOptionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockProductOptionsSelector.sObjectType())
            .thenReturn(SBQQ__ProductOption__c.SObjectType);
        mocks.when(
                mockProductOptionsSelector.selectByProductNames(
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__ProductOption__c>{ productOption });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineOptions = InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForMxPortalPayload(
            payload,
            new Map<String, SBQQ__QuoteLine__c>{ PRODUCT_NAME_STOREFRONT_PACKAGE => mockQuoteLine },
            mockQuote,
            mockPricebook
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLineOptions[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSSOBPortalPayloadPassedThenCreateQuoteLineOptions() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id mockPricebookId = Fake.generateId(Pricebook2.class);
        Id mockPriceBookEntryIdForOption = Fake.generateId(PricebookEntry.class);
        Id mockProductOptionId = Fake.generateId(SBQQ__ProductOption__c.class);
        Id mockProductId = Fake.generateId(Product2.class);
        Id mockOptionProductId = Fake.generateId(Product2.class);
        Id mockDiscountScheduleId = Fake.generateId(SBQQ__DiscountSchedule__c.class);
        Id mockDiscountTierId = Fake.generateId(SBQQ__DiscountTier__c.class);
        Id mockOptionProductFeatureId = Fake.generateId(SBQQ__ProductFeature__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            CurrencyISOCode = CURRENCY_ISO_CODE_USD
        );
        SBQQ__QuoteLine__c mockQuoteLine = new SBQQ__QuoteLine__c(Id = mockQuoteLineId);
        Pricebook2 mockPricebook = new Pricebook2(Id = mockPricebookId);
        PricebookEntry pricebookEntriesForOptions = new PricebookEntry(
            Id = mockPriceBookEntryIdForOption
        );
        SBQQ__ProductOption__c productOption = (SBQQ__ProductOption__c) new Fake(
                SBQQ__ProductOption__c.class
            )
            .setField(SBQQ__ProductOption__c.Id, mockProductOptionId)
            .setParent(
                'SBQQ__ConfiguredSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockProductId)
                    .setField(Product2.Name, PRODUCT_NAME_SOF_PACKAGE)
            )
            .setParent(
                'SBQQ__OptionalSKU__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, mockOptionProductId)
                    .setField(Product2.Name, PRODUCT_NAME_REGULATORY_DASHER_FEE)
                    .setField(Product2.Description, PRODUCT_DESCRIPTION_DELIVERY)
            )
            .setParent(
                'SBQQ__Feature__r',
                new Fake(SBQQ__ProductFeature__c.class)
                    .setField(SBQQ__ProductFeature__c.Id, mockOptionProductFeatureId)
            )
            .toSObject();
        Fake discountschedules = new Fake(SBQQ__DiscountSchedule__c.class)
            .setField(SBQQ__DiscountSchedule__c.Id, mockDiscountScheduleId)
            .setField(SBQQ__DiscountSchedule__c.SBQQ__Product__c, mockOptionProductId);
        SBQQ__DiscountTier__c discountTier = (SBQQ__DiscountTier__c) new Fake(
                SBQQ__DiscountTier__c.class
            )
            .setField(SBQQ__DiscountTier__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__DiscountTier__c.Id, mockDiscountTierId)
            .setParent('SBQQ__Schedule__r', discountschedules)
            .toSObject();
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookEntriesSelector mockpricebookEntriesSelectorForOptions = (IPricebookEntriesSelector) mocks.mock(
            IPricebookEntriesSelector.class
        );
        ICPQProductOptionsSelector mockProductOptionsSelector = (ICPQProductOptionsSelector) mocks.mock(
            ICPQProductOptionsSelector.class
        );
        IDiscountTiersSelector mockDiscountTierSelector = (IDiscountTiersSelector) mocks.mock(
            IDiscountTiersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockpricebookEntriesSelectorForOptions.sObjectType())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(
                mockpricebookEntriesSelectorForOptions.selectByProductNamesAndCurrency(
                    (Set<String>) fflib_Match.anyObject(),
                    (String) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<PricebookEntry>{ pricebookEntriesForOptions });
        mocks.when(mockProductOptionsSelector.sObjectType())
            .thenReturn(SBQQ__ProductOption__c.SObjectType);
        mocks.when(
                mockProductOptionsSelector.selectByProductNames(
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<SBQQ__ProductOption__c>{ productOption });
        mocks.when(mockDiscountTierSelector.sObjectType())
            .thenReturn(SBQQ__DiscountTier__c.SObjectType);
        mocks.when(mockDiscountTierSelector.selectByUUID(new Set<String>{ UNIQUE_IDENTIFIER }))
            .thenReturn(new List<SBQQ__DiscountTier__c>{ discountTier });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockpricebookEntriesSelectorForOptions);
        Application.SELECTOR.setMock(mockProductOptionsSelector);
        Application.SELECTOR.setMock(mockDiscountTierSelector);
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineOptions = InstantIngestionQuoteAndQLIService.createQuoteLineOptionsByParentForSsobPayload(
            payload,
            new Map<String, SBQQ__QuoteLine__c>{ PRODUCT_NAME_SOF_PACKAGE => mockQuoteLine },
            new Map<String, List<SBQQ__DiscountTier__c>>{
                UNIQUE_IDENTIFIER => new List<SBQQ__DiscountTier__c>{ discountTier }
            },
            mockQuote,
            mockPricebook
        );
        Test.stopTest();
        System.assertEquals(
            payload.Uuid,
            quoteLineOptions[0].Unique_Identifier__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test whether a quote status is updated to contract signed or not.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIdsPassedThenQuoteUpdatedToOrdered() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id ingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            Slack_Notification_To_Opportunity_Owner__c = false,
            unique_identifier__c = UNIQUE_IDENTIFIER
        );
        Inbound_ingestion_Log__c ingestionlog = new Inbound_ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockpQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IInboundIngestionLogsSelector mockIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockpQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockpQuotesSelector.selectById(new Set<Id>{ mockQuoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote });
        mocks.when(mockIngestionSelector.sObjectType())
            .thenReturn(Inbound_ingestion_Log__c.SObjectType);
        mocks.when(
                mockIngestionSelector.selectInboundIngestionLogsByUUIDs(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.SELECTOR.setMock(mockpQuotesSelector);
        Application.SELECTOR.setMock(mockIngestionSelector);

        Test.startTest();
        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesToOrdered(
            new Set<Id>{ mockQuote.Id }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 3)).commitWork();
    }
    /**
     * @description It is used to test whether a quote status is updated to contract signed or not.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIdsPassedThenQuoteStatusUpdatedToContractSigned() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Test.startTest();
        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesToPrimaryAndContractSigned(
            new Set<Id>{ mockQuoteId }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 2)).commitWork();
    }

    /**
     * @description It is used to test whether the flag to send slack notification is updated or not.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIdsPassedThenQuoteFlagUpdatedToSendSlackNotification() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id ingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = mockQuoteId,
            unique_identifier__c = UNIQUE_IDENTIFIER
        );
        Inbound_ingestion_Log__c ingestionlog = new Inbound_ingestion_Log__c(
            Id = ingestionLogId,
            UUID__c = UNIQUE_IDENTIFIER
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector mockIngestionSelector = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        IQuotesSelector mockpQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockpQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockpQuotesSelector.selectById(new Set<Id>{ mockQuoteId }))
            .thenReturn(new List<SBQQ__Quote__c>{ mockQuote });
        mocks.when(mockIngestionSelector.sObjectType())
            .thenReturn(Inbound_ingestion_Log__c.SObjectType);
        mocks.when(
                mockIngestionSelector.selectInboundIngestionLogsByUUIDs(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_ingestion_Log__c>{ ingestionlog });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        Application.SELECTOR.setMock(mockIngestionSelector);
        Application.SELECTOR.setMock(mockpQuotesSelector);
        Test.startTest();
        InstantIngestionQuoteAndQLIService.updateInstantIngestionQuotesForSlackNotifications(
            new Set<Id>{ mockQuoteId }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 3)).commitWork();
    }
}