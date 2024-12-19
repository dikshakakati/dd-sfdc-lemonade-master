/**
 * @author Deloitte
 * @date 05/07/2024
 * @description Service implementation class for InstantIngestionQuoteAndQLIService.
 * Note: Added PMD suppress because of the null check added for data coming from payload.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public inherited sharing class InstantIngestionQuoteAndQLIServiceImpl implements IInstantIngestionQuoteAndQLIService {
    private static final String STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final String APPROVAL_STATUS_APPROVED = 'Approved';
    private static final String OPTION_TYPE_COMPONENT = 'Component';
    private static final String PRODUCT_SUBSCRPTION_TYPE = 'Evergreen';
    private static final String SPECIAL_PRICE_TYPE_CUSTOM = 'Custom';
    private static final String SUBSCRIPTION_BASE_LIST = 'List';
    private static final String SUBSCRIPTION_PRICING_FIXED_PRICE = 'Fixed Price';
    private static final String STORE_KEY = 'store';
    private static final String ORDER_PRODUCT = 'orderProducts';
    private static final String SUBSCRIPTION_TYPE_EVERGREEN = 'Evergreen';
    private static final String QUOTE_STATUS_DRAFT = 'Draft';
    private static final String QUOTE_DEAL_TERMS_STANDARD = 'Standard';
    private static final String QUOTE_PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String QUOTE_PAYMENT_METHOD_INVOICING = 'Invoicing';
    private static final String QUOTE_CONTRACT_GENERATION_PATH_TEMPLATIZED = 'Templatized';
    private static final String PAYMENT_TERMS_NET_30 = 'Net 30';
    private static final String QUOTE_TYPE = 'Quote';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String SOURCE_STRING = 'source';
    private static final String UUID_STRING = 'uuid';
    private Map<String, Object> orderProductValue = new Map<String, Object>();
    private Map<String, Object> jsonKeyToValue = new Map<String, Object>();
    private static final String STANDARD_STOREFRONT_PACKAGE = 'Standard Storefront Package';
    private static final String STOREFRONT_PACKAGE = 'Storefront';
    private static final String NUMBER_OF_VOLUME_TIER = 'numberOfVolumeTiers';
    private static final String VOLUME_TIER_COMMITMENT_TIER = 'volumeTierCommitmentTier';
    private static final String NAME_KEY = 'name';
    private static final String TIER_KEY = 'Tier ';
    private static final String SUCCESS_MESSAGE = ' event has been completed successfully';
    private static final String SUCESS_STATUS = 'Success';
    private static final String SELF_SERVING_ONBOARDING_SERVICE = 'selfServiceOnboardingService';
    private static final String CPQ_WS = 'CPQ';
    private static final String STORE_REWARD = 'Store Rewards (DD Loyalty)';
    private static final String QUOTELINE_PROGRAM_TYPE = 'Subtotal-based';
    private static final String QUOTELINE_REWARD_TYPE = '$ Reward';
    private static final String QUOTELINE_CAMPAIGN_NAME = 'Portal';
    private static final String SERVICE_RATE = 'Service Rate';
    private static final String SERVICE_RATE_CA = 'Service Rate - CA';
    private static final String EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED = 'EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED';
    private static final String PRODUCT_NAME_DASHPASS = 'Dashpass';

    Set<String> optionProductNames = new Set<String>();
    String campaignId = '';
    String businessId = '';
    String storeId = '';
    /**
     * @description It is used to create Quote by the received parent details.
     * @JIRA# LEM-14588
     * @param payload
     * @param opportunity
     * @param businessAccount
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    public SBQQ__Quote__c createQuote(
        InstantIngestionPayloadParser payload,
        Opportunity opportunity,
        Account businessAccount,
        Id standardPricebookId,
        String source
    ) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Signed_Contract_Link__c = payload.store.vendorContractRecord;
        quote.Account_Segment__c = payload.store.segmentType;
        quote = createQuoteFields(quote, opportunity, businessAccount, source, standardPricebookId);
        return quote;
    }

    /**
     * @description It is used to create quotes by the received payload for SSOB.
     * @param ssobPortalPayload
     * @param opportunity
     * @param standardPricebookId
     * @param source
     * @return SBQQ__Quote__c
     */
    public SBQQ__Quote__c createSSOBQuotes(
        SSOBOnboardingPayloadParser ssobPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    ) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Signed_Contract_Link__c = ssobPortalPayload.opportunity.contractDetails.vendorContractRecord;
        quote = createQuoteFields(quote, opportunity, null, source, standardPricebookId);
        return quote;
    }

    private SBQQ__Quote__c createQuoteFields(
        SBQQ__Quote__c quote,
        Opportunity opportunity,
        Account businessAccount,
        String source,
        Id standardPricebookId
    ) {
        quote.SBQQ__Type__c = QUOTE_TYPE;
        quote.Unique_Identifier__c = opportunity.Unique_Identifier__c;
        quote.SubmittedDate__c = System.today();
        if (businessAccount != null) {
            quote.CurrencyIsoCode = businessAccount.CurrencyIsoCode;
            quote.SBQQ__Account__c = businessAccount.Id;
        } else {
            quote.CurrencyIsoCode = opportunity.CurrencyIsoCode;
            quote.SBQQ__Account__c = opportunity.AccountId;
        }
        quote.SBQQ__Status__c = QUOTE_STATUS_DRAFT;
        quote.ApprovalStatus__c = APPROVAL_STATUS_APPROVED;
        quote.Deal_Terms__c = QUOTE_DEAL_TERMS_STANDARD;
        quote.Integration_Source__c = source;
        quote.Payment_Method__c = source == SOURCE_SSOB
            ? QUOTE_PAYMENT_METHOD_INVOICING
            : QUOTE_PAYMENT_METHOD_WITHHOLDING;
        quote.Contract_Generation_Path__c = QUOTE_CONTRACT_GENERATION_PATH_TEMPLATIZED;
        quote.SBQQ__PrimaryContact__c = opportunity.ContactId;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__PaymentTerms__c = PAYMENT_TERMS_NET_30;
        quote.SBQQ__PriceBook__c = standardPricebookId;
        quote.SBQQ__PricebookId__c = standardPricebookId;
        quote.SBQQ__LineItemsGrouped__c = true;
        quote.Contract_Signed_Date__c = System.today();
        return quote;
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
    public SBQQ__Quote__c createAdsAndPromosQuoteForMxPortal(
        MxPortalPayloadParser mxPortalPayload,
        Opportunity opportunity,
        Id standardPricebookId,
        String source
    ) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Signed_Contract_Link__c = mxPortalPayload.store.vendorContractRecord;
        quote = createQuoteFields(quote, opportunity, null, source, standardPricebookId);
        return quote;
    }

    /**
     * @description It is used to create QuoteLine Group by the received parent details.
     * @param opportunity
     * @param quote
     * @return SBQQ__QuoteLineGroup__c
     */
    public SBQQ__QuoteLineGroup__c createQuoteLineGroup(
        Opportunity opportunity,
        SBQQ__Quote__c quote
    ) {
        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
            Name = opportunity.Account.Name,
            SBQQ__Account__c = opportunity.AccountId,
            SBQQ__CustomerTotal__c = 0,
            SBQQ__ListTotal__c = 0,
            SBQQ__NetTotal__c = 0,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = quote.Id
        );
        return quoteLineGroup;
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
    public List<SBQQ__Quoteline__c> createBundleAndStandaloneQuoteLinesForSSOBPayload(
        SSOBOnboardingPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        Set<String> bundleHeaderAndStandaloneProductNames = new Set<String>();
        for (
            SSOBOnboardingPayloadParser.OrderProductsDetails eachOrderProductDetail : new List<SSOBOnboardingPayloadParser.OrderProductsDetails>{
                payload.opportunity.orderProducts
            }
        ) {
            bundleHeaderAndStandaloneProductNames.add(eachOrderProductDetail.name);
        }
        if (bundleHeaderAndStandaloneProductNames.isEmpty()) {
            return null;
        }
        return createBundleAndStandaloneQuoteLines(
            bundleHeaderAndStandaloneProductNames,
            quote,
            pricebook,
            quoteLineGroupId,
            new Map<String, String>{ SOURCE_STRING => source, UUID_STRING => payload.uuid }
        );
    }

    /**
     * @description It is used to create parent and standalone quote lines by the received details
     * from instant ingestion payload.
     * @param payload
     * @param quote
     * @param pricebook
     * @param quoteLineGroupId
     * @param source
     * @return List<SBQQ__QuoteLine__c>
     */
    public List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        Set<String> bundleHeaderAndStandaloneProductNames = new Set<String>();
        for (
            InstantIngestionPayloadParser.OrderProductsDetails eachOrderProductDetail : payload.store.orderProducts
        ) {
            if (eachOrderProductDetail.Name == STANDARD_STOREFRONT_PACKAGE) {
                bundleHeaderAndStandaloneProductNames.add(STOREFRONT_PACKAGE);
            } else {
                bundleHeaderAndStandaloneProductNames.add(eachOrderProductDetail.Name);
            }
        }
        if (bundleHeaderAndStandaloneProductNames.isEmpty()) {
            return null;
        }
        return createBundleAndStandaloneQuoteLines(
            bundleHeaderAndStandaloneProductNames,
            quote,
            pricebook,
            quoteLineGroupId,
            new Map<String, String>{ SOURCE_STRING => source, UUID_STRING => payload.uuid }
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
    public List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLinesForMxPortalPayload(
        MxPortalPayloadParser payload,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        String source
    ) {
        Set<String> bundleHeaderAndStandaloneProductNames = new Set<String>();
        for (
            MxPortalPayloadParser.OrderProductsDetails eachOrderProductDetail : new List<MxPortalPayloadParser.OrderProductsDetails>{
                payload.store.orderProducts
            }
        ) {
            if (eachOrderProductDetail.Name == STANDARD_STOREFRONT_PACKAGE) {
                bundleHeaderAndStandaloneProductNames.add(STOREFRONT_PACKAGE);
            } else {
                bundleHeaderAndStandaloneProductNames.add(eachOrderProductDetail.Name);
            }
        }
        if (bundleHeaderAndStandaloneProductNames.isEmpty()) {
            return null;
        }
        jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(payload));
        String storePayload = JSON.serialize(jsonKeyToValue.get(STORE_KEY));
        Map<String, Object> storeValue = (Map<String, Object>) JSON.deserializeUntyped(
            storePayload
        );
        String orderProductPayload = JSON.serialize(storeValue.get(ORDER_PRODUCT));
        orderProductValue = (Map<String, Object>) JSON.deserializeUntyped(orderProductPayload);
        campaignId = payload?.campaignId;
        storeId = payload?.store?.storeId;
        businessId = payload?.store?.businessId;
        return createBundleAndStandaloneQuoteLines(
            bundleHeaderAndStandaloneProductNames,
            quote,
            pricebook,
            quoteLineGroupId,
            new Map<String, String>{ SOURCE_STRING => source, UUID_STRING => payload.uuid }
        );
    }

    /**
     * @description It is used to create parent quote lines for instant ingestion payload.
     * @param bundleHeaderAndStandaloneProductNames
     * @param quote
     * @param pricebook
     * @param quoteLineGroupId
     * @param sourceAndUUID
     * @return List<SBQQ__QuoteLine__c>
     */
    private List<SBQQ__QuoteLine__c> createBundleAndStandaloneQuoteLines(
        Set<String> bundleHeaderAndStandaloneProductNames,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        Id quoteLineGroupId,
        Map<String, String> sourceAndUUID
    ) {
        List<SBQQ__QuoteLine__c> bundleAndStandaloneQuoteLines = new List<SBQQ__QuoteLine__c>();
        Integer counter = 0;
        String source = sourceAndUUID.get(SOURCE_STRING);
        String uuid = sourceAndUUID.get(UUID_STRING);
        for (
            PricebookEntry eachBundleOrStandaloneProduct : PricebookEntriesSelector.newInstance()
                .selectByProductNamesAndCurrency(
                    bundleHeaderAndStandaloneProductNames,
                    quote.CurrencyIsoCode
                )
        ) {
            bundleAndStandaloneQuoteLines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = quote.Id,
                    CurrencyIsoCode = quote.CurrencyIsoCode,
                    SBQQ__Product__c = eachBundleOrStandaloneProduct.Product2.Id,
                    SBQQ__PricebookEntryId__c = eachBundleOrStandaloneProduct.Id,
                    Unique_Identifier__c = uuid,
                    SBQQ__Bundle__c = true,
                    SBQQ__Description__c = eachBundleOrStandaloneProduct.Product2.Description,
                    SBQQ__ProductSubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__Quantity__c = 1,
                    SBQQ__SpecialPriceType__c = SPECIAL_PRICE_TYPE_CUSTOM,
                    Payment_Method__c = source == SOURCE_SSOB
                        ? QUOTE_PAYMENT_METHOD_INVOICING
                        : QUOTE_PAYMENT_METHOD_WITHHOLDING,
                    SBQQ__SubscriptionBase__c = SUBSCRIPTION_BASE_LIST,
                    SBQQ__SubscriptionPricing__c = SUBSCRIPTION_PRICING_FIXED_PRICE,
                    SBQQ__SubscriptionScope__c = QUOTE_TYPE,
                    SBQQ__SubscriptionTerm__c = 1,
                    SBQQ__Group__c = quoteLineGroupId,
                    SBQQ__SubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__ListPrice__c = 0,
                    SBQQ__NetPrice__c = 0,
                    SBQQ__RegularPrice__c = 0,
                    SBQQ__Number__c = ++counter, //Number field on parent quote line is used to maintain the hierarchy between the associated child quote lines.
                    Marketing_Flat_Fee__c = orderProductValue.get('marketingFee') != null
                        ? Decimal.valueOf(orderProductValue.get('marketingFee').toString())
                        : null,
                    Minimum_Spend_Per_Order__c = orderProductValue.get('orderCartMin') != null
                        ? Decimal.valueOf(orderProductValue.get('orderCartMin').toString())
                        : null,
                    Store_vs_Business_Level_Targeting__c = orderProductValue.get(
                            'storeTargeting'
                        ) != null
                        ? (String) orderProductValue.get('storeTargeting')
                        : '',
                    Marketing_Only_Commission__c = orderProductValue.get(
                            'additionalMarketingFeeRate'
                        ) != null
                        ? Decimal.valueOf(
                              orderProductValue.get('additionalMarketingFeeRate').toString()
                          )
                        : null,
                    Start_Date__c = orderProductValue.get('promoStartDate') != null
                        ? date.valueof(orderProductValue.get('promoStartDate').toString())
                        : null,
                    Budget__c = orderProductValue.get('budget') != null
                        ? Decimal.valueOf(orderProductValue.get('budget').toString())
                        : null,
                    End_Date__c = orderProductValue.get('promoEndDate') != null
                        ? date.valueof(orderProductValue.get('promoEndDate').toString())
                        : null,
                    Required_Spend_Threshold__c = orderProductValue.get('spentThreshold') != null
                        ? Decimal.valueOf(orderProductValue.get('spentThreshold').toString())
                        : null,
                    Budget_Period__c = orderProductValue.get('budgetPeriod') != null
                        ? (String) orderProductValue.get('budgetPeriod')
                        : '',
                    //= orderProductValue.get('daysOfWeek'),
                    Day_time_constraints__c = orderProductValue.get('dayTimeConstraints') != null
                        ? (String) orderProductValue.get('dayTimeConstraints')
                        : '',
                    //= orderProductValue.get('daysUntilExpiry'),
                    Dining_Spend_Minimum__c = orderProductValue.get('diningSpendMinimum') != null
                        ? Decimal.valueOf(orderProductValue.get('diningSpendMinimum').toString())
                        : null,
                    Discount_Percentage_for_Consumer__c = orderProductValue.get(
                            'discountPercentConsumer'
                        ) != null
                        ? Decimal.valueOf(
                              orderProductValue.get('discountPercentConsumer').toString()
                          )
                        : null,
                    Discounted_Delivery_Fee__c = orderProductValue.get('discountedDeliveryFee') !=
                        null
                        ? Decimal.valueOf(orderProductValue.get('discountedDeliveryFee').toString())
                        : null,
                    Flat_Discount_Amount_for_Consumer__c = orderProductValue.get(
                            'flatDiscountAmount'
                        ) != null
                        ? Decimal.valueOf(orderProductValue.get('flatDiscountAmount').toString())
                        : null,
                    Item_Discount_Percentage__c = orderProductValue.get('itemDiscountPercent') !=
                        null
                        ? Decimal.valueOf(orderProductValue.get('itemDiscountPercent').toString())
                        : null,
                    Max_Amount_from_Marketing_Percent__c = orderProductValue.get(
                            'maxMarketingPercent'
                        ) != null
                        ? Decimal.valueOf(orderProductValue.get('maxMarketingPercent').toString())
                        : null,
                    Max_Discount_Amount_for_Consumer__c = orderProductValue.get(
                            'maxDiscountConsumer'
                        ) != null
                        ? Decimal.valueOf(orderProductValue.get('maxDiscountConsumer').toString())
                        : null,
                    Max_Number_of_Redemptions__c = orderProductValue.get(
                            'maxNumberOfRedemptions'
                        ) != null
                        ? Decimal.valueOf(
                              orderProductValue.get('maxNumberOfRedemptions').toString()
                          )
                        : null,
                    Menu_Item_IDs_Option_IDs_List_A__c = orderProductValue.get(
                            'menuItemIDsOptionIDsItemsInListA'
                        ) != null
                        ? (String) orderProductValue.get('menuItemIDsOptionIDsItemsInListA')
                        : '',
                    Menu_Item_IDs_Option_IDs_List_B__c = orderProductValue.get(
                            'menuItemIDsOptionIDsItemsInListB'
                        ) != null
                        ? (String) orderProductValue.get('menuItemIDsOptionIDsItemsInListB')
                        : '',
                    Menu_Item_Name_Item_ID_Option_ID__c = orderProductValue.get(
                            'menuItemNameItemIDOptionID'
                        ) != null
                        ? (String) orderProductValue.get('menuItemNameItemIDOptionID')
                        : '',
                    Menu_Item_Minimum_Quantity__c = orderProductValue.get(
                            'menuItemMinimumQuantity'
                        ) != null
                        ? Decimal.valueOf(
                              orderProductValue.get('menuItemMinimumQuantity').toString()
                          )
                        : null,
                    Offer_detailed_description__c = orderProductValue.get(
                            'offerDetailedDescription'
                        ) != null
                        ? (String) orderProductValue.get('offerDetailedDescription')
                        : '',
                    Offer_title__c = orderProductValue.get('offerTitle') != null
                        ? (String) orderProductValue.get('offerTitle')
                        : '',
                    Order_Service_Type__c = orderProductValue.get('orderServiceType') != null
                        ? (String) orderProductValue.get('orderServiceType')
                        : '',
                    Promotion_Code__c = orderProductValue.get('promotionCode') != null
                        ? (String) orderProductValue.get('promotionCode')
                        : '',
                    Target_Cx_Audience__c = orderProductValue.get('targetAudience') != null
                        ? (String) orderProductValue.get('targetAudience')
                        : '',
                    Day_Time_of_Week__c = orderProductValue.get('timeOfDay') != null
                        ? (String) orderProductValue.get('timeOfDay')
                        : '',
                    Program_Type__c = ((String) orderProductValue.get('name')) == STORE_REWARD
                        ? QUOTELINE_PROGRAM_TYPE
                        : '',
                    Reward_Type__c = ((String) orderProductValue.get('name')) == STORE_REWARD
                        ? QUOTELINE_REWARD_TYPE
                        : '',
                    Campaign_Name__c = ((String) orderProductValue.get('name')) == STORE_REWARD
                        ? QUOTELINE_CAMPAIGN_NAME
                        : '',
                    Reward__c = orderProductValue.get('flatDiscountAmount') != null
                        ? Decimal.valueOf(orderProductValue.get('flatDiscountAmount').toString())
                        : null,
                    Campaign_Id__c = campaignId,
                    Store_Id__c = storeId,
                    Business_Id__c = businessId
                )
            );
        }
        return bundleAndStandaloneQuoteLines;
    }

    /**
     * @description It is used to create child quote lines by the received details
     * from instant ingestion payload.
     * @param payload
     * @param parentQuoteLinesByName
     * @param quote
     * @param pricebook
     * @return List<SBQQ__QuoteLine__c
     */
    public List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForInstantIngestionPayload(
        InstantIngestionPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        Map<String, InstantIngestionPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForInstantIngestion = new Map<String, InstantIngestionPayloadParser.ProductOptionsDetails>();
        for (
            InstantIngestionPayloadParser.OrderProductsDetails eachOrderProductDetail : payload.store.orderProducts
        ) {
            for (
                InstantIngestionPayloadParser.ProductOptionsDetails eachProductOption : eachOrderProductDetail.productOptions
            ) {
                if (
                    isEligibleToSkipQuoteLineCreation(
                        eachProductOption.name,
                        eachProductOption.commission,
                        eachProductOption.fee
                    )
                ) {
                    continue;
                }
                if (eachOrderProductDetail.name == STANDARD_STOREFRONT_PACKAGE) {
                    optionProductNameWithParentProductNameForInstantIngestion.put(
                        STOREFRONT_PACKAGE + eachProductOption.name,
                        eachProductOption
                    );
                } else {
                    optionProductNameWithParentProductNameForInstantIngestion.put(
                        eachOrderProductDetail.name + eachProductOption.name,
                        eachProductOption
                    );
                }
                if (eachProductOption.name == SERVICE_RATE) {
                    optionProductNames.add(SERVICE_RATE_CA);
                }
                optionProductNames.add(eachProductOption.name);
            }
        }
        return instantIngestionCreateQuoteLineOptionsByParent(
            optionProductNameWithParentProductNameForInstantIngestion,
            parentQuoteLinesByName,
            quote,
            pricebook,
            payload.uuid
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
    public List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForSsobPayload(
        SSOBOnboardingPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForSsob = new Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails>();
        for (
            SSOBOnboardingPayloadParser.OrderProductsDetails eachOrderProductDetail : new List<SSOBOnboardingPayloadParser.OrderProductsDetails>{
                payload.opportunity.orderProducts
            }
        ) {
            for (
                SSOBOnboardingPayloadParser.ProductOptionsDetails eachProductOption : eachOrderProductDetail.productOptions
            ) {
                optionProductNameWithParentProductNameForSsob.put(
                    eachOrderProductDetail.name + eachProductOption.name,
                    eachProductOption
                );
                optionProductNames.add(eachProductOption.name);
            }
        }
        return ssobCreateQuoteLineOptionsByParent(
            optionProductNameWithParentProductNameForSsob,
            parentQuoteLinesByName,
            discountTiersByUUID,
            quote,
            pricebook,
            payload.uuid
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
    public List<SBQQ__QuoteLine__c> createQuoteLineOptionsByParentForMxPortalPayload(
        MxPortalPayloadParser payload,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook
    ) {
        Map<String, MxPortalPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForMxPortal = new Map<String, MxPortalPayloadParser.ProductOptionsDetails>();
        for (
            MxPortalPayloadParser.OrderProductsDetails eachOrderProductDetail : new List<MxPortalPayloadParser.OrderProductsDetails>{
                payload.store.orderProducts
            }
        ) {
            for (
                MxPortalPayloadParser.ProductOptionsDetails eachProductOption : eachOrderProductDetail.productOptions
            ) {
                if (
                    isEligibleToSkipQuoteLineCreation(
                        eachProductOption.name,
                        eachProductOption.commission,
                        eachProductOption.fee
                    )
                ) {
                    continue;
                }
                if (eachOrderProductDetail.name == STANDARD_STOREFRONT_PACKAGE) {
                    optionProductNameWithParentProductNameForMxPortal.put(
                        STOREFRONT_PACKAGE + eachProductOption.name,
                        eachProductOption
                    );
                } else {
                    optionProductNameWithParentProductNameForMxPortal.put(
                        eachOrderProductDetail.name + eachProductOption.name,
                        eachProductOption
                    );
                }
                if (eachProductOption.name == SERVICE_RATE) {
                    optionProductNames.add(SERVICE_RATE_CA);
                }
                optionProductNames.add(eachProductOption.name);
            }
        }
        if (optionProductNames.isEmpty()) {
            return null;
        }
        return mxPortalCreateQuoteLineOptionsByParent(
            optionProductNameWithParentProductNameForMxPortal,
            parentQuoteLinesByName,
            quote,
            pricebook,
            payload.uuid
        );
    }

    //to create child quote lines for instant ingestion
    private List<SBQQ__QuoteLine__c> instantIngestionCreateQuoteLineOptionsByParent(
        Map<String, InstantIngestionPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForInstantIngestion,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        String uuid
    ) {
        List<SBQQ__QuoteLine__c> optionQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, Id> pricebookEntryIdByProductName = new Map<String, Id>();
        for (
            PricebookEntry eachPriceboookEntry : PricebookEntriesSelector.newInstance()
                .selectByProductNamesAndCurrency(optionProductNames, quote.CurrencyIsoCode)
        ) {
            pricebookEntryIdByProductName.put(
                eachPriceboookEntry.Product2.Name,
                eachPriceboookEntry.Id
            );
        }
        for (
            SBQQ__ProductOption__c eachOptionProduct : CPQProductOptionsSelector.newInstance()
                .selectByProductNames(optionProductNames, parentQuoteLinesByName.keySet())
        ) {
            optionQuoteLines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Quote__c,
                    CurrencyIsoCode = quote.CurrencyIsoCode,
                    SBQQ__PricebookEntryId__c = String.valueOf(
                        pricebookEntryIdByProductName.get(
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                    ),
                    SBQQ__DynamicOptionId__c = String.valueOf(eachOptionProduct.SBQQ__Feature__c),
                    SBQQ__RequiredBy__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .Id,
                    SBQQ__Bundle__c = false,
                    SBQQ__Description__c = eachOptionProduct.SBQQ__OptionalSKU__r.Description,
                    SBQQ__ProductSubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__Quantity__c = 1,
                    SBQQ__SpecialPriceType__c = SPECIAL_PRICE_TYPE_CUSTOM,
                    SBQQ__SpecialPrice__c = String.isBlank(
                            optionProductNameWithParentProductNameForInstantIngestion.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.fee
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForInstantIngestion.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .fee
                          ),
                    Requested_Commission__c = eachOptionProduct.SBQQ__OptionalSKU__r.Name ==
                        SERVICE_RATE_CA
                        ? decimal.valueOf(System.Label.Service_Rate_CA_Commission)
                        : String.isBlank(
                                  optionProductNameWithParentProductNameForInstantIngestion.get(
                                          eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                          eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                      )
                                      ?.commission
                              )
                              ? null
                              : Decimal.valueOf(
                                    optionProductNameWithParentProductNameForInstantIngestion.get(
                                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                        )
                                        .commission.removeEnd('%')
                                ),
                    Trial_Fee__c = String.isBlank(
                            optionProductNameWithParentProductNameForInstantIngestion.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.trialFee
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForInstantIngestion.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .trialFee
                          ),
                    Segment__c = quote.Segment__c,
                    Trial_Period__c = String.isBlank(
                        optionProductNameWithParentProductNameForInstantIngestion.get(
                                eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                eachOptionProduct.SBQQ__OptionalSKU__r.Name
                            )
                            ?.trialDuration
                    )
                    ? null
                        :
                            optionProductNameWithParentProductNameForInstantIngestion.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                .trialDuration
                          ,
                    Trial_Commission__c = String.isBlank(
                            optionProductNameWithParentProductNameForInstantIngestion.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.trialCommission
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForInstantIngestion.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .trialCommission.removeEnd('%')
                          ),
                    SBQQ__OptionType__c = OPTION_TYPE_COMPONENT,
                    SBQQ__OptionLevel__c = 1,
                    SBQQ__SubscriptionBase__c = SUBSCRIPTION_BASE_LIST,
                    SBQQ__SubscriptionPricing__c = SUBSCRIPTION_PRICING_FIXED_PRICE,
                    SBQQ__SubscriptionScope__c = QUOTE_TYPE,
                    SBQQ__SubscriptionTerm__c = 1,
                    SBQQ__SubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__ListPrice__c = 0,
                    SBQQ__NetPrice__c = 0,
                    SBQQ__RegularPrice__c = 0,
                    SBQQ__Product__c = eachOptionProduct.SBQQ__OptionalSKU__c,
                    SBQQ__ProductOption__c = eachOptionProduct.Id,
                    SBQQ__Group__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Group__c,
                    SBQQ__Number__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Number__c, //same Number field is stamped from the parent quote line to maintain the hierarchical (parent-child) relationship.
                    Unique_Identifier__c = uuid,
                    Pricing_Search_Complete__c = true
                )
            );
        }
        return optionQuoteLines;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private List<SBQQ__QuoteLine__c> ssobCreateQuoteLineOptionsByParent(
        Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForSsob,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        Map<String, List<SBQQ__DiscountTier__c>> discountTiersByUUID,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        String uuid
    ) {
        List<SBQQ__QuoteLine__c> optionQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, Id> pricebookEntryIdByProductName = new Map<String, Id>();
        for (
            PricebookEntry eachPriceboookEntry : PricebookEntriesSelector.newInstance()
                .selectByProductNamesAndCurrency(optionProductNames, quote.CurrencyIsoCode)
        ) {
            pricebookEntryIdByProductName.put(
                eachPriceboookEntry.Product2.Name,
                eachPriceboookEntry.Id
            );
        }
        for (
            SBQQ__ProductOption__c eachOptionProduct : CPQProductOptionsSelector.newInstance()
                .selectByProductNames(optionProductNames, parentQuoteLinesByName.keySet())
        ) {
            optionQuoteLines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Quote__c,
                    CurrencyIsoCode = quote.CurrencyIsoCode,
                    SBQQ__PricebookEntryId__c = String.valueOf(
                        pricebookEntryIdByProductName.get(
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                    ),
                    SBQQ__DynamicOptionId__c = String.valueOf(eachOptionProduct.SBQQ__Feature__c),
                    SBQQ__RequiredBy__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .Id,
                    SBQQ__Bundle__c = false,
                    SBQQ__Description__c = eachOptionProduct.SBQQ__OptionalSKU__r.Description,
                    SBQQ__ProductSubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__Quantity__c = 1,
                    SBQQ__SpecialPriceType__c = SPECIAL_PRICE_TYPE_CUSTOM,
                    SBQQ__SpecialPrice__c = (optionProductNameWithParentProductNameForSsob.get(
                                eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                eachOptionProduct.SBQQ__OptionalSKU__r.Name
                            )
                            .fee) == null
                        ? null
                        : optionProductNameWithParentProductNameForSsob.get(
                                  eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                  eachOptionProduct.SBQQ__OptionalSKU__r.Name
                              )
                              .fee,
                    Requested_Commission__c = (optionProductNameWithParentProductNameForSsob.get(
                                eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                eachOptionProduct.SBQQ__OptionalSKU__r.Name
                            )
                            .commission) == null
                        ? null
                        : optionProductNameWithParentProductNameForSsob.get(
                                  eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                  eachOptionProduct.SBQQ__OptionalSKU__r.Name
                              )
                              .commission,
                    SBQQ__OptionType__c = OPTION_TYPE_COMPONENT,
                    SBQQ__OptionLevel__c = 1,
                    SBQQ__SubscriptionBase__c = SUBSCRIPTION_BASE_LIST,
                    SBQQ__SubscriptionPricing__c = SUBSCRIPTION_PRICING_FIXED_PRICE,
                    SBQQ__SubscriptionScope__c = QUOTE_TYPE,
                    SBQQ__SubscriptionTerm__c = 1,
                    SBQQ__SubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__ListPrice__c = 0,
                    SBQQ__NetPrice__c = 0,
                    SBQQ__RegularPrice__c = 0,
                    SBQQ__Product__c = eachOptionProduct.SBQQ__OptionalSKU__c,
                    SBQQ__ProductOption__c = eachOptionProduct.Id,
                    SBQQ__Group__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Group__c,
                    SBQQ__Number__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Number__c, //same Number field is stamped from the parent quote line to maintain the hierarchical (parent-child) relationship.
                    Unique_Identifier__c = uuid,
                    Base_Fee_Distance__c = optionProductNameWithParentProductNameForSsob.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                        .deliveryRadiusMiles,
                    Incremental_Fee_Per_Mile_Driven__c = optionProductNameWithParentProductNameForSsob.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                        .costPerMile,
                    Max_Distance__c = optionProductNameWithParentProductNameForSsob.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                        .maxDeliveryDistanceRadius,
                    Evaluation_Period__c = optionProductNameWithParentProductNameForSsob.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                        .volumeTimePeriod,
                    Level__c = optionProductNameWithParentProductNameForSsob.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                        .businessLevelForVolumeTier1
                )
            );
        }
        for (List<SBQQ__DiscountTier__c> discountTiers : discountTiersByUUID.values()) {
            for (SBQQ__DiscountTier__c eachdiscountTier : discountTiers) {
                for (SBQQ__QuoteLine__c eachQuoteLine : optionQuoteLines) {
                    if (
                        eachdiscountTier.SBQQ__Schedule__r.SBQQ__Product__c ==
                        eachQuoteLine.SBQQ__Product__c &&
                        eachQuoteLine.Unique_Identifier__c ==
                        eachdiscountTier.Unique_Identifier__c &&
                        eachQuoteLine.SBQQ__DiscountTier__c == null
                    ) {
                        optionQuoteLines.add(eachQuoteLine.clone());
                        eachQuoteLine.SBQQ__DiscountTier__c = eachdiscountTier.Id;
                        break;
                    }
                }
            }
        }
        return optionQuoteLines;
    }

    //to create child quote lines for mx portal
    private List<SBQQ__QuoteLine__c> mxPortalCreateQuoteLineOptionsByParent(
        Map<String, MxPortalPayloadParser.ProductOptionsDetails> optionProductNameWithParentProductNameForMxPortal,
        Map<String, SBQQ__QuoteLine__c> parentQuoteLinesByName,
        SBQQ__Quote__c quote,
        Pricebook2 pricebook,
        String uuid
    ) {
        List<SBQQ__QuoteLine__c> optionQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, Id> pricebookEntryIdByProductName = new Map<String, Id>();
        for (
            PricebookEntry eachPriceboookEntry : PricebookEntriesSelector.newInstance()
                .selectByProductNamesAndCurrency(optionProductNames, quote.CurrencyIsoCode)
        ) {
            pricebookEntryIdByProductName.put(
                eachPriceboookEntry.Product2.Name,
                eachPriceboookEntry.Id
            );
        }
        for (
            SBQQ__ProductOption__c eachOptionProduct : CPQProductOptionsSelector.newInstance()
                .selectByProductNames(optionProductNames, parentQuoteLinesByName.keySet())
        ) {
            optionQuoteLines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Quote__c,
                    CurrencyIsoCode = quote.CurrencyIsoCode,
                    SBQQ__PricebookEntryId__c = String.valueOf(
                        pricebookEntryIdByProductName.get(
                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                        )
                    ),
                    SBQQ__DynamicOptionId__c = String.valueOf(eachOptionProduct.SBQQ__Feature__c),
                    SBQQ__RequiredBy__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .Id,
                    SBQQ__Bundle__c = false,
                    SBQQ__Description__c = eachOptionProduct.SBQQ__OptionalSKU__r.Description,
                    SBQQ__ProductSubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__Quantity__c = 1,
                    SBQQ__SpecialPriceType__c = SPECIAL_PRICE_TYPE_CUSTOM,
                    SBQQ__SpecialPrice__c = String.isBlank(
                            optionProductNameWithParentProductNameForMxPortal.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.fee
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForMxPortal.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .fee
                          ),
                    Requested_Commission__c = eachOptionProduct.SBQQ__OptionalSKU__r.Name ==
                        SERVICE_RATE_CA
                        ? decimal.valueOf(System.Label.Service_Rate_CA_Commission)
                        : String.isBlank(
                                  optionProductNameWithParentProductNameForMxPortal.get(
                                          eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                          eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                      )
                                      .commission
                              )
                              ? null
                              : Decimal.valueOf(
                                    optionProductNameWithParentProductNameForMxPortal.get(
                                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                            eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                        )
                                        .commission.removeEnd('%')
                                ),
                    Trial_Fee__c = String.isBlank(
                            optionProductNameWithParentProductNameForMxPortal.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.trialFee
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForMxPortal.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .trialFee
                          ),
                    Trial_Commission__c = String.isBlank(
                            optionProductNameWithParentProductNameForMxPortal.get(
                                    eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                    eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                )
                                ?.trialCommission
                        )
                        ? null
                        : Decimal.valueOf(
                              optionProductNameWithParentProductNameForMxPortal.get(
                                      eachOptionProduct.SBQQ__ConfiguredSKU__r.Name +
                                      eachOptionProduct.SBQQ__OptionalSKU__r.Name
                                  )
                                  .trialCommission.removeEnd('%')
                          ),
                    SBQQ__OptionType__c = OPTION_TYPE_COMPONENT,
                    SBQQ__OptionLevel__c = 1,
                    SBQQ__SubscriptionBase__c = SUBSCRIPTION_BASE_LIST,
                    SBQQ__SubscriptionPricing__c = SUBSCRIPTION_PRICING_FIXED_PRICE,
                    SBQQ__SubscriptionScope__c = QUOTE_TYPE,
                    SBQQ__SubscriptionTerm__c = 1,
                    SBQQ__SubscriptionType__c = SUBSCRIPTION_TYPE_EVERGREEN,
                    SBQQ__ListPrice__c = 0,
                    SBQQ__NetPrice__c = 0,
                    SBQQ__RegularPrice__c = 0,
                    SBQQ__Product__c = eachOptionProduct.SBQQ__OptionalSKU__c,
                    SBQQ__ProductOption__c = eachOptionProduct.Id,
                    SBQQ__Group__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Group__c,
                    SBQQ__Number__c = parentQuoteLinesByName.get(
                            eachOptionProduct.SBQQ__ConfiguredSKU__r.Name
                        )
                        .SBQQ__Number__c, //same Number field is stamped from the parent quote line to maintain the hierarchical (parent-child) relationship.
                    Unique_Identifier__c = uuid
                )
            );
        }
        return optionQuoteLines;
    }

    /**
     * @description It is used to create the discount tiers by the received details
     * from ssob payload.
     * @param ssobPayload
     * @return List<SBQQ__DiscountTier__c>
     */
    public List<SBQQ__DiscountTier__c> createDiscountTiers(
        SSOBOnboardingPayloadParser ssobPayload
    ) {
        Map<String, Object> ssobPayloadKeyToValue = new Map<String, Object>();
        List<SBQQ__DiscountTier__c> discountTiers = new List<SBQQ__DiscountTier__c>();
        Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails> optionProductNameWithProductDetails = new Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails>();
        Map<String, SBQQ__DiscountSchedule__c> discountScheduleByProductName = new Map<String, SBQQ__DiscountSchedule__c>();
        for (
            SSOBOnboardingPayloadParser.ProductOptionsDetails eachProductOption : ssobPayload.opportunity.orderProducts.productOptions
        ) {
            optionProductNameWithProductDetails.put(eachProductOption.name, eachProductOption);
        }
        for (
            SBQQ__DiscountSchedule__c eachDiscountSchedule : DiscountSchedulesSelector.newInstance()
                .selectByProductName(optionProductNameWithProductDetails.keySet())
        ) {
            discountScheduleByProductName.put(
                eachDiscountSchedule.SBQQ__Product__r.Name,
                eachDiscountSchedule
            );
        }
        for (
            SSOBOnboardingPayloadParser.ProductOptionsDetails eachProductOption : ssobPayload.opportunity.orderProducts.productOptions
        ) {
            ssobPayloadKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(eachProductOption)
            );
            if (Integer.valueOf(ssobPayloadKeyToValue.get(NUMBER_OF_VOLUME_TIER)) == null) {
                continue;
            }
            for (
                Integer i = 1;
                i < Integer.valueOf(ssobPayloadKeyToValue.get(NUMBER_OF_VOLUME_TIER));
                i++
            ) {
                String name = (String) ssobPayloadKeyToValue.get(NAME_KEY);
                discountTiers.add(
                    new SBQQ__DiscountTier__c(
                        SBQQ__LowerBound__c = (Decimal) ssobPayloadKeyToValue.get(
                            VOLUME_TIER_COMMITMENT_TIER + i
                        ),
                        SBQQ__UpperBound__c = (Decimal) ssobPayloadKeyToValue.get(
                            VOLUME_TIER_COMMITMENT_TIER + (i + 1)
                        ),
                        SBQQ__Schedule__c = discountScheduleByProductName.get(name).Id,
                        Name = (String) TIER_KEY + i,
                        Unique_Identifier__c = ssobPayload.uuid
                    )
                );
            }
        }
        return discountTiers;
    }

    /**
     * @description It is used to update the quote status to Contract Signed.
     * @JIRA# LEM-14648
     * @param recordIdsByPayload
     */
    public void updateInstantIngestionQuotesToOrdered(Set<Id> recordIdsByPayload) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        Map<Id, SBQQ__Quote__c> quotesByIds = new Map<Id, SBQQ__Quote__c>(
            QuotesSelector.newInstance().selectById(recordIdsByPayload)
        );
        for (Id eachQuoteIdToUpdate : recordIdsByPayload) {
            if (
                quotesByIds.containskey(eachQuoteIdToUpdate) &&
                quotesByIds.get(eachQuoteIdToUpdate).Slack_Notification_To_Opportunity_Owner__c ==
                false
            ) {
                uowUpdateHelper.registerUpdate(
                    new SBQQ__Quote__c(Id = eachQuoteIdToUpdate, SBQQ__Ordered__c = true)
                );
            }
        }
        uow.commitWork();
        updateInboundIngestionLogForSuccess(recordIdsByPayload);
    }

    /**
     * @description It is used to update the quote primary status.
     * @param recordIdsByPayload
     */
    public void updateInstantIngestionQuotesToPrimaryAndContractSigned(Set<Id> recordIdsByPayload) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        for (Id eachQuoteIdToUpdate : recordIdsByPayload) {
            uowUpdateHelper.registerUpdate(
                new SBQQ__Quote__c(
                    Id = eachQuoteIdToUpdate,
                    SBQQ__Primary__c = true,
                    SBQQ__Status__c = STATUS_CONTRACT_SIGNED
                )
            );
        }
        uow.commitWork();
        InstantIngestorEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_UPDATE_QUOTES_TO_CONTRACT_SIGNED => JSON.serialize(recordIdsByPayload)
            }
        );
    }

    /**
     * @description It is used to update the quote fields.
     * @param quoteId
     * @param mxPortalPayloadWrapperByUUID
     * @param mxPortalEventType
     */
    public void updateQuoteFieldsMappingOnAmendmentQuote(
        Id quoteId,
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID,
        String mxPortalEventType
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        List<MxPortalPayloadParser> mxPortalParser = mxPortalPayloadWrapperByUUID.values();
        uowUpdateHelper.registerUpdate(
            new SBQQ__Quote__c(
                Id = quoteId,
                Signed_Contract_link__c = mxPortalParser[0].store.vendorContractRecord,
                Contract_Signed_Date__c = System.today()
            )
        );
        SBQQ.TriggerControl.disable();
        uow.commitWork();
        SBQQ.TriggerControl.enable();
    }

    /**
     * @description It is used to update the quote to send slack notifications.
     * @JIRA# LEM-14648
     * @param recordIdsByPayload
     */
    public void updateInstantIngestionQuotesForSlackNotifications(Set<Id> recordIdsByPayload) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uow.registerWork(uowUpdateHelper);
        for (Id eachQuoteIdToUpdate : recordIdsByPayload) {
            uowUpdateHelper.registerUpdate(
                new SBQQ__Quote__c(
                    Id = eachQuoteIdToUpdate,
                    Slack_Notification_To_Opportunity_Owner__c = true
                )
            );
        }
        uow.commitWork();
        updateInboundIngestionLogForSuccess(recordIdsByPayload);
    }
    /**
     * @description It is used to update the success status on inbound ingestion log record.
     * @JIRA# LEM-16085
     * @param recordIdsByPayload
     */
    private void updateInboundIngestionLogForSuccess(Set<Id> recordIdsByPayload) {
        Set<String> uniqueIdentifiersSet = new Set<String>();
        List<Inbound_ingestion_Log__c> inboundIngestionLogs = new List<Inbound_ingestion_Log__c>();
        for (
            SBQQ__Quote__c eachQuote : QuotesSelector.newInstance().selectById(recordIdsByPayload)
        ) {
            uniqueIdentifiersSet.add(eachQuote.Unique_Identifier__c);
        }
        for (
            Inbound_ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectInboundIngestionLogsByUUIDs(uniqueIdentifiersSet)
        ) {
            inboundIngestionLogs.add(eachInboundIngestionLog);
        }
        if (inboundIngestionLogs.isEmpty()) {
            return;
        }
        IngestionErrorHandlingService.updateInboundIngestionLogForSuccess(
            inboundIngestionLogs[0],
            SUCCESS_MESSAGE
        );
    }

    /**
     * @description It is used to skip the creation of quote line if commission and fee both are
     * sent as null in payload.
     * @JIRA LEM-21655
     * @param productName
     * @param productCommission
     * @param productFee
     * @return Boolean
     * TO DO: Currently it is applicable only for Dashpass quote line and will be made as
     *        generic post go-live to skip any line creation where commission and fee are received
     *        as null in the payload.
     */
    private Boolean isEligibleToSkipQuoteLineCreation(
        String productName,
        String productCommission,
        String productFee
    ) {
        return (productName == PRODUCT_NAME_DASHPASS &&
        String.isBlank(productCommission) &&
        String.isBlank(productFee));
    }
}