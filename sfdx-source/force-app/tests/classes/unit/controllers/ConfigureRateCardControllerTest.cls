/**
 * @author DoorDash
 * @date 08/28/2023
 * @description Test class for ConfigureRateCardController class.
 */
@isTest(SeeAllData=false)
private class ConfigureRateCardControllerTest {
    private static final String ALCOHOLDELIVERY_PRODUCT_CODE = '10061';
    private static final String ASSERT_MESSAGE_NOT_RETRIEVED = 'Unexpected result: Records were not retrieved appropriately.';
    private static final String ASSERT_MESSAGE_ENTERED_INTO_EXCEPTION = 'Unexpected result: This should be entered into Exception.';
    private static final String MARKETPLACE_PRODUCT_CODE = '10017';
    private static final String QUOTE_TYPE_AMENDMENT = 'Amendment';
    private static final String RATE_CARD_FEETYPE_FLATFEE = 'Flat Fee';
    private static final String RATE_CARD_FEETYPE_TIEREDPRICING = 'Tiered Pricing';
    private static final String RATE_CARD_STATE_ALABAMA_AL = 'Alabama - AL';
    private static final String RATE_CARD_STATE_ALASKA_AK = 'Alaska - AK';

    /**
     * @description To test getting the Standard Rate Card Tiers.
     */
    @isTest
    private static void testWhenComponentLoadedThenGetStandardRateCardTiers() {
        Standard_Rate_Card_Tier__mdt standardRateCardTierData1 = (Standard_Rate_Card_Tier__mdt) new Fake(
                Standard_Rate_Card_Tier__mdt.class
            )
            .setField(Standard_Rate_Card_Tier__mdt.Lower_Bound__c, 0.00)
            .setField(Standard_Rate_Card_Tier__mdt.Upper_Bound__c, 9.99)
            .setField(Standard_Rate_Card_Tier__mdt.Fee_Value__c, 1.50)
            .setField(Standard_Rate_Card_Tier__mdt.MasterLabel, 'Rate Card Tier 1')
            .setField(Standard_Rate_Card_Tier__mdt.DeveloperName, 'Rate_Card_Tier_1')
            .setFakeId()
            .toSObject();
        Standard_Rate_Card_Tier__mdt standardRateCardTierData2 = (Standard_Rate_Card_Tier__mdt) new Fake(
                Standard_Rate_Card_Tier__mdt.class
            )
            .setField(Standard_Rate_Card_Tier__mdt.Lower_Bound__c, 10.00)
            .setField(Standard_Rate_Card_Tier__mdt.Upper_Bound__c, 19.99)
            .setField(Standard_Rate_Card_Tier__mdt.Fee_Value__c, 2.50)
            .setField(Standard_Rate_Card_Tier__mdt.MasterLabel, 'Rate Card Tier 2')
            .setField(Standard_Rate_Card_Tier__mdt.DeveloperName, 'Rate_Card_Tier_2')
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStandardRateCardTiersSelector standardRateCardsTiersSelectorMock = (IStandardRateCardTiersSelector) mocks.mock(
            IStandardRateCardTiersSelector.class
        );
        mocks.startStubbing();
        mocks.when(standardRateCardsTiersSelectorMock.sObjectType())
            .thenReturn(Standard_Rate_Card_Tier__mdt.SObjectType);
        mocks.when(standardRateCardsTiersSelectorMock.getAllValues())
            .thenReturn(
                new List<Standard_Rate_Card_Tier__mdt>{
                    standardRateCardTierData1,
                    standardRateCardTierData2
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(standardRateCardsTiersSelectorMock);
        Test.startTest();
        List<Standard_Rate_Card_Tier__mdt> standardRateCardsTiers = ConfigureRateCardController.getStandardRateCardTiers();
        System.assertEquals(2, standardRateCardsTiers.Size(), ASSERT_MESSAGE_NOT_RETRIEVED);
        Test.stopTest();
    }

    /**
     * @description To test getting the Rate Card and Rate Card Tiers associated to Quote Line.
     */
    @isTest
    private static void testWhenQuoteLineIdThenGetRateCardsForQuoteLine() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id quoteGroupId = fflib_IDGenerator.generate(SBQQ__QuoteLineGroup__c.SObjectType);
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id quoteLineId2 = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, Fake.generateId(SBQQ__Subscription__c.class))
            .setfield(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineId)
            .toSObject();
        Rate_Card__c rateCardData1 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALABAMA_AL)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_FLATFEE)
            .setField(Rate_Card__c.Requested_Fee__c, 1.50)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .toSObject();
        Rate_Card__c rateCardData2 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALASKA_AK)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_TIEREDPRICING)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .setChildren(
                'Rate_Card_Tiers__r',
                new List<Fake>{
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 0.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 9.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 2),
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 10.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 29.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 4)
                }
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRateCardsSelector rateCardsSelectorMock = (IRateCardsSelector) mocks.mock(
            IRateCardsSelector.class
        );
        ISubscriptionSelector subcriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(rateCardsSelectorMock.sObjectType()).thenReturn(Rate_Card__c.SObjectType);
        mocks.when(rateCardsSelectorMock.selectByQuoteLineIds(new Set<Id>{ quoteLineId }))
            .thenReturn(new List<Rate_Card__c>{ rateCardData1, rateCardData2 });
        mocks.when(subcriptionSelectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subcriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscription1.Id }))
            .thenReturn(new List<SBQQ__Subscription__c>{ subscription1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(rateCardsSelectorMock);
        Application.SELECTOR.setMock(subcriptionSelectorMock);
        Test.startTest();
        List<Rate_Card__c> rateCardList = ConfigureRateCardController.getRateCardsForQuoteLine(
            quoteLineId2,
            QUOTE_TYPE_AMENDMENT,
            subscription1.Id,
            quoteId,
            quoteGroupId
        );
        System.assertEquals(2, rateCardList.Size(), ASSERT_MESSAGE_NOT_RETRIEVED);
        Test.stopTest();
    }
    
    /**
     * @description To test getting the Rate Card and Rate Card Tiers associated to Quote Line.
     */
    @isTest
    private static void testWhenAmendmentQuoteIsDoneThenGetRateCardsForQuoteLine() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id quoteGroupId = fflib_IDGenerator.generate(SBQQ__QuoteLineGroup__c.SObjectType);
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id quoteLineId2 = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setfield(SBQQ__Quote__c.SBQQ__Type__c, QUOTE_TYPE_AMENDMENT)
            .toSObject();
        SBQQ__QuoteLineGroup__c quoteGroup = (SBQQ__QuoteLineGroup__c) new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, quoteGroupId)
            .setfield(SBQQ__QuoteLineGroup__c.SBQQ__Quote__c, quote.Id)
            .toSObject();
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, Fake.generateId(SBQQ__Subscription__c.class))
            .setfield(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineId)
            .toSObject();
        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, Fake.generateId(SBQQ__QuoteLine__c.class))
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quote__c, quote.Id)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Group__c, quoteGroup.Id)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quantity__c, 0)
            .setfield(SBQQ__QuoteLine__c.SBQQ__UpgradedSubscription__c, subscription1.Id)
            .setfield(SBQQ__QuoteLine__c.Package_Code__c, MARKETPLACE_PRODUCT_CODE)
            .setfield(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, ALCOHOLDELIVERY_PRODUCT_CODE)
            .toSObject();
        SBQQ__QuoteLine__c quoteLine2 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId2)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quote__c, quote.Id)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Group__c, quoteGroup.Id)
            .setfield(SBQQ__QuoteLine__c.SBQQ__Quantity__c, 1)
            .setfield(SBQQ__QuoteLine__c.Package_Code__c, MARKETPLACE_PRODUCT_CODE)
            .setfield(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, ALCOHOLDELIVERY_PRODUCT_CODE)
            .toSObject();
        Rate_Card__c rateCardData1 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALABAMA_AL)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_FLATFEE)
            .setField(Rate_Card__c.Requested_Fee__c, 1.50)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .toSObject();
        Rate_Card__c rateCardData2 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALASKA_AK)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_TIEREDPRICING)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .setChildren(
                'Rate_Card_Tiers__r',
                new List<Fake>{
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 0.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 9.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 2),
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 10.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 29.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 4)
                }
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector quoteLineItemsSelectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        IRateCardsSelector rateCardsSelectorMock = (IRateCardsSelector) mocks.mock(
            IRateCardsSelector.class
        );
        ISubscriptionSelector subcriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(quoteLineItemsSelectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(quoteLineItemsSelectorMock.selectMarketplaceAlcoholDeliveryQuoteLinesFromQuoteIds(new Set<Id>{ quoteId }))
            .thenReturn(new List<SBQQ__QuoteLine__c>{ quoteLine });
        mocks.when(rateCardsSelectorMock.sObjectType()).thenReturn(Rate_Card__c.SObjectType);
        mocks.when(rateCardsSelectorMock.selectByQuoteLineIds(new Set<Id>{ quoteLineId }))
            .thenReturn(new List<Rate_Card__c>{ rateCardData1, rateCardData2 });
        mocks.when(subcriptionSelectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subcriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscription1.Id }))
            .thenReturn(new List<SBQQ__Subscription__c>{ subscription1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quoteLineItemsSelectorMock);
        Application.SELECTOR.setMock(rateCardsSelectorMock);
        Application.SELECTOR.setMock(subcriptionSelectorMock);
        Test.startTest();
        List<Rate_Card__c> rateCardList = ConfigureRateCardController.getRateCardsForQuoteLine(
            quoteLine2.Id,
            QUOTE_TYPE_AMENDMENT,
            null,
            quoteId,
            quoteGroupId
        );
        System.assertEquals(2, rateCardList.Size(), ASSERT_MESSAGE_NOT_RETRIEVED);
        Test.stopTest();
    }

    /**
     * @description To test Insert, Update and Delete the Rate Card and Rate Card Tiers associated to Quote Line.
     */
    @isTest
    private static void testWhenClickedOnSaveThenUpsertRateCards() {
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Rate_Card__c rateCardData1 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALABAMA_AL)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_FLATFEE)
            .setField(Rate_Card__c.Requested_Fee__c, 1.50)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .setChildren(
                'Rate_Card_Tiers__r',
                new List<Fake>{
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 0.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 9.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 2),
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 10.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 29.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 4)
                }
            )
            .toSObject();
        Rate_Card__c rateCardData2 = (Rate_Card__c) new Fake(Rate_Card__c.class)
            .setField(Rate_Card__c.State__c, RATE_CARD_STATE_ALASKA_AK)
            .setField(Rate_Card__c.Fee_Type__c, RATE_CARD_FEETYPE_TIEREDPRICING)
            .setField(Rate_Card__c.Quote_Line__c, quoteLineId)
            .setFakeId()
            .setChildren(
                'Rate_Card_Tiers__r',
                new List<Fake>{
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 0.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 9.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 2),
                    new Fake(Rate_Card_Tier__c.class)
                        .setField(Rate_Card_Tier__c.Lower_Bound__c, 10.00)
                        .setField(Rate_Card_Tier__c.Upper_Bound__c, 29.99)
                        .setField(Rate_Card_Tier__c.Fee_Value__c, 4)
                }
            )
            .toSObject();

        List<Rate_Card__c> rateCards = new List<Rate_Card__c>{ rateCardData1, rateCardData2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IRateCardsSelector rateCardsSelectorMock = (IRateCardsSelector) mocks.mock(
            IRateCardsSelector.class
        );
        mocks.startStubbing();
        mocks.when(rateCardsSelectorMock.sObjectType()).thenReturn(Rate_Card__c.SObjectType);
        mocks.when(rateCardsSelectorMock.selectByQuoteLineIds(new Set<Id>{ quoteLineId }))
            .thenReturn(rateCards);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(rateCardsSelectorMock);
        Test.startTest();
        List<ConfigureRateCardController.RateCardsContainer> rateCardsWrapperList = new List<ConfigureRateCardController.RateCardsContainer>();
        for (Rate_Card__c rateCard : rateCards) {
            ConfigureRateCardController.RateCardsContainer rateCardWrapper = new ConfigureRateCardController.RateCardsContainer();
            rateCardWrapper.rateCard = rateCard;
            rateCardWrapper.relatedRateCardTiers = rateCard.Rate_Card_Tiers__r;
            rateCardWrapper.deleteRateCardTiers = new List<Rate_Card_Tier__c>();
            rateCardsWrapperList.add(rateCardWrapper);
        }

        try {
            ConfigureRateCardController.upsertRateCards(
                System.JSON.serialize(rateCardsWrapperList),
                new List<Rate_Card__c>(),
                quoteLineId
            );
        } catch (exception ex) {
            System.assertEquals(
                'Script-thrown exception',
                ex.getMessage(),
                ASSERT_MESSAGE_ENTERED_INTO_EXCEPTION
            );
        }
        Test.stopTest();
    }
}