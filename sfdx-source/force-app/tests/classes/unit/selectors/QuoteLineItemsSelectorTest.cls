/**
 * @author Deloitte
 * @date 11/17/2022
 * @description Test class for QuoteLineItemsSelector
 */
@isTest(SeeAllData=false)
private class QuoteLineItemsSelectorTest {
    private static final String AMENDMENT = 'Amendment';
    private static final String QUOTE = 'Quote';
    private static final String DISTANCE_BASED = 'Distance Based (incl. tiered)';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String UNIQUE_IDENTIFIER = '3242342-324234d-23423';
    private static final string INVALID_ASSERT_MESSAGE = 'The Quote Line Items were not retrieved.';

    @testSetup
    static void setupData() {
        Test.startTest();
        SBQQ.TriggerControl.disable();
        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Family = 'Advertisement';
        insert product;
        Product2 prodPackage = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);

        SBQQ__ProductOption__c prodOption = CPQTestDataFactory.createProductOption(
            product,
            prodPackage,
            false
        );
        prodOption.Active_Rate_Eligible__c = true;
        insert prodOption;

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLineGroup__c qlGroup = CPQTestDataFactory.createGroup(quote.Id, true);
        qlGroup.CCP_Unique_Group_Id__c = Id.valueOf(qlGroup.Id);
        update qlGroup;
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, false);
        quoteLine.SBQQ__Group__c = qlGroup.Id;
        quoteLine.Campaign_Name__c = 'Halloween Deals';
        quoteLine.SBQQ__ProductOption__c = prodOption.Id;
        quoteLine.SBQQ__Group__c = qlGroup.Id;
        insert quoteLine;

        Order qlOrder = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, true);
        OrderItem qlOrderItem = CPQTestDataFactory.createOrderItem(
            qlOrder,
            quoteLine,
            pbe.Id,
            true
        );
        quote.SBQQ__Status__c = 'Approved';
        quote.Signed_Contract_Link__c = 'Link';
        quote.Contract_Signed_Date__c = System.today() - 5;
        update quote;

        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);
        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contract.Id;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        subRec.SBQQ__OrderProduct__c = qlOrderItem.Id;
        insert subRec;
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        QuoteLineItemsSelector lineItemsSelectorInstance = new QuoteLineItemsSelector();

        Schema.SObjectType typeOfObj = lineItemsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = lineItemsSelectorInstance.getSObjectFieldList();

        QuoteLineItemsSelector.newInstance();

        System.assertEquals(
            Schema.SBQQ__QuoteLine__c.SObjectType,
            typeOfObj,
            'The object type must be Quote Line.'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                SBQQ__QuoteLine__c.Id,
                SBQQ__QuoteLine__c.Name,
                SBQQ__QuoteLine__c.Campaign_Name__c,
                SBQQ__QuoteLine__c.SBQQ__Quote__c,
                SBQQ__QuoteLine__c.Custom_Creative_Required__c,
                SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c,
                SBQQ__QuoteLine__c.SBQQ__Quantity__c,
                SBQQ__QuoteLine__c.Program_Type__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenSelectByIdThenReturnQuoteLinesWithGroupFields() {
        Set<Id> quoteLineIds = new Set<Id>{
            [
                SELECT Id, SBQQ__Group__c, SBQQ__Group__r.CCP_Unique_Group_Id__c
                FROM SBQQ__QuoteLine__c
                LIMIT 1
            ]
            .Id
        };
        SBQQ__QuoteLineGroup__c grp = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectQuoteLineGroupFields(quoteLineIds);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
        System.assertEquals(
            quoteLines[0].SBQQ__Group__r.CCP_Unique_Group_Id__c,
            Id.valueOf(grp.Id),
            'The QuoteLine Item retrieved is not related to the expected group.'
        );
    }

    @isTest
    private static void testWhenSelectDrawerFieldByQuotesThenReturnAttributes() {
        Set<Id> quoteIds = new Set<Id>{ [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id };
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectDrawerFieldByQuotes(quoteIds);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
        System.assertEquals(
            quoteLines[0].Campaign_Name__c,
            'Halloween Deals',
            'The QuoteLine Item retrieved is not related to the expected campaign.'
        );
    }
    @isTest
    private static void testWhenSelectByQuoteIdsThenReturnQuoteLinesWithMissingGroups() {
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Product2 productId = [SELECT id FROM Product2 WHERE family = :'Advertisement' LIMIT 1];

        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, true);
        SBQQ__Quote__c amendedQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        amendedQuote.SBQQ__Type__c = 'Amendment';
        insert amendedQuote;

        SBQQ__QuoteLine__c originalQuoteLine = [
            SELECT id, SBQQ__Group__c
            FROM SBQQ__QuoteLine__c
            WHERE sbqq__product__c = :productId.Id
            LIMIT 1
        ];
        SBQQ__Subscription__c sub = [
            SELECT id, SBQQ__QuoteLine__r.SBQQ__Group__c, SBQQ__QuoteLine__c
            FROM SBQQ__Subscription__c
            LIMIT 1
        ];
        sub.SBQQ__QuoteLine__c = originalQuoteLine.ID;
        sub.SBQQ__QuoteLine__r = originalQuoteLine;
        update sub;

        SBQQ__QuoteLine__c amendedQuoteLine = CPQTestDataFactory.createQuoteLine(
            productId,
            amendedQuote,
            false
        );
        amendedQuoteLine.SBQQ__Quote__r = amendedQuote;
        amendedQuoteLine.SBQQ__UpgradedSubscription__r = sub;
        amendedQuoteLine.SBQQ__UpgradedSubscription__c = sub.Id;
        insert amendedQuoteLine;
        amendedQuoteLine.SBQQ__Group__c = null;
        update amendedQuoteLine;

        Set<Id> newQuoteSet = new Set<Id>{ amendedQuote.Id };
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectQuoteLineswithMissingGroups(newQuoteSet);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
        System.assertEquals(
            quoteLines[0].Id,
            amendedQuoteLine.Id,
            'The Quote Line Items are not similar'
        );
    }

    /**
     * @description This test method is used to test that quotelines are returened when quote ids are passed
     */
    @isTest
    private static void testWhenQuoteIdsArePassedThenQuoteLinesAreReturned() {
        Product2 productId = [SELECT id FROM Product2 WHERE family = :'Advertisement' LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [
            SELECT id, SBQQ__Group__c, SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE sbqq__product__c = :productId.Id
            LIMIT 1
        ];
        Set<Id> newQuoteSet = new Set<Id>{ quoteLine.SBQQ__Quote__c };
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectQuoteLinesFromQuoteIds(newQuoteSet);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
        System.assertEquals(
            quoteLines[0].SBQQ__Group__c,
            quoteLine.SBQQ__Group__c,
            'The Quote Line Items are not similar'
        );
    }

    /**
     * @description This is test method to test when Amendment Quote Ids are passed then return Quote Lines .
     */
    @isTest
    private static void testWhenQuoteIdsPassedThenReturnMarketplaceAlcoholDeliveryQuoteLines() {
        Test.startTest();
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10017';
        insert product1;
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.ProductCode = '10061';
        insert product2;
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 55,
            SBQQ__ConfiguredSKU__c = product1.Id,
            SBQQ__OptionalSKU__c = product2.Id
        );
        insert productOption;
        SBQQ__Subscription__c sub = [SELECT id FROM SBQQ__Subscription__c LIMIT 1];
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, true);
        SBQQ__Quote__c amendedQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        amendedQuote.SBQQ__Type__c = AMENDMENT;
        insert amendedQuote;
        SBQQ__QuoteLine__c amendedQuoteLine = CPQTestDataFactory.createQuoteLine(
            product2,
            amendedQuote,
            false
        );
        amendedQuoteLine.SBQQ__UpgradedSubscription__c = sub.Id;
        amendedQuoteLine.SBQQ__Group__c = null;
        amendedQuoteLine.SBQQ__Quantity__c = 0;
        amendedQuoteLine.SBQQ__ProductOption__c = productOption.Id;
        insert amendedQuoteLine;
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectMarketplaceAlcoholDeliveryQuoteLinesFromQuoteIds(new Set<Id>{ amendedQuote.Id });

        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
        System.assertEquals(
            quoteLines[0].Id,
            amendedQuoteLine.Id,
            'The Quote Line Items are not similar'
        );
        Test.stopTest();
    }

    /**
     * @description test when quote line map is returned when passed a set of quoteline Ids
     */
    @isTest
    private static void testWhenQuoteLinesAreSelectedByIdsThenValidate() {
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Set<Id> quoteIds = new Set<Id>{ quoteLineId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(
                Id = quoteLineId,
                Brief_Item__c = briefItemId,
                SBQQ__Quote__c = quoteId,
                Campaign_Name__c = 'test'
            )
        };
        Map<Id, SBQQ__QuoteLine__C> quoteLineIdMap = new Map<Id, SBQQ__QuoteLine__c>();
        quoteLineIdMap.put(quoteLineId, quoteLineList[0]);

        QuoteLineItemsSelector quoteLineSelectorMock = (QuoteLineItemsSelector) mocks.mock(
            QuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(quoteLineSelectorMock.getSObjectType()).thenReturn(SBQQ__QuoteLine__c.class);
        mocks.when(quoteLineSelectorMock.getSObjectFieldList())
            .thenReturn(
                new List<Schema.SObjectField>{
                    SBQQ__QuoteLine__c.Id,
                    SBQQ__QuoteLine__c.Name,
                    SBQQ__QuoteLine__c.Campaign_Name__c,
                    SBQQ__QuoteLine__c.SBQQ__Quote__c
                }
            );
        mocks.when(quoteLineSelectorMock.selectQuoteLinesFromIdsWithBriefItems(quoteIds))
            .thenReturn(quoteLineIdMap);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quoteLineSelectorMock);

        Map<Id, SBQQ__QuoteLine__c> quoteLinesReturned = quoteLineSelectorMock.selectQuoteLinesFromIdsWithBriefItems(
            quoteIds
        );
        System.assertEquals(
            true,
            quoteLinesReturned.containsKey(quoteLineId),
            'Quote Lines Lists do not match'
        );
    }

    /**
     * @description tests selecting quote lines with upgraded subscriptions
     */
    @isTest
    public static void testWhenQuoteIdsArePassedThenAmendedQuoteLinesAreReturned() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id originalQuoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id upgradedSubId = Fake.generateId(SBQQ__Subscription__c.class);
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Set<Id> quoteIdSet = new Set<Id>{ quoteId };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SBQQ__QuoteLine__c originalQuoteLine = new SBQQ__QuoteLine__c(
            Id = originalQuoteLineId,
            Brief_Item__c = briefItemId
        );
        SBQQ__Subscription__c testSubscription = new SBQQ__Subscription__c(
            Id = upgradedSubId,
            SBQQ__OriginalQuoteLine__c = originalQuoteLine.Id
        );

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            Id = quoteLineId,
            Brief_Item__c = briefItemId,
            SBQQ__UpgradedSubscription__c = testSubscription.Id
        );
        Map<Id, SBQQ__QuoteLine__c> testQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>{
            quoteLine.Id => quoteLine
        };
        QuoteLineItemsSelector quoteLineSelectorMock = (QuoteLineItemsSelector) mocks.mock(
            QuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(quoteLineSelectorMock.getSObjectType()).thenReturn(SBQQ__QuoteLine__c.class);
        mocks.when(quoteLineSelectorMock.selectQuoteLinesWithUpgradedSubscriptions(quoteIdSet))
            .thenReturn(testQuoteLineMap);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quoteLineSelectorMock);
        Map<Id, SBQQ__QuoteLine__c> returnedMap = quoteLineSelectorMock.selectQuoteLinesWithUpgradedSubscriptions(
            quoteIdSet
        );
        System.assertEquals(testQuoteLineMap, returnedMap, 'Returned quoteline map does not match');
        Boolean wrongProdFamilyFound = false;
        for (SBQQ__QuoteLine__c qLine : returnedMap.values()) {
            if (
                qLine.SBQQ__ProductFamily__c != 'Marketplace Promotion' &&
                qLine.SBQQ__ProductFamily__c != 'Advertisement' &&
                qLine.SBQQ__ProductFamily__c != null
            ) {
                wrongProdFamilyFound = true;
            }
        }
        System.assertEquals(
            false,
            wrongProdFamilyFound,
            'Non-A&P Products are getting returned from the quoteline selector'
        );
    }
    @isTest
    private static void testWhenSelectByIdThenReturnQuoteLines() {
        Set<Id> quoteLineIds = new Set<Id>{ [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1].Id };
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector().selectById(quoteLineIds);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
    }

    @isTest
    private static void testWhenSelectByQuoteIdThenReturnQuoteLinesWithActivePrices() {
        Set<Id> quoteIds = new Set<Id>{ [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id };
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectActivePriceFieldsByQuotes(quoteIds);
        System.assertEquals(
            quoteLines.size(),
            1,
            'The Quote Line Items were not retrieved appropriately.'
        );
    }

    /**
     * @description It is used to test whether or not an error message is thrown when a quote has blank
     * or non-positive 'Number of stores' with Quote line of Family 'Advertisement'.
     */
    @isTest
    private static void testWhenQuoteNoofstoresInvalidWithAdsMPPRQuoteLineThenErrorThrown() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1][0];
        quote.Number_of_Stores__c = 0;
        Set<Id> quoteIds = new Set<Id>{ quote.Id };
        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Family = 'Marketplace Promotion';
        insert product;
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = QuoteLineItemsSelector.newInstance()
            .selectAdsMarketplacePromotionQuotesWithInvalidStores(quoteIds);
        Test.stopTest();
        System.assertEquals(quoteLines.size(), 1, 'The Quote Line Items incorrectly retrieved.');
    }

    /**
     * @description It is used to test if Delivery option under SOF/LOF has delivery type as Distance Based
     *  then return lines.
     */
    @isTest
    private static void testWhenQuoteIdsPassedThenReturnNewDriveDeliveryQuoteLinesWithDeliveryTypeAsDistance() {
        Test.startTest();
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10044';
        product1.Name = 'Large Order Fulfillment (LOF)';
        insert product1;
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.ProductCode = '10033';
        product2.Name = 'Delivery';
        insert product2;
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__Number__c = 10,
            SBQQ__ConfiguredSKU__c = product1.Id,
            SBQQ__OptionalSKU__c = product2.Id
        );
        insert productOption;
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, true);
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        newQuote.SBQQ__Type__c = AMENDMENT;
        insert newQuote;
        SBQQ__QuoteLine__c newQuoteLine1 = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        insert newQuoteLine1;
        SBQQ__QuoteLine__c newQuoteLine = CPQTestDataFactory.createQuoteLine(
            product2,
            newQuote,
            false
        );
        newQuoteLine.SBQQ__ProductOption__c = productOption.Id;

        newQuoteLine.Segment__c = SEGMENT_SMB;
        newQuoteLine.Delivery_Type__c = DISTANCE_BASED;
        newQuoteLine.SBQQ__Existing__c = false;
        insert newQuoteLine;
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectNewDriveDeliveryProductswithDeliveyTypeAsDistanceBased(
                new Set<Id>{ newQuote.Id }
            );
        System.assertEquals(quoteLines.size(), 1, 'The Quote Line Items were not retrieved.');
        Test.stopTest();
    }

    /**
     * @description It is used to test if whether A&P are returned or not for SMB Segment
     */
    @isTest
    private static void testWhenQuoteIdsPassedThenReturnSponsoredListings() {
        Test.startTest();
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        testAccountRec.Segment__c = SEGMENT_SMB;
        testAccountRec.Deck_Rank__c = 'Joker';
        update testAccountRec;
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10042';
        product1.Name = 'Sponsored Listings';
        product1.Family = 'Advertisement';
        insert product1;
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        newQuote.SBQQ__Type__c = QUOTE;

        insert newQuote;
        SBQQ__QuoteLine__c newQuoteLine = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        newQuoteLine.Segment__c = SEGMENT_SMB;
        newQuoteLine.SBQQ__Existing__c = false;
        newQuoteLine.Bid__c = null;
        newQuoteLine.Auto_Bidding__c = false;
        newQuoteLine.Flat_Discount_Amount_for_Consumer__c = null;
        newQuoteLine.Discount_Percentage_for_Consumer__c = null;
        newQuoteLine.SBQQ__Product__c = product1.Id;
        insert newQuoteLine;
        List<SBQQ__QuoteLine__c> quoteLines = new QuoteLineItemsSelector()
            .selectAdsAndPromosProductsForValidation(new Set<Id>{ newQuote.Id });
        System.assertEquals(quoteLines.size(), 1, 'The Quote Line Items were not retrieved.');
        Test.stopTest();
    }
    /**
     * @description It is used to test if the quote lines are retrieved
     * where the trial period is blank and created by process automation user.
     */
    @isTest
    private static void testWhenUniqueIdentifiersPassedThenReturnQuotelinesTrialPeriodisBlank() {
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User processAutomationUser = new User(
            Alias = 'pauto',
            Email = 'biz-apps-integrations+ddmx@testorg.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Process',
            LastName = 'Automation User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = systemAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'processautomation.user@dd.com'
        );

        testAccountRec.Segment__c = SEGMENT_SMB;
        testAccountRec.Deck_Rank__c = 'Joker';
        update testAccountRec;
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10042';
        product1.Name = 'Sponsored Listings';
        product1.Family = 'Advertisement';
        insert product1;
        SBQQ__ProductOption__c productOption = CPQTestDataFactory.createProductOption(
            product1,
            product1,
            true
        );
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        testOppRec.Source__c = 'SSMO';
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        newQuote.SBQQ__Type__c = QUOTE;
        insert newQuote;
        SBQQ__QuoteLine__c newQuoteLine = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        newQuoteLine.Segment__c = SEGMENT_SMB;
        newQuoteLine.SBQQ__Existing__c = false;
        newQuoteLine.Bid__c = null;
        newQuoteLine.Auto_Bidding__c = false;
        newQuoteLine.Flat_Discount_Amount_for_Consumer__c = null;
        newQuoteLine.Discount_Percentage_for_Consumer__c = null;
        newQuoteLine.SBQQ__Product__c = product1.Id;
        newQuoteLine.Unique_Identifier__c = UNIQUE_IDENTIFIER;
        newQuoteLine.SBQQ__ProductOption__c = productOption.Id;
        System.runAs(processAutomationUser) {
            insert newQuoteLine;
        }
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineItems = new QuoteLineItemsSelector()
            .selectSelfServeQuoteLineItemsWithBlankTrialPeriodByUUIDs(
                new Set<String>{ UNIQUE_IDENTIFIER }
            );
        Test.stopTest();
        System.assertEquals(1, quoteLineItems.size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test if no quote lines are retrieved
     * where the trial period is not blank and created by process automation user.
     */
    @isTest
    private static void testWhenUniqueIdentifiersPassedThenReturnNoQuotelines() {
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User processAutomationUser = new User(
            Alias = 'pauto',
            Email = 'biz-apps-integrations+ddmx@testorg.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Process',
            LastName = 'Automation User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = systemAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'processautomation.user@dd.com'
        );

        testAccountRec.Segment__c = SEGMENT_SMB;
        testAccountRec.Deck_Rank__c = 'Joker';
        update testAccountRec;
        Product2 product1 = CPQTestDataFactory.createProduct(false);
        product1.ProductCode = '10042';
        product1.Name = 'Sponsored Listings';
        product1.Family = 'Advertisement';
        insert product1;
        SBQQ__ProductOption__c productOption = CPQTestDataFactory.createProductOption(
            product1,
            product1,
            true
        );
        Opportunity testOppRec = CPQTestDataFactory.createOpportunity(testAccountRec.Id, false);
        testOppRec.Estimated_Number_of_Stores__c = 1;
        testOppRec.Source__c = 'SSMO';
        insert testOppRec;
        SBQQ__Quote__c newQuote = CPQTestDataFactory.createQuote(
            testOppRec,
            testAccountRec,
            null,
            false
        );
        newQuote.SBQQ__Type__c = QUOTE;
        insert newQuote;
        SBQQ__QuoteLine__c newQuoteLine = CPQTestDataFactory.createQuoteLine(
            product1,
            newQuote,
            false
        );
        newQuoteLine.Segment__c = SEGMENT_SMB;
        newQuoteLine.SBQQ__Existing__c = false;
        newQuoteLine.Bid__c = null;
        newQuoteLine.Auto_Bidding__c = false;
        newQuoteLine.Flat_Discount_Amount_for_Consumer__c = null;
        newQuoteLine.Discount_Percentage_for_Consumer__c = null;
        newQuoteLine.Trial_Period__c = '14';
        newQuoteLine.SBQQ__Product__c = product1.Id;
        newQuoteLine.Unique_Identifier__c = UNIQUE_IDENTIFIER;
        newQuoteLine.SBQQ__ProductOption__c = productOption.Id;
        System.runAs(processAutomationUser) {
            insert newQuoteLine;
        }
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineItems = new QuoteLineItemsSelector()
            .selectSelfServeQuoteLineItemsWithBlankTrialPeriodByUUIDs(
                new Set<String>{ UNIQUE_IDENTIFIER }
            );
        Test.stopTest();
        System.assertEquals(0, quoteLineItems.size(), INVALID_ASSERT_MESSAGE);
    }
}