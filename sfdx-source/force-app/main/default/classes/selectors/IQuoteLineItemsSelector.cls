/**
 * @author Deloitte
 * @date 11/08/2022
 * @description Interface for QuoteLineItemsSelector.
 */
public interface IQuoteLineItemsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quotes.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectDrawerFieldByQuotes(Set<Id> quoteIds);

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectQuoteLineGroupFields(Set<Id> quoteLineIds);

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of AccountIds.
     * @param businessAccountIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectAlcoholDeliveryQuoteLineItemByAccounts(
        Set<Id> businessAccountIds
    );
    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectById(Set<Id> quoteLineIds);

    /**
     * @description It is used to fetch Marketplace Alcohol Delivery Quote Line Items related to the passed set of quoteIds.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectMarketplaceAlcoholDeliveryQuoteLinesFromQuoteIds(
        Set<Id> quoteIds
    );
    /**
     * @description fetch quotelines by Ids with Brief Items
     * @param quoteLineIds
     * @return Map<Id,SBQQ__QuoteLine__c>
     */
    Map<Id, SBQQ__QuoteLine__c> selectQuoteLinesFromIdsWithBriefItems(Set<Id> quoteLineIds);

    /**
     * @description select quote lines from quote ids
     * @param newQuotesSet
     * @return List<SBQQ__QuoteLine__c> - returns list of quote lines
     */
    List<SBQQ__QuoteLine__c> selectQuoteLineItemsFromQuoteIds(Set<Id> newQuotesSet);
    /**
     * @description select original quote lines from original quote
     * @param quoteIds
     * @return Map<Id,SBQQ__QuoteLine__c>
     */
    Map<Id, SBQQ__QuoteLine__c> selectQuoteLinesWithUpgradedSubscriptions(Set<Id> quoteIds);

    /**
     * @description It is used to fetch Quote Line Items related to the passed set of Quote Line Ids.
     * @param newQuotesSet
     * @return List<SBQQ__QuoteLine__c> - returns list of quotelineswithMissingGroups
     */
    List<SBQQ__QuoteLine__c> selectQuoteLineswithMissingGroups(Set<Id> newQuotesSet);

    /**
     * @description It is used to fetch Quote Line Items with groups related to the passed set of quoteIds.
     * @param newQuotesSet
     * @return List<SBQQ__QuoteLine__c> - returns list of quote lines
     */
    List<SBQQ__QuoteLine__c> selectQuoteLinesFromQuoteIds(Set<Id> newQuotesSet);

    /**
     * @description It is used to fetch Quote Lines with Family Marketplace Promotion/Advertisement Family.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c> - returns list of quote lines
     */
    List<SBQQ__QuoteLine__c> selectAdsMarketplacePromotionQuotesWithInvalidStores(Set<Id> quoteIds);

    /**
     * @description It is used to select quote lines by the passed unique identifiers.
     * @JIRA LEM-14588
     * @param uniqueIdentifiers
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__QuoteLine__c> selectQuoteLinesbyUniqueIdentifiers(Set<String> uniqueIdentifiers);

    /**
     * @description It is used to fetch Quote Lines Active Price Fields related to the passed set of Quotes.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectActivePriceFieldsByQuotes(Set<Id> quoteIds);

    /**
     * @description It is used to fetch Alcohol Delivery/Delivery Quote Lines under LOF Package with
     * Fee Type as 'Commission' or 'Fee' with Min/Max delivery fee blank.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectLOFProductswithCommissionForValidation(Set<Id> quoteIds);

    /**
     * @description It is used to fetch Delivery Quote Lines under LOF/SOF Package with
     * Delivery Type as 'Distance Based (incl. tiered)'.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectNewDriveDeliveryProductswithDeliveyTypeAsDistanceBased(
        Set<Id> quoteIds
    );

    /**
     * @description It is used to fetch Marketplace Promotion/Advertisement Product Family Quote Lines with
     * Length of Term as blank.
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectLengthOfTermwithProductsForValidation(Set<Id> quoteIds);

    /**
     * @description It is used to fetch Marketplace Promotion/Advertisement Product Family Quote Lines with
     *
     * @param quoteIds
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectAdsAndPromosProductsForValidation(Set<Id> quoteIds);

    /**
     * @description It is used to fetch quotelines created via self serve payload where trial period is not blank.
     * @param uuids
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> selectSelfServeQuoteLineItemsWithBlankTrialPeriodByUUIDs(
        Set<String> uuids
    );
}