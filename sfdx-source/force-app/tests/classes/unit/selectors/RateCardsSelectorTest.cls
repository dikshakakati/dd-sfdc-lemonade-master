/**
 * @author DoorDash
 * @date 08/28/2023
 * @description Test class for RateCardsSelector class.
 */
@isTest
private class RateCardsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Rate Card Tier.';
    private static final String ASSERT_MESSAGE_NOT_RETRIEVED = 'Unexpected result: The Rate Cards were not retrieved appropriately.';
    private static final String RATE_CARD_FEETYPE_TIEREDPRICING = 'Tiered Pricing';
    private static final String RATE_CARD_STATE_ALABAMA_AL = 'Alabama - AL';
    
    @testSetup
    static void setupData() {
        Product2 product = CPQTestDataFactory.createProduct(true);

        Account testAccount = TestDataFactory.createAccount(true);
        CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        
        Rate_Card__c rateCard = new Rate_Card__c(
            State__c = RATE_CARD_STATE_ALABAMA_AL,
            Fee_Type__c = RATE_CARD_FEETYPE_TIEREDPRICING,
            Quote_Line__c = quoteLine.Id
        );
        insert rateCard;
        
        Rate_Card_Tier__c rateCardTier = new Rate_Card_Tier__c(
            Rate_Card__c = rateCard.Id,
            Lower_Bound__c = 0.00,
            Upper_Bound__c = 9.99,
            Fee_Value__c = 2
        );
        insert rateCardTier;
    }
    
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        RateCardsSelector rateCardsSelectorInstance = new RateCardsSelector();

        Schema.SObjectType typeOfObj = rateCardsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = rateCardsSelectorInstance.getSObjectFieldList();

        RateCardsSelector.newInstance();

        System.assertEquals(
            Schema.Rate_Card__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Rate_Card__c.Id,
                Rate_Card__c.State__c,
                Rate_Card__c.Fee_Type__c,
                Rate_Card__c.Requested_Fee__c,
                Rate_Card__c.Quote_Line__c
            },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
    
    /**
     * @description To test query on Rate Card for getting Rate Card details
     * based on Quote Line.
     */
    @isTest
    private static void testWhenSelectRateCardsByQuoteLinesThenReturnAttributes() {
        Test.startTest();
        Set<Id> quoteLineIds = new Set<Id>{ [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1].Id };
        List<Rate_Card__c> rateCards = new RateCardsSelector()
            .selectByQuoteLineIds(quoteLineIds);
        System.assertEquals(
            rateCards.size(),
            1,
            ASSERT_MESSAGE_NOT_RETRIEVED
        );
        Test.stopTest();
    }
}