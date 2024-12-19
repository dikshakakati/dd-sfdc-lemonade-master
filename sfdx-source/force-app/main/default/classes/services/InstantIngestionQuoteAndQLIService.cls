/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class for InstantIngestionQuoteAndQLIServiceImpl.
 */
public inherited sharing class InstantIngestionQuoteAndQLIService {
    /**
     * @description It is used to create Quote by the received parent details.
     * @param payload
     * @param opportunity
     * @param businessAccount
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    public static SBQQ__Quote__c createQuote(
        InstantIngestionPayloadParser payload,
        Opportunity opportunity,
        Account businessAccount,
        Id standardPricebookId,
        String source
    ) {
        return service()
            .createQuote(payload, opportunity, businessAccount, standardPricebookId, source);
    }

    /**
     * @description It is used to create Quote by the received parent details for Mx Portal Ads and Promos event.
     * @JIRA# LEM-16266
     * @param mxPortalPayload
     * @param opportunity
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    public static SBQQ__Quote__c createAdsAndPromosQuoteForMxPortal(
        MxPortalPayloadParser mxPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    ) {
        return service()
            .createAdsAndPromosQuoteForMxPortal(
                mxPortalPayload,
                opportunity,
                standardPricebookId,
                source
            );
    }

    /**
     * @description It is used to create QuoteLine Group by the received parent details.
     * @param opportunity
     * @param quote
     * @return SBQQ__QuoteLineGroup__c
     */
    public static SBQQ__QuoteLineGroup__c createQuoteLineGroup(
        Opportunity opportunity,
        SBQQ__Quote__c quote
    ) {
        return service().createQuoteLineGroup(opportunity, quote);
    }

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
    public static List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        return service()
            .createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
                payload,
                quote,
                pricebook,
                quoteLineGroupId,
                source
            );
    }

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
    public static List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForMxPortalPayload(
        MxPortalPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        return service()
            .createBundleAndStandaloneQuoteLinesForMxPortalPayload(
                payload,
                quote,
                pricebook,
                quoteLineGroupId,
                source
            );
    }

    /**
     * @description It is used to create child quote lines by the received details
     * from payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    public static List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        return service()
            .createQuoteLineOptionsByParentForInstantIngestionPayload(
                payload,
                parentQuoteLinesByName,
                quote,
                pricebook
            );
    }

    /**
     * @description It is used to create child quote lines by the received details
     * from mx portal payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    public static List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForMxPortalPayload(
        MxPortalPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        return service()
            .createQuoteLineOptionsByParentForMxPortalPayload(
                payload,
                parentQuoteLinesByName,
                quote,
                pricebook
            );
    }

    /**
     * @description It is used to update the quote status to Contract Signed.
     * @JIRA# LEM-14648
     * @param recordIdsByPayload
     */
    public static void updateInstantIngestionQuotesToOrdered(Set<Id> recordIdsByPayload) {
        service().updateInstantIngestionQuotesToOrdered(recordIdsByPayload);
    }

    /**
     * @description It is used to update the quote to Primary.
     * @param recordIdsByPayload
     */
    public static void updateInstantIngestionQuotesToPrimaryAndContractSigned(
        Set<Id> recordIdsByPayload
    ) {
        service().updateInstantIngestionQuotesToPrimaryAndContractSigned(recordIdsByPayload);
    }

    /**
     * @description It is used to update quote fields.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     * @param mxPortalEventType
     */
    public static void updateQuoteFieldsMappingOnAmendmentQuote(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        String mxPortalEventType
    ) {
        service()
            .updateQuoteFieldsMappingOnAmendmentQuote(
                quoteId,
                mxPortalPayloadWrapperByUUID,
                mxPortalEventType
            );
    }

    /**
     * @description It is used to update the quote to send slack notifications.
     * @JIRA# LEM-14648
     * @param recordIdsByPayload
     */
    public static void updateInstantIngestionQuotesForSlackNotifications(
        Set<Id> recordIdsByPayload
    ) {
        service().updateInstantIngestionQuotesForSlackNotifications(recordIdsByPayload);
    }

    /**
     * @description It is used to create quotes by the received payload for SSOB.
     * @param ssobPortalPayload
     * @param opportunity
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    public static SBQQ__Quote__c createSSOBQuotes(
        SSOBOnboardingPayloadParser ssobPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    ) {
        return service()
            .createSSOBQuotes(ssobPortalPayload, opportunity, standardPricebookId, source);
    }

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
    public static List<SBQQ__Quoteline__c> createBundleAndStandaloneQuoteLinesForSSOBPayload(
        SSOBOnboardingPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        return service()
            .createBundleAndStandaloneQuoteLinesForSSOBPayload(
                payload,
                quote,
                pricebook,
                quoteLineGroupId,
                source
            );
    }

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
    public static List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForSsobPayload(
        SSOBOnboardingPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        return service()
            .createQuoteLineOptionsByParentForSsobPayload(
                payload,
                parentQuoteLinesByName,
                discountTiersByUUID,
                quote,
                pricebook
            );
    }

    /**
     * @description It is used to create the discount tiers by the received details
     * from ssob payload.
     * @param ssobPayload
     * @return List<SBQQ__DiscountTier__c>
     */
    public static List<SBQQ__DiscountTier__c> createDiscountTiers(
        SSOBOnboardingPayloadParser ssobPayload
    ) {
        return service().createDiscountTiers(ssobPayload);
    }

    /**
     * @description It is used to create an instance of InstantIngestionQuoteAndQLIServiceImpl class.
     * @return InstantIngestionQuoteAndQLIService - return instance of InstantIngestionQuoteAndQLIServiceImpl
     */
    private static IInstantIngestionQuoteAndQLIService service() {
        return (IInstantIngestionQuoteAndQLIService) Application.Service.newInstance(
            IInstantIngestionQuoteAndQLIService.class
        );
    }
}