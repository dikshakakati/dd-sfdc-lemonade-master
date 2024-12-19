/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for InstantIngestionQuoteAndQLIService.
 */
public interface IInstantIngestionQuoteAndQLIService {
    /**
     * @description It is used to create Quote by the received parent details.
     * @param payload
     * @param opportunity
     * @param businessAccount
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    SBQQ__Quote__c createQuote(
        InstantIngestionPayloadParser payload,
        Opportunity opportunity,
        Account businessAccount,
        Id standardPricebookId,
        String source
    );

    /**
     * @description It is used to create Quote by the received parent details for Mx Portal Ads and Promos event.
     * @param mxPortalPayload
     * @param opportunity
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    SBQQ__Quote__c createAdsAndPromosQuoteForMxPortal(
        MxPortalPayloadParser mxPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    );

    /**
     * @description It is used to create QuoteLine Group by the received parent details.
     * @param opportunity
     * @param quote
     * @return SBQQ__QuoteLineGroup__c
     */
    SBQQ__QuoteLineGroup__c createQuoteLineGroup(Opportunity opportunity, SBQQ__Quote__c quote);

    /**
     * @description It is used to create parent and standalone quote lines by the received details
     * from payload.
     * @param payload
     * @param quote
     * @param pricebook
     * @param quoteLineGroupId
     * @param source
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    );

    /**
     * @description It is used to create parent and standalone quote lines by the received details
     * from mx portal payload.
     * @param payload
     * @param quote
     * @param pricebook
     * @param quoteLineGroupId
     * @param source
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForMxPortalPayload(
        MxPortalPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    );

    /**
     * @description It is used to create child quote lines by the received details
     * from payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    );

    /**
     * @description It is used to create child quote lines by the received details
     * from mx portal payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForMxPortalPayload(
        MxPortalPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    );

    /**
     * @description It is used to create quotes by the received payload for SSOB.
     * @param ssobPortalPayload
     * @param opportunity
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    SBQQ__Quote__c createSSOBQuotes(
        SSOBOnboardingPayloadParser ssobPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    );

    /**
     * @description It is used to create the discount tiers by the received details
     * from ssob payload.
     * @param ssobPayload
     * @return List<SBQQ__DiscountTier__c>
     */
    List<SBQQ__DiscountTier__c> createDiscountTiers(SSOBOnboardingPayloadParser ssobPayload);

    /**
     * @description It is used to create parent and standalone quote lines by the received details
     * from ssob payload.
     * @param payload
     * @param quote
     * @param pricebook
     * @param quoteLineGroupId
     * @param source
     * @return List<SBQQ__QuoteLine__c>
     */
    List<SBQQ__Quoteline__c> createBundleAndStandaloneQuoteLinesForSSOBPayload(
        SSOBOnboardingPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    );

    /**
     * @description It is used to create child quote lines by the received details
     * from ssob payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param discountTiersByUUID
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForSsobPayload(
        SSOBOnboardingPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    );

    /**
     * @description It is used to update the quote status to Contract Signed.
     * @param recordIdsByPayload
     */
    void updateInstantIngestionQuotesToOrdered(Set<Id> recordIdsByPayload);

    /**
     * @description It is used to update the quote to Primary.
     * @param recordIdsByPayload
     */
    void updateInstantIngestionQuotesToPrimaryAndContractSigned(Set<Id> recordIdsByPayload);

    /**
     * @description It is used to update quote fields.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     * @param mxPortalEventType
     */
    void updateQuoteFieldsMappingOnAmendmentQuote(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        String mxPortalEventType
    );

    /**
     * @description It is used to update the quote's flag 'Send Slack Notification To Owner'
     * to invoke slack notifications via flow.
     * @param recordIdsByPayload
     */
    void updateInstantIngestionQuotesForSlackNotifications(Set<Id> recordIdsByPayload);
}